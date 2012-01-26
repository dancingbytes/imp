# encoding: utf-8
module Imp

  class Base

    def initialize(name = 'proc', log_file = nil, &block)

      @name, @log_file = name, log_file
      @block  = block
      @pid    = ::Imp::MemoryPid.new

    end # new

    def start(multiple = false)

      if multiple || !::Imp::Util.exists?(@name)
        @pid.pid = call_daemon
        puts "Process with pid #{@pid.pid} was started."
      else
        puts "Process with name #{@name} already running. Skip."
      end
      self

    end # start

    def stop(sig = 'QUIT')

      yield if block_given?

      @pid.stop(sig)
      puts "Process with pid #{@pid.pid} successfully stopped."
      ::STDOUT.flush
      exit(0)

    end # stop

    def pid
      @pid.pid
    end # pid

    def status
      @pid.running? ? [true, @pid.pid] : [false, 0]
    end # status

    private

    def safefork

      @tryagain = true

      while @tryagain
        @tryagain = false
        begin
          if pid = fork
            return pid
          end
        rescue ::Errno::EWOULDBLOCK
          sleep 5
          @tryagain = true
        end
      end

    end # safefork

    def redirect_io

      begin ::STDIN.reopen "/dev/null";  rescue ::Imp::Exception; end

      if @log_file

        begin
          ::STDOUT.reopen @log_file, "a"
          ::STDERR.reopen @log_file, "a"
          ::File.chmod(0644, @log_file)
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
      begin ::STDERR.reopen "/dev/null"; rescue ::Imp::Exception; end

    end # std_out_err_reopen

    def call_daemon

      rd, wr = ::IO.pipe
    
      if tmppid = safefork
        
        # parent
        wr.close
        pid = rd.read.to_i
        rd.close

        ::Process.waitpid(tmppid)
        return pid

      else

        # child
        rd.close

        # Detach from the controlling terminal
        raise ::Imp::Exception.new('Cannot detach from controlling terminal') unless ::Process.setsid
        exit if safefork
        
        wr.write ::Process.pid
        wr.close

        $0 = @name

        ::Dir.chdir '/'
        ::File.umask 0000

        # Make sure all file descriptors are closed
        ::ObjectSpace.each_object(::IO) do |io|

          unless [STDIN, STDOUT, STDERR].include?(io)
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
        exit(0)
        
      end # if

    end # call_daemon

  end # Base

end # Imp