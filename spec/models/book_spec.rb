require 'rails_helper'

RSpec.describe Book, type: :model do

  describe 'associations' do
    it { is_expected.to belong_to(:author) }
    it { is_expected.to accept_nested_attributes_for(:author) }

    it { is_expected.to belong_to(:series).optional(true) }
    it { is_expected.to accept_nested_attributes_for(:series) }

    it { is_expected.to have_and_belong_to_many(:lists) }
    it { is_expected.to have_one_attached(:photo) }
  end

  describe 'methods' do
    let(:author) { Author.new(first_name: 'Dustin', surname: 'Benge') }
    subject { Book.new(title: 'The Loveliest Place', author: author) }

    it 'outputs title and author as expected' do
      expect(subject.title_and_author).to eq("The Loveliest Place (Dustin Benge)")
    end
  end

end
