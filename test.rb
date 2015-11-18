$dir_target = '/data/HER2/BCAC_PHASE1'

# Dir.glob("#{$dir_target}/*").each do |f|
#   if File.directory?(f)
#     puts "#{f}\n"
#   end
# end

Dir.entries("#{$dir_target}").each do |entry|
# Dir.entries($dir_target).each do |entry|
  if File.directory? File.join($dir_target, entry) and !(entry =='.' || entry == '..')
    puts entry
  end
end
puts '--------'
Dir.entries("#{$dir_target}").each do |f|
    if ( f == '.' || f == '..') then next end
    puts "#{f}\n"
 end