require "bio"
require "fileutils"

Bio::NCBI.default_email = "wdpearse@umn.edu"

class Wrap
  define_method(:folder) do |new_dir, &block|
    old_dir = Dir.getwd
    Dir.mkdir new_dir
    Dir.chdir new_dir
    block.call
    Dir.chdir old_dir
    FileUtils.rm_r new_dir
  end
end
