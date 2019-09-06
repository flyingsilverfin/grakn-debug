java_library(
    name = "grakn-api",
    exports = [
        "//external:jar/io/grakn/core/grakn-api"
    ],
    runtime_deps = [
        "//dependencies/maven/artifacts/com/google/code/findbugs:jsr305",
        "//dependencies/maven/artifacts/io/graql:graql-lang",
        ":grakn-concept"
    ],
    visibility = [
        "//visibility:public"
    ]
)



java_library(
    name = "grakn-common",
    exports = [
        "//external:jar/io/grakn/core/grakn-common"
    ],
    runtime_deps = [
        "//dependencies/maven/artifacts/com/google/code/findbugs:jsr305",
        "//dependencies/maven/artifacts/org/slf4j:slf4j-api"
    ],
    visibility = [
        "//dependencies/maven/artifacts:__subpackages__"
    ]
)



java_library(
    name = "grakn-concept",
    exports = [
        "//external:jar/io/grakn/core/grakn-concept"
    ],
    runtime_deps = [
        "//dependencies/maven/artifacts/com/google/code/findbugs:jsr305",
        "//dependencies/maven/artifacts/io/graql:graql-lang",
        ":grakn-common"
    ],
    visibility = [
        "//dependencies/maven/artifacts:__subpackages__"
    ]
)


