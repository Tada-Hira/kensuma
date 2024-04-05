class AddForeignersEmploymentManagerDetailsToBusinesses < ActiveRecord::Migration[6.1]
  def change
    add_column :businesses, :foreigners_employment_manager_job_title, :string
    add_column :businesses, :foreigners_employment_manager_my_phone_number, :string
  end
end
