public class ApprovalClass {
  @Auraenabled
    public static string sendrecforApproval(Id recId)
        {
            string statusCheck = 'info Complete';
            Id testrecId = recId;
            Test_Button__c testrec = [ SELECT Name, Test_Approval__c, Test_Type__c, Text_Organisation__c
                             FROM Test_Button__c
                             WHERE Id = :testrecId ];
            if ( testrec.Name == null
                 || testrec.Test_Approval__c == null
                 || testrec.Test_Type__c == null
                 || testrec.Text_Organisation__c == null
               ) {
                statusCheck ='info not Complete';
                return statusCheck;
            }else if(testrec.Name != null
                 || testrec.Test_Approval__c != null
                 || testrec.Test_Type__c != null
                     || testrec.Text_Organisation__c != null){
                        // submitForApproval(testrec);
                        system.debug('inside success method');
                     }
            return statusCheck;
        }
    
   /* public static void submitForApproval(Test_Button__c testbutton){
        
      // Create an approval request for the Test_Button__c
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically using Trigger');
        req1.setObjectId(testbutton.id);
       // req1.setNextApproverIds(new Id[] {testbutton.Next_Approver__c});

        // Submit the approval request for the Test_Button__c
        Approval.ProcessResult result = Approval.process(req1);
        
    }*/
}