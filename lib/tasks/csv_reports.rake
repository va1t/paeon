# rake task to import reports in csv format.
# csv file to be column A: title, col B: description, col C: name, col D: cat_all, col E: cat_provider
# col F: cat_patient, col G: cat_claim, col H: cat_balance, col I: cat_invoice, col J: cat_user, col K: cat_system
# csv file not required to have title row.  If it does, then column A: must be "title". 
# reports.csv is stored in a directory seeds under db.
 
namespace :csv do

  desc "Import Reports Listing in CSV format"
  task :reports => :environment do
    require 'csv'

    csv_file_path = "#{Rails.root}/db/seeds/reports.csv"    
    puts "Loading Reports: #{csv_file_path}"
    
    # Always delete the reports and reset the counter
    puts "Removing old reports"
    Reporting.delete_all
    #reset auto_increment    
    sql = "alter table reportings auto_increment=1"
    ActiveRecord::Base.connection.execute(sql)
     
    puts "Begin loading the reports csv..."      
    #reload from the csv file
    CSV.foreach(csv_file_path) do |row|
      #skip the header
      print "."      
      if !row.blank? && row[0].downcase != "title"
        row = Reporting.create!({:title => row[0], :description  => row[1], :name => row[2], :category_all => row[3],
              :category_provider => row[4], :category_patient => row[5], :category_claim => row[6], :category_balance => row[7],
              :category_invoice => row[8], :category_user => row[9], :category_system => row[10], :created_user => 'admin'})          
      end
    end
    puts " "
    puts "Completed reports load"
  end
end
