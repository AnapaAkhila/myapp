pipeline {
    agent any

    tools {
        maven 'Maven'   // Jenkins configured Maven name
    }

    stages {

        stage('Build & Upload to JFrog') {
            steps {
                sh 'mvn clean deploy'
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
