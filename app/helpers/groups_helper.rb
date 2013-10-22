module GroupsHelper
  
    
  #
  # creates the html code to be inserted into the seach_dialog div 
  # jquery dialog then uses this html inside a dialog popup box
  def group_search(groups)   
    @str = ""
    groups.each do |g|
      @str += link_to "#{g.group_name}", group_path(g.id) 
      @str += "<br />"
    end      
    return @str.html_safe  
  end
  
end
