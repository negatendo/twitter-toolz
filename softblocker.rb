#!/usr/bin/env ruby

require 'thor'
require_relative 'lib/configloader'
require_relative 'lib/catch_twitter'

class MyCLI < Thor
  #path to config.yml with bot auth info:
  @config = ConfigLoader.new('config.yml')

  desc "dostuff THING", "dostuff for THING"
  def dostuff()
  end

end

MyCLI.start(ARGV);

