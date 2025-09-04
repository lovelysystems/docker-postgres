plugins {
    id("com.lovelysystems.gradle") version ("1.16.0")
}

lovely {
    gitProject()
    dockerProject(
        "lovelysystems/docker-postgres",
        stages = listOf("", "backup", "client"),
    ) {
        from("docker")
    }
}
