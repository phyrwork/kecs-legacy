#!/bin/bash

mount /mnt/kecs ;
chown -R mysql:mysql /mnt/kecs/* ;
service mysql start ;