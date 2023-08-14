class Comment < ApplicationRecord
  belongs_to :article

  enum :status, {
    new: 1,
    moderated: 2,
    rejected: 3
  }, prefix: true

  enum anonymous: 1, named: 2
end
