#!/usr/bin/env ruby
##
# iterate through your followers and softblock people you are not following back
#

class SoftPrune < MyCLIPart
  def softprune(profile)
    # gather all followers - this takes a while
    followers = []
    say("Loading followers ... this might take a while.")
    catch_twitter {
      @client.follower_ids(profile).each_slice(50).with_index do |slice, i|
        @client.users(slice).each_with_index do |f, j|
          followers << f.screen_name
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
    followers.each do |follower|
      say("Loading next follower @#{follower}...")
      # show if they are a mutual
      @is_friend = false;
      catch_twitter {
        @is_friend = @client.friendship?(profile,follower)
      }
      skip = false
      if (@is_friend)
        say("+ You Follow Them")
        skip = true
      else
        say("- You Do Not Follow Them")
      end
      # skip if on list
      if (use_list)
        in_list = false;
        catch_twitter {
          in_list = @client.list_member?(@options[:listname],follower)
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
          softblock = true
        else
          if (agree("Softblock them?"))
            softblock = true
          end
        end
        if (softblock)
          say("Softblocking...")
          catch_twitter {
            @client.block(follower)
          }
          catch_twitter {
            #client.unblock(follower)
          }
          say("... SOFTBLOCKED!")
        end
      end
    end
  end
end

