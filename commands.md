# Supervisor
sudo vim /etc/supervisor/conf.d/bingo_supervisor.conf
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl status all
sudo supervisorctl status bingo_project
sudo supervisorctl restart bingo_project

sudo supervisorctl restart all

# Nginx
sudo service nginx restart

# REDIS
sudo systemctl restart redis.service
sudo /etc/init.d/redis-server restart
redis-server -v  # Version check