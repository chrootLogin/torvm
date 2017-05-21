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
    sh 'curl --upload-file ./tormvm.qcow2 https://transfer.sh/torvm-$BRANCH_NAME.qcow2'
  }

  stage('Cleanup') {
    cleanWs()
  }
}
