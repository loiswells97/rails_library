require 'rails_helper'

RSpec.describe Series, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:books) }
  end
end
