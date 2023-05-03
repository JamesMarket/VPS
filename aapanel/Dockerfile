FROM debian:11.7

# 安装必要的软件包
RUN apt-get update \
    && apt-get install -y wget sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# 安装 aapanel
RUN wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && \
    sh install.sh debian 11 64 -y && \
    rm -f install.sh


# 修改 aapanel 配置
RUN sqlite3 /www/server/panel/data/default.db "update bt_default_panel set username='JamesMarket' where id=1" \
    && sqlite3 /www/server/panel/data/default.db "update bt_default_panel set password='James8823@' where id=1"

# 启动服务
CMD ["/bin/bash", "-c", "service bt start && tail -f /dev/null"]