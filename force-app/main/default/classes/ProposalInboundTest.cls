@isTest(seeAllData = false)
private class ProposalInboundTest{
    
    @isTest
    public static void upsertProposalPOS(){
        Try{
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name =:GlobalConstants.INTEGRATIONUSERPROFILENAME].Id, UserName = 'ericsson888@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
          acc = (Account)TestDataGenerator.createSObject(new Account(), false);  
          insert acc;
        }

        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, OpportunityNumber__c = '35777'));
        insert opp;

        ProposalInbound.Proposal inbProp = new ProposalInbound.Proposal();
        inbProp.opportunityId = opp.OpportunityNumber__c;
        inbProp.proposalId = '777';
        inbProp.proposalName = '777';
        inbProp.sdpValue = GlobalConstants.sdpValueSDP2;
        inbProp.sdpStatus = GlobalConstants.sdpStatusSDP2;
        inbProp.pdProposalLink = 'www.google.com';
        inbProp.opportunityCurrency = 'SEK';
        inbProp.deliveryStartDate = String.valueOf(Date.newInstance(1991, 1, 13));
        inbProp.deliveryEndDate = String.valueOf(Date.newInstance(1991, 1, 13));
        inbProp.grossPrice = '777';
        inbProp.effectiveNetPrice = '777';
        inbProp.effectiveNetPriceIFRS15 = '777';
        inbProp.umbr = '777';
        inbProp.umbrIFRS15 = '777';
        inbProp.umar = '777';
        inbProp.umarIFRS15 = '777';

        ProposalInbound.ProposalProduct inbPropProd = new ProposalInbound.ProposalProduct();
        inbPropProd.commodity = '777';
    	inbPropProd.productArea = '777';
    	inbPropProd.effectiveNetPrice = '777';
    	inbPropProd.effectiveNetPriceIFRS15 = '777';
    	inbPropProd.umbr = '777';
    	inbPropProd.umbrIFRS15 = '777';
    	inbPropProd.umar = '777';
    	inbPropProd.umarIFRS15 = '777';

    	List<ProposalInbound.ProposalProduct> inbPropProdList = new List<ProposalInbound.ProposalProduct>();
    	inbPropProdList.add(inbPropProd);
    	inbProp.proposalProduct = inbPropProdList;

    	String response = ProposalInbound.upsertProposal(inbProp);

    	System.assertEquals(GlobalConstants.RESPONSE_SUCCESS_PROPOSAL_INBOUND, response);
            }catch(Exception e){	}
    }

    @isTest
    public static void upsertProposalNEG(){
        Try{
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name = :GlobalConstants.INTEGRATIONUSERPROFILENAME].Id, UserName = 'ericsson888@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
          acc = (Account)TestDataGenerator.createSObject(new Account(), false);  
          insert acc;
        }

        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, OpportunityNumber__c = '35777'));
        insert opp;

        ProposalInbound.Proposal inbProp = new ProposalInbound.Proposal();
        inbProp.opportunityId = opp.OpportunityNumber__c;
        inbProp.proposalId = '777';
        inbProp.proposalName = '777';
        inbProp.sdpValue = GlobalConstants.sdpValueSDP2;
        inbProp.sdpStatus = GlobalConstants.sdpStatusSDP2;
        inbProp.pdProposalLink = 'www.google.com';
        inbProp.opportunityCurrency = 'SEK';
        inbProp.deliveryStartDate = '13011991';
        inbProp.deliveryEndDate = String.valueOf(Date.newInstance(1991, 1, 13));
        inbProp.grossPrice = '777';
        inbProp.effectiveNetPrice = '777';
        inbProp.effectiveNetPriceIFRS15 = '777';
        inbProp.umbr = '777';
        inbProp.umbrIFRS15 = '777';
        inbProp.umar = '777';
        inbProp.umarIFRS15 = '777';

        ProposalInbound.ProposalProduct inbPropProd = new ProposalInbound.ProposalProduct();
        inbPropProd.commodity = '777';
    	inbPropProd.productArea = '777';
    	inbPropProd.effectiveNetPrice = '777';
    	inbPropProd.effectiveNetPriceIFRS15 = '777';
    	inbPropProd.umbr = '777';
    	inbPropProd.umbrIFRS15 = '777';
    	inbPropProd.umar = '777';
    	inbPropProd.umarIFRS15 = '777';

    	List<ProposalInbound.ProposalProduct> inbPropProdList = new List<ProposalInbound.ProposalProduct>();
    	inbPropProdList.add(inbPropProd);
    	inbProp.proposalProduct = inbPropProdList;

    	String response = ProposalInbound.upsertProposal(inbProp);

    	System.assertEquals('ERROR Invalid date: 13011991', response);
            }catch(Exception e){	}
    }

}