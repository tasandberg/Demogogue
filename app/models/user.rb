class User < ActiveRecord::Base
  validates :email, :password_digest, :session_token, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }

  after_initialize :ensure_session_token

  def self.find_by_credentials(user_params)
    user = User.find_by_email(user_params[:email])
    user.try(:is_password?, user_params[:password]) ? user : nil
  end

  def password=(raw_password)
    self.password_digest = BCrypt::Password.create(raw_password)
  end

  def is_password?(password)
    self.password_digest.is_password?(password)
  end

  def password_digest
    BCrypt::Password.new(super)
  end

  def ensure_session_token
    self.session_token ||= generate_session_token
  end

  def generate_session_token
    new_token = SecureRandom.urlsafe_base64
    new_token
  end

  def reset_session_token!
    self.session_token = generate_session_token
    self.save!
    self.session_token
  end

end
