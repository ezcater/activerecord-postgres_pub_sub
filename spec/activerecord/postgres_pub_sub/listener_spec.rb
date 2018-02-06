RSpec.describe ActiveRecord::PostgresPubSub::Listener, cleaner_strategy: :truncation do
  let(:channel) { "pub_sub_test" }

  describe ".listen" do
    let(:listener_options) { Hash.new }
    let!(:state) do
      OpenStruct.new(started: 0,
                     count: 0,
                     timeout_count: 0,
                     payloads: [])
    end

    before do
      @listener_thread = Thread.new do
        begin
          listener_loop(listener_options)
        ensure
          ActiveRecord::Base.clear_active_connections!
        end
      end
    end

    after do
      @listener_thread.terminate
      @listener_thread.join
    end

    it "invokes the notify block when it receives a notification" do
      wait_for_started

      ActiveRecord::Base.transaction do
        3.times { |i| notify(i) }
      end

      wait_for("notification received") { state.count > 0 }
      expect(state.payloads).to eq([nil])
      expect(state.count).to eq(1)
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
        expect(state.payloads).to eq(%w(0 1 2))
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

    def notify(payload)
      ActiveRecord::Base.connection.execute("NOTIFY #{channel}, '#{payload}'")
    end

    def wait_for_started
      wait_for("listener started") { state.started > 0 }
    end

    def wait_for(message, timeout: 5, poll_interval: 0.001)
      expires_at = Time.now + 5
      loop do
        return if yield
        if Time.now > expires_at
          raise "Timed out waiting for #{message}"
        else
          sleep(poll_interval)
        end
      end
    end

    def listener_loop(listen_timeout: nil, exclusive_lock: true, notify_only: true)
      described_class.listen(channel,
                             listen_timeout: listen_timeout,
                             exclusive_lock: exclusive_lock,
                             notify_only: notify_only) do |listener|
        listener.on_start do
          state.started += 1
        end

        listener.on_notify do |payload|
          state.count += 1
          state.payloads << payload
        end

        listener.on_timeout do
          state.timeout_count += 1
        end
      end
    end
  end
end
