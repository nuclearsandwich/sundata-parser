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
end
