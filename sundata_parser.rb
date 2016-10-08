#!/usr/bin/env ruby

require "csv"
require "ostruct"
require "pry"

# # SundataParser
# A class to read through an array of sundata TXT files and produce a csv file
# as output.
#
# ### Examples:
#     # Creating a new parser object. This is done when customizing the csv generation process.
#     SundataPaser.new ["data/file1.TXT", "data/file2.TXT"]
#
#     # Using the automatic runner. This starts the process as if it were run from a terminal
#     # prompt directly.
#     SundataParser.run! ARGV
class SundataParser
  attr_reader :input_files, :input_data, :output_data

  # Initialize a new parser object
  #
  # This method isn't run directly, but is run as part of SundataParser.new
  #
  # - `input_files` an array of filenames to read as sundata files.
  #
  def initialize input_files
    @input_files = input_files
    @input_data = Hash.new
    @output_data = Array.new
  end

  # Read input files into memory.
  #
  # Read from each input file in `input_files` and store the file contents
  # associated with the filename in a Ruby Hash Object.
  #
  # ### Examples:
  #     parser.read
  #     parser.input_data.each do |filename, file_contents|
  #       # ...
  #     end
  #
  # Filenames that do not exist are ignored without error.
  #
  # Returns nil but after reading data will be available in `input_data`.
  def read
    @input_files.each do |file|
      if File.exist? file
        input_data[file] = File.read(file)
      end
    end
    nil
  end

  # Set a preprocess script to be run once per input file when parsing data.
  #
  #
  # This can be used to add custom fields to the final output and is especially
  # useful if you have information you need to extract from the filename.
  #
  # To set a preprocessor, call this method with a Ruby block that has two
  # inputs, the filename of the current input file and the OpenStruct object
  # that will be used as the template for all row data in the final output.

  # ### Examples:
  #
  #     parser.preprocess do |filename, rowdata_template|
  #       rowdata_template.original_filename = filename
  #       rowdata_template.site_number = filename.split(" ")[2]
  #     end
  #
  # Does not return anything but stores the provided block for use during
  # parsing.  Raises an ArgumentError if called without a block.
  def preprocess &preprocess_block
    if preprocess_block.nil?
      raise ArgumentError.new "#preprocess received with no block argument."
    end
    @preprocess_block = preprocess_block
  end

  # Parse the input data and build output data.
  #
  # Transform the plaintext data that has been read and build an Array of
  # output rows.  If a preprocessor block was set, that will be used to set
  # initial values for rows in each filename.
  #
  # Does not have a return value but it will populate `output_data` with
  # OpenStruct objects representing each entry in the original data table.
  def parse
    input_data.each do |filename, data|
      rowdata_template = OpenStruct.new
      @preprocess_block.call(filename, rowdata_template) if @preprocess_block

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

          if matches = line.scan(/\s*([^\t:]+)\s*:\s*([^\t:]+)/)
            matches.flatten.map(&:strip).each_slice(2) do |key, value|
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


  # Write csv output to the given filename.
  #
  # - `filename` The name of the csv file to write to.
  # - `fields` The ordered array of fields to include. Defaults to all
  #   available fields.
  #
  # ### Examples
  #
  #     parser.write_csv("sample-output.csv")
  #     parser.write_csv("sample-output.csv", ["time", "incident", "beam", "transmitted")
  #     parser.write_csv("sample-output.csv", %w[zenith_angle plot sample lai notes]
  #
  # After running row data will be written to the filename specified with a header
  # line for import into a preferred spreadsheet tool.
  def write_csv filename, fields = nil

    # By default all fields present in every row of output_data will be incorporated.
    if fields.nil?
      # Transform each output struct into a list of its keys, then take the intersection of each Array of keys.
      # This ensures that only fields present for all rows will be incorporated.
      fields = output_data.map{|o| o.to_h.keys}.inject do |last_keys, this_keys|
        last_keys & this_keys
      end
    end

    CSV.open filename, "wb", row_sep: "\r\n" do |csv|
      # Header line
      csv << fields

      output_data.each do |out|
        output_row = []
        fields.each do |field|
          output_row << out[field]
        end
        csv << output_row
      end
    end
  end

  # Class method for running command line program.
  # Automatically called if $0 is this file.
  #
  # Can be called manually by requiring this file. When called from Ruby
  # this class method can take the preprocess_block directly.
  def SundataParser.run! argument_values, &preprocess_block
    require "optparse"
    argument_values << "-h" if argument_values.empty?
    optparser = OptionParser.new do |opts|
      opts.banner = "Usage: sundata_parser.rb --outfile OUTPUT_FILENAME --fields FIELDS INPUT_FILE..."
      opts.on "-oOUTFILE", "--outfile OUTFILE", "The name of the file output will be written to" do |outfile|
        @outfile = outfile
      end
      opts.on "-fFIELDS", "--fields FIELDS", "A comma-separated list of fields to output" do |fields|
        @fields = fields.split(",")
      end

      opts.on "-h", "--help", "Prints this help" do
        puts opts
        puts "  for more information and help visit https://github.com/nuclearsandwich/sundata-parser"
        exit
      end
    end.parse!(argument_values)

    if argument_values.empty?
      puts "Error: no input files. Run `#{$0} -h` for more information."
      exit(1)
    end

    unless defined?(@outfile)
      puts "Error: no output file. Run `#{$0} -h` for more information."
      exit(1)
    end

    parser = SundataParser.new argument_values
    parser.preprocess &preprocess_block unless preprocess_block.nil?
    parser.read
    parser.parse
    if defined?(@fields)
      parser.write_csv @outfile, @fields
    else
      parser.write_csv @outfile
    end
  end
end

if $0.match /\A\/?sundata_parser.rb/
  SundataParser.run! ARGV
end

