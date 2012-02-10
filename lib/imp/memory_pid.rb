# encoding: utf-8
module Imp

  class MemoryPid

    attr_accessor :pid

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

    def initialize(master_pid)
      @master_pid = master_pid || 0
    end # new

    def pid=(numeric_pid)
      @pid = numeric_pid
    end # pid=

    def owner?(proc_pid)
      @master_pid == proc_pid
    end # owner?

    def running?
      self.class.running?(@pid)
    end # running?

    def stop(sig = 'QUIT')

      return false if @pid.nil? || @stoping
      @stoping = true

      begin
        ::Process.kill(sig, @pid)
      rescue ::Errno::ESRCH
        @stoping = false
        return true
      end

      begin

        5.times {

          if self.running?
            sleep(1)
            ::Process.kill('KILL', @pid)
          end

        }

        if self.running?
          ::STDOUT.puts "Unable to forcefully kill process with pid #{@pid}."
          ::STDOUT.flush
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

  end # MemoryPid

end # Imp