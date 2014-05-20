require 'socket'

module Push
  module Daemon
    class Feeder
      extend DatabaseReconnectable
      extend InterruptibleSleep

      RESERVATION_TIME = 5.minutes # this can add latency for delivery if a daemon dies
      BATCH_SIZE = 300

      def self.name
        "Feeder"
      end

      def self.us
        Socket.gethostname + '_' + $$.to_s
      end

      def self.start(config)
        reconnect_database unless config.foreground

        loop do
          break if @stop
          sweep  # re-queue expired jobs

          with_database_reconnect_and_retry(name) do
            begin
              num_reserved = Push::Message.ready_for_delivery.where(:reserved_by => nil).limit(BATCH_SIZE).update_all(
                {:reserved_by => us, :reserved_until => Time.now + RESERVATION_TIME }
              )
              enqueue_notifications if num_reserved > 0

            end while num_reserved > 0
          end

          interruptible_sleep config.push_poll
        end
      end

      def self.stop
        @stop = true
        interrupt_sleep
      end

      protected

      def self.sweep
        begin
          with_database_reconnect_and_retry(name) do
            # re-queue notifications with stale reservations (in case other daemon died)
            Push::Message.ready_for_delivery.where("reserved_until < ?", Time.now).update_all(
              {:reserved_by => nil, :reserved_until => nil}
            )
          end
        rescue StandardError => e
          Push::Daemon.logger.error(e)
        end
      end

      def self.enqueue_notifications
        begin
          ready_apps = Push::Daemon::App.ready

          Push::Message.ready_for_delivery.where(:reserved_by => us).find_each do |notification|
            if ready_apps.include?(notification.app) && (notification.reserved_until >= Time.now)
              Push::Daemon::App.deliver(notification) unless notification.delivered
            end
          end
        rescue StandardError => e
          Push::Daemon.logger.error(e)
        end
      end
    end
  end
end
