aws ec2 describe-instances --filter Name=tag:Name,Values=TRAVELOVE --query "Reservations[].Instances[*].{InstanceType: InstanceType, InstanceId: InstanceId, State: State.Name}" --output table
pause
