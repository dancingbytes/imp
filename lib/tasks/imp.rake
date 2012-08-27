# encoding: utf-8
namespace :imp do

  desc 'Start all imp`s processes'
  task :start_all => :environment do

    Imp.start_all
    puts

  end # :start_all

  desc 'Stop all imp`s processes'
  task :stop_all => :environment do

    Imp.stop_all
    puts

  end # :stop_all

end # :imp