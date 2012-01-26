# encoding: utf-8
require 'imp/memory_pid'
require 'imp/base'
require 'imp/util'

module Imp

  class Exception < ::RuntimeError
  end # Exception

  def self.run(procces_name, logs = nil, &block)
    
    imp = ::Imp::Base.new(procces_name, logs, &block)
    imp.start
    imp

  end # run

end # Imp