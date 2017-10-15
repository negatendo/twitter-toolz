#!/usr/bin/env ruby
##
# iterate through your followers and softblock people you are not following back
#

require 'thor'
require 'highline/import'
HighLine.color_scheme = HighLine::SampleColorScheme.new

require_relative 'lib/configloader'
require_relative 'lib/catch_twitter'

class MyCLI < Thor
  #path to config.yml with bot auth info:
  @@config = ConfigLoader.new('config.yml')

  desc "softprune <profile>", "go through <profile> and then softblock (block then unblock, e.g. force the unfollow-of) nonmutuals."
  long_desc <<-LONGDESC
    sofprune:

    Go through accounts following the <profile> and softblock (block then unblock - e.g. force the unfollow of) nonmutuals.

    --noprompt=true to skip confirmation on each
    \x5-testrun=true to run the script without performing softblocks
  LONGDESC
  option :noprompt, :default => false
  option :testrun, :default => false
  def softprune(profile)
    # get our client
    client = @@config.get_profile_client(profile)
    # gather all followers - this takes a while
    followers = []
    puts "Loading followers ... this might take a while."
    catch_twitter {
      client.follower_ids(profile).each_slice(50).with_index do |slice, i|
        client.users(slice).each_with_index do |f, j|
          followers << f.screen_name
        end
      end
    }
    # go through them and if nonmutual then remove
    followers.each do |follower|
      puts Paint["Loading next follower @#{follower}...", :bright]
      # show if they are a mutual
      @is_friend = false;
      catch_twitter {
        @is_friend = client.friendship?(profile,follower)
      }
      skip = false
      if (@is_friend)
        puts Paint["+ You Follow Them", :green]
        skip = true
      else
        puts Paint["- You Do Not Follow Them", :red]
      end
      if (!skip)
        # prompts
        unfollow = false
        if (options[:noprompt])
          softblock = true
        else
          if (agree("Softblock them?"))
            softblock = true
          end
        end
        if (softblock)
          puts "Softblocking..."
          catch_twitter {
            client.block(follower)
          }
          catch_twitter {
            client.unblock(follower)
          }
          puts Paint["... SOFTBLOCKED!", :green, :bright]
        end
      end
    end
  end
end

MyCLI.start(ARGV);

