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
    friends.shuffle!
    friends.each do |friend|
      @output.say("Loading next friend @#{friend}...")
      if (use_list)
        @in_list = false;
        catch_twitter {
          @in_list = @client.list_member?(@options[:listname],friend)
        }
      end
      if (use_list && @in_list)
        @output.say("Hey cool, @#{friend} is in your list! Skipping!")
      else
        @this_friend = false;
        catch_twitter {
          @this_friend = @client.user(friend)
          sleep(3)
        }
        @output.say("-= #{@this_friend.name} =-")
        @output.say("-= #{@this_friend.uri} =-")
        @output.say("-= #{@this_friend.description} =-")
        if (@this_friend.website?)
          @output.say("#{@this_friend.website}")
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
          @output.say("+ Follows You")
        else
          @output.say("- Does Not Follow You")
        end

        # prompts
        if (agree("Unfollow them?"))
          @output.say("Unfollowing...")
          catch_twitter {
            @client.unfollow(friend)
          }
          @output.say("... DONE!")
        else
          @output.say("... Skipped!")
          if (use_list && agree("Add them to your list?"))
            @client.add_list_member(@options[:listname],friend)
            @output.say("... ADDED!")
          end
        end
      end
    end
  end
end

