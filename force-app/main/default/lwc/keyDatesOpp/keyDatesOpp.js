import { api, LightningElement, wire } from 'lwc';
import PSD from "@salesforce/schema/Opportunity.Proposal_Submission_Date__c";
import CloseDate from "@salesforce/schema/Opportunity.CloseDate";
import EDStartDate from "@salesforce/schema/Opportunity.Estimated_Delivery_Start_Date__c";
import EDEndDate from "@salesforce/schema/Opportunity.Estimated_Delivery_End_Date__c";
import FrameStartDate from "@salesforce/schema/Opportunity.Frame_Start_Date__c";
import FrameEndDate from "@salesforce/schema/Opportunity.Frame_End_Date__c";
import FrameDuration from "@salesforce/schema/Opportunity.Frame_Duration__c";
import RecordTypeName from "@salesforce/schema/Opportunity.RecordTypeName__c";
import MarketArea from "@salesforce/schema/Opportunity.MarketArea__c";
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';

//const keyfileds = [PSD, CloseDate, EDStartDate, EDEndDate, FrameStartDate, FrameEndDate, FrameDuration, RecordTypeName, MarketArea];
const keyfileds = [RecordTypeName, MarketArea];
export default class KeyDatesOpp extends LightningElement {
          @api recordId;
          @api keydate;
          @api displayfiles = [];
          @api objectAPIName;
          objectApiName = "Opportunity";
          @wire(getRecord, { recordId: '$recordId', fields: keyfileds })
          wiredkeydate({ data, error }) {
                    if (data) {
                              this.keydate = data;
                             // console.log('************ 88 ***********', this.keydate);
                            //  console.log('********** RT 8 *************', this.keydate.fields.RecordTypeName__c.value);
                           //   console.log('************ MarketArea 8 ***********', this.keydate.fields.MarketArea__c.value);
                              if (this.keydate.fields.RecordTypeName__c.value == 'Standard Opportunity') {
                                        if (this.keydate.fields.MarketArea__c.value == 'MELA')     {
                                                  this.displayfiles = [PSD,CloseDate, EDStartDate, EDEndDate ];
                                                 // console.log('*********** 1 1 ************', this.displayfiles);

                                        } else {
                                                  this.displayfiles = [CloseDate, EDStartDate, EDEndDate ];
                                                //  console.log('*********** 2 2 ************', this.displayfiles);

                                        }  
                              } else if (this.keydate.fields.RecordTypeName__c.value == 'Frame / Amendment Opportunity'){
                                        if (this.keydate.fields.MarketArea__c.value == 'MELA')     {
                                                  this.displayfiles = [PSD,CloseDate, EDStartDate, EDEndDate, FrameStartDate, FrameEndDate, FrameDuration];
                                                 // console.log('*********** 3 3 ************', this.displayfiles);
                                        } else {
                                                  this.displayfiles = [CloseDate, EDStartDate, EDEndDate, FrameStartDate, FrameEndDate, FrameDuration];
                                                //  console.log('*********** 4 4 ************', this.displayfiles);
                                        } 
                              }
                    }
                    else if (error) {
                              console.log('Error, ', error);

                    }
          }

        /*  get PSD() {
                    return getFieldValue(this.keydate.data, PSD);
          }
          get CloseDate() {
                    return getFieldValue(this.keydate.data, CloseDate);
          }
          get EDStartDate() {
                    return getFieldValue(this.keydate.data, EDStartDate);
          }
          get EDEndDate() {
                    return getFieldValue(this.keydate.data, EDEndDate);
          }
          get FrameStartDate() {
                    return getFieldValue(this.keydate.data, FrameStartDate);
          }
          get FrameEndDate() {
                    return getFieldValue(this.keydate.data, FrameEndDate);
          }
          get FrameDuration() {
                    return getFieldValue(this.keydate.data, FrameDuration);
          }
          get RecordTypeName() {
                    return getFieldValue(this.keydate.data, RecordTypeName);
          }
          get MarketArea() {
                    return getFieldValue(this.keydate.data, MarketArea);
          }
          */
}