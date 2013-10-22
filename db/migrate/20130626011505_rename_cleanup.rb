class RenameCleanup < ActiveRecord::Migration
  def up
    rename_column :patients_groups, :client_account_number, :patient_account_number
    rename_column :patients_providers, :client_account_number, :patient_account_number
    
    rename_column :eobs, :client_first_name, :patient_first_name
    rename_column :eobs, :client_last_name, :patient_last_name
    
    rename_column :insurance_sessions, :client_copay, :patient_copay
    rename_column :insurance_sessions, :client_additional_payment, :patient_additional_payment
    
    rename_column :subscribers, :type_client, :type_patient
    rename_column :subscribers, :type_client_other_description, :type_patient_other_description 
    rename_column :subscribers, :same_address_client, :same_address_patient
    rename_column :subscribers, :same_as_client, :same_as_patient    
  end

  def down
    rename_column :patients_groups, :patient_account_number, :client_account_number
    rename_column :patients_providers, :patient_account_number, :client_account_number
    
    rename_column :eobs, :patient_first_name, :client_first_name
    rename_column :eobs, :patient_last_name, :client_last_name
    
    rename_column :insurance_sessions, :patient_copay, :client_copay
    rename_column :insurance_sessions, :patient_additional_payment, :client_additional_payment
    
    rename_column :subscribers, :type_patient, :type_client
    rename_column :subscribers, :type_patient_other_description, :type_client_other_description 
    rename_column :subscribers, :same_address_patient, :same_address_client
    rename_column :subscribers, :same_as_patient, :same_as_client    

  end
end
