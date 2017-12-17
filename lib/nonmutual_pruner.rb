#!/usr/bin/env ruby
##
# iterate through your nonmutuals and unfollow
#

class NonmutualPruner < MyCLIPart
  def prune(profile)
    # gather all friends - this takes a while
    friends = []
    say("Loading friends... this might take a while.")
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

    # go through them and if nonmutual then remove
    friends.each do |friend|
      @output.say("Loading next friend @#{friend}...")
      # show if they are a mutual
      @is_follower = false;
      catch_twitter {
        @is_follower = @client.friendship?(friend,profile)
      }
      skip = false
      if (@is_follower)
        say("+ Follows Back")
        skip = true
      else
        say("- Does Not Follow Back")
      end

      # skip if on list
      if (use_list)
        in_list = false;
        catch_twitter {
          in_list = @client.list_member?(@options[:listname],friend)
        }
        if (in_list)
          say("+ A member of your list")
          skip = true
        end
      end

      if (!skip)
        # prompts
        unfollow = false
        if (@options[:noprompt])
          unfollow = true
        else
          if (agree("Unfollow them?"))
            unfollow = true
          end
        end
        if (unfollow)
          say("Unfollowing...")
          catch_twitter {
            @client.unfollow(friend)
          }
          say("... unfollowed!")
        end
      end
    end
  end
end

