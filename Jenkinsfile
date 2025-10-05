pipeline {
  agent { label 'slave' }

  environment {
    IMAGE_NAME = "reto2-demo-micro"
    DOCKERHUB_NAMESPACE = "jorgemore"   // reemplaza con tu usuario Docker Hub
    REGISTRY = "docker.io"
    JAVA_HOME = "${tool 'JDK17'}"
    MAVEN_HOME = "${tool 'M3'}"
    PATH = "${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${env.PATH}"
    //Cloud Run / GCP
    PROJECT_ID = 'cka-1-469505'
    REGION = 'us-central1'
    REPO_NAME = 'reto2-repo'
    SERVICE_NAME = 'reto2-demo-micro'
    GCP_KEY_FILE = '/home/jenkins/agent/gcp-key.json'
    IMAGE_GCP = "gcr.io/${PROJECT_ID}/${SERVICE_NAME}"
  }

  options {
    timestamps()
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
	dir('demo-micro'){
        sh 'mvn -B -DskipTests clean package'
	}
      }
      post {
        success {
          archiveArtifacts artifacts: 'demo-micro/target/*.jar', fingerprint: true
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        script {
          def tag = env.BUILD_NUMBER
          def image = docker.build("${DOCKERHUB_NAMESPACE}/${IMAGE_NAME}:${tag}")
          
	  echo "🔐 Publicando imagen en ${REGISTRY}/${DOCKERHUB_NAMESPACE}/${IMAGE_NAME}:${tag}"

	  docker.withRegistry("https://index.docker.io/v1/", 'dockerhub-creds') {
            image.push()
            image.push('latest')
          }
        }
      }
    }
   
    stage('Push Image to Google Artifact Registry') {
      steps {
        script {
            echo "☁️ Autenticando con GCP y subiendo imagen a GCR..."
            withCredentials([file(credentialsId: 'gcp-key', variable: 'GCP_KEY')]) {
                sh '''
                    echo "Usando clave: $GCP_KEY"
                    gcloud auth activate-service-account --key-file=$GCP_KEY
                    gcloud config set project $PROJECT_ID
                    gcloud auth configure-docker $REGION-docker.pkg.dev -q
                    docker push $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:$BUILD_NUMBER
                '''
                }
            }
        }
    }

    stage('Deploy to Cloud Run') {
      steps {
        script {
          echo "🚀 Desplegando servicio ${SERVICE_NAME} en Cloud Run..."
          sh """
            gcloud auth activate-service-account --key-file=${GCP_KEY_FILE}
            gcloud config set project ${PROJECT_ID}
            gcloud config set run/region ${REGION}
            gcloud run deploy ${SERVICE_NAME} \
              --image ${IMAGE_GCP}:${BUILD_NUMBER} \
              --region ${REGION} \
              --platform managed \
              --allow-unauthenticated
          """
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

