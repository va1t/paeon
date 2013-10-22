# rake task to fill in the insurance billing database
# client_id, dos, provider_id, and group_provider_id
 
namespace :build do

  desc "Fill in new history tables for sessions, billing and balance bill"
  task :history => :environment do


    puts "Loading insurance sessions"
    @sessions = InsuranceSession.unscoped.all

    @sessions.each do |session|
      begin
        #fix the db status null fields - mona's db has crap in it with the deleted records
        session.update_attributes(:status => SessionFlow::PRIMARY) if session.status.blank?
        
        #get all the unscoped records for this session
        session_history = InsuranceSessionHistory.unscoped.find_by_insurance_session_id(session.id)   
        #there are no history records for session, so create
        if session_history.blank?
          # create initial record
          history = session.insurance_session_histories.new(:status => SessionFlow::OPEN, :status_date => session.created_at, :created_user => session.created_user, :deleted => session.deleted)
          history.save!
          # create current history record
          if session.status > SessionFlow::OPEN
            history = session.insurance_session_histories.new(:status => session.status, :status_date => session.updated_at, 
                      :created_user => (session.updated_user.blank? ? session.created_user : session.updated_user), :deleted => session.deleted)
            history.save!
          end          
        end
      rescue => e
        puts e.inspect
        puts "Error with Insurance Billing record: #{bill.id}"
      end
    end
    puts "Completed Filling in session history"
    
    
    puts "Loading Insurance Billing"
    @billing = InsuranceBilling.unscoped.all
    @billing.each do |bill|
      begin
        billing_history = InsuranceBillingHistory.unscoped.find_by_insurance_billing_id(bill.id)
        #no history for this billing record, so create
        if billing_history.blank?
          #create the initial record
          history = bill.insurance_billing_histories.new(:status => BillingFlow::INITIATE, :status_date => bill.created_at, :created_user => bill.created_user, :deleted => bill.deleted)
          history.save!
          #look to created the ready record
          if bill.status >= BillingFlow::READY
            history = bill.insurance_billing_histories.new(:status => BillingFlow::READY, :status_date => bill.updated_at, 
                      :created_user => (bill.updated_user.blank? ? bill.created_user : bill.updated_user), :deleted => bill.deleted)
            history.save!        
          end
          #look to create the additional record, if needed
          if bill.status > BillingFlow::READY
            history = bill.insurance_billing_histories.new(:status => bill.status, :status_date => bill.updated_at, 
                      :created_user => bill.updated_user.blank? ? bill.created_user : bill.updated_user, :deleted => bill.deleted)
            history.save!                    
          end
        end    
      rescue => e
        puts e.inspect
        puts "Error with Insurance Billing record: #{bill.id}"
      end  
    end  
    puts "Completed filling billing history"
    
    
    puts "Loading Balance Bill"
    @balances = BalanceBill.unscoped.all
    @balances.each do |balance|
      begin
        balance_history = BalanceBillHistory.unscoped.find_by_balance_bill_id(balance.id)
        # no history for this balance bill
        if balance_history.blank?
          history = balance.balance_bill_histories.new(:status => BalanceBillFlow::INITIATE, :status_date => balance.created_at, :created_user => balance.created_user, :deleted => balance.deleted)
          history.save!
          #look to created th ready record
          if balance.status >= BalanceBillFlow::READY
            history = balance.balance_bill_histories.new(:status => BalanceBillFlow::READY, :status_date => balance.updated_at, 
                      :created_user => balance.updated_user.blank? ? balance.created_user : balance.updated_user, :deleted => balance.deleted)
            history.save!            
          end
          #look to create the current record
          if balance.status > BalanceBillFlow::READY
            history = balance.balance_bill_histories.new(:status => balance.status, :status_date => balance.updated_at, 
                      :created_user => balance.updated_user.blank? ? balance.created_user : balance.updated_user, :deleted => balance.deleted)
            history.save!
          end
        end
      rescue => e
        puts e.inspect
        puts "Error with Balance Bill record: #{balance.id}"
      end
    end
    puts "Completed filling Balance Bill history"
    
  end
end