import { LightningElement, track, wire, api } from 'lwc';
import findOpps from '@salesforce/apex/OpportunityLwcController.getOpps';

export default class GetOpportunityDetails extends LightningElement {
    @track searchKey = '';
    @api recordId;
    @track mapData = [];

    @wire(findOpps, { searchKey: '$searchKey' })
    wiredResult(result) {
        if (result.data) {
            var conts = result.data;
            for (var key in conts) {
                this.mapData.push({ value: conts[key], key: key });
            }
        }
    }
    connectedCallback() {
        this.searchKey = this.recordId;
    }
}