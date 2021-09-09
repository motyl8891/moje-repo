public without sharing class OppSummaryChartController {

    private final Opportunity o;
    public id PrimaryProposal {get;set;}
    public string R1 {get;set;}
    public string R2 {get;set;}
    public string R3 {get;set;}
    public string R4 {get;set;}

    public OppSummaryChartController(ApexPages.StandardController stdController) {
        List<Proposal__c> PPlist = new List<Proposal__c>();
        R1 = apexpages.currentpage().getparameters().get('R1');
        R2 = apexpages.currentpage().getparameters().get('R2');        
        R3 = apexpages.currentpage().getparameters().get('R3');
        R4 = apexpages.currentpage().getparameters().get('R4');
		this.o = (Opportunity)stdController.getRecord();
        for(Proposal__c p : [select id from proposal__c where primary__c = true and Opportunity__c =:o.id limit 1]){
        if(p.id!=null){
            PrimaryProposal = p.id;
        }
    }
        
    }


}