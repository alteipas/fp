mkdir log
a=""; 140.times{|n| a=a+rand(9).to_s}
IO.write("config/secret","w"){|f| f.puts a}
rake db:drop:all
rake db:create:all
rake db:migrate
rake db:test:prepare
