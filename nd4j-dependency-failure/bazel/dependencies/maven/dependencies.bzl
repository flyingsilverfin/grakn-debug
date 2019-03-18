# Do not edit. bazel-deps autogenerates this file from dependencies/maven/dependencies.yaml.
def _jar_artifact_impl(ctx):
    jar_name = "%s.jar" % ctx.name
    ctx.download(
        output=ctx.path("jar/%s" % jar_name),
        url=ctx.attr.urls,
        sha256=ctx.attr.sha256,
        executable=False
    )
    src_name="%s-sources.jar" % ctx.name
    srcjar_attr=""
    has_sources = len(ctx.attr.src_urls) != 0
    if has_sources:
        ctx.download(
            output=ctx.path("jar/%s" % src_name),
            url=ctx.attr.src_urls,
            sha256=ctx.attr.src_sha256,
            executable=False
        )
        srcjar_attr ='\n    srcjar = ":%s",' % src_name

    build_file_contents = """
package(default_visibility = ['//visibility:public'])
java_import(
    name = 'jar',
    tags = ['maven_coordinates={artifact}'],
    jars = ['{jar_name}'],{srcjar_attr}
)
filegroup(
    name = 'file',
    srcs = [
        '{jar_name}',
        '{src_name}'
    ],
    visibility = ['//visibility:public']
)\n""".format(artifact = ctx.attr.artifact, jar_name = jar_name, src_name = src_name, srcjar_attr = srcjar_attr)
    ctx.file(ctx.path("jar/BUILD"), build_file_contents, False)
    return None

jar_artifact = repository_rule(
    attrs = {
        "artifact": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
        "urls": attr.string_list(mandatory = True),
        "src_sha256": attr.string(mandatory = False, default=""),
        "src_urls": attr.string_list(mandatory = False, default=[]),
    },
    implementation = _jar_artifact_impl
)

def jar_artifact_callback(hash):
    src_urls = []
    src_sha256 = ""
    source=hash.get("source", None)
    if source != None:
        src_urls = [source["url"]]
        src_sha256 = source["sha256"]
    jar_artifact(
        artifact = hash["artifact"],
        name = hash["name"],
        urls = [hash["url"]],
        sha256 = hash["sha256"],
        src_urls = src_urls,
        src_sha256 = src_sha256
    )
    native.bind(name = hash["bind"], actual = hash["actual"])


def list_dependencies():
    return [
    {"artifact": "com.github.os72:protobuf-java-shaded-351:0.9", "lang": "java", "sha1": "7601234796af0ca95776ac15cab943f48127df01", "sha256": "25fa551dd76295930d49e40d44555a3af842a6e6f737b06ad9cbeb25e56b7ae6", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/com/github/os72/protobuf-java-shaded-351/0.9/protobuf-java-shaded-351-0.9.jar", "source": {"sha1": "19c872d378a598d5ebb6693326e46f5054407855", "sha256": "81434e5a60c1c66b4c00ccfab656a62f3333635a51489e2db652a098120d9f8c", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/com/github/os72/protobuf-java-shaded-351/0.9/protobuf-java-shaded-351-0.9-sources.jar"} , "name": "com-github-os72-protobuf-java-shaded-351", "actual": "@com-github-os72-protobuf-java-shaded-351//jar", "bind": "jar/com/github/os72/protobuf-java-shaded-351"},
    {"artifact": "com.github.os72:protobuf-java-util-shaded-351:0.9", "lang": "java", "sha1": "e4a45ffdf337c6d627bcf2edcb2de2d906bd6ee5", "sha256": "b42a48c6d6c3a46cd572616c7b7c929929c3b233a06c9309fd84e8076da0bb51", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/com/github/os72/protobuf-java-util-shaded-351/0.9/protobuf-java-util-shaded-351-0.9.jar", "source": {"sha1": "d6751f1692aa9b186ab886d2d6a27340b62b361e", "sha256": "68d03b6fe5c9185fd9c5e8df69c2e0892d0fc9bce30a27837cbe966817d11476", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/com/github/os72/protobuf-java-util-shaded-351/0.9/protobuf-java-util-shaded-351-0.9-sources.jar"} , "name": "com-github-os72-protobuf-java-util-shaded-351", "actual": "@com-github-os72-protobuf-java-util-shaded-351//jar", "bind": "jar/com/github/os72/protobuf-java-util-shaded-351"},
    {"artifact": "com.google.code.gson:gson:2.7", "lang": "java", "sha1": "751f548c85fa49f330cecbb1875893f971b33c4e", "sha256": "2d43eb5ea9e133d2ee2405cc14f5ee08951b8361302fdd93494a3a997b508d32", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/com/google/code/gson/gson/2.7/gson-2.7.jar", "source": {"sha1": "bbb63ca253b483da8ee53a50374593923e3de2e2", "sha256": "2d3220d5d936f0a26258aa3b358160741a4557e046a001251e5799c2db0f0d74", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/com/google/code/gson/gson/2.7/gson-2.7-sources.jar"} , "name": "com-google-code-gson-gson", "actual": "@com-google-code-gson-gson//jar", "bind": "jar/com/google/code/gson/gson"},
    {"artifact": "com.google.flatbuffers:flatbuffers-java:1.9.0", "lang": "java", "sha1": "460bc8f6411768659c1ffb529592e251a808b9f2", "sha256": "bca905c497fc67f5863d3ae9ece778073176c2ab588dedebdc8ab17da848ee48", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/com/google/flatbuffers/flatbuffers-java/1.9.0/flatbuffers-java-1.9.0.jar", "source": {"sha1": "63f3671654c2a3161ef65109b7a0c3a6a66f56a9", "sha256": "abf7678918df8f615ff3124086e16cb256d8c472ef65308d8f29fc51ac72c744", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/com/google/flatbuffers/flatbuffers-java/1.9.0/flatbuffers-java-1.9.0-sources.jar"} , "name": "com-google-flatbuffers-flatbuffers-java", "actual": "@com-google-flatbuffers-flatbuffers-java//jar", "bind": "jar/com/google/flatbuffers/flatbuffers-java"},
