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

  describe 'rogue_suggestions' do
    let(:recently_read_book) { create(:book, has_been_read: 'Yes', date_finished_reading: 1.day.ago) }
    let(:unrecently_read_book) { create(:book, has_been_read: 'Yes', date_finished_reading: 2.years.ago) }
    let(:current_book) { create(:book, has_been_read: 'In progress') }

    before do
      helper.cookies[:rogue_wait] = 1
    end

    it 'does not suggest read books' do
      expect(rogue_suggestions).not_to include(recently_read_book)
      expect(rogue_suggestions).not_to include(unrecently_read_book)
    end

    it 'does not suggest current books' do
      expect(rogue_suggestions).not_to include(current_book)
    end

    it 'does not suggest books related to current books' do
      book = create(:book, author: current_book.author, has_been_read: 'No')
      expect(rogue_suggestions).not_to include(book)
    end

    it 'does not suggest books related to recently read books' do
      book = create(:book, author: recently_read_book.author, has_been_read: 'No')
      expect(rogue_suggestions).not_to include(book)
    end

    it 'suggests books related to unrecently read books' do
      book = create(:book, author: unrecently_read_book.author, has_been_read: 'No')
      expect(rogue_suggestions).to include(book)
    end

    it 'suggests unread books that are unrelated to read and current books' do
      book = create(:book, has_been_read: 'No')
      expect(rogue_suggestions).to include(book)
    end
  end

  describe 'rereads' do
    let(:book) {create(:book)}
    before do
      helper.cookies[:reread_wait] = 5
    end

    it 'does not suggest related unread books' do
      unread_book = create(:book, author: book.author, has_been_read: 'No')
      expect(rereads([book])).not_to include(unread_book)
    end

    it 'does not suggest related in progress books' do
      current_book = create(:book, author: book.author, has_been_read: 'In progress')
      expect(rereads([book])).not_to include(current_book)
    end

    it 'does not suggest related books read within wait period' do
      recently_read_book = create(:book, author: book.author, has_been_read: 'Yes', date_finished_reading: 1.year.ago)
      expect(rereads([book])).not_to include(recently_read_book)
    end

    it 'does not suggest unrelated books read before wait period' do
      unrelated_book = create(:book, has_been_read: 'Yes', date_finished_reading: 10.years.ago)
      expect(rereads([book])).not_to include(unrelated_book)
    end

    it 'suggests related books read before wait period' do
      unrecently_read_book = create(:book, author: book.author, has_been_read: 'Yes', date_finished_reading: 10.years.ago)
      expect(rereads([book])).to include(unrecently_read_book)
    end
  end
end
