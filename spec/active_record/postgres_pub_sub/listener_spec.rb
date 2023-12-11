# frozen_string_literal: true

RSpec.describe ActiveRecord::PostgresPubSub::Listener, cleaner_strategy: :truncation do
  let(:channel) { "pub_sub_test" }

  describe ".listen" do
    let(:listener_options) { Hash.new }
    let!(:state) do
      OpenStruct.new(started: 0,
                     count: 0,
                     timeout_count: 0,
                     payloads: [],
                     received_channels: [])
    end
    let!(:listener_thread) do
      Thread.new do
        listener_loop(**listener_options)
      ensure
        ActiveRecord::Base.clear_active_connections!
      end
    end

    after do
      listener_thread.terminate
      listener_thread.join
    end

    it "invokes the notify block when it receives a notification" do
      wait_for_started

      ActiveRecord::Base.transaction do
        3.times { |i| notify(i) }
      end

      wait_for("notification received") { state.count > 0 }
      expect(state.payloads).to match_ordered_array([nil])
      expect(state.count).to eq(1)
    end

    context "when using 1-arg version of #on_notify" do
      let!(:listener_thread) do
        Thread.new do
          listener_loop(**listener_options) do |listener|
            listener.on_notify do |payload|
              state.count += 1
              state.payloads << payload
            end
          end
        ensure
          ActiveRecord::Base.clear_active_connections!
        end
      end

      it "invokes the single arg. notify block when it receives a notification" do
        wait_for_started

        ActiveRecord::Base.transaction do
          3.times { |i| notify(i) }
        end

        wait_for("notification received") { state.count > 0 }
        expect(state.payloads).to match_ordered_array([nil])
        expect(state.count).to eq(1)
      end
    end

    context "when using notify_only=false" do
      let(:listener_options) do
        Hash[notify_only: false]
      end

      it "invokes the notify block with the payload of each notification" do
        wait_for_started

        ActiveRecord::Base.transaction do
          3.times { |i| notify(i) }
        end

        wait_for("notification received") { state.count == 3 }
        expect(state.payloads).to match_ordered_array(%w(0 1 2))
      end
    end

    context "when a timeout is set" do
      let(:listener_options) do
        Hash[listen_timeout: 0.001]
      end

      it "invokes the timeout block if a notification is not received" do
        wait_for_started

        wait_for("listener timeout") { state.timeout_count > 0 }
      end
    end

    context "when listen to multiple channels" do
      let(:channels) { %w(pub_sub_test1 pub_sub_test2) }
      let(:listener_options) { Hash[listen_to: channels, notify_only: false] }

      it "invokes the notify multiple channels block with notification notify to diffrent channels" do
        wait_for_started

        ActiveRecord::Base.transaction do
          channels.each { |c| notify(c, notify_to: c) }
        end

        wait_for("notification received") { state.received_channels.count > 0 }
        expect(state.payloads).to match_ordered_array(channels)
        expect(state.received_channels).to match_ordered_array(channels)
      end
    end

    def notify(payload, notify_to: channel)
      # rubocop:disable Ezcater/RailsTopLevelSqlExecute
      ActiveRecord::Base.connection.execute("NOTIFY #{notify_to}, '#{payload}'")
      # rubocop:enable Ezcater/RailsTopLevelSqlExecute
    end

    def wait_for_started
      wait_for("listener started") { state.started > 0 }
    end

    def wait_for(message, timeout: 5, poll_interval: 0.001)
      expires_at = Time.now + timeout
      loop do
        return if yield
        raise "Timed out waiting for #{message}" if Time.now > expires_at

        sleep(poll_interval)
      end
    end

    def listener_loop(listen_to: [channel], listen_timeout: nil, exclusive_lock: true, notify_only: true)
      described_class.listen(*listen_to,
                             listen_timeout: listen_timeout,
                             exclusive_lock: exclusive_lock,
                             notify_only: notify_only) do |listener|
        listener.on_start do
          state.started += 1
        end

        listener.on_notify do |payload, channel|
          state.count += 1
          state.payloads << payload
          state.received_channels << channel
        end

        listener.on_timeout do
          state.timeout_count += 1
        end

        yield(listener) if block_given?
      end
    end
  end
end
