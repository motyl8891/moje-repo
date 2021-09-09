import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import BULLETIN_OBJECT from '@salesforce/schema/OC_AN_Bulletin_Template__c';
import USER_PREF_OBJECT from '@salesforce/schema/OC_AN_User_Preferences__c';
import PRIORITY_FIELD from '@salesforce/schema/OC_AN_Bulletin_Template__c.OC_AN_Type__c';
import getProducts from '@salesforce/apex/OC_AN_UserPreferencesController.getProducts';
import saveUserPreference from '@salesforce/apex/OC_AN_UserPreferencesController.saveUserPreference';
import getCurrentUserPreference from '@salesforce/apex/OC_AN_UserPreferencesController.getCurrentUserPreference';

export default class Oc_an_userPreferences extends LightningElement {
    @track isLoaded = false;
    @track isFromToggle = false;
    selectedProducts = {};
    @track searchKey;
    @track selectedRows= [];
    @track isModalOpen = false;
    @track bulletinRecordTypeId;
    @track productRecordTypeId;
    priorityTypeValues = [];
    @track isPortalUser = false;
    @track backendData;
    @track isFirstLoad = true;

    oldSelectedRows = [];
    collapsedSelectedRowsMap = new Map();
    isExpandedMap = new Map();
    hasCollapsedParentMap = new Map();
    doNotUpdateFamily = false;
  

    gridColumns = [{ type: 'text', fieldName: 'Name', label: 'Name'},
    // { type: 'text', fieldName: 'Id', label: 'Id'}
  ];
    gridData = [];
    userSettings ={
        "bulletin":{
            "recordType":{"Id": this.bulletinRecordTypeId != undefined? this.bulletinRecordTypeId: ""}
        },
        "product":{
            "recordType":{"Id": this.productRecordTypeId != undefined? this.productRecordTypeId: ""},
            "selectedProducts": {}
        },
        "isCompleted" :false
    };

    modifyKeys(){
    var jsonParsedArray = this.backendData;
       this.backendData = [];
        for (var index in jsonParsedArray) {
            if (jsonParsedArray.hasOwnProperty(index)) {
                var raft = Object.keys(jsonParsedArray[index]).forEach(pKey => {
                    if(pKey == 'releases'){
                        jsonParsedArray[index][`_children`] = jsonParsedArray[index][pKey];
                        delete jsonParsedArray[index][pKey];
                        //console.log(typeof jsonParsedArray[index][`_children`]);
                            if(typeof jsonParsedArray[index][`_children`] === 'object' && jsonParsedArray[index][`_children`].length != undefined){
                                for (var vIndex in jsonParsedArray[index][`_children`]) {
                                    if (jsonParsedArray[index][`_children`].hasOwnProperty(vIndex)) {
                                        var shaft = Object.keys(jsonParsedArray[index][`_children`][vIndex]).forEach(rKey => {
                                            if(rKey == 'versions'){
                                                jsonParsedArray[index][`_children`][vIndex][`_children`] = jsonParsedArray[index][`_children`][vIndex][rKey];
                                                delete jsonParsedArray[index][`_children`][vIndex][rKey];
                                            }
                                        });                                        
                                        if(shaft)
                                        Object.assign(shaft, jsonParsedArray[index][`_children`][vIndex][`_children`]);
                                    }
                                }
                            }
                        }
                    });
                    if(raft)
                        Object.assign(raft, jsonParsedArray[index]);
                    this.backendData.push(jsonParsedArray[index]);
                }

                this.gridData = this.backendData;
                this.isLoaded = true;
                //eval("$A.get('e.force:refreshView').fire()");
        }

        console.log('jsonArray: ' + this.gridData.length);
    }

    filterProduct(event){
        if(event.detail.value != null){
          this.gridData = this.backendData.filter(a => String(a.Name).toUpperCase().includes(String(event.detail.value).toUpperCase()));
        }
            
        else
        this.gridData = this.backendData;
    }

    
    errorCallback(error, stack){
       console.error('ERROR: ' + JSON.stringify(error));
       console.error('ERROR- STACK: ' + JSON.stringify(stack));
    }

