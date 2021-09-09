global class GSTSearchBatchScheduler implements schedulable {
	global void execute(Schedulablecontext sc) {
		GSTSearchBatch acc = new GSTSearchBatch();
		//Database.executeBatch(instance,size);
		Database.executeBatch(acc, 200);
	}
}