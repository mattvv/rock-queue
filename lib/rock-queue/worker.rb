module RockQueue
  class Worker
    # Whether the worker should log basic info to STDOUT
    attr_accessor :verbose
    
    # Initialize connection to queue server
    def initialize(*queues)
      @queues = queues
      RockQueue.logger.info "=> Initializing..."
    end
    
    # Main worker loop where all jobs are beeing pulled of the queue. 
    # This is also a place where every job starts and ends it's lifecycle.
    def work(interval = 5)
      RockQueue.logger.info "=> Worker ready. Hold your horses!"
      loop do
        ActiveRecord::Base.verify_active_connections!
        RockQueue.receive do |queue|
          if queue
            begin
              # code that actually performs the action
              args = queue.args.first
              RockQueue.logger.info "=> Processing class #{queue.object.name} with params: #{args.inspect}"
              args.empty? ? queue.object.perform : queue.object.perform(args)
            rescue Object => e
              # Add failed processing and retry
              if queue.add_fail(e)
                sleep(queue.get_sleep_time)
                RockQueue.logger.error "=> Processing fail! Retrying #{queue.fails.length}"
                RockQueue.logger.error "   Message: #{e.message}"
                retry
              end
            end
          end
        end
        break if interval == 0
      end
    end
 
  end
end
