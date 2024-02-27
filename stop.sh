arn_1=`aws elbv2 describe-load-balancers --query 'LoadBalancers[0].LoadBalancerArn' --output text`
arn_2=`aws elbv2 describe-load-balancers --query 'LoadBalancers[1].LoadBalancerArn' --output text`
aws elbv2 delete-load-balancer --load-balancer-arn $arn_1
aws elbv2 delete-load-balancer --load-balancer-arn $arn_2


travelove_id=`aws ec2 describe-instances --filters "Name=tag:Name,Values=TRAVELOVE" --query Reservations[0].Instances[0].InstanceId --output text`
thumbnail_id=`aws ec2 describe-instances --filters "Name=tag:Name,Values=THUMBNAIL" --query Reservations[0].Instances[0].InstanceId --output text`
payment_id=`aws ec2 describe-instances --filters "Name=tag:Name,Values=PAYMENT" --query Reservations[0].Instances[0].InstanceId --output text`

aws ec2 stop-instances --instance-id $travelove_id
aws ec2 stop-instances --instance-id $thumbnail_id
aws ec2 stop-instances --instance-id $payment_id
clear
echo "Travelove is stopped"
read
