/**
* @File Name          : OC_AN_UserPreferencesTriggerHandler
* @Description        : Trigger handler for user preferences
*                       U-2758 Alerts & Notification: Creation of User Prefrences.
* @Author             : IBM
* @Group              : 
* @Created Date       : 11th June 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-06-11             	IBM               Initial Version
*/
public class OC_AN_UserPreferencesTriggerHandler {
    public void onBeforeInsert(List<OC_AN_User_Preferences__c> newUserPreferencesList)
    {
        set<string> bullteinNames=new set<string>();
        set<string> bullteinUsers=new set<string>();
        set<string> bullteinContacts=new set<string>();
        set<string> prdinUsers=new set<string>();
        set<string> prdContacts=new set<string>();
        set<string> prdNames=new set<string>();
        set<string> releaseNames=new set<string>();
        set<string> versionNames=new set<string>();
        set<string> bulletinCheck=new set<string>();
        set<string> bulletinCheck1=new set<string>();
        set<string> prdCheck=new set<string>();
        set<string> prdCheck1=new set<string>();
        List<OC_AN_User_Preferences__c> cleanData=new List<OC_AN_User_Preferences__c>();
        for(OC_AN_User_Preferences__c usPref :newUserPreferencesList){
            if(usPref.RecordTypeId!=null){
                String recordTypeName=Schema.getGlobalDescribe().get('OC_AN_User_Preferences__c').getDescribe().getRecordTypeInfosById().get(usPref.RecordTypeId).getName();
                if(recordTypeName.equals(OC_AN_Constants.bulletinSetting)){
                    bullteinNames.add(usPref.Name);
                    bullteinUsers.add(usPref.OC_AN_User__c);
                    bullteinContacts.add(usPref.OC_AN_Contact__c);
                    String name='';
                    if(String.isBlank(usPref.OC_AN_User__c) && String.isBlank(usPref.OC_AN_Contact__c)){
                         usPref.addError(Label.OC_AN_UserContact_blank_error);
                    }
                    if(usPref.OC_AN_User__c!=null){
                        name=usPref.Name+'_'+usPref.OC_AN_User__c;
                    }
                    else{
                        name=usPref.Name+'_'+usPref.OC_AN_Contact__c;
                    }
                    if(!bulletinCheck1.contains(name)){
                        bulletinCheck1.add(name);
                        cleanData.add(usPref);
                    }else{
                        usPref.addError(Label.OC_AN_Record_Duplicate_Error);
                    }
                }
            }
        }
        
        List<OC_AN_User_Preferences__c> ocUsrPrefLst1=[Select id,name,OC_AN_User__c,OC_AN_Contact__c from 
                                                       OC_AN_User_Preferences__c where recordType.Name=:OC_AN_Constants.bulletinSetting 
                                                       and name IN:bullteinNames and OC_AN_User__c IN:bullteinUsers and 
                                                       OC_AN_Contact__c IN:bullteinContacts];
        for(OC_AN_User_Preferences__c usrPref : ocUsrPrefLst1){
            if(usrPref.OC_AN_User__c!=null)
                bulletinCheck.add(usrPref.Name+'_'+usrPref.OC_AN_User__c);
            else
                bulletinCheck.add(usrPref.Name+'_'+usrPref.OC_AN_Contact__c);
        }
    
        for(OC_AN_User_Preferences__c usPref :newUserPreferencesList){
            if(usPref.RecordTypeId!=null){
                String recordTypeName=Schema.getGlobalDescribe().get('OC_AN_User_Preferences__c').getDescribe().getRecordTypeInfosById().get(usPref.RecordTypeId).getName();
                if(recordTypeName.equals(OC_AN_Constants.bulletinSetting)){
                    String tempstr='';
                    if(usPref.OC_AN_User__c!=null){
                        tempstr=usPref.Name+'_'+usPref.OC_AN_User__c;
                    }
                    else{
                        tempstr=usPref.Name+'_'+usPref.OC_AN_Contact__c;
                    }
                    if(bulletinCheck.contains(tempstr) && usPref.OC_AN_Email__c){
                        usPref.addError(Label.OC_AN_Record_duplicate_of_existing_record_in_system);
                    }
                }
          
            }
        }
    }   
}