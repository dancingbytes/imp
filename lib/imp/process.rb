# encoding: utf-8
module Imp

  class Process

    def initialize(name, log_file = nil, closefd = true, &pr)

      @name     = name
      @log_file = log_file
      @block    = pr
      @closefd  = closefd === true
      @before_exit = ->{}

    end # new

    def before_exit=(pr)

      @before_exit = pr if pr.is_a?(::Proc)
      self

    end # before_exit=

    def block=(pr)

      @block = pr if pr.is_a?(::Proc)
      self

    end # block=

    def start

      call_daemon
      self

    end # start

    def name
      @name
    end # name

    def running?

      return false if @pid.nil?
      @pid.running?

    end # running?

    alias :run?    :running?
    alias :exists? :running?
    alias :exist?  :running?

    def signal(sig)

      return false if @pid.nil?
      @pid.signal(sig)

    end # signal

    def stop(sig = 'QUIT')

      return false if @pid.nil?
      @pid.stop(sig)

    end # stop

    def inspect

      "#<Imp::Process\n" <<
      " process:  #{@name},\n" <<
      " pid:      #{@pid ? @pid.pid : 0},\n" <<
      " running:  #{self.running?},\n"
      " logs:     #{@log_file || '/dev/null' },\n" <<
      " block:    #{@block.inspect}>\n"

    end # inspect

    alias :to_s   :inspect
    alias :to_str :inspect

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
          @block.call if @block.is_a?(::Proc)
        rescue => ex

          msg "has errors.."
          puts "#{ex.inspect}"
          puts "#{ex.message} (#{ex.class}): #{ex.backtrace.join("\r")}"

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

      ios = ::Array.new(8192) { |i| ::IO.for_fd(i) rescue nil }.compact
      ios.each do |io|
        next if io.fileno < 3
        io.close
      end

    end # close_fd

    def trap_signals

      # Завершение работы процесса
      ::Imp::EXIT_SIGNALS.each do |sig|

        trap(sig) {

          ::Thread.new {
            @before_exit.call
          }

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