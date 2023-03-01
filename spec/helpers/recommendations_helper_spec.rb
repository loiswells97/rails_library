require 'rails_helper'

RSpec.describe RecommendationsHelper, type: :helper do
  describe 'related books' do
    let(:series) { create(:series) }
    let!(:book1) { create(:book, series: series) }
    let!(:book2) { create(:book, author: book1.author) }
    let!(:book3) { create(:book, series: series) }
    let!(:book4) { create(:book)}
    let!(:list) { create(:list, books: [book3, book4]) }

    it 'considers a book to be related to itself' do
      expect(helper.related_books([book1])).to include(book1)
    end

    it 'considers books with the same author to be related' do
      expect(helper.related_books([book1])).to include(book2)
    end

    it 'considers books from the same series to be related' do
      expect(helper.related_books([book1])).to include(book3)
    end

    it 'considers books on the same list to be related' do
      expect(helper.related_books([book3])).to include(book4)
    end
  end
end
