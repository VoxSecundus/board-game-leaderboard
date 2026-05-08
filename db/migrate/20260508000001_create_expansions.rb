class CreateExpansions < ActiveRecord::Migration[8.1]
  def change
    create_table :expansions do |t|
      t.references :game, null: false, foreign_key: true, index: false
      t.integer :bgg_id
      t.string :name, null: false
      t.boolean :bgg_sourced, null: false, default: false
      t.boolean :owned, null: false, default: true

      t.timestamps
    end

    add_index :expansions, :game_id
    add_index :expansions, [ :game_id, :bgg_id ], unique: true,
              where: "bgg_id IS NOT NULL", name: "index_expansions_on_game_id_and_bgg_id"
  end
end
