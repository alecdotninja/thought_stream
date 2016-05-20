class User < ActiveRecord::Base
  HANDLE_MATCHER = /\A[a-z][a-z0-9_]+\z/i
  UNACHORED_HANDLE_MATCHER = /[a-z][a-z0-9_]+/i

  devise :database_authenticatable, :registerable, :rememberable, :trackable

  has_many :thoughts, inverse_of: :user, dependent: :destroy

  has_many :mentions_as_mentionee, class_name: 'Mention', foreign_key: :mentionee_id, inverse_of: :mentionee, dependent: :destroy
  has_many :mentioners, through: :mentions_as_mentionee

  has_many :mentions_as_mentioner, through: :thoughts, source: :mentions, dependent: :destroy, inverse_of: :mentioner
  has_many :mentionees, through: :mentions_as_mentionee, source: :mentionee

  has_many :mentions, class_name: 'Thought', through: :mentions_as_mentionee, source: :thought

  has_many :follows_as_followee, class_name: 'Follow', foreign_key: :followee_id, inverse_of: :followee, dependent: :destroy
  has_many :followers, through: :follows_as_followee

  has_many :follows_as_follower, class_name: 'Follow', foreign_key: :follower_id, inverse_of: :follower, dependent: :destroy
  has_many :followees, through: :follows_as_follower

  has_many :friendly_follows, -> { friendly }, class_name: 'Follow', foreign_key: :follower_id, inverse_of: :follower
  has_many :friends, through: :friendly_follows, source: :followee, class_name: 'User'

  has_many :checkins, through: :thoughts, inverse_of: :user, dependent: :destroy
  has_many :locations, through: :checkins

  has_one :_thought, class_name: 'Thought', inverse_of: :user # a hack to shut Rails up about the association number
  has_one :most_recent_checkin, -> { most_recent_for_user }, through: :_thought, source: :checkin, class_name: 'Checkin', inverse_of: :user
  has_one :current_location, through: :most_recent_checkin, source: :location, class_name: 'Location'

  validates :handle, presence: true, uniqueness: true, format: HANDLE_MATCHER

  # scope :created_before, ->(time) { where(arel_table[:created_at].lt(time)) }

  def self.created_before(time)
    all.tap do |created_before|
      created_before.where!(
        created_before.table[:created_at].lt(
          Arel::Nodes::BindParam.new
        )
      )

      created_before.bind!(
        [columns_hash['created_at'], time]
      )
    end
  end

  # def related_thoughts
  #   @related_thoughts ||= Thought.distinct.where(
  #     Thought.arel_table[:id].in(
  #       Arel.sql(thoughts.select(:id).to_sql)
  #     ).or(
  #       Thought.arel_table[:id].in(
  #         Arel.sql(mentions.select(:id).to_sql)
  #       )
  #     )
  #   )
  # end

  def related_thoughts
    @related_thoughts ||= Thought.all.tap do |related_thoughts|
      thought_ids = thoughts.except(:distinct, :select).select(:id)
      mention_ids = mentions.except(:distinct, :select).select(:id)

      thoughts_arel = thought_ids.arel
      mentions_arel = mention_ids.arel

      thoughts_binds = thoughts_arel.bind_values + thought_ids.bind_values
      mentions_binds = mentions_arel.bind_values + mention_ids.bind_values

      related_thoughts.where!(
        related_thoughts.table[:id].in(
          thoughts_arel
        ).or(
          related_thoughts.table[:id].in(
            mentions_arel
          )
        )
      )

      (thoughts_binds + mentions_binds).each do |bind|
        related_thoughts.bind!(bind)
      end
    end
  end

  def following?(user)
    if followees.loaded?
      followees.include?(user)
    else
      followees.where(id: user.id).exists?
    end
  end

  def average_time_between_thoughts
    @average_time_between_thoughts ||= thoughts.average_time_between_created_ats
  end
end
