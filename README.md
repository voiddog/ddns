# 一个 DDNS 程序

支持：
* Godaddy
* 其它没有，懒得写

## 使用
```bash
dart "bin/ddns.dart" -c config.json
```

所有内容都在配置文件: config.json
```json
{
    "ip": {},
    "godaddy": {
        "domain": "your domain",
        "records": "your record",
        "key": "your godaddy key", // godaddy key: https://developer.godaddy.com/keys#
        "secret": "your godaddy secret",
        "error_mails": [
            "your email(receive error)"
        ]
    },
    "mail": {
        "username": "send email",
        "password": "send email password",
        "smtp_host": "send email smtp server host",
        "smtp_port": 0, // send email smtp port
        "ssl": true // if use ssl
    }
}
```