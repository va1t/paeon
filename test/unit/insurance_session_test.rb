require 'test_helper'

class InsuranceSessionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @session1 = insurance_sessions(:one)
    @session2 = insurance_sessions(:two)
    @session3 = insurance_sessions(:three)
    @session5 = insurance_sessions(:five)
    @session6 = insurance_sessions(:six)
  end
  
  test "test named scope primary" do
    # make sure test case is not in the testing state
    @session1.status = SessionFlow::OPEN
    @session1.save

    assert_difference('InsuranceSession.primary.count') do
      @session1.status = SessionFlow::PRIMARY
      @session1.save      
    end    
  end

  test "test named scope secondary" do
    # make sure test case is not in the testing state
    @session1.status = SessionFlow::OPEN
    @session1.save

    assert_difference('InsuranceSession.secondary.count') do
      @session1.status = SessionFlow::SECONDARY
      @session1.save      
    end    
  end

  test "test named scope tertiary" do
    # make sure test case is not in the testing state
    @session1.status = SessionFlow::OPEN
    @session1.save

    assert_difference('InsuranceSession.tertiary.count') do
      @session1.status = SessionFlow::TERTIARY
      @session1.save      
    end    
  end

  test "test named scope other" do
    # make sure test case is not in the testing state
    @session1.status = SessionFlow::OPEN
    @session1.save

    assert_difference('InsuranceSession.other.count') do
      @session1.status = SessionFlow::OTHER
      @session1.save      
    end    
  end


  test "test named scope balance bill" do
    # make sure test case is not in the testing state
    @session1.status = SessionFlow::OPEN
    @session1.save
    assert_difference('InsuranceSession.balancebill.count') do
      @session1.status = SessionFlow::BALANCE
      @session1.save      
    end    
  end


  test "test named scope closed" do
    # make sure test case is not in the testing state
    # use the fixture session that is deletable
    @session3.status = SessionFlow::OPEN    
    @session3.save
    if @session3.errors.any?
      @session3.errors.full_messages.each {|msg| puts msg }
    end

    assert_difference('InsuranceSession.closed.count') do
      @session3.status = SessionFlow::CLOSED
      @session3.balance_owed = 0
      @session3.save      
      if @session3.errors.any?
        @session3.errors.full_messages.each {|msg| puts msg }
      end
    end 
  end

  
  test "test named scope no_claims" do
    # testing no claims and no balance bills 
    @insurance_billing = insurance_billings(:five)
    @balance_bill = balance_bill_sessions(:five)
    assert_difference('InsuranceSession.no_claims.count') do
      @insurance_billing.insurance_session_id = 1
      @insurance_billing.save!
    end
  end


  test "test named scope closed_claims" do
    @insurance_billing = insurance_billings(:five)    
    assert_difference('InsuranceSession.closed_claims.count') do
      @insurance_billing.status = BillingFlow::CLOSED
      @insurance_billing.save!
    end    
  end

  test "test verify session state method" do
    #test the insurance_billing half of the method    
    assert !@session5.verify_session_state
    @session5.insurance_billings.each { |billing| 
        billing.status = BillingFlow::CLOSED
        billing.skip_callbacks = true }
    @session5.skip_callbacks = true
    @session5.save!
    assert @session5.verify_session_state
    
    #test the balance billing half of the method    
    assert !@session6.verify_session_state
    @session6.balance_bill_session.balance_bill.status = BalanceBillFlow::CLOSED     
    @session6.save!
    assert @session6.verify_session_state
    
  end

  test "validate session closeable" do
    #set the test case to a default state to test each clause
    @session1.insurance_billings.each {|bill| bill.status = BillingFlow::CLOSED }
    @session1.save!
    
    #test balance owed   
    assert !@session1.update_attributes(:balance_owed => 100, :status => SessionFlow::CLOSED)        
    assert !@session1.validate_record_closeable
    #@session1.errors.full_messages.each { |msg| puts msg } if @session1.errors.any?
    
    assert @session1.update_attributes(:balance_owed => 0, :status => SessionFlow::CLOSED)
    assert @session1.validate_record_closeable
    assert @session1.update_attributes(:balance_owed => 0)  #set balance owed to 0 to take it out of the test
    #test closed billings
    @session1.insurance_billings.each {|bill| bill.status = BillingFlow::READY }
    @session1.status = SessionFlow::PRIMARY  # reset the session to an open state
    assert @session1.save!
    @session1.status = SessionFlow::CLOSED
    assert !@session1.validate_record_closeable
    
    #reset
    @session1.insurance_billings.each {|bill| bill.status = BillingFlow::CLOSED }
    assert @session1.save!
    #verify can close
    assert @session1.validate_record_closeable
    
  end
  
  test "verify session is deletable" do
    @billings = @session1.insurance_billings.all
    @billings.each {|billing| billing.update_attributes(:status => BillingFlow::SUBMITTED) }
    assert !@session1.verify_record_deleteable     
    @billings.each {|billing| billing.update_attributes(:status => BillingFlow::READY) }
    assert @session1.verify_record_deleteable
    
  end
  
end
