# encoding: utf-8
module Imp

  class MemoryPid

    attr_accessor :pid

    include ::Imp::Signals

    class << self

      def running?(pid)

        return false if pid.nil?

        begin
          ::Process.kill(0, pid)
          return true
        rescue ::Errno::ESRCH
          return false
        end

      end # running?

    end # class << self

    def initialize(pid)
      @pid = pid
    end # new

    def pid; @pid; end

    def running?
      self.class.running?(@pid)
    end # running?

    alias :exists? :running?
    alias :exist?  :running?

    def signal(sig)
      ::Process.kill(sig, @pid)
    end # signal

    def stop(sig = 'QUIT')

      return false if @pid.nil? || @stoping
      @stoping = true

      begin
        self.signal(sig)
      rescue ::Errno::ESRCH
        @stoping = false
        return true
      end

      begin

        5.times {

          if self.running?
            sleep(1)
            self.signal('KILL')
          end

        }

        if self.running?
          puts "Unable to forcefully kill process with pid #{@pid}."
          return false
        else
          return true
        end

      rescue ::Errno::ESRCH
        return true
      rescue => e
        return false
      ensure
        @stoping = false
      end

    end # stop

    def inspect; nil; end

  end # MemoryPid

end # Imp