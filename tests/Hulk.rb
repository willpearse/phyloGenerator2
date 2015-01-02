require_relative "../lib/Hulk.rb"
require_relative "wrapper.rb"
require 'minitest/spec'
require 'minitest/autorun'

species = ["achillea_millefolium", "arrhenatherum_elatius", "anagallis_arvensis", "cirsium_arvense", "rumex_acetosella"]

describe Hulk do
  it "Runs ExaML" do
    Wrap.new.folder("hulk_test") do
      FileUtils.cp_r(Dir["../*.fasta"], Dir.getwd())
      test = Hulk.new("examl", false)
      test.smash(species, ["rbcL"], false)
      assert Dir["ExaML_result.*"].length > 0
    end
  end
  it "Runs RAxML (inc. constraints)" do
    Wrap.new.folder("hulk_test") do
      FileUtils.cp_r(Dir["../*.fasta"], Dir.getwd())
      test = Hulk.new("raxml", false)
      test.smash(species, ["rbcL"], false)
      assert Dir["RAxML_result.hulk_*"].length > 0
      test = Hulk.new("raxml", Bio::Newick.new("(((achillea_millefolium,arrhenatherum_elatius),(anagallis_arvensis,cirsium_arvense)),rumex_acetosella);").tree)
      test.smash(species, ["rbcL"], false)
      assert Dir["RAxML_result.hulk_*"].length > 0
    end
  end
  it "Runs ExaBayes" do
    Wrap.new.folder("hulk_test") do
      FileUtils.cp_r(Dir["../*.fasta"], Dir.getwd())
      test = Hulk.new("exabayes", false)
      test.smash(species, ["rbcL"], false)
      assert Dir["ExaBayes_topologies.hulk_*"].length > 0
    end
  end
end
