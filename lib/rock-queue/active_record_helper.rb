require 'active_record'

module RockQueue
  module ActiveRecordHelper
    def self.included(base) 
      base.extend ClassMethods 
      base.send(:include, InstanceMethods) 
    end
    
    module ClassMethods
      def perform(*args)
        args = args.first
        id = args.shift
        method = args.shift
        find(id).send(method, *args)
      end
      
      def queue
        const_defined?(:QUEUE) ? self::QUEUE : :default
      end   
    end
    
    module InstanceMethods 
      def async(method, *args)
	return true if Config.instance.stub_active_record
        RockQueue.push(self.class.queue, self.class, id, method, *args)
      end
      
      def async_at(method, time_to_run_at, *args)
	return true if Config.instance.stub_active_record
        RockQueue.push_at(self.class, time_to_run_at, id, method, *args)
      end
    end 
  end
end
