/**
* @File Name          : OC_AN_InternalDistributionController 
* @Description        : Handles the wrapper structure for public group selection UI and 
                	    addition of selected group records to bulletin.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 21st July
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-21-07              IBM               Initial Version
**/

public  class OC_AN_InternalDistributionController {

    @AuraEnabled
    public static groupListWrapper fetchAccountsFrmFilter ( String searchKeyword) {
        try{
            system.debug('searchKeyword:' +searchKeyword);
            groupListWrapper pubWrapperRecList = new groupListWrapper();
            Set<PublicGroupWrapper> groups = new Set<PublicGroupWrapper>();
            Set<ID> itemid = new Set<ID>();
            pubWrapperRecList.groups = groups;
            String searchWord = '%'+searchKeyword+'%';
            List<OC_AN_Public_Group__c> publicgrouplist = [SELECT Id,Name 
                                                FROM OC_AN_Public_Group__c 
                                                where Name like :searchWord];
            system.debug('publicgrp:' +publicgrouplist);
            for( OC_AN_Public_Group__c publicGrpRec :publicgrouplist)
            { 
                PublicGroupWrapper newWarpper = new PublicGroupWrapper();
                newWarpper.Name = publicGrpRec.Name;
                newWarpper.Id=publicGrpRec.Id;
                groups.add(newWarpper);
            }
            pubWrapperRecList.groups = groups;
            system.debug('sending items:' +pubWrapperRecList);
            return pubWrapperRecList;
        }
        catch(Exception e){
            throw new AuraHandledException( e.getMessage());
        }
    }
    
    private static final string SEMICOLON = ';';
    /**************************************************************************************************
* @Description : Generic Method which return the picklist values based on the Sobject and Field Name.
* @Param       : SobjectName - SobjectName for which we need picklist values.
* @Param       : PicklistField - picklist field for which values are required.
* @Return      : List of picklist values for the supplied object and field.
****************************************************************************************************/
public static list<string> getselectOptions(string SobjectName,string PicklistField){
        
    list<string> picklists=new List<string>(); 
    List<Schema.PicklistEntry> PicklistValues  = Schema.getGlobalDescribe().get(SobjectName).getDescribe().fields.getMap().get(PicklistField).getDescribe().getPicklistValues();               

    for( Schema.PicklistEntry PicklistValue : PicklistValues){
        picklists.add(string.valueof(PicklistValue.getLabel()));
    }
    return picklists;
} 
       
    
    
