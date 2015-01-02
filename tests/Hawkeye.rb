require_relative "../lib/Hawkeye.rb"
require_relative "wrapper.rb"
require 'minitest/spec'
require 'minitest/autorun'

species = ["achillea_millefolium", "arrhenatherum_elatius", "anagallis_arvensis", "cirsium_arvense", "rumex_acetosella"]

describe Hawkeye do
  it "Checks sequences" do
    Wrap.new.folder("hawkeye_test") do
      FileUtils.cp_r(Dir["../*.fasta"], Dir.getwd())
      test = Hawkeye.new(species, "rbcL", {:ref_file=>"/home/will/Code/phyloGenerator2/demo/rbcL_reference.fasta", :ref_min=>400,:ref_max=>1500,:gap_length=>5,:max_gaps=>10,:max_dwn=>10})
      assert test.check == ["anagallis_arvensis_rbcL"]
      assert Dir["hawkeye*"] == ["hawkeye_0_rbcL.fasta", "hawkeye_0_rbcL_mafft.fasta"]
    end
  end
end
