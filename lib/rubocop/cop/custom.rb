module RuboCop::Cop::Custom; end

Dir[File.join(__dir__, 'custom', '*.rb')].each { |file| require file }
