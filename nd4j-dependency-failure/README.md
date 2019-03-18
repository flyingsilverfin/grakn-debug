# bazel-vs-maven-nd4j-dependency
Illustrates issue that emerges when depending on nd4j in bazel, which succeeds when using maven

This repository contains two projects: a bazel and a maven one.
Both attempt to depend on `nd4j`


## nd4j 
Website: https://deeplearning4j.org/docs/latest/deeplearning4j-quickstart#Maven
Specifically interested in https://deeplearning4j.org/docs/latest/nd4j-overview
Not the whole deeplearning4j project.

Relevant maven artifact I've found is `nd4j-native`.
The maven repostiroy listing for this artifact can be found at https://repo.maven.apache.org/maven2/org/nd4j/nd4j-native/0.9.1/

Issue #75 in `graknlabs/benchmark` repository.
