require 'rails_helper'

RSpec.describe Author, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:books) }
  end

  describe 'methods' do
    context 'when first_name present' do
      subject { build(:author, first_name: 'John', surname: 'Owen') }

      it 'outputs first name and surname' do
        expect(subject.full_name).to eq('John Owen')
      end
    end

    context 'when first_name empty' do
      subject { build(:author, first_name: '', surname: 'Owen') }
      
      it 'outputs just surname' do
        expect(subject.full_name).to eq('Owen')
      end
    end
  end
end
