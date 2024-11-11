# set up docker rootless enable api via tcp quick start
# assumes ubuntu 23 or 24, can be modified for other *nix deployments

# clean up any old docker stuff
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
# install pre-req
sudo apt-get install -y dbus-user-session 
sudo apt-get install -y uidmap
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# run the rootless install packaged with docker
/usr/bin/dockerd-rootless-setuptool.sh install

# make sure cant accidentally run rooted
sudo systemctl disable containerd
sudo systemctl disable docker
sudo systemctl mask docker
sudo systemctl mask containerd

#generate certs for tls encryption of api
#generate CA
openssl req -x509 -newkey rsa:4096 -days 360 -nodes -keyout ca-key.pem -out ca-cert.pem -subj "/C=COUNTRY/ST=STATE/L=Location/O=Self/OU=docker/CN=hostname.example.com/emailAddress="
#generate docker api server priv key and csr
openssl req -newkey rsa:4096 -keyout server-key.pem -nodes -out server-req.pem -subj "/C=COUNTRY/ST=STATE/L=Location/O=Self/OU=docker/CN=hostname.example.com/emailAddress="
# generate alt names file for cert
echo "subjectAltName=DNS:hostname,DNS:hostname.example.com,IP:192.168.1.2" > server-ext.cnf
#generate docker api server cert
openssl x509 -req -in server-req.pem -days 360 -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile server-ext.cnf
#verify
openssl verify -CAfile ca-cert.pem server-cert.pem
openssl x509 -in server-cert.pem -text -noout
#put certs into folder for api server
mkdir /home/name/.docker/certs
cp -v ca-cert.pem /home/name/.docker/certs/
cp -v server-cert.pem /home/name/.docker/certs/
cp -v server-key.pem /home/name/.docker/certs/

# setup to allow api via tcp
mkdir /home/name/.config/systemd/docker
#copy daemon.json from source or edit manually to your user's home directory :eg /home/name/.config/systemd/docker/daemon.json
#{
#  "hosts": ["unix:///run/user/1000/docker.sock", "tcp://0.0.0.0:2376"],
#  "tlsverify": true,
#  "tlscacert": "/home/name/.docker/certs/ca-cert.pem",
#  "tlscert": "/home/name/.docker/certs/server-cert.pem",
#  "tlskey": "/home/name/.docker/certs/server-key.pem"
#}
sudo cp -v daemon.json /home/name/.config/systemd/docker/daemon.json

#vi ~/.config/systemd/user/docker.service (or copy file from source pack)
#Environment=DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS="-p 0.0.0.0:2376:2376/tcp"
#ExecStart=/usr/bin/dockerd-rootless.sh -H unix:///run/user/1000/docker.sock -H tcp://0.0.0.0:2376 --tlsverify --tlscacert=/home/name/.docker/certs/ca-cert.pem --tlscert=/home/name/.docker/certs/server-cert.pem --tlskey=/home/name/.docker/certs/server-key.pem
sudo cp docker.service /home/name/.config/systemd/user/docker.service

# After all config file edits (or copies)
systemctl --user daemon-reload
systemctl --user start docker
systemctl --user status docker
journalctl -u docker.service

# Example to verify docker info works against API encrypted by TLS
docker --tlsverify --tlscacert /home/name/.docker/certs/ca-cert.pem --tlscert /home/name/.docker/certs/server-cert.pem --tlskey /home/name/.docker/certs/server-key.pem -H hostname.example.com:2376 info