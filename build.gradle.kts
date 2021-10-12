plugins {
    id("com.lovelysystems.gradle") version ("1.6.1")
}

lovely {
    gitProject()
    dockerProject("lovelysystems/docker-postgres")

    with(dockerFiles) {
        from("docker")
    }
}
