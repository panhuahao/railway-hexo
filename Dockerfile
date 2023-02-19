FROM nginx
# 跳过缓存，因为railway无法指定docker build --no_cache参数，所以理论会一直使用缓存，
# 故无法git clone到新的仓库文件，无论仓库更新多少次railway都会使用缓存！
ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache
# 设置容器时区为上海，不然发布文章的时间是国际时间（UTC），也就是比我们晚8个小时
ENV TZ=Asia/Shanghai

# 设置nginx html目录环境变量
ENV NGINX_HTML_DIR /usr/share/nginx/html
# 设置nginx配置文件包含路径环境变量
ENV NGINX_INCLUED_CONFIG_DIR /etc/nginx/conf.d
WORKDIR /usr/
# 提醒大家最好不要用 && \ 或 & \ 来一个RUN执行特别多条命令，容易排错困难
# 更新依赖
RUN apt update
# 安装wget，记得加 -y
RUN apt install -y wget
# 安装xz解压缩工具 xz-utils
RUN apt install -y xz-utils
# 安装git
RUN apt install -y git
# 安装vim
RUN apt install -y vim

# 下载nodejs二进制发布包
RUN wget https://nodejs.org/dist/v16.15.0/node-v16.15.0-linux-x64.tar.xz -O nodejs.tar.xz
RUN tar -xvf nodejs.tar.xz
RUN rm nodejs.tar.xz
RUN mv node-v16.15.0-linux-x64 nodejs
# 建立软连接，变为全局
RUN ln -sb /usr/nodejs/bin/node /usr/local/bin/
RUN ln -sb /usr/nodejs/bin/npm /usr/local/bin/


RUN npm install hexo-cli -g && ln -sb /usr/nodejs/bin/hexo /usr/local/bin/
# Create hexo base files
RUN hexo init /hexo
RUN hexo generate


WORKDIR /usr/share/nginx/html
COPY --from=0 /hexo/blog/public .

ENTRYPOINT ["nginx", "-g", "daemon off;"]

