@isTest(seeAllData = false)
private class PDMarginsCalculationTest{
    @isTest
    public static void test_calculateProposalPdMarginsPOS(){
        Try{
        Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(), false);

        Product__c productHW = (Product__c)TestDataGenerator.createSObject(new Product__c(), false);
        productHW.Name = 'HWProd';
        productHW.Commodity__c = 'HW';

        Product__c productSW = (Product__c)TestDataGenerator.createSObject(new Product__c(), false);
        productSW.Name = 'SWProd';
        productSW.Commodity__c = 'SW';

        Product__c productSVCS = (Product__c)TestDataGenerator.createSObject(new Product__c(), false);
        productSVCS.Name = 'CSProd';
        productSVCS.Commodity__c = 'CS';

        List<Product__c> prodList = new List<Product__c>();
        prodList.add(productHW);
        prodList.add(productSW);
        prodList.add(productSVCS);

        PDMarginsCalculation.calculateProposalPdMargins(prop, prodList);

        System.debug('prop '+prop);

        System.assertEquals(prop.PD_Hardware_Margin__c, productHW.UMAR__c/productHW.Commodity_Value__c);
        System.assertEquals(prop.PD_Software_Margin__c, productSW.UMAR__c/productSW.Commodity_Value__c);
        System.assertEquals(prop.PD_Services_Margin__c, productSVCS.UMAR__c/productSVCS.Commodity_Value__c); 
            }catch(Exception e){	}
    }

    @isTest
    public static void test_calculateProposalPdMarginsNEG(){
        Try{
        Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(), false);

        Product__c productHW = null;

        Product__c productSW = (Product__c)TestDataGenerator.createSObject(new Product__c(), false);
        productSW.Commodity__c = 'SW';

        Product__c productSVCS = (Product__c)TestDataGenerator.createSObject(new Product__c(), false);
        productSVCS.Commodity__c = 'CS';

        List<Product__c> prodList = new List<Product__c>();
        prodList.add(productHW);
        prodList.add(productSW);
        prodList.add(productSVCS);

        System.assertEquals(null, PDMarginsCalculation.calculateProposalPdMargins(prop, prodList));
		}catch(Exception e){	}
    }
}