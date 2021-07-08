#! /bin/ash

if test ! -f "/bootstrap/bootstrap"; then
  #lerna bootstrap

  # This provides an init-contianer-like experience on docker-compose, which
  # doesn't natively support init containers.
  today=$(date +"%Y-%m-%d")

  echo "${today}" > /bootstrap/bootstrap

  # Generate private key and cert for CA:
  openssl req -x509 -new -newkey rsa:4096 -nodes \
    -subj "/C=US/ST=FL/L=Boreville/O=Dis/CN=ca.shifti.us" \
    -days 1825 \
    -keyout /ca/ca-ex.key \
    -out /ca/ca-ex.pem

  # Create client subdir
  mkdir -p /ca/clientcert

  # Generate a sample client certificate:

  ### Key and CSR
  openssl x509 -req -new -newkey rsa:4096 -nodes \
    -subj "/C=US/ST=FL/L=Boreville/O=Dis/CN=client.shifti.us/emailAddress=client@shifti.us" \
    -days 365 \
    -extfile /ca/client_cert_ext.cnf \
    -CA /ca/ca-ex.pem \
    -CAkey /ca/ca-ex.key \
    -keyout /ca/client-ex.key \
    -out /ca/client-ex.pem


fi

sleep infinity