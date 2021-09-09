/*******************************************************************
* @author: 
* @date: 
* @description: 

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Shubham Jagatap			22-07-2020				U-1903 - Replaced Hard coded values by global constants

********************************************************************/
public class SalesTeamTriggerHelper {
    public static void setPrimaryFlagBeforeInsert(List<Opportunity_Sales_Team__c> newOSTList) {
        Try{
        Set<id> oppIds = new Set<id>();  
        for(Opportunity_Sales_Team__c ost : newOSTList) {
            oppIds.add(ost.opportunity__c);
        }       
        Map<Id, List<Opportunity_Sales_Team__c>> oppToOstMap = new Map<Id, List<Opportunity_Sales_Team__c>>();
        for(Opportunity_Sales_Team__c ost : [SELECT ID, role__c,opportunity__c, primary__c FROM Opportunity_Sales_Team__c 
                                              WHERE primary__c = true and opportunity__c IN:oppIds
                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
            if(!oppToOstMap.containsKey(ost.opportunity__c)) {
            	oppToOstMap.put(ost.opportunity__c, new List<Opportunity_Sales_Team__c>());                                  
            }
            oppToOstMap.get(ost.opportunity__c).add(ost);
        }
        Integer acrCount=0;Integer cfrCount=0;Integer csrCount=0;
        for(Opportunity_Sales_Team__c ost : newOSTList) {
            acrCount=0;cfrCount=0;csrCount=0;
            if(oppToOstMap.containsKey(ost.Opportunity__c)) {
                for(Opportunity_Sales_Team__c oldost : oppToOstMap.get(ost.Opportunity__c)) {
                    //U-1903
                    if(oldost.Role__c==GlobalConstants.ACR) {acrCount++;}
                    else if(oldost.Role__c==GlobalConstants.CFR) {cfrCount++;}
                    else if(oldost.Role__c==GlobalConstants.CSR) {csrCount++;}
                }
            }
            //U-1903
            if(ost.Role__c == GlobalConstants.ACR && acrCount==0) {
                ost.Primary__c=true;
            }else if(ost.Role__c == GlobalConstants.CFR && cfrCount==0) {
                ost.Primary__c=true;
            }else if(ost.Role__c == GlobalConstants.CSR && csrCount==0) {
                ost.Primary__c=true;
            }
        }
            }catch(Exception e){	}
    }
    public static void onInsertUpdatePrimary(List<Opportunity_Sales_Team__c> newOSTList) {
        Try{
        List<Opportunity_Sales_Team__c> ostListUpdate = new List<Opportunity_Sales_Team__c>();
		Set<Id> primayOstIds = new Set<Id>();
        Set<Id> primayOppIds = new Set<Id>();
        for(Opportunity_Sales_Team__c ost : newOSTList) {
            if(ost.Primary__c) {
                primayOstIds.add(ost.Id); 
                primayOppIds.add(ost.Opportunity__c);
            }
        }
        Map<Id, List<Opportunity_Sales_Team__c>> oppToACROstMap = new Map<Id, List<Opportunity_Sales_Team__c>>();
        Map<Id, List<Opportunity_Sales_Team__c>> oppToCFROstMap = new Map<Id, List<Opportunity_Sales_Team__c>>();
        Map<Id, List<Opportunity_Sales_Team__c>> oppToCSROstMap = new Map<Id, List<Opportunity_Sales_Team__c>>();
       	for(Opportunity_Sales_Team__c ost : [SELECT ID, role__c, Primary__c,Opportunity__c FROM Opportunity_Sales_Team__c 
             								 WHERE Opportunity__c IN: primayOppIds AND Primary__c=true order by createdDate Desc
                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
            //U-1903                                     
            if(ost.Role__c == GlobalConstants.ACR) {
                if(!oppToACROstMap.containsKey(ost.Opportunity__c)) {
                    oppToACROstMap.put(ost.Opportunity__c, new List<Opportunity_Sales_Team__c>());
                }
                oppToACROstMap.get(ost.Opportunity__c).add(ost);
            }else if(ost.Role__c == GlobalConstants.CFR) {
                if(!oppToCFROstMap.containsKey(ost.Opportunity__c)) {
                    oppToCFROstMap.put(ost.Opportunity__c, new List<Opportunity_Sales_Team__c>());
                }
                oppToCFROstMap.get(ost.Opportunity__c).add(ost);
            }else if(ost.Role__c == GlobalConstants.CSR) {
            	if(!oppToCSROstMap.containsKey(ost.Opportunity__c)) {
                    oppToCSROstMap.put(ost.Opportunity__c, new List<Opportunity_Sales_Team__c>());
                }
                oppToCSROstMap.get(ost.Opportunity__c).add(ost);
            }
        }
        for(Id oppId : oppToACROstMap.keySet()) {
            if(oppToACROstMap.get(oppId).size() > 1 && primayOppIds.contains(oppId)){
                for(Opportunity_Sales_Team__c ost : oppToACROstMap.get(oppId)) {
                    if(!primayOstIds.contains(ost.Id)) {ost.Primary__c=false; ostListUpdate.add(ost);}
                }
            }
        }
        for(Id oppId : oppToCSROstMap.keySet()) {
            if(oppToCSROstMap.get(oppId).size() > 1 && primayOppIds.contains(oppId)){
                for(Opportunity_Sales_Team__c ost : oppToCSROstMap.get(oppId)) {
                    if(!primayOstIds.contains(ost.Id)) {ost.Primary__c=false;ostListUpdate.add(ost);}
                }
            }
        }
        for(Id oppId : oppToCFROstMap.keySet()) {
            if(oppToCFROstMap.get(oppId).size() > 1 && primayOppIds.contains(oppId)){
                for(Opportunity_Sales_Team__c ost : oppToCFROstMap.get(oppId)) {
                    if(!primayOstIds.contains(ost.Id)) {ost.Primary__c=false;ostListUpdate.add(ost);}
                }
            }
        }
        if(!ostListUpdate.isEmpty()) {
            update ostListUpdate;
        }
            }catch(Exception e){	}
    }
	public static void onUpdatePrimary(List<Opportunity_Sales_Team__c> newOSTList, Map<Id, Opportunity_Sales_Team__c> oldOSTMap) {
        Try{
        Set<Id> oppIds = new Set<Id>();
        List<Opportunity_Sales_Team__c> listToUpdate = new List<Opportunity_Sales_Team__c>();
        List<Id> ostIdsfuture = new List<Id>();
        List<Opportunity_Sales_Team__c>  listOSTSameFPR = new List<Opportunity_Sales_Team__c>();
        for(Opportunity_Sales_Team__c ost : newOSTList) { 
            // U-1869 Start
			 ost.IsAuto__c = false;
             if(ost.primary__c==oldOSTMap.get(ost.id).primary__c && ost.Primary__c == false) {
                   ost.IsAuto__c = true;
                   listOSTSameFPR.add(ost);
                      }
            else if(ost.primary__c!=oldOSTMap.get(ost.id).primary__c) {
                if(ost.Role__c !=oldOSTMap.get(ost.id).Role__c){
                    ost.IsAuto__c = true;
                    listOSTSameFPR.add(ost);
                }else{
                	oppIds.add(ost.Opportunity__c);    
                }
            }
            /*if(ost.primary__c!=oldOSTMap.get(ost.id).primary__c) {
                oppIds.add(ost.Opportunity__c);
            }*/
        }
        if(listOSTSameFPR.size() > 0){
                setPrimaryFlagBeforeInsert(listOSTSameFPR);       
            }
        // U-1869 End
        Map<Id, List<Opportunity_Sales_Team__c>> oppToACROstMap = new Map<Id, List<Opportunity_Sales_Team__c>>();
        Map<Id, List<Opportunity_Sales_Team__c>> oppToCFROstMap = new Map<Id, List<Opportunity_Sales_Team__c>>();
        Map<Id, List<Opportunity_Sales_Team__c>> oppToCSROstMap = new Map<Id, List<Opportunity_Sales_Team__c>>();
       	for(Opportunity_Sales_Team__c ost : [SELECT ID, role__c, Primary__c,Opportunity__c FROM Opportunity_Sales_Team__c 
             								 WHERE Opportunity__c IN: OppIds AND Primary__c=true
                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
            //U-1903                                     
            if(ost.Role__c == GlobalConstants.ACR) {
                if(!oppToACROstMap.containsKey(ost.Opportunity__c)) {
                    oppToACROstMap.put(ost.Opportunity__c, new List<Opportunity_Sales_Team__c>());
                }
                oppToACROstMap.get(ost.Opportunity__c).add(ost);
            }else if(ost.Role__c == GlobalConstants.CFR) {
                if(!oppToCFROstMap.containsKey(ost.Opportunity__c)) {
                    oppToCFROstMap.put(ost.Opportunity__c, new List<Opportunity_Sales_Team__c>());
                }
                oppToCFROstMap.get(ost.Opportunity__c).add(ost);
            }else if(ost.Role__c == GlobalConstants.CFR) {
            	if(!oppToCSROstMap.containsKey(ost.Opportunity__c)) {
                    oppToCSROstMap.put(ost.Opportunity__c, new List<Opportunity_Sales_Team__c>());
                }
                oppToCSROstMap.get(ost.Opportunity__c).add(ost);
            }
        }
        for(Opportunity_Sales_Team__c newost : newOSTList) {
            //U-1903
            if(newost.Role__c == GlobalConstants.ACR){
               if(newost.Primary__c && oppToACROstMap.containsKey(newost.Opportunity__c)) {
                    for(Opportunity_Sales_Team__c oldost: oppToACROstMap.get(newost.Opportunity__c)) {
                        oldost.primary__c = false;
                        listToUpdate.add(oldost);
                        ostIdsfuture.add(oldost.Id);
                    }
                }else {
                    //U-1903
                    if(oppToACROstMap==null || (oppToACROstMap.containsKey(newost.Opportunity__c) && oppToACROstMap.get(newost.Opportunity__c).size() == 1)) newost.addError(GlobalConstants.Error_To_Restrict_Updation_for_Primary_Sales_Team_Member);    
                }
            }else if(newost.Role__c == GlobalConstants.CFR){
                if(newost.Primary__c && oppToCFROstMap.containsKey(newost.Opportunity__c)) {
                    for(Opportunity_Sales_Team__c oldost: oppToCFROstMap.get(newost.Opportunity__c)) {
                        oldost.primary__c = false;
                        listToUpdate.add(oldost);
                        ostIdsfuture.add(oldost.Id);
                    }
                }else {
                     //U-1903
                    if(oppToCFROstMap==null || (oppToCFROstMap.containsKey(newost.Opportunity__c) && oppToCFROstMap.get(newost.Opportunity__c).size() == 1)) newost.addError(GlobalConstants.Error_To_Restrict_Updation_for_Primary_Sales_Team_Member);
                }
            }else if(newost.Role__c== GlobalConstants.CSR){
                if(newost.Primary__c && oppToCSROstMap.containsKey(newost.Opportunity__c)) {
                    for(Opportunity_Sales_Team__c oldost: oppToCSROstMap.get(newost.Opportunity__c)) {
                        oldost.primary__c = false;
                        listToUpdate.add(oldost);
                        ostIdsfuture.add(oldost.Id);
                    }   
                }else {
                    //U-1903
                   if(oppToCSROstMap==null || (oppToCSROstMap.containsKey(newost.Opportunity__c) && oppToCSROstMap.get(newost.Opportunity__c).size() == 1))newost.addError(GlobalConstants.Error_To_Restrict_Updation_for_Primary_Sales_Team_Member);
                }       
            }
          }
            if(!listToUpdate.isEmpty()){
                updateSTRecords(ostIdsfuture);
            }
        }catch(Exception e){	}
    }    
    @future
    static void updateSTRecords(List<id> ids) {
        List<Opportunity_Sales_Team__c> ostList = new List<Opportunity_Sales_Team__c>();
        for(Opportunity_Sales_Team__c ost : [SELECT Id from Opportunity_Sales_Team__c WHERE id iN : ids
                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
            ost.Primary__c=false;
            ostList.add(ost);
        }
        update ostList;
    } 
}