class BooksController < ApplicationController

  STATUS_SORT_ORDER = ['Yes', 'In progress', 'No']

  def index
    @search_term = filter_params[:search_term]

    if @search_term.nil? && params[:sort].nil?
      @books = Book.all.sort_by{|book| book[:title]}
    elsif params[:sort] == 'has_been_read'
      @books = filter(Book.all).sort_by{|book| STATUS_SORT_ORDER.find_index(book[params[:sort]])}
    else
      @books = filter(Book.all).sort_by{|book| book[params[:sort]]}
    end

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
      params.require(:book).permit(:title, :subtitle, :author, :publisher, :publication_date, :number_of_pages, :photo, :year_first_published, :blurb, :has_been_read, :date_finished_reading)
    end

    def filter_params
      params.fetch(:filter, {}).permit(:search_term)
    end

    def filter(books)
      return books if filter_params.empty?
      title_results = books.where("lower(title) LIKE (?)", "%#{filter_params[:search_term]}%")
      author_results = books.where("lower(author) LIKE (?)", "%#{filter_params[:search_term]}%")
      subtitle_results = books.where("lower(subtitle) LIKE (?)", "%#{filter_params[:search_term]}%")
      blurb_results = books.where("lower(blurb) LIKE (?)", "%#{filter_params[:search_term]}%")
      publisher_results = books.where("lower(publisher) LIKE (?)", "%#{filter_params[:search_term]}%")
      list_results = books.joins(:lists).where("lower(lists.title) LIKE (?)", "%#{filter_params[:search_term]}%")
      (title_results + author_results + subtitle_results + list_results + blurb_results + publisher_results).uniq
    end

end
