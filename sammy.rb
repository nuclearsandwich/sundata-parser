module Sammy
  def self.site_from_filename filename
    if File.basename(filename) =~ /\Asam/
      site = File.basename(filename).match(/\Asam (\d+)/)[1]
      site.to_i.to_s
    else
      site = File.basename(filename).match(/\Asite (\d+)/)[1]
      site.to_i.to_s
    end
  end

  def self.year_from_filename filename
    if File.basename(filename) =~ /\Asam/
      year = "2011"
    else
      year = File.basename(filename).match(/\Asite \d+ (\d\d\d\d)/)[1]
    end
  end
end

