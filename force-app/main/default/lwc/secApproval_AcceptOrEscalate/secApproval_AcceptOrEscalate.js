import { LightningElement,track,api } from 'lwc';
import UpdateSecondaryApproval from '@salesforce/apex/OpportunityLwcController.UpdateSecondaryApproval';
export default class ModalPopupLWC extends LightningElement {
    @api recordId;
    @api ErrorMessage;
    @api comment;
    @api isAccepted;
    @track isModalOpen = false;
    /*openModal() {
        this.isModalOpen = true;
    }*/
    closeModal() {
        this.isModalOpen = false;
    }
    handelButtonEvent(event){
        //alert("name : "+event.target.name);
           if (event.target.name === 'Accept') {
               this.isAccepted = true;
               this.submitDetails();
           }
           if (event.target.name === 'Escalate') {
               this.isAccepted = false;
               this.isModalOpen = true;
           }
           //alert(this.isAccepted);
    }
    handleFieldChange(event){
            if (event.target.name === 'Escalation Comments') {
                this.comment = event.target.value;
                
            }
     }
    submitDetails() {
        UpdateSecondaryApproval({
            SecApprovalId : this.recordId,
            EscalationComments : this.comment,
            isAccepted : this.isAccepted
        })
        .then(() => {
            window.location.reload();
        })
        .catch((error) =>{
            this.ErrorMessage = error;
            alert("Error: ",JSON.stringify(this.ErrorMessage));
        })
        this.isModalOpen = false;
    }
}