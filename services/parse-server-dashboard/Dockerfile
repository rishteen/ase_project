FROM node:latest


RUN mkdir parse

ADD . /parse
WORKDIR /parse

RUN npm install -g parse-dashboard

CMD ["parse-dashboard","--config","parse-dashboard-config.json","--allowInsecureHTTP" ,"true"]

