# encoding: utf-8
namespace :imp do

  puts "Loading #{::Rails.env} environment"

  desc 'List of processes'
  task :list => :environment do

    Imp.list
    puts

  end # :list

  desc 'List of processes'
  task :lists => :environment do
    Rake::Task["imp:list"].invoke
  end # :lists

  desc 'Start all processes'
  task :start_all => :environment do

    Imp.start_all
    puts

  end # :start_all

  desc 'Stop all processes'
  task :stop_all => :environment do

    Imp.stop_all
    puts

  end # :stop_all

  desc 'Restart all processes'
  task :restart_all => :environment do

    Imp.restart_all
    puts

  end # :restart_all

  desc 'Start custom process'
  task :start => :environment do

    name = ENV["p"] || ENV["process"]
    if name.nil? || name.blank?
      puts "Error. Set process name with `p` or `process` variable."
      exit
    end

    Imp(name).start
    puts

  end # :start

  desc 'Stop custom process'
  task :stop => :environment do

    name = ENV["p"] || ENV["process"]
    if name.nil? || name.blank?
      puts "Error. Set process name with `p` or `process` variable."
      exit
    end

    Imp(name).stop
    puts

  end # :stop

  desc 'Restart custom process'
  task :restart => :environment do

    name = ENV["p"] || ENV["process"]
    if name.nil? || name.blank?
      puts "Error. Set process name with `p` or `process` variable."
      exit
    end

    Imp(name).restart
    puts

  end # :restart

  desc 'Inspect custom process'
  task :inspect => :environment do

    name = ENV["p"] || ENV["process"]
    if name.nil? || name.blank?
      puts "Error. Set process name with `p` or `process` variable."
      exit
    end

    puts Imp(name).inspect
    puts

  end # :inspect

  desc 'Inspect custom process'
  task :show => :environment do
    Rake::Task["imp:inspect"].invoke
  end # :show

  desc 'List of commands'
  task :help => :environment do

    puts

    puts "Usage: bundle exec rake imp:start p=my_process_name RAILS_ENV=production"
    puts
    puts "Available rake commands:  "
    puts "  list                  Show list of process"
    puts "  stop p=name           Stop process with `name`"
    puts "  start p=name          Start process with `name`"
    puts "  restart p=name        Restart process with `name`"
    puts "  stop_all              Stop all processes"
    puts "  start_all             Start all processes"
    puts "  restart_all           Restart all processes"
    puts "  show p=name           Show information about process with `name`"

    puts

  end # :help

end # :imp

task :imp => 'imp:help'