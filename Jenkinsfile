#!groovy

node('privileged') {
  properties([disableConcurrentBuilds()])

  stage('Checkout') {
    deleteDir()
    checkout scm
  }

  stage('Build') {
    sh 'sudo bash ./build.sh'
  }

  stage('Upload') {
    sh 'bash ./deploy.sh'
  }
}
