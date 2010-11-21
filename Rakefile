
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name  'template_builder'
  authors  'Anthony'
  email  'anthony.laibe@gmail.com'
  url      'http://github/zetm9/template_builder'
  ignore_file  '.gitignore'
}

