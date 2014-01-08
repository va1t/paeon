require 'test_helper'

class AccidentTypesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @accident_type = accident_types(:one)
  end


  test "style sheets" do
    sign_in @admin
    get :index

    assert_select 'link[href^=?]', '/assets/application.css'
    assert_select 'script[src^=?]', '/assets/accident_types.js'
    assert_select 'script[src^=?]', '/assets/application.js'
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:accident_types)
  end


  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end


  test "should create accident_type" do
    sign_in @admin
    assert_difference('AccidentType.count') do
      post :create, accident_type: { name: @accident_type.name }
    end

    assert_redirected_to accident_types_path
  end


  test "should get edit" do
    sign_in @admin
    get :edit, id: @accident_type
    assert_response :success
  end


  test "should update accident_type" do
    sign_in @admin
    put :update, id: @accident_type, accident_type: { name: @accident_type.name }
    assert_redirected_to accident_types_path
  end


  test "should destroy accident_type" do
    sign_in @admin
    assert_difference('AccidentType.without_status(:deleted).count', -1) do
      delete :destroy, id: @accident_type
    end

    assert_redirected_to accident_types_path
  end
end
