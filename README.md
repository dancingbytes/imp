imp
======


Small daemons` manager for ruby

### Supported environment

Ruby:   1.9.3

Rails:  3.0, 3.1, 3.2

### Tested with servers

WEBrik:     1.3.1

Thin:       1.4.1

Unicorn:    4.3.1

### Example

    ### Simple use
    require 'imp'

    ### 1. With process registration

    # format
    #
    # Imp(proc_name, [file_log = nil], [close_file_descriptors = true], &block)
    #

    Imp( "name-of-your-proccess", File.join("Path", "to", "log.file") ) do
      # do some work
    end

    # or without logs
    Imp( "name-of-your-proccess" ) do
      # do some work
    end

    # And then start
    Imp("name-of-your-proccess").start

    ### 2. Without process registartion

    # format
    #
    # imp(proc_name, [file_log = nil], [close_file_descriptors = true], &block)
    #

    imp( "name-of-your-proccess" ) do
      # do some work
    end

    ### Why to register process?
    Registered process can be auto stopped when master process is exit
    and may be managed by you (stop, run, send signals) through rails console or rake task

    ### Lists of commands

    # Show userful information about process
    Imp("name-of-your-proccess")

    # For selected process
    Imp("name-of-your-proccess").stop

    Imp("name-of-your-proccess").restart

    # Check process status under OS
    Imp("name-of-your-proccess").running? # true

    # Total processes running under name "name-of-your-proccess" (usually 1)
    Imp("name-of-your-proccess").count # 1

    # Send signal to process...
    Imp("name-of-your-proccess").signal("HUP")

    # ... or
    Imp("name-of-your-proccess").hup

    # Lists of imp`s processes
    Imp.list

    # Start all
    Imp.start_all

    # Stop all
    Imp.stop_all

    ### List of rake commands
    bundle exec rake imp

### License

Author: Tyralion (piliaiev@gmail.com)

Copyright (c) 2012 DansingBytes.ru, released under the BSD license