val check by tasks.registering {
    dependsOn(":buildDockerImage")
    group = "Verification"
    doLast {
        exec {
            commandLine("./upgrade_procedure.sh")
        }
    }
}

