public with sharing class OpportunitySalesTeamTriggerHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static boolean isFromBachJob ;
    public static boolean isFromUploadAPI=false;
    
    public OpportunitySalesTeamTriggerHandler (boolean isExecuting, integer size){
        this.isExecuting = isExecuting;
        batchSize = size;
    }
    //D-1729
    public void OnBeforeInsert(List<Opportunity_Sales_Team__c> newOppSalesTeam){
        Try{
        OpportunitySalesTeamHelper.restrictSalesTeamOnClosedOppty(newOppSalesTeam);  
            }catch(Exception e){	}
    }
   public void onAfterInsert(List<Opportunity_Sales_Team__c> newOppSalesTeam){
       Try{
        OpportunitySalesTeamHelper.updateSalesteamOnOpportunity(newOppSalesTeam); 
        OpportunitySalesTeamHelper.insertOpportunityTeamMembersOnOpportunity(newOppSalesTeam);
		//U-1938
        OpportunitySalesTeamHelper.updatePrimaryCore3OnSDR(newOppSalesTeam);
           }catch(Exception e){	}
    }
     //D-1729
    public void OnBeforeUpdate( List<Opportunity_Sales_Team__c> newOppSalesTeam, List<Opportunity_Sales_Team__c> oldOppSalesTeam, Map<ID, Opportunity_Sales_Team__c> newOppSalesTeamMap , Map<ID, Opportunity_Sales_Team__c> oldOppSalesTeamMap ){
        Try{
        OpportunitySalesTeamHelper.restrictSalesTeamOnClosedOppty(newOppSalesTeam); 
            }catch(Exception e){	}
    }
   public void onAfterUpdate( List<Opportunity_Sales_Team__c> newOppSalesTeam, List<Opportunity_Sales_Team__c> oldOppSalesTeam, Map<ID, Opportunity_Sales_Team__c> newOppSalesTeamMap , Map<ID, Opportunity_Sales_Team__c> oldOppSalesTeamMap ){
       Try{ 
       OpportunitySalesTeamHelper.updateSalesteamOnOpportunity(newOppSalesTeam);
	   // U-1938
       OpportunitySalesTeamHelper.updatePrimaryCore3OnSDR(newOppSalesTeam);
           }catch(Exception e){	}
    }
    public void onBeforeDelete( List<Opportunity_Sales_Team__c> newOppSalesTeam,List<Opportunity_Sales_Team__c> oldOppSalesTeam, Map<ID, Opportunity_Sales_Team__c> oldOppSalesTeamMap){
        Try{
        OpportunitySalesTeamHelper.removeEmployeeFromOpptyTeam(oldOppSalesTeam);
            }catch(Exception e){	}
    }
    public void onAfterDelete(  List<Opportunity_Sales_Team__c> newOppSalesTeam,List<Opportunity_Sales_Team__c> oldOppSalesTeam, Map<ID, Opportunity_Sales_Team__c> oldOppSalesTeamMap ){
       Try{
        OpportunitySalesTeamHelper.updateSalesteamOnOpportunity(newOppSalesTeam);
        OpportunitySalesTeamHelper.clearSalesTeamAssignmentOnOppty(oldOppSalesTeam);
           }catch(Exception e){	}
    }
    }