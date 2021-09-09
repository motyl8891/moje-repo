/******************************************************************************************
*
*      	@author       : 
*      	@date         : 
@description  : Handler Class for TagTrigger
@testClass    : OpportunityTagHelperTest

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Ankit Jain					26-06-2020				U-2907 - onAfterUpdate Method added

******************************************************************************************/

public without sharing class TagTriggerHandler {
    /****************************************************************
* @author: Ankit Jain  
* @date: 26-06-2020
* @User Story: D-2907
*****************************************************************/
    public static void onAfterUpdate( List<Tags__c> newTag, List<Tags__c> oldTag, Map<ID, Tags__c> newTagMap , Map<ID, Tags__c> oldTagMap ){
            TagTriggerHelper.updateTagOnOpportunity(oldTagMap,newTagMap);
    } 
}