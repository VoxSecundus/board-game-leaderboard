class CreateBggCollectionImports < ActiveRecord::Migration[8.1]
  def change
    create_table :bgg_collection_imports do |t|
      t.string :username, null: false
      t.timestamps
    end
  end
end
