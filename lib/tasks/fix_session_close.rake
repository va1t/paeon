# sessions were not closing because of the closed for resubmission claims.
# the test to see if a claim could be closed was to stringent
# this rake takse pulls in all sessions.  If all claims are closed or closed for resubmission
# and their is a waived fee, then this task will set the balance owed to 0.0 and close the session
 
namespace :reset do

  desc "Checks all sessions, if waived fee and claims closed, then closes session"
  task :session_close => :environment do


    puts "Loading insurance sessions"
    @sessions = InsuranceSession.all

    @sessions.each do |session|
      begin
        @can_close = true
        
        session.insurance_billings.each do |claim|
          # if the cliam status is not closed then cannot close session
          @can_close = false if claim.status < BillingFlow::CLOSED
        end
        if !session.waived_fee.blank? && session.waived_fee > 0 && @can_close
          puts "Current Session State: #{session.id}, Waived Fee: #{session.waived_fee}, Status #{SessionFlow.status(session.status)}, Can close: #{@can_close}"
          session.update_attributes(:balance_owed => '0.0', :status => SessionFlow::CLOSED)
          puts " Updated State: #{session.id}, Waived Fee: #{session.waived_fee}, Status #{SessionFlow.status(session.status)}"
        end
    
      rescue => e
        puts e.inspect
        puts "Error with session #{session.id}"
      end
    end
    puts "Completed Closing Sessions"
    
    
  end
end