     /**************************************************************************************************
    * @Description : This method will return public groups under All Internal Groups.
    * @Param       : GroupSelectionWrapper checks offset and group count to display records.
    * @Return      : public group wrapper list of public group records to display.
    ****************************************************************************************************/
    @AuraEnabled
    public static groupListWrapper getPublicGroupsHierarchy(GroupSelectionWrapper  wrapper){
        try{
            groupListWrapper pubWrapperRecList = new groupListWrapper();
            pubWrapperRecList.isCompleted=wrapper.isCompleted;
            Set<PublicGroupWrapper> groups = new Set<PublicGroupWrapper>();
            pubWrapperRecList.groups = groups;
            Map<Id,OC_AN_Group_Member__c> parentGroupId = new Map<Id,OC_AN_Group_Member__c>();
            Set<Id> childGroupId = new Set<Id>();
    
            Map<Id,List<OC_AN_Group_Member__c>> parentIdToListOfChildGroups = new Map<Id,List<OC_AN_Group_Member__c>>();
            Map<Id,List<OC_AN_Group_Member__c>> childIdToListOfSubChildGroups = new Map<Id,List<OC_AN_Group_Member__c>>();
            
            AggregateResult ar = [SELECT count(Id) FROM OC_AN_Group_Member__c WHERE Id != null];
            Integer groupcount = Integer.valueOf(ar.get('expr0'));
           
            for(OC_AN_Group_Member__c parentGroupRec : [SELECT Name,id,OC_AN_Parent_Group__c,OC_AN_Parent_Group__r.Name FROM OC_AN_Group_Member__c 
                                                        WHERE OC_AN_Parent_Group__r.Name like :OC_AN_Constants.Internal_Groups ORDER BY Name ASC]){
                                                            parentGroupId.put(parentGroupRec.OC_AN_Parent_Group__c,parentGroupRec);
                                                            //system.debug('parentGroupRec' +parentGroupRec);                                          
            }
            
            //system.debug('offset' +wrapper.offsetCount);
             Integer off1=wrapper.offsetCount +1;   
            if(wrapper.offsetCount != null && wrapper.offsetCount > 0 && wrapper.offsetCount < groupcount){
                for(OC_AN_Group_Member__c parentToChild : [SELECT Id,OC_AN_Parent_Group__c,OC_AN_Child_Group__r.Name , OC_AN_Child_Group__c FROM OC_AN_Group_Member__c 
                                                            WHERE OC_AN_Parent_Group__c IN : parentGroupId.keyset() 
                                                            ORDER BY Name ASC LIMIT 10 OFFSET :off1]){
                                                                //system.debug('parentToChild' +parentToChild);
                    if(parentIdToListOfChildGroups.containsKey(parentToChild.OC_AN_Parent_Group__c) 
                       && parentIdToListOfChildGroups.get(parentToChild.OC_AN_Parent_Group__c) != null) {
                           
                           List<OC_AN_Group_Member__c> groupMember = parentIdToListOfChildGroups.get(parentToChild.OC_AN_Parent_Group__c);
                           groupMember.add(parentToChild);
                           parentIdToListOfChildGroups.put(parentToChild.OC_AN_Parent_Group__c,groupMember); 
                    }
                    else {
                           parentIdToListOfChildGroups.put(parentToChild.OC_AN_Parent_Group__c
                                                           , new List<OC_AN_Group_Member__c>{parentToChild});   
                    }

                    childGroupId.add(parentToChild.OC_AN_Child_Group__c); 
                }  
                //system.debug('childGroupId1' +childGroupId);                              
            }
                                                    
            
                                              
            else if(wrapper.offsetCount == null || (wrapper.offsetCount != null && wrapper.offsetCount == 0)){
                for(OC_AN_Group_Member__c parentToChild : [SELECT Id,OC_AN_Parent_Group__c,OC_AN_Child_Group__r.Name , OC_AN_Child_Group__c FROM OC_AN_Group_Member__c 
                                                            WHERE OC_AN_Parent_Group__c IN : parentGroupId.keyset() 
                                                             ORDER BY Name ASC LIMIT 10]){
                    if(parentIdToListOfChildGroups.containsKey(parentToChild.OC_AN_Parent_Group__c) 
                                    && parentIdToListOfChildGroups.get(parentToChild.OC_AN_Parent_Group__c) != null) {
                        List<OC_AN_Group_Member__c> groupMember = parentIdToListOfChildGroups.get(parentToChild.OC_AN_Parent_Group__c);
                        groupMember.add(parentToChild);
                        parentIdToListOfChildGroups.put(parentToChild.OC_AN_Parent_Group__c,groupMember); 
                    }else{
                        parentIdToListOfChildGroups.put(parentToChild.OC_AN_Parent_Group__c, new List<OC_AN_Group_Member__c>{parentToChild});   
                    }

                     childGroupId.add(parentToChild.OC_AN_Child_Group__c);
                }
            }   
    
    
               
            else if(groupcount == wrapper.offsetCount){
                pubWrapperRecList.isCompleted = true;
            }                                      
            
            for(OC_AN_Public_Group__c childPgs : [SELECT Id,(SELECT OC_AN_Child_Group__r.Name,OC_AN_Child_Group__c,OC_AN_Parent_Group__c FROM Parent_Group__r) FROM OC_AN_Public_Group__c  
                                                         WHERE Id IN : childGroupId  ORDER BY Name ASC]){
                                                             for(OC_AN_Group_Member__c childToSubChild : childPgs.Parent_Group__r){
                                                                if(childIdToListOfSubChildGroups.containsKey(childToSubChild.OC_AN_Parent_Group__c) 
                                                                     && childIdToListOfSubChildGroups.get(childToSubChild.OC_AN_Parent_Group__c) != null) {
                                                                    
                                                                    List<OC_AN_Group_Member__c> groupMember = childIdToListOfSubChildGroups.get(childToSubChild.OC_AN_Parent_Group__c);
                                                                    groupMember.add(childToSubChild);
                                                                    childIdToListOfSubChildGroups.put(childToSubChild.OC_AN_Parent_Group__c,groupMember); 
                                                                }else{
                                                                    childIdToListOfSubChildGroups.put(childToSubChild.OC_AN_Parent_Group__c
                                                                                                      , new List<OC_AN_Group_Member__c>{childToSubChild});   
                                                                }
                                                         }
            }
            
            for(OC_AN_Group_Member__c parentRecord : parentGroupId.values()){
                
                PublicGroupWrapper newWarpper = new PublicGroupWrapper();
                newWarpper.Name = parentRecord.OC_AN_Parent_Group__r.Name;  
                newWarpper.Id = parentRecord.OC_AN_Parent_Group__c;
                List<ChildPublicGroupWrapper> childRecordList = new List<ChildPublicGroupWrapper>();
                if(parentIdToListOfChildGroups.containsKey(parentRecord.OC_AN_Parent_Group__c)){
                    for(OC_AN_Group_Member__c childRec : parentIdToListOfChildGroups.get(parentRecord.OC_AN_Parent_Group__c) ){
                        ChildPublicGroupWrapper childWrapperRec = new ChildPublicGroupWrapper ();
                        childWrapperRec.Id = childRec.OC_AN_Child_Group__c;
                        childWrapperRec.Name = childRec.OC_AN_Child_Group__r.Name;
                        childWrapperRec.parentId = parentRecord.OC_AN_Parent_Group__c;
                        List<ChildPublicGroupWrapper> subChildRecList = new List<ChildPublicGroupWrapper> ();
                        if(childIdToListOfSubChildGroups.containsKey(childRec.OC_AN_Child_Group__c)){
                            for(OC_AN_Group_Member__c subChildRec : childIdToListOfSubChildGroups.get(childRec.OC_AN_Child_Group__c) ){
                                ChildPublicGroupWrapper subChildWrapperRec = new ChildPublicGroupWrapper ();
                                if(subChildRec.OC_AN_Child_Group__c != null){
                                subChildWrapperRec.Id = subChildRec.OC_AN_Child_Group__c;
                                subChildWrapperRec.Name = subChildRec.OC_AN_Child_Group__r.Name;
                                subChildWrapperRec.parentId = childRec.OC_AN_Child_Group__c;
                                subChildRecList.add(subChildWrapperRec);
                                }
                            } 
                        }
                        if(!subChildRecList.isEmpty()){
                            childWrapperRec.children = subChildRecList;
                        }
                        childRecordList.add(childWrapperRec);
                    }
                    newWarpper.children = childRecordList;
                }
                groups.add(newWarpper);  
                //system.debug('addchildren' +groups) ;
            }
            pubWrapperRecList.groups =groups;
           return pubWrapperRecList;
        }

        catch(Exception e){
            throw new AuraHandledException( e.getMessage());
        }
            
    } 
    
