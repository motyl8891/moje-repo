/**
* File Name          : oc_an_localBulletinCreationLWC
* Description        : Controller to pass modified bulletin data to apex, in order to handle local bulletin creation
                        to Alerts and Notifications.
* Author             : IBM
* Group              : OmniChannel - Service
* Created Date       : 31 May 2021
* Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-31                IBM                   Initial Version
**/

import { LightningElement , track, api, wire} from 'lwc';
import getExternalDistributionList from '@salesforce/apex/OC_AN_LocalBulletinCreationController.getExternalDistributionList';  
import createLocalBulletin from '@salesforce/apex/OC_AN_LocalBulletinCreationController.createLocalBulletin';  
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import BAP_OBJECT from '@salesforce/schema/OC_AN_Bulletin_Account_Product__c';
import STATUS_FIELD from '@salesforce/schema/OC_AN_Bulletin_Account_Product__c.OC_AN_Status__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {allConstants, labels} from './oc_an_LocalBulletinCreationMainLabels';
import { refreshApex } from '@salesforce/apex';

export default class oc_an_localBulletinCreationLWC extends LightningElement {
    //Declare & Initiliaze variables
    constants = allConstants;
    label = labels; 
    hasRendered= false;
    @track disable;
    @track areDetailsVisible = false;
    @track noBody;
    @track localBulletinList=[];
    @track isLoading=false;
    @api recordId;
    @track textBoxValue;
    @track commentValues=[];
    @track showCheckbox=[];
    @track selectedBulletin=[];
    @track selectCheckboxHandle=[];
    @track comments=[];
    @track StatusPicklistValues=[];
    @track showBoolean= false;
    @track SubStatusDependentValues=[];
    @track displayMessage;
    @track noModalBody;
    @track statusList=[];
    @track substatusList=[];
    @track refreshTable=[];
    showMessage= true;
    statusValue;
    toEnable=[];
    toDisable=[];
    value = '';

    //Get data from apex controller
    //As per status and substatus values received from controller, collect checkbox information in showCheckbox[]       
    @wire(getExternalDistributionList,{parentbulletinId : '$recordId'})
    getAccounts(result){
        this.refreshTable = result;
        if(result.data){          
            this.noModalBody= true; 
            this.isLoading = true;
            this.areDetailsVisible= true;
            this.localBulletinList= result.data; 
            console.log('result.data'+result.data);
            console.log('result.data'+JSON.stringify(result.data));                       
            this.isLoading = false; 
            this.noBody= false;
            if(this.localBulletinList != "undefined" && this.localBulletinList.length>0){
                 this.localBulletinList.forEach(ele => {
              
                  });   
                 
        }else{
            this.noModalBody= false;
            this.noBody= true;
            if(this.showMessage==true){
            this.showToastMessages(
                this.constants.toast_Variant_Warning,
                this.constants.toast_Variant_Warning,
                this.label.oc_an_noRecordsFound,
                3000
                );
        }
    }
        }
             
    }
      // Get Status picklists values from controller and set the same in child component status picklist
      @wire(getObjectInfo, { objectApiName: BAP_OBJECT })
      objectInfo;