    connectedCallback(){
      this.getUserPreference();
      this.userSettings.limitCount = 0;
        getProducts({wrapper: this.userSettings})
        .then(result => {
            if(result != null){
                this.backendData = result.products;
                this.modifyKeys();
                this.isLoaded = true;
            }
        })
        .catch(error => {
            console.log('Products: error' + error);        
        });
    };

  
    getUserPreference(){
        getCurrentUserPreference()
                    .then(result => {
                       if(result != null){
                           this.userSettings = result;
                           this.isPortalUser = result.isCommunityUser;
                           this.selectedRows = [];
                           this.selectedProducts = {};
                           if(this.userSettings.expandedProducts == null)
                           this.userSettings.expandedProducts =[];
                           for(var k in this.userSettings.product) {
                               if(k != 'recordType' && this.userSettings.product[k].email){
                                   this.selectedRows.push(k);
                                   this.selectedProducts[k] = this.userSettings.product[k];
                               }
                           }     
                           
                           if(this.isFirstLoad){
                            this.isFirstLoad = false;
                           }
                           else{
                            //this.collapsedSelectedRowsMap = this.selectedRows;
                            this.isModalOpen = true;
                            this.template.querySelectorAll('.slds-scrollable_y')[0].scroll(handleScroll);
                           }
                       }
                    })
                    .catch(error => {        
                        console.log('getCurrentUserPreference:' + JSON.stringify(error));
                    });
    }
    
    handleScroll(event){
      this.userSettings.offsetCount = this.backendData.length;
       if(this.isLoaded && !this.userSettings.isCompleted){
          this.isLoaded = false;          
          getProducts({wrapper: this.userSettings})
            .then(result => {
                if(result != null){
                    this.userSettings.isCompleted = result.isCompleted;
                    this.backendData.push.apply(this.backendData, result.products)
                    this.modifyKeys();
                }
            })
            .catch(error => {
                console.log('Products: error' + error);    
            });
        }
    }
    
    @wire(getPicklistValues, { recordTypeId: '$bulletinMetadata.data.defaultRecordTypeId'
    , fieldApiName: PRIORITY_FIELD})
    getPriorityValues({ data, error }) {
        if (data && this.userSettings.bulletin) {
            for (var obj in data.values) {
                if(this.userSettings.bulletin[data.values[obj].value]  == undefined ){
                    this.userSettings.bulletin[data.values[obj].value] = {
                        'email': false, 'notification': false
                    };
                    this.priorityTypeValues.push(Object.assign(
                        {
                            emailcheckBoxName: 'email-'+data.values[obj].value
                            , notifyCheckboxName: 'notification-'+data.values[obj].value
                }, data.values[obj]));
                }
                else if(this.userSettings.bulletin[data.values[obj].value]  != 'recordType' ){
                    this.priorityTypeValues.push(Object.assign(
                        {
                            'email': this.userSettings.bulletin[data.values[obj].value].email
                            , 'notification':  this.userSettings.bulletin[data.values[obj].value].notification
                            , emailcheckBoxName: 'email-'+data.values[obj].value
                            , notifyCheckboxName: 'notification-'+data.values[obj].value
                }, data.values[obj]));
                }
            }
        } else if (error) {
            console.error('getPicklistvalues: : ' + JSON.stringify(error));
        }
    }
    
