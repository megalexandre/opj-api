class CreateLedgers < ActiveRecord::Migration[8.1]
  def change
    create_table :ledgers, id: :uuid do |t|
      t.references :project, type: :uuid, null: true, foreign_key: true
      t.references :service, type: :uuid, null: true, foreign_key: true
      t.integer :amount_cents, null: false, default: 0
      t.string  :reason
      t.text    :description

      t.timestamps
    end
  end
end
