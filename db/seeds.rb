# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# User.transaction do
#   100.times do
#     User.create(
#           email: FFaker::Internet.email,
#           handle: FFaker::HipsterIpsum.words.join('_').gsub(/[^a-z0-9]/i,'_').downcase,
#           password: SecureRandom.hex
#     )
#   end
# end
#
# Thought.transaction do
#   User.find_each do |user|
#     10.times do
#       user.thoughts.create(message: FFaker::HipsterIpsum.sentence)
#     end
#   end
# end