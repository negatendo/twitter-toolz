#!/usr/bin/env ruby
##
# a few operations for lists:
# import - import a list of twitter account names from a .txt file to a list
#

class ListAdder < MyCLIPart
  def import(profile,path,listname)
    members = []
    # load text file from supplied path
    File.open(path, "r") do |f|
      f.each_line do |line|
        members << line.gsub('@','').gsub('\n','');
      end
    end

    # setup client and add members to list
    list = @client.list(listname)
    members.each do |member|
      catch_twitter {
        if (!@client.list_member?(profile,listname,member))
          say("#{member} to be added...")
          @client.add_list_member(listname,member)
          say("... DONE!")
        else
          say("#{member} already in list - skipping")
        end
      }
    end
  end

  def addtolist(profile,listname,member)
    say("Adding #{member} to @#{profile}/#{listname}...")
    @client.add_list_member(listname,member)
    say("... DONE!")
  end
end
