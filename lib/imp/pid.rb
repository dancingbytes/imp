# encoding: utf-8
module Imp

  class Pid

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

      return false if @stoping || !running?
      @stoping = true

      msg "is trying to stop.."

      begin
        self.signal(sig)
        sleep(0.5)
      rescue ::Errno::ESRCH
        terminated
      end

      begin

        5.times {

          if self.running?
            sleep(1)
            self.signal('KILL')
          end

        }

        if self.running?
          msg "unable to forcefully kill"
          return false
        else
          terminated
        end

      rescue ::Errno::ESRCH
        terminated
      rescue => ex

        @stoping = false
        msg "unable to forcefully kill.\n\n#{ex.backtrace.join('\n')}: #{ex.message} (#{ex.class})"
        return false

      end

    end # stop

    def inspect

      "#<Imp::Pid\n" <<
      " pid:      #{@pid || 0},\n" <<
      " running:  #{self.running?}>\n"

    end # inspect

    private

    def msg(message)
      puts "[#{::Time.now}] Process [#{@pid}] #{message}."
    end # msg

    def terminated

      @stoping = false
      msg "successfully stopped"

    end # terminated

  end # Pid

end # Imp