# duplicates in com.google.guava:guava promoted to 20.0
# - com.github.os72:protobuf-java-util-shaded-351:0.9 wanted version 19.0
# - org.nd4j:nd4j-common:1.0.0-beta3 wanted version 20.0
    {"artifact": "com.google.guava:guava:20.0", "lang": "java", "sha1": "89507701249388e1ed5ddcf8c41f4ce1be7831ef", "sha256": "36a666e3b71ae7f0f0dca23654b67e086e6c93d192f60ba5dfd5519db6c288c8", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/com/google/guava/guava/20.0/guava-20.0.jar", "source": {"sha1": "9c8493c7991464839b612d7547d6c263adf08f75", "sha256": "994be5933199a98e98bd09584da2bb69ed722275f6bed61d83459af88ace5cbd", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/com/google/guava/guava/20.0/guava-20.0-sources.jar"} , "name": "com-google-guava-guava", "actual": "@com-google-guava-guava//jar", "bind": "jar/com/google/guava/guava"},
    {"artifact": "commons-codec:commons-codec:1.10", "lang": "java", "sha1": "4b95f4897fa13f2cd904aee711aeafc0c5295cd8", "sha256": "4241dfa94e711d435f29a4604a3e2de5c4aa3c165e23bd066be6fc1fc4309569", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/commons-codec/commons-codec/1.10/commons-codec-1.10.jar", "source": {"sha1": "11fb3d88ae7e3b757d70237064210ceb954a5a04", "sha256": "dfae68268ce86f1a18fc45b99317c13d6c9d252f001d37961e79a51076808986", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/commons-codec/commons-codec/1.10/commons-codec-1.10-sources.jar"} , "name": "commons-codec-commons-codec", "actual": "@commons-codec-commons-codec//jar", "bind": "jar/commons-codec/commons-codec"},
    {"artifact": "commons-io:commons-io:2.5", "lang": "java", "sha1": "2852e6e05fbb95076fc091f6d1780f1f8fe35e0f", "sha256": "a10418348d234968600ccb1d988efcbbd08716e1d96936ccc1880e7d22513474", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/commons-io/commons-io/2.5/commons-io-2.5.jar", "source": {"sha1": "0caf033a4a7c37b4a8ff3ea084cba591539b0b69", "sha256": "3b69b518d9a844732e35509b79e499fca63a960ee4301b1c96dc32e87f3f60a1", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/commons-io/commons-io/2.5/commons-io-2.5-sources.jar"} , "name": "commons-io-commons-io", "actual": "@commons-io-commons-io//jar", "bind": "jar/commons-io/commons-io"},
    {"artifact": "commons-net:commons-net:3.1", "lang": "java", "sha1": "2298164a7c2484406f2aa5ac85b205d39019896f", "sha256": "34a58d6d80a50748307e674ec27b4411e6536fd12e78bec428eb2ee49a123007", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/commons-net/commons-net/3.1/commons-net-3.1.jar", "source": {"sha1": "8cc516e03d35ecf8f4ca71511f7961f1a9339820", "sha256": "9d0a748c3aec356a951fe6128fec94f691779d4d6ac6c09ea2e0126ccee0ed83", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/commons-net/commons-net/3.1/commons-net-3.1-sources.jar"} , "name": "commons-net-commons-net", "actual": "@commons-net-commons-net//jar", "bind": "jar/commons-net/commons-net"},
    {"artifact": "joda-time:joda-time:2.2", "lang": "java", "sha1": "a5f29a7acaddea3f4af307e8cf2d0cc82645fd7d", "sha256": "e5183ca131f7195bde5b27e4cd18deeb6d14f8bc5c483b1431421132927240af", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/joda-time/joda-time/2.2/joda-time-2.2.jar", "source": {"sha1": "ad622e3cfe39319ea53b183aa5615f96ff346584", "sha256": "e4c9ef888912cef316f0bb408c5949aaea9b519720ff6806e7ba727a073df856", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/joda-time/joda-time/2.2/joda-time-2.2-sources.jar"} , "name": "joda-time-joda-time", "actual": "@joda-time-joda-time//jar", "bind": "jar/joda-time/joda-time"},
    {"artifact": "junit:junit:4.12", "lang": "java", "sha1": "2973d150c0dc1fefe998f834810d68f278ea58ec", "sha256": "59721f0805e223d84b90677887d9ff567dc534d7c502ca903c0c2b17f05c116a", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/junit/junit/4.12/junit-4.12.jar", "source": {"sha1": "a6c32b40bf3d76eca54e3c601e5d1470c86fcdfa", "sha256": "9f43fea92033ad82bcad2ae44cec5c82abc9d6ee4b095cab921d11ead98bf2ff", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/junit/junit/4.12/junit-4.12-sources.jar"} , "name": "junit-junit", "actual": "@junit-junit//jar", "bind": "jar/junit/junit"},
    {"artifact": "net.ericaro:neoitertools:1.0.0", "lang": "java", "sha1": "25fa0a0aaf12bc386ecdb19a6ee747b361c73a20", "sha256": "f6b0697bc7425ef072908c446b4b6f2307bcfe8150506fb607b081ada4cb96c6", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/net/ericaro/neoitertools/1.0.0/neoitertools-1.0.0.jar", "source": {"sha1": "eb896e55dbacc0ce95263c18440758118947c6ea", "sha256": "eee1528b18783258cdd89ed7adf236c06995c70bd10da6d09347b7657a9e6bfc", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/net/ericaro/neoitertools/1.0.0/neoitertools-1.0.0-sources.jar"} , "name": "net-ericaro-neoitertools", "actual": "@net-ericaro-neoitertools//jar", "bind": "jar/net/ericaro/neoitertools"},
    {"artifact": "org.apache.commons:commons-compress:1.16.1", "lang": "java", "sha1": "7b5cdabadb4cf12f5ee0f801399e70635583193f", "sha256": "a20d8e45315abbe07faf952e095817b9925f38c4fc39e8a211c7d072702e97eb", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/apache/commons/commons-compress/1.16.1/commons-compress-1.16.1.jar", "source": {"sha1": "f7dde5c5163ac128750fc2d6ec00ae6a7ff624ab", "sha256": "0d155b498471fd7744176ecd09599e79e3fca4e8e38ff6d91c2666de89e03f25", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/apache/commons/commons-compress/1.16.1/commons-compress-1.16.1-sources.jar"} , "name": "org-apache-commons-commons-compress", "actual": "@org-apache-commons-commons-compress//jar", "bind": "jar/org/apache/commons/commons-compress"},
    {"artifact": "org.apache.commons:commons-lang3:3.6", "lang": "java", "sha1": "9d28a6b23650e8a7e9063c04588ace6cf7012c17", "sha256": "89c27f03fff18d0b06e7afd7ef25e209766df95b6c1269d6c3ebbdea48d5f284", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/apache/commons/commons-lang3/3.6/commons-lang3-3.6.jar", "source": {"sha1": "4765e418c9084c4e01233cb5f09bdd6b5f311ccc", "sha256": "295e1b426e7e309a501b96fd3c935f773114bb83937707ee6add5d21c6c6d887", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/apache/commons/commons-lang3/3.6/commons-lang3-3.6-sources.jar"} , "name": "org-apache-commons-commons-lang3", "actual": "@org-apache-commons-commons-lang3//jar", "bind": "jar/org/apache/commons/commons-lang3"},
    {"artifact": "org.apache.commons:commons-math3:3.4.1", "lang": "java", "sha1": "3ac44a8664228384bc68437264cf7c4cf112f579", "sha256": "d1075b14a71087038b0bfd198f0f7dd8e49b5b3529d8e2eba99e7d9eb8565e4b", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/apache/commons/commons-math3/3.4.1/commons-math3-3.4.1.jar", "source": {"sha1": "975c1f46d8df327af57892ea4787007f31d2066b", "sha256": "70b3203a34e7cab888588c442046758bc56e8dae80f881b55efe7f3b351072d0", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/apache/commons/commons-math3/3.4.1/commons-math3-3.4.1-sources.jar"} , "name": "org-apache-commons-commons-math3", "actual": "@org-apache-commons-commons-math3//jar", "bind": "jar/org/apache/commons/commons-math3"},
    {"artifact": "org.bytedeco.javacpp-presets:mkl-dnn:0.16-1.4.3", "lang": "java", "sha1": "65a2621e884a34ba5ce2cc57ace7c985567de9a8", "sha256": "a7e9d528fa70f810aad66fbdca618323c4ada98a39bf952bd51c47c0584b492b", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp-presets/mkl-dnn/0.16-1.4.3/mkl-dnn-0.16-1.4.3.jar", "source": {"sha1": "d3e59aa6af626f4b4aa8c35de7b31ed972aad63b", "sha256": "50523c7e39df332c62a9f2b29b600ba237d6991bc1383f61ffc23f0a3ca1757b", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp-presets/mkl-dnn/0.16-1.4.3/mkl-dnn-0.16-1.4.3-sources.jar"} , "name": "org-bytedeco-javacpp-presets-mkl-dnn", "actual": "@org-bytedeco-javacpp-presets-mkl-dnn//jar", "bind": "jar/org/bytedeco/javacpp-presets/mkl-dnn"},
    {"artifact": "org.bytedeco.javacpp-presets:mkl-dnn:jar:macosx-x86_64:0.16-1.4.3", "lang": "java", "sha1": "2a66b7f81b55a6e29793159759d689ba08252828", "sha256": "51cd794fe097a01dae2be250d4a95b7ea359ee6fe2c9ddd0eb4e4624c67e9a3c", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp-presets/mkl-dnn/0.16-1.4.3/mkl-dnn-0.16-1.4.3-macosx-x86_64.jar", "source": {"sha1": "d3e59aa6af626f4b4aa8c35de7b31ed972aad63b", "sha256": "50523c7e39df332c62a9f2b29b600ba237d6991bc1383f61ffc23f0a3ca1757b", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp-presets/mkl-dnn/0.16-1.4.3/mkl-dnn-0.16-1.4.3-sources.jar"} , "name": "org-bytedeco-javacpp-presets-mkl-dnn-jar-macosx-x86_64", "actual": "@org-bytedeco-javacpp-presets-mkl-dnn-jar-macosx-x86_64//jar", "bind": "jar/org/bytedeco/javacpp-presets/mkl-dnn-jar-macosx-x86-64"},
    {"artifact": "org.bytedeco.javacpp-presets:mkl:2019.0-1.4.3", "lang": "java", "sha1": "08b1ee1d83fb7c9578faa5223980aca0bf50f8f8", "sha256": "f246501ab8243bca688c763524948b4f1b7a69c13797bb70805c8da11bac9926", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp-presets/mkl/2019.0-1.4.3/mkl-2019.0-1.4.3.jar", "source": {"sha1": "07999c3941bec0ce9197ad67bd20e6f0938622ff", "sha256": "daa818173a144b3636ce5c185d358d80a4966b905898c659a33bcd5e4c970a26", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp-presets/mkl/2019.0-1.4.3/mkl-2019.0-1.4.3-sources.jar"} , "name": "org-bytedeco-javacpp-presets-mkl", "actual": "@org-bytedeco-javacpp-presets-mkl//jar", "bind": "jar/org/bytedeco/javacpp-presets/mkl"},
    {"artifact": "org.bytedeco.javacpp-presets:mkl:jar:macosx-x86_64:2019.0-1.4.3", "lang": "java", "sha1": "42f487249b4ee7e3341723c9a5ef333fee8ca4a5", "sha256": "853f79cf6daaee7807f9f106aab4fd21fae04ff2823691a855cb870836fbc24a", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp-presets/mkl/2019.0-1.4.3/mkl-2019.0-1.4.3-macosx-x86_64.jar", "source": {"sha1": "07999c3941bec0ce9197ad67bd20e6f0938622ff", "sha256": "daa818173a144b3636ce5c185d358d80a4966b905898c659a33bcd5e4c970a26", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp-presets/mkl/2019.0-1.4.3/mkl-2019.0-1.4.3-sources.jar"} , "name": "org-bytedeco-javacpp-presets-mkl-jar-macosx-x86_64", "actual": "@org-bytedeco-javacpp-presets-mkl-jar-macosx-x86_64//jar", "bind": "jar/org/bytedeco/javacpp-presets/mkl-jar-macosx-x86-64"},
    {"artifact": "org.bytedeco.javacpp-presets:openblas:0.3.3-1.4.3", "lang": "java", "sha1": "fcb1f86620b2c9ed78018cae24660c76b17bd8b9", "sha256": "61122eeb48d2c584724aaa4a1db71155c82b5cc95f1bdabdfba7e63e39fbdd7d", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp-presets/openblas/0.3.3-1.4.3/openblas-0.3.3-1.4.3.jar", "source": {"sha1": "d93f108dc2b39a18726af1e1719a6dfa22a05459", "sha256": "59c92ef59940e00ab1edffa1e791d1c94bb9dd41e8a05a090a95469c09459f48", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp-presets/openblas/0.3.3-1.4.3/openblas-0.3.3-1.4.3-sources.jar"} , "name": "org-bytedeco-javacpp-presets-openblas", "actual": "@org-bytedeco-javacpp-presets-openblas//jar", "bind": "jar/org/bytedeco/javacpp-presets/openblas"},
    {"artifact": "org.bytedeco.javacpp-presets:openblas:jar:macosx-x86_64:0.3.3-1.4.3", "lang": "java", "sha1": "0d4fcc3994bffc58f56e16af52dbbc20c7a70448", "sha256": "61dc78347d4fef82fb59ab8cbd2049d81ae9b2c5b1c56b3d41ee735d94e94588", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp-presets/openblas/0.3.3-1.4.3/openblas-0.3.3-1.4.3-macosx-x86_64.jar", "source": {"sha1": "d93f108dc2b39a18726af1e1719a6dfa22a05459", "sha256": "59c92ef59940e00ab1edffa1e791d1c94bb9dd41e8a05a090a95469c09459f48", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp-presets/openblas/0.3.3-1.4.3/openblas-0.3.3-1.4.3-sources.jar"} , "name": "org-bytedeco-javacpp-presets-openblas-jar-macosx-x86_64", "actual": "@org-bytedeco-javacpp-presets-openblas-jar-macosx-x86_64//jar", "bind": "jar/org/bytedeco/javacpp-presets/openblas-jar-macosx-x86-64"},
    {"artifact": "org.bytedeco:javacpp:1.4.3", "lang": "java", "sha1": "476e9e3988d255c18ac28a28562c3f54cfb91a8b", "sha256": "b343812936dd822835ae4f46127bd7543df8b7d07cac8f72adbb5ba28deb6f70", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp/1.4.3/javacpp-1.4.3.jar", "source": {"sha1": "c834bb55e46012fce5aa7d01767d398ca9b9240d", "sha256": "fdbf1a02b7c98dc2d8d6e1a338ac13506759ebf1c7df0755e91c22c78f4fb5e5", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/bytedeco/javacpp/1.4.3/javacpp-1.4.3-sources.jar"} , "name": "org-bytedeco-javacpp", "actual": "@org-bytedeco-javacpp//jar", "bind": "jar/org/bytedeco/javacpp"},
    {"artifact": "org.codehaus.woodstox:stax2-api:3.1.4", "lang": "java", "sha1": "ac19014b1e6a7c08aad07fe114af792676b685b7", "sha256": "86d7c0b775a7c9b454cc6ba61d40a8eb3b99cc129f832eb9b977a3755b4b338e", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/codehaus/woodstox/stax2-api/3.1.4/stax2-api-3.1.4.jar", "source": {"sha1": "b40604d61c01cc081a4a7bdfc562aa9847ee8857", "sha256": "2c36141117b83f63b5dded35f490c7b501a472fe60c60ecf02ed9e9954ef28b9", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/codehaus/woodstox/stax2-api/3.1.4/stax2-api-3.1.4-sources.jar"} , "name": "org-codehaus-woodstox-stax2-api", "actual": "@org-codehaus-woodstox-stax2-api//jar", "bind": "jar/org/codehaus/woodstox/stax2-api"},
    {"artifact": "org.hamcrest:hamcrest-core:1.3", "lang": "java", "sha1": "42a25dc3219429f0e5d060061f71acb49bf010a0", "sha256": "66fdef91e9739348df7a096aa384a5685f4e875584cce89386a7a47251c4d8e9", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar", "source": {"sha1": "1dc37250fbc78e23a65a67fbbaf71d2e9cbc3c0b", "sha256": "e223d2d8fbafd66057a8848cc94222d63c3cedd652cc48eddc0ab5c39c0f84df", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3-sources.jar"} , "name": "org-hamcrest-hamcrest-core", "actual": "@org-hamcrest-hamcrest-core//jar", "bind": "jar/org/hamcrest/hamcrest-core"},
    {"artifact": "org.nd4j:jackson:1.0.0-beta3", "lang": "java", "sha1": "ca14119b41b91c02b6edbbe5b62d21f0f575e6ff", "sha256": "c017b7efda805087e53aa7a62311852f32d81206141c2c12401b70e86bde46d3", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/jackson/1.0.0-beta3/jackson-1.0.0-beta3.jar", "source": {"sha1": "c258e8eb471096cbca94c729ec436c8063fc3a7a", "sha256": "a563d7fe78880881ecf0bc1145f40bfb823fdc2dee3f4aed413f81224b241199", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/jackson/1.0.0-beta3/jackson-1.0.0-beta3-sources.jar"} , "name": "org-nd4j-jackson", "actual": "@org-nd4j-jackson//jar", "bind": "jar/org/nd4j/jackson"},
    {"artifact": "org.nd4j:nd4j-api:1.0.0-beta3", "lang": "java", "sha1": "4b494837bc256d814b984ed658effbeafef1035d", "sha256": "939f35cd6ad3de60ba3448df244fbc419fc40cac73fdd47d48fae72166258140", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-api/1.0.0-beta3/nd4j-api-1.0.0-beta3.jar", "source": {"sha1": "ae3a83d57ad23a1a881cb0745b7f725411d05a32", "sha256": "173413a038f34f3fafaa9d1cfe8c4ac14d36fa12118254522bb6959f84aeea34", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-api/1.0.0-beta3/nd4j-api-1.0.0-beta3-sources.jar"} , "name": "org-nd4j-nd4j-api", "actual": "@org-nd4j-nd4j-api//jar", "bind": "jar/org/nd4j/nd4j-api"},
    {"artifact": "org.nd4j:nd4j-buffer:1.0.0-beta3", "lang": "java", "sha1": "33ea9e57b260e3b5e05582e864aa41592f5c5ccf", "sha256": "d96e5803c17333118b7c419069eb6a29081a48ac23225a9508e16f17332c0446", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-buffer/1.0.0-beta3/nd4j-buffer-1.0.0-beta3.jar", "source": {"sha1": "6d8c75c36a008ff99fcc7a92931cf4a2884a57da", "sha256": "1cea6505019192ee25eeddfb3091ee86b7ab2a4356140526721b8c0c10981786", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-buffer/1.0.0-beta3/nd4j-buffer-1.0.0-beta3-sources.jar"} , "name": "org-nd4j-nd4j-buffer", "actual": "@org-nd4j-nd4j-buffer//jar", "bind": "jar/org/nd4j/nd4j-buffer"},
    {"artifact": "org.nd4j:nd4j-common:1.0.0-beta3", "lang": "java", "sha1": "b62f372d17556189848274eb184c10e50e52f230", "sha256": "32d7875f1d12a4eeb91fb91061e8469cb3900a88b67954d630f11cd7a1344420", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-common/1.0.0-beta3/nd4j-common-1.0.0-beta3.jar", "source": {"sha1": "e8b68518a26dbf83409a8c295792b137f4981cca", "sha256": "03223a2a8fcd7dbbfd24c887dcecf82ceaa482e1a13c6abf0e40ee4a78da8946", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-common/1.0.0-beta3/nd4j-common-1.0.0-beta3-sources.jar"} , "name": "org-nd4j-nd4j-common", "actual": "@org-nd4j-nd4j-common//jar", "bind": "jar/org/nd4j/nd4j-common"},
    {"artifact": "org.nd4j:nd4j-context:1.0.0-beta3", "lang": "java", "sha1": "577126b55fdc9b2161132870418a5a3718537875", "sha256": "f951be1b9307898c49e476fefddfce0d550d99351adbd15ac3fd1074620cc679", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-context/1.0.0-beta3/nd4j-context-1.0.0-beta3.jar", "source": {"sha1": "af6604d8ff7f18ad35eb1f43f801433c38578a44", "sha256": "9d8bd342fff387b118fe4f93644d709da3455ded7b9d25e8f503088bd374a6af", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-context/1.0.0-beta3/nd4j-context-1.0.0-beta3-sources.jar"} , "name": "org-nd4j-nd4j-context", "actual": "@org-nd4j-nd4j-context//jar", "bind": "jar/org/nd4j/nd4j-context"},
    {"artifact": "org.nd4j:nd4j-native-api:1.0.0-beta3", "lang": "java", "sha1": "86ee835f391afaa20ad4aa21708d476d6a6082f6", "sha256": "4bc1dfbefb960cc9e780faf22784155b90f919cbd367f88340d3f17455ba2f96", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-native-api/1.0.0-beta3/nd4j-native-api-1.0.0-beta3.jar", "source": {"sha1": "a0a332e165405f45273b0b95d630cc19d0658a8b", "sha256": "ab84c80449ab1647ec38ed57a59553b81088f832448dda4b3b5fcbec2e709740", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-native-api/1.0.0-beta3/nd4j-native-api-1.0.0-beta3-sources.jar"} , "name": "org-nd4j-nd4j-native-api", "actual": "@org-nd4j-nd4j-native-api//jar", "bind": "jar/org/nd4j/nd4j-native-api"},
    {"artifact": "org.nd4j:nd4j-native:1.0.0-beta3", "lang": "java", "sha1": "4e1e36053c90b2aaffdd5915e293eaf639cde149", "sha256": "4da5b3f1d3c2c103a8acd98751aa9de6f7240b3f363f2dcb2b9f8cd1913535b6", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-native/1.0.0-beta3/nd4j-native-1.0.0-beta3.jar", "source": {"sha1": "f6aeb6958a1083aeb978e1e81668579401504596", "sha256": "5b296e770f1499c84e4846ff791e1478918d9ffb6ed408eaf71967fb1fb49bab", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-native/1.0.0-beta3/nd4j-native-1.0.0-beta3-sources.jar"} , "name": "org-nd4j-nd4j-native", "actual": "@org-nd4j-nd4j-native//jar", "bind": "jar/org/nd4j/nd4j-native"},
    {"artifact": "org.nd4j:nd4j-native:jar:linux-x86_64:1.0.0-beta3", "lang": "java", "sha1": "b53370b7834c06dd817e446374aae3c884ffdd75", "sha256": "f013ce70d9095ca8c58d6c032a891028b1b8b5dcbd777d3915b5010ed74b932d", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-native/1.0.0-beta3/nd4j-native-1.0.0-beta3-linux-x86_64.jar", "source": {"sha1": "f6aeb6958a1083aeb978e1e81668579401504596", "sha256": "5b296e770f1499c84e4846ff791e1478918d9ffb6ed408eaf71967fb1fb49bab", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-native/1.0.0-beta3/nd4j-native-1.0.0-beta3-sources.jar"} , "name": "org-nd4j-nd4j-native-jar-linux-x86_64", "actual": "@org-nd4j-nd4j-native-jar-linux-x86_64//jar", "bind": "jar/org/nd4j/nd4j-native-jar-linux-x86-64"},
    {"artifact": "org.nd4j:nd4j-native:jar:macosx-x86_64:1.0.0-beta3", "lang": "java", "sha1": "84f9c4298e86e37a833750e78828b6356d659984", "sha256": "ee17d52f6550896d59e5f9facc8d3d7d3aa84a99b8e8455f8114ae6db7392345", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-native/1.0.0-beta3/nd4j-native-1.0.0-beta3-macosx-x86_64.jar", "source": {"sha1": "f6aeb6958a1083aeb978e1e81668579401504596", "sha256": "5b296e770f1499c84e4846ff791e1478918d9ffb6ed408eaf71967fb1fb49bab", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/nd4j/nd4j-native/1.0.0-beta3/nd4j-native-1.0.0-beta3-sources.jar"} , "name": "org-nd4j-nd4j-native-jar-macosx-x86_64", "actual": "@org-nd4j-nd4j-native-jar-macosx-x86_64//jar", "bind": "jar/org/nd4j/nd4j-native-jar-macosx-x86-64"},
