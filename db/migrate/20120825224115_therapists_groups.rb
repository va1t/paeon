class TherapistsGroups < ActiveRecord::Migration
  def change
    create_table :group_therapists_therapists do |t|
      t.references :group_therapist,  :null => false
      t.references :therapist,        :null => false            
      t.string :created_user
      t.string :updated_user
      t.boolean :deleted,             :null => false, :default => false
      
      t.timestamps
    end
    
    add_index :group_therapists_therapists, :therapist_id
    add_index :group_therapists_therapists, :group_therapist_id
  end
end
