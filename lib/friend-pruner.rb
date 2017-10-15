#!/usr/bin/env ruby
##
# iterate through your friends, show some info about them
# and then decide if you want to unfollow or not - BRUTAL!
#

require 'thor'
require 'highline/import'
HighLine.color_scheme = HighLine::SampleColorScheme.new

require_relative 'configloader'
require_relative 'catch_twitter'

class FriendPruner < MyCLI
  #path to config.yml with bot auth info:
  @@config = ConfigLoader.new('config.yml')

  desc "prune PROFILE", "iterate through all friends of PROFILE and give info and option to unfollow. if --listname=LISTNAME is provided, members of provided list will be ignored in process, and you will be given the option to add those you don't unfollow to that list. if --brief=true is provided fewer information lookups will be performed and less info per person shown."
  option :listname, :required => false
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
    # are we involving a list? if so, gather members
    use_list = false
    if (options[:listname])
      catch_twitter {
        list = client.list(options[:listname])
      }
      use_list = true
    end

    # go through them and show info and prompt
    friends.each do |friend|
      puts Paint["Loading next friend @#{friend}...", :bright]
      if (use_list)
        @in_list = false;
        catch_twitter {
          @in_list = client.list_member?(options[:listname],friend)
        }
      end
      if (use_list && @in_list)
        puts Paint["Hey cool, @#{friend} is in your list! Skipping!", :bright]
      else
        @this_friend = false;
        catch_twitter {
          @this_friend = client.user(friend)
          sleep(3)
        }
        puts Paint["-= #{@this_friend.name} =-", :red]
        puts "#{@this_friend.uri}"
        puts Paint["#{@this_friend.description}", :blue]
        if (@this_friend.website?)
          puts Paint["#{@this_friend.website}", :green]
        end

        # last 20 tweets
        catch_twitter {
          client.user_timeline(friend).each do |tweet|
            puts Paint["#{tweet.created_at} - #{tweet.text}", "#CCCCCC"]
          end
        }

        # show if they are a mutual
        @is_follower = false;
        catch_twitter {
          @is_follower = client.friendship?(friend,profile)
        }
        if (@is_follower)
          puts Paint["+ Follows You", :green]
        else
          puts Paint["- Does Not Follow You ", :red]
        end

        # prompts
        if (agree("Unfollow them?"))
          puts "Unfollowing..."
          catch_twitter {
            client.unfollow(friend)
          }
          puts Paint["... DONE!", :green, :bright]
        else
          puts Paint["... Skipped!", :yellow, :bright]
          if (use_list && agree("Add them to your list?"))
            client.add_list_member(options[:listname],friend)
            puts Paint["... ADDED!", :green, :bright]
          end
        end
      end
    end
  end
end

MyCLI.start(ARGV);

