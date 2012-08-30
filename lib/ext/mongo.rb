# encoding: utf-8
module Mongo

  class Pool

    def checkout_existing_socket

      socket = (@sockets - @checked_out).first
      if @pids[socket] != Process.pid
        @pids[socket] = nil
        @sockets.delete(socket)
        socket.close unless socket.closed?
        checkout_new_socket
      else
        @checked_out << socket
        socket
      end

    end # checkout_existing_socket

  end # Pool

end # Mongo