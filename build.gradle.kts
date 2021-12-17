plugins {
    id("com.lovelysystems.gradle") version ("1.6.2")
}

lovely {
    gitProject()
    dockerProject("lovelysystems/docker-postgres", stages = listOf("", "client"))
    with(dockerFiles) {
        from("docker")
    }
}
