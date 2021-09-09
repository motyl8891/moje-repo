public with sharing class CustomerReportingGroupTriggerHandler {
    
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static boolean isFromBachJob ;
    public static boolean isFromUploadAPI = false;
    
    public CustomerReportingGroupTriggerHandler(boolean isExecuting, integer size) {
        this.isExecuting = isExecuting;
        batchSize = size;
    }
    /**
* CustomerReportingGroup Trigger On Before Insert
* @param CustomerReportingGroup List of new CustomerReportingGroup objects
*/
    public void onBeforeInsert(List<CustomerReportingGroup__c> newCustomerReportingGroups) {
        Try{
            CRGTriggerHandlerHelper.updateCRGAccountPrimaryKAM(newCustomerReportingGroups, null);
        }catch(Exception e){	}
    }
    
    /**
* CustomerReportingGroup Trigger On After Insert
* @param CustomerReportingGroup List of new CustomerReportingGroup objects
*/
    public void onAfterInsert(List<CustomerReportingGroup__c> newCustomerReportingGroups) {
        Try{
            CRGTriggerHandlerHelper.recalculateCUGCUTargets(newCustomerReportingGroups);
        }catch(Exception e){	}
    }
    
    /**
* CustomerReportingGroup Trigger On Before Update
* @param newCustomerReportingGroups     List of new CustomerReportingGroup objects
* @param oldCustomerReportingGroups     List of old CustomerReportingGroup objects
* @param newCustomerReportingGroupsMap  Map containing new CustomerReportingGroup ID and new CustomerReportingGroup object
* @param oldCustomerReportingGroupsMap  Map containing old CustomerReportingGroup ID and old CustomerReportingGroup object
*/
    public void onBeforeUpdate( List<CustomerReportingGroup__c> newCustomerReportingGroups, List<CustomerReportingGroup__c> oldCustomerReportingGroups, Map<ID, CustomerReportingGroup__c> newCustomerReportingGroupMap , Map<ID, CustomerReportingGroup__c> oldCustomerReportingGroupMap ) {
        Try{
            CRGTriggerHandlerHelper.updateCRGAccountPrimaryKAM(newCustomerReportingGroups, oldCustomerReportingGroupMap);
        }catch(Exception e){	}
    }
    
    /**
* CustomerReportingGroup Trigger On After Update
* @param newCustomerReportingGroups     List of new CustomerReportingGroup objects
* @param oldCustomerReportingGroups     List of old CustomerReportingGroup objects
* @param newCustomerReportingGroupsMap  Map containing new CustomerReportingGroup ID and new CustomerReportingGroup object
* @param oldCustomerReportingGroupsMap  Map containing old CustomerReportingGroup ID and old CustomerReportingGroup object
*/
    public void onAfterUpdate( List<CustomerReportingGroup__c> newCustomerReportingGroups, List<CustomerReportingGroup__c> oldCustomerReportingGroups, Map<ID, CustomerReportingGroup__c> newCustomerReportingGroupMap , Map<ID, CustomerReportingGroup__c> oldCustomerReportingGroupMap ) {
        Try{
            CRGTriggerHandlerHelper.recalculateCUGCUTargets(newCustomerReportingGroups);
            CRGTriggerHandlerHelper.removeCRGSharing(newCustomerReportingGroups,oldCustomerReportingGroupMap);
        }catch(Exception e){	}
    }
}