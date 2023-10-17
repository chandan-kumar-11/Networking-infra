pipeline{
    agent any

    
    environment {
        AWS_CREDS = credentials('aws-creds')
        Checkov_dir_path ='https://github.com/chandan-kumar-11/Networking-infra.git'
        
    }
    
    
    stages{
        stage('checkout'){
            steps{
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/chandan-kumar-11/Networking-infra.git']])
            }
        }
        
        stage('Tofu Init') {
            steps {
                sh 'tofu init '
            }
            
            
        }
        stage('Tofu Plan') {
            steps {
              script {
                  
                  sh ' tofu plan  -out=tfplan -var-file=aws.tfvars'
                }
            }
        }

        stage('Checkov Scan') {
            steps {
                 script{
                        sh'  docker run --rm bridgecrew_checkov -d ./Networking-infra-master --soft-fail  --skip-check CKV_SECRET_2,CKV2_AWS_41 > result.json'

                       
                 }
            }
        }
        
        stage('deploy infra ?'){
            steps{
                script {
                      // Define Variable
                       def USER_INPUT = input(
                              message: 'User input required - Some Yes or No question?',
                              parameters: [
                                      [$class: 'ChoiceParameterDefinition',
                                       choices: ['no','yes'].join('\n'),
                                       name: 'input',
                                       description: 'Menu - select box option']
                              ])
          
                      echo "The answer is: ${USER_INPUT}"
          
                      if( "${USER_INPUT}" == "yes"){
                          sh 'echo"going to deploy"'
                          sh 'tofu apply -var-file=aws.tfvars -auto-approve'
                      } else {
                           sh 'echo "aborting infra deplo'
                      }
                 }         
            }    
           
        }
        
        stage('Configure Terraform Backend') {
            steps {
                // Configure Terraform backend for storing state in S3 and locking with DynamoDB
                sh 'terraform remote config \
                    -backend=s3 \
                    -backend-config="grafana-json-collector" \
                    -backend-config="key=." \
                    -backend-config="region=us-west-2" \
                    -backend-config="dynamodb_table=terraform-lock" \
                    -backend-config="encrypt=true"'
            }
        }
        
        stage('Want to export state file on s3 and lock  using dynamodb?'){
            steps{
                script {
                      // Define Variable
                       def USER_INPUT = input(
                              message: 'User input required - Some Yes or No question?',
                              parameters: [
                                      [$class: 'ChoiceParameterDefinition',
                                       choices: ['no','yes'].join('\n'),
                                       name: 'input',
                                       description: 'Menu - select box option']
                              ])
          
                      echo "The answer is: ${USER_INPUT}"
          
                      if( "${USER_INPUT}" == "yes"){
                          sh 'echo"going to export statefile on s3"'
                          sh 'aws s3 cp terraform.tfstate s3://grafana-json-collector/'
                          sh ''
                      } else {
                          sh 'echo "aborting to export state file on s3 and lock  using dynamodb " '
                      }
                }
            }    
           
        }
     
      
    }
     post {
    success {
      slackSend(channel: "jenkins-channel",color: 'good', message: "my tofu infra deployed successfully")
    }
    failure {
      slackSend(channel: "jenkins-channel", color: 'danger', message: "tofu infra notdeployed (failed)")
    }
  }


}
