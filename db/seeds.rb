# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# seed the user database
puts "seeding User and Roles table"
if User.count == 0 
  admin_user = User.create!(:email => 'admin@comcast.net', :login_name => 'admin', :first_name => 'Super', :last_name => 'User', 
                            :home_phone => '732 933-0484', :cell_phone => '732 245-8444', :password => '123456', :password_confirmation => '123456',
                            :created_user => 'admin', :perm => true, :ability_superadmin => true )
                            
  invoice_user = User.create!(:email => 'manage@comcast.net', :login_name => 'manage', :first_name => 'Manage', :last_name => 'User', 
                            :home_phone => '732 933-0484', :cell_phone => '732 245-8444', :password => '123456', :password_confirmation => '123456',
                            :created_user => admin_user.login_name, :ability_invoice => true )
                            
  general_user = User.create!(:email => 'read@comcast.net', :login_name => 'read', :first_name => 'Reado', :last_name => 'User', 
                            :home_phone => '732 933-0484', :cell_phone => '732 245-8444', :password => '123456', :password_confirmation => '123456',
                            :created_user => admin_user.login_name )
  puts "User and Roles table seeded"
else
  puts "User and Roles already seeded"
  admin_user = User.find_by_login_name('admin')
end


# Supporting tables in the database
#insured_types
puts "seeding Insured Type"
if InsuredType.count == 0  
  InsuredType.create!(:name => "Self", :perm => true, :created_user => admin_user.login_name)
  InsuredType.create!(:name => "Spouse", :perm => true, :created_user => admin_user.login_name)
  InsuredType.create!(:name => "Child", :perm => true, :created_user => admin_user.login_name)
  InsuredType.create!(:name => "Other", :perm => false, :created_user => admin_user.login_name)
  puts "Insured Type seeded"
else
  puts "Insured Types already seeded"
end

#insurance types
puts "seeding Insurance Type"
if InsuranceType.count == 0 
  InsuranceType.create!(:name => "Group",    :perm => true, :created_user => admin_user.login_name)
  InsuranceType.create!(:name => "Medicare", :perm => true, :created_user => admin_user.login_name)
  InsuranceType.create!(:name => "Medicaid", :perm => true, :created_user => admin_user.login_name)
  InsuranceType.create!(:name => "VA Group", :perm => true, :created_user => admin_user.login_name)
  InsuranceType.create!(:name => "Other",    :perm => false, :created_user => admin_user.login_name)
  puts "Insurance Type seeded"
else
  puts "Insurance Type already seeded"
end

#accident types
puts "seeding Accident Type"
if AccidentType.count == 0
  AccidentType.create!(:name => "Auto", :perm => true, :created_user => admin_user.login_name)
  AccidentType.create!(:name => "Employment", :perm => true, :created_user => admin_user.login_name)
  AccidentType.create!(:name => "Not an Accident", :perm => true, :created_user => admin_user.login_name)
  AccidentType.create!(:name => "Other", :perm => true, :created_user => admin_user.login_name)
  puts "Accident Type seeded"
else
  puts "Accident Type already seeded"
end

#Referred to/from types
puts "seeding Referred Type"
if ReferredType.count == 0 
  ReferredType.create(:referred_type => "Physician", :perm => true, :created_user => admin_user.login_name)
  ReferredType.create(:referred_type => "Hospital", :perm => true, :created_user => admin_user.login_name)
  ReferredType.create(:referred_type => "Provider", :perm => true, :created_user => admin_user.login_name)
  ReferredType.create(:referred_type => "Patient", :perm => false, :created_user => admin_user.login_name)
  ReferredType.create(:referred_type => "Walk-In", :perm => false, :created_user => admin_user.login_name)
  puts "Referred Type seeded"
else
  puts "Referred Type already seeded"
end

#Office Types
puts "seeding Office Type"
if OfficeType.count == 0
  OfficeType.create(:name => "Main Office", :perm => true, :created_user => admin_user.login_name)
  OfficeType.create(:name => "Primary Office", :perm => true, :created_user => admin_user.login_name)
  OfficeType.create(:name => "Branch Office", :perm => true, :created_user => admin_user.login_name)
  OfficeType.create(:name => "Secondary Office", :perm => true, :created_user => admin_user.login_name)
  puts "Office Type seeded"
else
  puts "Office Type already seeded"
end

#EDI Vendors, each vendor has an engine for send/receiving
#edi vendors have to be seeded as they are added 
puts "seeding EDI Vendor"
if EdiVendor.count == 0
  EdiVendor.create(:primary => false, :name => "OfficeAlly", :trans835 => true, :trans837p => true, :trans837i => false, :trans837d => false, :trans997 => false, :trans999 => true,
                   :ftp_address => "ftp.officeally.com", :ftp_port => 22, :ssh_sftp_enabled => true, :passive_mode_enabled => true, 
                   :folder_send_to => "/inbound", :folder_receive_from => "/outbound", :testing => true, :created_user => admin_user.login_name, )
  puts "EDI Vendor seeded"
else
  puts "EDI Vendor already seeded"
end
