global class SendEmailToNotifyCloseDateBatchScheduler implements schedulable {
    global void execute(Schedulablecontext sc) {
        SendEmailToNotifyCloseDateBatch b = new SendEmailToNotifyCloseDateBatch();
        Database.executeBatch(b, 200);
    }
}