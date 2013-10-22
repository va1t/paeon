# rake task to import icd-9 codes in csv format.
# csv file to be column A: code, column B: long_description, column C: short_description
# icd-9 codes to be stored in a directory seeds under db.
 
namespace :csv do

  desc "Import ICD-9 Codes in CSV format"
  task :icd9 => :environment do

    require 'csv'

    csv_file_path = "#{Rails.root}/db/seeds/icd9_codes.csv"
    puts "Loading CSV: #{csv_file_path}"
  
    if CodesIcd9.count == 0 
      puts "Cleanup & prepare to load ICD9 codes"
      
      #reload from the csv file
      CSV.foreach(csv_file_path) do |row|
          if !(row[0] == "code" || row[0] == "Code")
            row = CodesIcd9.create!({:code => row[0], :long_description  => row[1], :short_description => row[2], :created_user => 'admin'})
          end
      end
    else
      puts "ICD9 codes already seeded, codes not loaded"
    end
    puts "Completed ICD9 code load"
  end
end
