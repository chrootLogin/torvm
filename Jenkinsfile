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
      ansiColor('xterm') {
        sh 'sudo bash ./build.sh'
      }
    }

    stage('Package') {
      sh 'bash ./package.sh'
    }

    stage('Deploy local') {
      withCredentials([
        usernamePassword(credentialsId: 'nextcloud',
          passwordVariable: 'NEXTCLOUD_PASSWORD',
          usernameVariable: 'NEXTCLOUD_USERNAME')
      ]) {
        sh 'bash ./deploy.sh'
      }
    }

    stage('Deploy sourceforge') {
      sshagent(['8ffaa0c1-6e5d-4884-b2ee-854685476789']) {
        sh 'rsync -aP -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l rootlogin" target/torvm-vmware.zip frs.sourceforge.net:/home/frs/project/torvm/TorVM-VMware-${BRANCH_NAME}.zip'
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
