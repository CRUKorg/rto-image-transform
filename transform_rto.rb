# CRUK Reverse The Odds image transformation script
# Copyright (C) 2016 Cancer Research UK
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'pry'
require 'bson'
require 'json'
require 'securerandom'

# these are file location parameters for processing
$data_root_folder = '/data'  # all images will be in here, both source and transformed
$source_folder_name =  'RTO/MRE11c' # within data root folder
$image_file_ext = '.jpg'
$create_colour_range = false
$colour_transfrom_manifest = '100,300,96'

$image_metadata = []
$processed_count = 0

def transform_file(file, destination_folder)
  random_base_name = BSON::ObjectId.new
  name = file.split('/').last
  collection = 'MRE11c'

  id_no = name.split('.').first
  stain_type = 'MRE11'
  score = ''
  orig_file_name = name
  orig_directory = file

  # puts id_no
  # create destination folder per slide
  slide_destination_folder = destination_folder + '/' + id_no
  slide_destination_folder = slide_destination_folder.gsub(' ','_')
  `mkdir -p "#{slide_destination_folder}"`
  base_dest_filename = slide_destination_folder + '/' + random_base_name.to_s

  if $create_colour_range
    `convert "#{file}" +repage  -crop 4x4@  +adjoin -resize 495x496 "#{base_dest_filename}_%d__original.jpg"`
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
    # `convert "#{file}" +repage   -negate  -modulate 100,300,96  -crop 6x6@ +repage  +adjoin -resize 495x496 -background black "tmp/#{random_base_name}_%d.jpg"`

    # transform to subimages with specified colour changes
    `convert "#{file}" +repage -negate -modulate #{$colour_transfrom_manifest} -crop 6x6@ +repage +adjoin -resize 495x496 -background black "#{base_dest_filename}_%d.jpg"`
    # remove edge images
    for suffix in [0,1,2,3,4,5,6,11,12,17,18,23,24,29,30,31,32,33,34,35] do
      file_to_delete = base_dest_filename + '_' + suffix.to_s() + '.jpg'
      # puts 'deleting... ' + file_to_delete
      `rm #{file_to_delete}`
    end
    # make a list of the files just created
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
    if File.directory? File.join(source_folder, subfolder) and !(subfolder =='.' || subfolder == '..' || subfolder == 'Do not transform')
      transform_folder(File.join(source_folder, subfolder), File.join(destination_folder, subfolder))
    end
  end

end

source_folder = File.join($data_root_folder,  $source_folder_name)

destination_folder = File.join($data_root_folder,'transform',$source_folder_name).gsub(' ','_')

start_time = Time.now
#
# `mkdir -p "#{destination_folder}"`

transform_folder(source_folder, destination_folder)

File.open(File.join(destination_folder, 'manifest.json'), 'w'){|f| f.puts $image_metadata.to_json}

# output time report
end_time = Time.now
elapsed = end_time - start_time
time_per_slide = elapsed / $processed_count / 16
puts "#{$processed_count} slides processed in #{elapsed.round(0)} seconds, #{time_per_slide.round(3)}s per slide"