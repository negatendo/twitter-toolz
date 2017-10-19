# skeleton class for command classes
class MyCLIPart
  @output = false
  @client = false
  @options = []
  def initialize(output,client,options)
    # send highline obj and a twitter client
    @output = output
    @client = client
    @options = options
  end
end

