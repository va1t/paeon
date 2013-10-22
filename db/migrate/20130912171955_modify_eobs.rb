class ModifyEobs < ActiveRecord::Migration
  def up
    rename_column :eobs, :check_number, :check_number_old
    add_column :eobs, :check_number, :string, :limit => 100
    
    #move old check numbers to new string format
    @eobs = Eob.unscoped.all
    @eobs.each do |e|      
      e.update_attributes(:check_number => e.check_number_old) if !e.check_number_old.blank?
      puts "#{e.id}, original check: #{e.check_number_old}, new:#{e.check_number}"
    end
  end


  def down
    remove_column :eobs, :check_number
    rename_column :eobs, :check_number_old, :check_number
  end
end
