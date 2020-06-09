class User < ApplicationRecord
  has_secure_password

  validates :first_name, :presence => true,
    :length => { :maximum => 50 }
  validates :last_name, :presence => true,
    :length => { :maximum => 50 }
  validates :username, :presence => true,
    :length => { :within => 4..25 },
    :uniqueness => true
  validates :email, :presence => true,
    :format => URI::MailTo::EMAIL_REGEXP

  def admin?
    is_admin
  end

  def public_attributes 
    {
      :id => id,
      :first_name => first_name,
      :last_name => last_name,
      :username => username,
      :email => email,
      :is_admin => is_admin,
      :updated_at => updated_at,
      :created_at => created_at
    }
  end

  def name
    [first_name, last_name].join(' ')
  end
end
