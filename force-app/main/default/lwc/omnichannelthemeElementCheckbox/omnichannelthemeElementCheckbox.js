import {
    LightningElement,
    api,
    track
} from 'lwc';

export default class OmnichannelthemeElementCheckbox extends LightningElement {
    @api
    selectedState = 'unchecked';

    @api change;

    onchange(event) {
        var selectedState = event.currentTarget.dataset.state;

        if (selectedState == 'checked') {
            //this.selectedState = 'unchecked';
            selectedState = 'unchecked';
        }
        else if (selectedState == 'indeterminate') {
            //this.selectedState = 'unchecked';
            selectedState = 'unchecked';
        }
        else { //will be treated as unchecked
            //this.selectedState = 'checked';
            selectedState = 'checked';
        }

        const selectedEvent = new CustomEvent("change", {
            detail: { selectedState: /*this.selectedState*/ selectedState}
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    get stateCSS(){
        if (this.selectedState == 'checked') {
            return 'checkbox checked';
        }
        else if (this.selectedState == 'indeterminate') {
            return 'checkbox indeterminate';
        }
        else { //will be treated as unchecked
            return 'checkbox';
        }
    }
}