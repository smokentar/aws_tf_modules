#!bin/bash

cat > /home/ubuntu/index.html <<EOF
<h1>Hello, World!</h1>
<p>DB Address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF

busybox httpd -p ${user_data_server_port} -h /home/ubuntu/
