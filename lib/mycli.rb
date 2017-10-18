require 'thor'
require 'highline/import'

require 'csv'

require_relative 'configloader'
require_relative 'catch_twitter'

# each of these bring in a class used by commands
require_relative 'delete-tweets'
#require_relative 'friend-pruner'
#require_relative 'list-adder'
require_relative 'nonmutual-pruner'
#require_relative 'softblock-nonfollowbacks'

# configure base cli interface and highline output
class MyCLI < Thor
  #path to config.yml with bot auth info:
  @@config = ConfigLoader.new('config.yml')
  # TODO cool color scheme? lol nah
  HighLine.color_scheme = HighLine::SampleColorScheme.new
  @@output = HighLine.new

  ##
  # delete-tweets
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
  # nonmutual-prunter
  #
  desc "prune PROFILE", "iterate through nonmutual followers and unfollow. supply --noprompt=true to skip confirmation on each."
  option :noprompt, :default => false
  def prune(profile)
    client = @@config.get_profile_client(profile)
    NonmutualPruner.new(@@output,client,options).prune(profile)
  end
end

MyCLI.start(ARGV)



