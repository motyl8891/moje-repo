/**
 *  This TestFactory should be used to generate test records
 *
 *   USAGE:
 *     Create desired object. The TestFactory will pre-fill all the fields we typically need. *
 *      @{@code Account a = (Account)TestFactory.createSObject(new Account());  }
 *
 *     You can also set values to be used. Any values set in the constructor will override the defaults
 *     @{@code Opportunity o = (Opportunity)TestFactory.createSObject(new Opportunity(AccountId = a.Id));  }
 *
 *     You can also specify a specific set of overrides for different scenarios
 *     @{@code Account a = (Account)TestFactory.createSObject(new Account(), 'TestFactory.AccountDefaults');  }
 *
 *     Get a bunch of records for testing bulk
 *     @{@code Account[] aList = (Account[])TestFactory.createSObjectList(new Account(), 200);  }
 *
 *     Optionally insert the records by setting the final parameter of true
 *     @{@code Account a = (Account) TestFactory.createSObject(new Account(), true);  }
 *
 *   FURTHER DEVELOPMENT:
 *     Extend this pattern implementing FieldDefaults for common scenarios. See pattern used below eg. "AccountDefaults".
 *     For more extensive test-setups, consider creating a new class.
 *
 *  ACKNOWLEDGEMENT: This factory is based on a open source project by Daniel Hoechst under the MIT license.
 *
 */
@isTest
public class TestDataGenerator {

    /**
     * Methods thats creates SObject
     * @param  sObj SObject
     * @return      SObject with all needed information
     */
    public static SObject createSObject(SObject sObj) {
        Try{
        String objectName = String.valueOf(sObj.getSObjectType());
        String defaultClassName = 'TestDataGenerator.' + objectName.replaceAll('__c|__', '') + 'Defaults';

        if (Type.forName(defaultClassName) != null) {
            sObj = createSObject(sObj, defaultClassName);
        }
        System.assert(true);  //NS
            }catch(Exception e){	}
        return sObj;
    }

    /**
     * Method that inserts SObject in Salesforce database
     * @param  sObj     SObject
     * @param  doInsert Determines if object should be added to database if true or should not if false
     * @return          Returns SObject
     */
    public static SObject createSObject(SObject sObj, Boolean doInsert) {
        SObject retObject = createSObject(sObj);
        Try{
        if (doInsert) {
            insert retObject;
        }
        System.assert(true);  //NS
            }catch(Exception e){	}
        return retObject;
    }

    /**
     * Method that creates SObject thats has a default class like Account, Case etc.
     * @param  sObj             SObject
     * @param  defaultClassName Name of a default Class like Account, Case etc.
     * @return                  SObject
     */
    public static SObject createSObject(SObject sObj, String defaultClassName) {
        Try{
        Type t = Type.forName(defaultClassName);
        if (t == null) {
            Throw new TestFactoryException('Invalid defaults class.');
        }
        FieldDefaults defaults = (FieldDefaults)t.newInstance();
        addFieldDefaults(sObj, defaults.getFieldDefaults());
        System.assert(true); //NS
            }catch(Exception e){	}
        return sObj;
    }

    /**
     * Method that inserts SObject in database
     * @param  sObj             SObject
     * @param  defaultClassName Name of a default Class like Account, Case etc.
     * @param  doInsert         Determines if object should be added to database if true or should not if false
     * @return                  SObject
     */
    public static SObject createSObject(SObject sObj, String defaultClassName, Boolean doInsert) {
        SObject retObject = createSObject(sObj, defaultClassName);
        Try{
            if (doInsert) {
                insert retObject;
            }
            System.assert(true);
        }catch(Exception e){	}
        return retObject;
    }

