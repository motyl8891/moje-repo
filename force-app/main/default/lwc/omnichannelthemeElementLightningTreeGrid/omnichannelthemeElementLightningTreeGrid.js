import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import css from '@salesforce/resourceUrl/OmniChannelThemeResource';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class OmnichannelthemeElementLightningTreeGrid extends LightningElement {
    loadTable = true;
    
    //Attribute parentChildMapTableData map will be used to preserve the selections changes
    parentChildMapTableData = new Map();;

    old_parentChildMapTableData = new Map();;

    //Attribute selectedStateTreeGrid map will be used to preserve the selectedState of the root row
    @track selectedStateTreeGrid;

    //Attribute gridColumn will be used by parent to pass the columns of the grid data
    @api gridColumn;

    //Attribute gridData will be used by parent to pass the grid data. This grid data will be used to further update the attribute tableData
    @api gridData;

    //Grid data from parent will be cloned to this attribute and will be utilized to make the component UI
    @track tableData;

    //Id to maintain the root row selectedState and tree structure for whole grid data
    rootId = '000000000000000000';

    iconsURL = css+'/icons/ericsson-icons.svg';

    @track searchText = '';
    @track filterPaused = true;
    @api placeholderText;
    @api searchInputRequired = false;
    @api searchFieldName = 'Name';
    @track isFilter = false;

    //Actions on initalization of the component
    connectedCallback() {
 
        //Load style sheets
        Promise.all([
            loadStyle(this, css + '/css/icons.css'),
            loadStyle(this, css + '/css/fonts.css')
        ]).then(() => {});
        
        //Load initial data to component's tracked attribute tableData
        this.initData();

        //Prepare the parentChildMapTableData map to preserve selections changes
        //this.parentChildMapTableData = new Map();
        this.parentChildMapTableData.set(this.rootId, { Id: this.rootId, parentId: null, selectedState: 'unchecked', childrenIds: this.prepareParentChildMapTableData(this.tableData, this.rootId, this.parentChildMapTableData)});
        
        this.setParentsSelectedState(this.old_parentChildMapTableData);
    }

    //To load gird data to component's tracked attribute tableData
    initData(){
       
        //Grid data cloned to this attribute which will be utilized to make the component UI
        
        this.tableData = JSON.parse(JSON.stringify(this.gridData));
        //console.log('this.tableData>>>' +this.tableData);
        //Prepare the old_parentChildMapTableData map for the loaded selections
        this.old_parentChildMapTableData.set(this.rootId, { Id: this.rootId, parentId: null, selectedState: this.selectedStateTreeGrid, childrenIds: this.prepareParentChildMapTableData(this.tableData, this.rootId, this.old_parentChildMapTableData)});
       
        //Reset if any search value is there on tableData change
        console.log('this.searchText init>>>' +this.searchText);
        this.filterValues(this.searchText);
    }

    //To prepare the parentChildMapTableData map to preserve selections changes
    //This will call recursively itself for all levels of tableData
    prepareParentChildMapTableData(tableRow, parentId, mapToSet){
        var children = new Set();

        tableRow.forEach(child => {
            children.add(child.Id);
            if(child.children){
                mapToSet.set(child.Id, { Id: child.Id, parentId: parentId, selectedState: child.selectedState, it: child, childrenIds: this.prepareParentChildMapTableData(child.children, child.Id, mapToSet) });
            }
            else{
                mapToSet.set(child.Id, { Id: child.Id, parentId: parentId, selectedState: child.selectedState, it: child, childrenIds: [] });
            }
        });
        
        return children;
    }

    //Update selectedStates in the whole tree based on the root row selection change
    handleCompleteTreeSelection(event){
        var detail = event.detail;
        detail.Id = this.rootId;
        this.changeTreeSelctions(this.tableData, this.calculateTreeSelections(detail));
    }

    //Fires when a row selection change is made, event will come from all level childrens
    //Based on the selectedState of the row selection change, update selectedState of child nodes as well as parent nodes
    //selectedState calculations to current, parent(till 0th level) & child(till nth level) nodes of tree will be supported by sub methods - calculateTreeSelections, calculateChildSelections, calculateParentSelections
    //After calculations of selectedState current, parent(till 0th level) & child(till nth level) nodes of tree, updates will be done to attribute tableData by method changeTreeSelctions
    handleRowSelection(event){
        this.changeTreeSelctions(this.tableData, this.calculateTreeSelections(event.detail));
    }

    //A scroll event will be notified to parent if scroll has reached to bottom of the component's UI area
    handleScroll(event){
        //if( Math.floor(event.currentTarget.scrollTop) === (event.currentTarget.scrollHeight - event.currentTarget.offsetHeight)){
        if(!this.isFilter && Math.ceil(event.currentTarget.scrollTop) + event.currentTarget.offsetHeight >= event.currentTarget.scrollHeight ){
            const scrollEvent = new CustomEvent("scroll", {});
            // Dispatches the event.
            this.dispatchEvent(scrollEvent);
        }
    }

    handleFilter(event){
        console.log('event.currentTarget>>>' +event.currentTarget.value);
        this.isFilter = (event.currentTarget.value != undefined && event.currentTarget.value.length >0) ? true : false;
        this.filterValues(event.currentTarget.value);
    }

    //After a row selection change, to calculate selectedState changes for current, parent(till 0th level) & child(till nth level) nodes of tree. This will be supported by sub methods - calculateChildSelections, calculateParentSelections
    calculateTreeSelections(affectedItem) {
        //Map to collect all affected nodes including current, parent(till 0th level) & child(till nth level) nodes of tree for current row selection change
        var currentSelectionEffectMap = new Map();
        currentSelectionEffectMap.set(affectedItem.Id, affectedItem);

        if (this.parentChildMapTableData.has(affectedItem.Id)) {

            //Change selectedState for the current element received from event. Recorded & supported by map parentChildMapTableData, currentSelectionEffectMap
            this.parentChildMapTableData.get(affectedItem.Id).selectedState = affectedItem.selectedState;
            
            //Calculate selectedState for affected child nodes till nth level. Recorded & supported by map parentChildMapTableData, currentSelectionEffectMap
            if(this.parentChildMapTableData.get(affectedItem.Id).childrenIds.size){
                this.calculateChildSelections(this.parentChildMapTableData.get(affectedItem.Id).childrenIds, currentSelectionEffectMap, affectedItem.selectedState);
            }

            //Calculate selectedState for affected parent nodes till 0th level. Recorded & supported by map parentChildMapTableData, currentSelectionEffectMap
            if (this.parentChildMapTableData.get(affectedItem.Id).parentId) {
                this.calculateParentSelections(this.parentChildMapTableData.get(this.parentChildMapTableData.get(affectedItem.Id).parentId), currentSelectionEffectMap);
            }
        }
        
        return currentSelectionEffectMap;
    }

    //To calculate selectedState changes for child(till nth level) nodes of tree.
    //This will be called recursively to calculate selectedState change till nth child nodes
    //All selectedState changes will be recorrded and supported by map parentChildMapTableData
    calculateChildSelections(childElements, currentSelectionEffectMap, selectedState){
        childElements.forEach(childElementId => {
            var childElement = this.parentChildMapTableData.get(childElementId);
            childElement.selectedState = selectedState;
            currentSelectionEffectMap.set(childElement.Id, childElement);
            if(childElement.childrenIds.size){
                this.calculateChildSelections(childElement.childrenIds, currentSelectionEffectMap, childElement.selectedState);
            }
        });
    }

    //To calculate selectedState changes for parent(till 0th level) nodes of tree.
    //This will be called recursively to calculate selectedState change till 0th parent nodes
    //All selectedState changes will be recorrded and supported by map parentChildMapTableData
    calculateParentSelections(parenElement, currentSelectionEffectMap){
        var checkedCounter = 0;
        var uncheckedCounter = 0;
        var indeterminateCounter = 0;

        parenElement.childrenIds.forEach(childElementId => {
            var childElement = this.parentChildMapTableData.get(childElementId);
            if (childElement.selectedState == 'checked') {
                checkedCounter++;
            }
            else if (childElement.selectedState == 'indeterminate') {
                indeterminateCounter++;
            }
            else { //will be treated as unchecked
                uncheckedCounter++;
            }
        });

        if(parenElement.childrenIds.size == checkedCounter){
            parenElement.selectedState = 'checked';
        }
        else if(parenElement.childrenIds.size == uncheckedCounter){
            parenElement.selectedState = 'unchecked';
        }
        else{ //will be treated as indeterminate
            parenElement.selectedState = 'indeterminate';
        }

        currentSelectionEffectMap.set(parenElement.Id, parenElement);

        if(parenElement.parentId && this.parentChildMapTableData.has(parenElement.parentId)){
            this.calculateParentSelections(this.parentChildMapTableData.get(parenElement.parentId), currentSelectionEffectMap);
        }
    }

    //After calulation of affected noeds in currentSelectionEffectMap, updates will be done to attribute tableData
    //Updates will trigger the UI Changes as it is a tracked attribute
    changeTreeSelctions(tableData, currentSelectionEffectMap){
        
        //console.log('currentSelectionEffectMap>>' +currentSelectionEffectMap);
        
        tableData.forEach(tableRow => {
            if(currentSelectionEffectMap.has(tableRow.Id)){
                tableRow.selectedState = currentSelectionEffectMap.get(tableRow.Id).selectedState;
            }
            if(tableRow.children){
                this.changeTreeSelctions(tableRow.children, currentSelectionEffectMap);
            }
        });

       //console.log('tableData>>' +JSON.stringify(this.tableData));
        //console.log('this.rootId>>' +this.rootId);
        this.selectedStateTreeGrid = currentSelectionEffectMap.get(this.rootId).selectedState;
        console.log('this.selectedStateTreeGrid>>' +JSON.stringify(this.selectedStateTreeGrid));
 
    }

    //Will be available to and fired by parent to reflect the row additions made to grid data
    @api updateChanges(){
        console.log('updateChanges>>>');
        var rootEffectMap = new Map();

        //Load updated data to component's tracked attribute tableData
        this.initData();

        //Update previous selections changes made before the updated tableData
        this.changeTreeSelctions(this.tableData, this.parentChildMapTableData);

        //Prepare the parentChildMapTableData map again for the future selections changes
        this.parentChildMapTableData.set(this.rootId, { Id: this.rootId, parentId: null, selectedState: this.selectedStateTreeGrid, childrenIds: this.prepareParentChildMapTableData(this.tableData, this.rootId, this.parentChildMapTableData)});
        
        this.setParentsSelectedState(this.parentChildMapTableData);

        //Recalculate the root row selectedState based on updated data selections
        this.calculateParentSelections(this.parentChildMapTableData.get(this.rootId), rootEffectMap);

        //Update the root row selectedState based on updated data selections
        this.selectedStateTreeGrid = rootEffectMap.get(this.rootId).selectedState;

    }

    //
    @api getSelectedRows(){
        var selectedRows = {};
        var deselectedRows = {};

        this.parentChildMapTableData.forEach(element => {
            if(element.selectedState == 'checked'){
                selectedRows[element.Id] = element.it;
            }
            else if(this.old_parentChildMapTableData.get(element.Id).selectedState == 'checked'){
                deselectedRows[element.Id] = element.it;
            }
        });
        console.log('@@@@' +selectedRows);
        return {'selected': selectedRows, 'deselected': deselectedRows};
    }

    filterValues(value){
        this.tableData.forEach(element => {
            if(element[this.searchFieldName].toLowerCase().includes(value.trim().toLowerCase())){
                element.filtered = true;
            }
            else{
                element.filtered = false;
            }
        });
        console.log('this.tableData>>>' +JSON.stringify(this.tableData));
    }

    setParentsSelectedState(map){
        var selectedItems = new Map();
        map.forEach(element => {
            if(element.selectedState == 'checked' && element.Id != this.rootId){
                selectedItems.set(element.Id, element);
            }
        });

        selectedItems.forEach(element => {
            this.changeTreeSelctions(this.tableData, this.calculateTreeSelections(element));
        });
    }
}