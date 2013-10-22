require 'test_helper'

class InsuranceCompaniesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
    
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @insurance_co = insurance_companies(:one)
    @ins_deleteable = insurance_companies(:three)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:insurance_cos)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should create insurance_co" do
    sign_in @admin
    assert_difference('InsuranceCompany.count') do
      post :create, insurance_company: { name: @insurance_co.name, address1: @insurance_co.address1, address2: @insurance_co.address2, 
                    city: @insurance_co.city, state: @insurance_co.state, zip: @insurance_co.zip, 
                    main_phone: @insurance_co.main_phone, alt_phone: @insurance_co.alt_phone,
                    fax_number: @insurance_co.fax_number, insurance_co_id: @insurance_co.insurance_co_id,          
                    submitter_id: @insurance_co.submitter_id, created_user: @admin.login_name }      
      if assigns(:insurance_co).errors.any?
        puts assigns(:insurance_co).errors.inspect
      end
    end
    assert_redirected_to insurance_company_path(assigns(:insurance_co))
  end

  test "should show insurance_co" do
    sign_in @admin
    get :show, id: @insurance_co
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @insurance_co
    assert_response :success
  end

  test "should update insurance_co" do
    sign_in @admin
    put :update, id: @insurance_co, insurance_company: { address1: @insurance_co.address1, address2: @insurance_co.address2, alt_phone: @insurance_co.alt_phone, city: @insurance_co.city, fax_number: @insurance_co.fax_number, insurance_co_id: @insurance_co.insurance_co_id, main_phone: @insurance_co.main_phone, name: @insurance_co.name, state: @insurance_co.state, submitter_id: @insurance_co.submitter_id, zip: @insurance_co.zip }
    assert_redirected_to insurance_company_path(assigns(:insurance_co))
  end

  # the first yaml test case has dependencies, it should no tbe allowed to be deleted
  test "should not destroy insurance_co" do
    sign_in @admin
    assert_difference('InsuranceCompany.count', 0) do
      delete :destroy, id: @insurance_co
    end
    assert_errors assigns(:insurance_co).errors[:base], "There are patient insured dependencies for Aetna. Deletion is not allowed"
    assert_redirected_to insurance_companies_path
  end

  test "should destroy insurance_co" do
    sign_in @admin
    assert_difference('InsuranceCompany.count', -1) do
      delete :destroy, id: @ins_deleteable
    end    
    assert_redirected_to insurance_companies_path
  end

end

