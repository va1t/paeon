require 'test_helper'

class OfficesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  # all tests are performed froma patient perspective with the polmorphic notes class
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @office = offices(:one)
    @provider = providers(:one)
  end


  test "should get index" do
    sign_in @admin
    get :index, provider_id: @provider
    assert_response :success
    assert_not_nil assigns(:offices)
  end

  test "should get new" do
    sign_in @admin
    get :new, provider_id: @provider
    assert_response :success
  end

  test "should create office" do
    sign_in @admin
    assert_difference('Office.count') do
      post :create, provider_id: @provider, 
           office: { address1: @office.address1, address2: @office.address2, city: @office.city, 
                     office_fax: @office.office_fax, office_phone: @office.office_phone, priority: @office.priority, second_phone: @office.second_phone, 
                     state: @office.state, third_phone: @office.third_phone, zip: @office.zip }
      if assigns(:office).errors.any?
        puts assigns(:office).errors.inspect 
      end
    end
    assert_redirected_to provider_offices_path(provider_id: @provider)
  end

  test "should show office" do
    sign_in @admin
    get :show, provider_id: @provider, id: @office
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, provider_id: @provider, id: @office
    assert_response :success
  end

  test "should update office" do
    sign_in @admin
    put :update, provider_id: @provider, id: @office, 
        office: { address1: @office.address1, address2: @office.address2, 
                  city: @office.city, office_fax: @office.office_fax, office_phone: @office.office_phone, priority: @office.priority, 
                  second_phone: @office.second_phone, state: @office.state, third_phone: @office.third_phone, zip: @office.zip }
    assert_redirected_to provider_offices_path(provider_id: @provider)
  end

  test "should destroy office" do
    sign_in @admin
    assert_difference('Office.count', -1) do
      delete :destroy, provider_id: @provider, id: @office
    end

    assert_redirected_to provider_offices_path(provider_id: @provider)
  end
end
