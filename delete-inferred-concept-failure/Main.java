package test;


import grakn.core.client.GraknClient;
import graql.lang.Graql;
import graql.lang.query.GraqlGet;
import graql.lang.query.GraqlInsert;
import graql.lang.query.GraqlDelete;
import grakn.core.concept.answer.ConceptSet;

import java.util.List;

public class Main {

    public static void main(String[] args) {
        GraknClient client = new GraknClient("localhost:48555");

        try {
            deleteInferredAttribute(client);
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            deleteInferredImplicitRelationship(client);
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            oneRuleDeleteInferredRelationship(client);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void oneRuleDeleteInferredRelationship(GraknClient client) {
        /*
        One rule - aunthood
        This is NOT a reified relationship because there's nothing attached to the aunthood relationship
         */
        String schemaOneRule = "define " +
                "person sub entity, plays mother, plays sister, plays son, plays nephew, plays aunt; " +
                "motherhood sub relation, relates mother, relates son;" +
                "sisterhood sub relation, relates sister;" +
                "aunthood sub relation, relates aunt, relates nephew, has number;" +
                "number sub attribute, datatype long;" +
                "auntie-rule sub rule, " +
                "when { " +
                "$mother isa person; " +
                "$sister isa person; " +
                "$son isa person; " +
                "(sister: $mother, sister: $sister) isa sisterhood; " +
                "(mother: $mother, son: $son) isa motherhood; " +
                "}, then {" +
                "(aunt: $sister, nephew: $son) isa aunthood; };";


        System.out.println("\nInserting schema for DeleteInferredRelationship() ...");
        GraknClient.Session session = client.session("ksp1");
        GraknClient.Transaction tx = session.transaction().write();

        tx.execute(Graql.parse(schemaOneRule).asDefine());

        System.out.println("Inserting people and sisterhood, motherhood...");
        GraqlInsert insert = Graql.parse( "insert $m isa person; $s isa person; $d isa person; " +
                "(sister: $m, sister: $s) isa sisterhood; " +
                "(mother: $m, son: $d) isa motherhood;").asInsert();
        tx.execute(insert);
        tx.commit();

        tx = session.transaction().write();
        GraqlGet get = Graql.parse("match $r isa aunthood; get $r;").asGet();
        System.out.printf("Inferred aunthoods: ");
        System.out.println(tx.execute(get));

        System.out.println("Trying to delete inferred aunthoods...");

        GraqlDelete delete = Graql.parse("match $r isa aunthood; delete $r;").asDelete();
        List<ConceptSet> deletedConcepts = tx.execute(delete);


        System.out.println("Committing...");
        tx.commit();
        session.close();
    }

    public static void deleteInferredAttribute(GraknClient client) {
        /*
        One rule - aunthood
        This is NOT a reified relationship because there's nothing attached to the aunthood relationship
        */
        String schemaTwoRule= "define " +
                "person sub entity, plays mother, plays son; " +
                "motherhood sub relation, relates mother, relates son, has number;" +
                "number sub attribute, datatype long;" +
                "motherhood-number sub rule, when { $motherhood isa motherhood; }, then { $motherhood has number 1; };";

        System.out.println("\nInserting schema - deleteInferredAttribute()...");
        GraknClient.Session session = client.session("ksp2");
        GraknClient.Transaction tx = session.transaction().write();

        tx.execute(Graql.parse(schemaTwoRule).asDefine());

        GraqlInsert insert = Graql.parse( "insert $m isa person; $s isa person; $d isa person; " +
                "(mother: $m, son: $d) isa motherhood;").asInsert();
        tx.execute(insert);
        tx.commit();

        tx = session.transaction().write();

        GraqlGet get = Graql.parse("match $r isa motherhood, has number $n; get $n;").asGet();
        System.out.printf("Inferred motherhoods: ");
        System.out.println(tx.execute(get));

        System.out.println("Trying to delete motherhood numbers: ");

        GraqlDelete delete = Graql.parse("match $r ($m, $s) isa motherhood, has number $n; $n 1; delete $n;").asDelete();
        List<ConceptSet> deletedConcepts = tx.execute(delete);

        for (ConceptSet set : deletedConcepts) {
            for (Object id : set.set()) {
                System.out.println(id);
            }
        }

        tx.commit();

        session.close();
    }

    public static void deleteInferredImplicitRelationship(GraknClient client) {
        String schemaTwoRule= "define " +
                "person sub entity, plays mother, plays son; " +
                "motherhood sub relation, relates mother, relates son, has number;" +
                "number sub attribute, datatype long;" +
                "motherhood-number sub rule, when { $motherhood isa motherhood; }, then { $motherhood has number 1; };";

        System.out.println("\nInserting schema - deleteInferredImplicitRelationship()...");
        GraknClient.Session session = client.session("ksp3");
        GraknClient.Transaction tx = session.transaction().write();

        tx.execute(Graql.parse(schemaTwoRule).asDefine());

        GraqlInsert insert = Graql.parse( "insert $m isa person; $s isa person; $d isa person; " +
                "(mother: $m, son: $d) isa motherhood;").asInsert();
        tx.execute(insert);
        tx.commit();

        tx = session.transaction().write();

        GraqlGet get = Graql.parse("match $r isa motherhood, has number $n; get $n;").asGet();
        System.out.printf("Inferred motherhoods: ");
        System.out.println(tx.execute(get));

        System.out.println("Trying to delete motherhood implicit attr relationships: ");

        GraqlDelete delete = Graql.parse("match $r ($m, $s) isa motherhood, has number $n via $imp; $n 1; delete $imp;").asDelete();
        List<ConceptSet> deletedConcepts = tx.execute(delete);

        for (ConceptSet set : deletedConcepts) {
            for (Object id : set.set()) {
                System.out.println(id);
            }
        }

        tx.commit();

        session.close();
    }


}
