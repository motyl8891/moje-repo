public with sharing class CustomerUnitTriggerHandler {
	private boolean isExecuting = false;
	private integer batchSize = 0;
	public static boolean isFromBachJob ;
	public static boolean isFromUploadAPI = false;

	public CustomerUnitTriggerHandler(boolean isExecuting, integer size) {
		this.isExecuting = isExecuting;
		batchSize = size;
	}
	/**
	 * CustomerUnit Trigger On Before Insert
	 * @param newCustomerUnits List of new CustomerUnit objects
	 */
	public void onBeforeInsert(List<CustomerUnit__c> newCustomerUnits) {

	}

	/**
	 * CustomerUnit Trigger On After Insert
	 * @param newCustomerUnits List of new CustomerUnit objects
	 */
	public void onAfterInsert(List<CustomerUnit__c> newCustomerUnits) {
        Try{
		CustomerUnitTriggerHandlerHelper.updateNewCUAccountCUHead(newCustomerUnits); 
        Map<ID, CustomerUnit__c> oldCustomerUnitMap = new Map<id, CustomerUnit__c>();
		CustomerUnitTriggerHandlerHelper.updateCuGcuSharing(newCustomerUnits, oldCustomerUnitMap);
            }catch(Exception e){	}
	}

	/**
	 * CustomerUnit Trigger On Before Update
	 * @param newCustomerUnits     List of new CustomerUnit objects
	 * @param oldCustomerUnits     List of old CustomerUnit objects
	 * @param newCustomerUnitsMap  Map containing new CustomerUnit ID and new CustomerUnit object
	 * @param oldCustomerUnitsMap  Map containing old CustomerUnit ID and old CustomerUnit object
	 */
	public void onBeforeUpdate( List<CustomerUnit__c> newCustomerUnits, List<CustomerUnit__c> oldCustomerUnits, Map<ID, CustomerUnit__c> newCustomerUnitMap , Map<ID, CustomerUnit__c> oldCustomerUnitMap ) {
	}

	/**
	* CustomerUnit Trigger On After Update
	* @param newCustomerUnits     List of new CustomerUnit objects
	* @param oldCustomerUnits     List of old CustomerUnit objects
	* @param newCustomerUnitsMap  Map containing new CustomerUnit ID and new CustomerUnit object
	* @param oldCustomerUnitsMap  Map containing old CustomerUnit ID and old CustomerUnit object
	*/
	public void onAfterUpdate( List<CustomerUnit__c> newCustomerUnits, List<CustomerUnit__c> oldCustomerUnits, Map<ID, CustomerUnit__c> newCustomerUnitMap , Map<ID, CustomerUnit__c> oldCustomerUnitMap ) {
        Try{
        CustomerUnitTriggerHandlerHelper.updateAccountCUHead(newCustomerUnits, oldCustomerUnitMap);
		CustomerUnitTriggerHandlerHelper.markAsRequireATSRecalc(newCustomerUnitMap, oldCustomerUnitMap);
        CustomerUnitTriggerHandlerHelper.updateCuGcuSharing(newCustomerUnits, oldCustomerUnitMap);
            }catch(Exception e){	}
    }
}