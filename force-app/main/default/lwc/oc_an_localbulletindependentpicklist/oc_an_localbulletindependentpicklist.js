/**
* File Name          : oc_an_localbulletindependentpicklist
* Description        : Controller to get dependent picklist value of Sub Status and handle custom events
                       related to status & substatus change for Alerts and Notifications.
* Author             : IBM
* Group              : OmniChannel - Service
* Created Date       : 31 May 2021
* Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-31                IBM                   Initial Version
**/

import { LightningElement,track, api, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import BAP_OBJECT from '@salesforce/schema/OC_AN_Bulletin_Account_Product__c';
import SUBSTATUS_FIELD from '@salesforce/schema/OC_AN_Bulletin_Account_Product__c.OC_AN_Sub_Status__c';
import {labels} from './oc_an_localbulletindependentpicklistLabels';


export default class oc_an_localbulletindependentpicklist extends LightningElement {
@api acc;
@api status;
@track substatus=[];
SubStatusPicklistValues=[];
label = labels; 

 // Create dependent picklists
 @wire(getObjectInfo, { objectApiName: BAP_OBJECT })
 objectInfo;

@wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SUBSTATUS_FIELD})
  SubStatusVal({ data, error }) {
    if (data) this.SubStatusPicklistValues = data;

}

// When component loads, populate substatus dependent values based on status
connectedCallback(){
    let tempArray = JSON.parse(JSON.stringify(this.substatus))  //deep cloning
    this.substatus = tempArray;
   console.log('status'+JSON.stringify(this.status));
   console.log('status'+this.acc.OC_AN_Status__c);
    //Reset array and push values accordingly
    this.substatus=[];   
    if(this.acc.OC_AN_Status__c=== this.label.oc_an_send){
        this.substatus.push({label : this.label.oc_an_send, value : this.label.oc_an_send});
    }  
    if(this.acc.OC_AN_Status__c=== this.label.oc_an_under_analysis){
        this.substatus.push({label : this.label.oc_an_under_analysis, value : this.label.oc_an_under_analysis});
    }   
    if(this.acc.OC_AN_Status__c=== this.label.oc_an_action_required){
         this.substatus.push({label : this.label.oc_an_action_required, value : this.label.oc_an_action_required});
     }    
    if(this.acc.OC_AN_Status__c=== this.label.oc_an_hold){
         this.substatus.push({label: this.label.oc_an_forHoldValue1, value: this.label.oc_an_forHoldValue1},
                            {label:this.label.oc_an_forHoldValue2, value:this.label.oc_an_forHoldValue2},
                            {label:this.label.oc_an_forHoldValue3, value:this.label.oc_an_forHoldValue3});
     }

    
}

//Handle status changes and fetch dependent picklist values from controller
//Dependent list values are fetched using generic method
//Dispatching a custom event after status change to parent cmp
handleStatusChange(event) {     
        const selectedVal = event.detail.value;
        this.statusRowId = event.currentTarget.dataset.id;
        this.statusChangeSelectedVal= event.detail.value;
        this.substatus=[]; //reset array before pushing dependent values

             let controllerValues = this.SubStatusPicklistValues.controllerValues;
                this.SubStatusPicklistValues.values.forEach(depVal => {
                    depVal.validFor.forEach(depKey =>{
                        if(depKey === controllerValues[this.statusChangeSelectedVal]){
                                  
                            this.substatus.push({label : depVal.label, value : depVal.value});
                        }
                    });
                     
                });

        // Creates the event with the data.
        const selectedEvent = new CustomEvent("valuechange", {
        detail: {
            RecordId: this.statusRowId,
            Status:this.statusChangeSelectedVal
        }
      });
      // Dispatches the event.
      this.dispatchEvent(selectedEvent);       
     }

    //Dispatching a custom event after sub status change to parent cmp
    //Handle sub status changes
     handleSubStatusChange(event) {
      
        this.substatusRowId = event.currentTarget.dataset.id;
        this.substatusChangeSelectedVal= event.detail.value;
        // Creates the event with the data.
        const selectedEvent1 = new CustomEvent("valuechanges", {
            detail: {
                RecordId: this.substatusRowId,
                SUBSTATUS:this.substatusChangeSelectedVal   
            }
          });      
          // Dispatches the event.
          this.dispatchEvent(selectedEvent1);
     }
}