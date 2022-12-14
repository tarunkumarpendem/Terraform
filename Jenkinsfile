pipeline{
    agent{
        label 'node-2'
    }
    triggers{
        pollSCM('* * * * *')
    }
    stages{
        stage('clone'){
            steps{
                git url: 'https://github.com/tarunkumarpendem/terraform.git',
                    branch: 'main'
            }
        }
        stage('terraform'){
            steps{
                sh 'cd /home/ubuntu/remote_root/workspace/Terraform/lb-autoscaling-group && ls -la'
                //sh 'ls && pwd'
                //sh 'terraform init'
                //sh 'terraform apply -var-file="dev.tfvars" -auto-approve'
                //sh 'terraform destroy -var-file="dev.tfvars" -auto-approve'
            }
        }
    }
}
