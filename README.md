# 分发节点配置指南

常用链接：[联系我们](https://github.com/CampusVideo/forwarder/blob/master/contact.md) | [防火墙配置指南](https://github.com/CampusVideo/forwarder/blob/master/firewall.md)

## 报备节点地址

为了保护视频源服务，视频源设置有访问白名单列表以限制访问范围防止滥用。**在使用以下配置（无论是自动安装脚本还是手工操作）之前，请您先 [联系我们](https://github.com/CampusVideo/forwarder/blob/master/contact.md) 向我们提供您的服务器拟使用的 IP 地址，以便我们为您开通访问权限。否则您将无法完成安装步骤中的配置文件下载过程与后续的视频源访问操作。**

## 自动安装脚本

为了方便使用，提供了基于全新安装的 CentOS 7/8 操作系统下的自动安装配置脚本。

您可在操作系统安装完成并且成功配置网络连接后通过以下方式使用：

```bash
sh -c "$(curl -sSL https://raw.githubusercontent.com/CampusVideo/forwarder/master/installer.sh)"
```

在自动安装脚本执行完成后，您只需要手工配置防火墙即可。防火墙配置方法可参阅我们的文档：[防火墙配置指南](https://github.com/CampusVideo/forwarder/blob/master/firewall.md)

如果您需要自己手工操作，可参阅下方的步骤介绍。自动安装脚本执行的操作与以下步骤相同。

## 手工操作步骤

### 1. 安装操作系统并配置网络连接

请在您的服务器上全新安装 CentOS 7/8 操作系统。安装过程中 Software Selection 选项建议选择 Minimal Install 。

*如有其它喜好与需要，您亦可自行选用其它基于 Linux 内核的操作系统，但下述步骤的具体操作命令可能会不同。*

请在安装过程中或安装完成后配置系统的网络连接，使其能够正常访问互联网。

### 2. 安装所需软件包

请登录操作系统后，在终端执行以下命令，以安装需要使用的软件包。

```bash
yum install wget net-tools net-snmp chrony epel-release -y
yum install nginx -y
```

### 3. 关闭 SELinux

您可以通过关闭 SELinux 来避免可能出现的一些权限问题。

该步骤为可选步骤，但如果您选择不关闭 SELinux ，可能需要手工解决后续可能出现的权限问题。

操作步骤如下：

* 将当前实例的 SELinux 置为被动模式：

```bash
setenforce 0
```

* 修改配置文件在重新启动后禁用 SELinux ：

```bash
sed -i "s/SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
```

### 4. 开启 NTP 与 SNMP

NTP 服务用于通过网络时钟服务校准您的服务器系统时间；SNMP 服务用于分发平台网管采集您的服务器网络信息绘制分发平台拓扑与流量图。建议您开启这两项服务。

**自动安装脚本与下列命令使用统一的 SNMP 团体名。考虑到安全性问题，您可以修改为自定义的团体名，或限制只允许平台网管的 IP 地址访问。您可以 [联系我们](https://github.com/CampusVideo/forwarder/blob/master/contact.md) 获得平台网管服务器地址，或将更改后的 SNMP 团体名告知我们。**

```bash
#向 SNMP 配置文件添加团体名
echo "rocommunity CampUsVidEo" >> /etc/snmp/snmpd.conf

#启用 SNMP 服务
systemctl start snmpd
systemctl enable snmpd

#启用 NTP 服务
systemctl start chronyd
systemctl enable chronyd
```

### 5. 配置 Nginx

推荐您使用我们提供的 Nginx 配置文件：

* 北邮视频源（IPv4）：<http://202.112.62.138/nginx-bupt-4.conf>

* 北邮视频源（IPv6）：<http://202.112.62.138/nginx-bupt-6.conf>

下载相应配置文件后，使用其替换 `/etc/nginx/nginx.conf` 文件即可。

```bash
url="http://202.112.62.138/nginx-$source-$protocol.conf"
wget -O nginx.conf.forwarder $url
cp -f nginx.conf.forwarder /etc/nginx/
mv -f /etc/nginx/nginx.conf.forwarder /etc/nginx/nginx.conf
```

配妥 Nginx 配置文件后，启动 Nginx 服务：

```bash
systemctl start nginx
systemctl enable nginx
```

### 6. 配置防火墙

完成以上操作后，您的业务已经配置完成。

但是由于尚未进行防火墙配置，外部系统可能尚不能访问您的业务。您需要参照 [防火墙配置指南](https://github.com/CampusVideo/forwarder/blob/master/firewall.md) 配置防火墙，允许白名单地址访问您服务器80端口的视频业务。

## 后续配置：建设服务节点

本文档描述的内容为建设用于从上游源获取节目流内容并向其他节点提供源转发服务的转发节点。该节点不对最终观看用户提供服务。

播放服务节点的建设文档正在整理中，如您需要建设服务节点向校内用户提供服务，可先参阅 [清华大学开发的IPTV前端](https://github.com/tvly/tvly-web) 或在平台 QQ 、微信群内咨询，也可以选用 [网瑞达公司的商用产品](https://www.wrdtech.com/content/content.php?p=2_30_199) 。
