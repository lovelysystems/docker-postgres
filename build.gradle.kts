plugins {
    id("com.lovelysystems.gradle") version ("1.2.0")
}

lovely {
    gitProject()
    dockerProject("lovelysystems/docker-postgres")

    with(dockerFiles) {
        from("docker")
    }
}
