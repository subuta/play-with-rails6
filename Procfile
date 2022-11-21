release: bundle exec rake db:migrate
web: rm -f tmp/pids/server.pid && bin/rails server -p ${PORT:-5000} -e $RAILS_ENV -b "0.0.0.0"