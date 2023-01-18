class ListsController < ApplicationController
  STATUS_SORT_ORDER = ['Yes', 'In progress', 'No']

  def index
    @lists = List.all.order(is_default: :desc, title: :asc)
    recent_duration = cookies[:recent_duration].to_i || 1
    @recent_count = Book.where(date_finished_reading: recent_duration.month.ago..Date.today).length
    @current_count = Book.where(has_been_read: 'In progress').length
  end

  def show
    @list = List.find(params[:id])
    @books = sort_books(@list.books)
  end

  def new
    @list = List.new
    @books = Book.all.order(title: :asc)
  end

  def create
    @list = List.new(list_params)
    if @list.save
      redirect_to(lists_path)
    else
      render('new')
    end
  end

  def edit
    @list = List.find(params[:id])
    @books = Book.all.order(title: :asc)
  end

  def update
    @list = List.find(params[:id])
    if @list.update(list_params)
      redirect_to(list_path(@list))
    else
      render('edit')
    end
  end

  def delete
    @list = List.find(params[:id])
  end

  def destroy
    @list = List.find(params[:id])
    @list.destroy
    redirect_to(lists_path)
  end

  def current
    current_books = Book.where(has_been_read: 'In progress')
    @books = sort_books(current_books)
  end

  def recent
    recent_duration = cookies[:recent_duration].to_i || 1
    @recent_duration_string = recent_duration == 1 ? 'month' : "#{recent_duration} months"
    recent_books = Book.where(date_finished_reading: recent_duration.month.ago..Date.today)
    @books = sort_books(recent_books)
  end

  private
    def list_params
      params.require(:list).permit(:title, :description, book_ids: [])
    end

    def sort_books(books)
      if params[:sort].nil?
        return books.sort_by{|book| book[:title]}
      elsif params[:sort] == 'has_been_read'
        return books.sort_by{|book| STATUS_SORT_ORDER.find_index(book[params[:sort]])}
      elsif params[:sort] == 'author'
        return books.sort_by{|book| book.author.surname}
      else
        return books.sort_by{|book| book[params[:sort]] || 0}
      end
    end    
end
