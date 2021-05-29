#!/bin/bash

NAME="dnd_sos_project"                                   # Name of the application
DJANGODIR=/home/ubuntu/dnd_sos                             # Django project directory (above the "_project internal")
SOCKFILE=/home/ubuntu/venv_dndsos/run/gunicorn.sock  # we will communicte using this unix socket
USER=ubuntu                                         # the user to run as
GROUP=ubuntu                                        # the group to run as
NUM_WORKERS=9                                       # how many worker processes should Gunicorn spawn
DJANGO_SETTINGS_MODULE=dnd_sos_project.settings      # which settings file should Django use
DJANGO_WSGI_MODULE=dnd_sos_project.wsgi              # WSGI module name
echo "Starting $NAME as `whoami`"

# Activate the virtual environment

cd $DJANGODIR
source /home/ubuntu/venv_dndsos/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Create the run directory if it doesn't exist

RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)

exec gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --user=$USER --group=$GROUP \
  --bind=unix:$SOCKFILE \
  --log-level=debug \
  --log-file=-
