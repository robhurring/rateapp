class Topic
  class << self
    def get(key)
      if data = $redis.get(key)
        new JSON.parse(data).merge('key' => key)
      else
        create(key)
      end
    end

    def create(key)
      obj = new('key' => key, 'name' => 'Awesomeness', 'score' => 0, 'votes' => 0)
      obj.save
      obj
    end
  end

  attr_reader :key

  def initialize(attributes = {})
    @key = attributes.delete 'key'
    @attributes = attributes
  end

  def name
    @attributes['name']
  end

  def score
    (@attributes['score'] || 0).to_i
  end

  def votes
    (@attributes['votes'] || 0).to_i
  end

  def incr!
    self.votes += 1
    self.score += 1
  end

  def decr!
    self.votes += 1
    self.score -= 1
  end

  def percent
    return 0 if votes.zero?
    p = (score.to_f / votes.to_f * 100).round

    if p < 0
      0
    elsif p > 100
      100
    else
      p
    end
  end

  def save
    $redis.set @key, self.to_json
  end

  def destroy
    $redis.del @key
  end

  def to_h
    @attributes.merge('percent' => percent)
  end

  def to_json
    to_h.to_json
  end

protected

  def score=(value)
    @attributes['score'] = value
  end

  def votes=(value)
    @attributes['votes'] = value
  end
end
