class User < ActiveRecord::Base
  validates :username, uniqueness: true, presence: true
  include BCrypt
  has_and_belongs_to_many :roles

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

  # roles
  def add_role(role_name)
    role = Role.where(name: role_name).first_or_create
    if !roles.include?(role)
      roles << role
      save
    end
    role
  end

  def has_role?(role_name)
    !!roles.where(name: role_name).first
  end
end
