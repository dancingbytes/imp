# encoding: utf-8
require 'timeout'

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

    def initialize
    end # new

    def pid=(numeric_pid)

      @pid ||= numeric_pid
      @pid

    end # pid=

    def running?
      self.class.running?(@pid)
    end # running?

    def stop(sig = 'QUIT')

      return false if @pid.nil?

      begin
        ::Process.kill(sig, @pid)
      rescue ::Errno::ESRCH
      end

      begin

        ::Timeout::timeout(20) {

          if self.running?
            sleep(0.5)
            ::Process.kill('KILL', @pid)
          end
          
        }
        return true

      rescue ::Timeout::Error
        puts "Unable to forcefully kill process with pid #{@pid}."
        ::STDOUT.flush
        return false
      rescue ::Errno::ESRCH
        return true
      end

    end # stop

  end # MemoryPid

end # Imp