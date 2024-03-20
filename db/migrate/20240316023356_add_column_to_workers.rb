class AddColumnToWorkers < ActiveRecord::Migration[6.1]
  def change
    add_column :workers, :driver_licenses_cards, :json 
  end
end