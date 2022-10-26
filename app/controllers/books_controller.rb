class BooksController < ApplicationController

  def index
    @books = filter(Book.order('title ASC'))
  end

  def show
    @book = Book.find(params[:id])
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to(books_path)
    else
      render('new')
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to(book_path(@book))
    else
      render('edit')
    end
  end

  def delete
    @book = Book.find(params[:id])
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to(books_path)
  end

  private
    def book_params
      params.require(:book).permit(:title, :subtitle, :author, :publisher, :publication_date, :number_of_pages, :photo, :year_first_published, :has_been_read)
    end

    def filter_params
      params.fetch(:filter, {}).permit(:search_term)
    end

    def filter(relation)
      return relation if filter_params.empty?
      relation.where("lower(title) LIKE (?)", "%#{filter_params[:search_term]}%")
      .or(relation.where("lower(author) LIKE (?)", "%#{filter_params[:search_term]}%"))
    end

end
