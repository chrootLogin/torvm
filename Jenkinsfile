#!groovy

node('privileged') {
  properties([disableConcurrentBuilds()])

  currentBuild.result = "SUCCESS"
  try {
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
        usernamePassword(credentialsId: 'nextcloud',
          passwordVariable: 'NEXTCLOUD_PASSWORD',
          usernameVariable: 'NEXTCLOUD_USERNAME')
      ]) {
        sh 'bash ./deploy.sh'
      }
    }
  } catch(err) {
    currentBuild.result = "FAILURE"

    mail body: "TorVM Build failed: ${env.BUILD_URL}" ,
      from: 'jenkins@dini-mueter.net',
      subject: 'TorVM Build failed',
      to: 'me@rootlogin.ch'

    throw err
  }
}
