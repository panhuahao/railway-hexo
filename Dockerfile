FROM nginx:apline
# 跳过缓存，因为railway无法指定docker build --no_cache参数，所以理论会一直使用缓存，
# 故无法git clone到新的仓库文件，无论仓库更新多少次railway都会使用缓存！
ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache
# 设置容器时区为上海，不然发布文章的时间是国际时间（UTC），也就是比我们晚8个小时
ENV TZ=Asia/Shanghai

# 设置nginx html目录环境变量
ENV NGINX_HTML_DIR /usr/share/nginx/html
# 设置nginx配置文件包含路径环境变量
ENV NGINX_INCLUED_CONFIG_DIR /etc/nginx/conf.d


RUN npm install hexo-cli -g && ln -sb /usr/nodejs/bin/hexo /usr/local/bin/
# Create hexo base files
RUN hexo init /usr/share/hexo
RUN hexo generate


#WORKDIR /usr/share/nginx/html
#COPY --from=0 /usr/share/hexo/blog/public .

