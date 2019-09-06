package grakn.testing;

public class Main {
    public static void main(String[] args) {

        long startTime = System.currentTimeMillis();
        double total = 0;
        for (int rep = 0; rep < 200; rep++) {
            total += runOnce();
        }
        // must print out or the optimiser will probably remove the whole loop
        System.out.println("Total value: " + total);
        System.out.println("finished in: " + (System.currentTimeMillis() - startTime)/1000.0 + " seconds");
    }

    private static double runOnce() {
        long start = 123123;
        double v = warmupMaths(start, 10000);
        double next = Math.floor(v);
        for (int i = 0; i < 2000; i++) {
            next = Math.ceil(sinCos(next)) + warmupMaths((long) Math.floor(next), i);
        }
        return next;
    }

    private static double warmupMaths(long start, int repetitions) {
        long x = 1;
        double total = 0.0;
        for (int i = 0; i < repetitions; i++) {
            x *= 1000003;
            x ^= (start + i);
            total += x + Math.sin(Math.sqrt(Math.abs(x)));
        }
        return total;
    }

    private static double sinCos(double initial) {
        double v1 = Math.cos(Math.PI * initial);
        double v2 = Math.cos(v1);
        double v3 = v1 + v2 + Math.sin(v1 * v2);
        double v4 = Math.min(1.00003, v1 + v2 + Math.sin(v1 * v2)) + v3;
        return Math.atan(v4) + Math.tan(0.45123) + Math.cos(v1) + Math.sin(v2) + Math.atan(v3);
    }
}
