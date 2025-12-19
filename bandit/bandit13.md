from local:
`scp -P 2220 bandit13@bandit.labs.overthewire.org:sshkey.private .` 
`chmod 700 sshkey.private`

next level access:
`ssh -i sshkey.private bandit14@bandit.labs.overthewire.org -p 2220`
