# sessions were not closing because of the closed for resubmission claims.
# the test to see if a claim could be closed was to stringent
# this rake takse pulls in all sessions.  If all claims are closed or closed for resubmission
# and their is a waived fee, then this task will set the balance owed to 0.0 and close the session
 
namespace :report do

  desc "Quick and Dirty EOB report"
  task :eob => :environment do

    require 'csv'    
    csv_file_path = "#{Rails.root}/tmp/eob.csv"
    
    puts "Loading EOBs"    
    @eobs = Eob.includes(:provider).find(:all, :conditions => ["eob_date >= '2013-07-01 00:00:00' and insurance_billing_id"], :order => "providers.last_name")
    
    begin
      CSV.open(csv_file_path, 'wb') do |csv|
        csv << ["Provider Last Name", "Provider First Name", "Patient First Name", "Patient Last Name", "DOS", "Paid", "Check Date", "Check Number", "Deductible", "Coinsurance", "Copay", "Reason"]
        @eobs.each do |e|
          puts e.id
          str = ""       
          deductible = 0; coinsurance = 0; copay = 0
          e.eob_details.each do |d|
            d.eob_service_adjustments.each do |a|
              carc = CodesCarc.find_by_code(a.carc1)
              str +=  carc.description + "; "
            end
            deductible += d.deductible_amount if d.deductible_amount
            coinsurance += d.coinsurance_amount if d.coinsurance_amount
            copay += d.copay_amount if d.copay_amount
          end
          check_date = e.check_date.blank? ? "" : e.check_date.strftime("%m/%d/%Y") 
          reason = e.payment_amount == 0.0 ? str : ""
          csv << [ e.provider.last_name, e.provider.first_name, e.patient_first_name, e.patient_last_name, e.dos.strftime("%m/%d/%Y"), 
                   ("$ " + sprintf("%.2f",e.payment_amount)), check_date, e.check_number,
                   ("$ " + sprintf("%.2f",deductible)),
                   ("$ " + sprintf("%.2f",coinsurance)), 
                   ("$ " + sprintf("%.2f",copay)), reason]
        end
      end
    rescue => e
      puts "Exception #{e.inspect}"
    end
    puts "Completed EOB CSV"
    
  end
end