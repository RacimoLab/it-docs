UniCPH uses a Cisco AnyConnect vpn server. To connect, you'll first
need to install a Cisco AnyConnect client. Note that as of Sept 2021,
there is scattered information about this process on kunet,
but much of it is outdated, incorrect, or just plain doesn't work.
In particular, few users were able to navigate to `https://vpn.ku.dk/`
or `https://vpn.sund.ku.dk/` in a web browser and log on.

# Installation

## Cisco AnyConnect client (Windows/MacOS)

For Windows and MacOS users, download and install the Cisco client from,
e.g. https://www.uc.edu/about/ucit/services/connectivity-fac-staff/vpn.html
(and follow the instructions there). Note that this software is proprietary
and Cisco explicitly do not provide downloadable files from their own site.

## OpenConnect (Linux)

While Cisco also provide an AnyConnect client for Linux, it is usually
easiest to install [`openconnect`](https://www.infradead.org/openconnect/)
on a Linux system, as this is directly installable using the native package
manager in most Linux distributions
(e.g. `sudo apt install openconnect` on Ubuntu).

# Connect to `vpn.ku.dk`

## Cisco AnyConnect (Windows/MacOS)

Write `vpn.ku.dk` into the field and "connect", using your KU user id
and password. This will trigger a multi-factor authentication request
(e.g. in the "NetIQ Advanced Authentification" app on your phone),
which must be accepted to complete the login.

## OpenConnect (Linux)

Connect to `vpn.ku.dk` with the `openconnect` command.

```
openconnect -u <userid> vpn.ku.dk
```

This will prompt for your KU password. After successfully entering
your password, this will trigger a multi-factor authentication request
(e.g. in the "NetIQ Advanced Authentification" app on your phone),
which must be accepted to complete the login. After successful connection,
the terminal will show something like the following.

```
$ openconnect -u <userid> vpn.ku.dk
POST https://vpn.ku.dk/
Connected to 130.225.226.60:443
SSL negotiation with vpn.ku.dk
Connected to HTTPS on vpn.ku.dk with ciphersuite (TLS1.2)-(RSA)-(AES-256-CBC)-(SHA1)
Server requested SSL client certificate; none was configured
POST https://vpn.ku.dk/
XML POST enabled
Please enter your username and password.
Password:
POST https://vpn.ku.dk/
Got CONNECT response: HTTP/1.1 200 OK
CSTP connected. DPD 30, Keepalive 20
Connected as 10.74.199.76, using SSL, with DTLS in progress
Established DTLS connection (using GnuTLS). Ciphersuite (DTLS0.9)-(RSA)-(AES-256-CBC)-(SHA1).
```
