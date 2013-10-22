require 'test_helper'

class EdiVendorsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
    
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)   
    @edi_vendor = edi_vendors(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:edi_vendors)
  end


  test "should show edi_vendor" do
    sign_in @admin
    get :show, id: @edi_vendor
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @edi_vendor
    assert_response :success
  end

  test "should update edi_vendor" do
    sign_in @admin
    put :update, id: @edi_vendor, 
        edi_vendor: { folder_receive_from: @edi_vendor.folder_receive_from, folder_send_to: @edi_vendor.folder_send_to, ftp_address: @edi_vendor.ftp_address, 
                      ftp_port: @edi_vendor.ftp_port, name: @edi_vendor.name, passive_mode_enabled: @edi_vendor.passive_mode_enabled, password: @edi_vendor.password, 
                      ssh_sftp_enabled: @edi_vendor.ssh_sftp_enabled, trans835: @edi_vendor.trans835, trans837d: @edi_vendor.trans837d, trans837i: @edi_vendor.trans837i, 
                      trans837p: @edi_vendor.trans837p, trans997: @edi_vendor.trans997, trans999: @edi_vendor.trans999, username: @edi_vendor.username }
    if assigns(:edi_vendor).errors.any?
      puts assigns(:edi_vendor).errors.inspect
    end                      
    assert_redirected_to edi_vendor_path(assigns(:edi_vendor))
  end

end
