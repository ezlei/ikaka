FROM python:3.7.4-alpine3.10

WORKDIR /opt/ikala

ADD . /opt/ikala/
RUN pip install -r requirement.txt

ENTRYPOINT ["python", "/opt/ikala/app.py"]

EXPOSE 5000
