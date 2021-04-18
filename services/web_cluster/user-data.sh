#!bin/bash

os_release = $(lsb_release -a)

cat > /home/ubuntu/index.html <<EOF
<h1>Hello, Ubuntu!</h1>
<p> Env: ${os_release}</p>
<br>
<p>DB Address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF

busybox httpd -p ${user_data_server_port} -h /home/ubuntu/
