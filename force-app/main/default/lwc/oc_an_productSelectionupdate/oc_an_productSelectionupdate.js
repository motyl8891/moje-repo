import { LightningElement, track, api, wire } from 'lwc';
import getProducts from "@salesforce/apex/OC_AN_ProductSelectionController.getProducts";
import saveProductSelection from "@salesforce/apex/OC_AN_ProductSelectionController.saveProductSelection";
import getCurrentBulletinProducts from "@salesforce/apex/OC_AN_ProductSelectionController.getCurrentBulletinProducts";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Oc_an_productSelectionupdate extends LightningElement {


    @track hasLoaded = false;
    @track gridData;
    
    loadedProdcutsInfo = {isCompleted: false, offsetCount: 0};
    gridColumns = [{ type: 'text', fieldName: 'Name', label: 'Name' }];
    @api savedProductSettings;
    @api bulletinRecordId;
    @api isModalOpen = false;
    

    connectedCallback(){
        console.log('inside Oc_an_productSelectionupdate');
        getCurrentBulletinProducts({bulletinId: this.bulletinRecordId}).then(result => {
            if(result != null){
                console.log('getCurrentBulletinProducts: ' + JSON.stringify(result.product));
                this.savedProductSettings = result.product;
            }
        }).catch(error => {
            console.log('Products: error' + JSON.stringify(error));
        });

        getProducts({wrapper: this.loadedProdcutsInfo}).then(result => {
                if(result != null){
                    console.log('result.isCompleted before>>' +JSON.stringify(result.isCompleted));
                    console.log('result.products length before>>' +JSON.stringify(result.products.length));
                    
                    this.loadSelectedStates(result.products, this.savedProductSettings);
                    this.gridData = result.products;
                    this.loadedProdcutsInfo.isCompleted = result.isCompleted;
                    this.loadedProdcutsInfo.offsetCount = result.products.length;
                    this.hasLoaded = true;

                   // console.log('result.products>>' +JSON.stringify(result.products));
                   
                    console.log('this.savedProductSettings>>>' +JSON.stringify(this.savedProductSettings));
                    console.log('this.loadedProdcutsInfo>>' +JSON.stringify(this.loadedProdcutsInfo));
                   
                }
            }).catch(error => {
                console.log('Products: error' + JSON.stringify(error));
            });
    }


    handleScroll(event) {
        if (!this.loadedProdcutsInfo.isCompleted) {
            getProducts({wrapper: this.loadedProdcutsInfo}).then(result => {
                if (result != null) {
                    this.loadSelectedStates(result.products, this.savedProductSettings);
                    this.gridData.push.apply(this.gridData, result.products);
                    this.loadedProdcutsInfo.isCompleted = result.isCompleted;
                    this.loadedProdcutsInfo.offsetCount += result.products.length;
                    console.log('this.loadedProdcutsInfo after scroll>>' +JSON.stringify(this.loadedProdcutsInfo));
                   
                    this.template.querySelector('c-omnichanneltheme-element-lightning-tree-grid').updateChanges();
                    
                }
            }).catch(error => {
                console.log('Products: error' + error);
            });
        }
    }

    loadSelectedStates(elements, savedProductSettings){
        
        elements.forEach(element => {
            if(element.children){
                this.loadSelectedStates(element.children, savedProductSettings)
            }
           if(savedProductSettings && savedProductSettings.includes(element.Id)){
                //if(element['OC_MD_Parent__c'])
                    element['selectedState'] = 'checked';
            }
            else{
                element['selectedState'] = 'unchecked';
            }
           
        });
        //console.log('elements after::::: ' + JSON.stringify(elements));
    } 

    @api getProductSettings(){
        return this.template.querySelector('c-omnichanneltheme-element-lightning-tree-grid').getSelectedRows();
    }

    closeModal(){
        this.isModalOpen = false;
  
        this.dispatchEvent(
            new CustomEvent("handleafterclose", {
              bubbles: true,
              composed: true
            })
          );
        
      //  eval('$A.get("e.force:refreshView").fire()');
    }

    handleAddProducts() {
        this.selectedproducts = JSON.stringify(this.template.querySelector('c-omnichanneltheme-element-lightning-tree-grid').getSelectedRows());
        saveProductSelection({jsoninput:this.selectedproducts,bulletinRecId:this.bulletinRecordId}) .then(result => {
            if (result != null) {
                 this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Selection saved successfully.',
                    variant: 'success'
                }));
                this.isModalOpen = false;
                
                this.dispatchEvent(
                    new CustomEvent("handleaftersave", {
                      bubbles: true,
                      composed: true
                    })
                  );

                //eval('$A.get("e.force:refreshView").fire()');
            }
        }).catch(error => {
            console.log('product error::' + JSON.stringify(error));
        });
    }
}