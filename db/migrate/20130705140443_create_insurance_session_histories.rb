class CreateInsuranceSessionHistories < ActiveRecord::Migration
  def change
    create_table :insurance_session_histories do |t|
      t.references :insurance_session
      t.integer    :status
      t.datetime   :status_date
      
      t.string     :created_user, :null => false
      t.string     :updated_user
      t.boolean    :deleted,      :null => false, :default => false

      t.timestamps
    end
  end
end
