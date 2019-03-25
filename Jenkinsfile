node {
   stage('Build image') {
  app = docker.build("asia.gcr.io/brave-scanner-234908/rails-kube-demo_app")
}
stage('Push image') {
  docker.withRegistry('https://gcr.io', 'gcr:dc5fb7715eb053efb853c14d7128764b3fde672a') {
    app.push("${env.BUILD_NUMBER}")
    app.push("latest")
  }
}
}
