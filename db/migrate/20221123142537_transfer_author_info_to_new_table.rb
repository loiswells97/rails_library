class TransferAuthorInfoToNewTable < ActiveRecord::Migration[7.0]
  def up
    full_names = Book.distinct.pluck(:author)
    full_names.each do |n|
      Author.create(first_name: n.split(' ')[0..-2].join(' '), surname: n.split(' ').last)
    end
  end

  def down
    Author.delete_all
  end
end
