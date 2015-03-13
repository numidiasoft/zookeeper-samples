require "bundler/setup"
require "zk"

class Election

  def initialize name
    @zk = ZK.new
    @name = name
  end

  def start_server
    submit_condidate
    $stdout.puts "Running the server"

    while true
      sleep(2)
    end
  end

  private
  def submit_condidate
    candidate = @zk.election_candidate(@name, "db.numidiasoft.com", :follow => :leader)

    candidate.on_winning_election { become_master_node }
    candidate.on_losing_election { become_slave_of_master }
    
    candidate.vote!
  end

  def become_master_node
    $stdout.puts "I'm the leader :) my process id is #{Process.pid}"
    $stdout.puts "I'am processing the message"
  end

  def become_slave_of_master
    $stdout.puts "I'm the slave :( my process is #{Process.pid} "
  end

end

name = "realtime_election"
Election.new(name).start_server
