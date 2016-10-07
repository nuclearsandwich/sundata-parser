#!/usr/bin/env ruby

require "csv"
require "ostruct"

class SundataParser
  attr_reader :input_files, :input_data, :output_data

  def initialize input_files
    @input_files = input_files
    @input_data = Hash.new
    @output_data = Array.new
  end

  def read
    @input_files.each do |file|
      if File.exist? file
        input_data[file] = File.read(file)
      end
    end
  end

  def preprocess &preprocess_block
    if preprocess_block.nil?
      raise ArgumentError.new "#preprocess received with no block argument."
    end
    @preprocess_block = preprocess_block
  end

  def run_preprocess filename, rowdata_template
    @preprocess_block.call(filename, rowdata_template) if @preprocess_block
  end

  def parse
    input_data.each do |filename, data|
      rowdata_template = OpenStruct.new
      run_preprocess(filename, rowdata_template)

      arrived_at_table_data = false

      data.split("\r\n").each do |line|
        next if line.strip.empty? # Skip blank and whitespace lines

        if !arrived_at_table_data
          next if line =~ /\ACreated by SunData/ # Skip created by line
          if date_match = line.match(/\A(\d\d\d\d-\d\d-\d\d)\t\tLocal time is (GMT.\d+ Hrs)/)
            rowdata_template.date = date_match[1]
            rowdata_template.timezone = date_match[2]
          end

          if sunscan_match = line.match(/\ASunScan probe (v.*)/)
            rowdata_template.sunscan_version = sunscan_match[1]
          end

          if line[":"]
            line.split(":").map(&:strip).each_slice(2) do |key, value|
              next if value.nil? || value.empty?
              rowdata_template[key.downcase.gsub(" ", "_")] = value
            end
          end

          # Once we hit the table hearder we can start processing tabular data.
          # The header is two lines long because of the formatting.
          next if line =~ /\ATime\tPlot\t/
          arrived_at_table_data = true and next if line =~ /\s+mitted\s+ent/


        else
          rowdata = rowdata_template.dup
          table_line = line.split("\t")
          rowdata.time = table_line[0]
          rowdata.plot = table_line[1]
          rowdata.sample = table_line[2]
          rowdata.transmitted = table_line[3]
          rowdata.spread = table_line[4]
          rowdata.incident = table_line[5]
          rowdata.beam = table_line[6]
          rowdata.zenith_angle = table_line[7]
          rowdata.lai = table_line[8]
          rowdata.notes = table_line[9]
          # Only record output data once the full line data has been captured.
          output_data << rowdata
        end
      end
    end
  end

  def write_csv filename
    CSV.open filename, "wb", row_sep: "\r\n" do |csv|
      # Header line
      csv << %w[year site time plot sample transmitted spread incident beam zenith\ angle lai notes]

      output_data.sort_by{|o| o["site"]}.each do |out|
        csv << [out["year"], out["site"], out["time"], out["plot"], out["sample"], out["transmitted"], out["spread"], out["incident"], out["beam"], out["zenith angle"], out["lai"], out["notes"]]
      end
    end
  end
end

if $0.match /\A\/?sundata_parser.rb/
  require "optparse"
  ARGV << "-h" if ARGV.empty?
  optparser = OptionParser.new do |opts|
    opts.banner = "Usage: sundata_parser.rb --outfile OUTPUT_FILENAME INPUT_FILE..."
    opts.on "-oOUTFILE", "--outfile OUTFILE", "The name of the file output will be written to" do |outfile|
      OUTFILE = outfile
    end

    opts.on "-h", "--help", "Prints this help" do
      puts opts
      puts "  for more information and help visit https://github.com/nuclearsandwich/sundata-parser"
      exit
    end
  end.parse!

  if ARGV.empty?
    puts "Error: no input files. Run `#{$0} -h` for more information."
    exit
  end

  parser = SundataParser.new ARGV
  parser.read
  parser.parse
  parser.write_csv OUTFILE
end

