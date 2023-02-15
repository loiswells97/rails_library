class Author < ApplicationRecord
  has_many :books

  def full_name
    first_name!='' ? "#{first_name} #{surname}" : surname
  end
end
