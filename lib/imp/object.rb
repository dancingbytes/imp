# encoding: utf-8
module Imp

  module Object

    private

    def Imp(name, logs = nil, &block)

      if block_given?

        ::Imp::Manager.register(
          ::Imp::Process.new(name.to_s, logs, &block)
        )

      end # if

      ::Imp::Manager.new(name)

    end # Imp

  end # Object

end # Imp

::Object.send(:include, ::Imp::Object)