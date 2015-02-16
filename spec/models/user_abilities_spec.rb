require 'spec_helper'
require "cancan/matchers"

describe User do
  describe "abilities" do
    let(:user) { nil }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:user_bookmark) { FactoryGirl.create(:bookmark, user: user) }
    let(:other_user_bookmark) { FactoryGirl.create(:bookmark, user: other_user) }
    subject(:ability) { Ability.new(user) }

    context "when is a guest" do
      it { is_expected.to     be_able_to(:read,   other_user) }
      it { is_expected.to_not be_able_to(:manage, other_user) }
      it { is_expected.to     be_able_to(:read,   other_user_bookmark) }
      it { is_expected.to_not be_able_to(:manage, other_user_bookmark) }
    end

    context "when is a user" do
      let(:user) { FactoryGirl.create(:user) }
      it { is_expected.to     be_able_to(:read,   user) }
      it { is_expected.to     be_able_to(:manage, user) }
      it { is_expected.to     be_able_to(:read,   user_bookmark) }
      it { is_expected.to     be_able_to(:manage, user_bookmark) }
      it { is_expected.to     be_able_to(:read,   other_user) }
      it { is_expected.to_not be_able_to(:manage, other_user) }
      it { is_expected.to     be_able_to(:read,   other_user_bookmark) }
      it { is_expected.to_not be_able_to(:manage, other_user_bookmark) }
    end

    context "when is an admin" do
      let(:user) { FactoryGirl.create(:admin) }
      it { is_expected.to be_able_to(:read,   user) }
      it { is_expected.to be_able_to(:manage, user) }
      it { is_expected.to be_able_to(:read,   user_bookmark) }
      it { is_expected.to be_able_to(:manage, user_bookmark) }
      it { is_expected.to be_able_to(:read,   other_user) }
      it { is_expected.to be_able_to(:manage, other_user) }
      it { is_expected.to be_able_to(:read,   other_user_bookmark) }
      it { is_expected.to be_able_to(:manage, other_user_bookmark) }
    end
  end
end
