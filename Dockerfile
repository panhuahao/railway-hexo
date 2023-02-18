FROM nginx

ENV NGINX_INCLUED_CONFIG_DIR /etc/nginx/conf.d




# Grab dependencies
RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup | bash - && apt-get update && apt-get install -y curl git nodejs
RUN npm install -g hexo-cli

# Create hexo base files
RUN hexo init /usr/share/nginx/html
WORKDIR /usr/share/nginx/html
RUN npm install
RUN mv /usr/share/nginx/html/nginx-server.conf $NGINX_INCLUED_CONFIG_DIR/default.conf

CMD hexo generate && nginx -g "daemon off;"
