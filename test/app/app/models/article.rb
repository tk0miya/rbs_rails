class Article < ApplicationRecord
  belongs_to :blog
  has_many :comments

  # Rails5 style enum
  enum status: {
    draft: 1,
    published: 2
  }

  enum category: {
    news: 1,
    tech: 2
  }, _prefix: true
end
