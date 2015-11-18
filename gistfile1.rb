require 'pry'
require 'bson'
require 'json'

manifest = []
outfile = 'for_testing'
blank_images = []


["MRE11 TMAs.zip"].each do |zip_name|
  puts "doing #{zip_name}"
  `cp "#{zip_name}" working/`
  `cd working; unzip "#{zip_name}"`


  Dir.glob("./working/**/*.jpg").each do |file|


    random_base_name = BSON::ObjectId.new
    name  = file.split("/").last
    collection = "MRE11 TMAs"

    id_no = name.split(".").first
    stain_type = "MRE11"
    score  = ""
    orig_file_name  = name
    orig_directory  = file

    `mkdir -p tmp`
    `convert "#{file}" +repage   -negate  -modulate 100,300,96  -crop 6x6@ +repage  +adjoin -resize 495x496 -background black "tmp/#{random_base_name}_%d.jpg"`
    `mv tmp/ "results_mre11/#{id_no}"`

    transformed_files  = Dir.glob("results_mre11/#{id_no}/*.jpg")

    manifest<< {
      base_name: random_base_name,
      name: name,
      colellection: collection,
      id_no: id_no,
      stain_type: stain_type,
      score: score,
      orig_file_name: orig_file_name,
      orig_directory: orig_directory,
      files: transformed_files
    }

  end
  `rm  -rf working/*`
end

File.open("mre11_manifest.json", "w"){|f| f.puts manifest.to_json}
