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
  
  stage('Package') {
    sh 'bash ./package.sh'
  }

  stage('Deploy') {
    withCredentials([
      usernamePassword(credentialsId: 'bintray',
        passwordVariable: 'BINTRAY_PASSWORD',
        usernameVariable: 'BINTRAY_USERNAME')
    ]) {
      sh 'bash ./deploy.sh'
    }
  }
}
