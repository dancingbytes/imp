# encoding: utf-8
require 'imp/util'
require 'imp/signals'
require 'imp/pid'
require 'imp/manager'
require 'imp/process'
require 'imp/object'

require 'imp/railtie'   if defined?(::Rails)

module Imp

  extend self

  class Exception < ::RuntimeError; end # Exception

  def list

    puts "=> Imp`s process list"

    ::Imp::Manager.names do |name|

      pids = ::Imp::Util::find_by_name(name)

      puts
      puts "  process:  #{name}"
      puts "  pids:     #{pids}"
      puts "  running:  #{pids.length > 0}"
      puts

    end
    puts "  Done."

  end # list

  alias :lists :list

  def start_all

    ::Imp::Manager.each(&:start)
    nil

  end # start_all

  def stop_all(sig = 'QUIT')

    ::Imp::Manager.each do |pr|
      ::Imp::Manager.new(pr.name).stop(sig)
    end
    nil

  end # stop_all

  def restart_all(sig = 'QUIT')

    stop_all(sig)
    sleep 0.2
    start_all

  end # restart_all

end # Imp