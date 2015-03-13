require "bundler/setup"
require "zookeeper"
require "time"

# This process set a watcher on a defined path and track each modification
# Can be used to check if a worker is not in a weird state 

class WatchEvents

  def initialize(path)
    @path = path
    @zk =  Zookeeper.new("localhost:2181")
    @watcher = Zookeeper::Callbacks::WatcherCallback.new {}
  end

  def run
    get = @zk.get(path: @path, watcher: @watcher)
    @last_event = Time.parse(get[:data])
    puts "Waiting for events ................."
    watch
  end

  def process_data(data)
    puts "Data : #{data.inspect}"
  end

  def wait(watcher:, timeout:)
    time_to_stop = Time.now + timeout
    until watcher.completed?
      if Time.now > time_to_stop
        return false
      end
    end
    return true
  end

  def watch
    while true do
      success = wait(watcher: @watcher, timeout: 10)
      if success
        @watcher.instance_variable_set('@completed', false)
        get = @zk.get(path: @path, watcher: @watcher)
        puts "new data new data"
        puts get[:data]
        @last_event = Time.parse(get[:data])
      else
        @watcher.instance_variable_set('@completed', false)
        @zk.get(path: @path, watcher: @watcher)
      end
     
      witness = ((Time.now - @last_event)/60)
      check_healthy(witness)
      sleep(2)
    end
  end

  private 
  def check_healthy witness
    if witness> 1.0
      puts "Your worker has a pb, no  event since #{witness}"
    else
      puts "Everything is ok !!"
    end
  end

end

WatchEvents.new("/formatter/hello").run
