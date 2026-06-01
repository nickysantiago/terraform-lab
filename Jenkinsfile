pipeline {
    agent { label 'terraform-agent' }

    environment {
        
        AWS_DEFAULT_REGION    = 'us-east-1'

        // Terraform settings
        TF_VERSION            = '1.6.0'
        TF_WORKSPACE          = 'default'

        /* Sub directory where .tf files are located. CHANGE according to the lab
         i.e. 4-multiple-instances/environments/dev/us-east-1, 
         2-vpc-and-instance, etc.
        */
        TF_DIR                = '5-cloudfront-s3' 
    }

    triggers {
        githubPush()
    }

    options {
        // Keep last 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
        // Timeout entire pipeline after 1 hour
        timeout(time: 1, unit: 'HOURS')
        // Prevent concurrent builds
        disableConcurrentBuilds()
        // Add timestamps to console output
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo "Building branch: ${env.BRANCH_NAME}"
                echo "Commit: ${env.GIT_COMMIT}"
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-terraform-iac']]){
                    dir("${TF_DIR}") {
                    sh '''
                        echo "Initializing Terraform..."
                        terraform init \
                            -input=false \
                            -reconfigure
                    '''
                    }
                }
            }
        }

        stage('Terraform Format Check') {
            steps {
                dir("${TF_DIR}") {
                    sh '''
                        echo "Checking Terraform formatting..."
                        terraform fmt -check -recursive
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${TF_DIR}") {
                    sh '''
                        echo "Validating Terraform configuration..."
                        terraform validate
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-terraform-iac']]){
                    dir("${TF_DIR}") {
                    sh '''
                        echo "Running Terraform plan..."
                        terraform plan \
                            -input=false \
                            -out=tfplan \
                            -detailed-exitcode || exit_code=$?

                        # Exit codes:
                        # 0 = No changes
                        # 1 = Error
                        # 2 = Changes present
                        if [ "${exit_code}" -eq 1 ]; then
                            echo "Terraform plan failed!"
                            exit 1
                        fi
                    '''

                    // Save plan output as readable text for review
                    sh 'terraform show -no-color tfplan > tfplan.txt'

                    // Archive the plan for review
                    archiveArtifacts artifacts: 'tfplan.txt', fingerprint: true
                    }
                }
            }
        }

        stage('Plan Review') {
            steps {
                script {
                    // Display plan summary in console
                    sh "cat ${TF_DIR}/tfplan.txt"

                    // Only require approval on main/production branches
                    if (env.BRANCH_NAME == 'main') {
                        input(
                            message: 'Review the Terraform plan above. Proceed with Apply?',
                            ok: 'Apply',
                            submitter: 'admin,jenkins-approvers'  // Restrict who can approve
                        )
                    } else {
                        echo "Non-production branch - skipping manual approval"
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                    expression { env.BRANCH_NAME.startsWith('release/') }
                }
            }
            steps {
                withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-terraform-iac']]){
                    dir("${TF_DIR}") {
                    sh '''
                        echo "Applying Terraform plan..."
                        terraform apply \
                            -input=false \
                            -auto-approve \
                            tfplan
                    '''
                    }
                }
            }
        }

        stage('Terraform Output') {
            steps {
                withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-terraform-iac']]){
                    dir("${TF_DIR}") {
                    sh '''
                        echo "Terraform Outputs:"
                        terraform output
                    '''
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                try {
                    cleanWs()
                } catch (e) {
                    echo "Workspace cleanup skipped: ${e.message}"
                }
            }
        }
        success {
            echo "✅ Terraform pipeline completed successfully!"
        }
        failure {
            echo "❌ Terraform pipeline failed!"
        }
        unstable {
            echo "⚠️ Terraform pipeline is unstable!"
        }
    }
}