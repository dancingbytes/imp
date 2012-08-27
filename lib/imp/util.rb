# encoding: utf-8
module Imp

  module Util

    extend self

    def find_by_name(app_name)

      pids = []
      begin

        app_name = app_name.strip
        x = `ps auxw | grep -v grep | awk '{print $2, $11, $12}' | grep #{app_name}`
        if x && x.chomp!

          (x.split(/\n/).compact || []).map { |prs|

            pid, name, add = prs.split(/\s/)
            pids << pid.to_i if app_name == name.strip

          }

        end
        pids

      rescue
      end
      pids

    end # find_by_name

    def exists?(app_name)
      !find_by_name(app_name).empty?
    end # exists?

  end # Util

end # Imp