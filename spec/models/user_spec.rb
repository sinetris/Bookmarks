require 'spec_helper'

describe User do
  subject { FactoryGirl.build(:user) }
  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to validate_uniqueness_of(:username) }
  it { is_expected.to have_and_belong_to_many(:roles) }
  it { is_expected.to have_many(:bookmarks) }
  describe '.authenticate' do
    let(:user) { FactoryGirl.build_stubbed(:user, password: "valid_password") }
    it "authenticate with valid password" do
      expect(user.authenticate("valid_password")).to be true
    end
    it "does not authenticate with invalid password" do
      expect(user.authenticate("invalid_password")).to be false
    end
  end

  describe '.has_role?' do
    let(:user) { FactoryGirl.create(:admin) }
    it "have the right role" do
      expect(user.has_role?(:admin)).to be true
    end
    it "don't have other roles" do
      expect(user.has_role?(:fake)).to be false
    end
  end

  describe '.add_role' do
    let(:user) { FactoryGirl.create(:user) }
    it "add a role to roles" do
      expect {
        user.add_role(:admin)
      }.to change { user.roles.count }.by(1)
    end
    it "don't add the role twice" do
      expect {
        user.add_role(:admin)
        user.add_role(:admin)
      }.to change { user.roles.count }.by(1)
    end
  end
end
