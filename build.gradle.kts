plugins {
    id("com.lovelysystems.gradle") version ("1.6.1")
}

lovely {
    gitProject()
    dockerProject("lovelysystems/docker-postgres", stages = listOf("", "upgrade12"))

    with(dockerFiles) {
        from("docker")
    }
}
