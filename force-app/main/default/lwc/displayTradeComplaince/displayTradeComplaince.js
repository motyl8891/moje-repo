import { LightningElement, api } from "lwc";
//import NAME_FIELD from "@salesforce/schema/Opportunity.Name";
import Sensitive_Product_List__c_FIELD from "@salesforce/schema/Opportunity.Sensitive_Product_List__c";
import Trade_Compliance_Status__c_FIELD from "@salesforce/schema/Opportunity.Trade_Compliance_Status__c";
import Trade_Classifications__c_FIELD from "@salesforce/schema/Opportunity.Trade_Classifications__c";
import Sensitive_Products_in_scope__c_FIELD from "@salesforce/schema/Opportunity.Sensitive_Products_in_scope__c";

export default class DisplayTradeComplaince extends LightningElement {
    @api recordId;
    @api objectApiName;

    objectApiName = "Opportunity";
    fields = [Trade_Compliance_Status__c_FIELD, Trade_Classifications__c_FIELD, Sensitive_Products_in_scope__c_FIELD, Sensitive_Product_List__c_FIELD];
}