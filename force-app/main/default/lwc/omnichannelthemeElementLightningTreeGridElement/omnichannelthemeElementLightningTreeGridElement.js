import { LightningElement, track, api} from 'lwc';

export default class OmnichannelthemeElementLightningTreeGridElement extends LightningElement {
    @api rowData;
    @api gridColumn;
    @track isLevelCollapsed;
    @api level;
    
    @api
    get rowElement(){
       // console.log('inside rowElement');
        var rowElement = [];
        this.gridColumn.forEach(element => {
            rowElement.push( {name: element.fieldName, value: this.rowData[element.fieldName]} );
        });
        return rowElement;
    }

    connectedCallback() {
        //console.log('inside OmnichannelthemeElementLightningTreeGrid elemet');
        //To make row groups collapse or extended based on initial selections
        this.isLevelCollapsed = this.rowData.selectedState != 'unchecked'? false : true;
        //this.isLevelCollapsed = false;
    }

    onchange(event){
        var detail = event.detail;
        detail.Id = this.rowData.Id;
        const selectedEvent = new CustomEvent("rowselect", {
            detail: detail,
            bubbles: true,
            composed: true
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    collapseOrExpand(event){
        this.isLevelCollapsed = !this.isLevelCollapsed;
    }
    
    get childsVisibilityStyle(){
        return this.isLevelCollapsed? 'collapsed': 'expanded';
    }

    get arrowStyle(){
        return this.isLevelCollapsed? 'icon icon-chevron-right': 'icon icon-chevron-down';
    }
    
    get elementLevelCSS(){
        return 'level' + this.elementLevel;
    }

    get elementLevel(){
        return parseInt(this.level) + 1;
    }
    
}