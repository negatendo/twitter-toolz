require 'highline/import'

def catch_twitter
  # custom error catching for twitter gem
  # inspired by https://github.com/BooDoo/ebooks_example/blob/master/boodoo.rb
  max_error_retries = 3
  timeout_sleep = 10
  retries = 0
  output = HighLine.new
  begin
    yield
  rescue Twitter::Error => error
    retries += 1
    raise if retries > max_error_retries
    if error.class == Twitter::Error::TooManyRequests
      output.say("RATE: Going to sleep for ~#{timeout_sleep} minutes...")
      sleep timeout_sleep * 60
      retry
    elsif ["execution", "capacity"].any?(&error.to_s.method(:include?))
      output.say("WARN: Timeout?\n\t#{error}\nSleeping for #{timeout_sleep} seconds...")
      sleep timeout_sleep
      retry
    elsif error.class == Twitter::Error::Forbidden
      # don't count "Already faved/followed" message against attempts
      retries -= 1 if error.to_s.include?("already")
      output.say("WARN: #{error.to_s}")
      return true
    elsif error.class == Twitter::Error::NotFound
      # don't retry 404s just continue
      retries -= 1
      output.say("WARN: Twitter::Error::NotFound but we are going to continue: #{error.to_s}")
      return true
    else
      say("ERR: Unhandled exception from Twitter: #{error.to_s}")
      raise
    end
  end
end
