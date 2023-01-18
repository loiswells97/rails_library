class CreateSeriesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :series do |t|
      t.string :title 

      t.timestamps
    end
  end
end
