class Mention < ActiveRecord::Base
  belongs_to :thought
  belongs_to :mentionee, class_name: 'User'

  has_one :mentioner, through: :thought, source: :user

  validates :thought, :mentioner, :mentionee, presence: true
end
