module Sammy
  def self.site_from_filename filename
    if File.basename(filename) =~ /\Asam/
      match = File.basename(filename).match(/\Asam(?: (\d+\w?)|_(tnc_\d+))/)
      site = match[1] || match[2]
      site.sub(/\A0/,"").gsub("_", " ")
    else
      match = File.basename(filename).match(/(?:\Asite (\d+\w?)|(\Atnc \d+))/)
      site = match[1] || match[2]
      site.sub(/\A0/,"").gsub("_", " ")
    end
  end

  def self.year_from_filename filename
    if File.basename(filename) =~ /\Asam/
      year = "2011"
    else
      year = File.basename(filename).match(/\A(?:site|tnc) \d+ (\d\d\d\d)/)[1]
    end
  end
end

