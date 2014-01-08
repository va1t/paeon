class BalanceBillDetail < ActiveRecord::Base
  #
  # includes
  #
  include CommonStatus

  #
  # model associations
  #
  belongs_to :balance_bill_session

  # paper trail versions
  has_paper_trail :class_name => 'BalanceBillDetailVersion'

  #
  # constants
  #
  BALANCE = 'Balance'
  DEDUCTIBLE = 'Deductible'

  #
  # assignments
  #

  # allows the skipping of callbacks to save on database loads
  # use InsuranceBilling.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
  cattr_accessor :skip_callbacks

  attr_accessible :balance_bill_session_id, :amount, :description, :quantity, :detail_status,
                  :created_user, :updated_user
  attr_protected :status

  #
  # validations
  #
  validates :amount, :numericality => true
  validates :created_user, :presence => true

end

