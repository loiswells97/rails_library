class BooksController < ApplicationController

  STATUS_SORT_ORDER = ['Yes', 'In progress', 'No']

  def index
    @search_term = filter_params[:search_term]
    @books = helpers.filter_and_sort_books(Book.all, params[:sort], @search_term)
  end

  def show
    @book = Book.find(params[:id])
    related = helpers.related_books([@book])
    @related_books = (related.uniq - [@book]).sort_by{|book| related.count(book)}.reverse
  end

  def new
    @book = Book.new
    @lists = List.all
  end

  def create
    @book = Book.new(book_params)

    author = Author.find_by(book_params[:author_attributes])
    @book.author = author.nil? ? @book.author : author

    series = Series.find_by(book_params[:series_attributes])
    if @book.series.title == ''
      @book.series = nil
    elsif !series.nil?
      @book.series = series
    end

    if @book.save
      redirect_to(books_path)
    else
      render('new')
    end
  end

  def edit
    @book = Book.find(params[:id])
    @lists = List.all
  end

  def update
    @book = Book.find(params[:id])
    author = @book.author
    series = @book.series
    @book.attributes = book_params

    if author.first_name != book_params[:author_attributes][:first_name] || author.surname != book_params[:author_attributes][:surname]
      new_author = Author.find_by(book_params[:author_attributes])
      @book.author = new_author unless new_author.nil?
    else
      @book.author = author
    end

    if @book.series.title == ''
      @book.series = nil
    elsif series.nil? || series.title != book_params[:series_attributes][:title]
      new_series = Series.find_by(book_params[:series_attributes])
      @book.series = new_series unless new_series.nil?
    else
      @book.series = series
    end

    if @book.save
      if author.books.length == 0
        author.destroy
      end

      if !series.nil? && series.books.length == 0
        series.destroy
      end
      
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
    author = @book.author
    series = @book.series
    
    @book.destroy
    author.destroy unless author.books.length > 0
    series.destroy unless series.books.length > 0

    redirect_to(books_path)
  end

  def recommendations
    recent_duration = cookies[:recent_duration].to_i || 1
    recent_books = Book.where(date_finished_reading: recent_duration.month.ago..Date.today)
    current_books = Book.where(has_been_read: 'In progress')
    @recent_recommendations = helpers.weighted_sample(helpers.related_books(recent_books+current_books, read_status='No'), 5)
    favourite_books = List.find_by(title: 'Favourites 🌟').books
    @favourite_recommendations = helpers.weighted_sample(helpers.related_books(favourite_books, read_status='No'), 5)
    @rouge_recommendations = helpers.rogue_suggestions.sample(5)
    @reread_recommendations = helpers.weighted_sample(helpers.rereads(recent_books+current_books), 5)
    @favourites_list = List.find_by(title: 'Favourites 🌟')
  end

  private
    def book_params
      params.require(:book).permit(
        :id,
        :title,
        :subtitle,
        :series_number,
        :publisher,
        :publication_date,
        :trim,
        :number_of_pages,
        :photo,
        :year_first_published,
        :blurb,
        :has_been_read,
        :date_finished_reading,
        :author_attributes => [:first_name, :surname, :id],
        :series_attributes => [:title],
        list_ids: []
      )
    end

    def filter_params
      params.fetch(:filter, {}).permit(:search_term)
    end
end
