class CreateArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :articles do |t|
      t.belongs_to :blog, null: false

      t.timestamps
    end
  end
end
