require 'thor'
require 'highline/import'

require 'csv'

require_relative 'mycli_part'
require_relative 'configloader'
require_relative 'catch_twitter'

# each of these bring in a class used by commands - idk its ugly
require_relative 'delete_tweets'
require_relative 'nonmutual_pruner'
require_relative 'friend_pruner'
#require_relative 'softblock_nonfollowbacks'
#require_relative 'list_adder'


# configure base cli interface and highline output
class MyCLI < Thor
  #path to config.yml with bot auth info:
  @@config = ConfigLoader.new('config.yml')
  # TODO cool color scheme? lol nah
  HighLine.color_scheme = HighLine::SampleColorScheme.new
  @@output = HighLine.new

  ##
  # cvsdelete from delete-tweets
  #
  desc "csvdelete <profile> <path>", "iterate through a twitter archive's .csv file for <profile> at <path> and delete all tweets."
  long_desc <<-LONGDESC
    csvdelete:
    \x5iterates through a twitter archive's .csv file at <path> and deletes all the tweet ids for <profile>

    --noprompt=true to skip confirmation on each
    \x5--testrun=true to run the script without performing deletes
  LONGDESC
  option :noprompt, :default => false
  option :testrun, :default => false
  def csvdelete(profile,path)
    client = @@config.get_profile_client(profile)
    DeleteTweets.new(@@output,client,options).csvdelete(path)
  end

  ##
  # prunenonmutuals from nonmutual-pruner
  #
  desc "prunenonmutuals PROFILE", "iterate through nonmutual followers and unfollow. supply --noprompt=true to skip confirmation on each."
  option :noprompt, :default => false
  def prunenonmutuals(profile)
    client = @@config.get_profile_client(profile)
    NonmutualPruner.new(@@output,client,options).prune(profile)
  end

  ##
  # processfriends from friend-pruner
  #
   desc "processfriends PROFILE", "iterate through all friends of PROFILE, give information about each, and give the option to unfollow. if --listname=LISTNAME is provided, members of provided list will be ignored in process, and you will be given the option to add those you choose not to unfollow to that list. if --brief=true is provided, less information lookups will be performed and less info per person shown (such as their last 20 tweets)."
  option :listname, :required => false
  option :brief,    :required => false
  def processfriends(profile)
    client = @@config.get_profile_client(profile)
    FriendPruner.new(@@output,client,options).prune(profile)
  end
end


MyCLI.start(ARGV)



