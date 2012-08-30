# encoding: utf-8
module Imp

  module Object

    private

    def Imp(name, logs = nil, closefd = true, &block)

      if block_given?

        ::Imp::Manager.register(
          ::Imp::Process.new(name.to_s, logs, closefd, &block)
        )

      end # if

      ::Imp::Manager.new(name)

    end # Imp

  end # Object

end # Imp

::Object.send(:include, ::Imp::Object)