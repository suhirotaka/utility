require 'roo-xls'

in_path = ARGV.shift
in_path = in_path.sub('~', Dir.home)
out_path = ARGV.shift
out_path = out_path.sub('~', Dir.home)

Dir["#{in_path}/*.xls","#{in_path}/*.xlsx" ].each do |file|
  case ext = File.extname(file)
  when '.xls'
    xls = Roo::Excel.new(file)
  when '.xlsx'
    xls = Roo::Excelx.new(file)
  end
  xls.to_csv("#{out_path}/#{File.basename(file, ext)}.csv")
  puts "Converted successful: #{file}"
end
