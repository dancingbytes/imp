# encoding: utf-8
require 'imp/util'
require 'imp/signals'
require 'imp/pid'
require 'imp/manager'
require 'imp/process'
require 'imp/object'
require 'imp/trap'

require 'ext/mongo'     if defined?(::Mongo::Pool)
require 'imp/railtie'   if defined?(::Rails)

module Imp

  extend self

  EXIT_SIGNALS = ["QUIT", "TERM", "INT"].freeze

  class Exception < ::RuntimeError; end # Exception

  def start(name)
    ::Imp::Manager.new(name).start
  end # start

  def stop(name)
    ::Imp::Manager.new(name).stop
  end # stop

  def restart(name)
    ::Imp::Manager.new(name).restart
  end # restart

  def inspect(name)
    ::Imp::Manager.new(name).inspect
  end # inspect

  def list

    puts "=> Imp`s registered process list"

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

    return if locked?

    ::Imp::Manager.each(&:start)
    nil

  end # start_all

  def stop_all(sig = 'QUIT')

    return if locked?

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

  def locked?
    ::Imp::LOCKED
  end # locked?

  alias :lock? :locked?

end # Imp

::Imp::LOCKED = (!::Imp::Trap.catch).freeze
