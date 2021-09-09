import { LightningElement, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import USER_PREF_OBJECT from '@salesforce/schema/OC_AN_User_Preferences__c';
import getProducts from '@salesforce/apex/OC_AN_UserPreferencesController.getProducts';

export default class Oc_an_user_preferences_prodcutsContainer extends LightningElement {
    
    productRecordTypeId;

    loadedProdcutsInfo = {isCompleted: false, offsetCount: 0};

    @wire(getObjectInfo, { objectApiName: USER_PREF_OBJECT }) function ({ data, error }){
        if(data){
            data['recordTypeInfos'].forEach(element => {
                if(element.name === 'Product Setting')
                this.productRecordTypeId = element.recordTypeId;
            });              
        }
        else if(error){
            console.error('getObjectInfo: USER_PREF_OBJECT: ' + JSON.stringify(error));
        }
    }

    connectedCallback(){
        getProducts({wrapper: this.loadedProdcutsInfo}).then(result => {
            if(result != null){
                console.log(result);
            }
        }).catch(error => {
            console.log('Products: error' + error);
        });
    }
}