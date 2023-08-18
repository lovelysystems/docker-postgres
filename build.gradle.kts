plugins {
    id("com.lovelysystems.gradle") version ("1.11.5")
}

lovely {
    gitProject()
    dockerProject(
        "lovelysystems/docker-postgres",
        stages = listOf("", "backup", "client", "upgrade12"),
        platforms = listOf("linux/amd64"),
        buildPlatforms = listOf("linux/amd64")
    ) {
        from("docker")
    }
}

