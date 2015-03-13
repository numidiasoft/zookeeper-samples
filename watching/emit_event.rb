require "bundler/setup"
require "zk"

# This Process creates a znode and change it avery 5 seconds

class EmitEvent

  def initialize(path)
    @path = path
    @zk = ZK.new
  end

  def run
    @zk.create( @path) rescue ZK::Exceptions::NodeExists
    while true do
      data = "#{Time.now.to_s}"
      rv = @zk.set(@path, data)
      puts rv.inspect
      puts data
      sleep(5)
    end
  end
end

EmitEvent.new("/formatter/hello").run

