import { LightningElement, track, api, wire } from 'lwc';
import getProducts from '@salesforce/apex/OC_AN_UserPreferencesController.getProducts';

export default class Oc_an_user_preferences_productsContainer extends LightningElement {
    
    productRecordTypeId;
    loadedProdcutsInfo = {isCompleted: false, offsetCount: 0};
    gridColumns = [{ type: 'text', fieldName: 'Name', label: 'Name' }];

    @track gridData;
    @track hasLoaded = false;
    @api savedProductSettings;

    connectedCallback(){
        console.log('rest Miro');
        console.log('savedProductSettings'+JSON.stringify(this.savedProductSettings));
        debugger;
        getProducts({wrapper: this.loadedProdcutsInfo}).then(result => {
            if(result != null){
                console.log(result);
                this.loadSelectedStates(result.products, this.savedProductSettings);
                this.gridData = result.products;
                this.loadedProdcutsInfo.isCompleted = result.isCompleted;
                this.loadedProdcutsInfo.offsetCount = result.products.length;
                this.hasLoaded = true;
            }
        }).catch(error => {
            console.log('Products: error' + error);
        });
    }

    handleScroll(event) {
        if (/*this.hasLoaded && */ !this.loadedProdcutsInfo.isCompleted) {
            //this.isLoaded = false;
            getProducts({wrapper: this.loadedProdcutsInfo}).then(result => {
                if (result != null) {
                    this.loadSelectedStates(result.products, this.savedProductSettings); 
                    this.gridData.push.apply(this.gridData, result.products);
                    this.loadedProdcutsInfo.isCompleted = result.isCompleted;
                    this.loadedProdcutsInfo.offsetCount += result.products.length;

                    this.template.querySelector('c-omnichanneltheme-element-lightning-tree-grid').updateChanges();
                }
            }).catch(error => {
                console.log('Products: error' + error);
            });
        }
    }

    loadSelectedStates(elements, savedProductSettings){
        elements.forEach(element => {
            if(savedProductSettings && savedProductSettings.hasOwnProperty(element.Id) && savedProductSettings[element.Id].email){
                element.selectedState = 'checked';
            }
            else{
                element.selectedState = 'unchecked';
            }
            if(element.children){
                this.loadSelectedStates(element.children, savedProductSettings)
            }
        });
    }

    @api getProductSettings(){

        
        //return this.template.querySelector('c-omnichanneltheme-element-lightning-tree-grid').getSelectedRows();
        return this.template.querySelector('c-omnichanneltheme-element-lightning-tree-grid').getSelectedRows();
        


    }
}