class CreatePlays < ActiveRecord::Migration[8.1]
  def change
    create_table :plays do |t|
      t.references :game, null: false, foreign_key: true
      t.references :location, null: true, foreign_key: true
      t.date :date
      t.text :notes

      t.timestamps
    end
  end
end
