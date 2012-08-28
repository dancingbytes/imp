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

      return false if @pid.nil? || @stoping
      msg "is trying to stop.."
      @stoping = true

      begin
        self.signal(sig)
        sleep(0.5)
      rescue ::Errno::ESRCH
        @stoping = false
        msg "successfully stopped"
        return true
      end

      begin

        5.times {

          if self.running?
            sleep(1)
            self.signal('KILL')
          else
            msg "successfully stopped"
            return true
          end

        }

        if self.running?
          msg "unable to forcefully kill"
          return false
        else
          msg "successfully stopped"
          return true
        end

      rescue ::Errno::ESRCH
        msg "successfully stopped"
        return true
      rescue => e
        msg "unable to forcefully kill. Error: #{e.inspect}"
        return false
      ensure
        @stoping = false
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

  end # Pid

end # Imp