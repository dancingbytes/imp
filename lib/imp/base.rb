# encoding: utf-8
module Imp

  class Base

    def initialize(name = 'proc', log_file = nil, &block)

      @name, @log_file = name, log_file
      @block  = block
      @pid    = ::Imp::MemoryPid.new(::Process.pid)

    end # new

    def start(multiple = false)
      
      if multiple || !::Imp::Util.exists?(@name)
        call_daemon
        ::STDOUT.puts "Process [pid #{@pid.pid}] was started."
      else
        ::STDOUT.puts "Process [#{@name}] already running. Skip."
      end

      at_exit do

        if @pid.owner?(::Process.pid) && self.running?

          self.stop

          if $!.nil? || $!.is_a?(::SystemExit) && $!.success?
            puts "Process [pid #{@pid.pid}] successfully stopped."
          else
            code = $!.is_a?(::SystemExit) ? $!.status : 1
            puts "Process [pid #{@pid.pid}] failure with code #{code}."
          end
          
        end # if

      end # at_exit

      self

    end # start

    def stop(sig = 'QUIT')
      @pid.stop(sig)
    end # stop

    def pid
      @pid.pid
    end # pid

    def status
      self.running? ? [true, self.pid] : [false, 0]
    end # status

    def running?
      @pid.running?
    end # running?  

    private

    def redirect_io

      begin ::STDIN.reopen "/dev/null";  rescue ::Imp::Exception; end

      if @log_file

        begin
          ::STDOUT.reopen @log_file, "a"
          ::STDERR.reopen ::STDOUT
        rescue ::Imp::Exception
          std_out_err_reopen
        end

      else
        std_out_err_reopen
      end

      ::STDIN.sync  = true
      ::STDOUT.sync = true
      ::STDERR.sync = true

    end # redirect_io
    
    def std_out_err_reopen

      begin ::STDOUT.reopen "/dev/null"; rescue ::Imp::Exception; end
      begin ::STDERR.reopen ::STDOUT; rescue ::Imp::Exception; end

    end # std_out_err_reopen

    def call_daemon

      rd, wr = ::IO.pipe

      if (tmppid = ::Process.fork)

        # in parent process
        wr.close
        @pid.pid = rd.read.to_i
        rd.close

        ::Process.waitpid(tmppid)
        ::Process.detach(tmppid)
        
      else  

        # in child process
        rd.close

        # Detach from the controlling terminal
        raise ::Imp::Exception.new('Cannot detach from controlling terminal') unless ::Process.setsid
        exit if fork
        
        wr.write(pid = ::Process.pid)
        wr.close

        $0 = @name

        ::Dir.chdir '/'
        ::File.umask 0000

        # Make sure all file descriptors are closed
        ::ObjectSpace.each_object(::IO) do |io|

          unless [::STDIN, ::STDOUT, ::STDERR].include?(io)
            begin
              io.close unless io.closed?
            rescue ::Imp::Exception
            end
          end

        end # each_object

        ios = ::Array.new(8192) { |i| ::IO.for_fd(i) rescue nil }.compact
        ios.each do |io|
          next if io.fileno < 3
          io.close
        end

        redirect_io
        @block.call
        exit

      end # if

    end # call_daemon

  end # Base

end # Imp