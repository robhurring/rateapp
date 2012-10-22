class Topic
  def self.get(key)
    new key
  end

  attr_reader :key

  def initialize(key)
    @key = key
    initialize_if_necessary
  end

  def name
    $redis.hget key, 'name'
  end

  def name=(new_name)
    $redis.hset key, 'name', name
    self.score = 0
  end

  def score
    total = ($redis.hget key, 'score').to_i
    return 0 if votes.nil? || votes.zero?

    (total / votes.to_f).round
  end

  def score=(new_score)
    $redis.hset key, 'score', 0
    $redis.hset key, 'votes', 0
  end

  def incr!(ip = nil)
    $redis.hincrby key, 'score', 1
    $redis.hincrby key, 'votes', 1
  end

  def decr!(ip = nil)
    $redis.hincrby key, 'score', -1
    $redis.hincrby key, 'votes', 1
  end

  def votes
    $redis.hget(key, 'votes').to_i
  end

private

  def initialize_if_necessary
    self.name = 'Default' if name.nil?
    # self.score = 0 if score.zero?
  end
end
