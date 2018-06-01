#!/bin/bash
cat > index.html <<EOF 
<H1>Its running</H1>
<p>DB address : ${db_address}</p>
<p>DB port    : ${db_port}</p>
EOF
echo '<H1>Instance</H1><p>Responding instance : ' >> index.html
curl http://169.254.169.254/latest/meta-data/instance-id >> index.html
nohup busybox httpd -f -p "${server_port}" &