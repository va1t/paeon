# sessions were not closing because of the closed for resubmission claims.
# the test to see if a claim could be closed was to stringent
# this rake takse pulls in all sessions.  If all claims are closed or closed for resubmission
# and their is a waived fee, then this task will set the balance owed to 0.0 and close the session
 
namespace :reset do

  desc "Recalculate the EOB Paid Amount using detail records"
  task :eob_recalc => :environment do


    puts "Loading EOBs"
    @eobs = Eob.includes(:eob_details).all

    @eobs.each do |e|      
      begin
        if !e.manual          
          payment = 0; charge = 0; subscriber = 0; copay_amount = 0; coinsurance_amount = 0; deductible_amount = 0; 
          not_covered_amount = 0; other_carrier_amount = 0
          
          # sum up the detail records
          e.eob_details.each do |d|
            d.eob_service_adjustments.each do |s|              
              case s.claim_adjustment_group_code
                when "PI" #payment reduction due to difference in contract
                  not_covered_amount += s.monetary_amount1.to_f
                when "PR" #patient responsibility
                  case s.carc1
                    when "1"
                      deductible_amount += s.monetary_amount1.to_f
                    when "2"
                      coinsurance_amount += s.monetary_amount1.to_f
                    when "3"
                      copay_amount += s.monetary_amount1.to_f
                  end
                when "OA", "CO", "CR" 
                  other_carrier_amount += s.monetary_amount1.to_f
              end
            end
            subscriber = deductible_amount + coinsurance_amount + copay_amount
            charge     += d.charge_amount if d.charge_amount?
            payment    += d.payment_amount if d.payment_amount?
            # update the detailed break out from the service adjustment records
            puts "EOB Detail #{d.id} updating"
            d.update_attributes(:not_covered_amount => not_covered_amount, :deductible_amount => deductible_amount, :copay_amount => copay_amount, 
                                :coinsurance_amount => coinsurance_amount, :other_carrier_amount => other_carrier_amount)            
          end          
          puts "EOB #{e.id} updating, Old Charge: #{e.charge_amount}, New: #{charge}, Old Payment: #{e.payment_amount}, New: #{payment}, Old Sub: #{e.subscriber_amount}, New: #{subscriber}"
          e.update_attributes(:charge_amount => charge, :payment_amount => payment, :subscriber_amount => subscriber)
        end
      rescue => err        
        puts "Error with EOB: #{e.id},#{err.inspect}"
      end
    end
    puts "Completed Updating EOBs"
  end
end