맨 먼저 S3 버킷을 만든다.
Terraform 1.10 이상이면 DynamoDB 없이 S3 Lock을 쓸 수 있다.
```
aws s3api create-bucket \
--bucket sohyun-tf-state-1234 \
--region ap-northeast-2 \
--create-bucket-configuration LocationConstraint=ap-northeast-2

aws s3api put-bucket-versioning \
--bucket sohyun-tf-state-1234 \
--versioning-configuration Status=Enabled
```

이전 state 옮기기
```
terraform init -migrate-state
```
d4에서 destroy 했기 때문에 state가 비어 있다.