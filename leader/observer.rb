require "bundler/setup"
require "zk"

class Observer

  def initialize name
    @zk = ZK.new
    @name = name
  end

  def start_server
    init_observer
    $stdout.puts "Running the server"

    while true
      sleep(2)
    end
  end

  def init_observer
    observer = @zk.election_observer(@name)

    observer.on_leaders_death do
      $stdout.puts "A leader is dead :( :)"
    end

    observer.on_new_leader do
      $stdout.puts " A new leader is elected :( :("
    end

    observer.observe!

  end

end

name = "realtime_election"
Observer.new(name).start_server
