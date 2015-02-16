class User < ActiveRecord::Base
  validates :username, uniqueness: true, presence: true
  include BCrypt

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def authenticate(password)
    self.password == password unless password.blank?
  end
end