    @AuraEnabled
    public static GroupSelectionWrapper getCurrentBulletinProductsGroups(Id bulletinId){
            GroupSelectionWrapper wrapper;
            try{
                wrapper = new GroupSelectionWrapper();
                wrapper.grouprec = new Set<Id>();
                Map<Id, List<ChildPublicGroupWrapper>> productsMap = new  Map<Id, List<ChildPublicGroupWrapper>>();
               
               List<OC_AN_Bulletin_Account_Product__c> listBAP = [SELECt OC_AN_GroupId__c 
                , OC_AN_Public_Group_Name__c, OC_AN_Bulletin__c, OC_AN_RoleForA_N__c
                ,OC_AN_IsPublicGroup__c
                FROM OC_AN_Bulletin_Account_Product__c
                WHERE OC_AN_Bulletin__c = :bulletinId and
                RecordTypeId =:OC_AN_Constants.recTypeId_PublicGroup]; 
                    if(!listBAP.isEmpty()){
                        for(OC_AN_Bulletin_Account_Product__c itemBAP : listBAP)
                        wrapper.grouprec.add(itemBAP.OC_AN_GroupId__c);
                 }
                 
            }
            catch(Exception e){
                throw new AuraHandledException( e.getMessage());
            }
            return wrapper;
        }
    
