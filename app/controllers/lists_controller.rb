class ListsController < ApplicationController

  def index
    @lists = List.all
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

  private
    def list_params
      params.require(:list).permit(:title, :description, book_ids: [])
    end
    
end
