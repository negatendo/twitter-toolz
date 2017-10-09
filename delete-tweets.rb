#!/usr/bin/env ruby
##
# TODO iterate through your tweets and delete them alllllll
#

require 'thor'
require 'highline/import'
require 'paint'
require_relative 'lib/configloader'
require_relative 'lib/catch_twitter'

class MyCLI < Thor
  #path to config.yml with bot auth info:
  @@config = ConfigLoader.new('config.yml')

  desc "csvdelete PROFILE PATH", "iterate through a twitter .csv file for PROFILE at PATH and delete all tweets. --noreplies=true to not delete replies. --noprompt=true to not be prompted for each delete"
  option :noreplies, :default => false
  option :noprompt, :default => false
  def csvdelete(profile)
    # get our client
    client = @@config.get_profile_client(profile)
    # collect tweets from csv
    # iterate through each
    # -- skip replies if according
    # -- don't prompt if according
  end
end

MyCLI.start(ARGV);

