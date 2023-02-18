FROM nginx

ENV NGINX_INCLUED_CONFIG_DIR /etc/nginx/conf.d




# Grab dependencies
FROM node:11.1.0-alpine
RUN apk add --update --no-cache git
RUN npm config set unsafe-perm true \
    && npm install hexo-cli -g 

# Create hexo base files
RUN hexo init /usr/share/nginx/html
WORKDIR /usr/share/nginx/html

RUN mv /usr/share/nginx/html/nginx-server.conf $NGINX_INCLUED_CONFIG_DIR/default.conf

CMD hexo generate && nginx -g "daemon off;"
