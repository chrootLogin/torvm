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
