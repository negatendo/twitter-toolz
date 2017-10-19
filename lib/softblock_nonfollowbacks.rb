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
        say("<%= color('+ You Follow Them',:green) %>")
        skip = true
      else
        say("<%= color('- You Do NOt Follow Them',:red) %>")
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
          say("<%= color('... SOFTBLOCKED!',:notice) %>")
        end
      end
    end
  end
end

