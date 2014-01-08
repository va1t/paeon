# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140108014651) do

  create_table "accident_types", :force => true do |t|
    t.string   "name",         :limit => 50,                    :null => false
    t.boolean  "perm",                       :default => false
    t.string   "created_user",                                  :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                    :default => false, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "status",       :limit => 25
  end

  create_table "balance_bill_detail_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "balance_bill_detail_versions", ["item_type", "item_id"], :name => "index_balance_bill_detail_versions_on_item_type_and_item_id"

  create_table "balance_bill_details", :force => true do |t|
    t.integer  "balance_bill_session_id",                                              :null => false
    t.string   "description"
    t.decimal  "amount",                                :precision => 15, :scale => 2
    t.string   "detail_status",           :limit => 25
    t.integer  "quantity"
    t.string   "created_user",                                                         :null => false
    t.string   "updated_user"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.string   "status",                  :limit => 25
  end

  add_index "balance_bill_details", ["balance_bill_session_id"], :name => "index_balance_bill_details_on_balance_bill_id"

  create_table "balance_bill_payment_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "balance_bill_payment_versions", ["item_type", "item_id"], :name => "index_balance_bill_payment_versions_on_item_type_and_item_id"

  create_table "balance_bill_payments", :force => true do |t|
    t.integer  "balance_bill_id"
    t.decimal  "balance_amount",                :precision => 15, :scale => 2
    t.decimal  "payment_amount",                :precision => 15, :scale => 2
    t.string   "created_user",                                                 :null => false
    t.string   "updated_user"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.string   "status",          :limit => 25
    t.datetime "payment_date"
    t.string   "check_number",    :limit => 25
    t.string   "payment_method",  :limit => 10
  end

  add_index "balance_bill_payments", ["balance_bill_id"], :name => "index_balance_bill_payments_on_balance_bill_id"

  create_table "balance_bill_session_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "balance_bill_session_versions", ["item_type", "item_id"], :name => "index_balance_bill_session_versions_on_item_type_and_item_id"

  create_table "balance_bill_sessions", :force => true do |t|
    t.integer  "insurance_session_id"
    t.integer  "patient_id"
    t.decimal  "total_amount",                       :precision => 15, :scale => 2
    t.string   "created_user"
    t.string   "updated_user"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "group_id"
    t.integer  "provider_id"
    t.datetime "dos"
    t.integer  "balance_bill_id"
    t.integer  "disposition"
    t.string   "status",               :limit => 25
  end

  add_index "balance_bill_sessions", ["insurance_session_id"], :name => "index_balance_bills_on_insurance_session_id"
  add_index "balance_bill_sessions", ["patient_id"], :name => "index_balance_bills_on_patient_id"

  create_table "balance_bill_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "balance_bill_versions", ["item_type", "item_id"], :name => "index_balance_bill_versions_on_item_type_and_item_id"

  create_table "balance_bills", :force => true do |t|
    t.integer  "patient_id"
    t.datetime "invoice_date"
    t.datetime "closed_date"
    t.decimal  "total_amount",                         :precision => 15, :scale => 2
    t.decimal  "payment_amount",                       :precision => 15, :scale => 2
    t.decimal  "balance_owed",                         :precision => 15, :scale => 2
    t.integer  "invoice_id"
    t.string   "created_user",                                                                           :null => false
    t.string   "updated_user"
    t.datetime "created_at",                                                                             :null => false
    t.datetime "updated_at",                                                                             :null => false
    t.decimal  "adjustment_amount",                    :precision => 15, :scale => 2
    t.string   "adjustment_description"
    t.decimal  "late_amount",                          :precision => 15, :scale => 2
    t.integer  "dataerror_count",                                                     :default => 0
    t.boolean  "dataerror",                                                           :default => false
    t.integer  "provider_id"
    t.integer  "group_id"
    t.string   "comment"
    t.string   "balance_status",         :limit => 25
    t.string   "status",                 :limit => 25
    t.decimal  "waived_amount",                        :precision => 15, :scale => 2, :default => 0.0
    t.datetime "waived_date"
  end

  add_index "balance_bills", ["patient_id"], :name => "index_balance_bills_on_patient_id"

  create_table "codes_carcs", :force => true do |t|
    t.string   "code",         :limit => 10
    t.string   "description"
    t.string   "created_user",                                  :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                    :default => false, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "status",       :limit => 25
  end

  create_table "codes_cpts", :force => true do |t|
    t.string   "code",              :limit => 25,                     :null => false
    t.string   "long_description",                                    :null => false
    t.string   "short_description", :limit => 100
    t.string   "created_user",                                        :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                          :default => false, :null => false
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "status",            :limit => 25
  end

  create_table "codes_dsms", :force => true do |t|
    t.string   "version",           :limit => 10,                     :null => false
    t.string   "code",              :limit => 25,                     :null => false
    t.string   "long_description",                                    :null => false
    t.string   "short_description", :limit => 100
    t.string   "category",          :limit => 75
    t.string   "created_user",                                        :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                          :default => false, :null => false
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "status",            :limit => 25
  end

  create_table "codes_icd10s", :force => true do |t|
    t.string   "code",              :limit => 25,                     :null => false
    t.string   "long_description",                                    :null => false
    t.string   "short_description", :limit => 100
    t.string   "created_user",                                        :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                          :default => false, :null => false
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "status",            :limit => 25
  end

  create_table "codes_icd9s", :force => true do |t|
    t.string   "code",              :limit => 25,                     :null => false
    t.string   "long_description",                                    :null => false
    t.string   "short_description", :limit => 100
    t.string   "created_user",                                        :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                          :default => false, :null => false
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "status",            :limit => 25
  end

  create_table "codes_modifiers", :force => true do |t|
    t.string   "code",         :limit => 10
    t.string   "description"
    t.string   "created_user",                                  :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                    :default => false, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "status",       :limit => 25
  end

  create_table "codes_pos", :force => true do |t|
    t.string   "code",         :limit => 25,                     :null => false
    t.string   "description",  :limit => 100
    t.string   "created_user",                                   :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                     :default => false, :null => false
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "status",       :limit => 25
  end

  create_table "codes_rarcs", :force => true do |t|
    t.string   "code",         :limit => 10
    t.string   "description"
    t.string   "created_user",                                  :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                    :default => false, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "status",       :limit => 25
  end

  create_table "dataerrors", :force => true do |t|
    t.integer  "dataerrorable_id"
    t.string   "dataerrorable_type"
    t.string   "message"
    t.string   "created_user",                          :null => false
    t.string   "updated_user"
    t.boolean  "deleted",            :default => false, :null => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "dataerrors", ["dataerrorable_type", "dataerrorable_id"], :name => "index_dataerrors_on_dataerrorable_type_and_dataerrorable_id"

  create_table "edi_vendors", :force => true do |t|
    t.boolean  "primary",                             :default => false
    t.string   "name",                 :limit => 100
    t.boolean  "trans835",                            :default => true
    t.boolean  "trans837p",                           :default => true
    t.boolean  "trans837i",                           :default => false
    t.boolean  "trans837d",                           :default => false
    t.boolean  "trans997",                            :default => false
    t.boolean  "trans999",                            :default => true
    t.string   "ftp_address",          :limit => 100
    t.integer  "ftp_port",                            :default => 22
    t.boolean  "ssh_sftp_enabled",                    :default => true
    t.boolean  "passive_mode_enabled",                :default => true
    t.string   "folder_send_to",       :limit => 150, :default => "/inbound"
    t.string   "folder_receive_from",  :limit => 150, :default => "/outbound"
    t.string   "password"
    t.string   "username",             :limit => 100
    t.string   "created_user",                                                 :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                             :default => false,       :null => false
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.boolean  "testing",                             :default => true
    t.string   "status",               :limit => 25
  end

  create_table "eob_claim_adjustment_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "eob_claim_adjustment_versions", ["item_type", "item_id"], :name => "index_eob_claim_adjustment_versions_on_item_type_and_item_id"

  create_table "eob_claim_adjustments", :force => true do |t|
    t.integer  "eob_id"
    t.string   "claim_adjustment_group_code"
    t.string   "carc1",                       :limit => 5
    t.decimal  "monetary_amount1",                         :precision => 15, :scale => 2
    t.integer  "quantity1"
    t.string   "carc2",                       :limit => 5
    t.decimal  "monetary_amount2",                         :precision => 15, :scale => 2
    t.integer  "quantity2"
    t.string   "carc3",                       :limit => 5
    t.decimal  "monetary_amount3",                         :precision => 15, :scale => 2
    t.integer  "quantity3"
    t.string   "carc4",                       :limit => 5
    t.decimal  "monetary_amount4",                         :precision => 15, :scale => 2
    t.integer  "quantity4"
    t.string   "carc5",                       :limit => 5
    t.decimal  "monetary_amount5",                         :precision => 15, :scale => 2
    t.integer  "quantity5"
    t.string   "carc6",                       :limit => 5
    t.decimal  "monetary_amount6",                         :precision => 15, :scale => 2
    t.integer  "quantity6"
    t.string   "created_user",                                                                               :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                                                                 :default => false, :null => false
    t.datetime "created_at",                                                                                 :null => false
    t.datetime "updated_at",                                                                                 :null => false
  end

  create_table "eob_detail_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "eob_detail_versions", ["item_type", "item_id"], :name => "index_eob_detail_versions_on_item_type_and_item_id"

  create_table "eob_details", :force => true do |t|
    t.integer  "eob_id"
    t.datetime "dos"
    t.integer  "provider_id"
    t.string   "provider_name",            :limit => 75
    t.string   "type_of_service",          :limit => 75
    t.decimal  "charge_amount",                          :precision => 15, :scale => 2
    t.decimal  "allowed_amount",                         :precision => 15, :scale => 2
    t.decimal  "copay_amount",                           :precision => 15, :scale => 2
    t.decimal  "deductible_amount",                      :precision => 15, :scale => 2
    t.decimal  "other_carrier_amount",                   :precision => 15, :scale => 2
    t.decimal  "not_covered_amount",                     :precision => 15, :scale => 2
    t.decimal  "payment_amount",                         :precision => 15, :scale => 2
    t.decimal  "subscriber_amount",                      :precision => 15, :scale => 2
    t.decimal  "coinsurance_amount",                     :precision => 15, :scale => 2
    t.string   "created_user",                                                                             :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                                                               :default => false, :null => false
    t.datetime "created_at",                                                                               :null => false
    t.datetime "updated_at",                                                                               :null => false
    t.integer  "units"
    t.datetime "service_start"
    t.datetime "service_end"
    t.string   "claim_number",             :limit => 50
    t.string   "ref_authorization_number", :limit => 50
    t.string   "ref_prior_authorization",  :limit => 50
  end

  add_index "eob_details", ["id", "dos", "type_of_service"], :name => "index_eob_details_on_id_and_dos_and_type_of_service"

  create_table "eob_service_adjustment_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "eob_service_adjustment_versions", ["item_type", "item_id"], :name => "index_eob_service_adjustment_versions_on_item_type_and_item_id"

  create_table "eob_service_adjustments", :force => true do |t|
    t.integer  "eob_detail_id"
    t.string   "claim_adjustment_group_code"
    t.string   "carc1",                       :limit => 5
    t.decimal  "monetary_amount1",                         :precision => 15, :scale => 2
    t.integer  "quantity1"
    t.string   "carc2",                       :limit => 5
    t.decimal  "monetary_amount2",                         :precision => 15, :scale => 2
    t.integer  "quantity2"
    t.string   "carc3",                       :limit => 5
    t.decimal  "monetary_amount3",                         :precision => 15, :scale => 2
    t.integer  "quantity3"
    t.string   "carc4",                       :limit => 5
    t.decimal  "monetary_amount4",                         :precision => 15, :scale => 2
    t.integer  "quantity4"
    t.string   "carc5",                       :limit => 5
    t.decimal  "monetary_amount5",                         :precision => 15, :scale => 2
    t.integer  "quantity5"
    t.string   "carc6",                       :limit => 5
    t.decimal  "monetary_amount6",                         :precision => 15, :scale => 2
    t.integer  "quantity6"
    t.string   "created_user",                                                                               :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                                                                 :default => false, :null => false
    t.datetime "created_at",                                                                                 :null => false
    t.datetime "updated_at",                                                                                 :null => false
  end

  create_table "eob_service_remark_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "eob_service_remark_versions", ["item_type", "item_id"], :name => "index_eob_service_remark_versions_on_item_type_and_item_id"

  create_table "eob_service_remarks", :force => true do |t|
    t.integer  "eob_detail_id"
    t.string   "code_list_qualifier", :limit => 5
    t.string   "remark_code",         :limit => 30
    t.string   "created_user",                                         :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                           :default => false, :null => false
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  create_table "eob_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "eob_versions", ["item_type", "item_id"], :name => "index_eob_versions_on_item_type_and_item_id"

  create_table "eobs", :force => true do |t|
    t.integer  "insurance_billing_id"
    t.datetime "eob_date"
    t.string   "claim_number",             :limit => 50
    t.string   "group_number",             :limit => 50
    t.decimal  "charge_amount",                           :precision => 15, :scale => 2
    t.decimal  "payment_amount",                          :precision => 15, :scale => 2
    t.decimal  "subscriber_amount",                       :precision => 15, :scale => 2
    t.string   "subscriber_first_name",    :limit => 40
    t.string   "subscriber_last_name",     :limit => 40
    t.string   "payor_name",               :limit => 100
    t.integer  "insurance_company_id"
    t.string   "created_user",                                                                              :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                                                                :default => false, :null => false
    t.datetime "created_at",                                                                                :null => false
    t.datetime "updated_at",                                                                                :null => false
    t.integer  "patient_id"
    t.string   "patient_first_name",       :limit => 40
    t.string   "patient_last_name",        :limit => 40
    t.datetime "claim_date"
    t.datetime "service_start_date"
    t.datetime "service_end_date"
    t.string   "subscriber_ins_policy",    :limit => 50
    t.string   "claim_status_code",        :limit => 10
    t.string   "claim_indicator_code",     :limit => 10
    t.string   "payor_claim_number",       :limit => 50
    t.string   "payor_contact",            :limit => 100
    t.string   "payor_contact_qualifier",  :limit => 10
    t.string   "ref_class_contract",       :limit => 50
    t.string   "ref_authorization_number", :limit => 50
    t.string   "provider_first_name",      :limit => 40
    t.string   "provider_last_name",       :limit => 40
    t.string   "provider_npi",             :limit => 25
    t.string   "payee_name",               :limit => 100
    t.string   "payee_npi",                :limit => 25
    t.string   "payee_payor_id",           :limit => 75
    t.string   "payee_ein",                :limit => 20
    t.string   "payee_ssn",                :limit => 20
    t.string   "payee_address1",           :limit => 40
    t.string   "payee_address2",           :limit => 40
    t.string   "payee_city",               :limit => 20
    t.string   "payee_state",              :limit => 15
    t.string   "payee_zip",                :limit => 15
    t.datetime "dos"
    t.integer  "provider_id"
    t.integer  "group_id"
    t.integer  "check_number_old"
    t.datetime "check_date"
    t.decimal  "check_amount",                            :precision => 15, :scale => 2
    t.boolean  "manual",                                                                 :default => false
    t.integer  "subscriber_id"
    t.string   "check_number",             :limit => 100
    t.string   "payment_method",           :limit => 10
    t.decimal  "bpr_monetary_amount",                     :precision => 15, :scale => 2, :default => 0.0
    t.string   "trn_payor_identifier",     :limit => 20
    t.integer  "invoice_id"
    t.string   "crossover_carrier",        :limit => 100
  end

  add_index "eobs", ["eob_date"], :name => "index_eobs_on_eob_date"
  add_index "eobs", ["insurance_billing_id", "eob_date"], :name => "index_eobs_on_insurance_billing_id_and_eob_date"

  create_table "groups", :force => true do |t|
    t.string   "group_name",         :limit => 40,                                                   :null => false
    t.string   "web_site"
    t.string   "office_phone",       :limit => 20
    t.string   "office_fax",         :limit => 20
    t.string   "ein_number",         :limit => 20
    t.boolean  "signature_on_file",                                               :default => false
    t.datetime "signature_date"
    t.string   "license_number",     :limit => 20
    t.datetime "license_date"
    t.boolean  "insurance_accepted",                                              :default => false
    t.datetime "insurance_date"
    t.string   "upin_usin_id",       :limit => 20
    t.string   "npi",                :limit => 25
    t.string   "created_user",                                                                       :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                                                         :default => false, :null => false
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
    t.integer  "invoice_method"
    t.decimal  "flat_fee",                         :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "dos_fee",                          :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "claim_percentage",                 :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "balance_percentage",               :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "setup_fee",                        :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "cob_fee",                          :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "denied_fee",                       :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "discovery_fee",                    :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "admin_fee",                        :precision => 15, :scale => 2, :default => 0.0
    t.integer  "payment_terms"
  end

  add_index "groups", ["group_name"], :name => "index_groups_on_group_name"

  create_table "groups_providers", :force => true do |t|
    t.integer  "group_id",                        :null => false
    t.integer  "provider_id",                     :null => false
    t.string   "created_user"
    t.string   "updated_user"
    t.boolean  "deleted",      :default => false, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "groups_providers", ["group_id"], :name => "index_groups_therapists_on_group_id"
  add_index "groups_providers", ["provider_id"], :name => "index_groups_providers_on_provider_id"

  create_table "idiagnostics", :force => true do |t|
    t.integer  "idiagable_id"
    t.string   "idiagable_type"
    t.string   "icd9_code",      :limit => 25
    t.string   "icd10_code",     :limit => 25
    t.string   "dsm_code",       :limit => 25
    t.string   "dsm4_code",      :limit => 25
    t.string   "dsm5_code",      :limit => 25
    t.string   "created_user",                                    :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                      :default => false, :null => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "idiagnostics", ["idiagable_type", "idiagable_id"], :name => "index_idiagnostics_on_idiagable_type_and_idiagable_id"

  create_table "insurance_billing_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "insurance_billing_versions", ["item_type", "item_id"], :name => "index_insurance_billing_versions_on_item_type_and_item_id"

  create_table "insurance_billings", :force => true do |t|
    t.integer  "insurance_session_id",                                                                 :null => false
    t.integer  "subscriber_id"
    t.decimal  "insurance_billed",                   :precision => 15, :scale => 2
    t.string   "claim_number",         :limit => 50
    t.datetime "claim_submitted"
    t.integer  "dataerror_count",                                                   :default => 0
    t.boolean  "dataerror",                                                         :default => false
    t.string   "created_user",                                                                         :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                                                           :default => false, :null => false
    t.datetime "created_at",                                                                           :null => false
    t.datetime "updated_at",                                                                           :null => false
    t.datetime "dos"
    t.integer  "patient_id"
    t.integer  "provider_id"
    t.integer  "group_id"
    t.integer  "insurance_company_id"
    t.integer  "status"
    t.string   "override_user_id"
    t.datetime "override_datetime"
    t.integer  "secondary_status",                                                  :default => 200
    t.integer  "managed_care_id"
  end

  add_index "insurance_billings", ["insurance_session_id"], :name => "index_insurance_billings_on_insurance_session_id"

  create_table "insurance_companies", :force => true do |t|
    t.string   "name",                   :limit => 100,                    :null => false
    t.string   "address1",               :limit => 40
    t.string   "address2",               :limit => 40
    t.string   "city",                   :limit => 20
    t.string   "state",                  :limit => 15
    t.string   "zip",                    :limit => 15
    t.string   "main_phone",             :limit => 20
    t.string   "alt_phone",              :limit => 20
    t.string   "fax_number",             :limit => 20
    t.string   "insurance_co_id",        :limit => 100
    t.string   "submitter_id",           :limit => 100
    t.string   "created_user",                                             :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                               :default => false, :null => false
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.string   "alt_phone_description",  :limit => 50
    t.string   "main_phone_description", :limit => 50
  end

  create_table "insurance_session_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "insurance_session_versions", ["item_type", "item_id"], :name => "index_insurance_session_versions_on_item_type_and_item_id"

  create_table "insurance_sessions", :force => true do |t|
    t.integer  "patient_id",                                                                                 :null => false
    t.integer  "provider_id",                                                                                :null => false
    t.integer  "group_id"
    t.integer  "office_id"
    t.integer  "patient_injury_id"
    t.integer  "managed_care_id"
    t.datetime "dos",                                                                                        :null => false
    t.string   "pos_code",                   :limit => 25
    t.decimal  "charges_for_service",                      :precision => 15, :scale => 2
    t.decimal  "copay_amount",                             :precision => 15, :scale => 2
    t.decimal  "patient_additional_payment",               :precision => 15, :scale => 2
    t.decimal  "interest_payment",                         :precision => 15, :scale => 2
    t.decimal  "waived_fee",                               :precision => 15, :scale => 2
    t.decimal  "balance_owed",                             :precision => 15, :scale => 2
    t.decimal  "ins_paid_amount",                          :precision => 15, :scale => 2
    t.decimal  "ins_allowed_amount",                       :precision => 15, :scale => 2
    t.decimal  "bal_bill_paid_amount",                     :precision => 15, :scale => 2
    t.string   "created_user",                                                                               :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                                                                 :default => false, :null => false
    t.datetime "created_at",                                                                                 :null => false
    t.datetime "updated_at",                                                                                 :null => false
    t.integer  "billing_office_id"
    t.integer  "status"
    t.integer  "selector"
    t.decimal  "coinsurance_amount",                       :precision => 15, :scale => 2
    t.decimal  "deductible_amount",                        :precision => 15, :scale => 2
  end

  add_index "insurance_sessions", ["group_id"], :name => "index_insurance_sessions_on_group_id"
  add_index "insurance_sessions", ["patient_id"], :name => "index_insurance_sessions_on_patient_id"
  add_index "insurance_sessions", ["provider_id"], :name => "index_insurance_sessions_on_provider_id"

  create_table "insurance_types", :force => true do |t|
    t.string   "name",         :limit => 50,                    :null => false
    t.boolean  "perm",                       :default => false
    t.string   "created_user",                                  :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                    :default => false, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "status",       :limit => 25
  end

  create_table "insured_types", :force => true do |t|
    t.string   "name",         :limit => 50,                    :null => false
    t.boolean  "perm",                       :default => false
    t.string   "created_user",                                  :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                    :default => false, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "status",       :limit => 25
  end

  create_table "invoice_detail_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "invoice_detail_versions", ["item_type", "item_id"], :name => "index_invoice_detail_versions_on_item_type_and_item_id"

  create_table "invoice_details", :force => true do |t|
    t.integer  "invoice_id"
    t.integer  "idetailable_id"
    t.string   "idetailable_type"
    t.integer  "disposition"
    t.string   "created_user",                                                                       :null => false
    t.string   "updated_user"
    t.string   "status",            :limit => 25
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
    t.decimal  "ins_paid_amount",                  :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "ins_billed_amount",                :precision => 15, :scale => 2, :default => 0.0
    t.integer  "record_type"
    t.datetime "dos"
    t.decimal  "charge_amount",                    :precision => 15, :scale => 2, :default => 0.0
    t.boolean  "discovery_fee",                                                   :default => false
    t.boolean  "admin_fee",                                                       :default => false
    t.string   "patient_name",      :limit => 80
    t.string   "claim_number",      :limit => 50
    t.string   "insurance_name",    :limit => 100
    t.string   "provider_name",     :limit => 90
    t.string   "group_name",        :limit => 40
    t.string   "description"
  end

  add_index "invoice_details", ["idetailable_type", "idetailable_id"], :name => "index_invoice_details_on_idetailable_type_and_idetailable_id"
  add_index "invoice_details", ["invoice_id"], :name => "index_invoice_details_on_invoice_id"

  create_table "invoice_payment_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "invoice_payment_versions", ["item_type", "item_id"], :name => "index_invoice_payment_versions_on_item_type_and_item_id"

  create_table "invoice_payments", :force => true do |t|
    t.integer  "invoice_id"
    t.decimal  "payment_amount",               :precision => 15, :scale => 2
    t.datetime "payment_date"
    t.decimal  "balance_amount",               :precision => 15, :scale => 2
    t.string   "created_user",                                                :null => false
    t.string   "updated_user"
    t.string   "status",         :limit => 25
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
  end

  add_index "invoice_payments", ["invoice_id"], :name => "index_invoice_payments_on_invoice_id"

  create_table "invoice_versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "invoice_versions", ["item_type", "item_id"], :name => "index_invoice_versions_on_item_type_and_item_id"

  create_table "invoices", :force => true do |t|
    t.integer  "invoiceable_id"
    t.string   "invoiceable_type"
    t.string   "invoice_status",               :limit => 25
    t.datetime "created_date"
    t.datetime "sent_date"
    t.datetime "closed_date"
    t.datetime "waived_date"
    t.decimal  "total_invoice_amount",                       :precision => 15, :scale => 2
    t.decimal  "balance_owed_amount",                        :precision => 15, :scale => 2
    t.decimal  "waived_amount",                              :precision => 15, :scale => 2
    t.string   "created_user",                                                                               :null => false
    t.string   "updated_user"
    t.string   "status",                       :limit => 25
    t.datetime "created_at",                                                                                 :null => false
    t.datetime "updated_at",                                                                                 :null => false
    t.datetime "second_notice_date"
    t.datetime "third_notice_date"
    t.datetime "deliquent_notice_date"
    t.decimal  "total_claim_charge_amount",                  :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "total_claim_payment_amount",                 :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "total_balance_charge_amount",                :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "total_balance_payment_amount",               :precision => 15, :scale => 2, :default => 0.0
    t.integer  "count_claims",                                                              :default => 0
    t.integer  "count_balances",                                                            :default => 0
    t.integer  "count_cob",                                                                 :default => 0
    t.integer  "count_denied",                                                              :default => 0
    t.integer  "count_setup",                                                               :default => 0
    t.integer  "count_admin",                                                               :default => 0
    t.integer  "count_discovery",                                                           :default => 0
    t.integer  "invoice_method"
    t.decimal  "flat_fee",                                   :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "dos_fee",                                    :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "claim_percentage",                           :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "balance_percentage",                         :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "cob_fee",                                    :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "denied_fee",                                 :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "setup_fee",                                  :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "admin_fee",                                  :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "discovery_fee",                              :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "subtotal_claims",                            :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "subtotal_balance",                           :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "subtotal_setup",                             :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "subtotal_cob",                               :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "subtotal_denied",                            :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "subtotal_admin",                             :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "subtotal_discovery",                         :precision => 15, :scale => 2, :default => 0.0
    t.integer  "payment_terms"
    t.datetime "fee_start"
    t.datetime "fee_end"
    t.integer  "count_dos",                                                                 :default => 0
    t.integer  "count_flat",                                                                :default => 0
  end

  add_index "invoices", ["invoiceable_type", "invoiceable_id"], :name => "index_invoices_on_invoiceable_type_and_invoiceable_id"

  create_table "iprocedures", :force => true do |t|
    t.integer  "iprocedureable_id"
    t.string   "iprocedureable_type"
    t.string   "modifier1",           :limit => 10
    t.string   "modifier2",           :limit => 10
    t.string   "modifier3",           :limit => 10
    t.string   "modifier4",           :limit => 10
    t.string   "created_user",                                                                        :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                                                          :default => false, :null => false
    t.datetime "created_at",                                                                          :null => false
    t.datetime "updated_at",                                                                          :null => false
    t.string   "cpt_code",            :limit => 25
    t.integer  "rate_id"
    t.decimal  "rate_override",                     :precision => 15, :scale => 2
    t.decimal  "total_charge",                      :precision => 15, :scale => 2
    t.boolean  "diag_pointer1",                                                    :default => false
    t.boolean  "diag_pointer2",                                                    :default => false
    t.boolean  "diag_pointer3",                                                    :default => false
    t.boolean  "diag_pointer4",                                                    :default => false
    t.boolean  "diag_pointer5",                                                    :default => false
    t.boolean  "diag_pointer6",                                                    :default => false
    t.integer  "units"
    t.integer  "sessions"
  end

  add_index "iprocedures", ["iprocedureable_type", "iprocedureable_id"], :name => "index_iprocedures_on_iprocedureable_type_and_iprocedureable_id"

  create_table "managed_cares", :force => true do |t|
    t.integer  "patient_id",                                                            :null => false
    t.integer  "subscriber_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "authorization_id"
    t.integer  "authorized_sessions"
    t.integer  "authorized_units"
    t.decimal  "authorized_charges",  :precision => 15, :scale => 2
    t.integer  "used_sessions"
    t.integer  "used_units"
    t.decimal  "used_charges",        :precision => 15, :scale => 2
    t.decimal  "copay",               :precision => 15, :scale => 2
    t.string   "created_user",                                                          :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                                            :default => false, :null => false
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
    t.boolean  "active",                                             :default => true
    t.boolean  "cob",                                                :default => false
    t.integer  "provider_id"
    t.integer  "group_id"
  end

  create_table "notes", :force => true do |t|
    t.integer  "noteable_id"
    t.string   "noteable_type"
    t.text     "note"
    t.string   "created_user",                     :null => false
    t.string   "updated_user"
    t.boolean  "deleted",       :default => false, :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "notes", ["noteable_type", "noteable_id"], :name => "index_notes_on_noteable_type_and_noteable_id"

  create_table "office_ally835s", :force => true do |t|
    t.integer  "office_ally_file_receive_id"
    t.string   "bpr_transaction_handling_code", :limit => 5
    t.decimal  "bpr_monetary_amount",                         :precision => 15, :scale => 2
    t.string   "bpr_payment_method_code",       :limit => 5
    t.datetime "bpr_date_check"
    t.string   "trn_check_number",              :limit => 50
    t.string   "trn_payer_identifier",          :limit => 20
    t.integer  "clm_count"
    t.string   "clm_claim_number",              :limit => 50
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
  end

  create_table "office_ally837ps", :force => true do |t|
    t.integer  "office_ally_file_send_id"
    t.string   "clp_claim_number",               :limit => 50
    t.string   "payor_name",                     :limit => 100
    t.string   "payor_identifier",               :limit => 20
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "gs_control_number",              :limit => 10
    t.string   "transaction_set_control_number", :limit => 10
  end

  create_table "office_ally999_errors", :force => true do |t|
    t.integer  "office_ally999_id"
    t.string   "segment",           :limit => 10
    t.integer  "segment_position"
    t.string   "loop",              :limit => 10
    t.string   "error_code",        :limit => 10
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "office_ally999_errors", ["office_ally999_id"], :name => "index_office_ally999_errors_on_office_ally999_id"

  create_table "office_ally999s", :force => true do |t|
    t.integer  "office_ally_file_receive_id"
    t.string   "ak1_gs_control_number",                  :limit => 10
    t.integer  "ak2_count"
    t.string   "ak2_transaction_set_identifier",         :limit => 5
    t.string   "ak2_transaction_set_control_number",     :limit => 10
    t.integer  "ik3_error_count",                                      :default => 0
    t.string   "ik5_transaction_set_acknoledgment_code", :limit => 5
    t.string   "ak9_gs_acknowledgment_code",             :limit => 5
    t.integer  "ak9_st_sets_included"
    t.integer  "ak9_st_sets_received"
    t.integer  "ak9_st_sets_accepted"
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
  end

  create_table "office_ally_file_receives", :force => true do |t|
    t.string   "filename",                       :limit => 50
    t.integer  "size"
    t.string   "extension",                      :limit => 50
    t.boolean  "was_zipped",                                   :default => false
    t.string   "zipfile_name",                   :limit => 75
    t.datetime "file_downloaded"
    t.datetime "file_parsed"
    t.datetime "file_purged"
    t.string   "isa_control_number",             :limit => 10
    t.string   "isa_control_version_number",     :limit => 10
    t.string   "gs_control_number",              :limit => 10
    t.string   "gs_version_identifier_code",     :limit => 15
    t.string   "transaction_set_identifier",     :limit => 5
    t.string   "transaction_set_control_number", :limit => 10
    t.integer  "transaction_set_count"
    t.integer  "transaction_set_segment_count"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.datetime "file_modified"
    t.datetime "file_accessed"
  end

  create_table "office_ally_file_sends", :force => true do |t|
    t.string   "filename",                       :limit => 50
    t.integer  "filesize"
    t.string   "sftp_address",                   :limit => 100
    t.boolean  "confirmed_sent",                                :default => false
    t.datetime "file_sent"
    t.string   "isa_control_number",             :limit => 10
    t.string   "isa_control_version_number",     :limit => 10
    t.string   "gs_control_number",              :limit => 10
    t.string   "gs_version_identifier_code",     :limit => 15
    t.string   "transaction_set_identifier",     :limit => 5
    t.string   "transaction_set_control_number", :limit => 10
    t.integer  "transaction_set_count"
    t.integer  "transaction_set_segment_count"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
  end

  create_table "office_types", :force => true do |t|
    t.string   "name",         :limit => 50,                    :null => false
    t.boolean  "perm",                       :default => false
    t.string   "created_user",                                  :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                    :default => false, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "status",       :limit => 25
  end

  create_table "offices", :force => true do |t|
    t.integer  "officeable_id"
    t.string   "officeable_type"
    t.string   "priority",         :limit => 40
    t.string   "address1",         :limit => 40
    t.string   "address2",         :limit => 40
    t.string   "city",             :limit => 20
    t.string   "state",            :limit => 15
    t.string   "zip",              :limit => 15
    t.string   "office_phone",     :limit => 20
    t.string   "office_fax",       :limit => 20
    t.string   "second_phone",     :limit => 20
    t.string   "third_phone",      :limit => 20
    t.string   "created_user",                                      :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                        :default => false, :null => false
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.string   "office_name",      :limit => 50
    t.boolean  "billing_location",               :default => false
    t.boolean  "service_location",               :default => false
  end

  add_index "offices", ["officeable_type", "officeable_id"], :name => "index_offices_on_officeable_type_and_officeable_id"

  create_table "patient_injuries", :force => true do |t|
    t.integer  "patient_id",                                                         :null => false
    t.string   "description"
    t.datetime "start_illness"
    t.datetime "start_therapy"
    t.datetime "hospitalization_start"
    t.datetime "hospitalization_stop"
    t.datetime "disability_start"
    t.datetime "disability_stop"
    t.datetime "unable_to_work_start"
    t.datetime "unable_to_work_stop"
    t.string   "accident_type",         :limit => 50, :default => "Not an Accident"
    t.string   "accident_description"
    t.string   "accident_state",        :limit => 15
    t.string   "created_user",                                                       :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                             :default => false,             :null => false
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
  end

  add_index "patient_injuries", ["patient_id"], :name => "index_patient_injuries_on_patient_id"

  create_table "patients", :force => true do |t|
    t.string   "first_name",          :limit => 40,                       :null => false
    t.string   "last_name",           :limit => 40,                       :null => false
    t.string   "address1",            :limit => 40
    t.string   "address2",            :limit => 40
    t.string   "city",                :limit => 20
    t.string   "state",               :limit => 15
    t.string   "zip",                 :limit => 15
    t.string   "home_phone",          :limit => 20
    t.string   "work_phone",          :limit => 20
    t.string   "cell_phone",          :limit => 20
    t.string   "ssn_number",          :limit => 20
    t.string   "gender",              :limit => 10
    t.datetime "dob"
    t.string   "relationship_status",               :default => "Single"
    t.string   "referred_to",         :limit => 50
    t.string   "referred_to_type",    :limit => 50
    t.string   "referred_from",       :limit => 50
    t.string   "referred_from_type",  :limit => 50
    t.string   "referred_from_npi",   :limit => 25
    t.boolean  "assignment_benefits",               :default => false
    t.boolean  "accept_assignment",                 :default => false
    t.boolean  "signature_on_file",                 :default => false
    t.string   "created_user",                                            :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                           :default => false,    :null => false
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "patient_status",      :limit => 50
    t.string   "pos_code",            :limit => 25
  end

  add_index "patients", ["last_name"], :name => "index_patients_on_last_name"

  create_table "patients_groups", :force => true do |t|
    t.integer  "patient_id"
    t.integer  "group_id"
    t.string   "patient_account_number"
    t.decimal  "special_rate",           :precision => 15, :scale => 2
    t.string   "created_user"
    t.string   "updated_user"
    t.boolean  "deleted",                                               :default => false
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
    t.integer  "invoice_id"
  end

  add_index "patients_groups", ["group_id"], :name => "index_patients_groups_on_group_id"
  add_index "patients_groups", ["patient_id"], :name => "index_patients_groups_on_patient_id"

  create_table "patients_providers", :force => true do |t|
    t.integer  "patient_id"
    t.integer  "provider_id"
    t.string   "patient_account_number"
    t.decimal  "special_rate",           :precision => 15, :scale => 2
    t.string   "created_user"
    t.string   "updated_user"
    t.boolean  "deleted",                                               :default => false
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
    t.integer  "invoice_id"
  end

  add_index "patients_providers", ["patient_id"], :name => "index_client_therapists_on_client_id"
  add_index "patients_providers", ["patient_id"], :name => "index_patients_providers_on_patient_id"
  add_index "patients_providers", ["provider_id"], :name => "index_patients_providers_on_provider_id"

  create_table "provider_insurances", :force => true do |t|
    t.integer  "providerable_id"
    t.string   "providerable_type"
    t.integer  "insurance_company_id",                                  :null => false
    t.string   "provider_id",          :limit => 75
    t.datetime "expiration_date"
    t.datetime "notification_date"
    t.string   "created_user",                                          :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                            :default => false, :null => false
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.datetime "effective_date"
    t.text     "notes"
    t.string   "ein_suffix",           :limit => 2
  end

  add_index "provider_insurances", ["insurance_company_id"], :name => "index_provider_insurances_on_insurance_company_id"
  add_index "provider_insurances", ["providerable_type", "providerable_id"], :name => "provider_insurances on_providerable"

  create_table "providers", :force => true do |t|
    t.string   "first_name",          :limit => 40,                                                   :null => false
    t.string   "last_name",           :limit => 40,                                                   :null => false
    t.string   "provider_identifier", :limit => 20
    t.string   "ssn_number",          :limit => 20
    t.string   "ein_number",          :limit => 20
    t.boolean  "signature_on_file",                                                :default => false
    t.datetime "signature_date"
    t.string   "license_number",      :limit => 20
    t.datetime "license_date"
    t.boolean  "insurance_accepted",                                               :default => false
    t.datetime "insurance_date"
    t.string   "upin_usin_id",        :limit => 20
    t.string   "office_phone",        :limit => 20
    t.string   "cell_phone",          :limit => 20
    t.string   "home_phone",          :limit => 20
    t.string   "web_site"
    t.string   "npi",                 :limit => 25
    t.string   "created_user",                                                                        :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                                                          :default => false, :null => false
    t.datetime "created_at",                                                                          :null => false
    t.datetime "updated_at",                                                                          :null => false
    t.datetime "dob"
    t.string   "fax_phone",           :limit => 20
    t.string   "email",               :limit => 75
    t.integer  "invoice_method"
    t.decimal  "flat_fee",                          :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "dos_fee",                           :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "claim_percentage",                  :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "balance_percentage",                :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "setup_fee",                         :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "cob_fee",                           :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "denied_fee",                        :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "discovery_fee",                     :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "admin_fee",                         :precision => 15, :scale => 2, :default => 0.0
    t.integer  "payment_terms"
  end

  add_index "providers", ["last_name"], :name => "index_providers_on_last_name"

  create_table "rates", :force => true do |t|
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.string   "description"
    t.decimal  "rate",                        :precision => 15, :scale => 2, :default => 0.0
    t.string   "cpt_code",      :limit => 25
    t.string   "created_user",                                                                  :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                                                    :default => false, :null => false
    t.datetime "created_at",                                                                    :null => false
    t.datetime "updated_at",                                                                    :null => false
  end

  add_index "rates", ["rateable_type", "rateable_id"], :name => "index_rates_on_rateable_type_and_rateable_id"

  create_table "referred_types", :force => true do |t|
    t.string   "referred_type", :limit => 50,                    :null => false
    t.boolean  "perm",                        :default => false
    t.string   "created_user",                                   :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                     :default => false, :null => false
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "status",        :limit => 25
  end

  create_table "reportings", :force => true do |t|
    t.string   "title",             :limit => 50
    t.string   "description"
    t.boolean  "category_all",                    :default => false
    t.boolean  "category_provider",               :default => false
    t.boolean  "category_patient",                :default => false
    t.boolean  "category_claim",                  :default => false
    t.boolean  "category_balance",                :default => false
    t.boolean  "category_invoice",                :default => false
    t.boolean  "category_user",                   :default => false
    t.boolean  "category_system",                 :default => false
    t.string   "name",              :limit => 50
    t.string   "status",            :limit => 25
    t.string   "created_user",                                       :null => false
    t.string   "updated_user"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  create_table "subscriber_valids", :force => true do |t|
    t.integer  "validable_id"
    t.string   "validable_type"
    t.integer  "subscriber_id"
    t.integer  "in_network",     :default => 0
    t.datetime "validated_date"
    t.string   "created_user",                      :null => false
    t.string   "updated_user"
    t.boolean  "deleted",        :default => false, :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "subscriber_valids", ["subscriber_id"], :name => "index_subscriber_valids_on_subscriber_id"
  add_index "subscriber_valids", ["validable_type", "validable_id"], :name => "index_subscriber_valids_on_validable_type_and_validable_id"

  create_table "subscribers", :force => true do |t|
    t.integer  "patient_id",                                                           :null => false
    t.integer  "insurance_company_id",                                                 :null => false
    t.string   "ins_policy",                       :limit => 50
    t.string   "ins_group",                        :limit => 50
    t.string   "ins_priority",                     :limit => 50
    t.string   "type_patient",                     :limit => 25,  :default => "Self"
    t.string   "type_patient_other_description",   :limit => 100
    t.string   "type_insurance",                   :limit => 50,  :default => "Group"
    t.string   "type_insurance_other_description", :limit => 100
    t.datetime "start_date"
    t.datetime "subscriber_dob"
    t.string   "subscriber_gender",                :limit => 10
    t.string   "employer_name",                    :limit => 100
    t.string   "employer_address1",                :limit => 40
    t.string   "employer_address2",                :limit => 40
    t.string   "employer_city",                    :limit => 20
    t.string   "employer_state",                   :limit => 15
    t.string   "employer_zip",                     :limit => 15
    t.string   "employer_phone",                   :limit => 20
    t.boolean  "same_address_patient",                            :default => false
    t.string   "created_user",                                                         :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                                         :default => false,   :null => false
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.string   "subscriber_address1",              :limit => 40
    t.string   "subscriber_address2",              :limit => 40
    t.string   "subscriber_city",                  :limit => 20
    t.string   "subscriber_state",                 :limit => 15
    t.string   "subscriber_zip",                   :limit => 15
    t.string   "subscriber_ssn_number",            :limit => 20
    t.string   "subscriber_first_name",            :limit => 40
    t.string   "subscriber_last_name",             :limit => 40
    t.boolean  "same_as_patient",                                 :default => false
  end

  add_index "subscribers", ["patient_id"], :name => "index_subscribers_on_patient_id"

  create_table "system_infos", :force => true do |t|
    t.string   "organization_name",       :limit => 100
    t.string   "ein_number",              :limit => 20
    t.string   "ssn_number",              :limit => 20
    t.string   "first_name",              :limit => 40
    t.string   "last_name",               :limit => 40
    t.string   "address1",                :limit => 40
    t.string   "address2",                :limit => 40
    t.string   "city",                    :limit => 20
    t.string   "state",                   :limit => 15
    t.string   "zip",                     :limit => 15
    t.string   "work_phone",              :limit => 20
    t.string   "fax_phone",               :limit => 20
    t.string   "email",                   :limit => 100
    t.string   "created_user",                                              :null => false
    t.string   "updated_user"
    t.boolean  "deleted",                                :default => false, :null => false
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.string   "system_claim_identifier", :limit => 3
    t.string   "status",                  :limit => 25
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "",    :null => false
    t.string   "encrypted_password",                   :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "login_name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "home_phone"
    t.string   "cell_phone"
    t.string   "created_user"
    t.string   "updated_user"
    t.boolean  "perm",                                 :default => false
    t.boolean  "ability_invoice",                      :default => false
    t.boolean  "ability_admin",                        :default => false
    t.boolean  "ability_superadmin",                   :default => false
    t.boolean  "deleted",                              :default => false
    t.string   "status",                 :limit => 25
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
