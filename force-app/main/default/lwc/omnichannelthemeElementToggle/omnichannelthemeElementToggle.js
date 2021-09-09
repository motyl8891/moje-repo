import { LightningElement, api } from 'lwc';

export default class OmnichannelthemeElementToggle extends LightningElement {
    @api keyid;
    @api type;
    @api checked = false;
    @api disabled = false;

    get stateCSS(){
        if(this.disabled){
            return 'toggle disabled';
        }
        else if (this.checked) {
            return 'toggle checked';
        }
        else { //will be treated as unchecked
            return 'toggle';
        }
    }

    onchange(event) {
        if(this.disabled){
            return;
        }

        const selectedEvent = new CustomEvent("change", {
            detail: {keyid: this.keyid, type: this.type, checked: event.currentTarget.dataset.state === 'true'? false : true}
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}