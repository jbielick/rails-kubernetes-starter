node {
   stage('Build image') {
  app = docker.build("asia.gcr.io/brave-scanner-234908/rails-kube-demo_app")
}
stage('Push image') {
  docker.withRegistry('https://asia.gcr.io', 'gcr:pace-config-updated') {
    app.push("${env.BUILD_NUMBER}")
    app.push("latest")
  }
}

stage('Deploy App') {
  sh("kubectl apply -f ./kube/web-deployment.yml")
  }
}
