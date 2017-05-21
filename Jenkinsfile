#!groovy

node('privileged') {
  stage('Checkout') {
    checkout scm
  }

  stage('Build') {
    sh 'sudo bash ./build.sh'
  }
}
