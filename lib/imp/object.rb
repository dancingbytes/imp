# encoding: utf-8
module Imp

  module Object

    private

    def Imp(name, logs = nil, &block)

      if block_given?

        process = ::Imp::Process.new(name.to_s, logs, &block)
        ::Imp::Base.register(process)

      end # if

      ::Imp::Base.new(name)

    end # Imp

  end # Object

end # Imp

::Object.send(:include, ::Imp::Object)