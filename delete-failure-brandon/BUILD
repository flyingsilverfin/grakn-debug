java_library(
    name = "delete-failure-test",
    srcs = [ "GraknCalendarTest.java" ],
    deps = [
        "@graknlabs_client_java//:client-java",
        "@graknlabs_grakn_core//api:api",
        "@graknlabs_graql//java:graql",
        "@graknlabs_grakn_core//concept:concept",
    ]
)

java_binary(
    name = "delete-failure-test-binary",
    runtime_deps = [ ":delete-failure-test" ],
    main_class = "test.GraknCalendarTest",
    visibility = ["//visibility:public"],
    classpath_resources = ["//:logback.xml"],
    data = ["grakn-schema.gql"]
)