FROM python:3.7.4-alpine3.10

ADD . /opt/ikala/
WORKDIR /opt/ikala

RUN pip install -r requirement.txt

CMD python /opt/ikala/app.py

EXPOSE 5000
