require 'rails_helper'

RSpec.describe BooksHelper, type: :helper do
  let(:books) { Book.where(id: [create(:book), create(:book), create(:book)].map(&:id)) }

  describe 'filter_and_sort_books' do
    before do
      allow(helper).to receive(:filter_books).and_return(books)
      allow(helper).to receive(:sort_books)
      helper.filter_and_sort_books(books, :number_of_pages, 'search term')
    end
    it 'filters the books by the search term' do
      expect(helper).to have_received(:filter_books).with(books, 'search term')
    end

    it 'sorts the books by the attribute provided' do
      expect(helper).to have_received(:sort_books).with(books, :number_of_pages)
    end
  end

  describe 'filter_books' do
    let(:book) { books.sample }
    let!(:series) { create(:series, books: [book])}
    let!(:list) { create(:list, books: [book]) }

    it 'filters by title' do
      search_results = helper.filter_books(books, book.title)
      expect(search_results).to include(book)
    end

    it 'filters by subtitle' do
      search_results = helper.filter_books(books, book.subtitle)
      expect(search_results).to include(book)
    end

    it 'filters by blurb' do
      search_results = helper.filter_books(books, book.blurb[10..25])
      expect(search_results).to include(book)
    end

    it 'filters by author full name' do
      search_results = helper.filter_books(books, book.author.full_name)
      expect(search_results).to include(book)
    end

    it 'filters by publisher' do
      search_results = helper.filter_books(books, book.publisher)
      expect(search_results).to include(book)
    end

    it 'filters by series' do
      search_results = helper.filter_books(books, book.series.title)
      expect(search_results).to include(book)
    end

    it 'filters by list' do
      search_results = helper.filter_books(books, book.lists[0].title)
      expect(search_results).to include(book)
    end
  end

  describe 'sort_books' do
    it 'defaults to sorting by title' do
      sorted_books = helper.sort_books(books, nil)
      expect(sorted_books).to eq(books.sort_by{|book| book.title})
    end

    it 'sorts by has_been_read correctly' do
      sorted_books = helper.sort_books(books, 'has_been_read')
      STATUS_SORT_ORDER = ["Yes", "In progress", "No"]
      expect(sorted_books).to eq(books.sort_by{|book| STATUS_SORT_ORDER.find_index(book.has_been_read)})
    end

    it 'sorts by author surname' do
      sorted_books = helper.sort_books(books, 'author')
      expect(sorted_books).to eq(books.sort_by{|book| book.author.surname})
    end

    it 'sorts by other attributes correctly' do
      sorted_books = helper.sort_books(books, 'number_of_pages')
      expect(sorted_books).to eq(books.sort_by{|book| book.number_of_pages})
    end
  end
end
