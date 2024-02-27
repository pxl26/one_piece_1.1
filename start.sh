#!/bin/bas
travelove_2511_target="arn:aws:elasticloadbalancing:ap-southeast-1:756376042281:targetgroup/travelove-http-2511/4481d1a3f736a4ae"
thumbnail_target="arn:aws:elasticloadbalancing:ap-southeast-1:756376042281:targetgroup/thumbnail/7a9bbfa2104f5eda"

travelove_id=`aws ec2 describe-instances --filters "Name=tag:Name,Values=TRAVELOVE" --query Reservations[0].Instances[0].InstanceId --output text`
thumbnail_id=`aws ec2 describe-instances --filters "Name=tag:Name,Values=THUMBNAIL" --query Reservations[0].Instances[0].InstanceId --output text`
payment_id=`aws ec2 describe-instances --filters "Name=tag:Name,Values=PAYMENT" --query Reservations[0].Instances[0].InstanceId --output text`

aws ec2 start-instances --instance-id $travelove_id
arn=`aws elbv2 create-load-balancer --name travelove-elb --subnets subnet-0cb471c508ec4d890 subnet-09b41deaedba7fea2 --security-groups sg-0bdab3e4f7ec90856 --query 'LoadBalancers[0].LoadBalancerArn' --output text`
aws elbv2 create-listener --load-balancer-arn $arn --protocol HTTPS --port 443  --default-actions Type=forward,TargetGroupArn=$travelove_2511_target --certificates CertificateArn=arn:aws:acm:ap-southeast-1:756376042281:certificate/80c262ef-d8cc-49aa-b881-c5438255f837
elb_dns=`aws elbv2 describe-load-balancers --query 'LoadBalancers[0].DNSName' --output text`
echo "{\"Comment\": \"CREATE/DELETE/UPSERT a record \",\"Changes\": [{\"Action\": \"UPSERT\",\"ResourceRecordSet\": {\"Name\": \"api.travelovecompany.com\",\"Type\": \"CNAME\",\"TTL\": 300,\"ResourceRecords\": [{ \"Value\": \""$elb_dns"\"}]}}]}" > record_change.json
aws route53 change-resource-record-sets --hosted-zone-id Z044281721TYCAN7LUCSS --change-batch file://record_change.json

# start thumbnail server
aws ec2 start-instances --instance-id $thumbnail_id
arn=`aws elbv2 create-load-balancer --name thumbnail-elb --subnets subnet-0cb471c508ec4d890 subnet-09b41deaedba7fea2 --security-groups sg-0bdab3e4f7ec90856 --query 'LoadBalancers[0].LoadBalancerArn' --output text`
aws elbv2 create-listener --load-balancer-arn $arn --protocol HTTPS --port 443  --default-actions Type=forward,TargetGroupArn=$thumbnail_target --certificates CertificateArn=arn:aws:acm:ap-southeast-1:756376042281:certificate/80c262ef-d8cc-49aa-b881-c5438255f837
elb_dns=`aws elbv2 describe-load-balancers --query 'LoadBalancers[1].DNSName' --output text`
echo "{\"Comment\": \"CREATE/DELETE/UPSERT a record \",\"Changes\": [{\"Action\": \"UPSERT\",\"ResourceRecordSet\": {\"Name\": \"storage.travelovecompany.com\",\"Type\": \"CNAME\",\"TTL\": 300,\"ResourceRecords\": [{ \"Value\": \""$elb_dns"\"}]}}]}" > record_change.json
aws route53 change-resource-record-sets --hosted-zone-id Z044281721TYCAN7LUCSS --change-batch file://record_change.json

#start payment server
aws ec2 start-instances --instance-id $payment_id
clear
echo Travelove is started
read
