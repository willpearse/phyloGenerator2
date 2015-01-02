task default: %w[test]

task :test do
  ruby "tests/Cap.rb"
  ruby "tests/Thor.rb"
  ruby "tests/Hulk.rb"
  ruby "tests/Hawkeye.rb"
end
