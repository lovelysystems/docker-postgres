plugins {
    id("com.lovelysystems.gradle") version ("1.12.0")
}

lovely {
    gitProject()
    dockerProject(
        "lovelysystems/docker-postgres",
        stages = listOf("", "backup", "client", "upgrade12"),
        // note that the platform is nailed as AMD64 here, because M1 Macs would generate ARM64 images by default, but,
        // when ARM64 is used, `diffdb` bumps into the following error when it runs the `apgdiff` command:
        // "qemu-x86_64: Could not open '/lib64/ld-linux-x86-64.so.2': No such file or directory"
        // That's because the apgdiff tool is only available within an AMD64 image, and even though it's copied
        // successfully to an ARM64 image build time, it still won't work.
        platforms = listOf("linux/amd64"),
        buildPlatforms = listOf("linux/amd64")
    ) {
        from("docker")
    }
}

