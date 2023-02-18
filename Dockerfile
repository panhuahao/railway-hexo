FROM node:11.1.0-alpine

RUN apk add --update --no-cache git
RUN npm config set unsafe-perm true \
    && npm install hexo-cli -g

WORKDIR /Hexo

# 全局安装hexo，设置软连接
RUN npm install -g hexo && ln -sb /usr/nodejs/bin/hexo /usr/local/bin/
# 安装依赖
RUN npm install
# 生成静态页
RUN hexo clean && hexo generate
# 创建存放项目静态页面的文件夹
RUN mkdir $NGINX_HTML_DIR/app
# 移动public目录下的所有文件及文件夹到/usr/share/nginx/html/app目录下
RUN mv /Hexo/public/* $NGINX_HTML_DIR/app
# 给nginx.conf配置文件授权
RUN chmod +rw /Hexo/nginx-server.conf
# 覆盖原nginx.conf文件
RUN mv /Hexo/nginx-server.conf $NGINX_INCLUED_CONFIG_DIR/default.conf
# 收尾工作，删除不必要的文件
#RUN rm -rf /Hexo
#RUN rm -rf /usr/local/bin/*
# 删除无用软件，记得加 -y
# 不用再次暴露端口，nginx镜像已经做了
# 不要重写ENTRYPOINT和CMD！nginx镜像已经写好了！你重写如果和源nginx镜像不一样100%出问题！
