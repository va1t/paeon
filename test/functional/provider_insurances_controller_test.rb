require 'test_helper'

class ProviderInsurancesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @provider = providers(:one)
    @group = groups(:one)
    @provider_group = provider_insurances(:one)
    @provider_provider = provider_insurances(:two)
    @type_group = 'group'
    @type_thera = 'provider'
  end

  test "should get index" do
    sign_in @admin    
    get :index, :group_id => @group, :id => @provider_group.id
    assert_response :success
    assert_not_nil assigns(:provider)   
    
    get :index, :provider_id => @provider, :id => @provider_provider.id
    assert_response :success
    assert_not_nil assigns(:provider)  
  end
  
  
  test "should get new provider_group" do
    sign_in @admin
    get :new, :group_id => @group
    assert_response :success

  end

  test "should get new provider_provider" do
    sign_in @admin
    get :new, :provider_id => @provider
    assert_response :success
  end


  test "should create provider_insurance" do
    sign_in @admin        
    assert_difference('ProviderInsurance.count') do
      post :create, :group_id => @group,                 
                    :provider_insurance => {:insurance_company_id => @provider_group.insurance_company_id, :provider_id => @provider_group.provider_id, 
                    :"expiration_date(1i)" => "2013", :"expiration_date(2i)" => "10", :"expiration_date(3i)" => "16",
                    :"notification_date(1i)" => "2013", :"notification_date(2i)" => "09", :"notification_date(3i)" => "16", 
                    :created_user => @provider_group.created_user }  
      if assigns(:provider).errors
        assigns(:provider).errors.each { |er|
          puts er.full_message }        
      end      
    end
    assert_redirected_to group_provider_insurance_path(:group_id => @group.id, :id => assigns(:provider) )
  end


  test "should show provider_group" do
    sign_in @admin
    get :show, :group_id => @group.id, :id => @provider_group.id
    assert_response :success
  end

  test "should show provider_provider" do
    sign_in @admin
    get :show, :provider_id => @provider.id, :id => @provider_provider.id
    assert_response :success
  end



  test "should get edit group" do
    sign_in @admin
    get :edit, :group_id => @group.id, id: @provider_group
    assert_response :success
  end
  
  test "should get edit provider" do
    sign_in @admin
    get :edit, :provider_id => @provider.id, id: @provider_provider
    assert_response :success
  end

  

  test "should update provider_group" do
    sign_in @admin
    put :update, :group_id => @group, id: @provider_group, id: @provider_group, type: @type_group,
                              provider: { created_user: @provider_group.created_user, expiration_date: @provider_group.expiration_date, 
                                          notification_date: @provider_group.notification_date, provider_id: @provider_group.provider_id, 
                                          updated_user: @provider_group.updated_user, insurance_company_id: @provider_group.insurance_company_id }
                                          
    assert_redirected_to group_provider_insurance_path(:group_id => @group.id, :id => @provider_group )
  end
  
  test "should update provider_provider" do
    sign_in @admin
    put :update, :provider_id => @provider, id: @provider_provider, id: @provider_provider, type: @type_thera,
                              provider: { created_user: @provider_provider.created_user, expiration_date: @provider_provider.expiration_date, 
                                          notification_date: @provider_provider.notification_date, provider_id: @provider_provider.provider_id, 
                                          updated_user: @provider_provider.updated_user, insurance_company_id: @provider_provider.insurance_company_id }
                                          
    assert_redirected_to provider_provider_insurance_path(:provider_id => @provider.id, :id => @provider_provider )
  end
    

  test "should destroy provider_group" do
    sign_in @admin
    
    assert_difference('ProviderInsurance.count', -1) do
      delete :destroy, :group_id => @group.id, id: @provider_group, id: @provider_group
    end

    assert_redirected_to group_provider_insurances_path(:group_id => @group.id)
  end


  test "should destroy provider_provider" do
    sign_in @admin
    
    assert_difference('ProviderInsurance.count', -1) do
      delete :destroy, :provider_id => @provider.id, id: @provider_provider
      #assert_nil assigns(:provider_insurance).errors
    end

    assert_redirected_to provider_provider_insurances_path(:provider_id => @provider.id)
  end

end
