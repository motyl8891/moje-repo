public class CustomerUnitATSRecalcBatchScheduler{ 

    public static void scheduleBatches(){
        Try{
        CustomerUnitATSRecalcBatch c1 = new CustomerUnitATSRecalcBatch();
        String sch1 = '0 0 5 * * ?';
        System.schedule('CustomerUnitATSRecalcBatchDaily5AM', sch1, c1);
            }catch(Exception e){	}
    }
}