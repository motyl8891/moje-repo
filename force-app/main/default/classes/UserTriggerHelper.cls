/****************************************************************
Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Richa Gupta			10-09-2020				U-1999 - Automate the process of assigning users to existing employee records.

* ****************************************************************/
public without Sharing class UserTriggerHelper {
    /* This method is used to pass signum for mapping User to Employee */
    public static void mapUserToEmployee(List<User> newUsersList,Map<id,user> oldUsersMap,Boolean isInsert ){
        try{ 
            Set<String> newSignumSet= new Set<String>();
            Set<String> oldSignumSet= new Set<String>();
            map<string,ID>mapofSignumWithUser=new map<string,ID>();
            for(User u:newUsersList){
                if(u.Signum__c!=null){
                    newSignumSet.add(u.Signum__c);
                    mapofSignumWithUser.put(u.Signum__c,u.id);
                    if(oldUsersMap!=null) {
                        if(u.Signum__c!=oldUsersMap.get(u.id).Signum__c){
                            oldSignumSet.add(oldUsersMap.get(u.id).Signum__c);
                        }
                    }
                }
            }
            updateSalesforceUser(newSignumSet,oldSignumSet,mapofSignumWithUser);
        } catch(Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.UserTriggerHelper,
                                                  GlobalConstants.mapUserToEmployee, GlobalConstants.UserTriggerHelper, true, e));
        }
    }
    /* This method is uses to map Employee salesfore User to created or Updated User by Signum*/
    @future
    public static void updateSalesforceUser(Set<String> newSignumSet,Set<String> oldSignumSet,
                                            map<string,ID> mapofSignumWithUser){
        try{   
           // Map <String,User>userMap ;
            List<Employee__c> updateListEmp= new List<Employee__c>();
            if(!newSignumSet.isEmpty()){
                for(Employee__c  emp: [select id,First_Name__c,Signum__c from Employee__c where Signum__c in :newSignumSet
                                       Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    emp.Salesforce_User__c=mapofSignumWithUser.get(emp.Signum__c); 
                    updateListEmp.add(emp);
                }
            }if(!oldSignumSet.isEmpty()){
                for(Employee__c  emp: [select id,Signum__c from Employee__c where Signum__c in :oldSignumSet 
                                       Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    emp.Salesforce_User__c=null; 
                    updateListEmp.add(emp);
                } 
            }if(!updateListEmp.isEmpty()){
            database.update(updateListEmp);
            }
 }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.UserTriggerHelper,
                                                  GlobalConstants.updateSalesforceUser, GlobalConstants.UserTriggerHelper, true, e));
        }
		
    }

    /****************************************************************
* @author: Shubham Jagatap
* @date: 07-12-2020
* @User Story:  U-2275
* @description:  Store the Territory of the Users in AssociatedTerritories__c field on user before deactivating and add them back on reactivation.
*****************************************************************/ 
    public static void upadteAssociatedTerritories(List<User> newUsersList,Map<id,user> oldUsersMap){
        try{ 
           
            Set<Id> usersToUpdateSet = new Set<Id>();
            List<UserTerritory2Association> listUserTerritory2Association2 = new List<UserTerritory2Association>();
            Map<Id, List<String>> mapUserwithUserTerritory2Association = new Map<Id, List<String>>();
            
            //Before Deactivating user
            for(User u : newUsersList) {
                if(u.IsActive != oldUsersMap.get(u.Id).IsActive && u.IsActive == false){
                    usersToUpdateSet.add(u.Id);
                }
            }
           
            if(!usersToUpdateSet.isEmpty()){
             for(UserTerritory2Association record : [select Id, UserId, Territory2Id, IsActive from UserTerritory2Association 
                                                        where userId in :usersToUpdateSet]) 
                {
                    if(mapUserwithUserTerritory2Association.containsKey(record.userId)) {
                        mapUserwithUserTerritory2Association.get(record.userId).add(record.Territory2Id);
                    } else {
                        mapUserwithUserTerritory2Association.put(record.userId, new List<String> { record.Territory2Id });
                    }
                }
            }
            if(!mapUserwithUserTerritory2Association.isEmpty()){
                for(User u : newUsersList) {
                    if(u.IsActive != oldUsersMap.get(u.Id).IsActive){
                        String associatedTerritories = '';
                        String delimiter = ';';
                        List<String> listAssociatedTerritories = new List<String>();
                        if(u.IsActive == false){
                            for (String terrId : mapUserwithUserTerritory2Association.get(u.id)) {
                                associatedTerritories += associatedTerritories.equals('') ? terrId : delimiter + terrId;
                            } 
                            u.AssociatedTerritories__c = associatedTerritories;
                        }
                    }
                }
            }
            
            //Before Activating user
            for(User u : newUsersList) {
                if(u.IsActive != oldUsersMap.get(u.Id).IsActive && u.IsActive && u.AssociatedTerritories__c!= null){
                    Set<String> setassociatedTerritories = new Set<String>(u.AssociatedTerritories__c.split(GlobalConstants.SEMICOLON));
                        for(String associatedTerritories: setassociatedTerritories){
                            UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association(Territory2Id= associatedTerritories, UserId= u.Id);
                            listUserTerritory2Association2.add(objUserTerritory2Association);
                        }
                }
            }
            if(!listUserTerritory2Association2.isEmpty()){
                insert listUserTerritory2Association2;
            }
        }
        catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.UserTriggerHelper, GlobalConstants.UPDATE_ASSOCIATED_TERRITORIES, GlobalConstants.UserTriggerHelper, true, e))); 
        }
    }

        public static void updateUserNickName(List<User> newUsersList){
            try{
                set<string>nicknameset=new set<string>();
                map<string,user> mapwithnickname=new map<string,user>();
                for(User u : newUsersList) {
                    if(u.FirstName != null && u.LastName != null){
                    	nicknameset.add(u.FirstName + ' ' +u.LastName.substring(0,1).toUpperCase() +'.'+'%');
                    }    
                }
               for(user u:[select id,CommunityNickname from user where  CommunityNickname LIKE : nicknameset]){
                    mapwithnickname.put(u.CommunityNickname,u);
                }
                for(User u : newUsersList) {
                    string s=u.FirstName + ' ' +u.LastName.substring(0,1).toUpperCase() +'.';
                     if(u.FirstName != null && u.LastName != null && mapwithnickname.isempty()){
                         u.CommunityNickname = s;
                     }
                     if(!mapwithnickname.isempty() && mapwithnickname.size()==1){
                         u.CommunityNickname = s+'_1';
                     }
                     if(!mapwithnickname.isempty() && mapwithnickname.size()>1){
                         integer cont=mapwithnickname.size()+1;
                         u.CommunityNickname = s+'_'+cont;
                     }    
                         
                   }
                                 
            }catch (Exception e){
                EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.UserTriggerHelper, GlobalConstants.updateNickName, GlobalConstants.UserTriggerHelper, true, e))); 
        
            }

    }
    
}