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
end

