plugins {
    id("com.lovelysystems.gradle") version ("1.6.2")
}

lovely {
    gitProject()
    dockerProject("lovelysystems/docker-postgres", stages = listOf("", "client", "upgrade12"))
    with(dockerFiles) {
        from("docker")
    }
}

