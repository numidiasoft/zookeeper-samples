require 'bundler/setup'
require 'zk'

# This is an example of how we can get an exclusive lock between two distribued procceses  
#
# To test it: 
# - Start two instances of this script
# - One of the two processes will block
# - Crash the non blocked process to see how the second one gets the lock

class Lock

 def initialize path
   @path = path
   @zk = ZK.new
 end

 def process_messages
   puts "waiting the lock ........"
   @zk.with_lock(@path) do |lock|
     puts "lock got !!!!!"
     while true
       yield
     end
   end
 end

end

path = "/formatter/facebook"
Lock.new(path).process_messages do
  puts "I am getting the messsage"
  sleep(10)
end
