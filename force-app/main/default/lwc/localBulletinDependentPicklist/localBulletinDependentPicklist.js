import { LightningElement,track, api, wire } from 'lwc';


export default class Oc_an_localBulletinCreationLWC extends LightningElement {
@api acc;
@api status;
@api substatus;

connectedCallback(){
    console.log('child component');
    console.log('acc>>>' +this.acc);
    console.log('status>>>' +this.status);
    console.log('substatus>>' +this.substatus);
    
}
    
     handleChangeForStatus(event) {
       
     }
     handleSubStatusChange(event) {}
    



}