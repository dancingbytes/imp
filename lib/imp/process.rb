# encoding: utf-8
module Imp

  class Process

    def initialize(name, log_file = nil, closefd = true, &block)

      @name     = name
      @log_file = log_file
      @block    = block
      @closefd  = closefd === true

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

    def call_daemon

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
        ::Process::exit! if ::Process.fork

        @pid = ::Imp::Pid.new(::Process.pid)

        wr.write(@pid.pid)
        wr.close

        $0 = @name

        ::Dir.chdir '/'
        ::File.umask 0000

        close_fd if @closefd
        redirect_io
        trap_signals

        msg "was started"

        begin
          @block.call
        rescue => ex

          msg "has errors.."
          puts "#{ex.message} (#{ex.class}): #{ex.backtrace.join("\r")}"

        ensure
          ::Process::exit(0)
        end

      end # if

    end # call_daemon

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

    def close_fd

      ::ObjectSpace.each_object(::IO) do |io|

        unless [::STDIN, ::STDOUT, ::STDERR].include?(io)

          begin
            io.close unless io.closed?
          rescue
          end

        end # unless

      end # each_object

    end # close_fd

    def trap_signals

      # Завершение работы процесса
      ::Imp::EXIT_SIGNALS.each do |sig|

        trap(sig) {

          unless @pid.stop(sig)
            msg "successfully stopped"
          end

        }

      end # each

      at_exit {
        msg "successfully stopped"
      }

    end # trap_signals

    def msg(message)
      puts "[#{::Time.now}] Process [#{@pid.pid}] #{message}."
    end # msg

  end # Process

end # Imp