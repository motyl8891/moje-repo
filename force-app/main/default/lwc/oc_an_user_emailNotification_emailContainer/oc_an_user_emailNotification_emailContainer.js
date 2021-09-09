import { LightningElement, wire, track, api } from 'lwc';

export default class Oc_an_user_emailNotification_emailContainer extends LightningElement {
    @track checked = false ; 
    onchange(event){
        this.checked = event.target.checked;
    }
}