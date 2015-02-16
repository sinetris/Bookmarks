require 'spec_helper'

describe User do
  subject { FactoryGirl.build(:bookmark) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to belong_to(:user) }
end