# duplicates in org.objenesis:objenesis promoted to 2.6
# - org.apache.commons:commons-compress:1.16.1 wanted version 2.6
# - org.nd4j:nd4j-api:1.0.0-beta3 wanted version 2.6
# - uk.com.robust-it:cloning:1.9.3 wanted version 2.1
    {"artifact": "org.objenesis:objenesis:2.6", "lang": "java", "sha1": "639033469776fd37c08358c6b92a4761feb2af4b", "sha256": "5e168368fbc250af3c79aa5fef0c3467a2d64e5a7bd74005f25d8399aeb0708d", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/objenesis/objenesis/2.6/objenesis-2.6.jar", "source": {"sha1": "96614f514a1031296657bf0dde452dc15e42fcb8", "sha256": "52d9f4dba531677fc074eff00ea07f22a1d42e5a97cc9e8571c4cd3d459b6be0", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/objenesis/objenesis/2.6/objenesis-2.6-sources.jar"} , "name": "org-objenesis-objenesis", "actual": "@org-objenesis-objenesis//jar", "bind": "jar/org/objenesis/objenesis"},
    {"artifact": "org.slf4j:slf4j-api:1.7.21", "lang": "java", "sha1": "139535a69a4239db087de9bab0bee568bf8e0b70", "sha256": "1d5aeb6bd98b0fdd151269eae941c05f6468a791ea0f1e68d8e7fe518af3e7df", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/slf4j/slf4j-api/1.7.21/slf4j-api-1.7.21.jar", "source": {"sha1": "f285ac123f201fb4b028bac556928d7cf527ef48", "sha256": "3d68eb11e27819d6a999b603d104566d8cdd93fd37efa2c02e12a99809f49c86", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/slf4j/slf4j-api/1.7.21/slf4j-api-1.7.21-sources.jar"} , "name": "org-slf4j-slf4j-api", "actual": "@org-slf4j-slf4j-api//jar", "bind": "jar/org/slf4j/slf4j-api"},
    {"artifact": "org.yaml:snakeyaml:1.12", "lang": "java", "sha1": "ebe66a6b88caab31d7a19571ad23656377523545", "sha256": "0699c809d1644b6a8209e700763bf59497df3e63756bb22f52e331e2c7e750a8", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/yaml/snakeyaml/1.12/snakeyaml-1.12.jar", "source": {"sha1": "f86c67beb22f7d1edb5d6c6a3c4dab77a23234da", "sha256": "363e9e69b052ebae3dbb0103f55180cc78971457e0da4155bb871a559c12be30", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/org/yaml/snakeyaml/1.12/snakeyaml-1.12-sources.jar"} , "name": "org-yaml-snakeyaml", "actual": "@org-yaml-snakeyaml//jar", "bind": "jar/org/yaml/snakeyaml"},
    {"artifact": "uk.com.robust-it:cloning:1.9.3", "lang": "java", "sha1": "543bce6b30867ebccc79956528d4c46f0e491735", "sha256": "168557b404f8bc001760e6a21bd5ebe48f37729758da5d8efa0b1815cbf2a7d4", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/uk/com/robust-it/cloning/1.9.3/cloning-1.9.3.jar", "source": {"sha1": "72b2480974e81ece08f4a586a25613c2a05cd661", "sha256": "350ab4dd60abdccb31cab602a4e6e0ed3f251c86b9b0bcda2c063bac7a3a141f", "repository": "https://repo.maven.apache.org/maven2/", "url": "https://repo.maven.apache.org/maven2/uk/com/robust-it/cloning/1.9.3/cloning-1.9.3-sources.jar"} , "name": "uk-com-robust-it-cloning", "actual": "@uk-com-robust-it-cloning//jar", "bind": "jar/uk/com/robust-it/cloning"},
    ]

def maven_dependencies(callback = jar_artifact_callback):
    for hash in list_dependencies():
        callback(hash)
