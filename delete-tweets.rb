#!/usr/bin/env ruby
##
# TODO iterate through your tweets and delete them alllllll
#

require 'thor'
require 'highline/import'
require 'paint'
require 'csv'
require_relative 'lib/configloader'
require_relative 'lib/catch_twitter'

class MyCLI < Thor
  #path to config.yml with bot auth info:
  @@config = ConfigLoader.new('config.yml')

  desc "csvdelete PROFILE PATH", "iterate through a twitter .csv file for PROFILE at PATH and delete all tweets. --noprompt=true to not be prompted for each delete."
  option :noprompt, :default => false
  def csvdelete(profile,path)
    # get our client
    client = @@config.get_profile_client(profile)

    # collect tweet ids from csv
    rownum = 0
    ids = []
    CSV.foreach(path) do |row|
      if rownum != 0
        ids << row[0]
      end
      rownum = rownum + 1
    end
    # iterate through each and delete
    ids.each do |id|
      tweet = false
      catch_twitter {
        tweet = client.status(id)
      }
      if (tweet)
        puts Paint["Tweet id #{id} : \"#{tweet.text}\"", :blue, :bright]
        do_delete = false
        if (options[:noprompt])
          do_delete = true
        else
          if agree("Delete tweet id #{id}?")
            do_delete = true
          end
        end
        if (do_delete)
          puts Paint["Deleting id #{id}...", :green]
          catch_twitter {
            client.destroy_status(id)
          }
          puts Paint["... DELETED!", :red]
        end
      end
    end
  end
end

MyCLI.start(ARGV)
