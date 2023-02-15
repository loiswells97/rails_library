require 'rails_helper'

RSpec.describe List, type: :model do
  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:books) }
  end
end
