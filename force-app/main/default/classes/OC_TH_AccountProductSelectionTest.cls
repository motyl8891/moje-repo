@IsTest
public class OC_TH_AccountProductSelectionTest {
    
    @testsetup 
    static void setup(){
        
        List<OC_TH_Routing_Rules__c> routingRuleList = new List<OC_TH_Routing_Rules__c>();
        List<Group> groupList = new List<Group>();
        List<QueueSObject> queueList = new List<QueueSObject>();
        List<OC_TH_Queues__c> customQueueList = new List<OC_TH_Queues__c>();
        
        Id serviceProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id;   
        Id PermissionSetId = [select Id from PermissionSet WHERE PermissionSet.Name =:OC_TH_Constants.getBDAPermissionSet].Id;
        
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = serviceProfileId;
        testuser.IsActive = true;     
        insert testuser;
        
        //Create a permission set assignment record for test user       
        PermissionSetAssignment testAssignment = (PermissionSetAssignment)OC_TestDataGenerator.createSObject(new PermissionSetAssignment());
        testAssignment.AssigneeId= testuser.Id;
        testAssignment.PermissionSetId= PermissionSetId;
        insert testAssignment;
        
        Group testGroup1 = new Group(Name='Test queue group', Type='Queue');
        insert testGroup1;
        QueuesObject queue1 = new QueueSObject(
            QueueId = testGroup1.id, 
            SObjectType = 'Case');
        insert queue1;
        
        System.runAs(testUser){ 
            Account accountDataOne = (Account)OC_TestDataGenerator.createSObject(new Account(
                Account_Type__c = 'Service',
                Name = 'TestAccount001',
                RecordTypeId = OC_TH_Constants.getAccountServiceRecordTypeId));
            insert accountDataOne;
            
            Account accountDataTwo = (Account)OC_TestDataGenerator.createSObject(new Account(
                Account_Type__c = 'Service',
                Name = 'TestAccount002',
                RecordTypeId = OC_TH_Constants.getAccountServiceRecordTypeId));
            insert accountDataTwo;
            
            Product2 productNodeTypeRecOne = (Product2) OC_TestDataGenerator.createSObject(new Product2(
                OC_MD_Product_type__c = OC_TH_Constants.getNodeType,
                Product_Code_Number__c = '0001',
                Name = 'NT-P001',
                RecordTypeId = OC_TH_Constants.getNodeTypeRecordTypeId,
                isActive = True
            ));
            insert productNodeTypeRecOne;
            
            Product2 productNodeTypeRecTwo = (Product2) OC_TestDataGenerator.createSObject(new Product2(
                OC_MD_Product_type__c = OC_TH_Constants.getNodeType,
                Product_Code_Number__c = '0002',
                Name = 'NT-P002',
                RecordTypeId = OC_TH_Constants.getNodeTypeRecordTypeId,
                isActive = True
            )); 
            insert productNodeTypeRecTwo;
            
            Product2 productNodeCmpRecOne = (Product2) OC_TestDataGenerator.createSObject(new Product2(
                OC_MD_Product_type__c = OC_TH_Constants.getNodeComponent,
                Product_Code_Number__c = '0003',
                Name = 'NC-P001',
                RecordTypeId = OC_TH_Constants.getNodeComponentRecordTypeId,
                isActive = True
            ));
            insert productNodeCmpRecOne;
            
            Product2 productNodeCmpRecTwo = (Product2) OC_TestDataGenerator.createSObject(new Product2(
                OC_MD_Product_type__c = OC_TH_Constants.getNodeComponent,
                Product_Code_Number__c = '0004',
                Name = 'NC-P002',
                RecordTypeId = OC_TH_Constants.getNodeComponentRecordTypeId,
                isActive = True
            ));
            insert productNodeCmpRecTwo;
            
            Product2 productSolutionRecOne = (Product2) OC_TestDataGenerator.createSObject(new Product2(
                OC_MD_Product_type__c = OC_TH_Constants.getSolution,
                Product_Code_Number__c = '0005',
                Name = 'SOL-P001',
                RecordTypeId = OC_TH_Constants.getSolutionRecordTypeId,
                isActive = True
            ));
            insert productSolutionRecOne;
            
            Product2 productSolutionRecTwo = (Product2) OC_TestDataGenerator.createSObject(new Product2(
                OC_MD_Product_type__c = OC_TH_Constants.getSolution,
                Product_Code_Number__c = '0006',
                Name = 'SOL-P002',
                RecordTypeId = OC_TH_Constants.getSolutionRecordTypeId,
                isActive = True
            ));
            insert productSolutionRecTwo;
            
            OC_TH_Queues__c  queueRec = (OC_TH_Queues__c)OC_TestDataGenerator.createSObject(new OC_TH_Queues__c (
                Name  = 'Test queue group',
                OC_TH_Queue_Type__c = 'Local'    
            )); 
            insert queueRec;
            OC_TH_Routing_Rules__c routingRuleRec = (OC_TH_Routing_Rules__c)OC_TestDataGenerator.createSObject(new OC_TH_Routing_Rules__c(
                OC_TH_Active__c = True,
                OC_TH_Selected_Routing_Rule__c = 'With-in Market Area',
                OC_TH_Queue__c = queueRec.Id,
                OC_TH_Logic_Operator_Customer__c='Not Equal',
                Tech_OC_TH_Service_To_Party_ID__c= accountDataOne.Id+'#'+accountDataTwo.Id,
                OC_TH_ServiceToParty__c = '#TestAccount002#TestAccount001#Account 1#CLARO-BR#',
                OC_TH_NodeTypeProduct__c='#IVR#Juniper/EX-series#NT-P002#',
                OC_TH_NodeComponentProduct__c='#COMPONENT - 001#CMP-TEST-2#NC-P002#',
                OC_TH_SolutionProduct__c='#TEST-SOLUTION-003PRODUCT#TEST-SOL-PROD-02#TEST-SOL-001#SOL-P002#'
            ));
            insert routingRuleRec;  
        }
    }
    @isTest
    /* Account Wrapper test method*/
    static void testAccountWrapperMethod(){
        Test.startTest();
        OC_TH_AccountProductSelection.AccountProductSelectionWrapper wrapper = new OC_TH_AccountProductSelection.AccountProductSelectionWrapper();
        wrapper.isCompleted = false;
        wrapper.offsetCount = 0;
        OC_TH_AccountProductSelection.scrollAccountData(wrapper);
        wrapper.offsetCount = 1;
        OC_TH_AccountProductSelection.scrollAccountData(wrapper);
        wrapper.offsetCount = 2;
        OC_TH_AccountProductSelection.scrollAccountData(wrapper);
        wrapper.offsetCount = 4;
        OC_TH_AccountProductSelection.scrollAccountData(wrapper);
        wrapper.offsetCount = 400;
        OC_TH_AccountProductSelection.scrollAccountData(wrapper);
        OC_TH_Routing_Rules__c routingRec = [SELECT Id FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        Account accRec = [SELECT Id,Name FROM Account WHERE Name = 'TestAccount001'];
        Test.stopTest();
    }
    
    @isTest
    /* Product2 Wrapper test method*/
    static void testProductWrapperMethod(){
        Test.startTest();
        OC_TH_AccountProductSelection.ProductSelectionWrapper prodWrapper = new OC_TH_AccountProductSelection.ProductSelectionWrapper();
        prodWrapper.isCompleted = false;
        prodWrapper.offsetCount = 0;
        OC_TH_AccountProductSelection.getProducts(prodWrapper);
        prodWrapper.offsetCount = 1;
        OC_TH_AccountProductSelection.getProducts(prodWrapper);
        prodWrapper.offsetCount = 2;
        OC_TH_AccountProductSelection.getProducts(prodWrapper);
        prodWrapper.offsetCount = 4;
        OC_TH_AccountProductSelection.getProducts(prodWrapper);
        prodWrapper.offsetCount = 400;
        OC_TH_AccountProductSelection.getProducts(prodWrapper);
        OC_TH_Routing_Rules__c routingRec = [SELECT Id FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        Product2 prodRec = [SELECT Id, Name,RecordTypeId,isActive,OC_MD_Product_type__c FROM Product2 WHERE OC_MD_Product_type__c =: OC_TH_Constants.getNodeType LIMIT 1];
        Test.stopTest();
    }
    @isTest
    /*Test method for JSON checked account selections*/
    static void testSelectedAccountJsonInputMethod(){
        Test.startTest();
        OC_TH_Routing_Rules__c routingRec = [SELECT Id FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        Account accRec = [SELECT Id,Name FROM Account WHERE Name = 'TestAccount001'];
        String inputJson = '{"selected":{}, "deselected":{}}';
        OC_TH_AccountProductSelection.submitAccountDetails(inputJson,routingRec.Id,'Equal');
        inputJson = '{"selected":{"'+accRec.Id
            +'":{"Id":"'+accRec.Id
            +'","Name":"'+accRec.Name
            +'", "selectedState":"checked" } }, "deselected":{ } }';
        OC_TH_AccountProductSelection.submitAccountDetails(inputJson,routingRec.Id,'Equal');
        OC_TH_Routing_Rules__c routingRecSelected = [SELECT Id,OC_TH_ServiceToParty__c,Tech_OC_TH_Service_To_Party_ID__c FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        System.assertEquals(routingRecSelected.Id,routingRec.Id);
        Test.stopTest();
    }
    
    @isTest
    /*Test method for JSON Unchecked account selections*/
    static void testDeSelectedAccountJsonInputMethod(){
        Test.startTest();
        OC_TH_Routing_Rules__c routingRec = [SELECT Id FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        Account accRec = [SELECT Id,Name FROM Account WHERE Name = 'TestAccount002' LIMIT 1];
        String inputJson = '{"selected":{}, "deselected":{}}';
        OC_TH_AccountProductSelection.submitAccountDetails(inputJson,routingRec.Id,'Equal');
        inputJson = '{"selected":{"'+accRec.Id
            +'":{"Id":"'+accRec.Id
            +'","Name":"'+accRec.Name
            +'", "selectedState":"checked" } }, "deselected":{"'+accRec.Id
            +'":{"Id":"'+accRec.Id
            +'","Name":"'+accRec.Name
            +'", "selectedState": "unchecked" }}}';
        OC_TH_AccountProductSelection.submitAccountDetails(inputJson,routingRec.Id,'Equal');
        OC_TH_Routing_Rules__c routingRecDeSelected = [SELECT Id,OC_TH_ServiceToParty__c,Tech_OC_TH_Service_To_Party_ID__c FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        System.assertEquals(routingRecDeSelected.Id,routingRec.Id);
        Test.stopTest();
    }
    @isTest
    /*Test method for JSON checked product2 node type selections*/
    static void testSelectedNodeTypeMethod(){
        Test.startTest();
        OC_TH_Routing_Rules__c routingRec = [SELECT Id FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        Product2 prodRecNodeType = [SELECT Id, Name,RecordTypeId,isActive,OC_MD_Product_type__c FROM Product2 
                                    WHERE RecordTypeId =: OC_TH_Constants.getNodeTypeRecordTypeId LIMIT 1];
        String inputJson = '{"selected":{}, "deselected":{}}';
        OC_TH_AccountProductSelection.submitProduct2Details(inputJson,routingRec.Id);
        inputJson = '{"selected":{"'+prodRecNodeType.Id
            +'":{"Id":"'+prodRecNodeType.Id
            +'","Name":"'+prodRecNodeType.Name
            +'", "selectedState":"checked" } }, "deselected":{ } }';
        OC_TH_AccountProductSelection.submitProduct2Details(inputJson,routingRec.Id);
        OC_TH_Routing_Rules__c routingNodeTypeSelection = [SELECT Id,OC_TH_NodeTypeProduct__c FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        System.assertEquals(routingNodeTypeSelection.Id,routingRec.Id);
        Test.stopTest();
    }
    
    @isTest
    /*Test method for JSON checked product2 node component selections*/
    static void testSelectedNodeCmpMethod(){
        Test.startTest();
        OC_TH_Routing_Rules__c routingRec = [SELECT Id FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        Product2 prodRecNodeComponent = [SELECT Id, Name,RecordTypeId,isActive,OC_MD_Product_type__c FROM Product2 
                                         WHERE RecordTypeId =: OC_TH_Constants.getNodeComponentRecordTypeId LIMIT 1];
        String inputJson = '{"selected":{}, "deselected":{}}';
        OC_TH_AccountProductSelection.submitProduct2Details(inputJson,routingRec.Id);
        inputJson = '{"selected":{"'+prodRecNodeComponent.Id
            +'":{"Id":"'+prodRecNodeComponent.Id
            +'","Name":"'+prodRecNodeComponent.Name
            +'", "selectedState":"checked" } }, "deselected":{ } }';
        OC_TH_AccountProductSelection.submitProduct2Details(inputJson,routingRec.Id);
        OC_TH_Routing_Rules__c routingNodeComponentSelection = [SELECT Id,OC_TH_NodeComponentProduct__c FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        System.assertEquals(routingNodeComponentSelection.Id,routingRec.Id);
        Test.stopTest();
    }
    @isTest
    /*Test method for JSON checked product2 Solution selections*/
    static void testSelectedSolutionMethod(){
        Test.startTest();
        OC_TH_Routing_Rules__c routingRec = [SELECT Id FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        Product2 prodRecSolution = [SELECT Id, Name,RecordTypeId,isActive,OC_MD_Product_type__c FROM Product2 
                                    WHERE RecordTypeId =: OC_TH_Constants.getSolutionRecordTypeId LIMIT 1];
        String inputJson = '{"selected":{}, "deselected":{}}';
        OC_TH_AccountProductSelection.submitProduct2Details(inputJson,routingRec.Id);
        inputJson = '{"selected":{"'+prodRecSolution.Id
            +'":{"Id":"'+prodRecSolution.Id
            +'","Name":"'+prodRecSolution.Name
            +'", "selectedState":"checked" } }, "deselected":{ } }';
        OC_TH_AccountProductSelection.submitProduct2Details(inputJson,routingRec.Id);
        OC_TH_Routing_Rules__c routingSolutionSelection = [SELECT Id,OC_TH_SolutionProduct__c FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        System.assertEquals(routingSolutionSelection.Id,routingRec.Id);
        Test.stopTest();
    }
    @isTest
    /*Test method for JSON Unchecked product2 Node type selections*/
    static void testDeSelectedNodeTypeMethod(){
        Test.startTest();
        OC_TH_Routing_Rules__c routingRec = [SELECT Id FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        Product2 prodRecNodeType = [SELECT Id, Name,RecordTypeId,isActive,OC_MD_Product_type__c FROM Product2 
                                    WHERE RecordTypeId =: OC_TH_Constants.getNodeTypeRecordTypeId AND Name = 'NT-P002' LIMIT 1];
        String inputJson = '{"selected":{}, "deselected":{}}';
        OC_TH_AccountProductSelection.submitProduct2Details(inputJson,routingRec.Id);
        inputJson = '{"selected":{} , "deselected":{"'+prodRecNodeType.Id
            +'":{"Id":"'+prodRecNodeType.Id
            +'","Name":"'+prodRecNodeType.Name
            +'", "selectedState":"unchecked" } }}';
        OC_TH_AccountProductSelection.submitProduct2Details(inputJson,routingRec.Id);
        OC_TH_Routing_Rules__c routingNodeTypeDeSelection = [SELECT Id,OC_TH_NodeTypeProduct__c FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        System.assertEquals(routingNodeTypeDeSelection.Id,routingRec.Id);
        Test.stopTest();
    }
    @isTest
    /*Test method for JSON Unchecked product2 Node component selections*/
    static void testDeSelectedNodeComponentMethod(){
        Test.startTest();
        OC_TH_Routing_Rules__c routingRec = [SELECT Id FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        Product2 prodRecNodeCmp = [SELECT Id, Name,RecordTypeId,isActive,OC_MD_Product_type__c FROM Product2 
                                   WHERE RecordTypeId =: OC_TH_Constants.getNodeComponentRecordTypeId AND Name = 'NC-P002' LIMIT 1];
        String inputJson = '{"selected":{}, "deselected":{}}';
        OC_TH_AccountProductSelection.submitProduct2Details(inputJson,routingRec.Id);
        inputJson = '{"selected":{} , "deselected":{"'+prodRecNodeCmp.Id
            +'":{"Id":"'+prodRecNodeCmp.Id
            +'","Name":"'+prodRecNodeCmp.Name
            +'", "selectedState":"unchecked" } }}';
        OC_TH_AccountProductSelection.submitProduct2Details(inputJson,routingRec.Id);
        OC_TH_Routing_Rules__c routingNodeComponentDeSelection = [SELECT Id,OC_TH_NodeComponentProduct__c FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        System.assertEquals(routingNodeComponentDeSelection.Id,routingRec.Id);
        Test.stopTest();
    }
    @isTest
    /*Test method for JSON Unchecked product2 solution selections*/
    static void testDeSelectedSolutionJsonInputMethod(){
        Test.startTest();
        OC_TH_Routing_Rules__c routingRec = [SELECT Id FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        Product2 prodRecSolution = [SELECT Id, Name,RecordTypeId,isActive,OC_MD_Product_type__c FROM Product2 
                                    WHERE RecordTypeId =: OC_TH_Constants.getSolutionRecordTypeId AND Name = 'SOL-P002' LIMIT 1];
        String inputJson = '{"selected":{}, "deselected":{}}';
        OC_TH_AccountProductSelection.submitProduct2Details(inputJson,routingRec.Id);
        inputJson = '{"selected":{} , "deselected":{"'+prodRecSolution.Id
            +'":{"Id":"'+prodRecSolution.Id
            +'","Name":"'+prodRecSolution.Name
            +'", "selectedState":"unchecked" } }}';
        OC_TH_AccountProductSelection.submitProduct2Details(inputJson,routingRec.Id);
        OC_TH_Routing_Rules__c routingSolutionDeSelection = [SELECT Id,OC_TH_SolutionProduct__c FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        System.assertEquals(routingSolutionDeSelection.Id,routingRec.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testMethodForSelection(){
        Test.startTest();
        OC_TH_Routing_Rules__c routingRec = [SELECT Id FROM OC_TH_Routing_Rules__c WHERE Id != null LIMIT 1];
        //System asserts to check getProductRecordTypes output
        //Method should return all product Types, assert equals should evaluate true
        Map<String,String> productRecordTypes= OC_TH_AccountProductSelection.getProductRecordTypes();   
        system.assertEquals('Node Component', productRecordTypes.values()[0]);
        system.assertEquals('Node Type', productRecordTypes.values()[1]);
        system.assertEquals('Solution', productRecordTypes.values()[2]);
        //System asserts to check fetchSelectedAccountsOnly output
        //Method should return account details like name & Id from routing rule, assert equals should evaluate true
        List<Account> accList= OC_TH_AccountProductSelection.fetchSelectedAccountsOnly(routingRec.Id);
        system.assertEquals('TestAccount001', accList[0].Name);
        system.assertEquals('TestAccount002', accList[1].Name);
        //System asserts to check picklistVal output
        //Method should return routing rule Logic Operator Customer values, assert equals should evaluate true
        Map<String, String> picklistVal = OC_TH_AccountProductSelection.getLogicalOpeartorCustomerValues();
        system.assertEquals('Equal', picklistVal.values()[0]);
        system.assertEquals('Not Equal', picklistVal.values()[1]);
        //System asserts to check getRoutingRuleLogicalOperator output
        //Method should return routing rule Logic Operator Customer values, assert equals should evaluate true      
        OC_TH_Routing_Rules__c obj= OC_TH_AccountProductSelection.getRoutingRuleLogicalOperator(routingRec.Id);
        system.assertEquals('Not Equal', obj.OC_TH_Logic_Operator_Customer__c);
        //System asserts to check associateLogicalOperatorToRoutingRule output
        //Method should update passed Logic Operator Customer value to technical field, assert equals should evaluate true      
        OC_TH_AccountProductSelection.associateLogicalOperatorToRoutingRule(routingRec.Id,OC_TH_Constants.equal);
        OC_TH_Routing_Rules__c routingRecAfterUpdate = [SELECT OC_TH_Logic_Operator_Customer__c FROM OC_TH_Routing_Rules__c WHERE Id =:routingRec.Id];
        System.assertEquals('Equal', routingRecAfterUpdate.OC_TH_Logic_Operator_Customer__c);
        //System asserts to check showErrorMessage output
        //Method should return true if test user us assigned to BDA permission set, assert equals should evaluate true          
        Boolean errorMessage= OC_TH_AccountProductSelection.showErrorMessage();
        System.assertEquals(True, errorMessage);
        //System asserts to check validationForLength output
        //Method should return true if routing rule Account & Product selection related fields length exceeds 255, assert equals should evaluate true          
        Boolean limitExceeded1= OC_TH_AccountProductSelection.validationForLength(OC_TH_Constants.dummyJSONInputForTestClassLimitBreach, routingRec.Id);
        System.assertEquals(True, limitExceeded1);
        //System asserts to check validationForLength output
        //Method should return false if routing rule Account & Product selection related fields length doesn't exceeds 255, assert equals should evaluate true                
        Boolean limitExceeded2= OC_TH_AccountProductSelection.validationForLength(OC_TH_Constants.dummyJSONInputForTestClassNoLimitBreach, routingRec.Id);
        System.assertEquals(False, limitExceeded2);
        //System asserts to check getProductName output
        //Method should return product details like name, Id & recordTypeId from routing rule, assert equals should evaluate true     
        List<Product2> productList= OC_TH_AccountProductSelection.getProductName(routingRec.Id);
        system.assertEquals('NT-P002', productList[0].Name);
        system.assertEquals('NC-P002', productList[1].Name);
        system.assertEquals('SOL-P002', productList[2].Name);
        Test.stopTest();
    }
    
    
    
}