    /**************************************************************************************************
    * @Description : This will be used to save  the selected public groups to the bulletin account product
    * @Param       : jsoninput - Json input from UI
    * @Param       : bulletinRecId - Id of the bulletin for which the accounts to associate
    * @Param       : selectedRole - List of rules to be associated to each public group.
    ****************************************************************************************************/
           
        @AuraEnabled
        public static String saveGroupSelection(string jsoninput,Id bulletinRecId,List<String> selectedRole){
            try{
                List<OC_AN_Bulletin_Account_Product__c> listBAPToBeAdded = new List<OC_AN_Bulletin_Account_Product__c> ();
                List<OC_AN_Bulletin_Account_Product__c> listBAPToBeDeleted ;
                String rolesToBackend;
                Map <String, Object> records   = (Map<String, Object>)json.deserializeUntyped(jsoninput);
                Map <String, Object> selectedRecords =  (Map<String, Object>) records.get('selected');
                Map <String, Object> deSelectedRecords =  (Map<String, Object>) records.get('deselected'); 
                Map<String, Id> pRVWithRecordId = new Map<String, Id>();               
                                
                List<OC_AN_Bulletin_Account_Product__c> listBAP = [select Name,id, OC_AN_GroupId__c from
                                                                    OC_AN_Bulletin_Account_Product__c
                                                                    where OC_AN_GroupId__c IN: selectedRecords.keySet() 
                                                                    AND OC_AN_Bulletin__c= :bulletinRecId];
              
                listBAPToBeDeleted = [SELECT Name,id, OC_AN_GroupId__c from 
                                        OC_AN_Bulletin_Account_Product__c
                                        where OC_AN_GroupId__c IN :deSelectedRecords.keySet() 
                                        AND OC_AN_Bulletin__c= :bulletinRecId];
           
                if(selectedRole == null || selectedRole.isEmpty()){
                    List<String> allRoles = getselectOptions(OC_AN_Constants.OC_AN_Bulletin_Account_Product,OC_AN_Constants.OC_AN_RoleForA_N);
                    rolesToBackend = String.join(allRoles, SEMICOLON);
                }
               else if(selectedRole != null || !selectedRole.isEmpty()){
                    rolesToBackend = String.join(selectedRole, SEMICOLON); 
                }

                
                for(OC_AN_Bulletin_Account_Product__c itemBAP : listBAP){
                    String itemId = '';
                    if(itemBAP.OC_AN_GroupId__c != null){
                        itemId = itemBAP.OC_AN_GroupId__c;
                        pRVWithRecordId.put(itemId, itemBAP.Id);
                    }
                }
                  
                for(String selectedRowId : selectedRecords.keyset()) {
                  Map<String,Object> mp =  (Map<String,Object>)selectedRecords.get(selectedRowId);                 
                    if(!pRVWithRecordId.containsKey(String.valueOf(mp.get('Id')))){
                        OC_AN_Bulletin_Account_Product__c  baprec = new OC_AN_Bulletin_Account_Product__c();
                        baprec.OC_AN_Public_Group_Name__c = String.valueOf(mp.get('Name'));
                        baprec.OC_AN_Bulletin__c  = bulletinRecId;
                        baprec.OC_AN_IsPublicGroup__c = true;
                        baprec.RecordTypeId = OC_AN_Constants.recTypeId_PublicGroup;
                        baprec.OC_AN_GroupId__c =String.valueOf(mp.get('Id'));
                        baprec.OC_AN_RoleForA_N__c = rolesToBackend;
                        listBAPToBeAdded.add(baprec);
                    }
                }

                if(!listBAPToBeAdded.isEmpty()){
                  upsert listBAPToBeAdded;
                  markIsInternalAsTrue(bulletinRecId);
                }
    
                if(listBAPToBeDeleted != null && listBAPToBeDeleted.size()>0){
                    delete listBAPToBeDeleted;
                }
    
                 return 'success';
            }
    
            catch(Exception e){       
                throw new AuraHandledException( e.getMessage());
            }  
        }    

