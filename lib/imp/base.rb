# encoding: utf-8
module Imp

  class Base

    include ::Imp::Signals

    class << self

      def register(process)

        raise ::Imp::Exception, "Process with name `#{process.name}` already registered!" unless self[process.name].nil?
        store[process.name] = process
        self

      end # register

      def [](name)
        store[name]
      end # get

      def each(&block)
        store.each_value(&block)
      end # each

      def names(&block)

        if block_given?
          store.each_key(&block)
        else
          store.keys
        end

      end # names

      private

      def store
        @hash ||= {}
      end # store

    end # class << self

    def initialize(name)

      @process = ::Imp::Base[name]
      raise ::Imp::Exception, "Process with name `#{name}` not found!" if @process.nil?

    end # new

    def start

      @process.start
      self

    end # start

    def stop(sig_name = 'QUIT')

      self.refresh
      walk do |pid|
        pid.signal(sig_name)
      end
      self

    end # stop

    def restart

      self.stop
      sleep 1
      self.start

    end # restart

    def refresh

      @pids = nil
      self

    end # refresh

    alias :reload :refresh

    def count
      pids.length
    end # count

    alias :size   :count
    alias :length :count

    def signal(name)

      walk do |pid|
        pid.signal(name)
      end
      self

    end # signal

    def running?

      self.refresh
      self.count > 0

    end # running?

    alias :run?    :running?
    alias :exists? :running?
    alias :exist?  :running?

    def [](i)
      pids[i]
    end # []

    def inspect; nil; end

    private

    def pids

      return @pids if @pids

      @pids = []
      ::Imp::Util::find_by_name(@process.name).each do |pid|
        @pids << ::Imp::MemoryPid.new(pid)
      end
      @pids

    end # pids

    def walk

      tr = []
      pids.each do |pid|

        tr << ::Thread.new {
          yield(pid)
        }

      end

      tr.join

    end # walk

  end # Base

end # Imp