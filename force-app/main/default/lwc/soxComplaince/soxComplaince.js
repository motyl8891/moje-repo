import { LightningElement, api } from 'lwc';
import SignedContract from "@salesforce/schema/Opportunity.SignedContract__c";
import IFRSTranslationDocument from "@salesforce/schema/Opportunity.IFRSTranslationDocument__c";
import SOXLA1ComplianceStatus from "@salesforce/schema/Opportunity.SOXLA1ComplianceStatus__c";
import CustomerNetPriceList from "@salesforce/schema/Opportunity.CustomerNetPriceList__c";
import SOXLA1111Comments from "@salesforce/schema/Opportunity.SOXLA1111Comments__c";

export default class SoxComplaince extends LightningElement {          
          @api recordId;
          @api objectAPIName;
          objectApiName = "Opportunity";
          fields = [SignedContract, IFRSTranslationDocument, SOXLA1ComplianceStatus, CustomerNetPriceList, SOXLA1111Comments];
}