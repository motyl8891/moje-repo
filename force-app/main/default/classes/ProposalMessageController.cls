public class ProposalMessageController {
    
    @AuraEnabled
    public static String getProposalIdForDevType(String propID)
            {
        String message;

        try{      
            
          List<Deviation__c> devList =  [SELECT Id, DeviationType__c,BusinessArea__c,
                                         Proposal__r.Opportunity__r.MarketArea__c, Product_Group__c
              							 FROM Deviation__c 
               							WHERE Proposal__c =: propID
                  						 AND Proposal__r.Opportunity__r.MarketArea__c = 'MELA'
                                         AND BusinessArea__c = 'BDGS'
                                         ];
                   IF(devList != NULL)
               {
                   For(Deviation__c dev : devList )
                   {
                      If( dev.DeviationType__c!= NULL && dev.DeviationType__c == GlobalConstants.Comparison_Price && dev.Product_Group__c != null &&
                         (dev.Product_Group__c.contains(GlobalConstants.Communication_Services) ||
                          dev.Product_Group__c.contains(GlobalConstants.User_Management) ||
                          dev.Product_Group__c.contains(GlobalConstants.Evolved_Pack_Core)))
                          
                      {
                          message  = GlobalConstants.MELA_Effective_Message;
                      }
                   }
               }
            
           
        }
            
        catch(Exception e)
        {
            EventLog.createLog(new EventLog.Error(GlobalConstants.ProposalMessageController, 
                               GlobalConstants.getProposalIdForDevType, GlobalConstants.ProposalMessageController, true, e)); 
        }
     
        return message; 
            }
    }