1. Choose helm chart to copy
   1. for example chartmuseum
2. Search for stable version in public repos
   1. helm search repo chartmuseum
3. Download package
   1. helm pull chartmuseum/chartmuseum
4. upload package to my server
   1. curl --data-binary "@chartmuseum-3.10.1.tgz" https://chartmuseum.158.160.63.42.nip.io/api/charts
   2. expected response: {"saved":true}
5. List all my repos
   1. helm repo list
6. Remove all repos
   1. helm repo remove
7. Add my own chartmuseum repo
   1. helm repo add mymuseum https://chartmuseum.158.160.63.42.nip.io/
8. Search for all chartmuseum package
   1. helm search repo chartmuseum
9. Install package from my repo
   1. helm upgrade --install museum2 mymuseum/chartmuseum --namespace=museum2 --create-namespace
10. Validate install
    1. helm list --namespace=museum2
