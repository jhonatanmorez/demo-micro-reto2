pipeline {
  agent { label 'slave' }

  environment {
    IMAGE_NAME = "demo-micro"
    DOCKERHUB_NAMESPACE = "jorgemore"   // reemplaza con tu usuario Docker Hub
    REGISTRY = "docker.io"
    JAVA_HOME = "${tool 'JDK17'}"
    MAVEN_HOME = "${tool 'M3'}"
    PATH = "${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${env.PATH}"
  }

  options {
    timestamps()
    ansiColor('xterm')
    disableConcurrentBuilds()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Sanity check') {
      steps {
        sh '''
          whoami
          java -version
          mvn -v
          docker --version
        '''
      }
    }

    stage('Build JAR') {
      steps {
        sh 'mvn -B -DskipTests clean package'
      }
      post {
        success {
          archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        script {
          def tag = env.BUILD_NUMBER
          def image = docker.build("${DOCKERHUB_NAMESPACE}/${IMAGE_NAME}:${tag}")
          docker.withRegistry("https://${REGISTRY}", 'dockerhub-creds') {
            image.push()
            image.push('latest')
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Imagen publicada en Docker Hub: ${env.DOCKERHUB_NAMESPACE}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}"
    }
    failure {
      echo "❌ Build fallido. Revisar logs."
    }
  }
}

