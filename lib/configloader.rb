require 'yaml'
require 'twitter'

class ConfigLoader
  # loads and acts on config.yml file
  def initialize(path)
    begin
      @config = YAML.load_file(path)
    rescue
      raise "Could not load config.yml"
      exit
    end
  end
  def get_all_profiles
    # returns all profile names
    profiles =[]
    @config['profiles'].each do |profile|
      profiles << profile.first
    end
    return profiles
  end
  def get_profile(profilename)
    # returns profile config
    profile = @config['profiles'][profilename]
    if profile
      return profile
    else
      raise "Could not find configuration info for a profile called " + profilename
    end
  end
  def get_profile_client(profilename)
    # returns a client connected to profile
    profile = get_profile(profilename)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = profile['consumer_key']
      config.consumer_secret     = profile['consumer_secret']
      config.access_token        = profile['token']
      config.access_token_secret = profile['secret']
    end
    return client
  end
  def get_config_value(profilename,key)
    # return value for just one config var
    return @config['profiles'][profilename][key]
  end
end
