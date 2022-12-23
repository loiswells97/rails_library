class BooksController < ApplicationController

  STATUS_SORT_ORDER = ['Yes', 'In progress', 'No']

  def index
    @search_term = filter_params[:search_term]

    if @search_term.nil? && params[:sort].nil?
      @books = Book.all.sort_by{|book| book[:title]}
    elsif params[:sort] == 'has_been_read'
      @books = filter(Book.all).sort_by{|book| STATUS_SORT_ORDER.find_index(book[params[:sort]])}
    elsif params[:sort] == 'author'
      @books = filter(Book.all).sort_by{|book| book.author.surname}
    else
      @books = filter(Book.all).sort_by{|book| book[params[:sort]] || 0}
    end

  end

  def show
    @book = Book.find(params[:id])
  end

  def new
    @book = Book.new
    @lists = List.all
  end

  def create
    author = Author.find_by(book_params[:author_attributes])
    if author.nil?
      @book = Book.new(book_params)
    else
      @book = Book.new(book_params)
      @book.author = author
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
    @book.attributes = book_params

    if author.first_name != book_params[:author_attributes][:first_name] || author.surname != book_params[:author_attributes][:surname]
      new_author = Author.find_by(book_params[:author_attributes])
      @book.author = new_author unless new_author.nil?
    else
      @book.author = author
    end

    if @book.save
      if author.books.length == 0
        author.destroy
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
    @book.destroy
    redirect_to(books_path)
  end

  def recommendations
    recent_books = Book.where(date_finished_reading: Date.today-30..Date.today)
    @recent_recommendations = related_books(recent_books).sample(5)
    favourite_books = List.find_by(title: 'Favourites 🌟').books
    @favourite_recommendations = related_books(favourite_books).sample(5)

  end

  private
    def book_params
      params.require(:book).permit(
        :title,
        :subtitle,
        :publisher,
        :publication_date,
        :number_of_pages,
        :photo,
        :year_first_published,
        :blurb,
        :has_been_read,
        :date_finished_reading,
        :author_attributes => [:first_name, :surname],
        list_ids: []
      )
    end

    def filter_params
      params.fetch(:filter, {}).permit(:search_term)
    end

    def filter(books)
      return books if filter_params.empty?
      title_results = books.where("lower(title) LIKE (?)", "%#{filter_params[:search_term]}%")
      author_results = books.joins(:author).where("lower(authors.first_name || ' ' || authors.surname) LIKE (?)", "%#{filter_params[:search_term]}%")
      subtitle_results = books.where("lower(subtitle) LIKE (?)", "%#{filter_params[:search_term]}%")
      blurb_results = books.where("lower(blurb) LIKE (?)", "%#{filter_params[:search_term]}%")
      publisher_results = books.where("lower(publisher) LIKE (?)", "%#{filter_params[:search_term]}%")
      list_results = books.joins(:lists).where("lower(lists.title) LIKE (?)", "%#{filter_params[:search_term]}%")
      (title_results + author_results + subtitle_results + list_results + blurb_results + publisher_results).uniq
    end

    def related_books(books)
      authors = books.map{|book| book.author}
      lists = []
      books.each{|book| lists.append(*(book.lists))}
      author_recommendations = Book.where(author: [authors], has_been_read: 'No')
      list_recommendations = []
      lists.each do |list|
        list.books.where(has_been_read: 'No').each do |book|
          list_recommendations.append(book)
        end
      end
      return (author_recommendations + list_recommendations).uniq
    end

end
