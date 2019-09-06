package test;

import grakn.core.client.GraknClient;
import grakn.core.concept.answer.ConceptMap;
import grakn.core.concept.answer.ConceptSet;
import graql.lang.Graql;
import graql.lang.query.GraqlGet;
import graql.lang.query.GraqlQuery;
import graql.lang.statement.Statement;
import graql.lang.statement.StatementInstance;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Date;
import java.util.List;
import java.util.Scanner;

import static graql.lang.Graql.var;

class GraknCalendarTest {

    private static final String host = "localhost";
    private static final int port = 48555;
    private static final String keyspace = "grakn3";

    public static void main(String[] args) throws FileNotFoundException {
        GraknClient client = new GraknClient(host + ":" + port);
        GraknClient.Session session = client.session(keyspace);

        //setup ontology
        GraknClient.Transaction tx = session.transaction().write();
        GraqlQuery query = Graql.parse(new Scanner(new File("grakn-schema.gql")).useDelimiter("\\Z").next());
        tx.execute(query);
        System.out.println("Ontology setup");
        tx.commit();
        tx.close();

        //insert things
        tx = session.transaction().write();
        for (int i = 0; i < 2; i++) {
            Date date = new Date();
            int hour = 1;
            insertThing(tx, date.toString(), hour);
        }
        System.out.println("Inserted things");

        //done
        tx.commit();
        tx.close();
        session.close();
        client.close();
    }

    private static void insertThing(GraknClient.Transaction tx, String date, int hour) {
        //get/create Date
        StatementInstance dateStatement = var("d").isa("Date").has("dayMonthYear", date);
        GraqlGet match = Graql.match(dateStatement).get("d");
        List<ConceptMap> answer = tx.execute(match);

        String dateId;
        if (answer.isEmpty()) {
            answer = tx.execute(Graql.insert(dateStatement));
            dateId = answer.get(0).get("d").asEntity().id().getValue();
        } else {
            dateId = answer.get(0).get("d").asEntity().id().getValue();
        }
        System.out.println("dateId: " + dateId);

        //get/create time
        Statement[] timeStatements = new Statement[]{
                var("d").id(dateId),
                var("t").isa("Time").has("hour", hour),
                var().rel("has_time", var("d")).rel("is_time", var("t")).isa("time_relation")
        };
        match = Graql.match(timeStatements).get();
        answer = tx.execute(match);
        String timeId;
        if (answer.isEmpty()) {
            List<ConceptMap> inserted = tx.execute(Graql.insert(timeStatements));
            timeId = inserted.get(0).get("t").asEntity().id().getValue();
        } else {
            timeId = answer.get(0).get("t").asEntity().id().getValue();
        }

        System.out.println("timeId: " + timeId);

        //insert thing
        String thingId = tx.execute(Graql.insert(
                var("x").isa("Thing"),
                var("t").id(timeId),
                var().rel("has_thing", var("t")).rel("is_thing", var("x"))
                        .isa("thing_relation")
        )).get(0).get("x").asEntity().id().getValue();

        System.out.println("thingId: " + thingId);

        //update most recent thing
        List<ConceptSet> execute = tx.execute(Graql.match(
                var("d").id(dateId),
                var("t").isa("Thing"),
                var("m").rel("has_most_recent_thing", var("d")).rel("is_most_recent_thing",
                        var("t")).isa("most_recent_thing_relation")
        ).delete("m"));
        for (ConceptSet conceptSet : execute) {
            System.out.println(conceptSet.set());
        }

        String mostRecentThing = tx.execute(Graql.insert(
                var("d").id(dateId),
                var("t").id(thingId),
                var("m").rel("has_most_recent_thing", var("d")).rel("is_most_recent_thing",
                        var("t")).isa("most_recent_thing_relation"))
        ).toString();
        System.out.println("Most recent thing inserted: " + mostRecentThing);
    }
}