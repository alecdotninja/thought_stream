class HipCheck
  include ActiveModel::Model

  attr_accessor :user, :time, :topic

  validates :user, :time, :topic, presence: true

  with_options if: -> { time.present? && topic.present? } do
    validates :number_of_users_at_time, numericality: { greater_than: 0 }
    validates :number_of_thoughts_on_topic_at_time, numericality: { greater_than: 0 }
  end

  def hipness
    @hipness ||= user_topic_concentration / average_topic_concentration
  end

  private

  def thoughts_on_topic_at_time
    @thoughts_on_topic_at_time ||= Thought.on_topic(topic).created_before(time.to_time)
  end

  def user_thoughts_on_topic_at_time
    @user_thoughts_on_topic_at_time ||= thoughts_on_topic_at_time.merge(user.thoughts)
  end

  def number_of_thoughts_on_topic_at_time
    @number_of_thoughts_on_topic_at_time ||= BigDecimal.new(thoughts_on_topic_at_time.count)
  end

  def number_of_users_at_time
    @number_of_users_at_time ||= BigDecimal.new(User.created_before(time.to_time).count)
  end

  def average_topic_concentration
    @average_topic_concentration ||= number_of_thoughts_on_topic_at_time / number_of_users_at_time
  end

  def user_topic_concentration
    @user_topic_concentration ||= BigDecimal.new(user_thoughts_on_topic_at_time.count)
  end
end
