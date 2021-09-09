import { LightningElement, wire, track, api } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import BULLETIN_OBJECT from '@salesforce/schema/OC_AN_Bulletin_Template__c';
import PRIORITY_FIELD from '@salesforce/schema/OC_AN_Bulletin_Template__c.OC_AN_Type__c';

export default class Oc_an_user_preferences_bulletinsContainer extends LightningElement {
    bulletinRecordTypeId;
    @api savedBulletinSettings;
    @track local_bulletinSettings = [];

    @wire(getObjectInfo, { objectApiName: BULLETIN_OBJECT }) bulletinMetadata;
 
    @wire(getPicklistValues, { recordTypeId: '$bulletinMetadata.data.defaultRecordTypeId', fieldApiName: PRIORITY_FIELD }) function ({ data, error }){
        if (data) {
            data.values.forEach(element => {
                this.local_bulletinSettings.push({
                                                    email: this.savedBulletinSettings.hasOwnProperty(element.value)? this.savedBulletinSettings[element.value].email: false,
                                                    notification: this.savedBulletinSettings.hasOwnProperty(element.value)? this.savedBulletinSettings[element.value].notification: false,
                                                    label: element.label,
                                                    value: element.value
                                                });
            });
        }
        else if(error){
            console.error('getPicklistvalues: : ' + JSON.stringify(error));
        }
    }

    @api
    getBulletinSettings(){
        var bulletinSettings = {};
        this.local_bulletinSettings.forEach(element => {
            bulletinSettings[element.value] = element;
        });
        return bulletinSettings;
    }

    onchange(event){
        this.local_bulletinSettings.forEach(element =>{ 
            if(element.value == event.detail.keyid){
                element[event.detail.type] = event.detail.checked;
            }
        });
    }
}