# Supervisor
sudo vim /etc/supervisor/conf.d/bingo_supervisor.conf
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start dnd_sos
sudo supervisorctl status dnd_sos
sudo supervisorctl stop dnd_sos
sudo supervisorctl restart dnd_sos
sudo supervisorctl status all

sudo supervisorctl restart all


# Nginx
sudo service nginx restart

# REDIS
sudo systemctl restart redis.service
sudo /etc/init.d/redis-server restart
redis-server -v  # Version check

# Debug:
sudo lsof -i TCP:8001 | grep LISTEN

# Languages
django-admin makemessages -l he -i venv_dnd_sos
django-admin compilemessages
