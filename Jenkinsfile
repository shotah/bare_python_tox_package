pipeline {
    agent {
        label 'python-3.14'  // Ensure agent has Python 3.14 installed
    }

    environment {
        // Artifactory configuration - set these in Jenkins credentials
        ARTIFACTORY_URL = credentials('artifactory-url')
        ARTIFACTORY_REPO = 'pypi-local'  // Your PyPI repo name in Artifactory
        ARTIFACTORY_CREDS = credentials('artifactory-credentials')  // username:password or username:token
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git log -1 --format="%H %s"'
            }
        }

        stage('Setup') {
            steps {
                echo 'Setting up Python environment...'
                sh '''
                    python --version
                    pip install pipenv
                    pipenv install --dev
                '''
            }
        }

        stage('Lint') {
            steps {
                echo 'Running linting checks...'
                sh '''
                    pipenv run ruff check src/ tests/
                    pipenv run ruff format --check src/ tests/
                '''
            }
        }

        stage('Type Check') {
            steps {
                echo 'Running type checking...'
                sh 'pipenv run mypy src/'
            }
        }

        stage('Security') {
            steps {
                echo 'Running security checks...'
                sh 'pipenv run bandit -r src/ -c pyproject.toml -f json -o bandit-report.json || true'
                sh 'pipenv run bandit -r src/ -c pyproject.toml'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'bandit-report.json', allowEmptyArchive: true
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh '''
                    pipenv run pytest tests/ \
                        --cov=hello_world \
                        --cov-report=term-missing \
                        --cov-report=xml:coverage.xml \
                        --junitxml=test-results.xml \
                        -v
                '''
            }
            post {
                always {
                    // Publish test results
                    junit 'test-results.xml'

                    // Publish coverage report (requires Cobertura plugin)
                    publishCoverage adapters: [coberturaAdapter('coverage.xml')]
                }
            }
        }

        stage('Build') {
            steps {
                echo 'Building package...'
                sh '''
                    pipenv run python -m build
                    pipenv run twine check dist/*
                '''
            }
            post {
                success {
                    archiveArtifacts artifacts: 'dist/*', fingerprint: true
                }
            }
        }

        stage('Publish') {
            when {
                branch 'main'  // Only publish from main branch
            }
            steps {
                echo 'Publishing to Artifactory...'
                sh '''
                    pipenv run twine upload \
                        --repository-url ${ARTIFACTORY_URL}/api/pypi/${ARTIFACTORY_REPO} \
                        -u ${ARTIFACTORY_CREDS_USR} \
                        -p ${ARTIFACTORY_CREDS_PSW} \
                        --non-interactive \
                        dist/*
                '''
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
            // Add notification here (email, Slack, Teams, etc.)
            // mail to: 'team@example.com',
            //      subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
            //      body: "Check console output at ${env.BUILD_URL}"
        }
    }
}
