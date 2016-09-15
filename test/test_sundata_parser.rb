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
