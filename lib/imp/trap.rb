# encoding: utf-8
module Imp

  module Trap

    extend self

    def catch

      # Если работаем из консоли или запускаем rake-задачу,
      # игнориуем сигналы, завершающие работу демона и не блокируем процесс.
      return true if defined?(::IRB) || defined?(::Rake)

      begin

        return false if ::File.exist?(::Imp::Trap::FILE_LOCK)

        f = ::File.new(::Imp::Trap::FILE_LOCK, ::File::RDWR|::File::CREAT, 0400)
        return false if (f.flock(::File::LOCK_EX) === false)

        trap_signals

        return true

      rescue ::Errno::EACCES
        return false
      rescue => ex
        puts "[Imp::Trap.catch] Error.\n\n#{ex.backtrace}: #{ex.message} (#{ex.class})"
        return false
      end

    end # catch

    def mpid

      pid = ::Process.ppid
      pid == 1 ? ::Process.pid : pid

    end # mpid

    private

    def exit_process

      return if @terminating
      @terminating = true

      begin
        ::Imp.stop_all
        sleep 0.1
        ::Process::exit(0)
      ensure
        ::FileUtils.rm ::Imp::Trap::FILE_LOCK, :force => true
      end

    end # exit_process

    def trap_signals

      @terminating = false

      # Завершение работы при получении указанных сигналов
      ::Imp::EXIT_SIGNALS.each do |sig|
        trap(sig) { exit_process }
      end # each

      at_exit { exit_process }

    end # trap_signals

  end # Trap

end # Imp

::Imp::Trap::FILE_LOCK = "/tmp/imp_#{::Imp::Trap.mpid}.lock".freeze