java_library(
    name = "delete-inferred",
    srcs = [ "Main.java" ],
    deps = [
        "@graknlabs_client_java//:client-java",
        "@graknlabs_grakn_core//api:api",
        "@graknlabs_graql//java:graql",
        "@graknlabs_grakn_core//concept:concept",
    ]
)

java_binary(
    name = "delete-inferred-binary",
    runtime_deps = [ ":delete-inferred" ],
    main_class = "test.Main",
    visibility = ["//visibility:public"],
    classpath_resources = ["//:logback.xml"],
)