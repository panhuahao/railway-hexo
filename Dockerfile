FROM nginx


ADD default.conf /etc/nginx/conf.d/default.conf



# Grab dependencies
RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup | bash - && apt-get update && apt-get install -y curl git nodejs
RUN npm install -g hexo-cli

# Create hexo base files
RUN hexo init /usr/share/nginx/html
WORKDIR /usr/share/nginx/html
RUN npm install

CMD hexo generate && nginx -g "daemon off;"
