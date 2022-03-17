{
  "log": {
    "loglevel": "warning",
    "error": "/var/log/xray/access4.log",
    "access": "/var/log/xray/error.log"
  },
  "inbounds": [
    {
      "port": 2089,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "031289e0-787f-4d24-8da5-a0df7f5b3b15"
#vlessgrpc
### lifetime 2023-03-16
},{"id": "b38d52c8-661c-4acb-97d7-3ea2c3c5d9f9","email": "lifetime"
### danny 2022-04-18
},{"id": "4c1eef35-05c7-4acc-86f8-26fbfa222c40","email": "danny"
### danios 2022-04-18
},{"id": "fb7a53a6-9cd7-4efe-8744-a5d96fe318a8","email": "danios"
### dani 2022-04-18
},{"id": "2f8edfcb-43c6-454a-bca1-e323b3ab577f","email": "dani"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "grpc",
        "security": "none",
        "grpcSettings": {
          "serviceName": "GunService"
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
