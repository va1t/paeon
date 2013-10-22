require 'test_helper'

class CodesPosControllerTest < ActionController::TestCase
  include Devise::TestHelpers
    
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)   
    @codes_po = codes_pos(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:codes_pos)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should create codes_po" do
    sign_in @admin
    assert_difference('CodesPos.count') do
      post :create, codes_po: { code: @codes_po.code, description: @codes_po.description }
    end

    assert_redirected_to codes_pos_path(assigns(:codes_po))
  end

  test "should show codes_po" do
    sign_in @admin
    get :show, id: @codes_po
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @codes_po
    assert_response :success
  end

  test "should update codes_po" do
    sign_in @admin
    put :update, id: @codes_po, codes_po: { code: @codes_po.code, description: @codes_po.description }
    assert_redirected_to codes_pos_path(assigns(:codes_po))
  end

  test "should destroy codes_po" do
    sign_in @admin
    assert_difference('CodesPos.count', -1) do
      delete :destroy, id: @codes_po
    end

    assert_redirected_to codes_pos_index_path
  end
end
