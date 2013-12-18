#kill -s USR2 $(cat ./tmp/pids/unicorn.pid)
kill -9 $(cat ./tmp/pids/unicorn.pid)
sleep 5
bundle exec unicorn -c /home/weixin/wechatPro/config/unicorn_development.rb -D -E development 


