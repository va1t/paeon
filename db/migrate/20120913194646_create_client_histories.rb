class CreateClientHistories < ActiveRecord::Migration
  def change
    create_table :client_histories do |t|
      t.references :client,                :null => false
      t.string     :description
      t.datetime   :start_illness
      t.datetime   :start_therapy
      t.datetime   :hospitalization_start
      t.datetime   :hospitalization_stop
      t.datetime   :disability_start
      t.datetime   :disability_stop
      t.datetime   :unable_to_work_start
      t.datetime   :unable_to_work_stop
      t.string     :accident_type,                         :limit => 50, :default => "Not an Accident"
      t.string     :accident_description
      t.string     :accident_state,                        :limit => 15
      t.string     :created_user,           :null => false
      t.string     :updated_user
      t.boolean    :deleted,                :null => false, :default => false
      t.timestamps
    end
    
    add_index :client_histories, :client_id
  end
end