        @AuraEnabled(cacheable=true)
        public static List<String> getRolesForAN(){
            try{
                List<String> optionsToReturn = new List<String>();
                for(OC_AN_AlertsAndNotification__mdt  oc : [SELECT OC_AN_Value1__c From OC_AN_AlertsAndNotification__mdt
                                                    WHERE DeveloperName =: OC_AN_Constants.OC_AN_Alerts_and_Notfication_Role_Values]){
                                                        if(oc.OC_AN_Value1__c != null){
                                                            optionsToReturn.addAll(oc.OC_AN_Value1__c.split(','));
                                                        }
                }
                return optionsToReturn;
            }
            catch(Exception e){       
                throw new AuraHandledException( e.getMessage());
            }
    }
    
    
    /**************************************************************************************************
    * @Description : This will mark the internal checkbox as true whenever an account is successfully 
    associated to bulletin.
    * @Param       : bulletinId - Id of the bulletin to mark the checbox as true
    ****************************************************************************************************/
    
    public static string markIsInternalAsTrue(Id bulletinId){
        
    List<OC_AN_Bulletin__c> bulletinToUpdate = new List<OC_AN_Bulletin__c>();
    
    for(OC_AN_Bulletin__c oc : [SELECT Id,OC_AN_IsInternal__c,OC_AN_Current_Status__c FROM
                                OC_AN_Bulletin__c Where Id =:bulletinId ]){
                                    if(oc.OC_AN_IsInternal__c == false && oc.OC_AN_Current_Status__c == OC_AN_Constants.DRAFT){
                                        oc.OC_AN_IsInternal__c = true;  
                                        bulletinToUpdate.add(oc);
                                    }
                                }
        if(!bulletinToUpdate.isEmpty()){
            try{
                update bulletinToUpdate;
               
            }
            catch(Exception e){
                EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_InternalDistributionHandler,OC_AN_Constants.markIsInternalAsTrue,null, false, e)); 
            }
        }
        return 'success';
    }
    
         //Wrapper structure for Public Group records
        public Class PublicGroupWrapper{ 
            @AuraEnabled 
            public String Name {public get;public set;}
            @AuraEnabled 
            public List<ChildPublicGroupWrapper> children {public get;public set;}
            @AuraEnabled
            Public String Id {public get;public set;}
            @AuraEnabled
            Public Id parentId {public get;public set;}   
        }
        public Class groupListWrapper{
            @AuraEnabled
            public Set<PublicGroupWrapper> groups{public get; public set;}  
            @AuraEnabled 
            public Boolean isCompleted{public get; public set;}   
        }
        //Wrapper structure for ChildPublicGroupWrapper
        public Class ChildPublicGroupWrapper{
            @AuraEnabled 
            public String Name {public get;public set;}
            @AuraEnabled
            Public String Id {public get;public set;}
            @AuraEnabled
            Public Id parentId {public get;public set;}
            @AuraEnabled
            public List<ChildPublicGroupWrapper> children {public get;public set;}   
        }
    
        public class GroupSelectionWrapper{
            @AuraEnabled 
            public Boolean isCompleted{public get; public set;}
            @AuraEnabled 
            public Integer offsetCount{public get; public set;}
            @AuraEnabled
            public Set<Id> grouprec{public get; public set;}
        }
    }