require "minitest/autorun"
require "pry"

require_relative "../sundata_parser"
require_relative "../gleaner"

class TestSundataParser < MiniTest::Test

  def setup
    @fixture_root = File.expand_path("../fixtures", __FILE__)
    @parser_files = [File.join(@fixture_root, "site 1 2016.TXT"), File.join(@fixture_root, "site 2 2016.TXT")]
    @parser = SundataParser.new @parser_files
    @parser.preprocess do |filename, rowdata_template|
      rowdata_template.year = Gleaner.year_from_filename filename
      rowdata_template.site = Gleaner.site_from_filename filename
    end
    @parser.read
    @parser.parse
  end

  def test_reads_txt_files
    @parser_files.each do |f|
      refute_nil @parser.input_data[f], "No data read for #{f}"
    end
  end

  def test_parses_sunscan_date_and_timezone
    sample_data = @parser.output_data.first
    assert_equal "2016-09-30", sample_data["date"]
    assert_equal "GMT-4 Hrs", sample_data["timezone"]
  end

  def test_parses_sunscan_version
    sample_data = @parser.output_data.first
    assert_equal "v1.02R (C) JGW 2004/01/19", sample_data.sunscan_version
  end

  def test_parses_sunscan_file_attributes
    sample_data = @parser.output_data.first
    assert_equal "Fictional", sample_data["location"]
    assert_equal "Sample Sunscan Data", sample_data["title"]
    assert_equal "35.17N", sample_data["latitude"]
    assert_equal "79.18W", sample_data["longitude"]
    assert_equal "BFS", sample_data["ext sensor"]
    assert_equal "1", sample_data["leaf angle distn parameter"]
  end

  def test_parses_sunscan_table_attributes
    sample_data = @parser.output_data.first
    assert_equal "10:00:18", sample_data["time"]
    assert_equal "10", sample_data["plot"]
    assert_equal "1", sample_data["sample"]
    assert_equal "1551.8", sample_data["transmitted"]
    assert_equal "0.43", sample_data["spread"]
    assert_equal "1977.7", sample_data["incident"]
    assert_equal "0.40", sample_data["beam"]
    assert_equal "165.9", sample_data.zenith_angle
    assert_equal "3.4", sample_data["lai"]
    assert_equal nil, sample_data["notes"]
  end

  def test_writes_out_csv_file
    outfile = File.join(@fixture_root, "2016-test-output.csv")
    parser = SundataParser.new @parser_files
    parser.read
    parser.parse
    parser.write_csv(outfile)
    assert File.exist?(outfile), "Output file #{outfile} not written."
    assert_equal File.read(File.join(@fixture_root, "sunscan_data_sample.csv")), File.read(outfile)
  end

  def test_preprocessor_adds_fields_to_each_row
    parser = SundataParser.new @parser_files
    parser.preprocess do |filename, rowdata_template|
      rowdata_template.filenames ||= Array.new
      rowdata_template.testing = "result"
    end
    parser.read
    parser.parse
    output_data = parser.output_data.sample
    assert_equal "result", output_data.testing
  end

  def test_error_when_preprocess_is_missing_block_argument
    parser = SundataParser.new @parser_files
    assert_raises(ArgumentError, "No exception raised when calling preprocess without a block.") do
      parser.preprocess
    end
  end
end
