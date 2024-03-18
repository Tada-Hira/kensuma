class CreateWorkerLicenses < ActiveRecord::Migration[6.1]
  def change
    create_table :worker_licenses do |t|
      t.json :images # 技能検定の写し
      t.references :worker, foreign_key: true, null: false
      t.references :license, foreign_key: true, null: false

      t.timestamps
    end
    add_index :worker_licenses, [:worker_id, :license_id], unique: true
  end
end
