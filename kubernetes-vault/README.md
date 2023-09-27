### Operator Init vaults

/ $ vault operator init
Unseal Key 1: oDKZiqX5TbkefmV3bAS2VXjuCr3Y1sydYvGvSO7YzBnQ
Unseal Key 2: bHxC2ZMwTE0KCQE/fVkU9IZ87Tsj4yhU9RfdbbiggBo+
Unseal Key 3: 60tjAAgQz3nXqfmGK2qXtlRPJPWY8cwryRsz+gAxqyqQ
Unseal Key 4: 6NQ7lVuYW2qDXTb4JPDifwKoLAKdhyu4+0Vwvdfl7Znp
Unseal Key 5: ZjJnd1UPJk81RxvM4GO0g81CXpI4kwYC6hc39Wwl1CJY

Initial Root Token: hvs.JVy3vdAVAAv7UatuZlDyG08t

vault operator raft join http://vault-0.vault-internal:8200
vault operator unseal

/ $ vault operator raft list-peers
Node                                    Address                        State       Voter
----                                    -------                        -----       -----
8d2cd3a4-cf0f-fec4-e93f-e862442e5eea    vault-0.vault-internal:8201    leader      true
ec33333e-05a8-94b5-a6db-64931f41eef4    vault-1.vault-internal:8201    follower    true
f6892790-4f26-d8cf-a1fd-ff5949cb6ef5    vault-2.vault-internal:8201    follower    true

### Create vault policy
vault policy write read-write-secret - <<EOF
path "otus/otus-ro/*" {
capabilities = ["read", "list"]
}

path "otus/otus-rw/*" {
capabilities = ["read", "create", "list"]
}

path "auth/token/renew-self" {
capabilities = ["update"]
}
EOF

### Create k8s auth
vault auth enable kubernetes

vault write auth/kubernetes/config \
kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443 \
issuer="https://kubernetes.default.svc.cluster.local"

### Create Role
vault write auth/kubernetes/role/read-write-secret \
bound_service_account_names=vault-auth \
bound_service_account_namespaces=* \
policies=read-write-secret \
alias_name_source=serviceaccount_name \
ttl=1h

create pod with serviceaccount vault-auth
enter shell
apk add curl jq

curl --request POST --data '{"jwt": "'$KUBE_TOKEN'", "role": "read-secret"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq
{
"request_id": "d3c250a7-ce9a-b3f4-895d-200b4f48faef",
"lease_id": "",
"renewable": false,
"lease_duration": 0,
"data": null,
"wrap_info": null,
"warnings": null,
"auth": {
"client_token": "hvs.CAESIEmuoY5rXtE1jXlCxR2owDUEldjONteoq5tcTC0bnlh7Gh4KHGh2cy5BakhoUW9udDRkbk1DbUIyN3hxWElnTzg",
"accessor": "sGpgPQjdHHVbI5awel0DiaB3",
"policies": [
"default",
"read-write-secret"
],
"token_policies": [
"default",
"read-write-secret"
],
"metadata": {
"role": "read-write-secret",
"service_account_name": "vault-auth",
"service_account_namespace": "default",
"service_account_secret_name": "",
"service_account_uid": "1a5f051c-9772-41a3-a697-7777b3206067"
},
"lease_duration": 3600,
"renewable": true,
"entity_id": "3d500260-68c9-ef3c-511c-bf61e63464df",
"token_type": "service",
"orphan": true,
"mfa_requirement": null,
"num_uses": 0
}
}

### get values inside from tmppod
curl --header "X-Vault-Token:$TOKEN" $VAULT_ADDR/v1/otus/otus-rw/config | jq
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
Dload  Upload   Total   Spent    Left  Speed
100   20{    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
"request_id": "3f0d31d7-8bf1-516b-0abe-5ea4b2eb8cf3",
"lease_id": "",
"renewable": false,
"lease_duration": 2764800,
"data": {
9      "password": "otuspassword",
"username": "otus"100   
},
"wrap_info": null,
"warnings": null,
"auth": null
}

### write values from pod
/ # curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token:$TOKEN" $VAULT_ADDR/v1/otus/otus-rw/config
{"errors":["1 error occurred:\n\t* permission denied\n\n"]}

### edit policy
vault policy write read-write-secret - <<EOF
path "otus/otus-ro/*" {
capabilities = ["read", "list"]
}

path "otus/otus-rw/*" {
capabilities = ["read", "create", "list", "update"]
}

path "auth/token/renew-self" {
capabilities = ["update"]
}
EOF

###

