# encoding: utf-8
module Imp

  class Manager

    include ::Imp::Signals

    class << self

      def register(process)

        raise ::Imp::Exception, "Process with name `#{process.name}` already registered!" unless self[process.name].nil?
        store[process.name] = process
        process

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

      @process = ::Imp::Manager[name]
      puts "Error. Process with name `#{name}` not found!" if @process.nil?

    end # new

    def before_exit=(pr)

      return if locked?
      @process.before_exit = pr
      self

    end # before_exit=

    def block=(pr)

      return if locked?
      @process.block = pr
      self

    end # block=

    def start

      return if locked?

      @process.start if @process
      nil

    end # start

    def stop(sig_name = 'QUIT')

      return if locked?

      self.refresh
      walk do |pid|
        pid.stop(sig_name)
      end

      nil

    end # stop

    def restart

      self.stop
      sleep 0.2
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

      return if locked?

      self.refresh
      walk do |pid|
        pid.signal(name)
      end
      nil

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

    def inspect

      return unless @process

      logs   = @process.instance_variable_get(:@log_file)
      block  = @process.instance_variable_get(:@block)
      pids_a = pids.map(&:pid)

      "#<Imp::Manager\n" <<
      " process:  #{@process.name},\n" <<
      " pids:     #{pids_a},\n" <<
      " running:  #{pids_a.length > 0},\n" <<
      " logs:     #{logs || '/dev/null'},\n" <<
      " block:    #{block}>\n"

    end # inspect

    alias :to_s   :inspect
    alias :to_str :inspect

    private

    def pids

      return @pids  if @pids
      return []     unless @process

      @pids = []
      ::Imp::Util::find_by_name(@process.name).each do |pid|
        @pids << ::Imp::Pid.new(pid)
      end
      @pids

    end # pids

    def walk

      pids.each do |pid|
        yield(pid)
      end

    end # walk

    def locked?
      ::Imp::locked?
    end # locked?

  end # Manager

end # Imp