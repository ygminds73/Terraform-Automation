pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['DEV', 'UAT', 'PROD'],
            description: 'Select the target environment (DEV / UAT / PROD)'
        )
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select the Terraform action to perform'
        )
    }

    environment {
        REPO_URL       = 'https://github.com/omkardvd/Terraform-Automation.git'
        GITHUB_API_URL = 'https://api.github.com/repos/omkardvd/Terraform-Automation/branches'
        ENV_LOWER      = "${params.ENVIRONMENT?.toLowerCase() ?: 'dev'}"
        TF_VAR_FILE    = "envs/${ENV_LOWER}.tfvars"
        TF_WORKSPACE   = "${ENV_LOWER}"
    }

    stages {

        // ─────────────────────────────────────────────
        // STAGE 1 — Fetch branches & filter by ENV
        // ─────────────────────────────────────────────
        stage('Fetch & Select Branch') {
            steps {
                script {
                    echo "🔍 Fetching branches for environment: ${params.ENVIRONMENT}"

                    // Fetch all branches from GitHub API
                    def response = sh(
                        script: """
                            curl -s "${GITHUB_API_URL}" \
                                 -H "Accept: application/vnd.github.v3+json"
                        """,
                        returnStdout: true
                    ).trim()

                    def allBranches = readJSON(text: response).collect { it.name }
                    echo "All available branches: ${allBranches}"

                    // ── Filter branches matching the selected environment ──
                    // Convention: branches named like dev/*, uat/*, prod/*
                    def envPrefix    = env.ENV_LOWER   // dev | uat | prod
                    def envBranches  = allBranches.findAll { it.startsWith("${envPrefix}/") || it == envPrefix }

                    // Fallback: if no env-specific branches found, show all
                    def branchList = envBranches ?: allBranches
                    echo "Filtered branches for ${params.ENVIRONMENT}: ${branchList}"

                    // ── Let user pick from filtered list ──────────────────
                    def selectedBranch = input(
                        message: "Select a branch for ${params.ENVIRONMENT} deployment",
                        parameters: [
                            choice(
                                name: 'BRANCH',
                                choices: branchList,
                                description: "Branches filtered for ${params.ENVIRONMENT} environment"
                            )
                        ]
                    )

                    env.SELECTED_BRANCH = selectedBranch
                    echo "✅ Selected branch: ${env.SELECTED_BRANCH}"
                }
            }
        }

        // ─────────────────────────────────────────────
        // STAGE 2 — Checkout selected branch
        // ─────────────────────────────────────────────
        stage('Checkout') {
            steps {
                echo "📦 Checking out branch: ${env.SELECTED_BRANCH} for ENV: ${params.ENVIRONMENT}"
                checkout scmGit(
                    branches: [[name: "*/${env.SELECTED_BRANCH}"]],
                    extensions: [],
                    userRemoteConfigs: [[url: "${REPO_URL}"]]
                )
            }
        }

        // ─────────────────────────────────────────────
        // STAGE 3 — Validate env tfvars file exists
        // ─────────────────────────────────────────────
        stage('Validate Config') {
            steps {
                script {
                    echo "🔎 Validating config for ENV: ${params.ENVIRONMENT}"

                    def tfvarsExists = fileExists("${TF_VAR_FILE}")
                    if (!tfvarsExists) {
                        error "❌ Missing tfvars file: ${TF_VAR_FILE}. Please create it before running the pipeline."
                    }

                    echo "✅ Found tfvars: ${TF_VAR_FILE}"
                }
            }
        }

        // ─────────────────────────────────────────────
        // STAGE 4 — Terraform Init + Workspace
        // ─────────────────────────────────────────────
        stage('Terraform Init') {
            steps {
                script {
                    echo "⚙️ Initialising Terraform for ENV: ${params.ENVIRONMENT}"
                    sh "terraform init -reconfigure"

                    // Select or create workspace per environment
                    sh """
                        terraform workspace select ${TF_WORKSPACE} || \
                        terraform workspace new ${TF_WORKSPACE}
                    """
                    echo "✅ Terraform workspace set to: ${TF_WORKSPACE}"
                }
            }
        }

        // ─────────────────────────────────────────────
        // STAGE 5 — Terraform Action (plan/apply/destroy)
        // ─────────────────────────────────────────────
        stage('Terraform Action') {
            steps {
                script {
                    def varFile = "-var-file=${TF_VAR_FILE}"
                    def envTag  = "-var='environment=${env.ENV_LOWER}'"

                    switch (params.ACTION) {

                        case 'plan':
                            echo "📋 Running terraform plan — ENV: ${params.ENVIRONMENT} | BRANCH: ${env.SELECTED_BRANCH}"
                            sh "terraform plan ${varFile} ${envTag}"
                            break

                        case 'apply':
                            // Manual approval gate for UAT and PROD
                            if (params.ENVIRONMENT in ['UAT', 'PROD']) {
                                input message: "⚠️ Confirm APPLY to ${params.ENVIRONMENT} from branch '${env.SELECTED_BRANCH}'?", ok: "Yes, Apply"
                            }
                            echo "🚀 Running terraform apply — ENV: ${params.ENVIRONMENT} | BRANCH: ${env.SELECTED_BRANCH}"
                            sh "terraform apply --auto-approve ${varFile} ${envTag}"
                            break

                        case 'destroy':
                            // Strict approval for destroy — all environments
                            input message: "🔴 DANGER: Confirm DESTROY on ${params.ENVIRONMENT} from branch '${env.SELECTED_BRANCH}'?", ok: "Yes, Destroy"
                            echo "💣 Running terraform destroy — ENV: ${params.ENVIRONMENT} | BRANCH: ${env.SELECTED_BRANCH}"
                            sh "terraform destroy --auto-approve ${varFile} ${envTag}"
                            break

                        default:
                            error "❌ Unknown action: ${params.ACTION}"
                    }
                }
            }
        }
    }

    // ─────────────────────────────────────────────
    // POST — Build summary
    // ─────────────────────────────────────────────
    post {
        success {
            echo """
            ✅ Pipeline SUCCEEDED
            ───────────────────────────
            ENV      : ${params.ENVIRONMENT}
            ACTION   : ${params.ACTION}
            BRANCH   : ${env.SELECTED_BRANCH}
            WORKSPACE: ${env.TF_WORKSPACE}
            TFVARS   : ${env.TF_VAR_FILE}
            ───────────────────────────
            """
        }
        failure {
            echo """
            ❌ Pipeline FAILED
            ───────────────────────────
            ENV      : ${params.ENVIRONMENT}
            ACTION   : ${params.ACTION}
            BRANCH   : ${env.SELECTED_BRANCH ?: 'N/A'}
            WORKSPACE: ${env.TF_WORKSPACE}
            ───────────────────────────
            """
        }
        aborted {
            echo "⛔ Pipeline ABORTED by user — ENV: ${params.ENVIRONMENT} | ACTION: ${params.ACTION}"
        }
    }
}