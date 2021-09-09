import { api, LightningElement, track, wire } from 'lwc';
import getData from '@salesforce/apex/OC_AN_DistributionSummaryController.getDistributionSummaryData';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const columns = [
    {label: 'Name', fieldName: 'name', type: 'text'},
    {label: 'Email', fieldName: 'email', type: 'email'},
];

export default class OC_AN_DistributionSummary extends NavigationMixin(LightningElement) {
    @track isModalOpen = true;
    @api recordId;
    columns = columns;
    tableData;
    error;
    isExternal = true;
    distributionSummaryHeader = this.isExternal ? "External Distribution Summary" : "Internal Distribution Summary";
    @wire(getData, { bulletinId : '$recordId', isExternal : '$isExternal' })
    data({ data,error }) {
        console.log(JSON.stringify(data));
        
        console.log(JSON.stringify(error))
        if (data && data.length > 0) {

            this.isModalOpen = true;
            console.log('data!')
            this.tableData = data;
            this.error = undefined;
        } else if (error) {
            this.isModalOpen = true;
            console.log('error!')
            this.error = error;
            this.record = undefined;
            this.showToastMessage(
                this.constants.toast_Variant_Error,
                this.constants.toast_Variant_Error,
                error,
                2000
                );
        }else if (data && data.length < 1 && this.recordId){
            console.log('close');
            this.closeModal();
        }
    };
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'OC_AN_Bulletin__c',
                actionName: 'view',
                recordId: this.recordId
            },
        },true);
    }
    //Handle success message
    showToastMessage(toastTitle, toastVariant, toastMessage,pageReloadDelay){
        const event = new ShowToastEvent({
          title: toastTitle,
          variant: toastVariant,
          message: toastMessage
        });      
        this.dispatchEvent(event);
        if (pageReloadDelay) {
            this.closeModal();
          }
    }
}