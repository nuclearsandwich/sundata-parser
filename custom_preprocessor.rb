require_relative "sundata_parser"
require_relative "gleaner"

sundata = SundataParser.run! ARGV do |filename, rowdata_template|
  rowdata_template.year = Gleaner.year_from_filename filename
  rowdata_template.site = Gleaner.site_from_filename filename
end

