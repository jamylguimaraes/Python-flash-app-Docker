FROM python:3.8-slim-buster

COPY app/ app/
COPY app/templates app/templates/
COPY app/static/js app/static/js/
COPY app/static/css app/static/css/
COPY gunicorn.sh app/
WORKDIR app/
RUN pip3 install -r requirements.txt
EXPOSE 8000
ENTRYPOINT ["./gunicorn.sh"]
