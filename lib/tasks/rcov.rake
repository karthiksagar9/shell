namespace :test do
  desc 'Tracks test coverage with rcov'
  task :coverage do
    unless PLATFORM['i386-mswin32' ]
      rm_f "coverage"
      rm_f "coverage.data"
      rcov = "rcov --sort coverage --rails --aggregate coverage.data " +
             "--text-summary -Ilib -T -x gems/*,rcov*"
      system("#{rcov} --html test/unit/*_test.rb" )
      system("#{rcov} --html test/functional/*_test.rb" )
#      system("#{rcov} --html test/integration/*_test.rb" )
      system("open coverage/index.html" ) if PLATFORM['darwin' ]
    else
      rm_f "coverage"
      rm_f "coverage.data"
      rcov = "rcov.cmd --sort coverage --rails --aggregate coverage.data " +
             "--text-summary -Ilib -T"
      system("#{rcov} --html test/unit/*_test.rb" )
      system("#{rcov} --html test/functional/*_test.rb" )
      system("#{rcov} --html test/integration/*_test.rb" )
      system("\"C:/Program Files/Mozilla Firefox/firefox.exe\" " +
             "coverage/index.html" )
    end
  end
end
