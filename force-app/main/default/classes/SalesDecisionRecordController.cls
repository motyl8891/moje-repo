public class SalesDecisionRecordController {
    @AuraEnabled
    public static boolean opptyOwnerCheck(String parentId)
    {
        boolean flag = false;
        Try{
        Id salesOpProfileId = GlobalConstants.getProfileId(GlobalConstants.Ericsson_Sales_Operations);
        Sales_Decision_Record__c salesDecision = [select id,Opportunity__r.OwnerId from Sales_Decision_Record__c 
                                                  where id =: parentId limit 1];
        if(UserInfo.getUserId()!=salesDecision.Opportunity__r.OwnerId && UserInfo.getProfileId()!=salesOpProfileId)
            flag = true;
            }catch(Exception e){	}
        return flag;
    }
    @AuraEnabled
    public static boolean sendEmailToDecisionMakers(String parentId)
    {
        Boolean isEmailSent = false;
        Try{
        List<Sales_Decision_Maker__c> decisionMakeList = new List<Sales_Decision_Maker__c>();
        for(Sales_Decision_Maker__c decisionMaket : [Select Id,Notification__c,Approval_Status__c from Sales_Decision_Maker__c
                                                     where Sales_Decision_Record__c =: parentId])       
        {
            /*if(decisionMaket.Approval_Status__c == 'Approved' || decisionMaket.Approval_Status__c == 'Requested')
            {
                decisionMaket.Notification__c = true;
                decisionMakeList.add(decisionMaket);
            }*/
            if(decisionMaket.Approval_Status__c == GlobalConstants.TOBEREQUESTED)
            {
                decisionMaket.Notification__c = true;
                decisionMakeList.add(decisionMaket);
            }
        }
        if(!decisionMakeList.isEmpty()){
            isEmailSent = true;
            database.update(decisionMakeList,false); 
        }
            }catch(Exception e){	}
        return isEmailSent;
    }
}