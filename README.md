# NGINX Client Certificate Authentication/Verification (mTLS)

NGINX can be used to authenticate/verify clients using x509 client certificates and, if desired, forward the client certificate [post verification] to an IDP or other policy engine for further authorization.

## Prerequisites

- docker 20.10.6+
- docker-compose 1.29.1+
- Access to Iron Bank ([Registration is open to everyone](https://sso-info.il2.dso.mil/new_account.html))

## Usage

1. Clone the repository
```
git clone https://github.com/liveaverage/docker-nginx-cac-x509.git; cd docker-nginx-cac-x509
```
2. Login to Iron Bank
```
docker login registry1.dso.mil
## Enter your username/CLI secret from: https://registry1.dso.mil/harbor/projects
```
3. Start the containers
```
docker-compose up
```
4. In another terminal, `cd` to the repo directory and execute the following (as output by the bootstrap container)
```
## Quick test WITHOUT MUTUAL TLS (Returns 400):
curl --cacert ./ca/ca-ex.pem --resolve ca.shifti.us:8443:127.0.0.1 https://ca.shifti.us:8443
```
To access NGINX with client certificate auth
```
## Quick test WITH MUTUAL TLS (Returns 200):
curl --cert ./ca/clientcert/client.pem --key ./ca/clientcert/client.key --cacert ./ca/ca-ex.pem --resolve ca.shifti.us:8443:127.0.0.1 https://ca.shifti.us:8443
```

> If you'd like to test client certificate authentication/verification in you browser you can import the generated `client.pfx` (within the `ca/clientcert` directory) into Chrome/[Firefox](https://support.globalsign.com/digital-certificates/digital-certificate-installation/install-client-digital-certificate-firefox-windows)/Safari. **The default passphrase associated with the generated `client.pfx` file is `changeme`** 


# Additional Information

- http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_verify_client