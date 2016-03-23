require 'date'

class HipCheck
  include ActiveModel::Model

  attr_accessor :user, :time, :topic

  def user_id
    user.try(:id)
  end

  def user_id=(user_id)
    @user = User.find(user_id)
  end

  def hipness
    @hipness ||= (user_number_of_thoughts_on_topic_at_time - average_user_number_of_thoughts_on_topic_at_time) / average_user_number_of_thoughts_on_topic_at_time
  end

  private

  def time_stamp
    time.to_time
  end

  def thoughts_on_topic_at_time
    @thoughts_on_topic_at_time ||= Thought.on_a_topic_before_a_time(topic, time_stamp)
  end

  def user_thoughts_on_topic_at_time
    @user_thoughts_on_topic_at_time ||= thoughts_on_topic_at_time.merge(user.thoughts)
  end

  def number_of_users_at_time
    @number_of_users_at_time ||= User.created_before(time_stamp).count
  end

  def average_user_number_of_thoughts_on_topic_at_time
    @average_user_number_of_thoughts_on_topic_at_time ||= thoughts_on_topic_at_time.count.to_f / user_thoughts_on_topic_at_time.count
  end

  def user_number_of_thoughts_on_topic_at_time
    @user_number_of_thoughts_on_topic_at_time ||= user_thoughts_on_topic_at_time.count
  end
end