      @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: STATUS_FIELD})
       StatusValues({ data, error }) {
          if (data) this.StatusPicklistValues = data.values;}

    //Set checkbox enable/disable after receivng response from server, once table is rendered
    //keep checkbox enable only for status as hold & substatus as Message Applicable, but I want to modify                
    /*renderedCallback() {
      if(this.hasRendered === false){
        let selectedRows = this.template.querySelectorAll('lightning-input'); 
        for(let i = 0; i < selectedRows.length; i++){  
           if(selectedRows[i].type==='checkbox'){
                this.disable = this.showCheckbox.find(v=>v.RecordId== selectedRows[i].dataset.id).disableTrue;
                
                selectedRows[i].disabled = this.disable;            
                this.hasRendered= true; //set true        
        }
    }
 }
 }*/
   
  //Collect comments data when user enter any comment in comment column
    handleTextBoxChange(event){      
        this.textBoxValue =  event.target.value;
        var index = this.commentValues.findIndex((el) => el.RecordId === event.currentTarget.dataset.id)
        if(index>=0){
        this.commentValues[index] = {
            RecordId: event.currentTarget.dataset.id,
            textBoxValue: event.detail.value
            }
        }else{
            this.commentValues.push({RecordId: event.currentTarget.dataset.id, textBoxValue: event.detail.value });
 
        }          
    }

    get options() {
        return [
            { label: 'Send', value: 'Send' },
            { label: 'Action Required', value: 'Action Required' },
            { label: 'Hold', value: 'Hold' },
        ];
    }

    //Collect checkboxes true/false information and set flag isCreateLBforAccount accordingly
    // This is to inform backend what rows users has selected to create local bulletin
    handleCheckBoxChange(event){    
        this.selectCheckboxHandle=[];
        let selectedRows = this.template.querySelectorAll('lightning-input'); 
  
        for(let i = 0; i < selectedRows.length; i++){
            if(selectedRows[i].type==='checkbox'){
            if(selectedRows[i].checked== true){
                this.selectCheckboxHandle.push({
                    isCreateLBforAccount: 'True',
                    RecordId: selectedRows[i].dataset.id                                     
                })
            }else{
                this.selectCheckboxHandle.push({
                    isCreateLBforAccount: 'False',
                    RecordId: selectedRows[i].dataset.id                                     
                })
            }
        }
    }

    }

    handleChange(event){     

        this.statusValue= event.target.value;
        var index = this.statusList.findIndex((el) => el.RecordId === event.currentTarget.dataset.id)
        if(index>=0){
        this.statusList[index] = {
            RecordId: event.currentTarget.dataset.id,
            Status: event.target.value
            }
        }else{
     this.statusList.push({RecordId: event.currentTarget.dataset.id, Status: event.target.value });
        }
}
   
   
    // Colleact all information from UI in 'selectedBulletin'
    // Set all data including Status, substatus, checkbox, comment, account details in 'selectedBulletin'    
    handleClick(event) {
        console.log('line 180 Hit');
        this.isLoading = true;
        console.log('line 182 Hit');
        console.log('statusList'+JSON.stringify(this.statusList));
        for(let i = 0; i < this.statusList.length; i++) {
        var index = this.selectedBulletin.findIndex((el) => el.RecordId === this.statusList[i].RecordId)
            if(index>=0){
                this.selectedBulletin[index] = {
                RecordId: this.statusList[i].RecordId ,
                Status: this.statusList[i].Status,
                }
            }else{
                this.selectedBulletin.push({RecordId: this.statusList[i].RecordId , Status: this.statusList[i].Status});
 
            }
        }
 
        this.commentValues.forEach(ele =>{
            var index = this.selectedBulletin.findIndex((el) => el.RecordId === ele.RecordId)
                if(index>=0){
                    this.selectedBulletin[index]['textBoxValue'] = ele.textBoxValue;
                    
                }else{
                    this.selectedBulletin.push({
                        RecordId: ele.RecordId,
                        textBoxValue:ele.textBoxValue
  
                    });
                }
        });   
        //To fetch Account ID, Account Name form localBulletinList(returned from controller)
        // Add data in selectedBulletin accordingly  
            if(this.localBulletinList!= null && typeof this.localBulletinList != "undefined"){
                this.localBulletinList.forEach(ele => {
                    var index = this.selectedBulletin.findIndex((el) => el.RecordId === ele.Id)
                    if(index>=0){
                        this.selectedBulletin[index]['accountName'] = ele.OC_AN_Account__r.Name;
                        this.selectedBulletin[index]['accountID'] = ele.OC_AN_Account__c;
                        if(this.selectedBulletin.find(v=>v.RecordId=== ele.Id).Status === undefined)
                            this.selectedBulletin[index]['Status'] = ele.OC_AN_Status__c;
                       if(this.selectedBulletin.find(v=>v.RecordId=== ele.Id).textBoxValue === undefined)
                            this.selectedBulletin[index]['textBoxValue'] = ele.OC_AN_Comments__c;                          
                    }else{
                        this.selectedBulletin.push({'Status': ele.OC_AN_Status__c ,'textBoxValue': ele.OC_AN_Comments__c != null? ele.OC_AN_Comments__c :'','accountName': ele.OC_AN_Account__r.Name ,'accountID': ele.OC_AN_Account__c, RecordId: ele.Id});
                    }
                });               
    }

     //To add checkbox flag in selectedBulletin
     this.selectCheckboxHandle.forEach(ele =>{
        var index = this.selectedBulletin.findIndex((el) => el.RecordId === ele.RecordId)
            if(index>=0){
                this.selectedBulletin[index]['isCreateLBforAccount'] = ele.isCreateLBforAccount;
            }
     });
       //Add createLBForAccountFlag 
        for(let i = 0; i < this.selectCheckboxHandle.length; i++) {              
            this.selectedBulletin.find(v=>v.RecordId== this.selectCheckboxHandle[i].RecordId).createLBForAccountFlag = this.selectCheckboxHandle[i].isCreateLBforAccount;
        }   

        console.log('JSON.stringify(this.selectedBulletin)'+JSON.stringify(this.selectedBulletin));
       //Pass data to controller
       //Call apex method
        createLocalBulletin( {bulletinRecordsFromJS : JSON.stringify(this.selectedBulletin),
            bulletinId:this.recordId})
            .then((result) => {
                this.showToastMessage(
                this.constants.toast_Variant_Success,
                this.constants.toast_Variant_Success,
                this.label.successMessage,
                2000
                );   
                //To refresh component after submit
                this.showMessage= false;
                this.isLoading = false;
                return refreshApex(this.refreshTable);
            })
            .catch((error) => {
               this.showToastMessage(
                this.constants.toast_Variant_Error,
                this.constants.toast_Variant_Error,
                this.label.errorMessage,
                2000
                );
                this.isLoading = false;
                this.dispatchEvent(
                new CustomEvent("handleafterfailed", {
                    bubbles: true,
                    composed: true
                })
                );
            });
        //Reset array after passing data
        this.selectedBulletin=[];  
    }
  
    //Handle success message
    showToastMessage(toastTitle, toastVariant, toastMessage, pageReloadDelay){
        const event = new ShowToastEvent({
          title: toastTitle,
          variant: toastVariant,
          message: toastMessage
        });      
        this.dispatchEvent(event);
        if (pageReloadDelay) {
          this.dispatchEvent(
            new CustomEvent("handleaftersave", { bubbles: true, composed: true })
          );
        }      
    }
    //When no records found, display info message
    showToastMessages(toastTitle, toastVariant, toastMessage, pageReloadDelay){
        const event = new ShowToastEvent({
          title: toastTitle,
          variant: toastVariant,
          message: toastMessage
        });      
        this.dispatchEvent(event);
        if (pageReloadDelay) {
          this.dispatchEvent(
            new CustomEvent("handleaftercancel", { bubbles: true, composed: true })
          );
        }
    }
    //Handle cancel event
    handleCancel(event){
        this.dispatchEvent(
            new CustomEvent("handleaftercancel", { bubbles: true, composed: true })
          );    
        }
   
}