java_library(
    name = "graql-grammar",
    exports = [
        "//external:jar/io/graql/graql-grammar"
    ],
    runtime_deps = [
        "//dependencies/maven/artifacts/org/antlr:antlr4-runtime"
    ],
    visibility = [
        "//dependencies/maven/artifacts:__subpackages__"
    ]
)



java_library(
    name = "graql-lang",
    exports = [
        "//external:jar/io/graql/graql-lang"
    ],
    runtime_deps = [
        "//dependencies/maven/artifacts/com/google/code/findbugs:jsr305",
        "//dependencies/maven/artifacts/com/google/guava:guava",
        "//dependencies/maven/artifacts/org/antlr:antlr4-runtime",
        "//dependencies/maven/artifacts/org/slf4j:slf4j-api",
        ":graql-grammar"
    ],
    visibility = [
        "//visibility:public"
    ]
)


