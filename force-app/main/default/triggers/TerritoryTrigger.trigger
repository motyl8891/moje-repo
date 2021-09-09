/******************************************************************************************
*
*            @author       : Ankit Jain
*            @date         : 08-07-2020
@description  : TerritoryTrigger
Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-                                                                                     -                                                                                     Original Version
Ankit Jain                08-07-2020            U-1921,U-1990

******************************************************************************************/
trigger TerritoryTrigger on Territory2 (after update, after insert){
    if ( Trigger.isAfter){
        if(Trigger.isUpdate){
            TerritoryTriggerHandler.OnAfterUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }
        if(Trigger.isInsert){
            TerritoryTriggerHandler.onAfterInsert(trigger.NewMap ,trigger.Old);
        }
    }
}