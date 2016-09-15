require "minitest/autorun"

require_relative "../sammy"

class TestSammy < MiniTest::Test
  def test_site_from_filename_for_2011
    assert_equal "4", Sammy.site_from_filename("sam 04 _7_1.TXT")
  end

  def test_site_from_filename_for_2012_and_on
    assert_equal "1", Sammy.site_from_filename("site 1 2013.TXT")
  end
end
