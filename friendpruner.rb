#!/usr/bin/env ruby
# iterate through friends, see some info about them
# and then decide if you want to unfollow or not

require 'thor'
require "highline/import"
require_relative 'lib/configloader'
require_relative 'lib/catch_twitter'

class MyCLI < Thor
  #path to config.yml with bot auth info:
  @@config = ConfigLoader.new('config.yml')

  desc "prune PROFILE", "iterate through all friends of PROFILE, provide --list=LISTNAME to add them to a list too"
  option :list, :required => false
  def prune(profile)
    # get our client
    client = @@config.get_profile_client(profile)
    # gather all friends - this takes a while
    friends = ['LILBTHEBASEDGOD','Twitter']
    #puts "Loading friends... this might take a while."
    #catch_twitter {
    #  client.friend_ids(profile).each_slice(50).with_index do |slice, i|
    #    client.users(slice).each_with_index do |f, j|
    #      friends << f.screen_name
    #    end
    #  end
    #}
    # go through them and show info and prompt
    input = ask "Input text: "
    # show profile and last few tweets
    # show if they are a mutual
    # add option to unfollow
    # add option to softblock if following
    # add to list if option provided
  end

end

MyCLI.start(ARGV);

