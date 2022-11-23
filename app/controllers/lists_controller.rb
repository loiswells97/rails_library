class ListsController < ApplicationController

  def index
    @lists = List.all.order(is_default: :desc, title: :asc)
    @recent_count = Book.where(date_finished_reading: Date.today-30..Date.today).length
    @current_count = Book.where(has_been_read: 'In progress').length
  end

  def show
    @list = List.find(params[:id])
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
    @books = Book.where(has_been_read: 'In progress')
  end

  def recent
    @books = Book.where(date_finished_reading: Date.today-30..Date.today)
  end

  private
    def list_params
      params.require(:list).permit(:title, :description, book_ids: [])
    end
    
end
