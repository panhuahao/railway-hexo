FROM nginx
# 跳过缓存，因为railway无法指定docker build --no_cache参数，所以理论会一直使用缓存，
# 故无法git clone到新的仓库文件，无论仓库更新多少次railway都会使用缓存！
ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache
# 设置容器时区为上海，不然发布文章的时间是国际时间（UTC），也就是比我们晚8个小时
ENV TZ=Asia/Shanghai
# 设置容器http代理,如果你的宿主机有代理，可以使用宿主机的局域网ipv4，
# 有用户名密码可以使用 协议://`用户名`:`密码`@`主机`:`端口`（宿主机的代理需要允许来自局域网LAN的连接）
#ENV http_proxy "http://192.168.0.102:7890"
#ENV HTTP_PROXY "http://192.168.0.102:7890"
#ENV https_proxy "http://192.168.0.102:7890"
#ENV HTTPS_PROXY "http://192.168.0.102:7890"
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
# 可选，设置git代理，按道理只要上面设置了代理就是全局生效，如果你不起作用这个也可以设置上
#RUN git config --global http.proxy "http://192.168.0.102:7890"
#RUN git config --global https.proxy "http://192.168.0.102:7890"
# 下载nodejs二进制发布包
RUN wget https://nodejs.org/dist/v16.15.0/node-v16.15.0-linux-x64.tar.xz -O nodejs.tar.xz
RUN tar -xvf nodejs.tar.xz
RUN rm nodejs.tar.xz
RUN mv node-v16.15.0-linux-x64 nodejs
# 建立软连接，变为全局
RUN ln -sb /usr/nodejs/bin/node /usr/local/bin/
RUN ln -sb /usr/nodejs/bin/npm /usr/local/bin/
FROM node:11.1.0-alpine

RUN apk add --update --no-cache git
RUN npm config set unsafe-perm true \
    && npm install hexo-cli -g
RUN cd /usr/
RUN mkdir forhexo
RUN hexo init blog
RUN cd blog
RUN hexo server
RUN hexo new "Hello Hexo"
RUN hexo generate
WORKDIR /usr/forhexo/blog/


RUN mkdir $NGINX_HTML_DIR/app
# 移动public目录下的所有文件及文件夹到/usr/share/nginx/html/app目录下
RUN mv /usr/forhexo/blog/public/* $NGINX_HTML_DIR/app
# 给nginx.conf配置文件授权
RUN chmod +rw /usr/forhexo/blog/nginx-server.conf
# 覆盖原nginx.conf文件
RUN mv /usr/forhexo/blog/nginx-server.conf $NGINX_INCLUED_CONFIG_DIR/default.conf
# 收尾工作，删除不必要的文件
#RUN rm -rf /Hexo
#RUN rm -rf /usr/local/bin/*
# 删除无用软件，记得加 -y
# 不用再次暴露端口，nginx镜像已经做了
# 不要重写ENTRYPOINT和CMD！nginx镜像已经写好了！你重写如果和源nginx镜像不一样100%出问题！
