# Twitter Toolz

Various handy Twitter API tools made in Ruby and to be run from the command line. See the "Run" section for a list of some commands.

## Install

Requires Ruby 2.3.0 or higher. Run bundler to install required gems.

```
$ bundle install
```

## Configure

Copy the file sample.config.yml to config.yml and edit it, replacing the example information with your API keys. The file format is very similar to what [Twurl](https://github.com/twitter/twurl) produces, so I recommend that tool. You will of course have to set register your Twitter application with Twitter first.

twitter-toolz support multiple Twitter profiles (accounts). Just add authorization information for each, as shown in the sample.config.yml file.

## Run

Run dostuff to see a list of commands:

```
$ ./dostuff
```

Then run your commands like so:

```
$ ./dostuff csvdelete mytwitter ~/archive.csv
```

## List of Commands

+ addtolist - Quickly add someone to the provided list name.
+ csvdelete - Delete all tweets using the archive.csv file you get from your Twitter archive as an index. This is the most reliable way I've found to delete all tweets.
+ importlist - Import members captured in a .txt file (maybe other formats coming soon) to a list.
+ processfriends - Iterate randomly through each of your friends, show some information, and offer options for unfollowing, adding to lists, etc.
+ prunenonmutuals - Unfollow all nonmutual followers.
+ softprune - Softblock (block then unblocks, thus making them unfollow you) all nonmutuals.

