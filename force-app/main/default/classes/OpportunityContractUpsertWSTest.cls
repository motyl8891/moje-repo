@isTest(SeeAllData=false)
private without sharing class OpportunityContractUpsertWSTest {
	@isTest
	static void testAllFieldsisNull() {
		OpportunityContractUpsert_WS.OpportunityContract testOc = new OpportunityContractUpsert_WS.OpportunityContract();
		OpportunityContractUpsert_WS.OpportunityContract_VLE[] testOcProdLs = new List<OpportunityContractUpsert_WS.OpportunityContract_VLE>();
		OpportunityContractUpsert_WS.OpportunityContract_VLE testProd1 = new OpportunityContractUpsert_WS.OpportunityContract_VLE();

		String testresult = '';

		testProd1.EricssonCompanyCode = 'erics_code_test';
		testProd1.SoldtopartyLocalID = '60';
		testProd1.SoldtopartyStatus = 'test_status';

		testOcProdLs.add(testProd1);

		/*
		test_pp_prod_ls[1].RelatingCommodity='test2_1';
		test_pp_prod_ls[1].RelatingProductPercentage='40';
		test_pp_prod_ls[1].RelatingProductCode='test2_2'; */

		testOc.ContractID = '';
		testOc.ContractClassification = '';
		testOc.ContractName = '';
		testOc.ContractUrl = '';
		testOc.ContractOwner = '';
		testOc.ContractSigningPartyID = '';
		testOc.OpportunityContracts_VLE = testOcProdLs;

		testresult = OpportunityContractUpsert_WS.upsertOpportunityContract(testOc);

		System.assertEquals(testresult, 'OK');

		// Implement test code
	}

	@isTest
	static void testSomeFieldsisMore255() {
		OpportunityContractUpsert_WS.OpportunityContract testOc = new OpportunityContractUpsert_WS.OpportunityContract();
		OpportunityContractUpsert_WS.OpportunityContract_VLE[] testOcProdLs = new List<OpportunityContractUpsert_WS.OpportunityContract_VLE>();
		OpportunityContractUpsert_WS.OpportunityContract_VLE testProd1 = new OpportunityContractUpsert_WS.OpportunityContract_VLE();

		String testresult = '';

		testProd1.EricssonCompanyCode = 'erics_code_test2';
		testProd1.SoldtopartyLocalID = '75421';
		testProd1.SoldtopartyStatus = 'test_status_2';

		testOcProdLs.add(testProd1);

		/*
		test_pp_prod_ls[1].RelatingCommodity='test2_1';
		test_pp_prod_ls[1].RelatingProductPercentage='40';
		test_pp_prod_ls[1].RelatingProductCode='test2_2'; */

		testOc.ContractID = '';
		testOc.ContractClassification = 'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia,			 looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" ((The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.';
		testOc.ContractName = '';
		testOc.ContractUrl = '';
		testOc.ContractOwner = '';
		testOc.ContractSigningPartyID = '';
		testOc.OpportunityContracts_VLE = testOcProdLs;

		testresult = OpportunityContractUpsert_WS.upsertOpportunityContract(testOc);

		System.assertEquals(testresult, 'OK');

		// Implement test code
	}
}