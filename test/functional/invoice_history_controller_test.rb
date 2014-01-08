require 'test_helper'

class InvoiceHistoryControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @admin =      users(:admin)
    @balance_bill = balance_bills(:one)
    @group = groups(:one)
    @provider = providers(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
  end

  test "should get group" do
    sign_in @admin
    get :group, id: @group
    assert_response :success
  end

  test "should get provider" do
    sign_in @admin
    get :provider, id: @provider
    assert_response :success
  end

end
