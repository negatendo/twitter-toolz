#!/usr/bin/env ruby
<-DOC
iterate through your friends, show some info about them
and then decide if you want to unfollow or not - BRUTAL!
DOC

require 'thor'
require 'highline/import'
require 'paint'
require_relative 'lib/configloader'
require_relative 'lib/catch_twitter'

class MyCLI < Thor
  #path to config.yml with bot auth info:
  @@config = ConfigLoader.new('config.yml')

  desc "prune PROFILE", "iterate through all friends of PROFILE and give info and option to unfollow. if --list=LISTNAME is provided, members of provided list will be ignored in process, and you will be given the option to add those you don't unfollow to that list"
  option :listname, :required => false
  def prune(profile)
    # get our client
    client = @@config.get_profile_client(profile)
    # gather all friends - this takes a while
    friends = ['MarbleckaeYumte','LILBTHEBASEDGOD','negatendo_ebook']
=begin
    friends = []
    puts "Loading friends... this might take a while."
    catch_twitter {
      client.friend_ids(profile).each_slice(50).with_index do |slice, i|
        client.users(slice).each_with_index do |f, j|
          friends << f.screen_name
        end
      end
    }
=end
    # are we involving a list? if so, gather members
    use_list = false
    if (listname)
      catch_twitter {
        list = client.list(listname)
      }
      use_list = true
    end

    # go through them and show info and prompt
    friends.each do |friend|
      puts Paint["Loading next friend...", :bright]
      if (client.list_member?(list,friend))
        puts Paint["Hey cool, @#{friend} is in your list! Skipping!"]
      else
        @this_friend = false;
        catch_twitter {
          @this_friend = client.user(friend)
          sleep(3)
        }
        puts Paint["-= @#{@this_friend.name} =-", :red]
        puts Paint["#{@this_friend.description}", :blue]
        if (@this_friend.website?)
          puts Paint["#{@this_friend.website}", :green]
        end
        else
          catch_twitter {
            client.user_timeline(friend).each do |tweet|
              puts Paint["-- #{tweet.text}", "#CCCCCC"]
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

          if (agree("Unfollow them?"))
            puts "Unfollowing..."
            catch_twitter {
              client.unfollow(friend)
            }
            puts Paint["... DONE!", :green, :bright]
          else
            puts Paint["... Skipped!", :yellow, :bright]
          end
        end
      end
    end
  end
end

MyCLI.start(ARGV);

