#!/bin/sh
gunicorn --bind=0.0.0.0 --timeout 600 --log-level debug app
