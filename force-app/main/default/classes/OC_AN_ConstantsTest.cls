/**
* @File Name          : OC_AN_ConstantsTest
* @Description        : Test Class for
*						OC_AN_Constants
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10th April 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-04-10              	IBM               Initial Version
**/


@isTest
public class OC_AN_ConstantsTest {
    
    @isTest(seeAllData = false)
    static void testConstantsInitialization(){
        Test.startTest();
        OC_AN_Constants.testConstants();  
        Test.stopTest();
    }

}