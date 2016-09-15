require "minitest/autorun"

require_relative "../sundata_parser"

class TestSundataParser < MiniTest::Test

  def setup
    @fixture_root = File.expand_path("../fixtures", __FILE__)
    @parser_files = [File.join(@fixture_root, "site 1 2012.TXT"), File.join(@fixture_root, "site 1 2013.TXT")]
    @parser = SundataParser.new @parser_files
    @parser.read
    @parser.parse
  end

  def test_reads_txt_files
    @parser_files.each do |f|
      refute_nil @parser.input_data[f], "No data read for #{f}"
    end
  end

  def test_parses_sunscan_table_attributes
    sample_data = @parser.output_data.first
    assert_equal "13:12:37", sample_data["time"]
    assert_equal "21", sample_data["plot"]
    assert_equal "4", sample_data["sample"]
    assert_equal "164.0", sample_data["transmitted"]
    assert_equal "0.38", sample_data["spread"]
    assert_equal "1770.8", sample_data["incident"]
    assert_equal "0.80", sample_data["beam"]
    assert_equal "14.3", sample_data["zenith angle"]
    assert_equal "4.6", sample_data["lai"]
    assert_equal nil, sample_data["notes"]
  end

  def test_writes_out_csv_file
    sunscan_files = ["sam 01 _6 27.TXT", "sam 03 _6 27.TXT", "sam 04 _7_1.TXT", "sam 05 _6 28.TXT", "sam 06 6_30.TXT"].map{|name| File.join(@fixture_root, name)}
    outfile = File.join(@fixture_root, "2011-test-output.csv")
    parser = SundataParser.new sunscan_files
    parser.read
    parser.parse
    parser.write_csv(outfile)
    assert File.exist?(outfile), "Output file #{outfile} not written."
    assert_equal File.read(outfile), File.read(File.join(@fixture_root, "sunscan_data_v1.csv"))
  end
end
