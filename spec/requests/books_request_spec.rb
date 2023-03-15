require 'rails_helper'

RSpec.describe "Books", type: :request do
  let!(:book1) { create(:book) }
  let!(:book2) { create(:book) }

  describe '#show' do
    before do
      get book_path(book1.id)
    end

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns show page for the correct book' do
      expect(CGI.unescapeHTML(response.body)).to include(book1.title)
    end
  end

  describe '#index' do
    before do
      get books_path
    end

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns page containing the book titles' do
      expect(CGI.unescapeHTML(response.body)).to include(book1.title, book2.title)
    end
  end

  describe '#create' do
    let(:new_book) { build(:book) }
    let(:book_params) {
      {
        title: new_book.title,
        author: new_book.author,
        publisher: new_book.publisher,
        series_attributes: {
          title: ''
        }
      }
    }

    it 'creates book' do
      expect{ post books_path, params: { book: book_params } }.to change{ Book.count }.by(1)
    end
    
    it 'redirects to index page' do
      post books_path, params: { book: book_params } 
      expect(response).to redirect_to(books_path)
    end
  end

  describe '#update' do
    let(:updated_book_params) { { title: 'New title', author_attributes: author_attributes, publisher: book1.publisher, series_attributes: {title: ''} } }

    context 'author is the same as before' do
      let(:author_attributes) { { first_name: book1.author.first_name, surname: book1.author.surname } }
      it 'updates book' do
        expect {  put book_path(book1.id), params: { book: updated_book_params } }.to change { book1.reload.title }.to('New title')
      end

      it 'does not change author' do
        expect { put book_path(book1.id), params: { book: updated_book_params } }.not_to change { book1.reload.author }
      end
    end

    context 'old author only has one book' do
      context 'author changed to author of another book' do
        let(:author_attributes) { { first_name: book2.author.first_name, surname: book2.author.surname } }
  
        it 'updates author to be the same as other book' do
          expect { put book_path(book1.id), params: {book: updated_book_params } }.to change {book1.reload.author}.to(book2.author)
        end
    
        it 'deletes old author' do
          expect { put book_path(book1.id), params: {book: updated_book_params } }.to change { Author.count }.by(-1)
        end
      end
  
      context 'author changed to new author' do
        let(:new_author) { build(:author) }
        let(:author_attributes) { { first_name: new_author.first_name, surname: new_author.surname } }
  
        it 'creates replaces old author' do
          expect { put book_path(book1.id), params: {book: updated_book_params } }.not_to change { Author.count }
        end
  
        it 'updates book author' do
          expect { put book_path(book1.id), params: {book: updated_book_params } }.to change {book1.reload.author.full_name}.to(new_author.full_name)
        end
      end
    end

    context 'old author has more than one book' do
      let!(:book3) { create(:book, author: book1.author) }

      context 'author changed to author of another book' do
        let(:author_attributes) { { first_name: book2.author.first_name, surname: book2.author.surname } }
        
        it 'does not change number of authors' do
          expect { put book_path(book1.id), params: {book: updated_book_params } }.not_to change { Author.count }
        end

        it 'updates author of book' do
          expect { put book_path(book1.id), params: {book: updated_book_params } }.to change {book1.reload.author}.to(book2.author)
        end

        it 'does not change author of other book' do
          expect { put book_path(book1.id), params: {book: updated_book_params } }.not_to change {book3.reload.author}
        end
      end

      context 'author changed to new author' do
        let(:new_author) { build(:author) }
        let(:author_attributes) { { first_name: new_author.first_name, surname: new_author.surname } }

        it 'creates a new author' do
          expect { put book_path(book1.id), params: {book: updated_book_params } }.to change { Author.count }.by(1) 
        end

        it 'updates author of book' do
          expect { put book_path(book1.id), params: {book: updated_book_params } }.to change {book1.reload.author.full_name}.to(new_author.full_name)
        end

        it 'does not change author of other book' do
          expect { put book_path(book1.id), params: {book: updated_book_params } }.not_to change {book3.reload.author}
        end
      end
    end
  end
end
