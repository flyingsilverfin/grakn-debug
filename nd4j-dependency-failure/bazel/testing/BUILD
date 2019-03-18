config_setting(
    name = "osx_build",
    constraint_values = [
   		"@bazel_tools//platforms:osx",
        "@bazel_tools//platforms:x86_64",
    ]
)

config_setting(
    name = "linux_build",
    constraint_values = [
   		"@bazel_tools//platforms:linux",
        "@bazel_tools//platforms:x86_64",
    ]
)

java_library(
	name = "nd4j-native-platform-independent",
	exports = select({
		":linux_build": ["//dependencies/maven/artifacts/org/nd4j:nd4j-native-jar-linux-x86-64"],
		":osx_build": ["//dependencies/maven/artifacts/org/nd4j:nd4j-native-jar-macosx-x86-64"]
	})
)

java_library(
    name = "testing",
    srcs = ["Main.java"],
    deps = [
        "//dependencies/maven/artifacts/org/nd4j:nd4j-native",
        "//dependencies/maven/artifacts/org/nd4j:nd4j-api",
        "//dependencies/maven/artifacts/org/nd4j:nd4j-native-api",
        ":nd4j-native-platform-independent"
    ]
)

java_binary(
    name = "testing-binary",
    main_class = "testing.Main",
    runtime_deps = [":testing"],
    visibility = ["//visibility:public"]
)



# ---------------------------------------------------------------------
# compare running same code via java_binary versus java_test
# java_test fails with a LinkError, while java_binary suceeds

java_library(
    name = "nd4j-unit-test-library",
    srcs = ["test/Nd4jUserTest.java"],
    deps = [
        "//dependencies/maven/artifacts/junit:junit",

        "//dependencies/maven/artifacts/org/nd4j:nd4j-native",
        "//dependencies/maven/artifacts/org/nd4j:nd4j-api",
        "//dependencies/maven/artifacts/org/nd4j:nd4j-native-api",
        ":nd4j-native-platform-independent"
    ]
)

# entry via binary -- main()
java_binary(
    name = "nd4j-unit-binary",
    main_class = "testing.test.Nd4jUserTest",
    runtime_deps = [":nd4j-unit-test-library"],
    visibility = ["//visibility:public"]
)


# entry via JUnit test -- fails
java_test(
    name = "nd4j-unit-library-test",
    test_class = "testing.test.Nd4jUserTest",
    runtime_deps = [":nd4j-unit-test-library"],
    visibility = ["//visibility:public"]
)
