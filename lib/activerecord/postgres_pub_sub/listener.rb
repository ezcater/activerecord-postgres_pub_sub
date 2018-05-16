# frozen_string_literal: true

require "private_attr"
require "with_advisory_lock"

module ActiveRecord
  module PostgresPubSub
    class Listener
      extend PrivateAttr

      private_attr_reader :on_notify_blk, :on_start_blk, :on_timeout_blk,
                          :channel, :listen_timeout, :exclusive_lock, :notify_only

      def self.listen(channel, listen_timeout: nil, exclusive_lock: true, notify_only: true)
        listener = new(channel,
                       listen_timeout: listen_timeout,
                       exclusive_lock: exclusive_lock,
                       notify_only: notify_only)
        yield(listener) if block_given?
        listener.listen
      end

      def initialize(channel, listen_timeout: nil, exclusive_lock: true, notify_only: true)
        @channel = channel
        @listen_timeout = listen_timeout
        @exclusive_lock = exclusive_lock
        @notify_only = notify_only
      end

      def on_notify(&blk)
        @on_notify_blk = blk
      end

      def on_start(&blk)
        @on_start_blk = blk
      end

      def on_timeout(&blk)
        @on_timeout_blk = blk
      end

      def listen
        with_connection do |connection|
          on_start_blk&.call

          loop do
            wait_for_notify(connection) do |payload|
              notify_only ? on_notify_blk.call : on_notify_blk.call(payload)
            end
          end
        end
      end

      private

      def with_connection
        ActiveRecord::Base.connection_pool.with_connection do |connection|
          with_optional_lock do
            connection.execute("LISTEN #{channel}")

            begin
              yield(connection)
            ensure
              connection.execute("UNLISTEN #{channel}")
            end
          end
        end
      end

      def with_optional_lock
        if exclusive_lock
          ActiveRecord::Base.with_advisory_lock(lock_name) { yield }
        else
          yield
        end
      end

      def lock_name
        "#{channel}-listener"
      end

      def empty_channel(connection)
        while connection.wait_for_notify(0)
          # call until nil is returned
        end
      end

      def wait_for_notify(connection)
        connection_pid = connection.raw_connection.backend_pid
        event_result = connection.raw_connection.wait_for_notify(listen_timeout) do |_event, pid, payload|
          if pid != connection_pid
            empty_channel(connection.raw_connection) if notify_only
            yield(payload)
          end
        end

        on_timeout_blk&.call if event_result.nil?
      end
    end
  end
end
