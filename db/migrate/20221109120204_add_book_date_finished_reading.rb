class AddBookDateFinishedReading < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :date_finished_reading, :date
  end
end
