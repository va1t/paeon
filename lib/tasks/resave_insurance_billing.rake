# rake task resave each subscriber record
# re-run the validations and data error routines
 
namespace :resave do

  desc "Re-Save each insurance billing record to force validations to run and data errors to update"
  task :insurance_billing => :environment do

    puts "Inititiating insurance billing re-save"
    @insurance_billings = InsuranceBilling.all
    
    @insurance_billings.each do |i|
      if i.save
        puts "#{i.id} updated"
      else
        puts "#{i.id} not updated ****"
      end 
    end
    puts "Completed the Insurance Billing re-save"
  end
end
