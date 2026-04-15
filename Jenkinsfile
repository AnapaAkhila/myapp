pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                deleteDir()        
                checkout scm       
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                docker rm -f myapp-container || true
                docker build -t myapp .
                docker run -d -p 8081:8080 --name myapp-container myapp
                '''
            }
        }
    }
}
