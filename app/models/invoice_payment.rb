class InvoicePayment < ActiveRecord::Base
  #
  # includes
  #
  include CommonStatus

  #
  # model associations
  #
  belongs_to :invoice

  # paper trail versions
  has_paper_trail :class_name => 'InvoicePaymentVersion'


  #
  # assignements
  #

  # allows the skipping of callbacks to save on database loads
  # use InsuranceBilling.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
  cattr_accessor :skip_callbacks

  attr_accessible :balance_amount, :payment_amount, :payment_date,
                  :created_user, :updated_user

  #
  # validations
  #
  validates :created_user, :presence => true


  #
  # instance methods
  #


  # revert the balance bill payment to the previous state
  def revert
    version = InvoicePaymentVersion.find(self.versions.last.id)
    # if there are versions then revert to the previous one.
    if version.reify
      self.transaction do
        version.reify.save
      end
    else
      self.destroy
    end
    return true
  end

end
