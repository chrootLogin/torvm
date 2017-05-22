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
  
  stage('Convert') {
    sh 'qemu-img convert -f qcow2 -O vmdk torvm.qcow2 torvm.vmdk'
  }

  stage('Upload') {
    sh 'bash ./deploy.sh'
  }
}
