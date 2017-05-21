#!groovy

node('privileged') {
  properties([disableConcurrentBuilds()])

  stage('Checkout') {
    checkout scm
  }

  stage('Build') {
    sh 'sudo bash ./build.sh'
  }

  stage('Upload') {
    sh 'bash ./deploy.sh'
  }
}
