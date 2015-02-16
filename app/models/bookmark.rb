class Bookmark < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true
  validates :url, presence: true
  validates :description, presence: true
end
