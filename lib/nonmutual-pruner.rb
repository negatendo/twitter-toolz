#!/usr/bin/env ruby
##
# iterate through your nonmutuals and unfollow
#

class NonmutualPruner
  @output = false
  @client = false
  @options = []
  def initialize(output,client,options)
    # send highline obj and a twitter client
    @output = output
    @client = client
    @options = options
  end
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
        say("<%= color('+ Follows Back', [:bold, :red]) %>")
        skip = true
      else
        say("<%= color('- Does Not Follow Back', [:bold, :green]) %>")
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
          say("<%= color('... unfollowed!', :info) %>")
        end
      end
    end
  end
end

