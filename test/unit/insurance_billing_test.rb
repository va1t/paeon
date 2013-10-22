require 'test_helper'

class InsuranceBillingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @insurance_billing = insurance_billings(:one)
  end
  
  test "test named scope initial" do
    @insurance_billing.status = BillingFlow::CLOSED
    @insurance_billing.save!
    assert_difference('InsuranceBilling.initial.count') do
      @insurance_billing.update_attributes(:status => BillingFlow::INITIATE, :skip_callbacks => true)
    end    
  end

  
  test "test named scope pending" do
    @insurance_billing.status = BillingFlow::CLOSED
    @insurance_billing.save!
    assert_difference('InsuranceBilling.pending.count') do
      @insurance_billing.update_attributes(:status => BillingFlow::READY, :skip_callbacks => true)      
    end        
  end


  test "test named scope processed" do
    @insurance_billing.update_attributes(:status => BillingFlow::CLOSED, :skip_callbacks => true)      
    assert_no_difference('InsuranceBilling.processed.count') do
      @insurance_billing.update_attributes(:status => BillingFlow::READY, :skip_callbacks => true)      
    end        
    assert_no_difference('InsuranceBilling.processed.count') do
      @insurance_billing.update_attributes(:status => BillingFlow::PAID, :skip_callbacks => true)      
    end        
    assert_difference('InsuranceBilling.processed.count') do
      @insurance_billing.update_attributes(:status => BillingFlow::SUBMITTED, :skip_callbacks => true)      
    end
    @insurance_billing.update_attributes(:status => BillingFlow::CLOSED, :skip_callbacks => true)      
    assert_difference('InsuranceBilling.processed.count') do
      @insurance_billing.update_attributes(:status => BillingFlow::PRINTED, :skip_callbacks => true)      
    end
    @insurance_billing.update_attributes(:status => BillingFlow::CLOSED, :skip_callbacks => true)      
    assert_difference('InsuranceBilling.processed.count') do
      @insurance_billing.update_attributes(:status => BillingFlow::ACKNOWLEDGED, :skip_callbacks => true)      
    end
    @insurance_billing.update_attributes(:status => BillingFlow::CLOSED, :skip_callbacks => true)
    assert_difference('InsuranceBilling.processed.count') do
      @insurance_billing.update_attributes(:status => BillingFlow::ERRORS, :skip_callbacks => true)
    end
  end


  test "test named scope aged_processed" do
    @date = DateTime.now - 10.days
    #set the claim submitted date to 1 day before we're testing
    @insurance_billing.claim_submitted = @date - 1.day
    @insurance_billing.update_attributes(:status => BillingFlow::CLOSED, :skip_callbacks => true)
    assert_no_difference('InsuranceBilling.aged_processed(@date).count') do
      @insurance_billing.update_attributes(:status => BillingFlow::READY, :skip_callbacks => true)
    end        
    assert_no_difference('InsuranceBilling.aged_processed(@date).count') do
      @insurance_billing.update_attributes(:status => BillingFlow::PAID, :skip_callbacks => true)
    end        
    assert_difference('InsuranceBilling.aged_processed(@date).count') do
      @insurance_billing.update_attributes(:status => BillingFlow::SUBMITTED, :skip_callbacks => true)
      @insurance_billing.errors.full_messages.each {|msg| puts msg } if @insurance_billing.errors.any?
    end
    @insurance_billing.update_attributes(:status => BillingFlow::CLOSED, :skip_callbacks => true)
    assert_difference('InsuranceBilling.aged_processed(@date).count') do
      @insurance_billing.update_attributes(:status => BillingFlow::PRINTED, :skip_callbacks => true)
    end
    @insurance_billing.update_attributes(:status => BillingFlow::CLOSED, :skip_callbacks => true)
    assert_difference('InsuranceBilling.aged_processed(@date).count') do
      @insurance_billing.update_attributes(:status => BillingFlow::ACKNOWLEDGED, :skip_callbacks => true)
    end
  end


  test "test named scope edi" do
    @insurance_billing.update_attributes(:status => BillingFlow::CLOSED, :skip_callbacks => true)
    assert_difference('InsuranceBilling.edi.count') do
      @insurance_billing.update_attributes(:status => BillingFlow::SUBMITTED, :skip_callbacks => true)
    end   
  end


  test "test named scope printed" do
    @insurance_billing.update_attributes(:status => BillingFlow::CLOSED, :skip_callbacks => true)
    assert_difference('InsuranceBilling.printed.count') do
      @insurance_billing.update_attributes(:status => BillingFlow::PRINTED, :skip_callbacks => true)
    end    
  end


  test "test named scope ack" do
    @insurance_billing.update_attributes(:status => BillingFlow::CLOSED, :skip_callbacks => true)
    assert_difference('InsuranceBilling.ack.count') do
      @insurance_billing.update_attributes(:status => BillingFlow::ACKNOWLEDGED, :skip_callbacks => true)
    end    
  end


  test "test named scope pending_eob" do
    @insurance_billing.skip_callbacks = true
    @insurance_billing.status = BillingFlow::CLOSED
    @insurance_billing.save!
    assert_no_difference('InsuranceBilling.pending_eob.count') do
      @insurance_billing.status = BillingFlow::READY
      @insurance_billing.save!
    end        
    assert_no_difference('InsuranceBilling.pending_eob.count') do
      @insurance_billing.status = BillingFlow::PAID
      @insurance_billing.save!
    end        
    assert_difference('InsuranceBilling.pending_eob.count') do
      @insurance_billing.status = BillingFlow::SUBMITTED
      @insurance_billing.save!
    end
    @insurance_billing.status = BillingFlow::CLOSED
    @insurance_billing.save!
    assert_difference('InsuranceBilling.pending_eob.count') do
      @insurance_billing.status = BillingFlow::PRINTED
      @insurance_billing.save!
    end
    @insurance_billing.status = BillingFlow::CLOSED
    @insurance_billing.save!
    assert_difference('InsuranceBilling.pending_eob.count') do
      @insurance_billing.status = BillingFlow::ACKNOWLEDGED
      @insurance_billing.save!
    end
  end


  test "test named scope errors" do
    @insurance_billing.skip_callbacks = true
    @insurance_billing.status = BillingFlow::CLOSED
    @insurance_billing.save!
    assert_difference('InsuranceBilling.errors.count') do
      @insurance_billing.status = BillingFlow::ERRORS
      @insurance_billing.save!
    end    
  end


  test "test named scope paid" do
    @insurance_billing.skip_callbacks = true
    @insurance_billing.status = BillingFlow::CLOSED
    @insurance_billing.save!
    assert_difference('InsuranceBilling.paid.count') do
      @insurance_billing.status = BillingFlow::PAID
      @insurance_billing.save!
    end    
  end


  test "test named scope completed" do
    @insurance_billing.skip_callbacks = true
    @insurance_billing.status = BillingFlow::INITIATE
    @insurance_billing.save!
    assert_difference('InsuranceBilling.completed.count') do
      @insurance_billing.status = BillingFlow::CLOSED
      @insurance_billing.save!
    end    
  end

  test "verify insurance billing record is deleteable" do
    
    @insurance_billing.update_attributes(:status => BillingFlow::READY, :skip_callbacks => true)
    assert @insurance_billing.verify_record_deletable
    @insurance_billing.update_attributes(:status => BillingFlow::INITIATE, :skip_callbacks => true)
    assert @insurance_billing.verify_record_deletable
    @insurance_billing.update_attributes(:status => BillingFlow::SUBMITTED, :skip_callbacks => true)
    assert !@insurance_billing.verify_record_deletable
    @insurance_billing.update_attributes(:status => BillingFlow::CLOSED, :skip_callbacks => true)
    assert !@insurance_billing.verify_record_deletable      
  end
  
end