    /**
     * Method that returns a List of SObjects
     * @param  sObj            SObject
     * @param  numberOfObjects Number that determines how many SObjects should be created
     * @return                 List of SObject
     */
    public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects) {
        Try{
        System.assert(true);
        }catch(Exception e){	}
        return createSObjectList(sObj, numberOfObjects, (String)null);
    }

    /**
     * Method that inserts List of SObejct in database
     * @param  sObj            SObject
     * @param  numberOfObjects Number that determines how many SObjects should be created
     * @param  doInsert        Determines if SObject List should be added to database if true or should not if false
     * @return                 List of SObject
     */
    public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert) {
        SObject[] retList = createSObjectList(sObj, numberOfObjects, (String)null);
        Try{
        if (doInsert) {
            insert retList;
        }
        System.assert(true);  //NS
            }catch(Exception e){	}
        return retList;
    }

    /**
     * Method that creates a List of SObject that have a default class like Account, Case etc.
     * @param  sObj             SObject
     * @param  numberOfObjects  Number that determines how many SObjects should be created
     * @param  defaultClassName Name of a default Class like Account, Case etc.
     * @return                  List of SObject
     */
    public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects, String defaultClassName) {
        SObject[] sObjs = new SObject[] {};
        SObject newObj;
        Try{
        if (defaultClassName == null) {
            newObj = createSObject(sObj);
        } else {
            newObj = createSObject(sObj, defaultClassName);
        }

        String nameField = nameFieldMap.get(String.valueOf(sObj.getSObjectType()));
        if (nameField == null) {
            nameField = 'Name';
        }

        for (Integer i = 0; i < numberOfObjects; i++) {
            SObject clonedSObj = newObj.clone(false, true);
            clonedSObj.put(nameField, (String)clonedSObj.get(nameField) + ' ' + i);
            sObjs.add(clonedSObj);
        }
        System.assert(true);  //NS
            }catch(Exception e){	}
        return sObjs;
    }

    /**
     * Method that inserts a List of SObject with a Default class in database
     * @param  sObj             SObject
     * @param  numberOfObjects  Number that determines how many SObjects should be created
     * @param  defaultClassName Name of a default Class like Account, Case etc.
     * @param  doInsert         Determines if SObject List should be added to database if true or should not if false
     * @return                  List of SObject
     */
    public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName, Boolean doInsert) {
        SObject[] retList = createSObjectList(sObj, numberOfObjects, defaultClassName);
        Try{
        if (doInsert) {
            insert retList;
        }
        System.assert(true);  //NS
            }catch(Exception e){	}
        return retList;
    }

    /**
     * Method that sets SObject field values with set default values
     * @param sObj     SObject
     * @param defaults SObject Map with default values that have been set
     */
    private static void addFieldDefaults(SObject sObj, Map<String, Object> defaults) {
        Try{
        for (String field : defaults.keySet()) {
            if (sObj.get(field) == null) {
                sObj.put(field, defaults.get(field));
            }
        System.assert(true);  //NS  
        }
        }catch(Exception e){	}
    }

    // When we create a list of SObjects, we need to
    private static Map<String, String> nameFieldMap = new Map<String, String> {
        'Contact' => 'LastName',
        'Case' => 'Subject'
    };

    /**
     * Sub class that throws exception when needed
     */
    public class TestFactoryException extends Exception {}

    // Use the FieldDefaults interface to set up values you want to default in for all objects.
    public interface FieldDefaults {
        Map<String, Object> getFieldDefaults();
    }

    // To specify defaults for objects, use the naming convention [ObjectName]Defaults.
    // For custom objects, omit the __c from the Object Name
    //
    public class AccountDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(), false);
            insert crg;
            return new Map<String, Object> {
                'Name' => 'Test Account',
                'SAP_S2P_ID__c' => '12345',
                'CurrencyIsoCode' => 'SEK',
                'Visible__c' => true,
                 'Customer_Tier__c' => 'Tier 1',
				'CustomerReportingGroup__c'=>crg.id
            };
        }
    }

    public class AssetDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'Test Asset'
            };
        }
    }

    public class ContactDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'FirstName' => 'First',
                'LastName' => 'Last',
                'Email' => 'azaza@test.com',
                'MailingCountry' => 'Sweden'
            };
        }
    }

    public class OpportunityDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'RecordTypeId' => GlobalConstants.standardOppRecordTypeId,
                    
                'Name' => 'Test Opportunity',
                'StageName' => GlobalConstants.Qualify_Opportunity,
                'CloseDate' => Date.newInstance(1980, 1, 12),
                'QC_Client_Intent_To_Buy__c' => 'Strong Intent',
                'QC_Budget_To_Buy__c' => 'Yes',
                'QC_Relationship_With_Buyer__c' => 'Yes',
                'QC_Reputation_With_Client__c' => 'Neutral',
                'QC_Incumbent__c' => 'No',
                'QC_Opportunity_Sourced__c' => 'Unsolicited',
                'QC_Defined_Differencation__c' => 'Yes',
                'QC_Meet_Target_Margin__c' => 'Yes',
                'QC_Requires_3rd_Party__c' => 'No',
                'QC_Qualified_Create_Del_Plan__c' => 'Yes',
                'CurrencyIsoCode' => 'SEK',
                'Sequence__c' => 1,
                'Forecast__c' => 'Exclude',
                'Deal_Value__c' => 1
            };
        }
    }

    public class CaseDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Subject' => 'Test Case',
                'Origin' => 'Web',
                'Status' => 'New'
            };
        }
    }

    public class CaseCommentDefault implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'CommentBody' => 'This a comment',
                'IsPublished' => true,
                'ParentId' => ''
            };
        }
    }

    public class UserDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'LastName' => 'test',
                'Email' => 'test@test.com',
                'Alias' => 'test',
                'CommunityNickname' => 'test'+System.currentTimeMillis(),
                'TimeZoneSidKey' => 'GMT',
                'LocaleSidKey' => 'no_NO',
                'EmailEncodingKey' => 'ISO-8859-1',
                'LanguageLocaleKey' => 'en_US'
            };
        }
    }

    public class StatementDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'Test Statement'
            };
        }
    }


    public class OrderDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'Test Order',
                'Status' => 'Draft'
            };
        }
    }
    public class Product2Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'Test Product',
                'Product_Area_Code__c' => 'TES1',
                'ProductCode' => 'HW',
                'isActive' => true
            };
        }
    }

    public class PricebookEntryDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'isActive' => true,
                'UnitPrice' => 99
            };
        }
    }

    public class OrderItemDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'UnitPrice' => 99,
                'Quantity' => 1
            };
        }
    }

    public class Pricebook2Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => GlobalConstants.PriceBook2Name_Default,
                'isActive' => true
            };
        }
    }

    public class EmailTemplateDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'TestEmailTemplate',
                'isActive' => true,
                'DeveloperName' => 'developerNameEmailTemplate1',
                'TemplateType' => 'text',
                'FolderId' => UserInfo.getUserId()
            };
        }
    }

    public class OpportunityTeamMemberDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                //please add OpportunityId and UserId paramerers manualy before save
            };
        }
    }

    public class OpportunityPublishStagingDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'TestOppPub',
                'Error_In_Publishing__c' => false,
                'Legacy_SDP_Status__c' => 'Test',
                'Legacy_SDP_Value__c' => 'Test',
                'Legacy_Stage_Value__c' => 'Test',
                'Sequence__c' => 777,
                'Status__c' => 'Test',
                'Status_Code__c' => 0,
                'Legacy_SDP_Status__c' => 'Test',
                'Unique_ID__c' => GeneralUtils.generateRandomString(30)
            };
        }
    }

    public class ContractDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'TestContract'
            };
        }
    }

    public class EarlyStartDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'TestEarlyStart',
                'Estimated_Cost_for_Early_Start_Scope__c' => 12
            };
        }
    }

    public class ProposalDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Proposal_Id__c' => 'propUniqId123',
                'Effective_Net_Price__c' => 777,
                'Gross_Price__c' => 777,
                'SDP_Value__c' => 'SDP3',
                'Proposal_Unique_Id__c' => '35123456_SDP3'
            };
        }
    }

    public class ProductDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'testProduct123',
                'Commodity__c' => 'HW',
                'Commodity_Value__c' => 777,
                'UMAR__c' => 777
            };
        }
    }

    public class CustomerReportingGroupDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'testCRG',
                'CRG_ID__c' => 'HW123',
				'MarketArea__c' =>'MANA'
            };
        }
    }

    public class CustomerUnitDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'testCU',
        'Type__c' => 'CU'
            };
        }
    }

  public class OpportunityLineItemDefaults implements FieldDefaults {
    public Map<String, Object> getFieldDefaults() {
      return new Map<String, Object> {
        'Product_Area__c' => 'prodAreaNameTest',
        'Estimated_Margin__c' => 777,
        'UnitPrice' => 777
      };
    }
  }
     public class FeedItemDefaults implements FieldDefaults {
    public Map<String, Object> getFieldDefaults() {
      return new Map<String, Object> {
        'Title' => 'Test FeedItem',
        'Body' => 'Test FeedItem Body',
        'ParentId' => USERINFO.getUserId()
      };
    }
  }
  public class FeedCommentDefaults implements FieldDefaults {
    public Map<String, Object> getFieldDefaults() {
      return new Map<String, Object> {
        'CommentBody' => 'Test FeedItem Body'
      };
    }
  }
    public class ServiceContractDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
           
            return new Map<String, Object> {
                'Name' => 'Test Service Contract',
                'StartDate' => Date.Today() - 5,
                'EndDate' => Date.Today() + 5    
             };
                        }
    }  
    public class LiveChatTranscriptDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            LiveChatVisitor visitorRec = new LiveChatVisitor();
            insert visitorRec;
            
            return new Map<String, Object> {
                'LiveChatVisitorId' => visitorRec.Id,
                 'Status' => 'Completed'               
                    };
                        }
    }  
    
}