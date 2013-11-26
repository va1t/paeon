# rake task resave each session record
# re-run the finance re-calc, validations and data error routines
 
namespace :resave do

  desc "Re-Save each session record to force finance re-calc, validations to run and data errors to update"
  task :sessions => :environment do

    puts "Inititiating session re-save"
    @insurance_sessions = InsuranceSession.all
    
    @insurance_sessions.each do |i|
      if i.save
        puts "#{i.id} updated"
      else
        puts "#{i.id} not updated; Charges: #{i.charges_for_service}, Ins Paid: #{i.ins_paid_amount}, Bal Paid: #{i.bal_bill_paid_amount}, Waived: #{i.waived_fee}, Owed: #{i.balance_owed}"        
        i.errors.messages.each{ |m| puts m}        
      end 
    end
    puts "Completed the Sessions re-save"
  end
end
