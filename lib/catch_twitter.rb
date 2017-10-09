def catch_twitter
  #custom error catching for twitter gem
  #ty https://github.com/BooDoo/ebooks_example/blob/master/boodoo.rb
  max_error_retries = 3
  timeout_sleep = 10
  retries = 0
  begin
    yield
  rescue Twitter::Error => error
    retries += 1
    raise if retries > max_error_retries
    if error.class == Twitter::Error::TooManyRequests
      puts "RATE: Going to sleep for ~#{timeout_sleep} minutes..."
      sleep timeout_sleep * 60
      retry
    elsif error.class == Twitter::Error::Forbidden
      # don't count "Already faved/followed" message against attempts
      retries -= 1 if error.to_s.include?("already")
      puts "WARN: #{error.to_s}"
      return true
    elsif ["execution", "capacity"].any?(&error.to_s.method(:include?))
      puts "ERR: Timeout?\n\t#{error}\nSleeping for #{timeout_sleep} seconds..."
      sleep timeout_sleep
      retry
    elsif error.class == Twitter::Error::NotFound
    else
      puts "Status does not exist but continuing"
      return true
    end
  end
end
