ruby -e 'a=""; 140.times{|n| a=a+rand(9).to_s};File.open("config/secret","w"){|f| f.puts a}'
mkdir log
rake db:drop:all
rake db:create:all
rake db:migrate
rake db:test:prepare
