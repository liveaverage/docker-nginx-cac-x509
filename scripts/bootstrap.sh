#! /bin/bash

DIR=/tmp/ca
CDIR=${DIR}/clientcert

mkdir -p ${CDIR}


if [ ! -f ${CDIR}/client.pem ]; then

  # Generate private key and cert for CA:
  openssl req -x509 -new -newkey rsa:4096 -nodes \
    -subj "/C=US/ST=FL/L=Boreville/O=Dis/CN=ca.shifti.us" \
    -days 1825 \
    -keyout ${DIR}/ca-ex.key \
    -out ${DIR}/ca-ex.pem

  # Generate openssl conf
  cat <<EOT >> ${DIR}/openssl-ext.cnf
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate for NGINX CAC"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection
EOT

  # Generate a sample client certificate:

  ### Key and CSR
  openssl genrsa -out ${CDIR}/client.key 4096
  openssl req -new \
    -key ${CDIR}/client.key \
    -subj "/C=US/ST=FL/L=Boreville/O=Dis/CN=client.shifti.us/emailAddress=client@shifti.us" \
    -out ${CDIR}/client.csr

  ### Sign CSR with CA cert/key
  openssl x509 -req -in ${CDIR}/client.csr -CA ${DIR}/ca-ex.pem -CAkey ${DIR}/ca-ex.key \
    -out ${CDIR}/client.pem \
    -CAcreateserial \
    -days 365 \
    -sha256 \
    -extfile ${DIR}/openssl-ext.cnf

  ### Generate a PKCS12 file for easy import
  openssl pkcs12 -export -inkey ${CDIR}/client.key \
    -in ${CDIR}/client.pem \
    -passout pass:changeme \
    -name NGINX_Client_Certificate \
    -out ${CDIR}/client.pfx
fi


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "Your CA certificate and key is located in:              ${DIR}"
echo -e "Your signed client certificate and key is located in:   ${CDIR}"
echo -e "${RED}Attempt to access NGINX with client certificate auth enabled at: ${GREEN}http://localhost:8443"
echo -e "${RED}You should receive response 400 - 'No Required SSL Certificate sent'\n"

echo -e "${RED}Quick test WITHOUT MUTUAL TLS (Returns 400):"
echo -e "${NC}curl --cacert ./ca/ca-ex.pem --resolve ca.shifti.us:8443:127.0.0.1 https://ca.shifti.us:8443\n"
echo -e "${GREEN}Quick test WITH MUTUAL TLS (Returns 200):"
echo -e "${NC}curl --cert ./ca/clientcert/client.pem --key ./ca/clientcert/client.key --cacert ./ca/ca-ex.pem --resolve ca.shifti.us:8443:127.0.0.1 https://ca.shifti.us:8443\n"

echo -e "After testing rejection based on a missing client certificate, import the generated PKCS12 cert into your "

sleep infinity