public without sharing class   Test_Internal {
    
   
    
    @AuraEnabled
   public static string /*groupListWrapper*/ getPublicGroupsHierarchy(GroupSelectionWrapper  wrapper){
       system.debug('GET PRODUCTS:' +wrapper);
    //PublicGroupWrapper PublicGroupWrapper = new PublicGroupWrapper();
    //PublicGroupWrapper.isCompleted = wrapper.isCompleted;
        //List<PublicGroupWrapper> pubWrapperRecList = new List<PublicGroupWrapper>();
        groupListWrapper pubWrapperRecList = new groupListWrapper();
        pubWrapperRecList.isCompleted=wrapper.isCompleted;
        //pubWrapperRecList.add(PublicGroupWrapper);
        Set<PublicGroupWrapper> groups = new Set<PublicGroupWrapper>();
        pubWrapperRecList.groups = groups;

        Map<Id,OC_AN_Group_Member__c> parentGroupId = new Map<Id,OC_AN_Group_Member__c>();
        Set<Id> childGroupId = new Set<Id>();

        Map<Id,List<OC_AN_Group_Member__c>> parentIdToListOfChildGroups = new Map<Id,List<OC_AN_Group_Member__c>>();
        Map<Id,List<OC_AN_Group_Member__c>> childIdToListOfSubChildGroups = new Map<Id,List<OC_AN_Group_Member__c>>();
        
        AggregateResult ar = [SELECT count(Id) FROM OC_AN_Group_Member__c WHERE Id != null /*AND OC_AN_Parent_Group__r.Name like '%Internal Groups%'*/];
        Integer groupcount = Integer.valueOf(ar.get('expr0'));
        system.debug('PROUDCT COUNT' +groupcount+'OFFESTCOUNT:' +wrapper.offsetCount);


       
        for(OC_AN_Group_Member__c parentGroupRec : [SELECT Name,id,OC_AN_Parent_Group__c,OC_AN_Parent_Group__r.Name FROM OC_AN_Group_Member__c 
                                                    WHERE OC_AN_Parent_Group__r.Name like '%Internal Groups%' ORDER BY Name ASC]){
                                                        parentGroupId.put(parentGroupRec.OC_AN_Parent_Group__c,parentGroupRec);
                                                        
                                                    }
                                                    
                                                

       
            
        if(wrapper.offsetCount != null && wrapper.offsetCount > 0 && wrapper.offsetCount < groupcount){
            for(OC_AN_Group_Member__c parentToChild : [SELECT Id,OC_AN_Parent_Group__c,OC_AN_Child_Group__r.Name , OC_AN_Child_Group__c FROM OC_AN_Group_Member__c 
            WHERE OC_AN_Parent_Group__c IN : parentGroupId.keyset()   ORDER BY Name ASC LIMIT 10 OFFSET :wrapper.offsetCount]){
               // system.debug('parentGroupId.keyset()' +parentGroupId.keyset());
                if(parentIdToListOfChildGroups.containsKey(parentToChild.OC_AN_Parent_Group__c) 
                   && parentIdToListOfChildGroups.get(parentToChild.OC_AN_Parent_Group__c) != null) {
                       
                       List<OC_AN_Group_Member__c> groupMember = parentIdToListOfChildGroups.get(parentToChild.OC_AN_Parent_Group__c);
                       //system.debug(' parentIdToListOfChildGroups.get(parentToChild.OC_AN_Parent_Group__c);' + parentIdToListOfChildGroups.get(parentToChild.OC_AN_Parent_Group__c));
                       groupMember.add(parentToChild);
                       parentIdToListOfChildGroups.put(parentToChild.OC_AN_Parent_Group__c,groupMember); 
                   }else{
                       parentIdToListOfChildGroups.put(parentToChild.OC_AN_Parent_Group__c
                                                       , new List<OC_AN_Group_Member__c>{parentToChild});   
                   }
                childGroupId.add(parentToChild.OC_AN_Child_Group__c);
               
            }                                      
          }
                                                
        
                                          
     else if(wrapper.offsetCount == null || (wrapper.offsetCount != null && wrapper.offsetCount == 0)){
        for(OC_AN_Group_Member__c parentToChild : [SELECT Id,OC_AN_Parent_Group__c,OC_AN_Child_Group__r.Name , OC_AN_Child_Group__c FROM OC_AN_Group_Member__c 
                                                   WHERE OC_AN_Parent_Group__c IN : parentGroupId.keyset()  ORDER BY Name ASC LIMIT 10]){
                                                      // system.debug('parentGroupId.keyset()' +parentGroupId.keyset());
                                                       if(parentIdToListOfChildGroups.containsKey(parentToChild.OC_AN_Parent_Group__c) 
                                                          && parentIdToListOfChildGroups.get(parentToChild.OC_AN_Parent_Group__c) != null) {
                                                              
                                                              List<OC_AN_Group_Member__c> groupMember = parentIdToListOfChildGroups.get(parentToChild.OC_AN_Parent_Group__c);
                                                              //system.debug(' parentIdToListOfChildGroups.get(parentToChild.OC_AN_Parent_Group__c);' + parentIdToListOfChildGroups.get(parentToChild.OC_AN_Parent_Group__c));
                                                              groupMember.add(parentToChild);
                                                              parentIdToListOfChildGroups.put(parentToChild.OC_AN_Parent_Group__c,groupMember); 
                                                          }else{
                                                              parentIdToListOfChildGroups.put(parentToChild.OC_AN_Parent_Group__c
                                                                                              , new List<OC_AN_Group_Member__c>{parentToChild});   
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
            //ChildPublicGroupWrapper childRecordList = new ChildPublicGroupWrapper();
            if(parentIdToListOfChildGroups.containsKey(parentRecord.OC_AN_Parent_Group__c)){
                for(OC_AN_Group_Member__c childRec : parentIdToListOfChildGroups.get(parentRecord.OC_AN_Parent_Group__c) ){
                    ChildPublicGroupWrapper childWrapperRec = new ChildPublicGroupWrapper ();
                    childWrapperRec.Id = childRec.OC_AN_Child_Group__c;
                    childWrapperRec.Name = childRec.OC_AN_Child_Group__r.Name;
                    childWrapperRec.parentId = parentRecord.OC_AN_Parent_Group__c;
                    //childWrapperRec.rootRecId = parentRecord.OC_AN_Parent_Group__c;
                    List<ChildPublicGroupWrapper> subChildRecList = new List<ChildPublicGroupWrapper> ();
                    //ChildPublicGroupWrapper subChildRecList = new ChildPublicGroupWrapper ();
                    if(childIdToListOfSubChildGroups.containsKey(childRec.OC_AN_Child_Group__c)){
                        for(OC_AN_Group_Member__c subChildRec : childIdToListOfSubChildGroups.get(childRec.OC_AN_Child_Group__c) ){
                            ChildPublicGroupWrapper subChildWrapperRec = new ChildPublicGroupWrapper ();
                            if(subChildRec.OC_AN_Child_Group__c != null){
                            subChildWrapperRec.Id = subChildRec.OC_AN_Child_Group__c;
                            subChildWrapperRec.Name = subChildRec.OC_AN_Child_Group__r.Name;
                            subChildWrapperRec.parentId = childRec.OC_AN_Child_Group__c;
                            //subChildWrapperRec.rootRecId = parentRecord.OC_AN_Parent_Group__c;
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
            //pubWrapperRecList.add(newWarpper);
            groups.add(newWarpper);


        }
        pubWrapperRecList.groups =groups;

        
        system.debug('childGroupId=====>'+childGroupId);
        system.debug('parentIdToListOfChildGroups======>'+parentIdToListOfChildGroups);
        system.debug('childIdToListOfSubChildGroups====>'+childIdToListOfSubChildGroups);
        system.debug('Serializae String ===>'+JSON.serialize(pubWrapperRecList,true));
        system.debug('returing list ===>' +pubWrapperRecList);
        
        return JSON.serialize(pubWrapperRecList,true);
       //return pubWrapperRecList;
        
    } 

    @AuraEnabled
    public static GroupSelectionWrapper getCurrentBulletinProductsGroups(Id bulletinId){
        system.debug('BUlletinID' +bulletinId);
        GroupSelectionWrapper wrapper;
        try{
            wrapper = new GroupSelectionWrapper();
            wrapper.grouprec = new Set<Id>();
            Map<Id, List<ChildPublicGroupWrapper>> productsMap = new  Map<Id, List<ChildPublicGroupWrapper>>();
	       
		   List<OC_AN_Bulletin_Account_Product__c> listBAP = [SELECt OC_AN_GroupId__c 
            , OC_AN_Public_Group_Name__c, OC_AN_Bulletin__c, OC_AN_RoleForA_N__c
            ,OC_AN_IsPublicGroup__c
            FROM OC_AN_Bulletin_Account_Product__c
            WHERE OC_AN_Bulletin__c = :bulletinId and RecordTypeId = '0121l000000DgjoAAC']; 
            system.debug('listBAP' +listBAP);



				if(!listBAP.isEmpty()){
                    system.debug('inside if' );
                    for(OC_AN_Bulletin_Account_Product__c itemBAP : listBAP)
                    wrapper.grouprec.add(itemBAP.OC_AN_GroupId__c);
                    system.debug('WRAPPER' +wrapper );
             }
			 
        }
        catch(Exception e){
            throw new AuraHandledException( e.getMessage());
        }
        system.debug('GetCurrentSelection' +wrapper);
        return wrapper;
	}


        /** Save Group to Bulletin Product Account **/
    @AuraEnabled
    public static String saveGroupSelection(string jsoninput,Id bulletinRecId){
        system.debug('SELECTED RECORDS' +jsoninput);
        List<OC_AN_Bulletin_Account_Product__c> listBAPToBeAdded = new List<OC_AN_Bulletin_Account_Product__c> ();
        List<OC_AN_Bulletin_Account_Product__c> listBAPToBeDeleted ;
        try{
            Id productRTId = Schema.SObjectType.OC_AN_Bulletin_Account_Product__c.getRecordTypeInfosByDeveloperName().get('OC_AN_Public_Group').getRecordTypeId();
            Map <String, Object> records   = (Map<String, Object>)json.deserializeUntyped(jsoninput);
            //system.debug(' RECORDS' +records);
            Map <String, Object> selectedRecords =  (Map<String, Object>) records.get('selected');
            //system.debug(' selectedRecords' +selectedRecords);
            Map <String, Object> deSelectedRecords =  (Map<String, Object>) records.get('deselected');
            system.debug(' deSelectedRecords' +deSelectedRecords);
            
            List<OC_AN_Bulletin_Account_Product__c> listBAP = [select Name,id, OC_AN_GroupId__c from OC_AN_Bulletin_Account_Product__c
                                                         where OC_AN_GroupId__c IN: selectedRecords.keySet()];
          
            listBAPToBeDeleted = [SELECT Name,id, OC_AN_GroupId__c from OC_AN_Bulletin_Account_Product__c
            where OC_AN_GroupId__c IN :deSelectedRecords.keySet()];
            system.debug(' listBAPToBeDeleted ' +listBAPToBeDeleted);  
              
                Map<String, Id> pRVWithRecordId = new Map<String, Id>();
              {
                //system.debug(' inside map pRVWithRecordId ');
                for(OC_AN_Bulletin_Account_Product__c itemBAP : listBAP){
                    String itemId = '';
                    //system.debug(' inside map pRVWithRecordId 2 listBAP :==> ' +listBAP);
                    if(itemBAP.OC_AN_GroupId__c != null)
                   /// system.debug(' inside map pRVWithRecordId 3');
                        itemId = itemBAP.OC_AN_GroupId__c;
                        pRVWithRecordId.put(itemId, itemBAP.Id);
                        //system.debug(' pRVWithRecordId ' +pRVWithRecordId);
                }
              }
              for(String selectedRowId : selectedRecords.keyset()) {
              Map<String,Object> mp =  (Map<String,Object>)selectedRecords.get(selectedRowId);
              //system.debug(' MPMAP' +mp);
             
              if(!pRVWithRecordId.containsKey(String.valueOf(mp.get('Id')))){
                  //system.debug('This is  inside duplicate IF statement');
              OC_AN_Bulletin_Account_Product__c  baprec = new OC_AN_Bulletin_Account_Product__c();
              baprec.OC_AN_Public_Group_Name__c = String.valueOf(mp.get('Name'));
              baprec.OC_AN_Bulletin__c  = bulletinRecId;
              baprec.OC_AN_IsPublicGroup__c = true;
              baprec.RecordTypeId = productRTId;
              baprec.OC_AN_GroupId__c =String.valueOf(mp.get('Id'));
              //system.debug('  baprec.OC_AN_Public_Group_Name__c' + baprec.OC_AN_Public_Group_Name__c);
              listBAPToBeAdded.add(baprec);
              }

              }
              if(!listBAPToBeAdded.isEmpty()){
              Insert listBAPToBeAdded;
              }

              if(listBAPToBeDeleted != null && listBAPToBeDeleted.size()>0){
                delete listBAPToBeDeleted;
              }
             // system.debug(' listBAPToBeAdded' +listBAPToBeAdded);
             system.debug(' listBAPToBeDeleted' +listBAPToBeDeleted);




        }

        catch(Exception e){       
            //throw new AuraHandledException(e.getMessage() + 'listBAPToBeAdded: ' + listBAPToBeAdded + '\nlistBAPToBeDeleted: ' + listBAPToBeDeleted);
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
        @AuraEnabled 
        public Boolean isCompleted{public get; public set;}
       
        
    }
    public class groupListWrapper{
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
       // @AuraEnabled
        // Public Id rootRecId {public get;public set;}
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