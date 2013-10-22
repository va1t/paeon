#
# controller has only one method, destroy
# used for deleting session detail records 
#
class BalanceBillDetailsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!    
  authorize_resource :class => BalanceBill


  def destroy    
    @balance_bill_detail = BalanceBillDetail.find(params[:id])
    @balance_bill_detail.updated_user = current_user.login_name
    @balance_bill_detail.destroy
    
    respond_to do |format|
      format.html { redirect_to edit_insurance_session_balance_bill_session_path(params[:insurance_session_id], @balance_bill_detail.balance_bill_session_id) }
      format.json { head :no_content }
    end     
  end
end
