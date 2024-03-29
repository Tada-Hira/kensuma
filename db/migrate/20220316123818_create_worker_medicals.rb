class CreateWorkerMedicals < ActiveRecord::Migration[6.1]
  def change
    create_table :worker_medicals do |t|
      t.references :worker, null: false, foreign_key: true
      t.integer :is_med_exam, null: false, default: 0         # 健康診断の受診有無 enum
      t.date :med_exam_on                                     # 健康診断日
      t.integer :max_blood_pressure                           # 最高血圧
      t.integer :min_blood_pressure                           # 最低血圧
      t.integer :is_special_med_exam, null: false, default: 1 # 特別健康診断の受診有無 enum
      t.date :special_med_exam_on                             # 特別健康診断日
      t.json :special_med_exam_list                           # 特別健康診断
      t.string :special_med_exam_others                       # 特別健康診断(その他)
      t.integer :health_condition, null: false, default: 0    # 最近の健康状態 enum
      
      t.timestamps
    end
  end
end
