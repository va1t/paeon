require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
  end
  
  test "anonymous should get index" do
    get :index
    assert_redirected_to new_user_session_path    
  end
  
  test "should get index with read only user" do
    sign_in @everyone
    get :index
    assert_select "title", "Monalisa"
    assert_response :success
    assert_template "index"

    #defined in test_helper.rb
    loggedin_menu_displayed
  end

  test "should get index with user logout" do
    sign_out @everyone
    get :index
    assert_redirected_to new_user_session_path
  end
  
  #display list of claims in iniital state
  test "should show claims in initial_billing" do
    sign_in @admin
    get :initial_billing
    assert_response :success
    assert_template "initial_billing"    
  end
  
  #set session varaibles and redirect to insurnace billing index
  test "should set session and redirect" do    
    @session = insurance_sessions(:one)
    sign_in @admin    
    get :session_initial_state, id: @session.id    
    assert_redirected_to insurance_session_insurance_billings_path(insurance_session_id: @session.id)
  end
    
  test "show sessions with claims & BB closed link" do
    sign_in @admin
    get :index
    # get the current number of sessions without claims  
    @session = assigns(:session)
    @counter = @session[:closed_claims] + 1
    # set the ins billing record to close     
    @insurance_billing = insurance_billings(:five)
    @insurance_billing.update_attributes(:status => BillingFlow::CLOSED, :skip_callbacks => true)    
    # check to see if the number of open sessions without a claim increases        
    get :index    
    assert_response :success
    assert_template "index"
    # should increase by 1 from the counter
    @session = assigns(:session)
    assert_equal @counter, @session[:closed_claims]
    
    #set the balance bill record to close
#    @counter += 1
#    @balance = balance_bill_sessions(:five)
#    @balance.update_attributes(:status => BalanceBillFlow::CLOSED, :skip_callbacks => true)       
    #check to see if the number of open sessions without a bal bill increases
#    get :index    
#    assert_response :success
#    assert_template "index"
    # should increase by 1 from the counter
#    @session = assigns(:session)
#    assert_equal @counter, @session[:closed_claims]
#   @insurance_billing.update_attributes(:skip_callbacks => false)
#    @balance.update_attributes(:skip_callbacks => true)  
  end
  
  test "show sessions with no claims" do
    sign_in @admin
    get :index
    # get the current number of sessions without claims  
    @session = assigns(:session)
    @counter = @session[:no_claims] + 1
    # set the ins billing record to close     
    @insurance_billing = insurance_billings(:five)
    @insurance_billing.insurance_session_id = 1
    @insurance_billing.save!
    # check to see if the number of open sessions with no claim increases        
    get :index    
    assert_response :success
    assert_template "index"
    # should increase by 1 from the counter
    @session = assigns(:session)
    assert_equal @counter, @session[:no_claims]
    #set the balance bill record to another session
    @counter += 1
 #   @balance = balance_bill_sessions(:five)
 #   @balance.insurance_session_id = 1 
 #   @balance.save!
    #check to see if the number of open sessions with no balance bill increases
 #   get :index    
 #   assert_response :success
 #   assert_template "index"
    # should increase by 1 from the counter
 #   @session = assigns(:session)
 #   assert_equal @counter, @session[:no_claims]    
  end
  
  test "show session status" do
    sign_in @admin
    # ensure at least one record in that state to display page
    @session = insurance_sessions(:one)
    @session.status = SessionFlow::PRIMARY
    @session.save!
    get :session_status, status: SessionFlow::PRIMARY
    
    assert_response :success
    assert_template "session_status"
  end
  
  test "show bad session status" do
    sign_in @admin
    # ensure at least one record in that state to display page
    # set the ins billing record to close     
    @insurance_billing = insurance_billings(:five)
    @insurance_billing.insurance_session_id = 1
    @insurance_billing.save!
    get :bad_session, status: "200"
    
    assert_response :success
    assert_template "bad_session"    
  end
end
