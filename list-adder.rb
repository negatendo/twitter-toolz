#!/usr/bin/env ruby
# operate on a text file of followers adding them to a list

require 'thor'
require_relative 'lib/configloader'
require_relative 'lib/catch_twitter'

class MyCLI < Thor
  #path to config.yml with bot auth info:
  @@config = ConfigLoader.new('config.yml')

  desc "import PROFILE FILE LISTNAME", "import list for PROFILE from txt file at PATH into LISTNNAME"
  def import(profile,path,listname)
    members = []
    # load text file from supplied path
    File.open(path, "r") do |f|
      f.each_line do |line|
        members << line.gsub('@','').gsub('\n','');
      end
    end

    # setup client and add members to list
    client = @@config.get_profile_client(profile)
    list = client.list('main')
    list_id = list.id
    members.each do |member|
      catch_twitter {
        if (!client.list_member?(profile,listname,member))
          puts "#{member} to be added..."
          client.add_list_member(listname,member)
          puts "... DONE!"
        else
          puts "#{member} already in list - skipping"
        end
        sleep(10)
      }
    end
  end
end

MyCLI.start(ARGV);
