# rake task to import cpt codes in csv format.
# csv file to be column A: code, column B: long_description, column C: short_description
# cpt codes to be stored in a directory seeds under db.
 
namespace :csv do

  desc "Import CPT Codes in CSV format"
  task :cpt => :environment do

    require 'csv'

    csv_file_path = "#{Rails.root}/db/seeds/cpt_codes.csv"    
    puts "Loading CSV: #{csv_file_path}"
    
    if CodesCpt.count == 0 
      puts "Cleanup & prepare to load CPT codes"
      
      #reload from the csv file
      CSV.foreach(csv_file_path) do |row|
          if !(row[0] == "code" || row[0] == "Code")
            row = CodesCpt.create!({:code => row[0], :long_description  => row[1], :short_description => row[2], :created_user => 'admin'})          
          end
      end
    else
      puts "CPT codes already seeded, codes not loaded"
    end
    puts "Completed CPT code load"
  end
end