    @wire(getObjectInfo, { objectApiName: BULLETIN_OBJECT }) bulletinMetadata; 
    @wire(getObjectInfo, { objectApiName: USER_PREF_OBJECT }) function ({error, data}) {
        if(data){
            this.userPrefMetadata = data;
            var recordTypeObjects = [];
            for(var recordTypeObj in data['recordTypeInfos']) {
                if(data['recordTypeInfos'][recordTypeObj]['name'] === 'Bulletin Setting'){
                    this.userSettings['bulletin']['recordType']['Id']  = data['recordTypeInfos'][recordTypeObj]['recordTypeId'];
                    this.bulletinRecordTypeId = data['recordTypeInfos'][recordTypeObj]['recordTypeId'];
                }
                if(data['recordTypeInfos'][recordTypeObj]['name'] === 'Product Setting'){
                    this.userSettings['product']['recordType']['Id']  = data['recordTypeInfos'][recordTypeObj]['recordTypeId'];
                    this.productRecordTypeId = data['recordTypeInfos'][recordTypeObj]['recordTypeId'];
                }
            }                
        }
        if(error){
            console.error('getObjectInfo: USER_PREF_OBJECT: ' + JSON.stringify(error));
        }
    };  
    
    handleClick(event) {
        //this.isModalOpen = true;
        this.getUserPreference();
    }

