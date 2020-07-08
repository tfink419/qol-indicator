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
    :format => URI::MailTo::EMAIL_REGEXP,
    :uniqueness => true

  has_many :password_resets, dependent: :destroy
  has_one :map_preferences, dependent: :destroy

  before_validation do

  end

  scope :clean_order, lambda { |attr, dir| 
    #ensure attr and dir are safe values to use by checking within an array of allowed values
    attr = (User.attribute_names.include? attr) ? attr : 'created_at'
    dir.upcase!
    dir = (['ASC', 'DESC'].include? dir) ? dir : 'ASC'
    if ['first_name', 'last_name', 'email', 'username'].include? attr
      # case insensitive sort
      order(Arel.sql("lower(users.#{attr}) #{dir}"))
    else
      order("#{attr} #{dir}")
    end
  }

  def admin?
    is_admin
  end

  def public_attributes 
    {
      :id => id,
      :first_name => first_name,
      :last_name => last_name,
      :username => username,
      :email => email
    }
  end

  def name
    [first_name, last_name].join(' ')
  end
end
