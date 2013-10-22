require 'test_helper'

class IproceduresControllerTest < ActionController::TestCase
  include Devise::TestHelpers
    
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)  
    @patient = patients(:one)
    @iproc = iprocedures(:one)
    @rate = rates(:one)
  end


end
