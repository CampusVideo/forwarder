# 分发节点防火墙配置指南

## 建议实践

本文以 CentOS 7/8 操作系统为例。该系统使用的防火墙组件为 firewalld 。

HLS 协议视频流基于 HTTP 协议传输，使用80端口。建议对80端口配置防火墙规则，只允许已知的下游取源节点访问，不允许其他地址访问。

在配置防火墙规则时，建议通过 ipset 建立 IP 地址列表，通过单条防火墙规则来允许访问，而不是添加多条防火墙规则，以减少防火墙的性能开销。

## 操作步骤

### 0. 确认防火墙运行状态

在服务器执行如下命令：

```bash
firewall-cmd --state
```

如果返回结果为 `running` 即表示防火墙处于运行状态。

如果结果为 `not running` ，请使用以下命令开启：

```bash
systemctl start firewalld
systemctl enable firewalld
```

### 1. 建立 ipset 集合

IPv4 与 IPv6 的 ipset 集合需要分别建立。

* IPv4
    
```bash
firewall-cmd --permanent --new-ipset=whitelist --type=hash:net
```

* IPv6

```bash
firewall-cmd --permanent --new-ipset=whitelist6 --type=hash:net --option=family=inet6
```

这样就分别对 IPv4 与 IPv6 建立了 ipset 集合。其中前者的集合名为 whitelist ，后者为 whitelist6 。

### 2. 编辑集合内容

向集合添加 IP 地址或者 CIDR 区块时，需将对应协议的地址添加到对应协议的 ipset 集合中。

```bash
firewall-cmd --permanent --ipset=集合名 --add-entry=地址或CIDR
```

如需查看集合内容，可使用如下命令：

```bash
firewall-cmd --permanent --ipset=集合名 --get-entries
```

删除集合中某个条目的操作如下：

```bash
firewall-cmd --permanent --ipset=集合名 --remove-entry=地址或CIDR
```

### 3. 将集合添加到防火墙区域

在本示例中，我们使用防火墙的 work 区域

* 将 ipset 添加为区域的 source

```bash
firewall-cmd --permanent --zone=work --add-source=ipset:集合名
```

如果同时使用IPv4 与 IPv6 的 ipset ，需在这里将二者都添加进来。

* 将 http 添加为区域的 service

```bash
firewall-cmd --permanent --zone=work --add-service=http
```

### 4. 重新加载防火墙规则使其生效

```bash
firewall-cmd --reload
```

在这一步骤后，您配置的 ipset 中的地址应当已经可以访问您服务器的80端口了。

需要注意的是，如果您后续更改了防火墙配置，比如添加了新的 IP 地址到 ipset 集合中，需要再次执行重新加载命令使得改动生效。
