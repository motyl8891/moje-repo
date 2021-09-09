public class TestApprovalFlow {
    
    @invocableMethod
    public static List<string> getRecordDetails(List<Id> recordId){
        List<String> stringToReturn = new List<String>();
        system.debug('recordId======>'+recordId);
        
        Test_Button__c testrec = [ SELECT Name, Test_Approval__c, Test_Type__c, Text_Organisation__c
                             FROM Test_Button__c
                             WHERE Id IN :recordId LIMIT 1];
            if ( testrec.Name == null
                 || testrec.Test_Approval__c == null
                 || testrec.Test_Type__c == null
                 || testrec.Text_Organisation__c == null
               ) {
                   system.debug('inside this method');
                stringToReturn.add('info not Complete');
               }else if(testrec.Name != null
                 || testrec.Test_Approval__c != null
                 || testrec.Test_Type__c != null
                        || testrec.Text_Organisation__c != null){
                           stringToReturn.add('info Complete'); 
                        }
                        // submitForApproval(testrec);
                     
        system.debug('inside this method');
        return stringToReturn;
        
    }

}