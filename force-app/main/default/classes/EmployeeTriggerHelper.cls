/****************************************************************
 * @author: Aditya Mohapatra
 * @date: 18-09-2019
 * @User Story: 0994
 * @description: This class is a helper class for EmployeeTriggerHandler
 *****************************************************************/
public class EmployeeTriggerHelper {
	/****************************************************************
	 * @author: Aditya Mohapatra
	 * @date: 18-09-2019
	 * @User Story: 0994
	 * @description: This method will set Salesforce User based on Signum
	 *****************************************************************/
	public static void setUserFromSignum(List<Employee__c> newEmployee) {
		Map<String, id> signumWithUserIdMap = new Map<String, id>();
		List<String> empSignumList = new List<String>();
		try {
			for (Employee__c emp : newEmployee) {
				empSignumList.add(emp.Signum__c);
			}
			if (!empSignumList.isEmpty()) {
				for (User user : [
					SELECT id, Signum__c
					FROM User
					WHERE Signum__c IN :empSignumList
					LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())
				]) {
					signumWithUserIdMap.put(user.Signum__c, user.id);
				}
			}
			if (!signumWithUserIdMap.isEmpty()) {
				for (Employee__c emp : newEmployee) {
					emp.Salesforce_User__c = signumWithUserIdMap.get(emp.Signum__c);
				}
			}
		} catch (Exception e) {
			EventLog.createLogFuture(
				Json.serialize(
					new EventLog.Error(
						GlobalConstants.SalesDecisionRecordTriggerHelper,
						GlobalConstants.createSDApproverRecords,
						GlobalConstants.SalesDecisionRecordTriggerHelper,
						true,
						e
					)
				)
			);
		}
	}
}