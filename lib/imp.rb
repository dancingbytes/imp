# encoding: utf-8
require 'imp/util'
require 'imp/signals'
require 'imp/memory_pid'
require 'imp/base'
require 'imp/process'
require 'imp/object'

module Imp

  extend self

  class Exception < ::RuntimeError; end # Exception

  def list

    puts "=> Imp`s process list"
    puts "=> Name -> [Pids]"
    puts

    ::Imp::Base.names do |name|

      pids = ::Imp::Util::find_by_name(name)
      if pids.empty?
        puts "  #{name} -> not running"
      else
        puts "  #{name} -> [#{pids.join(', ')}]"
      end

    end
    puts

  end # list

  alias :lists :list

  def start_all

    ::Imp::Base.each(&:start)
    nil

  end # start_all

  def stop_all(sig = 'QUIT')

    ::Imp::Base.each do |pr|
      ::Imp::Base.new(pr.name).stop(sig)
    end
    nil

  end # stop_all

end # Imp