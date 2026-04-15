pipeline {
    agent any

    parameters {
        string(name: 'VERSION', defaultValue: '', description: 'Rollback version (leave empty for latest)')
    }

    environment {
        GIT_REPO = 'https://github.com/AnapaAkhila/myapp.git'

        JFROG_URL = 'https://trialwcx5g6.jfrog.io/artifactory'
        JFROG_CREDS = credentials('jfrog-creds')

        MAVEN_REPO = 'Maven-repo'
        DOCKER_REPO = 'docker-repo'

        IMAGE_NAME = 'trialwcx5g6.jfrog.io/docker-repo/myapp'
        APP_NAME = 'myapp'

    environment {
        APP_NAME = "myapp"
        CONTAINER_NAME = "myapp-container"
        PORT = "8081"

    }

    stages {

        stage('Clone Code') {
            when { expression { params.VERSION == '' } }
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Build Artifact') {
            when { expression { params.VERSION == '' } }
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/<your-username>/myapp.git'
            }
        }

        stage('Build & Upload to JFrog') {

            steps {
                sh 'mvn clean deploy'
            }
        }


        stage('Upload to JFrog') {
            when { expression { params.VERSION == '' } }
            steps {
                sh """
                curl -u $JFROG_CREDS_USR:$JFROG_CREDS_PSW \
                -T target/${APP_NAME}.war \
                ${JFROG_URL}/${MAVEN_REPO}/${APP_NAME}-${BUILD_NUMBER}.war
                """
            }
        }

        stage('Build Docker Image') {
            when { expression { params.VERSION == '' } }
            steps {
                sh """
                docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                """
            }
        }

        stage('Docker Login') {
            steps {
                sh """
                docker login -u $JFROG_CREDS_USR -p $JFROG_CREDS_PSW trialwcx5g6.jfrog.io
                """
            }
        }

        stage('Push Image') {
            when { expression { params.VERSION == '' } }
            steps {
                sh """
                docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                """
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                script {
                    def deployVersion = params.VERSION ?: env.BUILD_NUMBER

                    sh """
                    docker stop tomcat || true
                    docker rm tomcat || true

                    docker pull ${IMAGE_NAME}:${deployVersion}

                    docker run -d \
                        --name tomcat \
                        -p 8081:8080 \
                        ${IMAGE_NAME}:${deployVersion}
                    """
                }
        stage('Docker Build') {
            steps {
                sh 'docker build -t $APP_NAME .'
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                docker rm -f $CONTAINER_NAME || true
                docker run -d -p $PORT:8080 --name $CONTAINER_NAME $APP_NAME
                '''
             }
        }
    }

    post {
        success {
          echo "Deployment Successful"
        }
        failure {
            echo "Pipeline Failed"
            echo "Build Successful"
        }
        failure {
            echo "Build Failed"
        }
    }
}
