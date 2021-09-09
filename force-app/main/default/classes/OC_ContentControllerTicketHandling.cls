/**
* @File Name          : OC_ContentControllerTicketHandling
* @Description        : Controller class for the aura component omnichannelthemeContentSubContainerTickets & omnichannelthemeContentSubContainerTicket
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 20th July 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-07-20                 IBM                   Initial Version
* 2.0        2020-08-17                 IBM                   R20_09 U-2013 Fourth Quadrant on MyWorkspace to show Recent Tickets
* 3.0        2020-08-18                 IBM                   R20_09 U-2011 Tabs added for my Tickets and All tickets on Ticket Handling Page
* 4.0        2020-08-20                 IBM                   R20_09 U-2008,2009,2010 Display Tasks on Case Page
* 5.0        2020-09-15                 IBM                   Added second order sorting for My tickets and All tickets on Ticket Handling Page
* 6.0        2020-09-18                 IBM                   Customer was not able to update the task from community and was getting the exception of Insufficient Cross reference Id.
As confirmed on Salesforce ticket - 27400238,Customer profile must be given Write permission on Account via Sharing set to be able to update a task.
Hence, updating the task in with sharing context in class "OC_ContentControllerTicketHandling" and giving Write access to "Customer Community Plus Custom User" profile in Sharing Set.
* 7.0        2020-12-10                 IBM                   R21_01 U-2113 Add comments while rejecting a remedy/answer
* 8.0        2020-12-17                 IBM                   R21_01 U-2350 Multiple replacement of CaseNumber field with PrefixedCasNumber (OC_TH_Case_Number__c)
* 9.0        2021-05-10                 IBM                   R21_06 U-2644 updated Inconsistency in timestamp while updating RFI_C/Remedy/Answer task activity.
* 10.0       2021-07-07                 IBM                   R21_08 U-2957 Added LI Community Permission Set Users access for CSR on My tickets and All tickets on Ticket Handling Page
**/
public with sharing class OC_ContentControllerTicketHandling {
    
    /**************************************************************************************
* @Description  This method fetches the case record details. 
* @Param        Id of case record
* @Return       Case record wrapper
**************************************************************************************/ 
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestTicketDetail(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OCResponseTicketDetail response = new OmniChannelThemeRequestReponseWrappers.OCResponseTicketDetail();
        OmniChannelThemeRequestReponseWrappers.OCResponseTicketData requestedData = new OmniChannelThemeRequestReponseWrappers.OCResponseTicketData();
        OmniChannelThemeRequestReponseWrappers.OCRequestTicketDetail requestBody = (OmniChannelThemeRequestReponseWrappers.OCRequestTicketDetail) JSON.deserialize(JSON.serialize(request.requestBody), OmniChannelThemeRequestReponseWrappers.OCRequestTicketDetail.class) ;
        response.requestType = request.requestType;
        response.requestedData = requestedData;
        
        Id entityId;
        try{ 
            entityId = Id.valueOf(requestBody.entityId);
        }
        catch (StringException e){ 
            throw new AuraHandledException('You do not have permission to perform this action. Please contact you administrator.');
        }
        
        
        if(entityId.getSobjectType() == Case.SObjectType){
            List<OmniChannelThemeRequestReponseWrappers.OCResponseContentDocumentDataItem> attachmentList = new List<OmniChannelThemeRequestReponseWrappers.OCResponseContentDocumentDataItem>();
            OmniChannelThemeRequestReponseWrappers.OCResponseContentDocumentDataItem attachmentItem;
            //Fetching child task records of the Case
            Case tempRecord = [SELECT Id, AccountId, Account.Name, AssetId, Asset.Name, ContactId, OC_TH_Customer_Description__c, OC_TH_CSR_Priority__c, OC_TH_Security_CSR__c, OC_TH_Ext_Reference__c, Status, Subject, toLabel(Type),(Select Id,RecordType.Name,Status,Description,OwnerId,LastModifiedDate,CreatedBy.Name FROM Tasks ORDER BY RecordType.Name,Status,LastModifiedDate DESC) FROM CASE WHERE Id = :entityId];
            requestedData.itemId = tempRecord.Id;
            requestedData.itemPriority = tempRecord.OC_TH_CSR_Priority__c;
            requestedData.itemAccountId = tempRecord.AccountId;
            requestedData.itemAccountName = tempRecord.Account.Name;
            requestedData.itemAssetId = tempRecord.AssetId;
            requestedData.itemAssetName = tempRecord.Asset.Name;
            requestedData.itemTitle = tempRecord.Subject;
            requestedData.itemDescription = tempRecord.OC_TH_Customer_Description__c;
            requestedData.itemExtReference = tempRecord.OC_TH_Ext_Reference__c;
            requestedData.itemStatus = tempRecord.Status;
            requestedData.itemType = tempRecord.Type;
            requestedData.itemContactName = tempRecord.ContactId;
            requestedData.itemAttachments = attachmentList;
            //Add tasks to the wrapper response
            list<Task> answerTasks = new list<Task>();
            list<Task> remedyTasks = new list<Task>();
            list<Task> requestForInfoTasks = new list<Task>();
            //LPAS-874
            Id profileId = UserInfo.getProfileId();
			String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
            Id loggedUserID = UserInfo.getUserId();
            
            Id userName =[Select Id, ContactId from User where Id=:loggedUserID].ContactId;
            String caseContact = requestedData.itemContactName;
            System.debug('CaseContact>>>>' +caseContact);
            System.debug('loggedUserID>>>>' +userName);
            System.debug('tempRecord>>' +tempRecord);
            if(profileName == 'Customer Community Plus Custom User' && tempRecord.OC_TH_Security_CSR__c == true && (userName == caseContact)){
                       requestedData.showAttachments = true;
                   
            }
            else{
                requestedData.showAttachments = false;
            }
            System.debug('showAttachments>>' +requestedData.showAttachments);
            //end
            for(Task tempTask : tempRecord.Tasks){
                switch on tempTask.RecordType.Name {
                    when 'Answer' {
                        answerTasks.add(tempTask);
                    }
                    when 'Remedy' {
                        remedyTasks.add(tempTask);
                    }
                    when 'Request for Info' {
                        requestForInfoTasks.add(tempTask);
                    }
                }
            }
            if(!answerTasks.isEmpty()){
                requestedData.answerTaskList = answerTasks;
            }
            if(!remedyTasks.isEmpty()){
                requestedData.remedyTaskList = remedyTasks;
            }
            if(!requestForInfoTasks.isEmpty()){
                requestedData.requestForInfoTaskList = requestForInfoTasks;
            }
            //till here
            
            for(ContentDocumentLink tempDocument :OC_TH_Utility.getSobjectRecordAttachments(entityId)){
                attachmentItem = new OmniChannelThemeRequestReponseWrappers.OCResponseContentDocumentDataItem();
                attachmentItem.documentId = tempDocument.ContentDocument.Id;
                attachmentItem.documentTitle = tempDocument.ContentDocument.Title.contains('.') ? tempDocument.ContentDocument.Title.substringBefore('.') : tempDocument.ContentDocument.Title;
                attachmentItem.documentSize = OC_ContentControllerSubContentFormatter.BytesToSize(tempDocument.ContentDocument.ContentSize);
                attachmentItem.documentSizeOriginal = tempDocument.ContentDocument.ContentSize;
                system.debug('attachmentItem>>>>' +attachmentItem);
                attachmentList.add(attachmentItem);
            }
            system.debug('attachmentList>>>>>' +attachmentList);
        }
        system.debug('response>>>>> ' +response);
        return response;
    }
    
    /*public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestAddTicketComment(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
OmniChannelThemeRequestReponseWrappers.OCResponseTicketDetail response = new OmniChannelThemeRequestReponseWrappers.OCResponseTicketDetail();
OmniChannelThemeRequestReponseWrappers.OCResponseTicketData requestedData = new OmniChannelThemeRequestReponseWrappers.OCResponseTicketData();
OmniChannelThemeRequestReponseWrappers.OCRequestAddTicketComment requestBody = (OmniChannelThemeRequestReponseWrappers.OCRequestAddTicketComment) JSON.deserialize(JSON.serialize(request.requestBody), OmniChannelThemeRequestReponseWrappers.OCRequestAddTicketComment.class) ;
response.requestType = request.requestType;
response.requestedData = requestedData;

Id entityId;
try{ 
entityId = Id.valueOf(requestBody.entityId);
}
catch (StringException e){ 
throw new AuraHandledException('You do not have permission to perform this action. Please contact you administrator.');
}

if(String.isBlank(requestBody.entityData)){
throw new AuraHandledException('Please provide a valid input text.');
}

if(entityId.getSobjectType() == Case.SObjectType){            
Case tempRecord = [SELECT Id, OC_TH_Customer_Description__c FROM CASE WHERE Id = :entityId];
String commentData = UserInfo.getName() + ' : ' + Datetime.now().format('YYYY-MM-dd, hh:mm:ss a') + ':<br/>' + requestBody.entityData + '<br/>';
tempRecord.OC_TH_Customer_Description__c = commentData + tempRecord.OC_TH_Customer_Description__c;

update tempRecord;
}

return response;
}*/
    
    private static Integer filterFieldMapCount(List<String> filterMapValues){
        Integer filterFieldCount = 0;
        for(String filterValue : filterMapValues) {
            if(String.isNotBlank(filterValue) && filterValue != null){
                filterFieldCount++;
            }
        }
        system.debug('filterFieldCount--> '+filterFieldCount);
        return filterFieldCount;
    }

    private static Integer getCaseCount(List<Case> genericCaseList,
      OmniChannelThemeRequestReponseWrappers.OCTicketLists queryClauses) {
        Boolean hasDateFilter;
        List<Case> caseRecordsList = new List<Case>();
          system.debug('caseRecordsList size--> '+genericCaseList.size());
        if(queryClauses.searchValueByFieldMap != null && queryClauses.searchValueByFieldMap.get('targetdate') != null){
            for(Case caseRecord :genericCaseList){
                system.debug('caseRecord--> '+JSON.serializePretty(caseRecord));
                if(caseRecord.CaseMilestones.size() > 0){
                    caseRecordsList.add(caseRecord);
                }
            }
            return caseRecordsList.size();
        } else {
            return ((Integer)returnCaseList(queryClauses,OC_TH_Constants.getcount));
        }
    }
    
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestTicketHandling(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OCResponseTicketHandling response = new OmniChannelThemeRequestReponseWrappers.OCResponseTicketHandling();
        OmniChannelThemeRequestReponseWrappers.OCResponseTickethandlingData requestedData = new OmniChannelThemeRequestReponseWrappers.OCResponseTickethandlingData();
        OmniChannelThemeRequestReponseWrappers.OCRequestTicketHandling requestBody = (OmniChannelThemeRequestReponseWrappers.OCRequestTicketHandling) JSON.deserialize(JSON.serialize(request.requestBody), OmniChannelThemeRequestReponseWrappers.OCRequestTicketHandling.class);
        
        /*Added By Aayush U-2957*/
        OmniChannelThemeRequestReponseWrappers.OCTicketLists queryClauses = new OmniChannelThemeRequestReponseWrappers.OCTicketLists();
        
        requestedData.tickethandlingItems = new  List<OmniChannelThemeRequestReponseWrappers.OCResponseTicketHandlingDataItem>();
        response.requestType = request.requestType;
        response.requestedData = requestedData; 
        //test method
        
        List<Schema.PicklistEntry> TypePicklistValues  = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().get('Type' ).getDescribe().getPicklistValues();               
        List<Schema.PicklistEntry> PriorityPicklistValues  = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().get('Priority' ).getDescribe().getPicklistValues();               
        List<Schema.PicklistEntry> StatusPicklistValues  = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().get('Status' ).getDescribe().getPicklistValues();               
         
        List<String> typePicklistValueList = new List<String> ();
            for( Schema.PicklistEntry PicklistValue : TypePicklistValues){
                typePicklistValueList.add(string.valueof(PicklistValue.getLabel()));
            }
        List<String> priorityPicklistValueList = new List<String> ();
            for( Schema.PicklistEntry PicklistValue : PriorityPicklistValues){
                priorityPicklistValueList.add(string.valueof(PicklistValue.getLabel()));
            }
		List<String> statusPicklistValueList = new List<String> ();
            for( Schema.PicklistEntry PicklistValue : StatusPicklistValues){
                statusPicklistValueList.add(string.valueof(PicklistValue.getLabel()));
            }
        response.typePicklistValues = typePicklistValueList;
        response.priorityPicklistValues = priorityPicklistValueList;
        response.statusPicklistValues = statusPicklistValueList;    
        
        response.currentPageNumber=Integer.valueOf(requestBody.currentPageNumber);
        User loggedInUser = [SELECT Id,Contact.AccountId,ContactId FROM User where id =: UserInfo.getUserId()];
        
        Set<Id> set_accessibleAccounts = new Set<Id>();
        
        List<PermissionSetAssignment> permissionSet = [SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =:UserInfo.getUserId() AND  PermissionSet.Name=: OC_TH_Constants.getEricssonLiCommunityUserPermissionSet];
        Boolean isLiCsrUser = OC_TH_Constants.isLiCsrUser;
        if(permissionSet.size()>0){
            isLiCsrUser= true;
        }
        
        //UserInfo.getUserType() == 'PowerPartner' has been removed for now
        if (UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'PowerCustomerSuccess'){
            set_accessibleAccounts.add(loggedInUser.Contact.AccountId);
            Set<Id> accountIdSet = new Set<Id>();
            for(AccountContactRelation acr : [SELECT AccountId FROM AccountContactRelation WHERE ContactId =: loggedInUser.ContactId]){
                accountIdSet.add(acr.AccountId);
            }
            set_accessibleAccounts.addAll(accountIdSet);
            response.currentAccountId = new list<Id>(set_accessibleAccounts)[0];
        }
        else if(UserInfo.getUserType() == 'Standard'){ 
            set_accessibleAccounts.addAll((new map<Id,Account>([Select Id from Account])).keyset());
        }
        else{
            throw new AuraHandledException(System.Label.OC_Generic_Exception_Message);
            
        }
        Id RecordType=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard CSR').getRecordTypeId();
        List<Case> case_list;
        Integer caseCount;
        Integer filterMapSize = filterFieldMapCount(requestBody.contextSearchMap.values());      
        // logic to query all Tickets or my tickets on case based on request SubType and Search Parameter
        if(request.requestSubType == 'allTickets'){
            system.debug(request.requestType);
            if(isLiCsrUser!=null && isLiCsrUser== false){
                if(String.isNotBlank(requestBody.contextSearchText) || filterMapSize > 0){
                    if(String.isNotBlank(requestBody.contextSearchText)){
                    queryClauses.searchText = '%'+requestBody.contextSearchText+'%';
                    }
                    queryClauses.searchValueByFieldMap = requestBody.contextSearchMap;
                    queryClauses.accessibleAccounts = new Set<ID>(set_accessibleAccounts);
                    queryClauses.recordType = RecordType;
                    queryClauses.isLiCsr = false;
                    queryClauses.offset = requestBody.offset;
                    case_list = (List<Case>)returnCaseList(queryClauses,OC_TH_Constants.getlist);
                    caseCount = getCaseCount(case_list, queryClauses);
                    system.debug('1st inner If condition');
                }
                else{
                    queryClauses.accessibleAccounts = new Set<ID>(set_accessibleAccounts);
                    queryClauses.recordType = RecordType;
                    queryClauses.isLiCsr = false;
                    queryClauses.offset = requestBody.offset;
                    case_list = (List<Case>)returnCaseList(queryClauses,OC_TH_Constants.getlist);                    
                    caseCount = getCaseCount(case_list, queryClauses);
                    system.debug('2nd inner If condition');
                } 
            }
            else{
                if(String.isNotBlank(requestBody.contextSearchText)|| filterMapSize > 0){
                    if(String.isNotBlank(requestBody.contextSearchText)){
                    queryClauses.searchText = '%'+requestBody.contextSearchText+'%';
                    }
                    queryClauses.searchValueByFieldMap = requestBody.contextSearchMap;
                    queryClauses.accessibleAccounts = new Set<ID>(set_accessibleAccounts);
                    queryClauses.recordType = RecordType;
                    queryClauses.offset = requestBody.offset;
                    case_list = (List<Case>)returnCaseList(queryClauses,OC_TH_Constants.getlist);                    
                    caseCount = getCaseCount(case_list, queryClauses);
                    system.debug('3st inner If condition');
                }
                
                else{
                    queryClauses.accessibleAccounts = new Set<ID>(set_accessibleAccounts);
                    queryClauses.recordType = RecordType;
                    queryClauses.offset = requestBody.offset;
                    case_list = (List<Case>)returnCaseList(queryClauses,OC_TH_Constants.getlist);                    
                    caseCount = getCaseCount(case_list, queryClauses);
                    system.debug('4th inner If condition');
                }  
            }
        }
        else{
            if(isLiCsrUser!=null && isLiCsrUser== false){
                if(String.isNotBlank(requestBody.contextSearchText)){
                    if(loggedInUser.ContactId != null){
                        queryClauses.searchText = '%'+requestBody.contextSearchText+'%';
                        queryClauses.recordType = RecordType;
                        queryClauses.isLiCsr = false;
                        queryClauses.offset = requestBody.offset;
                        queryClauses.userId = UserInfo.getUserId();
                        queryClauses.contactId = loggedInUser.ContactId;
                        case_list = (List<Case>)returnCaseList(queryClauses,OC_TH_Constants.getlist);                    
                        caseCount = (Integer)returnCaseList(queryClauses,OC_TH_Constants.getcount);
                        system.debug('5th inner If condition');
                    }
                    else{
                        queryClauses.searchText = '%'+requestBody.contextSearchText+'%';
                        queryClauses.recordType = RecordType;
                        queryClauses.isLiCsr = false;
                        queryClauses.offset = requestBody.offset;
                        queryClauses.userId = UserInfo.getUserId();
                        case_list = (List<Case>)returnCaseList(queryClauses,OC_TH_Constants.getlist);                    
                        caseCount = (Integer)returnCaseList(queryClauses,OC_TH_Constants.getcount);
                        system.debug('6th inner If condition');
                        } 
                }
                else{
                    if(loggedInUser.ContactId != null){
                        queryClauses.recordType = RecordType;
                        queryClauses.isLiCsr = false;
                        queryClauses.offset = requestBody.offset;
                        queryClauses.userId = UserInfo.getUserId();
                        queryClauses.contactId = loggedInUser.ContactId;
                        system.debug(' queryClauses.contactId--'+ queryClauses.contactId);
                        case_list = (List<Case>)returnCaseList(queryClauses,OC_TH_Constants.getlist);                    
                        caseCount = (Integer)returnCaseList(queryClauses,OC_TH_Constants.getcount);
                        system.debug('7th inner If condition');
                    }
                    else{
                        queryClauses.recordType = RecordType;
                        queryClauses.isLiCsr = false;
                        queryClauses.offset = requestBody.offset;
                        queryClauses.userId = UserInfo.getUserId();
                        case_list = (List<Case>)returnCaseList(queryClauses,OC_TH_Constants.getlist);                    
                        caseCount = (Integer)returnCaseList(queryClauses,OC_TH_Constants.getcount);
                        system.debug('8th inner If condition');
                    }
                }
            }
            else {      
                if(String.isNotBlank(requestBody.contextSearchText)){
                    if(loggedInUser.ContactId != null){
                        queryClauses.searchText = '%'+requestBody.contextSearchText+'%';
                        queryClauses.recordType = RecordType;
                        queryClauses.offset = requestBody.offset;
                        queryClauses.userId = UserInfo.getUserId();
                        queryClauses.contactId = loggedInUser.ContactId;
                        case_list = (List<Case>)returnCaseList(queryClauses,OC_TH_Constants.getlist);                    
                        caseCount = (Integer)returnCaseList(queryClauses,OC_TH_Constants.getcount);
                        system.debug('9th inner If condition');
                    
                    }
                    else{
                        queryClauses.searchText = '%'+requestBody.contextSearchText+'%';
                        queryClauses.recordType = RecordType;
                        queryClauses.offset = requestBody.offset;
                        queryClauses.userId = UserInfo.getUserId();
                        case_list = (List<Case>)returnCaseList(queryClauses,OC_TH_Constants.getlist);                    
                        caseCount = (Integer)returnCaseList(queryClauses,OC_TH_Constants.getcount);
                        system.debug('10th inner If condition');
                    } 
                }
                else{
                    if(loggedInUser.ContactId != null){
                        queryClauses.recordType = RecordType;
                        queryClauses.offset = requestBody.offset;
                        queryClauses.userId = UserInfo.getUserId();
                        queryClauses.contactId = loggedInUser.ContactId;
                        case_list = (List<Case>)returnCaseList(queryClauses,OC_TH_Constants.getlist);                    
                        caseCount = (Integer)returnCaseList(queryClauses,OC_TH_Constants.getcount);
                        system.debug('11th inner If condition');
                     }
                    else{
                        queryClauses.recordType = RecordType;
                        queryClauses.offset = requestBody.offset;
                        queryClauses.userId = UserInfo.getUserId();
                        case_list = (List<Case>)returnCaseList(queryClauses,OC_TH_Constants.getlist);                    
                        caseCount = (Integer)returnCaseList(queryClauses,OC_TH_Constants.getcount);
                        system.debug('12th inner If condition');
                     }
                }
            }  
        }
        response.totaltickets = caseCount;
        Boolean filterDate = requestBody.contextSearchMap.get('targetdate') != null ? true : false;
        requestedData.tickethandlingItems.addAll(retrunList(case_list, filterDate));
        system.debug('response>>>>>>>' +response);
        return response;
    }
    
    public static Object returnCaseList(OmniChannelThemeRequestReponseWrappers.OCTicketLists queryClauses, String listOrCount){
        OmniChannelThemeRequestReponseWrappers.OCTicketLists result = new OmniChannelThemeRequestReponseWrappers.OCTicketLists();
        Id RecordType = queryClauses.recordType;
        String milestonetype = OC_TH_Constants.milestonetype;
        List<Case> case_list = new  List<Case>();
        Integer case_count ;
        Boolean shouldQueryOnMileStone = false;
        Integer filterMapSize = queryClauses.searchValueByFieldMap == null ? 0 : filterFieldMapCount(queryClauses.searchValueByFieldMap.values());
        Set<Id> accessibleAccounts = new Set<Id>();
        if(queryClauses.searchValueByFieldMap != null
           && filterMapSize > 0 && queryClauses.searchValueByFieldMap.get('targetdate') != null) {
               shouldQueryOnMileStone = true;
           }
        if(listOrCount.equals(OC_TH_Constants.getlist)) {
            Integer offSet = queryClauses.offset;
            system.debug('offset--'+offSet);
            String query = 'SELECT Id,Type, OC_TH_Case_Number__c, Asset.Name, OC_TH_Ext_Reference__c, Subject, OC_TH_CSR_Priority__c, Status, Owner.name, (SELECT Id, targetdate FROM CaseMilestones where milestonetype.name=:milestonetype), CreatedDate, OC_TH_Waiting_on__c FROM Case WHERE RecordTypeId = :RecordType and IsDeleted = false';
            String queryForMileStone = 'SELECT Id, targetdate, Case.Id,Case.Type, Case.OC_TH_Case_Number__c, Case.Asset.Name, Case.OC_TH_Ext_Reference__c, Case.Subject, Case.OC_TH_CSR_Priority__c, Case.Status, Case.Owner.name, Case.CreatedDate, Case.OC_TH_Waiting_on__c FROM CaseMileStone WHERE milestonetype.name=:milestonetype AND Case.RecordTypeId = :RecordType and case.IsDeleted = false';
            system.debug('accessibleAccounts--'+queryClauses.accessibleAccounts);
            system.debug('fieldSeacrchMap--'+JSON.serializePretty(queryClauses.searchValueByFieldMap));
            if(queryClauses.accessibleAccounts!= null){
                accessibleAccounts = queryClauses.accessibleAccounts;
                if(shouldQueryOnMileStone){
                    queryForMileStone += ' AND Case.accountId IN :accessibleAccounts';
                } else {
                query += ' AND accountId IN :accessibleAccounts';
                }
            }
            if(String.isNotBlank(queryClauses.searchText)){
                String searchText = queryClauses.searchText;
                query += ' AND (Subject like :searchText OR OC_TH_Ext_Reference__c like :searchText OR OC_TH_Case_Number__c like :searchText OR Status like :searchText OR OC_TH_CSR_Priority__c like :searchText OR Asset.Name like :searchText)';
            }
            if(queryClauses.searchValueByFieldMap != null
               && filterMapSize > 0){
                   if(!(filterMapSize == 1 && queryClauses.searchValueByFieldMap.get('targetdate') != null)){
                query += ' AND (';
                   }
                List<String> fieldsToFilter = new List<String>();
                for(String fieldName : queryClauses.searchValueByFieldMap.keySet()){
                    if(String.isNotBlank(queryClauses.searchValueByFieldMap.get(fieldName)) && queryClauses.searchValueByFieldMap.get(fieldName) != null){
                        fieldsToFilter.add(fieldName);
                        /*if(fieldName == 'targetdate'){
                          List<String> splitquery = query.split('\\)');
                            system.debug('split string--> '+splitquery);
                            String newQuery = splitquery[0] + ' AND DAY_ONLY(' + fieldName + ') = ' + queryClauses.searchValueByFieldMap.get(fieldName) + ' ) ' + splitquery[1];
                            system.debug('newQuery--> '+newQuery);
                            query = newQuery;*/
                        
                if(shouldQueryOnMileStone){
                        if(fieldName == 'targetdate'){
                            queryForMileStone += ' AND DAY_ONLY( '+ fieldName + ') = ' + queryClauses.searchValueByFieldMap.get(fieldName);
                                } else  {
                                   queryForMileStone += ' AND Case.' + fieldName + ' like '+ '\'%' + queryClauses.searchValueByFieldMap.get(fieldName) + '%\'';
                                }
                    system.debug('queryForMileStone--> '+queryForMileStone);
                }else {
                        query += fieldName + ' like '+ '\'%' + queryClauses.searchValueByFieldMap.get(fieldName) + '%\'' +' AND ';
                        }
                    }
                }
                system.debug('fieldsToFilter--> '+fieldsToFilter);
                system.debug('fieldsToFilter size--> '+fieldsToFilter.size());
                   if(!(filterMapSize == 1 && queryClauses.searchValueByFieldMap.get('targetdate') != null)){
                query = query.removeEnd(' AND ') + ')';
                   }
            }
            if(queryClauses.isLiCsr!=null){
                Boolean isLiCsr= queryClauses.isLiCsr;
                if(shouldQueryOnMileStone){
                    queryForMileStone += ' AND Case.OC_TH_LI_CSR__c=: isLiCsr';
                } else {
                query += ' AND OC_TH_LI_CSR__c=: isLiCsr';
                }
            }
            if(String.isNotBlank(queryClauses.contactId) && String.isNotBlank(queryClauses.userId)){
                Id contactId= queryClauses.contactId;
                Id userId= queryClauses.userId;
                query += ' AND (createdById =:userId OR Case.contactId =:contactId)';
            }
            if(String.isNotBlank(queryClauses.userId) && String.isBlank(queryClauses.contactId)){
                Id userId= queryClauses.userId;
                query += ' AND createdById =:userId';
            }
            
                if(shouldQueryOnMileStone){
                    queryForMileStone += ' ORDER BY Case.OC_TH_Waiting_Status__c DESC NULLS Last,Case.LastModifiedDate DESC NULLS Last Limit 10';
            system.debug('Final MileStone query--> '+queryForMileStone);
                    List<CaseMilestone> caseMilestoneList = new List<CaseMilestone>();
                    caseMilestoneList = Database.query(queryForMileStone);
                    for(CaseMilestone milestoneRecord : caseMilestoneList){
                    system.debug('Case fields--> '+milestoneRecord.Case);
                    }
                } else {}
            query += ' ORDER BY OC_TH_Waiting_Status__c DESC NULLS Last,LastModifiedDate DESC NULLS Last Limit 10 Offset :offSet';
            system.debug('query--> '+query);
            case_list = Database.query(query);
            return case_list;
        }
        else if (listOrCount.equals(OC_TH_Constants.getcount)){
            String query = 'SELECT count() FROM Case WHERE RecordTypeId = :RecordType and IsDeleted = false';
            if(queryClauses.accessibleAccounts!= null){
                accessibleAccounts = queryClauses.accessibleAccounts;
                query += ' AND accountId IN :accessibleAccounts';
            }
            if(String.isNotBlank(queryClauses.searchText)){
                String searchText = queryClauses.searchText;
                query += ' AND (Subject like :searchText OR OC_TH_Ext_Reference__c like :searchText OR OC_TH_Case_Number__c like :searchText OR Status like :searchText OR OC_TH_CSR_Priority__c like :searchText OR Asset.Name like :searchText)';
            }
            if(queryClauses.searchValueByFieldMap != null
               && filterMapSize > 0){
                if(!(filterMapSize == 1 && queryClauses.searchValueByFieldMap.get('targetdate') != null)){
                    query += ' AND (';
                }
                for(String fieldName : queryClauses.searchValueByFieldMap.keySet()){
                    if(String.isNotBlank(queryClauses.searchValueByFieldMap.get(fieldName)) && queryClauses.searchValueByFieldMap.get(fieldName) != null
                      && fieldName != 'targetdate'){
                        query += fieldName + ' like '+ '\'%' + queryClauses.searchValueByFieldMap.get(fieldName) + '%\'' +' AND ';
                    }
                }
                if(!(filterMapSize == 1 && queryClauses.searchValueByFieldMap.get('targetdate') != null)){
                    query = query.removeEnd(' AND ') + ')';
                    system.debug('countquery--> '+query);
                }
            }
            if(queryClauses.isLiCsr!=null){
                Boolean isLiCsr= queryClauses.isLiCsr;
                query += ' AND OC_TH_LI_CSR__c=: isLiCsr';
            }
            if(String.isNotBlank(queryClauses.contactId) && String.isNotBlank(queryClauses.userId)){
                Id contactId= queryClauses.contactId;
                Id userId= queryClauses.userId;
                query += ' AND (createdById =:userId OR Case.contactId =:contactId)';
            }
            if(String.isNotBlank(queryClauses.userId) && String.isBlank(queryClauses.contactId)){
                Id userId= queryClauses.userId;
                query += ' AND createdById =:userId';
            }
            case_count = Database.countQuery(query);
            return case_count;
        }
        return NULL;
    }
    
    
    //2.0 2020-08-17 IBM
    //R20_09 U-2013 Fourth Quadrant on MyWorkspace to show Recent Tickets
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestRecentTickets(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OCResponseTicketHandling response = new OmniChannelThemeRequestReponseWrappers.OCResponseTicketHandling();
        OmniChannelThemeRequestReponseWrappers.OCResponseTickethandlingRecentData requestedData = new OmniChannelThemeRequestReponseWrappers.OCResponseTickethandlingRecentData();
        
        requestedData.tickethandlingRecentItems = new  List<OmniChannelThemeRequestReponseWrappers.OCResponseTicketHandlingDataItem>();
        response.requestType = request.requestType;
        response.requestedData = requestedData;
        
        Set<Id> set_accessibleAccounts = new Set<Id>();
        User loggedInUser = [SELECT Id,Contact.AccountId,ContactId FROM User where id =: UserInfo.getUserId()];
        //UserInfo.getUserType() == 'PowerPartner' has been removed for now
        if (UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'PowerCustomerSuccess'){
            set_accessibleAccounts.add(loggedInUser.Contact.AccountId);
            Set<Id> accountIdSet = new Set<Id>();
            for(AccountContactRelation acr : [SELECT AccountId FROM AccountContactRelation WHERE ContactId =: loggedInUser.ContactId]){
                accountIdSet.add(acr.AccountId);
            }
            set_accessibleAccounts.addAll(accountIdSet);
            response.currentAccountId = new list<Id>(set_accessibleAccounts)[0];
        }
        else if(UserInfo.getUserType() == 'Standard'){ 
            set_accessibleAccounts.addAll((new map<Id,Account>([Select Id from Account])).keyset());
        }
        else{
            throw new AuraHandledException(System.Label.OC_Generic_Exception_Message);
            
        }
        Id RecordType=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard CSR').getRecordTypeId();
        List<Case> case_list;
        Integer caseCount;
        if(loggedInUser.contactId != null){
            case_list = [SELECT Id,Type, OC_TH_Case_Number__c, Asset.Name, OC_TH_Ext_Reference__c, Subject, OC_TH_CSR_Priority__c, Status, Owner.name, (SELECT Id, targetdate FROM CaseMilestones where milestonetype.name='Solution1' ), CreatedDate, OC_TH_Waiting_on__c FROM Case WHERE (createdById =:UserInfo.getUserId() OR Case.contactId =:loggedinuser.contactId) and accountId IN :set_accessibleAccounts and RecordTypeId = :RecordType and IsDeleted = false ORDER BY LastModifiedDate DESC NULLS Last, Casenumber DESC Limit 5];
            caseCount = [SELECT count() FROM Case WHERE (createdById =:UserInfo.getUserId() OR Case.contactId =:loggedinuser.contactId) and accountId IN :set_accessibleAccounts and RecordTypeId = :RecordType and IsDeleted = false ];
        }else{
            case_list = [SELECT Id,Type, OC_TH_Case_Number__c, Asset.Name, OC_TH_Ext_Reference__c, Subject, OC_TH_CSR_Priority__c, Status, Owner.name, (SELECT Id, targetdate FROM CaseMilestones where milestonetype.name='Solution1' ), CreatedDate, OC_TH_Waiting_on__c FROM Case WHERE CreatedById = :UserInfo.getUserId() and accountId IN :set_accessibleAccounts and RecordTypeId = :RecordType and IsDeleted = false ORDER BY LastModifiedDate DESC NULLS Last, Casenumber DESC Limit 5];
            caseCount = [SELECT count() FROM Case WHERE CreatedById = :UserInfo.getUserId() and accountId IN :set_accessibleAccounts and RecordTypeId = :RecordType and IsDeleted = false ];  
        }   
        response.totaltickets = caseCount;
        requestedData.tickethandlingRecentItems.addAll(retrunList(case_list, false));
        
        return response;
    }
    
    private static List<OmniChannelThemeRequestReponseWrappers.OCResponseTicketHandlingDataItem> retrunList(List<Case> genericCaseList, Boolean filterByTargetDate){
        List<OmniChannelThemeRequestReponseWrappers.OCResponseTicketHandlingDataItem> tempList = new List<OmniChannelThemeRequestReponseWrappers.OCResponseTicketHandlingDataItem>();
        OmniChannelThemeRequestReponseWrappers.OCResponseTicketHandlingDataItem tempItem;
        List<Case> caseRecordsList = new List<Case>();
        //Added by sejal for LPAS-237 and LPAS-1145
            Map<String,String> caseType = OC_Utility.getObjectPicklistValuesReverse(OC_TH_Constants.caseLiteral,OC_TH_Constants.caseType);
        if(filterByTargetDate){
            for(Case  tempCase :genericCaseList){
                if(tempCase.CaseMilestones.size() > 0){
                    caseRecordsList.add(tempCase);
                }
            }
        } else {
            caseRecordsList.addAll(genericCaseList);
        }
        for(Case  tempCase :caseRecordsList){
            tempItem = new OmniChannelThemeRequestReponseWrappers.OCResponseTicketHandlingDataItem();
            tempItem.id = tempCase.id;
            tempItem.casenumber = tempCase.OC_TH_Case_Number__c;
            tempItem.caseURL = Site.getPathPrefix() + '/case/' + tempCase.id + '/' + tempCase.OC_TH_Case_Number__c;
            tempItem.type = caseType.get(tempCase.type);
            tempItem.priority = tempCase.OC_TH_CSR_Priority__c;
            tempItem.asset = tempCase.Asset.Name;
            tempItem.subject = tempCase.Subject;
            tempItem.status = tempCase.Status;
            tempItem.extReference = tempCase.OC_TH_Ext_Reference__c;
            for(CaseMilestone  tempCasemilestone :tempCase.CaseMilestones){
                DateTime dt = tempCasemilestone.targetdate;
                tempItem.expectedDate = date.newinstance(dT.year(), dT.month(), dT.day());
            }
            tempItem.waitingOn = tempCase.OC_TH_Waiting_on__c;
            tempList.add(tempItem);
        }
        return tempList;
        
    }
    
    /**************************************************************************************
* @Description  This method updates the Remedy and Answer Task status and description selected by user 
* @Param        Task Id, new status
* @Return       Case record wrapper
**************************************************************************************/
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestUpdateTaskStatus(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OCResponseTicketDetail response = new OmniChannelThemeRequestReponseWrappers.OCResponseTicketDetail();
        OmniChannelThemeRequestReponseWrappers.OCResponseTicketData requestedData = new OmniChannelThemeRequestReponseWrappers.OCResponseTicketData();
        OmniChannelThemeRequestReponseWrappers.OCRequestUpdateTaskStatus requestBody = (OmniChannelThemeRequestReponseWrappers.OCRequestUpdateTaskStatus) JSON.deserialize(JSON.serialize(request.requestBody), OmniChannelThemeRequestReponseWrappers.OCRequestUpdateTaskStatus.class) ;
        response.requestType = request.requestType;
        response.requestedData = requestedData;
        
        Id entityId;
        try{ 
            entityId = Id.valueOf(requestBody.entityId);
            if(entityId.getSobjectType() == Task.SObjectType){
                if(UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'PowerCustomerSuccess'){
                    User loggedInUser = [SELECT ContactId FROM User where id =: UserInfo.getUserId()];
                    Task taskRecord = [Select WhatId,Description from Task where id=:entityId];    
                    if(OC_TH_Utility.checkCaseAccessibility(loggedInUser.ContactId, taskRecord.WhatId)){
                        String commentData = 'Comment:\n' + UserInfo.getName() + ' : ' + OC_TH_Utility.getUTCDateTime(Datetime.now()) +' UTC' + ':\n' + (String.isNotBlank(requestBody.entityComment) ? requestBody.entityComment : 'Accepted') + '\n' ;
                        String taskDescription = commentData + '\nAnswer:\n' + taskRecord.Description + '\n';
                        Task tempRecord = new Task(id=entityId, Status=requestBody.entityData, Description=taskDescription.unescapeHTML4());
                        Database.update(tempRecord,false);
                    }else{
                        throw new AuraHandledException(System.Label.OC_Generic_Exception_Message);            
                    }
                }else{
                    throw new AuraHandledException(System.Label.OC_Generic_Exception_Message);            
                }
            }else{
                throw new AuraHandledException(System.Label.OC_Generic_Exception_Message);            
            }
        }
        catch (StringException e){
            throw new AuraHandledException('You do not have permission to perform this action. Please contact you administrator.');
        }
        
        return response;
    }
    
    /**************************************************************************************
* @Description  This method updates the rfi response provided by customer on case and task 
* @Param        Task Id, rfi response
* @Return       Case record wrapper
**************************************************************************************/
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestUpdateRFI(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OCResponseTicketDetail response = new OmniChannelThemeRequestReponseWrappers.OCResponseTicketDetail();
        OmniChannelThemeRequestReponseWrappers.OCResponseTicketData requestedData = new OmniChannelThemeRequestReponseWrappers.OCResponseTicketData();
        OmniChannelThemeRequestReponseWrappers.OCRequestAddRFIComment requestBody = (OmniChannelThemeRequestReponseWrappers.OCRequestAddRFIComment) JSON.deserialize(JSON.serialize(request.requestBody), OmniChannelThemeRequestReponseWrappers.OCRequestAddRFIComment.class) ;
        response.requestType = request.requestType;
        response.requestedData = requestedData;
        
        Id taskId;
        try{ 
            taskId = Id.valueOf(requestBody.taskId);
            
            if(String.isBlank(requestBody.newComment)){
                throw new AuraHandledException('Please provide a valid input text.');
            }
            
            String commentData = 'Answer:\n' + UserInfo.getName() + ' : ' + OC_TH_Utility.getUTCDateTime(Datetime.now()) +' UTC' + ':\n' + requestBody.newComment + '\n' ;
            if(taskId.getSobjectType() == Task.SObjectType){            
                if(UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'PowerCustomerSuccess'){
                    User loggedInUser = [SELECT ContactId FROM User where id =: UserInfo.getUserId()];
                    Task taskRecord = [Select WhatId,Description from Task where id=:taskId];
                    if(OC_TH_Utility.checkCaseAccessibility(loggedInUser.ContactId, taskRecord.WhatId)){
                        String taskDescription = commentData + '\nQuestion:\n' + taskRecord.Description + '\n';
                        Task tempRecord = new Task(id=taskId,Description=taskDescription.unescapeHTML4(), Status='Info provided');
                        //OC_SystemUtility.updateRecord(tempRecord);
                        Database.update(tempRecord,false);
                    }else{
                        throw new AuraHandledException(System.Label.OC_Generic_Exception_Message);            
                    }
                }else{
                    throw new AuraHandledException(System.Label.OC_Generic_Exception_Message);            
                }
            }else{
                throw new AuraHandledException(System.Label.OC_Generic_Exception_Message);            
            }
        }
        catch (StringException e){ 
            throw new AuraHandledException('You do not have permission to perform this action. Please contact you administrator.');
        }
        return response;
    }	
    
     /**************************************************************************************
* @Description  This method is to fetch the picklist values of case field
* @Param        YourObjectName, YourFieldName
* @Return       Picklist Map
**************************************************************************************/
    @AuraEnabled
    
    public static list<string> getselectOptions(string YourObjectName,string YourFieldName){
        try{  
            list<string> picklists=new List<string>(); 
            List<Schema.PicklistEntry> PicklistValues  = Schema.getGlobalDescribe().get(YourObjectName).getDescribe().fields.getMap().get(YourFieldName ).getDescribe().getPicklistValues();               
            
            for( Schema.PicklistEntry PicklistValue : PicklistValues){
                picklists.add(string.valueof(PicklistValue.getLabel()));
            }
            system.debug('picklist1' +picklists);
            return picklists;
        }
        catch(Exception e){
            throw new AuraHandledException( e.getMessage());
        }
    } 
}