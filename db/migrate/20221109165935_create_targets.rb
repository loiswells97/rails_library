class CreateTargets < ActiveRecord::Migration[7.0]
  def change
    create_table :targets do |t|
      t.string :type
      t.integer :target
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
