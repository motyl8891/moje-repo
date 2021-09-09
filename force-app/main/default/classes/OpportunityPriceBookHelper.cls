public class OpportunityPriceBookHelper{
    
    public static void populatePriceBookIdOnNewOpp(List<Opportunity> newOppsList){

        try{
            //String defaultPriceBookName = System.Label.PriceBook2Name_Default;
            //if(String.isBlank(defaultPriceBookName))throw new UtilException('Custom Exception: Label PriceBook2Name_Default does not exist or empty');

            //List<PriceBook2> priceBook2List = [SELECT Id FROM PriceBook2 WHERE Name =: defaultPriceBookName];
            //if(priceBook2List.size() == 0)throw new UtilException('Custom Exception: PriceBook2 with name '+defaultPriceBookName+' not found');
            //Updated by Anukriti to resolve 101 SOQL Issue- D-1809
           String pbId = GlobalConstants.PriceBook2Name_Default_Id;

            for(Opportunity opp: newOppsList){
                opp.PriceBook2Id = pbId;
            }
        }catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityPriceBookHelper, GlobalConstants.populatePriceBookIdOnNewOpp, GlobalConstants.OpportunityPriceBookHelper, true, e)));throw e;}
    }
}