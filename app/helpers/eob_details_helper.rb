module EobDetailsHelper
  
  def eob_detail_form    
    @str = ""
    @eob_details.each_with_index do |detail, subscript|
      index = subscript + @count
      @str += "<div class='eob_detail_record'><div class='eobd_service'>Service Description:<br>"
      @str += "<input id='eob_eob_details_attributes_#{index}_type_of_service' name='eob[eob_details_attributes][#{index}][type_of_service]' size='30' value='' type='text'></div>"      
      if detail.id
        @str += "<span class='del'>"
        @str += "<a href='/eobs/#{@eob.id}/eob_details/#{detail.id}' data-method='delete' rel='nofollow'><img alt='Delete' src='/assets/del-button.png' title='Delete' height='20' border='0' width='20'></a>"
        @str += "</span>"
      end
      @str += "<div class='eobd_billed'>Billed:<br><input class='dollar2' id='eob_eob_details_attributes_#{index}_charge_amount' name='eob[eob_details_attributes][#{index}][charge_amount]' size='30' type='text'></div>"
      @str += "<div class='eobd_allowed'>Allowed:<br><input class='dollar2' id='eob_eob_details_attributes_#{index}_allowed_amount' name='eob[eob_details_attributes][#{index}][allowed_amount]' size='30' type='text'></div>"
      @str += "<div class='eobd_copay'>Copay:<br><input class='dollar2' id='eob_eob_details_attributes_#{index}_copay_amount' name='eob[eob_details_attributes][#{index}][copay_amount]' size='30' type='text'></div>"
      @str += "<div class='eobd_deductible'>Deduct:<br><input class='dollar2' id='eob_eob_details_attributes_#{index}_deductible_amount' name='eob[eob_details_attributes][#{index}][deductible_amount]' size='30' type='text'></div>"
      @str += "<div class='eobd_other'>Other:<br><input class='dollar2' id='eob_eob_details_attributes_#{index}_other_carrier_amount' name='eob[eob_details_attributes][#{index}][other_carrier_amount]' size='30' type='text'></div>"
      @str += "<div class='eobd_nc'>Not Cover:<br><input class='dollar2' id='eob_eob_details_attributes_#{index}_not_covered_amount' name='eob[eob_details_attributes][#{index}][not_covered_amount]' size='30' type='text'></div>"
      @str += "<div class='eobd_paid'>Paid:<br><input class='dollar2' id='eob_eob_details_attributes_#{index}_payment_amount' name='eob[eob_details_attributes][#{index}][payment_amount]' size='30' type='text'></div>"
      @str += "<div class='eobd_subscriber'>Subscriber:<br><input class='dollar2' id='eob_eob_details_attributes_#{index}_subscriber_amount' name='eob[eob_details_attributes][#{index}][subscriber_amount]' size='30' type='text'></div>"
      @str += "</div>"
    end
    
    return @str.html_safe  
  end
  
end
