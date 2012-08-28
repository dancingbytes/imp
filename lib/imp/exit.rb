# encoding: utf-8

# Если работаем из консоли или запускаем rake-задачу,
# игнориуем сигналы, завершающие работу демона.
if !defined?(::IRB) && !defined?(::Rake)

  # Завершение работы при получении указанных сигналов
  ::Imp::EXIT_SIGNALS.each do |sig|

    trap(sig) {
      ::Imp.stop_all
    }

  end # each

  at_exit {
    ::Imp.stop_all
  }

end # if