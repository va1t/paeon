class ModManagedCare < ActiveRecord::Migration
  def up
    add_column :managed_cares, :active, :boolean, :default => true
    add_column :insurance_billings, :managed_care_id, :integer
    
    @sessions = InsuranceSession.unscoped.all
    @sessions.each do |session|
      puts "Session: #{session.id}"
      session.insurance_billings.each do |billing|
        billing.update_attributes(:managed_care_id => session.managed_care_id)
        puts "   Saved Billing Record: #{billing.id}"
      end
    end
    
    #remove_column :insurance_sessions, :managed_care_id
  end

  def down
    #add_column :insurance_sessions, :managed_care_id, :integer

    #InsuranceSession.each do |session|
    # session.update_attributes(:managed_care_id => session.insurance_billings.first.managed_care_id)
    #end

   remove_column :insurance_billings, :managed_care_id
   remove_column :managed_cares, :active
  end
end
