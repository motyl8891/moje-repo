import { LightningElement , track, api, wire} from 'lwc';

export default class Addlocalbulletinhelper extends LightningElement {

    
    @api status=[];
    @api sub_status=[];
    @track selectedStatus;
    @api substatusdep=[];

    handleChange(event) {
        console.log(event.detail.value);
        let holdKey = this.substatusdep.controllerValues[event.detail.value];
        this.sub_status = this.substatusdep.values.filter(v=>v.validFor.includes(holdKey));
        console.log(this.sub_status);

    }

}