0000NBA09M4MD6M:kubernetes-vault aablago4$ kubectl exec -it vault-0 -n vault -- vault write pki_int/issue/devlab-dot-com common_name="gitlab.devlab.com" ttl="24h"
Error writing data to pki_int/issue/devlab-dot-com: Error making API request.

URL: PUT http://127.0.0.1:8200/v1/pki_int/issue/devlab-dot-com
Code: 400. Errors:

* unknown role: devlab-dot-com
### issue cert for example.com
/ $ vault write pki_int/issue/example-dot-com common_name="devlab.example.com" ttl="24h"
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDqjCCApKgAwIBAgIUAJB0Dn02f8rOJsccEnBOzi92lM4wDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLZXhtYXBsZS5jb20wHhcNMjMwOTIyMTQwMDQ5WhcNMjgw
OTIwMTQwMTE5WjAtMSswKQYDVQQDEyJleGFtcGxlLmNvbSBJbnRlcm1lZGlhdGUg
QXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7Zv8yAEJ
TInV8oqitzQ8gMmg8zprWOXGm/xj3QD7oDRdcgMftBFWl3Wcjfyjg3z9485t1g4x
5DAiql7OX0nyg9Wj6YJ7xvcGgT/FaLuU5y+1w4QqJrROFRi1S6s9s/+wCPRTw35I
pund3ozlKm24Dvu+VF99KT3Oj3SVGCoUcsl98c9U9ZLKFhFJJR6MfcYpW/n0Jfyh
aoTdlbsxxtfJz4oe6dsSMKw25ywCazwByCEkHKe4rWa2cNlM6i9tOPUPUrwgviuA
6riQshDTqdrjyYSgQ0/DQWrI/w42EWcGY4zRx2XUI9G+En3x6rWmsDcckU1C/BSy
b2h2aQIBuRgtmQIDAQABo4HYMIHVMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E
BTADAQH/MB0GA1UdDgQWBBSfFbDH+ugz2V7QyLWsb4nqjmAfnzAfBgNVHSMEGDAW
gBR0eZnOqptaEijs2GTw6Q1YQ1BfcjA9BggrBgEFBQcBAQQxMC8wLQYIKwYBBQUH
MAKGIWh0dHA6Ly92YXVsdC52YXVsdDo4MjAwL3YxL3BraS9jYTAzBgNVHR8ELDAq
MCigJqAkhiJodHRwOi8vdmF1bHQudmF1bHQ6ODIwMC92MS9wa2kvY3JsMA0GCSqG
SIb3DQEBCwUAA4IBAQAvnl7pz+YVc7/WsedzZn7fgeG5ucfH208+DfdiP+w+aDCG
9LPZg+b2V1IXX1Gsp/x9WD2M/PzgcPUxolwXxPKe3CC+gFPfpuHu+dYruBngWFhJ
yFXvJXPMg3RGa+R58R+PgXEO2xuV4jSkp5ihVmiNZrvX22kyf5owt43ijKwvpDs7
jYlP/2V2GFYqSMBPar1ulGJ41QcTDU1ZQB/8JUdzev5DlYx/7zaEdECk6eDP9mkH
1uWGVkPMbtw30whEf1w0atDSokghrJVvxEgWHqdeyZItlbcrc1WUyAdX1nhXS5fz
4AxglIT4Pl8rJ7QLRxlKI4ikRTyg39c8zc97ZXG4
-----END CERTIFICATE----- -----BEGIN CERTIFICATE-----
MIIDNTCCAh2gAwIBAgIUEn7YU37H3Q4cjbKqlwCENkzvnh0wDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLZXhtYXBsZS5jb20wHhcNMjMwOTIyMTMzMjIxWhcNMzMw
OTE5MTMzMjUxWjAWMRQwEgYDVQQDEwtleG1hcGxlLmNvbTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAKrH2HWvZDyqaqu/26E6HBV1YOUqxUz7wXKVv9bf
ea3vl8A2HiWJgKbhsiSakbfNCms4b4V2k8qXQiNNu+11hEp/glUb91HQhvis8RvB
yk8WPUbtrBP7cm4vj9AmQNwXufT7AQf69M2kZYy9oIhkS5Ws6qcrqrMlKZ6mowzw
MJEI79ova38/HOW3x9RcWSmq8IZOFw7OnG9JkvpQ3NlYrUT3gIa6BVIA0XOKCWMJ
U2itLwIdevGSRqq2CsARPdCVU7iBlof32M9BzhCrsOnCunK0HnxJW3YtiamDl2wv
1VkoJj7y+B/Y+I0c6ck8SOHN3hLgRypvbl3ZmFQHm/JLDqMCAwEAAaN7MHkwDgYD
VR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFHR5mc6qm1oS
KOzYZPDpDVhDUF9yMB8GA1UdIwQYMBaAFHR5mc6qm1oSKOzYZPDpDVhDUF9yMBYG
A1UdEQQPMA2CC2V4bWFwbGUuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQBduTZ8pIcy
ES3AOpBGBeHr8jHI/JU/SeXD/skyQRzmaN4QWc63NMxzh2yGYvCy6EWFbxuxYbnu
8dDZh2BFW4kdt1bhcroAa/uVC8+rEaX9m4m+fxz8WsgnvxmmK3ZHWCW6MiCBrw0r
2B/wInh7vcM0z5mytDSW+5ii8CmGIUHvKtAyr/GrwbzRYsbWn5RHcMEbgf4/7Q3i
SrijeH7HvDK/nFfl1rfslK9dRdFNEMqkvCtMrAj1FFlXcJLnWZMpTAhdlvsV+WOr
iYn0F/3M2wVhiHtuGLz7r5iG6zRGVwjn3XgajrySTJO6wzbA0c0RabnwPLFXzT2E
f2SZgxFNQ+O2
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDajCCAlKgAwIBAgIUJRLddquEDJwXLVY5o1TBvLKYEYwwDQYJKoZIhvcNAQEL
BQAwLTErMCkGA1UEAxMiZXhhbXBsZS5jb20gSW50ZXJtZWRpYXRlIEF1dGhvcml0
eTAeFw0yMzA5MjIxNDEyNDhaFw0yMzA5MjMxNDEzMThaMB0xGzAZBgNVBAMTEmRl
dmxhYi5leGFtcGxlLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AOWPSkqwP5h/fJHv1B3pohtyaC9FXCvyinjd9cTUTyXNo0VVmqo+43RedVp9NRrb
YvWog50+iAdPuB5qDfIAcrb1s3PsnxUhPOgtdoqZxmjigGdLyiMN/slg4rDhIWJZ
u8w6mPe9nEQaEixMeg+zlyWEgGji8koOvm8Ql0lBI4i/YLPmnRtPiyta0TPeR98j
/q2RpN4S9cGwAFR1JVjCzqLKdlFRfNsjKlXY0Cxi7c80SpdCeb8R3GHJhnVbuMEG
GxDwll75xpnG0ZVJOCanSTXWgMQbhsk5RPbTv7m+myG418n0rZleYjYzdlQvP0nx
MmaFxytHPmFSbgvycn4TDXUCAwEAAaOBkTCBjjAOBgNVHQ8BAf8EBAMCA6gwHQYD
VR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMB0GA1UdDgQWBBQDxkqztgC+r57Q
FxIg7ViLMjDCtTAfBgNVHSMEGDAWgBSfFbDH+ugz2V7QyLWsb4nqjmAfnzAdBgNV
HREEFjAUghJkZXZsYWIuZXhhbXBsZS5jb20wDQYJKoZIhvcNAQELBQADggEBANz8
E8n132/tWFxih7mWspXjVEsDvSk5eyUReVXylsHbYd9OS0XG1U+YQVGzrCnAbws8
9FAfP1BM0hBbOq/12lD2gVDaSbmFPOyHGe7b2VTThjI0CIk+MLr3c57/OI91ZeVZ
C+8+Z6RljcNJSlUSEzqXi/l2LPyn3xcA6MkbXImsZv4beiITx3dVj/1xOdLTRVCB
ydMR5kOdkFjBbZJK3iPuowYSVrjlkFSWtbzeQFjxTEyZluK/T1lhEPEs4CRYqBuu
sTfF5alahwYHOGyG7NUbycbim7DpTTQ0QnplQYxG5NNEI1E2U6KFTCzc2GgYAMo5
L1tXc/RRUNdPnfAijwU=
-----END CERTIFICATE-----
expiration          1695478398
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDqjCCApKgAwIBAgIUAJB0Dn02f8rOJsccEnBOzi92lM4wDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLZXhtYXBsZS5jb20wHhcNMjMwOTIyMTQwMDQ5WhcNMjgw
OTIwMTQwMTE5WjAtMSswKQYDVQQDEyJleGFtcGxlLmNvbSBJbnRlcm1lZGlhdGUg
QXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7Zv8yAEJ
TInV8oqitzQ8gMmg8zprWOXGm/xj3QD7oDRdcgMftBFWl3Wcjfyjg3z9485t1g4x
5DAiql7OX0nyg9Wj6YJ7xvcGgT/FaLuU5y+1w4QqJrROFRi1S6s9s/+wCPRTw35I
pund3ozlKm24Dvu+VF99KT3Oj3SVGCoUcsl98c9U9ZLKFhFJJR6MfcYpW/n0Jfyh
aoTdlbsxxtfJz4oe6dsSMKw25ywCazwByCEkHKe4rWa2cNlM6i9tOPUPUrwgviuA
6riQshDTqdrjyYSgQ0/DQWrI/w42EWcGY4zRx2XUI9G+En3x6rWmsDcckU1C/BSy
b2h2aQIBuRgtmQIDAQABo4HYMIHVMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E
BTADAQH/MB0GA1UdDgQWBBSfFbDH+ugz2V7QyLWsb4nqjmAfnzAfBgNVHSMEGDAW
gBR0eZnOqptaEijs2GTw6Q1YQ1BfcjA9BggrBgEFBQcBAQQxMC8wLQYIKwYBBQUH
MAKGIWh0dHA6Ly92YXVsdC52YXVsdDo4MjAwL3YxL3BraS9jYTAzBgNVHR8ELDAq
MCigJqAkhiJodHRwOi8vdmF1bHQudmF1bHQ6ODIwMC92MS9wa2kvY3JsMA0GCSqG
SIb3DQEBCwUAA4IBAQAvnl7pz+YVc7/WsedzZn7fgeG5ucfH208+DfdiP+w+aDCG
9LPZg+b2V1IXX1Gsp/x9WD2M/PzgcPUxolwXxPKe3CC+gFPfpuHu+dYruBngWFhJ
yFXvJXPMg3RGa+R58R+PgXEO2xuV4jSkp5ihVmiNZrvX22kyf5owt43ijKwvpDs7
jYlP/2V2GFYqSMBPar1ulGJ41QcTDU1ZQB/8JUdzev5DlYx/7zaEdECk6eDP9mkH
1uWGVkPMbtw30whEf1w0atDSokghrJVvxEgWHqdeyZItlbcrc1WUyAdX1nhXS5fz
4AxglIT4Pl8rJ7QLRxlKI4ikRTyg39c8zc97ZXG4
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA5Y9KSrA/mH98ke/UHemiG3JoL0VcK/KKeN31xNRPJc2jRVWa
qj7jdF51Wn01Gtti9aiDnT6IB0+4HmoN8gBytvWzc+yfFSE86C12ipnGaOKAZ0vK
Iw3+yWDisOEhYlm7zDqY972cRBoSLEx6D7OXJYSAaOLySg6+bxCXSUEjiL9gs+ad
G0+LK1rRM95H3yP+rZGk3hL1wbAAVHUlWMLOosp2UVF82yMqVdjQLGLtzzRKl0J5
vxHcYcmGdVu4wQYbEPCWXvnGmcbRlUk4JqdJNdaAxBuGyTlE9tO/ub6bIbjXyfSt
mV5iNjN2VC8/SfEyZoXHK0c+YVJuC/JyfhMNdQIDAQABAoIBAQCi8cYDI/3QSlXq
5PiEzwzRPLE1NJ+LVlryFmNYdndD1yaYlX32cDNVq6LTO2LRkH4674WUvQkjX3PK
qu8BI05KDjd2BrSY9AHesD6ffS23z2bja4msvkdnPA1NDlB7FkTWX5Wq7H0aXgMe
TJ6rvIeCCv529PiUlsiX34fzaHhHnHBjVl2e/+TLB4GaBKtcjbRjXZpRJEZ/3lVX
O4ep24IieYnClbTGv+r1vm9NpN3O98ITlusfLdVMVIsQzH7YQ6tlrG0A0mxsh/3h
qBfiorUQ3WSPJx5SHjeAUaqdvpn8Ru2Zd/0Y0wWWTIO6xuOx4F6N7KwX0MxgNt3C
KCaG3WUhAoGBAPWBTByKDFaO4ybkfh9HoMSnvTT3xnWD2Lzk6Vb97e/j2R7u3Bzz
/ij8vIw2dlMVN2s2DNuqEiWd+cX8P/bEZ5QyCmGGNPuQMETGorNU1BIe0TdEYHVa
d91s/47IGRmmZPOQkpfq/0FV2qV4CxCerpZOPcsIuuz41oMY5bNcPRrpAoGBAO9f
fm++C0zlnQXE54iN3YF7AgsUBWQ5bwyulzWJTIqJf4eld68XJP7wiEUETY+/qfTq
xAHMVJBkA5KXdIDPHz8yMhA2CIvYZLHmdm9dSwaCuxjb+z+bq0dJgHvEh9nVy0m8
+H+iRmrIFq3aWXMx+fXo50zkAtwdSblRCzDjIi6tAoGASUuW25ZjZJw4OO5SsSgD
WXLyzBOFTqRUWuDEwVICbXJK6i9Jy+MUaEw8RmgkH13gM8PpRtOZo11sqq1Ks3Oj
sNzXuJIG02wS3RWokX2r6tUEhUmGusKNsq/OBGS9Calhzk3FVlG0b18gbfJO62FU
ok8tp6YtmH4aHP2b5laNb7ECgYAz4FMrbllOmfh0tp6i9nPJytm/guBEPzo02mWE
wbOn1nKf+Bk/BdoLsh8mLe+NNrFjlblS1nCBNlub2lzySXDxJjS5VKx3ejcgYtzJ
98L5rz1S/uGtgFQXR/OjXw0+BVpgKacFKirum1xm4wo9r9gHFimCfWutPl+q3Mh7
GM5gpQKBgQDnTR4oYaTkij3X2a3/USXvuE3pry6KdPlBitW8vcxDDKCS84nbDpCq
TcgiPoEtzMzMCxj461SAVqq59I2OATQ2alB1S/QC7InhwI/U4LN1tugK+HGX5HUv
eW9umTxvDhbE4RwKLLBDphdifY53azkdQKbXo3DcoiLZjkrg5r9HCg==
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       25:12:dd:76:ab:84:0c:9c:17:2d:56:39:a3:54:c1:bc:b2:98:11:8c

