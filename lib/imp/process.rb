# encoding: utf-8
module Imp

  class Process

    EXIT_SIGNALS = ["QUIT", "TERM", "INT", "HUP", "USR2", "USR1"]

    def initialize(name, log_file = nil, &block)

      @name     = name
      @log_file = log_file
      @block    = block

    end # new

    def start

      call_daemon
      self

    end # start

    def name
      @name
    end # name

    def inspect

      "#<Imp::Process\n" <<
      " pid:      #{@pid ? @pid.pid : 0},\n" <<
      " name:     #{@name},\n" <<
      " logs:     #{@log_file},\n" <<
      " block:    #{@block.inspect}>\n"

    end # inspect

    private

    def trap_signals

      # Если работаем из консоли или запускаем rake-задачу,
      # игнориуем сигналы, завершающие работу демона.
      return if defined?(::IRB) || defined?(::Rake)

      # Завершение работы при получении указанных сигналов
      ::Imp::Process::EXIT_SIGNALS.each do |sig|

        trap(sig) {
          @pid.stop('QUIT')
        }

      end # each

      at_exit {
        @pid.stop('QUIT')
      }

    end # trap_signals

    def redirect_io

      begin
        ::STDOUT.reopen @log_file, "a"
      rescue
        begin ::STDOUT.reopen "/dev/null"; rescue ::Imp::Exception; end
      end

      begin ::STDERR.reopen ::STDOUT; rescue ::Imp::Exception; end

      ::STDIN.sync  = true
      ::STDOUT.sync = true
      ::STDERR.sync = true

    end # redirect_io

    def call_daemon

      # for parent
      trap_signals

      rd, wr = ::IO.pipe

      if (tmppid = ::Process.fork)

        # in parent process
        wr.close
        @pid = ::Imp::Pid.new(rd.read.to_i)
        rd.close

        ::Process.waitpid(tmppid)
        ::Process.detach(tmppid)

        msg "was started"

      else

        # in child process
        rd.close

        # Detach from the controlling terminal
        raise ::Imp::Exception.new('Cannot detach from controlling terminal') unless ::Process.setsid
        exit! if fork

        @pid = ::Imp::Pid.new(::Process.pid)

        wr.write(@pid.pid)
        wr.close

        $0 = @name

        ::Dir.chdir '/'
        ::File.umask 0000

        redirect_io

        msg "was started"

        # Завершение работы процесса
        at_exit {
          msg "successfully stopped"
        }

        ["QUIT", "TERM"].each do |sig|

          trap(sig) {
            msg "successfully stopped"
          }

        end # each

        @block.call
        exit!

      end # if

    end # call_daemon

    def msg(message)
      puts "[#{::Time.now}] Process [#{@pid.pid}] #{message}."
    end # msg

  end # Process

end # Imp