    handleSave(event) {
        this.userSettings.product.selectedProducts = this.selectedProducts;
        this.gridData = this.backendData;
        console.log('settings: ' + JSON.stringify(this.userSettings));
        saveUserPreference({inputJson: this.userSettings})
        .then(result => {
            for(var k in this.userSettings.product) {
                if(k != 'recordType'){
                    this.selectedRows.push(k);
                    this.selectedProducts[k] = this.userSettings.product[k];
                }
            }
           if(result != null && result == 'success'){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Preferences saved successfully.',
                variant: 'success'
            }));
            this.isModalOpen = false;
           }
           //this.getUserPreference();
        })
        .catch(error => {  
            console.error('ERORORORORO:' + JSON.stringify(error));     
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            }));
        });
        //this.handleCloseModal(event);
    }

    handleCloseModal(event){
        this.isModalOpen = false;
        //this.getUserPreference();
    }
    handleToggle(event){
        var elemName ='';
        var elemDataSet = event.currentTarget.dataset.toggle;
        if(elemDataSet != undefined && elemDataSet.includes('email-')){
            elemName = elemDataSet.replace('email-', '');
            // if(elemName != undefined  && this.userSettings.bulletin[elemName] != undefined)
            if(elemName != undefined )
            this.userSettings.bulletin[elemName]['email'] = event.detail.checked;
        }
        if(elemDataSet != undefined && elemDataSet.includes('notification-')){
            elemName = elemDataSet.replace('notification-', '');
            // if(elemName != undefined  && this.userSettings.bulletin[elemName] != undefined)
            if(elemName != undefined)
            this.userSettings.bulletin[elemName]['notification'] = event.detail.checked;
        }
        for (var i=0; i < this.priorityTypeValues.length; i++){
            if (this.priorityTypeValues[i]['value'] == elemName){
                this.priorityTypeValues[i]['email'] = this.userSettings.bulletin[elemName]['email'];
                this.priorityTypeValues[i]['notification'] = this.userSettings.bulletin[elemName]['notification'];
            }
        }
    }   
    
 
  /*
  Handles the toggle event by:
  -Update the isExpandedMap (to see which rows are expanded and thereby can be selected)
  -If the row is being collapsed and was prevoiusly selected: Save in collapsedSelectedRowsMap 
  -If the row is being expanded and was prevoiusly in collapsedSelectedRowsMap: Save in selectedRows 
   and remove from collapsedSelectedRowsMap
  */
   handleTreeGridToggle(event) {
    var tempHasCollapsedParentMap = this.hasCollapsedParentMap;
    var tempIsExpandedMap = this.isExpandedMap;
    tempIsExpandedMap.set(event.detail.name, event.detail.isExpanded);
    this.isExpandedMap = tempIsExpandedMap;
    if (!event.detail.isExpanded) {
     
      var rootId = Object.assign({}, event.detail.row).Id
        ? Object.assign({}, event.detail.row).Id
        : event.detail.name;      
      var tempSelectedRows = Object.assign([], this.selectedRows);
      var tempCollapsedSelectedRows = this.collapsedSelectedRowsMap.get(rootId)
        ? this.collapsedSelectedRowsMap.get(rootId)
        : [];
      var tempChildRowsEventRow = Object.assign(
        [],
        Object.assign({}, event.detail.row)._children
      );
      console.log('rootId: '+JSON.stringify(rootId));
      console.log('tempSelectedRows: '+JSON.stringify(tempSelectedRows));

      console.log('tempCollapsedSelectedRows: '+JSON.stringify(this.tempCollapsedSelectedRows));
      
      var i;
      for (i = 0; i < tempChildRowsEventRow.length; i++) {
        var tempObj = Object.assign({}, tempChildRowsEventRow[i]);
        if (
          !tempCollapsedSelectedRows.includes(tempObj.Id) &&
          tempSelectedRows.includes(tempObj.Id)
        ) {
          tempCollapsedSelectedRows.push(tempObj.Id);
          var isExpanded = tempIsExpandedMap.get(tempObj.Id)
            ? tempIsExpandedMap.get(tempObj.Id)
            : false;
          if (isExpanded) {
            tempHasCollapsedParentMap.set(tempObj.Id, true);
          }
        }
        var tempChildRows = tempObj._children
          ? Object.assign([], tempObj._children)
          : null;
        if (tempChildRows != null && tempChildRows.length > 0) {
          var j;
          for (j = 0; j < tempChildRows.length; j++) {
            var tempObjNextLevel = Object.assign({}, tempChildRows[j]);
            if (
              !tempCollapsedSelectedRows.includes(tempObjNextLevel.Id) &&
              tempSelectedRows.includes(tempObjNextLevel.Id)
            ) {
              tempCollapsedSelectedRows.push(tempObjNextLevel.Id);
              var isExpanded = tempIsExpandedMap.get(tempObjNextLevel.Id)
                ? tempIsExpandedMap.get(tempObjNextLevel.Id)
                : false;
              if (isExpanded) {
                tempHasCollapsedParentMap.set(tempObjNextLevel.Id, true);
              }
            }
          }
        }
      }
      this.hasCollapsedParentMap = tempHasCollapsedParentMap;
      var tempCollapsedSelectedRowsMap = this.collapsedSelectedRowsMap;
      tempCollapsedSelectedRowsMap.set(rootId, tempCollapsedSelectedRows);
      this.collapsedSelectedRowsMap = tempCollapsedSelectedRowsMap;
      this.doNotUpdateFamily = true;
    } else {
      var tempObj = Object.assign({}, event.detail.row);
      var tempChildRows = tempObj._children
        ? Object.assign([], tempObj._children)
        : [];
//      var rootId =  tempObj.Id;
      var rootId = tempObj.OC_MD_Product ? tempObj.OC_MD_Product : tempObj.Id;
      console.log('rootId: '+JSON.stringify(rootId));
      console.log('tempSelectedRows: '+JSON.stringify(tempSelectedRows));
      console.log('tempObj: '+JSON.stringify(tempObj));
      console.log('tempCollapsedSelectedRows: '+JSON.stringify(this.tempCollapsedSelectedRows));

      var selectRows = Object.assign([], this.selectedRows);
      var tempList = [];
      var tempCollapsedSelectedRows = this.collapsedSelectedRowsMap.get(rootId)
        ? this.collapsedSelectedRowsMap.get(rootId)
        : [];
      
      var i;
      for (i = 0; i < selectRows.length; i++) {
        tempList.push(selectRows[i]);
      }

      for (i = 0; i < tempChildRows.length; i++) {
        var tempObjLevel2 = Object.assign({}, tempChildRows[i]);
        console.log('tempList2: '+JSON.stringify(tempList));
        console.log('tempObjLevel2.Id2: '+JSON.stringify(tempObjLevel2.Id));
        if (
          !tempList.includes(tempObjLevel2.Id) &&
          tempCollapsedSelectedRows.includes(tempObjLevel2.Id)
        ) {
          tempList.push(tempObjLevel2.Id);
          var tmpIdx = tempCollapsedSelectedRows.indexOf(
            tempObjLevel2.Id
          );
          tempCollapsedSelectedRows.splice(tmpIdx, 1);
        }
        tempHasCollapsedParentMap.set(tempObjLevel2.Id, false);
        if (
          tempHasCollapsedParentMap.get(tempObjLevel2.Id) &&
          !tempList.includes(tempObjLevel2.Id)
        ) {
          tempList.push(tempObjLevel2.Id);
        }
        //for childrows, if expanded, populate
        var isExpanded = tempIsExpandedMap.get(tempObjLevel2.Id)
          ? tempIsExpandedMap.get(tempObjLevel2.Id)
          : false;
        var tempChildRowsNextLevel = tempObjLevel2._children
          ? Object.assign([], tempObjLevel2._children)
          : null;
        if (
          tempChildRowsNextLevel != null &&
          tempChildRowsNextLevel.length > 0
        ) {
          var j;
          for (j = 0; j < tempChildRowsNextLevel.length; j++) {
            var tempObjLevel3 = Object.assign({}, tempChildRowsNextLevel[j]);
            console.log('isExpanded3: '+isExpanded);
            console.log('tempList3: '+JSON.stringify(tempList));
            console.log('tempObjLevel3.Id: '+JSON.stringify(tempObjLevel3.Id));
            if (
              isExpanded &&
              !tempList.includes(tempObjLevel3.Id) &&
              (tempCollapsedSelectedRows.includes(tempObjLevel3.Id) ||
                tempHasCollapsedParentMap.get(tempObjLevel3.Id))
            ) {
              tempList.push(tempObjLevel3.Id);
              var tmpIdx = tempCollapsedSelectedRows.indexOf(
                tempObjLevel3.Id
              );
              tempCollapsedSelectedRows.splice(tmpIdx, 1);
              tempHasCollapsedParentMap.set(tempObjLevel3.Id, false);
            }
          }
        }
      }
      this.hasCollapsedParentMap = tempHasCollapsedParentMap;
      var tempCollapsedSelectedRowsMap = this.collapsedSelectedRowsMap;
      tempCollapsedSelectedRowsMap.set(rootId, tempCollapsedSelectedRows);
      this.collapsedSelectedRowsMap = tempCollapsedSelectedRowsMap;
      this.selectedRows = tempList;
      this.oldSelectedRows = tempList;
      this.doNotUpdateFamily = false;
    }
  }

  /*
  Handles the selectRows event by:
  -Update the isExpandedMap (to see which rows are expanded and thereby can be selected)
  -Updates the selected rows
  */
  updateSelectedRows(event) {
    if (!this.doNotUpdateFamily) {
      var newSelectedRows = [];
      var tempIsExpandedMap = this.isExpandedMap;
      var i;
      for (i = 0; i < event.detail.selectedRows.length; i++) {
        newSelectedRows.push(event.detail.selectedRows[i].Id);
        tempIsExpandedMap.set(
          event.detail.selectedRows[i].Id,
          event.detail.selectedRows[i].isExpanded
        );
      }

      this.isExpandedMap = tempIsExpandedMap;
      var tempList = this.updateSelectFamily(newSelectedRows);
      this.oldSelectedRows = tempList;
      this.selectedRows = tempList;
      this.selectedProducts = {};
      for (i = 0; i <  this.selectedRows.length; i++) {
          var foundObj = this.findNestedObj(this.selectedRows[i]);
          var pVal = {"Name":foundObj.Name};
          if((foundObj.OC_MD_Product != null && foundObj.OC_MD_Product != undefined)
          || (foundObj.OC_MD_Parent__c != null && foundObj.OC_MD_Parent__c != undefined))
              pVal = {"Name":foundObj.Name , "ProductAttribute":foundObj.Id};
        this.selectedProducts[this.selectedRows[i]]  = pVal;
      }
      console.log(JSON.stringify(this.selectedProducts));
    }
    console.log('Selected MAP (collapsed selection):'+JSON.stringify(this.collapsedSelectedRowsMap));
    this.doNotUpdateFamily = false;
  }

  findNestedObj(valToFind) {
    var keyToFind = 'Id';
    let foundObj;
    JSON.stringify(this.backendData, (_, nestedValue) => {
      if (nestedValue && nestedValue[keyToFind] === valToFind) {
        foundObj = nestedValue;
      }
      return nestedValue;
    });
    return foundObj;
  }

  /*
  -Updates the selected rows by iterating through the gridData
  */
  updateSelectFamily(incomingList) {
    var newSelectedRows = incomingList;
    var allData = Object.assign([], this.gridData);
    var i;
    for (i = 0; i < allData.length; i++) {
      var tempObj = Object.assign({}, allData[i]);
      var tempNewSelectedRows = this.selectOrDeselectChildren(
        tempObj,
        newSelectedRows
      );
      newSelectedRows = this.selectOrDeselectParent(
        tempObj,
        tempNewSelectedRows
      );
    }
    return newSelectedRows;
  }

  /*
  -Updates the selected rows by comparing the object from gridData with previously selected rows
  -If it was not selected before but is now, select all children
  -If it was selected before but is not now, deselect all children
  -Else, check children
  */
  selectOrDeselectChildren(incomingObject, incomingSelectedRows) {
    var rootId = incomingObject.Id;
    var newSelectedRows = incomingSelectedRows;
    var tempOldSelectedRows = Object.assign([], this.oldSelectedRows);
    // If object was not selected before but is now, select all children
    if (
      !tempOldSelectedRows.includes(incomingObject.Id) &&
      newSelectedRows.includes(incomingObject.Id)
    ) {
      var tempNewSelectedRows = newSelectedRows;
      newSelectedRows = this.updateChildrenAsSelectedOrDeselected(
        rootId,
        true,
        incomingObject,
        tempNewSelectedRows
      );
    }
    // If object was selected before but no longer is, deselect all children
    else if (
      tempOldSelectedRows.includes(incomingObject.Id) &&
      !newSelectedRows.includes(incomingObject.Id)
    ) {
      var tempNewSelectedRows = newSelectedRows;
      newSelectedRows = this.updateChildrenAsSelectedOrDeselected(
        rootId,
        false,
        incomingObject,
        tempNewSelectedRows
      );
    } else {
      //recursive for children
      var tempChildRows = incomingObject._children
        ? Object.assign([], incomingObject._children)
        : null;
      if (tempChildRows != null && tempChildRows.length > 0) {
        var i;
        for (i = 0; i < tempChildRows.length; i++) {
          var tempObjNextLevel = Object.assign({}, tempChildRows[i]);
          var tempNewSelectedRows = newSelectedRows;
          newSelectedRows = this.selectOrDeselectChildren(
            tempObjNextLevel,
            tempNewSelectedRows
          );
        }
      }
    }
    return newSelectedRows;
  }

  /*
  -Selecting or deselecting all children for object recursively
  */
  updateChildrenAsSelectedOrDeselected(
    rootId,
    shouldSelect,
    incomingObject,
    incomingSelectedRows
  ) {
    var returnList = incomingSelectedRows;
    var tempChildRows = incomingObject._children
      ? Object.assign([], incomingObject._children)
      : null;
    var isExpanded = this.isExpandedMap.get(incomingObject.Id)
      ? this.isExpandedMap.get(incomingObject.Id)
      : false;
    if (tempChildRows != null && tempChildRows.length > 0) {
      var tempCollapsedSelectedRowsMap = this.collapsedSelectedRowsMap;
      var tempCollapsedSelectedRows = tempCollapsedSelectedRowsMap.get(rootId)
        ? tempCollapsedSelectedRowsMap.get(rootId)
        : [];
      var i;
      for (i = 0; i < tempChildRows.length; i++) {
        if (shouldSelect) {
          if (isExpanded && !returnList.includes(tempChildRows[i].Id)) {
            returnList.push(tempChildRows[i].Id);
          } else if (
            !tempCollapsedSelectedRows.includes(tempChildRows[i].Id)
          ) {
            tempCollapsedSelectedRows.push(tempChildRows[i].Id);
          }
        } else {
          const indexSelected = returnList.indexOf(tempChildRows[i].Id);
          if (indexSelected > -1) {
            returnList.splice(indexSelected, 1);
          }
          const indexCollapsed = tempCollapsedSelectedRows.indexOf(
            tempChildRows[i].Id
          );
          if (indexCollapsed > -1) {
            tempCollapsedSelectedRows.splice(indexCollapsed, 1);
          }
        }
        tempCollapsedSelectedRowsMap.set(rootId, tempCollapsedSelectedRows);
        this.collapsedSelectedRowsMap = tempCollapsedSelectedRowsMap;
        var tempObjNextLevel = Object.assign({}, tempChildRows[i]);
        var tempNewReturnList = returnList;
        returnList = this.updateChildrenAsSelectedOrDeselected(
          rootId,
          shouldSelect,
          tempObjNextLevel,
          tempNewReturnList
        );
      }
    }
    return returnList;
  }

  /*
  -Checks whether or not a parent should be selected, recursively
  */
  selectOrDeselectParent(incomingObject, incomingSelectedRows) {
    var returnList = incomingSelectedRows;
    var tempChildRows = incomingObject._children
      ? Object.assign([], incomingObject._children)
      : null;
    var isExpanded = this.isExpandedMap.get(incomingObject.Id)
      ? this.isExpandedMap.get(incomingObject.Id)
      : false;
    var tempHasCollapsedParentMap = this.hasCollapsedParentMap;

    if (tempChildRows != null && tempChildRows.length > 0) {
      var i;
      for (i = 0; i < tempChildRows.length; i++) {
        var tempObjNextLevel = Object.assign({}, tempChildRows[i]);
        var tempNewReturnList = returnList;
        returnList = this.selectOrDeselectParent(
          tempObjNextLevel,
          tempNewReturnList
        );
      }
      var rootId = incomingObject.Id;
      var tempCollapsedSelectedRowsMap = this.collapsedSelectedRowsMap;
      var tempCollapsedSelectedRows = tempCollapsedSelectedRowsMap.get(rootId)
        ? tempCollapsedSelectedRowsMap.get(rootId)
        : [];
      var allSelected = true;

      for (i = 0; i < tempChildRows.length; i++) {
        var tempObjNextLevel = Object.assign({}, tempChildRows[i]); //for debug only
        var hasCollapsedParent = tempHasCollapsedParentMap.get(
          tempChildRows[i].Id
        )
          ? tempHasCollapsedParentMap.get(tempChildRows[i].Id)
          : false;
        if (
          (isExpanded &&
            !returnList.includes(tempChildRows[i].Id) &&
            !hasCollapsedParent) ||
          (!isExpanded &&
            !tempCollapsedSelectedRows.includes(tempChildRows[i].Id))
        ) {
          allSelected = false;
        }
      }
      if (allSelected) {
        if (isExpanded && !returnList.includes(incomingObject.Id)) {
          returnList.push(incomingObject.Id);
        } else if (
          !tempCollapsedSelectedRows.includes(incomingObject.Id)
        ) {
          tempCollapsedSelectedRows.push(incomingObject.Id);
        }
      } else if (
        !allSelected &&
        (returnList.includes(incomingObject.Id) ||
          tempCollapsedSelectedRows.includes(incomingObject.Id))
      ) {
        const indexSelected = returnList.indexOf(incomingObject.Id);
        if (indexSelected > -1) {
          returnList.splice(indexSelected, 1);
        }
        const indexCollapsed = tempCollapsedSelectedRows.indexOf(
          incomingObject.Id
        );
        if (indexCollapsed > -1) {
          tempCollapsedSelectedRows.splice(indexCollapsed, 1);
        }
      }
      tempCollapsedSelectedRowsMap.set(rootId, tempCollapsedSelectedRows);
      this.collapsedSelectedRowsMap = tempCollapsedSelectedRowsMap;
    }
    return returnList;
  }
    
}