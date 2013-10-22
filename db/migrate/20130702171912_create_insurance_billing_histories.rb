class CreateInsuranceBillingHistories < ActiveRecord::Migration
  def change
    create_table :insurance_billing_histories do |t|
      t.references :insurance_billing
      t.integer  :status                          # set with BillingFlow::status value
      t.datetime :status_date
      t.string   :edi_transaction, :limit => 10   # set with BillingFlow::edi_description
      t.integer  :edi_status                      # set with BillingFlow:edi_status
      
      t.string   :created_user, :null => false
      t.string   :updated_user
      t.boolean  :deleted,      :null => false, :default => false

      t.timestamps
    end
  end
end
