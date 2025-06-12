plugins {
    id("com.lovelysystems.gradle") version ("1.15.0")
}

lovely {
    gitProject()
    dockerProject(
        "lovelysystems/docker-postgres",
        stages = listOf("", "backup", "client", "upgrade12"),
    ) {
        from("docker")
    }
}

