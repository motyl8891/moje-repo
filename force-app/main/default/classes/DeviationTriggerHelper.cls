/****************************************************************
* @author: Pallavi Patil 
* @date: 21-11-2020
* @User Story: U-2120
* @description: This class is a helper class for DeviationTrigger 

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Pallavi Patil			11-11-2020				U-2120 - Add deviation data for EBD approval

*****************************************************************/
public class DeviationTriggerHelper {
/****************************************************************
* @author: Pallavi Patil/Biswajit Sahoo
* @date: 11-11-2020 and 14-01-2021
* @param: U-2120 and U-2291
* @description: This method will Update and concatinate Product group as well as Question(latest)
				on deviationtypegroup
***********************************************************************/  
   public static void updateProductGroup(List<Deviation__c> devList, Map<Id,Deviation__c> oldDevMap)
    {
        try{
            List<DeviationTypeGroup__c> updateDevgrpList = new List<DeviationTypeGroup__c>();
            Set<Id> devUpdatedSet = new Set<Id>();
            for(Deviation__c dev : devList)
            {
                if(dev.Product_Group__c != null || dev.Question__c != NULL)
                {
                    devUpdatedSet.add(dev.DeviationTypeGroup__c);
                }
            }
            
            If(devUpdatedSet!= NULL){
                for(DeviationTypeGroup__c devgrp :[select id,ProductGroup__c,Questions__c,
												(select id,Product_Group__c,Question__c from Deviations__r )
                                                from DeviationTypeGroup__c 
                                                   WHERE Id IN:devUpdatedSet
                                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())
                                                  ])
                {
                     String concatinateProdgrp = GlobalConstants.BLANK;
                     String concatinatequestions = GlobalConstants.BLANK;
                    for(Deviation__c devs : devgrp.Deviations__r )
                    {  
                        if(devs.Product_Group__c != NULL){
                        if(concatinateProdgrp.equals(GlobalConstants.BLANK)){
                            concatinateProdgrp = devs.Product_Group__c;
                        }
                        else{                        
                            concatinateProdgrp = concatinateProdgrp+ GlobalConstants.SPACE +  GlobalConstants.SEMICOLON + GlobalConstants.SPACE +devs.Product_Group__c; 
                                                   } 
                           }
                     devgrp.ProductGroup__c = concatinateProdgrp;
                    
                        if(devs.Question__c != NULL){
                        if(concatinatequestions.equals(GlobalConstants.BLANK)){
                            concatinatequestions = devs.Question__c;
                        }
                        else{                        
                            concatinatequestions = concatinatequestions+ GlobalConstants.SPACE +  GlobalConstants.SEMICOLON + GlobalConstants.SPACE +devs.Question__c; 
                                                   } 
                     }
					  devgrp.Questions__c = concatinatequestions;
                      }
                    updateDevgrpList.add(devgrp);
                    
                }
                
            }
            
            if(!updateDevgrpList.isEmpty()){
                database.update(updateDevgrpList);  
            }
        }
        catch(Exception e)
        {
            EventLog.createLog(new EventLog.Error(GlobalConstants.DeviationTriggerHelper,
                                                   GlobalConstants.updateProductGroup, GlobalConstants.DeviationTriggerHelper, true, e));
            
        }
    }
/****************************************************************
* @author: Biswajit Sahoo
* @date:19-01-2021
* @param:  U-2370
* @description: This method will Update and concatinate Product group to overcomee limitation of 
				Product Group of Deviation Type Comparison and BA BDGS
***********************************************************************/ 
  
	public static void updateProductGroupOnDeviation(List<Deviation__c> devList,Map<Id,Deviation__c> oldDevMap){
        try{
            Map<Id, Id> devUpdatedBDGSMap = new Map<Id,Id>();
            Map<Id, Id> devUpdatedNetEffectiveMap = new Map<Id,Id>();
            Set<String> productGroupSet = new Set<String>();
            String concatinateProdgrp1 = GlobalConstants.BLANK;
            String concatinateProdgrp2 = GlobalConstants.BLANK;
            Map<Id,DeviationTypeGroup__c> updateDevgrpMap = new Map<Id,DeviationTypeGroup__c>();
            for(Deviation__c dev : devList)
            {
                if(dev.Product_Group__c != null && !productGroupSet.contains(dev.Product_Group__c) &&
				(dev.BDGSComparisonPriceDTG__c != NULL || dev.MELANetEffectiveDeviationTypeGroup__c != NULL))
                {
                    devUpdatedBDGSMap.put(dev.Id,dev.BDGSComparisonPriceDTG__c);
                    devUpdatedNetEffectiveMap.put(dev.Id,dev.MELANetEffectiveDeviationTypeGroup__c);
				}
            	}
                for(DeviationTypeGroup__c devType : [SELECT Id,ProductGroup__c,
                                                     (SELECT id,Product_Group__c FROM PP_Deviations_BDGSCompPrice__r )
                                                    FROM DeviationTypeGroup__c
                                                     WHERE Id IN:devUpdatedBDGSMap.values()
                                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    for(Deviation__c devs1 : devType.PP_Deviations_BDGSCompPrice__r)
                    {
                        if(devs1.Product_Group__c != NULL){
                        if(concatinateProdgrp1.equals(GlobalConstants.BLANK)){
                            concatinateProdgrp1 = devs1.Product_Group__c;
                        }
                        else{                        
                            concatinateProdgrp1 = concatinateProdgrp1+ GlobalConstants.SPACE +  GlobalConstants.SEMICOLON + GlobalConstants.SPACE +devs1.Product_Group__c; 
                                                   } 
                           }
                    }
                    devType.ProductGroup__c = concatinateProdgrp1;
                    updateDevgrpMap.put(devType.Id,devType);
                }
            for(DeviationTypeGroup__c devType1 : [select id,ProductGroup__c, 
                                                  (select Id,Product_Group__c from PP_Deviations_MELAEffective__r)
                                                  FROM DeviationTypeGroup__c
                                                  WHERE Id IN:devUpdatedNetEffectiveMap.values()
                                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())
                                                    ] )
                {
                     for(Deviation__c devs2 : devType1.PP_Deviations_MELAEffective__r)
                    {
                        if(devs2.Product_Group__c != NULL){
                        if(concatinateProdgrp2.equals(GlobalConstants.BLANK)){
                            concatinateProdgrp2 = devs2.Product_Group__c;
                        }
                        else{                        
                            concatinateProdgrp2 = concatinateProdgrp2+ GlobalConstants.SPACE +  GlobalConstants.SEMICOLON + GlobalConstants.SPACE +devs2.Product_Group__c; 
                           } 
                           }
                    }
                    devType1.ProductGroup__c = concatinateProdgrp2;
                    updateDevgrpMap.put(devType1.Id,devType1);
                    }

             if(!updateDevgrpMap.isEmpty()){
                  database.update(updateDevgrpMap.values());
             }
            
        }catch(exception e){
           
            EventLog.createLog(new EventLog.Error(GlobalConstants.DeviationTriggerHelper,
                                                   GlobalConstants.updateProductGroupOnDeviation, GlobalConstants.DeviationTriggerHelper, true, e));
                    
        }
    }
    
}