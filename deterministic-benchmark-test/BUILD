java_library(
    name = "test-benchmark",
    srcs = ["Main.java"]
)

java_binary(
    name = "test-benchmark-binary",
    main_class = "grakn.testing.Main",
    runtime_deps = ["//:test-benchmark"]
)

java_library(
    name = "grakn-benchmark-test",
    srcs = ["GraknTest.java"],
    deps = [
        "//dependencies/maven/artifacts/io/grakn/client:grakn-client",
        "//dependencies/maven/artifacts/io/grakn/core:grakn-api",
        "//dependencies/maven/artifacts/io/graql:graql-lang",
    ]
)

java_binary(
    name = "grakn-benchmark-test-binary",
    main_class = "grakn.testing.GraknTest",
    runtime_deps = ["//:grakn-benchmark-test"],
    classpath_resources = [":logback"]
)

filegroup(
    name = "logback",
    srcs = ["logback.xml"],
    visibility = ["//visibility:public"]
)
