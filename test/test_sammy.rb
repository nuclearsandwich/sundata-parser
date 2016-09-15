require "minitest/autorun"

require_relative "../sammy"

class TestSammy < MiniTest::Test
  def test_site_from_filename_for_2011
    assert_equal "4", Sammy.site_from_filename("sam 04 _7_1.TXT")
  end

  def test_site_from_filename_without_space_for_2011
    assert_equal "12", Sammy.site_from_filename("sam12_2_08.TXT")
  end


  def test_tnc_site_from_filename_for_2011
    assert_equal "tnc 2", Sammy.site_from_filename("sam_tnc_2_5-10.TXT")
  end

  def test_site_from_filename_for_2012_and_on
    assert_equal "1", Sammy.site_from_filename("site 1 2013.TXT")
  end

  def test_site_from_filename_for_15b
    assert_equal "15b", Sammy.site_from_filename("site 15b 2013.TXT")
  end

  def test_tnc_site_from_filename_for_2012_and_on
    assert_equal "tnc 2", Sammy.site_from_filename("tnc 2 2013.TXT")
  end

  def test_year_from_filename_for_2011
    assert_equal "2011", Sammy.year_from_filename("sam 04 _7_1.TXT")
  end

  def test_year_from_tnc_filename_for_2011
    assert_equal "2011", Sammy.year_from_filename("sam_tnc_2_5-10.TXT")
  end

  def test_year_from_filename_for_2012_and_on
    assert_equal "2013", Sammy.year_from_filename("site 1 2013.TXT")
  end

  def test_year_from_tnc_filename_for_2012_and_on
    assert_equal "2013", Sammy.year_from_filename("tnc 1 2013.TXT")
  end
end

