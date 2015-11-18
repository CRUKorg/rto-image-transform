require 'pry'
require 'bson'
require 'json'
require 'securerandom'

# these are file location parameters for processing
$data_root_folder = '/data'  # all images will be in here, both source and transformed
$source_folder_name =  'HER2/search' # within data root folder
$image_file_ext = '.tiff'
$create_colour_range = false
$colour_transfrom_manifest = '100,100,100'

$image_metadata = []
$processed_count = 0

def transform_file(file, destination_folder)
  random_base_name = BSON::ObjectId.new
  name = file.split('/').last
  collection = 'HER2 TMAs'

  id_no = name.split('.').first
  stain_type = 'HER2'
  score = ''
  orig_file_name = name
  orig_directory = file

  # puts id_no
  # create destination folder per slide
  slide_destination_folder = destination_folder + '/' + id_no
  `mkdir -p "#{slide_destination_folder}"`

  if $create_colour_range
    `convert "#{file}" +repage  -crop 4x4@  +adjoin -resize 495x496 "#{slide_destination_folder}/#{random_base_name}_%d__original.jpg"`
    for saturation in (100..300).step(25) do
      `convert "#{file}" +repage  -modulate 100,#{saturation},100  -crop 4x4@ +repage  +adjoin -resize 495x496 "#{slide_destination_folder}/#{random_base_name}_%d_#{saturation}.jpg"`
      for hue in (0..90).step(10) do
          # `convert "#{file}" +repage   -negate  -modulate 100,#{saturation},#{hue}  -crop 4x4@ +repage  +adjoin -resize 495x496 -background black "#{slide_destination_folder}/#{random_base_name}_%d_#{saturation}_#{hue}.jpg"`
        end      end
    else
  #  Arguments to convert and what they do...
  #  +repage : removes virtual canvas metadata from output
  #   -negate : inverts image, outputs complementary colour for each pixel
  #   -modulate : adjusts brightness (100=no change), saturation (x3) and hue(-4%)
  #   -crop : with arg given this divides original image into 16 (4x4) equal subimages
  #   +adjoin : force output to be written to separate files
  #   -resize : specifies size of output files
  #   -background : specifies background fill colour for output image

    # original transform
    # `convert "#{file}" +repage   -negate  -modulate 100,300,96  -crop 4x4@ +repage  +adjoin -resize 495x496 -background black "tmp/#{random_base_name}_%d.jpg"`
    # transform to subimages only - no colour changes
    `convert "#{file}" +repage -modulate #{$colour_transfrom_manifest} -crop 4x4@  +adjoin -resize 495x496 "#{slide_destination_folder}/#{random_base_name}_%d.jpg"`

    transformed_files = Dir.glob("#{slide_destination_folder}/*.jpg")
  end
  {
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

def transform_files_in_folder(source_folder, destination_folder)
  source_file_names = File.join(source_folder, '*' + $image_file_ext)
  Dir.glob(source_file_names) do |file|
    # puts "Processing... #{file}"
    $image_metadata << transform_file(file, destination_folder)
    $processed_count += 1
    if ($processed_count % 10 == 0)
      puts $processed_count
    end
  end
end

def transform_folder(source_folder, destination_folder)
  # first do files in folder
  transform_files_in_folder(source_folder, destination_folder)
  # then do all subfolders
  Dir.entries(source_folder).each do |subfolder|
    if File.directory? File.join(source_folder, subfolder) and !(subfolder =='.' || subfolder == '..')
      transform_folder(File.join(source_folder, subfolder), File.join(destination_folder, subfolder))
    end
  end

end


source_folder = File.join($data_root_folder,  $source_folder_name)

destination_folder = File.join($data_root_folder,'transform',$source_folder_name)

start_time = Time.now
#
# `mkdir -p "#{destination_folder}"`

transform_folder(source_folder, destination_folder)

File.open(File.join(destination_folder, 'her2_manifest.json'), 'w'){|f| f.puts $image_metadata.to_json}

# output time report
end_time = Time.now
elapsed = end_time - start_time
time_per_slide = elapsed / $processed_count / 16
puts "#{$processed_count} slides processed in #{elapsed.round(0)} seconds, #{time_per_slide.round(3)}s per slide"