@isTest
private class GSTSearchWrapperTest {
	static testMethod void test1() {
		// Add the opportunity wrapper objects to a list.
		List<GSTSearchWrapper> searchList = new List<GSTSearchWrapper>();

		searchList.add(
			new GSTSearchWrapper(new GstCustomSearch__c(Name = 'Search 1'))
		);
		searchList.add(
			new GSTSearchWrapper(new GstCustomSearch__c(Name = 'Search 2'))
		);
		searchList.add(
			new GSTSearchWrapper(new GstCustomSearch__c(Name = 'Search 3'))
		);

		// Sort the wrapper objects using the implementation of the
		// compareTo method.
		searchList.sort();

		// Verify the sort order
		System.assertEquals('Search 1', searchList[0].searchObj.Name);
		System.assertEquals('Search 2', searchList[1].searchObj.Name);
		System.assertEquals('Search 3', searchList[2].searchObj.Name);

		// Write the sorted list contents to the debug log.
		System.debug(searchList);
	}
}