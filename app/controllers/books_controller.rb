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
    recent_duration = cookies[:recent_duration].to_i || 1
    recent_books = Book.where(date_finished_reading: recent_duration.month.ago..Date.today)
    current_books = Book.where(has_been_read: 'In progress')
    @recent_recommendations = weighted_sample(related_books(recent_books+current_books, read_status='No'), 5)
    favourite_books = List.find_by(title: 'Favourites 🌟').books
    @favourite_recommendations = weighted_sample(related_books(favourite_books, read_status='No'), 5)
    @rouge_recommendations = rogue_suggestions.sample(5)
    @reread_recommendations = weighted_sample(rereads(recent_books+current_books), 5)

  end

  private
    def book_params
      params.require(:book).permit(
        :title,
        :subtitle,
        :publisher,
        :publication_date,
        :trim,
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

    def related_books(books, read_status=['Yes', 'In progress', 'No'])
      authors = books.map{|book| book.author}
      lists = []
      books.each{|book| lists.append(*(book.lists))}
      author_recommendations = Book.where(author: [authors], has_been_read: read_status)
      list_recommendations = []
      lists.each do |list|
        list.books.where(has_been_read: read_status).each do |book|
          list_recommendations.append(book)
        end
      end
      return (author_recommendations + list_recommendations)
    end

    def rogue_suggestions
      read_or_in_progress_books = Book.where(has_been_read: ['Yes', 'In progress'])
      if cookies[:rogue_wait].to_i > 0
        rogue_wait = cookies[:rogue_wait].to_i
        books_read_within_timeframe = read_or_in_progress_books.filter{|book| !book.date_finished_reading || book.date_finished_reading > rogue_wait.year.ago}
        non_rogue_books = related_books(books_read_within_timeframe) + read_or_in_progress_books
      else
        non_rogue_books = related_books(read_or_in_progress_books)
      end
      return Book.all - non_rogue_books
    end

    def rereads(books)
      rereads = related_books(books, read_status='Yes')
      reread_wait = cookies[:reread_wait].to_i || 1
      return rereads.filter{|book| book.date_finished_reading && book.date_finished_reading < reread_wait.year.ago}
    end

    def weighted_sample(array, n)
      array.each{|book| puts(book.title)}
      result = []
      while result.length < [array.uniq.length, n].min
        random_sample = array.sample()
        result.append random_sample unless result.include?(random_sample)
      end
      result.sort_by{|element| array.count(element)}.reverse
    end

end
