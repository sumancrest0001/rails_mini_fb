# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  before :each do
    @user = User.new(name: 'test', email: 'test@test.com', password: 'test1234')
  end

  context 'Username validation' do
    it 'Valid username check' do
      expect(@user).to be_valid
    end

    it 'Invalid username check ' do
      @user.name = 'xxx'
      expect(@user).to_not be_valid
    end
  end

  context 'Email validation' do
    it 'Valid email check' do
      expect(@user).to be_valid
    end

    it 'Invalid email check' do
      @user.email = 'xxx'
      expect(@user).to_not be_valid
    end
  end
end
