class AddWorkExperienceToRequestOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :request_orders, :lead_engineer_work_experience, :integer
  end
end