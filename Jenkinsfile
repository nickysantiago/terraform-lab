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
                        terraform fmt -recursive
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
                        script {
                            // returnStatus lets Groovy read the exit code instead of
                            // Jenkins failing the step on non-zero.
                            def planStatus = sh(
                                returnStatus: true,
                                script: '''#!/usr/bin/env bash
                                    set -uo pipefail
                                    echo "Running Terraform plan..."
                                    terraform plan \
                                        -input=false \
                                        -out=tfplan \
                                        -detailed-exitcode
                                '''
                            )

                            // 0 = no changes, 1 = error, 2 = changes
                            if (planStatus == 1) {
                                error("Terraform plan failed!")
                            }
                            env.TF_HAS_CHANGES = (planStatus == 2).toString()  // "true" | "false"
                            echo (planStatus == 2 ? "Changes detected." : "No changes detected.")
                        }

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
                when {
                    expression { env.TF_HAS_CHANGES == 'true' }
                }
                script {
                    dir("${TF_DIR}") {
                        // Display plan summary in console
                        sh "cat tfplan.txt"

                        /* Again removing for now. Will re-evaluate once in multi-branch project

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
                        */
                    }
                }
            }
        }

        stage('Terraform Apply') {
            // Commenting out. This needs a multi branch pipeline to work. For now we will use a single branch pipeline. 
            /* when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                    expression { env.BRANCH_NAME.startsWith('release/') }
                }
            } */
            
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
