import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.factory.Nd4j;

public class Main {

    public static void main(String[] args) {
        INDArray identity = Nd4j.eye(100);
        Number sum = identity.sumNumber();
        System.out.println(sum);

    }
}
