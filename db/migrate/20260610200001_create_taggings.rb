class CreateTaggings < ActiveRecord::Migration[8.1]
  def change
    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :taggable, null: false, polymorphic: true
      t.timestamps
    end
    add_index :taggings, [ :taggable_type, :taggable_id, :tag_id ], unique: true
  end
end
