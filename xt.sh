{
  "log": {
    "access": "/var/log/xray/access.log",                                                                                   "error": "/var/log/xray/error.log",                                                                                     "loglevel": "info"
  },
  "inbounds": [
    {                                                                                                                         "port": 443,                                                                                                            "protocol": "vless",                                                                                                    "settings": {                                                                                                             "clients": [                                                                                                              {                                                                                                                         "id": "11fc4832-8cb9-4458-a3fb-ef2901717b86",                                                                           "flow": "xtls-rprx-direct"                                                                                  #XRay
          }                                                                                                                     ],
        "decryption": "none",
        "fallbacks": [                                                                                                            {
            "dest": 60000,                                                                                                          "alpn": "",                                                                                                             "xver": 1                                                                                                             },                                                                                                                      {                                                                                                                         "dest": 60001,
            "alpn": "h2",
            "xver": 1
          }
        ]
      },                                                                                                                      "streamSettings": {                                                                                                       "network": "tcp",                                                                                                       "security": "xtls",                                                                                                     "xtlsSettings": {                                                                                                         "minVersion": "1.2",                                                                                                    "certificates": [
            {
              "certificateFile": "/etc/v2ray/v2ray.crt",                                                                              "keyFile": "/etc/v2ray/v2ray.key"                                                                                     }                                                                                                                     ]                                                                                                                     }                                                                                                                     },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",                                                                                                                 "tls"                                                                                                                 ]                                                                                                                     }                                                                                                                     }                                                                                                                     ],                                                                                                                      "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
