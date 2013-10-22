class CreateEobServiceRemarks < ActiveRecord::Migration
  def change
    create_table :eob_service_remarks do |t|
      t.references :eob_detail
      t.string     :code_list_qualifier, :limit => 5
      t.string     :remark_code,         :limit => 30

      t.string  :created_user, :null => false
      t.string  :updated_user
      t.boolean :deleted,      :null => false, :default => false

      t.timestamps
    end
  end
end
