pipeline {
    agent { docker { image 'node:6.3' } }
    stages {
        stage('build') {
            steps {
                sh 'npm --version'
                //docker build -t app .
            }
        }
        //deploying image to Container Registry...
        stage('deploy image') {
            steps {
                //sh 'npm --version'
                docker build -t app .
            }
        }
    }
}