### revoke cert for example.com

/ $ vault write pki_int/revoke serial_number="25:12:dd:76:ab:84:0c:9c:17:2d:56:39:a3:54:c1:bc:b2:98:
11:8c"
Key                        Value
---                        -----
revocation_time            1695392040
revocation_time_rfc3339    2023-09-22T14:14:00.265303998Z
state                      revoked

### Star task. Step 1. Prepare Certmanager, clusterissuer, ingress - done
Artifacts stored in ./vault-https

### Star task. Step 2. Enable userpass auth and create user with existing policy
vault auth enable userpass
user - testuser1
password - testpassword1

### Step 3. Get x-auth token
curl --request POST --data '{"password": "testpassword1"}' https://vault.158.160.123.161.nip.io/v1/auth/userpass/login/testuser1 | jq '.auth.client_token'
Xauth=hvs.CAESIK5yI2YaweZFgvxl25kHA_Pw8NNzHxAdWzbKz9Kmwv-KGh4KHGh2cy5McEJwSklYUUx3WkFKVEVpWjF3TTVzRTY

### Step 4. Get data from secrets
curl --header "X-Vault-Token: $Xauth" https://vault.158.160.123.161.nip.io/v1/otus/data/otus-rw/config3 | jq '.data'     
output:
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
Dload  Upload   Total   Spent    Left  Speed
100   345  100   345    0     0   4014      0 --:--:-- --:--:-- --:--:--  4367
{
    "data": {
        "password": "otuspassword",
        "username": "otus"
    },
    "metadata": {
        "created_time": "2023-09-22T12:41:02.562023339Z",
        "custom_metadata": null,
        "deletion_time": "",
        "destroyed": false,
        "version": 2
    }
}

