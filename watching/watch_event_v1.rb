require "bundler/setup"
require "zk"

# This process set a watcher on a defined path and track each modification
# Can be used to check if a worker is not in a weird state or modify a worker confoguration withour restart it

class WatchEvent

  def initialize path
    @zk = ZK.new
    @path = path
    @zk.create("/formatter") rescue ZK::Exceptions::NodeExists
    @zk.create("/formatter/hello") rescue ZK::Exceptions::NodeExists
  end

  def subscribe
    @zk.register(@path, only: :changed) do |event|
      if event.node_changed?
        data = @zk.get(@path, watch: true).first
        process(data)
      end
    end

    r= @zk.stat(@path, watch: true)
    puts "Subscribed to #{@path}"
    self
  end

  def watch
    subscribe
    puts "Waiting events !!!!!!!!!!!!!!!"
    while true;end
  end

  private 
  def process data
    puts data
  end
end

WatchEvent.new("/formatter/hello").watch
