# encoding: utf-8
module Imp

  module Signals

    def quit
      self.signal("QUIT")
    end

    def exit
      puts "unsupported signal `SIGEXIT'"
    end

    def term
      self.signal("TERM")
    end

    def int
      self.signal("INT")
    end

    def kill
      self.signal("KILL")
    end

    def hup
      self.signal("HUP")
    end

    def usr1
      self.signal("USR1")
    end

    def user2
      self.signal("USR2")
    end

  end # Signals

end # Imp