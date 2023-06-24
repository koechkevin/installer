FROM nginx:1.13.7-alpine

ARG API_PORT
ARG REACT_APP_PORT
ENV API_PORT=$API_PORT
ENV REACT_APP_PORT=$REACT_APP_PORT

RUN mkdir -p /app

WORKDIR /app

RUN apk update && apk add --no-cache gettext
COPY ./nginx.conf nginx.conf
RUN envsubst '${API_PORT} ${REACT_APP_PORT}' < nginx.conf > /etc/nginx/conf.d/default.conf
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

