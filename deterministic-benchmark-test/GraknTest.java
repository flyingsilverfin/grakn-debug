package grakn.testing;

import grakn.client.GraknClient;
import graql.lang.Graql;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class GraknTest {
    static String schema = "define\n" +
            "\n" +
            "  contract sub relation,\n" +
            "    relates provider,\n" +
            "    relates customer;\n" +
            "\n" +
            "  call sub relation,\n" +
            "    relates caller,\n" +
            "    relates callee,\n" +
            "    has started-at,\n" +
            "    has duration;\n" +
            "\n" +
            "  company sub entity,\n" +
            "    plays provider,\n" +
            "    has name;\n" +
            "\n" +
            "person sub entity,\n" +
            "    plays customer,\n" +
            "    plays caller,\n" +
            "    plays callee,\n" +
            "    has first-name,\n" +
            "    has last-name,\n" +
            "    has phone-number,\n" +
            "    has city,\n" +
            "    has age,\n" +
            "    has is-customer;\n" +
            "\n" +
            "  name sub attribute,\n" +
            "\t  datatype string;\n" +
            "  started-at sub attribute,\n" +
            "\t  datatype date;\n" +
            "  duration sub attribute,\n" +
            "\t  datatype long;\n" +
            "  first-name sub attribute,\n" +
            "\t  datatype string;\n" +
            "  last-name sub attribute,\n" +
            "\t  datatype string;\n" +
            "  phone-number sub attribute,\n" +
            "\t  datatype string;\n" +
            "  city sub attribute,\n" +
            "\t  datatype string;\n" +
            "  age sub attribute,\n" +
            "\t  datatype long;\n" +
            "  is-customer sub attribute,\n" +
            "\t  datatype boolean;";


    static String matchQuery1 = "match\n" +
            "  $customer isa person, has phone-number $phone-number;\n" +
            "  $company isa company, has name \"Telecom\";\n" +
            "  (customer: $customer, provider: $company) isa contract;\n" +
            "  $target isa person, has phone-number \"+86 921 547 9004\";\n" +
            "  (caller: $customer, callee: $target) isa call, has started-at $started-at;\n" +
            "  $min-date == 2018-09-14T17:18:49; $started-at > $min-date;\n" +
            "get $phone-number;";

    static String matchQuery2 = "match\n" +
            "  $suspect isa person, has city \"London\", has age > 50;\n" +
            "  $company isa company, has name \"Telecom\";\n" +
            "  (customer: $suspect, provider: $company) isa contract;\n" +
            "  $pattern-callee isa person, has age < 20;\n" +
            "  (caller: $suspect, callee: $pattern-callee) isa call, has started-at $pattern-call-date;\n" +
            "  $target isa person, has phone-number $phone-number, has is-customer false;\n" +
            "  (caller: $suspect, callee: $target) isa call, has started-at $target-call-date;\n" +
            "  $target-call-date > $pattern-call-date;\n" +
            "get $phone-number;";

    static String matchQuery3 = "match\n" +
            "  $target isa person, has phone-number \"+48 894 777 5173\";\n" +
            "  $company isa company, has name \"Telecom\";\n" +
            "  $customer-a isa person, has phone-number $phone-number-a;\n" +
            "  $customer-b isa person, has phone-number $phone-number-b;\n" +
            "  (customer: $customer-a, provider: $company) isa contract;\n" +
            "  (customer: $customer-b, provider: $company) isa contract;\n" +
            "  (caller: $customer-a, callee: $customer-b) isa call;\n" +
            "  (caller: $customer-a, callee: $target) isa call;\n" +
            "  (caller: $customer-b, callee: $target) isa call;\n" +
            "get $phone-number-a, $phone-number-b;";

    static String matchQuery4 = "match\n" +
            "  $customer isa person, has age < 20;\n" +
            "  $company isa company, has name \"Telecom\";\n" +
            "  (customer: $customer, provider: $company) isa contract;\n" +
            "  (caller: $customer, callee: $anyone) isa call, has duration $duration;\n" +
            "get $duration; mean $duration;\n";

    static String matchQuery5 = "match $x sub thing; get;";
    static String matchQuery6 = "match $x ($a, $b, $c); $a != $b; $a != $c; $b != $c; get;";


    static String insertQuery1 = "insert $x isa person;";
    static String insertQuery2 = "insert \n" +
            "  $customer isa person, has phone-number \"12345\";\n" +
            "  $company isa company, has name \"Telecom\";\n" +
            "  (customer: $customer, provider: $company) isa contract;\n" +
            "  $target isa person, has phone-number \"+86 921 547 9004\";\n" +
            "  (caller: $customer, callee: $target) isa call;";
    static String insertQuery3 = "insert\n" +
            "  $suspect isa person, has city \"London\"; \n" +
            "  $company isa company, has name \"Telecom\";\n" +
            "  (customer: $suspect, provider: $company) isa contract;\n" +
            "  $pattern-callee isa person;\n" +
            "  (caller: $suspect, callee: $pattern-callee) isa call;\n" +
            "  $target isa person, has phone-number \"abc123\", has is-customer false;\n" +
            "  (caller: $suspect, callee: $target) isa call;\n";
    static String insertQuery4 = "insert\n" +
            "  $customer isa person, has age 20;\n" +
            "  $company isa company, has name \"Telecom\";\n" +
            "  (customer: $customer, provider: $company) isa contract;\n" +
            "  (caller: $customer) isa call, has duration -1;\n";
    static String insertQuery5 = "insert $x isa person;";


    public static void main(String[] args) {
        GraknClient client = new GraknClient("localhost:48555");
        GraknClient.Session session = client.session("test");

        loadSchema(session);
        runInsertQueries(session);
    }

    private static void loadSchema(GraknClient.Session session) {
        GraknClient.Transaction tx = session.transaction().write();
        tx.execute(Graql.parse(schema).asDefine());
        tx.commit();
        tx.close();
    }

    private static void runInsertQueries(GraknClient.Session session) {
        Map<String, List<Double>> queryTimes = new HashMap<>();
        Map<String, List<Double>> commitTimes = new HashMap<>();
        List<String> queries = Arrays.asList(insertQuery1, insertQuery2, insertQuery3, insertQuery4, insertQuery5);
        for (int i = 0; i < 20; i++) {
            for (String query : queries) {
                try (GraknClient.Transaction tx = session.transaction().write()) {

                    long startTime = System.nanoTime();
                    tx.execute(Graql.parse(query).asInsert());
                    long queryTime = System.nanoTime();
                    tx.commit();
                    long commitTime = System.nanoTime();

                    queryTimes.putIfAbsent(query, new ArrayList<>());
                    queryTimes.get(query).add(((double)queryTime - startTime)/1000000);
                    commitTimes.putIfAbsent(query, new ArrayList<>());
                    commitTimes.get(query).add(((double)commitTime - queryTime)/1000000);
                }
            }
        }

        for (String query : queryTimes.keySet()) {
            System.out.println(query);
            String queryTimesString = queryTimes.get(query).stream().map(Object::toString).collect(Collectors.joining(", "));
            String commitTimesString = commitTimes.get(query).stream().map(Object::toString).collect(Collectors.joining(", "));
            System.out.println(queryTimesString);
            System.out.println(commitTimesString);
            System.out.println();
        }
    }
}