### Star task 2. AutoUnseal
Use https://cloud.yandex.ru/docs/kms/tutorials/vault-secret instruction
Create serviceaccount
Create role with kms.keys.encrypterDecrypter privileges
Grant role to serviceaccount
Config YC CLI
Create new key for serviceaccount, config YC CLI to use account key.
YC CLI create token

Remove helm release
Edit helm values:
vault docker image - cr.yandex/yc/vault, version - latest
Edit config to use custom seal
seal "yandexcloudkms" {
    kms_key_id  = "abj81mjrombfjdl8asml"
    oauth_token = ""
}

Make new helm release
init first node:
/ $ vault operator init
Recovery Key 1: G+lQK+uiFgmsgvPPFxXuRYczOFdGz7oEoR3w558QVzhc
Recovery Key 2: zHK9KrNAXqLPvxp9mUinwvavA8eT1U51/vI7q2YHO1U8
Recovery Key 3: GAyAAyyaaf9Nu7Znkd01DribEUMt8/gQ1aYxj6/TnyK0
Recovery Key 4: JGZC5TBAzoUGC6r/gbff6Lm7JES5CDG+oIHNBNoEMaUL
Recovery Key 5: NEQnKWnrmkpqjMNdJiKB391d7GLV7akqDQ/f46pL7aNJ

Initial Root Token: hvs.cf9QeVn9U0yP6kdJ0FQUklUd

Success! Vault is initialized

add other nodes to cluster
vault operator raft join http://vault-0.vault-internal:8200

Delete all pods and make sure that all nodes of vault are automatically unsealed.