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
        IMAGE_NAME = 'trialwcx5g6.jfrog.io/docker-repo/myapp'

        APP_NAME = 'myapp'
        CONTAINER_NAME = 'myapp-container'
        PORT = '8081'
    }

    stages {

        // ✅ CLONE
        stage('Clone Code') {
            when { expression { params.VERSION == '' } }
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        // ✅ BUILD
        stage('Build Artifact') {
            when { expression { params.VERSION == '' } }
            steps {
                sh 'mvn clean package'
            }
        }

        // ✅ UPLOAD WAR
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

        // ✅ DOCKER BUILD
        stage('Build Docker Image') {
            when { expression { params.VERSION == '' } }
            steps {
                sh """
                docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                """
            }
        }

        // ✅ DOCKER LOGIN
        stage('Docker Login') {
            steps {
                sh """
                docker login -u $JFROG_CREDS_USR -p $JFROG_CREDS_PSW trialwcx5g6.jfrog.io
                """
            }
        }

        // ✅ PUSH IMAGE
        stage('Push Image') {
            when { expression { params.VERSION == '' } }
            steps {
                sh """
                docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                """
            }
        }

        // ✅ DEPLOY / ROLLBACK
        stage('Deploy') {
            steps {
                script {
                    def deployVersion = params.VERSION ?: env.BUILD_NUMBER

                    sh """
                    docker rm -f $CONTAINER_NAME || true

                    docker pull ${IMAGE_NAME}:${deployVersion}

                    docker run -d \
                        --name $CONTAINER_NAME \
                        -p $PORT:8080 \
                        ${IMAGE_NAME}:${deployVersion}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Deployment Successful 🚀"
        }
        failure {
            echo "Pipeline Failed ❌"
        }
    }
}
