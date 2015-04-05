require_relative "../lib/Download.rb"
require_relative "wrapper.rb"
require 'minitest/spec'
require 'minitest/autorun'
require 'fileutils'

species = ["quercus_robur", "quercus_ilex", "pinus_strobus", "jabberwocky"]

describe Download do
  it "Downloads sequences" do
    Wrap.new.folder("download_test") do
      old_dir = Dir.getwd; Dir.mkdir "download_test"; Dir.chdir "download_test"
      test = Download.new(species, "rbcL", {})
      missed = test.stream
      assert Dir["*.fasta"].length > 1
      downloaded = Dir["*.fasta"]
      assert missed == species.reject {|sp| downloaded.any? {|x| x[sp] } }
      Dir.chdir old_dir; FileUtils.rm_r "download_test"
    end
  end
  it "Conducts reference alignment" do
    Wrap.new.folder("download_test") do
      test = Download.new(species, "rbcL", {:ref_file=>"/home/will/Code/phyloGenerator2/demo/rbcL_reference.fasta", :ref_min=>400,:ref_max=>1500,:gap_length=>5,:max_gaps=>10,:max_dwn=>10})
      missed = test.stream
      downloaded = Dir["*.fasta"]
      assert missed == species.reject {|sp| downloaded.any? {|x| x[sp] } }
    end
  end
end
