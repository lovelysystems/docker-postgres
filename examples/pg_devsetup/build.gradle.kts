val check by tasks.registering {
    group = "Verification"
    dependsOn(":buildDockerImage")
    doLast {
        exec {
            commandLine("docker-compose", "up", "-d")
        }
        exec {
            commandLine("docker-compose", "run", "--rm", "client", "wait_for_postgres")
        }

        exec {
            commandLine("docker-compose", "run", "--rm", "client", "psql", "-c", "select 1")
        }
    }
}