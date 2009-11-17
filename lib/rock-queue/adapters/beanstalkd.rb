begin
  require "beanstalk-client"
rescue
  puts "You need `beanstalk-client` gem to use the Beanstalkd rock-queue interface"
  exit
end

module RockQueue
  class Beanstalkd
    
    attr_reader :obj
    
    def initialize(options = {})
      @obj = Beanstalk::Pool.new(["#{options[:server]}:#{options[:port]}"])
    end
  
    def pop
      loop
    end 
  end
end