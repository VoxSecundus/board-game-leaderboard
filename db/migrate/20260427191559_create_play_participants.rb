class CreatePlayParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :play_participants do |t|
      t.references :play, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :score
      t.boolean :winner, null: false, default: false

      t.timestamps
    end
  end
end
