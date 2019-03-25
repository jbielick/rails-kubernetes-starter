node {
   stage('Build image') {
  app = docker.build("asia.gcr.io/brave-scanner-234908/rails-kube-demo_app")
}
stage('Push image') {
  docker.withRegistry('https://gcr.io', 'gcr:_dcgcloud_token') {
    app.push("${env.BUILD_NUMBER}")
    app.push("latest")
  }
}
}
