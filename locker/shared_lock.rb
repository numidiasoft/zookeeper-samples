require "bundler/setup"
require "zk"

# This class give us the possibilty to get a shared lock for an resource
# If another process try to get an exclusive lock, il will be blocked until all procceses having the shared lock release it 

class SharedLock 

  def initialize path
    @zk = ZK.new
    @path = path
  end

 
  def process_messages
    @zk.with_lock("/formatter/facebook", mode: :shared) do |event|
      $stdout.puts  "I got the shared lock"
      while true
        yield
      end
    end
  end
end

path = "/formatter/shared"

SharedLock.new(path).process_messages do 
  $stdout.puts  "I got the shared lock"
  sleep(2)
end
