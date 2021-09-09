public class GSTSearchBatch implements Database.batchable<sobject>, Database.Stateful {
	public Map<Id, List<GSTSearchWrapper>> userSearch = new Map<Id, List<GSTSearchWrapper>>();

	public Database.QueryLocator start(Database.BatchableContext BC) {
		//Query to select all id, createdDate and CreatedById for all search objects
		String query = 'select Id,CreatedById,CreatedDate from GstCustomSearch__c';
		return Database.getQueryLocator(query);
	}
	public void execute(
		Database.BatchableContext BC,
		List<GstCustomSearch__c> scope
	) {
		for (GstCustomSearch__c obj : scope) {
			if (userSearch.get(obj.CreatedById) == null) {
				//User is not in Map already
				List<GSTSearchWrapper> tempList = new List<GSTSearchWrapper>();
				tempList.add(new GSTSearchWrapper(obj));
				userSearch.put(obj.CreatedById, tempList);
				//System.debug('in null'+userSearch.size());
			} else {
				//User is in Map, fetch the list and update it
				List<GSTSearchWrapper> tempList = userSearch.get(obj.CreatedById);
				tempList.add(new GSTSearchWrapper(obj));
				userSearch.put(obj.CreatedById, tempList);
			}
		}
	}
	public void finish(Database.BatchableContext BC) {
		//Iterate over the map, sort and delete per user
		List<GstCustomSearch__c> deleteList = new List<GstCustomSearch__c>();
		for (Id userId : userSearch.keySet()) {
			List<GSTSearchWrapper> wrapperList = userSearch.get(userId);
			wrapperList.sort();
			Integer i = 0;
			for (GSTSearchWrapper search : wrapperList) {
				//integer.ValueOf(System.Label.SearchObjectstoKeep given the dynamic value of search objects that need to be kept per user
				if (i > integer.ValueOf(System.Label.SearchObjectstoKeep)) {
					//Adding all the search objects which are more than SearchObjectstoKeep value
					deleteList.add(search.searchObj);
				}
				i++;
			}
		}
		//Deleting
		System.debug('Deleting: ' + deleteList.size() + ' search records');
		Database.delete(deleteList);
	}
}