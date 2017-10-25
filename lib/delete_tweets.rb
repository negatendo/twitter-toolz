#!/usr/bin/env ruby
##
# iterate through your tweets and delete them alllllll
#

class DeleteTweets < MyCLIPart
  def csvdelete(path)
    # collect tweet ids from csv         h
    rownum = 0
    ids = []
    CSV.foreach(path, encoding: "utf-8") do |row|
      if rownum != 0
        ids << row[0]
      end
      rownum = rownum + 1
    end
    # iterate through each and delete
    ids.each do |id|
      tweet = false
      catch_twitter {
        tweet = @client.status(id)
      }
      if (tweet)
        do_delete = false
        if (@options[:noprompt])
          do_delete = true
        else
          if agree("Delete this Tweet? #{tweet.url}")
            do_delete = true
          end
        end
        if (do_delete)
          @output.say("Deleting #{tweet.url}")
          catch_twitter {
            if (!@options[:testrun])
              @client.destroy_status(id)
              say("... Tweet deleted!")
            else
              say("DEBUG: The Tweet was not deleted because --testrun=true")
            end
          }
        end
      end
    end
  end
end
