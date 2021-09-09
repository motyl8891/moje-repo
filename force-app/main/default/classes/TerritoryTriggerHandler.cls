/******************************************************************************************
*
*            @author       : Ankit Jain
*            @date         : 08-07-2020
@description  : Handler Class for TerritoryTrigger
@testClass    : TerritoryTriggerHelperTest

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-                                                                                     -                                                                                     Original Version
Ankit Jain                  08-07-2020           U-1921,U-1990

******************************************************************************************/
public class TerritoryTriggerHandler {
/****************************************************************
* @author: Ankit Jain,Manu Singhal
* @date: 08-07-2020
* @param: oldTerritory,newTerritoryMap
* @description: U-1921 & U-1990 This method will be called on after insert trigger
*****************************************************************/
    public static void onAfterInsert( Map<ID, Territory2 > newTerritoryMap, List<Territory2 > oldTerritory){
        Try{
        	Map<id, Territory2> oldTerritoryMap = new Map<id, Territory2>();
            TerritoryTriggerHelper.updateCrgSharing(oldTerritoryMap,newTerritoryMap);
            }catch(Exception e){	}
    } 
/****************************************************************
* @author: Ankit Jain,Manu Singhal
* @date: 08-07-2020
* @param: newTerritory,oldTerritory,newTerritoryMap,oldTerritoryMap
* @description: U-1921 & U-1990 This method will be called on after update trigger.
*****************************************************************/
	public static void onAfterUpdate( List<Territory2 > newTerritory, List<Territory2 > oldTerritory, Map<ID, Territory2 > newTerritoryMap , Map<ID, Territory2 > oldTerritoryMap ){
        Try{
            TerritoryTriggerHelper.updateCrgSharing(oldTerritoryMap,newTerritoryMap);
            }catch(Exception e){	}
    }  
}