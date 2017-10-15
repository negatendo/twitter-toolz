#!/usr/bin/env ruby
##
# iterate through your nonmutuals and unfollow
#

require 'thor'

require_relative 'lib/configloader'
require_relative 'lib/catch_twitter'
require_relative 'lib/colorscheme'

class MyCLI < Thor
  #path to config.yml with bot auth info:
  @@config = ConfigLoader.new('config.yml')

  desc "prune PROFILE", "iterate through nonmutual followers and unfollow. supply --noprompt=true to skip confirmation on each."
  option :noprompt, :default => false
  def prune(profile)
    # get our client
    client = @@config.get_profile_client(profile)
    # gather all friends - this takes a while
    friends = []
    puts "Loading friends... this might take a while."
    catch_twitter {
      client.friend_ids(profile).each_slice(50).with_index do |slice, i|
        client.users(slice).each_with_index do |f, j|
          friends << f.screen_name
        end
      end
    }
    # go through them and if nonmutual then remove
    friends.each do |friend|
      puts Paint["Loading next friend @#{friend}...", :bright]
      # show if they are a mutual
      @is_follower = false;
      catch_twitter {
        @is_follower = client.friendship?(friend,profile)
      }
      skip = false
      if (@is_follower)
        puts Paint["+ Follows You Back", :green]
        skip = true
      else
        puts Paint["- Does Not Follow You Back", :red]
      end
      if (!skip)
        # prompts
        unfollow = false
        if (options[:noprompt])
          unfollow = true
        else
          if (agree("Unfollow them?"))
            unfollow = true
          end
        end
        if (unfollow)
          puts "Unfollowing..."
          catch_twitter {
            client.unfollow(friend)
          }
          puts Paint["... UNFOLLOWED!", :green, :bright]
        end
      end
    end
  end
end

MyCLI.start(ARGV);

