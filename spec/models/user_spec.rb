require 'spec_helper'

describe User do
  subject { FactoryGirl.build(:user) }
  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to validate_uniqueness_of(:username) }
  describe '.authenticate' do
    let(:user) { FactoryGirl.build_stubbed(:user, password: "valid_password") }
    it "authenticate with valid password" do
      expect(user.authenticate("valid_password")).to be true
    end
    it "does not authenticate with invalid password" do
      expect(user.authenticate("invalid_password")).to be false
    end
  end
end
