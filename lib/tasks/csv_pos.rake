# rake task to import icd-9 codes in csv format.
# csv file to be column A: code, column B: long_description, column C: short_description
# icd-9 codes to be stored in a directory seeds under db.
 
namespace :csv do

  desc "Import POS Codes in CSV format"
  task :pos => :environment do

    require 'csv'

    csv_file_path = "#{Rails.root}/db/seeds/pos_codes.csv"
    puts "Loading CSV: #{csv_file_path}"
  
    if CodesPos.count == 0
      puts "Cleanup & prepare to load POS codes"
      
      #reload from the csv file
      CSV.foreach(csv_file_path) do |row|
          if !(row[0] == "code" || row[0] == "Code")
            row = CodesPos.create!({:code => row[0], :description  => row[1], :created_user => 'admin'})
          end
      end
    else
      puts "POS codes already seeded, codes not loaded"
    end
    puts "Completed POS code load"
  end
end
