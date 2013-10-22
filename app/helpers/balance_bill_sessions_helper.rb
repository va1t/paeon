module BalanceBillSessionsHelper
  
  def balance_bill_session_build_detail
    str = "<table><tbody><tr>"
    str += "<th class='description'>Description:</th>"
    str += "<th class='quantity'>Quantity:</th>"
    str += "<th class='amount'>Amount:</th>"
    str += "<th></th></tr>"
    @balance_bill_session.balance_bill_details.each_with_index do |detail, index|
      str += "<tr class='detail_row'>"
      str += "<td><input autocomplete='off' class='description' id='balance_bill_session_balance_bill_details_attributes_#{index}_description' name='balance_bill_session[balance_bill_details_attributes][#{index}][description]' size='30' value='#{detail.description}' type='text'></td>"
      str += "<td><input autocomplete='off' class='quantity' id='balance_bill_session_balance_bill_details_attributes_#{index}_quantity' name='balance_bill_session[balance_bill_details_attributes][#{index}][quantity]' size='30' value='#{detail.quantity}' type='text'></td>"
      str += "<td><input autocomplete='off' class='amount dollar' id='balance_bill_session_balance_bill_details_attributes_#{index}_amount' name='balance_bill_session[balance_bill_details_attributes][#{index}][amount]' size='30' value='#{detail.amount}' type='text'></td>"
      str += "<td>"
      if detail.id
        str += "<a href='/insurance_sessions/#{@insurance_session.id}/balance_bill_details/#{detail.id}' data-method='delete' rel='nofollow'><img alt='Delete' src='/assets/del-button.png' title='Delete' height='20' border='0' width='20'></a>"
        str += "<input id='balance_bill_session_balance_bill_details_attributes_#{index}_id' name='balance_bill_session[balance_bill_details_attributes][#{index}][id]' value=#{detail.id} type='hidden'>"
      end
      str += "</td></tr>" 
    end
    str += "</tbody></table>"
    return str.html_safe
  end
end
