#!/usr/bin/env ruby
##
# iterate through your friends, show some info about them
# and then decide if you want to unfollow or not - BRUTAL!
#

class FriendPruner < MyCLIPart
  def prune(profile)
    # gather all friends - this takes a while
    friends = []
    @output.say("Loading friends... this might take a while.")
    catch_twitter {
      @client.friend_ids(profile).each_slice(50).with_index do |slice, i|
        @client.users(slice).each_with_index do |f, j|
          friends << f.screen_name
        end
      end
    }
    # are we involving a list? if so, gather members
    use_list = false
    if (@options[:listname])
      catch_twitter {
        list = @client.list(@options[:listname])
      }
      use_list = true
    end

    # go through them and show info and prompt
    friends.each do |friend|
      @output.say("Loading next friend @#{friend}...")
      if (use_list)
        @in_list = false;
        catch_twitter {
          @in_list = @client.list_member?(@options[:listname],friend)
        }
      end
      if (use_list && @in_list)
        @output.say("<%= color('Hey cool, @#{friend} is in your list! Skipping!',:notice) %>")
      else
        @this_friend = false;
        catch_twitter {
          @this_friend = @client.user(friend)
          sleep(3)
        }
        @output.say("<%= color('-= #{@this_friend.name} =-', :red) %>")
        @output.say("<%= color('-= #{@this_friend.uri} =-', :white) %>")
        #FIXME regx breaking escaping idk it's weird try with apostrophe
        #desc = "<%= color('-= #{@this_friend.description} =-', :blue) %>";
        #@output.say(desc)
        if (@this_friend.website?)
          @output.say("<%= color('#{@this_friend.website}', :green) %>")
        end

        # last 20 tweets if not brief
        if (!@options[:brief])
          catch_twitter {
            @client.user_timeline(friend).each do |tweet|
              @output.say("#{tweet.created_at} - #{tweet.text}")
            end
          }
        end

        # show if they are a mutual
        @is_follower = false;
        catch_twitter {
          @is_follower = @client.friendship?(friend,profile)
        }
        if (@is_follower)
          @output.say("<%= color('+ Follows You',:green) %>")
        else
          @output.say("<%= color('- Does Not Follow You',:red) %>")
        end

        # prompts
        if (agree("Unfollow them?"))
          @output.say("Unfollowing...")
          catch_twitter {
            @client.unfollow(friend)
          }
          @output.say("<%= color('... DONE!',:info) %>")
        else
          @output.say("<%= color('... Skipped!',:yellow) %>")
          if (use_list && agree("Add them to your list?"))
            @client.add_list_member(@options[:listname],friend)
            @output.say("<%= color('... ADDED!',[:green, :bright]) %>")
          end
        end
      end
    end
  end
end

