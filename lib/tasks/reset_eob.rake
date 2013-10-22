# rake task to clear out the eob and eob related tables
# reset the auto_increment to 1
# set all 835 records in the file receive table to unprocessed
 
namespace :reset do

  desc "WARNING - Clears out all eob related tables"
  task :eobs => :environment do

    # delete the eob & related tables
    puts "Deleteing the eob and related tables"
    Eob.delete_all
    EobDetail.delete_all
    EobClaimAdjustment.delete_all
    EobServiceAdjustment.delete_all
    EobServiceRemark.delete_all
    #also kill the 835 table
    OfficeAlly835.delete_all
    
    #reset auto_increment    
    sql = "alter table eobs auto_increment=1"
    ActiveRecord::Base.connection.execute(sql)
    sql = "alter table eob_details auto_increment=1"
    ActiveRecord::Base.connection.execute(sql)
    sql = "alter table eob_claim_adjustments auto_increment=1"
    ActiveRecord::Base.connection.execute(sql)
    sql = "alter table eob_service_adjustments auto_increment=1"
    ActiveRecord::Base.connection.execute(sql)
    sql = "alter table eob_service_remarks auto_increment=1"
    ActiveRecord::Base.connection.execute(sql)
    sql = "alter table office_ally835s auto_increment=1"
    ActiveRecord::Base.connection.execute(sql)
    puts "Auto increment reset to 1"
    
    #select all 835 and reset to unprocessed
    puts "Updating the file receive to reset 835 processeing"
    @records = OfficeAllyFileReceive.find_all_by_extension("835")
    @records.each do |rec|
      rec.update_attributes(:file_parsed => nil)
    end
    
    puts "Completed the Eob Reset"
  end
end
