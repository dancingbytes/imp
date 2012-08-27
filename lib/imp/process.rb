# encoding: utf-8
module Imp

  class Process

    def initialize(name, log_file = nil, &block)

      @name     = name
      @log_file = log_file
      @block    = block

    end # new

    def start

      call_daemon

      # Завершение работы
      ["QUIT", "TERM"].each do |sig|
        trap(sig) { stop }
      end # each

      # Игнорируем
      ["HUP", "USR1", "USR2", "EXIT"].each do |sig|
        trap(sig) { }
      end

      self

    end # start

    def name
      @name
    end # name

    def inspect; nil; end

    private

    def stop(sig = 'QUIT')

      @pid.stop(sig)

      if $!.nil? || $!.is_a?(::SystemExit) && $!.success?

        puts "Process [#{@pid.pid}] successfully stopped."
        return true

      else

        code = $!.is_a?(::SystemExit) ? $!.status : 1
        puts "Process [#{@pid.pid}] failure with code #{code}."
        return false

      end

    end # stop

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

      rd, wr = ::IO.pipe

      if (tmppid = ::Process.fork)

        # in parent process
        wr.close
        @pid = ::Imp::MemoryPid.new(rd.read.to_i)
        rd.close

        ::Process.waitpid(tmppid)
        ::Process.detach(tmppid)

      else

        # in child process
        rd.close

        # Detach from the controlling terminal
        raise ::Imp::Exception.new('Cannot detach from controlling terminal') unless ::Process.setsid
        exit! if fork

        @pid = ::Imp::MemoryPid.new(::Process.pid)

        wr.write(@pid.pid)
        wr.close

        $0 = @name

        ::Dir.chdir '/'
        ::File.umask 0000

        redirect_io

        puts "Process [#{@pid.pid}] was started."
        @block.call
        exit!

      end # if

    end # call_daemon

  end # Process

end # Imp