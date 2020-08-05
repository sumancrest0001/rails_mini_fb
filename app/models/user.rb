# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :friendships
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id'
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  before_save { self.email = email.downcase }

  validates :name, length: { minimum: 4, maximum: 50 }, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false },
                    length: { minimum: 10, maximum: 255 }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook]

  def likes?(post)
    like = Like.where('post_id = ? and user_id = ?', post.id, id)
    like.count.positive?
  end

  # returns an array of friend who are friends with a particular user.
  def friends
    friendships.where(status: true).pluck(:friend_id)
    inverse_friendships.where(status: true).pluck(:user_id)
  end

  def pending_friends(_user)
    friendships.where(status: false).pluck(:friend_id)
  end

  def received_requests(user)
    inverse_friendships.where(status: false).pluck(:user_id).include?(user.id)
  end

  def friend_requests
    inverse_friendships.map { |f| f unless f.status }.compact
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
  
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      #user.image = auth.info.image assuming the user model has an image
    end
  end
end
