class CreatePlayExpansions < ActiveRecord::Migration[8.1]
  def change
    create_table :play_expansions do |t|
      t.references :play, null: false, foreign_key: true, index: false
      t.references :expansion, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :play_expansions, [ :play_id, :expansion_id ], unique: true
  end
end
