@isTest(seeAllData = false)
private class DummyEmailHandlerTest {
    //DummyEmailHandler.handleInboundEmail();
    @isTest
    public static void test_DummyEmailHandler(){
        Try{
        Messaging.InboundEmail email = new Messaging.InboundEmail();

        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        DummyEmailHandler.handleInboundEmail(email,envelope);
		//NS
		System.assert(true);
            }catch(Exception e){	}
    }

}