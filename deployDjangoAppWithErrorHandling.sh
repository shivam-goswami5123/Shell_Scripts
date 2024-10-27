#!/bin/bash

<<TASK
DEPLOY A DJANGO APP USING SHELL SCRIPTING WITH ERROR HANDILING
TASK

code_clone(){
        echo "Cloning Djnago App...."
        git clone https://github.com/LondheShubham153/django-notes-app.git
        echo "Cloning Done!!!"
}

install_req(){
        echo "*********INSTALLING DEPENDENCIES************"
        sudo apt-get install docker.io nginx -y
}

required_restart(){
        #enable -> restart service upon system reboot
        sudo chown $USER /var/run/docker.sock
        sudo systemctl enable docker
        sudo systemctl enable nginx
        sudo systemctl restart docker
}

deploy(){
        docker build -t notesapp .
        docker run -d -p 8000:8000 notesapp:latest
}

echo "**********************DEPLOYMENT STARTED**************************"

if ! code_clone ; then
        echo "CODE ALREADY EXISTS!!!!!!"
        cd django-notes-app
fi

if ! install_req ; then
        echo "INSTALLATION FAILED!!!!!!"
         exit 1
fi

if ! required_restart ; then
        echo "SYSTEM FAULT IDENTIFIED!!!!!!!"
        exit 1
fi

if ! deploy ; then
        echo "DEPLOYMENT ISSUE!!!!!!!!!"
        exit 1
fi

echo "!!!!!!!!!!!!!!!!!!!!!!DEPLOYEMENT DONE!!!!!!!!!!!!!!!!!!!!!!"