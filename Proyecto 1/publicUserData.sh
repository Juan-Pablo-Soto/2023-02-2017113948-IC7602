#!/bin/bash
    sudo apt-get update

    sudo apt install apache2 -y
    echo "<h1>Hello world!</h1><h2>Mi apache publico!</h2>" | sudo tee /var/www/html/index.html

    sudo sed -i 's/Listen 80/Listen 443/' /etc/apache2/ports.conf #Para poder acesar al apache publico sin usar puerto 80
    sudo service apache2 restart

    #echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-ip-forward.conf
    #sudo sysctl -p /etc/sysctl.d/99-ip-forward.conf

    #sudo iptables --table nat --append PREROUTING --protocol tcp --destination 10.0.0.0.20 --dport 80 -o eth0 --jump DNAT --to-destination 10.0.128.0.20 -j MASQUERADE
    #sudo iptables --table nat --append POSTROUTING --protocol tcp --destination 10.0.128.0.20 --dport 80 -o eth1 --jump SNAT --to-source 10.0.0.0.20 -j MASQUERADE

    #sudo service iptables save
    #sudo systemctl enable iptables



    sudo echo "-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAqedsOnZKD8KkWtygnIUd95+Gn6Y5wE1SWDp/ujX42UZfpOcA
+P9H7vCJnO0hfLnVAmin6SIQFujsJfIHaE3QhDMIH91rTLUq8Qv7r42hr3mok7A0
S5glLmSvJVXdHBCpUkQc+ibgFSzwCd28i4CVHGSyxJAG/7oPIrdv1Okyp6NRk8HY
K2GA/xIQ8Jh8pNYbRgwz5tR1F+bPhWAiZY+zdfVL6B4GI4ja7HtHUSyEsVUqnuvu
4VR8CoK3uxAaNGO9drrDONF3mWoyBscSimwAt7Xho+mU+ADw2wDO2tXoT3L/pOuc
LIrUsdTkYKCRCuoERH0kRVRmWfLrwM6p6sQEMQIDAQABAoIBAGvs42Tnivgj7f8B
ssx6CqUnIn77Oigbdbkxv7zrV928xDidvJJupqTzCpcyUllGOjbDgBWpW4sR/h/E
dEwfUdsIB5smLWiWlGZ19DR5xUEQCLN39GAoj0W/EzqmJkQTmVr2hWmplCIfX4ME
5SXAUfetR5lw2+FJsR+eYl1enJy7KF5Q6HTSmuCNCW7sdmPYaI6VJG6ICIhiA+N9
cRsx8lBtOYzagnQB/fuwXjL62+ZkEbnaCWrGP5Sned5MnC5w4Rv9E28pAPl67LDS
m51GJ7pwBnQSsI6h641iMyF3nhxgR3EfQlAPrcpoKsU3rMAUG1jfUspWw4HMDskJ
JorBaCECgYEA7lTTLtF6pjV3E/uH1EkDn9vy6ZjC0bRNgHAEIuIQPl6vokDw+EN/
yBwNCzKhS+2r0+BXEKwqpiAIYm8EySrNmr3jS9kqN5G2MGbVfMsqgFY/nvrxafTD
ZhMUhEa59VJo0Kp9inKyxpKuYekrSESHRyE5Xph69xZ1BqX1rmdER30CgYEAtn/y
w7va+c9yqQ4RuDXAnyk5buI3uJ1Am6788vosz/PK+ERBlc+TrmiW6GFxY4gsGWX+
mwB9V6m30vfB5uRjZ997we17DB0g2ZGubkGczUHLQ64j4u706pr460bqyxp37VGJ
yC7kVI53o0JTEbPMAgrC6DypiBqThmWvsqsW1cUCgYAySWuVwVVjpHxPlw7917oQ
DNSgPT8+CBEiPIBi69gJkOj2D0XI3FUl3+VQq4ok/yz2M6urNOh6zN94BXy5BXME
Z3SCGHwz5WbPp6L8BdId6hTacpBljuN7siLuFg4+mPjMrmx2veTCyUhKGGytfugc
NgJo1zt6zx46HOJNvjRF8QKBgQCI2m+4udFejWLFRSiig6R7dhV8giUYystdM565
skMSehYVkFHCPtPW8NVhU1kNM1smfKato3Na3olbqbD9LP0iMqOCbExebCVrIeS1
B3zHKvR7P0Xn8hs1JptNC3QcdC/EheWVeRx+EAvFIIJcfwCX82vvbTYQOyWvnedg
Sw4npQKBgQCsO/XPoa+ivN4gd84mHZzS/MxeGr0mdqtJpn+FMMI0rfHJ9snV8cUB
mvhqIufFLHddOdj0XvdadhDbPDzlbP+1eMECqTpvx2IWl3mNIEkQLYawlvmb74H8
aAtGDOoyZB31N916YGzYKtjR5VXCDS5S0M/xtob4o6aatBS/0mAH+w==
-----END RSA PRIVATE KEY-----" > /home/ubuntu/testKey
    sudo chmod 600 /home/ubuntu/testKey