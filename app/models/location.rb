class Location < ActiveRecord::Base
  HANDLE_MATCHER = /\A[a-z][a-z0-9_]+\z/i
  UNACHORED_HANDLE_MATCHER = /[a-z][a-z0-9_]+/i

  has_many :checkins, inverse_of: :location, dependent: :destroy
  has_many :thoughts, through: :checkins
  has_many :users, -> { uniq }, through: :checkins

  has_many :most_recent_checkins_for_user, -> { most_recent_for_user }, class_name: 'Checkin', inverse_of: :location
  has_many :users_here_now, through: :most_recent_checkins_for_user, source: :user, class_name: 'User', inverse_of: :current_location

  scope :by_last_checked_in, -> { includes(:checkins).references(:checkins).merge(Checkin.order(created_at: :desc)) }

  validates :handle, presence: true, uniqueness: true, format: HANDLE_MATCHER
end
