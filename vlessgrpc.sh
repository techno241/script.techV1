{
  "log": {
    "loglevel": "warning",
    "error": "/var/log/v2ray/error.log", //若使用xray，此处目录名称v2ray改成xray。
    "access": "/var/log/v2ray/access.log" //若使用xray，此处目录名称v2ray改成xray。
  },
  "inbounds": [
    {
      "listen": "127.0.0.1", //只监听本机，避免本机外的机器探测到下面端口。
      "port": 2009, //vless+grpc监听端口
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "058e0bf3-dd56-11e9-aa37-5600024c1d6a", //修改为自己的UUID
            "email": "2009@gmail.com"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "grpc",
        "security": "none",
        "grpcSettings": {
          "serviceName": "cdngrpc" //修改为自己的服务名称，类似于HTTP/2中的Path。
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "protocol": [
          "bittorrent"
        ],
        "outboundTag": "blocked"
      }
    ]
  },
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "tag": "blocked",
      "protocol": "blackhole",
      "settings": {}
    }
  ]
}
