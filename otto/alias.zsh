alias gtst='gcloud container clusters get-credentials clickstream --region europe-west1 --project brain-ph-mavrodi-score-tst && kubectl port-forward --namespace analyzing service/grafana 3000:80'
alias gdev='gcloud container clusters get-credentials clickstream --region europe-west1 --project brain-ph-mavrodi-score-dev && kubectl port-forward --namespace analyzing-joreetz service/grafana 3000:80'
alias gprd='gcloud container clusters get-credentials clickstream --region europe-west1 --project brain-ph-mavrodi-score-prd && kubectl port-forward --namespace analyzing service/grafana 3000:80'
