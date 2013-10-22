# rake task to import icd-9 codes in csv format.
# csv file to be column A: code, column B: long_description, column C: short_description
# icd-9 codes to be stored in a directory seeds under db.
 
namespace :csv do

  desc "Import ICD-10 Codes in CSV format"
  task :icd10 => :environment do

    require 'csv'

    csv_file_path = "#{Rails.root}/db/seeds/icd10_codes.csv"
    puts "Loading CSV: #{csv_file_path}"
  
    if CodesIcd10.count == 0 
      puts "Cleanup & prepare to load ICD10 codes"
      
      #reload from the csv file
      CSV.foreach(csv_file_path) do |row|
          if !(row[0] == "code" || row[0] == "Code")
            row = CodesIcd10.create!({:code => row[0], :long_description  => row[1], :short_description => row[2], :created_user => 'admin'})
          end
      end
    else
      puts "ICD10 codes already seeded, codes not loaded"
    end
    puts "Completed ICD10 code load"
  end
end
