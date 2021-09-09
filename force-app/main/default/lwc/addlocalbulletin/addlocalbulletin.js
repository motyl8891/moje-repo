import { LightningElement , track, api, wire} from 'lwc';

import getData from '@salesforce/apex/localBulletinTable.getData';  

import { getPicklistValues } from 'lightning/uiObjectInfoApi';


import STATUS_ValUES from '@salesforce/schema/OC_AN_Bulletin_Account_Product__c.OC_AN_Status__c';
import SUBSTATUS_ValUES from '@salesforce/schema/OC_AN_Bulletin_Account_Product__c.OC_AN_Sub_Status__c';

export default class Addlocalbulletin extends LightningElement {

    @api records;
    @track error;
    @api status=[];
    @api sub_status=[];
    @track selectedStatus;

@api substatusdep;

    constructor() {
        super();
        getData()
            .then(result => {
                this.records = result;
            })
            .catch(error => {
                this.error = error;
            });
    }


        @wire(getPicklistValues, {recordTypeId:'0121l000000DgjmAAC', fieldApiName: STATUS_ValUES })
        statuspicklist2({ data, error }) {
            if (data) {
                this.status = data.values;
                console.log(this.status);
            }
            
        }

        @wire(getPicklistValues, {recordTypeId:'0121l000000DgjmAAC', fieldApiName: SUBSTATUS_ValUES })
        SUBSTATUS_ValUES({ data, error }) {
            if (data) {
                this.substatusdep = data;
                console.log(data.values);
            }
            
        }
        handleCheckBoxClick(event){
            let recordId= event.target.dataset.targetId;
            this.records.filter(v=>v.Id==recordId)[0].checked=event.target.checked;
            console.log(this.records);
         }

        /*
        handleCheckBoxClick({target:{dataset:{id}}}){
            console.log(id);
            
            let checkboxes = this.template.querySelectorAll(id);
            console.log(checkboxes);
         }
*/

}