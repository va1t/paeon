# sessions were not closing because of the closed for resubmission claims.
# the test to see if a claim could be closed was to stringent
# this rake takse pulls in all sessions.  If all claims are closed or closed for resubmission
# and their is a waived fee, then this task will set the balance owed to 0.0 and close the session
 
namespace :reset do

  desc "Nullify the foreign_keys dependencies for rates, offices and invoices"
  task :foreign_keys => :environment do

    puts "Loading Rates"
    begin
      @rates = Rate.unscoped.all
      
      @rates.each do |r|
        r.destroy if r.deleted
      end
    rescue => e
      puts "updating rates failed #{e.inspect}"
    end

    
    puts "Loading Offices"
    begin
      @offices = Office.unscoped.all
      
      @offices.each do |o|
        o.destroy if o.deleted
      end
    rescue => e
      puts "updating offices failed #{e.inspect}"
    end


    puts "Loading invoices"
    begin
      @invoices = Invoice.unscoped.all

      @invoices.each do |i| 
        i.destroy if i.deleted           
      end
    rescue => e
      puts "updating invocies failed #{e.inspect}"
    end
    puts "Completed Updating Foreign Key Dependencies"
    
  end
end