require_relative "../lib/PhyloGen.rb"
require_relative "wrapper.rb"
require 'minitest/spec'
require 'minitest/autorun'

species = ["achillea_millefolium", "arrhenatherum_elatius", "anagallis_arvensis", "cirsium_arvense", "rumex_acetosella"]

describe PhyloGen do
  it "Runs ExaML" do
    Wrap.new.folder("phylogen_test") do
      FileUtils.cp_r(Dir["../*.fasta"], Dir.getwd())
      test = PhyloGen.new("examl", false)
      test.build(species, ["rbcL"], false)
      assert Dir["ExaML_result.*"].length > 0
    end
  end
  it "Runs RAxML (inc. constraints)" do
    Wrap.new.folder("phylogen_test") do
      FileUtils.cp_r(Dir["../*.fasta"], Dir.getwd())
      test = PhyloGen.new("raxml", false)
      test.build(species, ["rbcL"], false)
      assert Dir["RAxML_result.phylogen_*"].length > 0
      test = PhyloGen.new("raxml", Bio::Newick.new("(((achillea_millefolium,arrhenatherum_elatius),(anagallis_arvensis,cirsium_arvense)),rumex_acetosella);").tree)
      test.build(species, ["rbcL"], false)
      assert Dir["RAxML_result.phylogen_*"].length > 0
    end
  end
  it "Runs ExaBayes" do
    Wrap.new.folder("phylogen_test") do
      FileUtils.cp_r(Dir["../*.fasta"], Dir.getwd())
      test = PhyloGen.new("exabayes", false)
      test.build(species, ["rbcL"], false)
      assert Dir["ExaBayes_topologies.phylogen_*"].length > 0
    end
  end
end
