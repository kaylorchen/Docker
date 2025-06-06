```bash
docker builder build -t kaylor/aptly:1.6.1 -f Dockerfile .
```

gpg --batch --generate-key <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: "kaylor"
Name-Comment: "Used in CI environment for SIAT"
Name-Email: "kaylor.chen@qq.com"
Expire-Date: 0
%no-protection
%commit
EOF
