/**
* @File Name          : OC_AN_AutoSubscribeBatchViaAsset
* @Description        : OC_AN_AutoSubscribeBatchViaAsset
*                       
* @Author             : IBM
* @Group              : 
* @Created Date       : 6th August 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-08-04             	IBM               Initial Version
*/


global class OC_AN_AutoSubscribeBatchViaAsset implements Database.Batchable<sObject>
{	
    global Database.QueryLocator start(Database.BatchableContext BC){
       
        String query='SELECT Id, Name,Product2.Name,AccountId,OC_MD_Release__c,OC_TH_Release__c,OC_MD_Version__c,Product2Id,recordTypeId FROM Asset where AccountId!=null and Product2Id!=null and OC_MD_Release__c!=null  and lastmodifieddate=today';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> assetList){
        Set<Id> accSalesIdsSet=new Set<Id>();
        Set<string> versionsSet=new Set<string>();
        Set<string> uniqueIdentifier=new Set<string>();
        List<Account> accList=new  List<Account>();
        List<OC_AN_User_Preferences__c> usrPrefList=new  List<OC_AN_User_Preferences__c>();
        List<OC_AN_User_Preferences__c> usrPrefList2=new  List<OC_AN_User_Preferences__c>();
        List<OC_AN_User_Preferences__c> usrPrefList3=new  List<OC_AN_User_Preferences__c>();
        // List<Contact> contList=new  List<Contact>();
        Map<Id,Asset> accAssetMap=new Map<Id,Asset>();
        Map<string,Id> prdRelVerIdMap=new Map<string,Id>();
        List<OC_MD_ProductAttributes__c> prdAttrLst=new List<OC_MD_ProductAttributes__c>();
        
        for(Asset asst : assetList) { 
            accSalesIdsSet.add(asst.AccountId);
            accAssetMap.put(asst.AccountId,asst);
            versionsSet.add(asst.OC_MD_Version__c);
        }
        prdAttrLst=[Select id,Name,OC_MD_Parent__c,OC_MD_Parent__r.OC_MD_Product__c from OC_MD_ProductAttributes__c where Name IN:versionsSet];
        if(prdAttrLst.size()>0){
            for(OC_MD_ProductAttributes__c prdAtr : prdAttrLst) { 
                String uiqueStr=prdAtr.OC_MD_Parent__r.OC_MD_Product__c+'_'+prdAtr.OC_MD_Parent__c+'_'+prdAtr.Name;
                prdRelVerIdMap.put(uiqueStr,prdAtr.id);
            }
            system.debug('prdRelVerIdMap' +prdRelVerIdMap);
        }
        if(accSalesIdsSet.size()>0){
            accList=[Select id,ParentId from Account where parentId IN:accSalesIdsSet and parent.recordtypeId=:OC_AN_Constants.recTypeId_salesAccount and recordtypeId=:OC_AN_Constants.recTypeId_serviceAccount];
            for(contact cont :[Select id,AccountId,Account.ParentId from contact where AccountId IN:accList]){
                Id parentAccId=cont.Account.ParentId;
                OC_AN_User_Preferences__c usrPref=new OC_AN_User_Preferences__c();
                
                usrPref.OC_AN_Contact__c=cont.id;
                if(accAssetMap.containsKey(parentAccId)){
                      usrPref.Name=accAssetMap.get(parentAccId).Product2.Name;
                    //get Product Id
                    usrPref.OC_AN_Product__c=accAssetMap.get(parentAccId).Product2Id;
                    //get Release Id
                    usrPref.OC_AN_ProductAttribute__c=accAssetMap.get(parentAccId).OC_MD_Release__c;
                    //get Version Id
                   
                    String uiqueStr=usrPref.OC_AN_Product__c+'_'+usrPref.OC_AN_ProductAttribute__c+'_'+accAssetMap.get(parentAccId).OC_MD_Version__c;
                   
                    if(prdRelVerIdMap.containsKey(uiqueStr)){
                        usrPref.OC_AN_Version__c=prdRelVerIdMap.get(uiqueStr);
                        system.debug('  usrPref.OC_AN_Version__c' +  usrPref.OC_AN_Version__c);
                    }
                    uniqueIdentifier.add(uiqueStr+'_'+cont.id);
                } 
                system.debug('  release' +usrPref.OC_AN_ProductAttribute__c); 
                //system.debug('  uiqueStr' +uiqueStr);
                              
                usrPref.OC_AN_Email__c=TRUE;
                usrPref.RecordTypeId =OC_AN_Constants.recTypeId_prdUsrPrefrences;
                usrPrefList.add(usrPref);
            }
        }
        usrPrefList2=[Select id,OC_AN_Contact__c,OC_AN_Unique_Identifier__c,OC_AN_Product__c,OC_AN_ProductAttribute__c,
                      OC_AN_Version__c from OC_AN_User_Preferences__c where OC_AN_Unique_Identifier__c IN :uniqueIdentifier];
        if(usrPrefList2.size()>0){
            system.debug('  usrPrefList2');
            for(OC_AN_User_Preferences__c usrPref : usrPrefList){
                String uiqueIdentifier=usrPref.OC_AN_Product__c+'_'+usrPref.OC_AN_ProductAttribute__c+'_'+usrPref.OC_AN_Version__c+'_'+usrPref.OC_AN_Contact__c;
                for(OC_AN_User_Preferences__c usrPref2 : usrPrefList2){
                    if(!uiqueIdentifier.equals(usrPref2.OC_AN_Unique_Identifier__c)){
                        usrPrefList3.add(usrPref);
                    }
                }
            }
            database.insert(usrPrefList3);
        }else{
            database.insert(usrPrefList);
        }
    }
    global void finish(Database.BatchableContext BC){
        
        
    }
}