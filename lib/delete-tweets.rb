#!/usr/bin/env ruby
##
# iterate through your tweets and delete them alllllll
#

class DeleteTweets
  @output = false
  @client = false
  @options = []
  def initialize(output,client,options)
    # send highline obj and a twitter client
    @output = output
    @client = client
    @options = options
  end
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
          if agree("<%= color('Delete this Tweet? #{tweet.url}', :bold) %>")
            do_delete = true
          end
        end
        if (do_delete)
          @output.say("<%= color('Deleting #{tweet.url}', :notice) %>")
          catch_twitter {
            if (!@options[:testrun])
              @client.destroy_status(id)
              say("<%= color('... Tweet deleted!', :info) %>")
            else
              say("<%= color('DEBUG: The Tweet was not deleted because --testrun=true', :debug) %>")
            end
          }
        end
      end
    end
  end
end
