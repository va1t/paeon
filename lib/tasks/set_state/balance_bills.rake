# set the state field for the state machine
# each model has a specific task defined within the namespace

namespace :set_state do

  desc "Set the state for balance_bill_session model"
  task :balance_bill_session => :environment do

    puts "Loading balance_bill_session"
    begin
      @bb_sessions = BalanceBillSession.unscoped.all
      @bb_sessions.each do |s|
        s.init_record
        if s.deleted
          s.delete_record
        end
        puts "id: #{s.id} updated state: #{s.status}"
      end
    rescue => e
      puts "updating balance bill sessions failed #{e.inspect}"
    end
  end


  desc "Set the state for balance_bills model"
  task :balance_bill => :environment do

    puts "Loading balance_bill"
    begin
      @bb = BalanceBill.unscoped.all
      @bb.each do |s|
        s.init_record
        s.init_balance_status
        if s.deleted
          s.delete_record
        end
        s.validate
        puts "id: #{s.id} updated state: #{s.status}"
      end
    rescue => e
      puts "updating balance bills failed #{e.inspect}"
    end
  end


  desc "Set the state for balance_bill_detail model"
  task :balance_bill_detail => :environment do

    puts "Loading balance_bill_detail"
    begin
      @bb = BalanceBillDetail.unscoped.all
      @bb.each do |s|
        s.init_record
        if s.deleted
          s.delete_record
        end
        puts "id: #{s.id} updated state: #{s.status}"
      end
    rescue => e
      puts "updating balance bill detail failed #{e.inspect}"
    end
  end


  desc "Set the state for balance_bill_payments model"
  task :balance_bill_payment => :environment do

    puts "Loading balance_bill_payment"
    begin
      @bb = BalanceBillPayment.unscoped.all
      @bb.each do |s|
        s.init_record
        if s.deleted
          s.delete_record
        end
        puts "id: #{s.id} updated state: #{s.status}"
      end
    rescue => e
      puts "updating balance bill payment failed #{e.inspect}"
    end
  end


end