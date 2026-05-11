Step 1: Run bootstrap 
        cd terraform/bootstrap
        terraform init && terraform apply

Step 2: Uncomment backend block in environments/dev/us-east-1/backend.tf

Step 3: Initialize dev environment - migrates state to S3
        cd terraform/environments/dev/us-east-1
        terraform init
        → "Do you want to copy existing state?" → yes

Step 4: Normal workflow from here on
        terraform plan
        terraform apply
        terraform destroy
