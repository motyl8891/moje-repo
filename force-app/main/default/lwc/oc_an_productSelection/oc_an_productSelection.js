import { LightningElement, api,track } from "lwc";
import getCountOfProducts from "@salesforce/apex/OC_AN_ProductSelectionController.getCountOfProducts";
import addPrdAttributesToBulletin from "@salesforce/apex/OC_AN_ProductSelectionController.addPrdAttributesToBulletin";
import getProducts from "@salesforce/apex/OC_AN_ProductSelectionController.getProducts";
import { allConstants, allLabels } from "./oc_an_productSelectionConstants";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getProducts1 from '@salesforce/apex/OC_AN_UserPreferencesController.getProducts';

/**
 * Solution for lightning-tree-grid including pagination and loading of data
 * The majority of the handler code is done for the following reasons:
 * 1. Handle Toggle (expand/collaps of a subtree):
 * 1.a. collaps of a tree/sub-tree generates a HandelSelection with all the elements in the tree as unselect.
 * 1.b. expand generates only a handle toggle.
 * 2. Handle Selection:
 * 2.a. Select or de-select the current value.
 * 2.b. Need to know if its a parent and all the elements needs to be selected/de-selected below the parent.
 * 2.c. Need to know if all subelements are clicked and then also select/de-select the parent.
 */
export default class Oc_an_productSelection extends LightningElement {
  constants = allConstants;
  labels = allLabels;
  @api bulletinRecordId;
  @track gridData =[];
  productGridColumns = this.constants.productGridColumns;
  gridColumns = [{ type: 'text', fieldName: 'Name', label: 'Name' }];
  numberOfProducts;
  currentPageNumber = "1";
  isDataRetrieved = false;
  numberOfRecPerPage = 10;

  productAttributeItemsWrapperMap = new Map();
  selectedRecordsWrapperMap = new Map();
  displaySpinner = false;

  selectedRows = [];

  oldSelectedRows = [];
  collapsedSelectedRowsMap = new Map();
  isExpandedMap = new Map();
  hasCollapsedParentMap = new Map();
  doNotUpdateFamily = false;
  loadedProdcutsInfo = {isCompleted: false, offsetCount: 0};

  connectedCallback() {
    this.displaySpinner = true;
    this.getProductsCount();
    //this.getProductData(1, this.numberOfRecPerPage);
  }

  getProductsCount() {
    getCountOfProducts()
      .then((result) => {
        this.numberOfProducts = result;
      })
      .catch((error) => {
        
      });
  }

  /*handlePagination(event) {
    // Check if to be removed...
    this.selectedRecordsWrapperMap.set(
      this.currentPageNumber,
      this.selectedRows
    );
    this.saveSelectedRowsAsProductAttributeItemsWrapper(this.selectedRows);
    this.displaySpinner = true;
    let currentPgNo = event.detail.pageNumber;
    let pageSize = event.detail.pageSize;
    this.currentPageNumber = currentPgNo;
    this.getProductData(currentPgNo, pageSize);
  }*/

  getProductData(currentPageNum, numofRecperPage) {
    getProducts({ pageNumber: currentPageNum, pageSize: numofRecperPage })
      .then((result) => {
        console.log('olddata' +JSON.stringify(result));
        let productData = JSON.parse(
          JSON.stringify(result).split("productAttrItems").join("_children")
        );
        this.gridData = JSON.parse(productData);
        this.displaySpinner = false;
        this.isDataRetrieved = true;
        if (this.selectedRecordsWrapperMap.get(currentPageNum)) {
          this.selectedRows = this.selectedRecordsWrapperMap.get(
            currentPageNum
          );
        } else {
          this.selectedRows = [];
        }
        this.template.querySelector(
          '[data-id="datarow"]'
        ).selectedRows = this.selectedRows;
      })
      .catch((error) => {
        this.displaySpinner = false;
        
      });
  }

  handleAddProducts() {
    this.displaySpinner = true;
    this.saveSelectedRowsAsProductAttributeItemsWrapper(this.selectedRows);
    if (this.productAttributeItemsWrapperMap.size > 0) {
      addPrdAttributesToBulletin({
        prdAttributesWrapperList: JSON.stringify(
          Array.from(this.productAttributeItemsWrapperMap.values())
        ),
        bulletinRecId: this.bulletinRecordId
      })
        .then((result) => {
          this.displaySpinner = false;
          this.showToastMessage(
            this.constants.toast_Variant_Success,
            this.constants.toast_Variant_Success,
            this.labels.productAttrUISuccessToastMsg,
            2000
          );
        })
        .catch((error) => {
         
          this.displaySpinner = false;
          this.showToastMessage(
            this.constants.toast_Variant_Error,
            this.constants.toast_Variant_Error,
            this.labels.productAttrUIErrorToastMsg,
            2000
          );
          this.dispatchEvent(
            new CustomEvent("handleafterfailed", { bubbles: true, composed: true })
          );
        });
    } else {
      this.displaySpinner = false;
      this.showToastMessage(
        null,
        this.constants.toast_Variant_Warning,
        this.labels.productAttrUINoSelectionMsg,
        null
      );
    }
  }

  showToastMessage(toastTitle, toastVariant, toastMessage, pageReloadDelay) {
    const event = new ShowToastEvent({
      title: toastTitle,
      variant: toastVariant,
      message: toastMessage
    });
    this.dispatchEvent(event);
    if (pageReloadDelay) {
      this.dispatchEvent(
        new CustomEvent("handleaftersave", { bubbles: true, composed: true })
      );
    }
  }

  /*
  Saves the selected rows in a format accepted by Apex backend. Populates with info from 
  gridData. Checks both selectedRows and collapsedRowsMap. Checks children with iteration 
  for 3 levels (no recursion).
  */
  saveSelectedRowsAsProductAttributeItemsWrapper(incomingList) {
    var allData = Object.assign([], this.gridData);
    var i;
    for (i = 0; i < allData.length; i++) {
      var tempObj = Object.assign({}, allData[i]);
      var rootId = tempObj.rootRecId ? tempObj.rootRecId : tempObj.recordId;
      var tempCollapsedSelectedRows = this.collapsedSelectedRowsMap.get(rootId)
        ? this.collapsedSelectedRowsMap.get(rootId)
        : [];
      if (
        incomingList.includes(tempObj.recordId) ||
        tempCollapsedSelectedRows.includes(tempObj.recordId)
      ) {
        var jsonObj = {
          name: tempObj.name,
          type: tempObj.type,
          recordId: tempObj.recordId,
          parentId: tempObj.parentId,
          rootRecId: tempObj.rootRecId
        };
        this.productAttributeItemsWrapperMap.set(tempObj.recordId, jsonObj);
      }
      if (tempObj._children != null) {
        var j;
        for (j = 0; j < tempObj._children.length; j++) {
          var tempObjLevel2 = Object.assign({}, tempObj._children[j]);
          if (
            incomingList.includes(tempObjLevel2.recordId) ||
            tempCollapsedSelectedRows.includes(tempObjLevel2.recordId)
          ) {
            var jsonObj = {
              name: tempObjLevel2.name,
              type: tempObjLevel2.type,
              recordId: tempObjLevel2.recordId,
              parentId: tempObjLevel2.parentId,
              rootRecId: tempObjLevel2.rootRecId
            };
            this.productAttributeItemsWrapperMap.set(
              tempObjLevel2.recordId,
              jsonObj
            );
          }
          if (tempObjLevel2._children != null) {
            var k;
            for (k = 0; k < tempObjLevel2._children.length; k++) {
              var tempObjLevel3 = Object.assign({}, tempObjLevel2._children[k]);

              if (
                incomingList.includes(tempObjLevel3.recordId) ||
                tempCollapsedSelectedRows.includes(tempObjLevel3.recordId)
              ) {
                var jsonObj = {
                  name: tempObjLevel3.name,
                  type: tempObjLevel3.type,
                  recordId: tempObjLevel3.recordId,
                  parentId: tempObjLevel3.parentId,
                  rootRecId: tempObjLevel3.rootRecId
                };
                this.productAttributeItemsWrapperMap.set(
                  tempObjLevel3.recordId,
                  jsonObj
                );
              }
            }
          }
        }
      }
    }
  }

  // ---------- Event handlers

  /*
  Handles the toggle event by:
  -Update the isExpandedMap (to see which rows are expanded and thereby can be selected)
  -If the row is being collapsed and was prevoiusly selected: Save in collapsedSelectedRowsMap 
  -If the row is being expanded and was prevoiusly in collapsedSelectedRowsMap: Save in selectedRows 
   and remove from collapsedSelectedRowsMap
  */
  handleToggle(event) {
    var tempHasCollapsedParentMap = this.hasCollapsedParentMap;
    var tempIsExpandedMap = this.isExpandedMap;
    tempIsExpandedMap.set(event.detail.name, event.detail.isExpanded);
    this.isExpandedMap = tempIsExpandedMap;
    
    if (!event.detail.isExpanded) {
      var rootId = Object.assign({}, event.detail.row).rootRecId
        ? Object.assign({}, event.detail.row).rootRecId
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
          !tempCollapsedSelectedRows.includes(tempObj.recordId) &&
          tempSelectedRows.includes(tempObj.recordId)
        ) {
          tempCollapsedSelectedRows.push(tempObj.recordId);
          var isExpanded = tempIsExpandedMap.get(tempObj.recordId)
            ? tempIsExpandedMap.get(tempObj.recordId)
            : false;
          if (isExpanded) {
            tempHasCollapsedParentMap.set(tempObj.recordId, true);
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
              !tempCollapsedSelectedRows.includes(tempObjNextLevel.recordId) &&
              tempSelectedRows.includes(tempObjNextLevel.recordId)
            ) {
              tempCollapsedSelectedRows.push(tempObjNextLevel.recordId);
              var isExpanded = tempIsExpandedMap.get(tempObjNextLevel.recordId)
                ? tempIsExpandedMap.get(tempObjNextLevel.recordId)
                : false;
              if (isExpanded) {
                tempHasCollapsedParentMap.set(tempObjNextLevel.recordId, true);
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
      var rootId = tempObj.rootRecId ? tempObj.rootRecId : tempObj.recordId;
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

        if (
          !tempList.includes(tempObjLevel2.recordId) &&
          tempCollapsedSelectedRows.includes(tempObjLevel2.recordId)
        ) {
          tempList.push(tempObjLevel2.recordId);
          var tmpIdx = tempCollapsedSelectedRows.indexOf(
            tempObjLevel2.recordId
          );
          tempCollapsedSelectedRows.splice(tmpIdx, 1);
        }
        tempHasCollapsedParentMap.set(tempObjLevel2.recordId, false);
        if (
          tempHasCollapsedParentMap.get(tempObjLevel2.recordId) &&
          !tempList.includes(tempObjLevel2.recordId)
        ) {
          tempList.push(tempObjLevel2.recordId);
        }
        //for childrows, if expanded, populate
        var isExpanded = tempIsExpandedMap.get(tempObjLevel2.recordId)
          ? tempIsExpandedMap.get(tempObjLevel2.recordId)
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
            console.log('tempList3: '+JSON.stringify(tempChildRowsNextLevel));
            console.log('tempObjLevel3.Id: '+JSON.stringify(tempObjLevel3.recordId));
            if (
              isExpanded &&
              !tempList.includes(tempObjLevel3.recordId) &&
              (tempCollapsedSelectedRows.includes(tempObjLevel3.recordId) ||
                tempHasCollapsedParentMap.get(tempObjLevel3.recordId))
            ) {
              tempList.push(tempObjLevel3.recordId);
              var tmpIdx = tempCollapsedSelectedRows.indexOf(
                tempObjLevel3.recordId
              );
              tempCollapsedSelectedRows.splice(tmpIdx, 1);
              tempHasCollapsedParentMap.set(tempObjLevel3.recordId, false);
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
        newSelectedRows.push(event.detail.selectedRows[i].recordId);
        tempIsExpandedMap.set(
          event.detail.selectedRows[i].recordId,
          event.detail.selectedRows[i].isExpanded
        );
      }

      this.isExpandedMap = tempIsExpandedMap;
      var tempList = this.updateSelectFamily(newSelectedRows);
      this.oldSelectedRows = tempList;
      this.selectedRows = tempList;
    }
    this.doNotUpdateFamily = false;
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
    var rootId = incomingObject.rootRecId
      ? incomingObject.rootRecId
      : incomingObject.recordId;
    var newSelectedRows = incomingSelectedRows;
    var tempOldSelectedRows = Object.assign([], this.oldSelectedRows);
    // If object was not selected before but is now, select all children
    if (
      !tempOldSelectedRows.includes(incomingObject.recordId) &&
      newSelectedRows.includes(incomingObject.recordId)
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
      tempOldSelectedRows.includes(incomingObject.recordId) &&
      !newSelectedRows.includes(incomingObject.recordId)
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
    var isExpanded = this.isExpandedMap.get(incomingObject.recordId)
      ? this.isExpandedMap.get(incomingObject.recordId)
      : false;
    if (tempChildRows != null && tempChildRows.length > 0) {
      var tempCollapsedSelectedRowsMap = this.collapsedSelectedRowsMap;
      var tempCollapsedSelectedRows = tempCollapsedSelectedRowsMap.get(rootId)
        ? tempCollapsedSelectedRowsMap.get(rootId)
        : [];
      var i;
      for (i = 0; i < tempChildRows.length; i++) {
        if (shouldSelect) {
          if (isExpanded && !returnList.includes(tempChildRows[i].recordId)) {
            returnList.push(tempChildRows[i].recordId);
          } else if (
            !tempCollapsedSelectedRows.includes(tempChildRows[i].recordId)
          ) {
            tempCollapsedSelectedRows.push(tempChildRows[i].recordId);
          }
        } else {
          const indexSelected = returnList.indexOf(tempChildRows[i].recordId);
          if (indexSelected > -1) {
            returnList.splice(indexSelected, 1);
          }
          const indexCollapsed = tempCollapsedSelectedRows.indexOf(
            tempChildRows[i].recordId
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
    var isExpanded = this.isExpandedMap.get(incomingObject.recordId)
      ? this.isExpandedMap.get(incomingObject.recordId)
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
      var rootId = incomingObject.rootRecId
        ? incomingObject.rootRecId
        : incomingObject.recordId;
      var tempCollapsedSelectedRowsMap = this.collapsedSelectedRowsMap;
      var tempCollapsedSelectedRows = tempCollapsedSelectedRowsMap.get(rootId)
        ? tempCollapsedSelectedRowsMap.get(rootId)
        : [];
      var allSelected = true;

      for (i = 0; i < tempChildRows.length; i++) {
        var tempObjNextLevel = Object.assign({}, tempChildRows[i]); //for debug only
        var hasCollapsedParent = tempHasCollapsedParentMap.get(
          tempChildRows[i].recordId
        )
          ? tempHasCollapsedParentMap.get(tempChildRows[i].recordId)
          : false;
        if (
          (isExpanded &&
            !returnList.includes(tempChildRows[i].recordId) &&
            !hasCollapsedParent) ||
          (!isExpanded &&
            !tempCollapsedSelectedRows.includes(tempChildRows[i].recordId))
        ) {
          allSelected = false;
        }
      }
      if (allSelected) {
        if (isExpanded && !returnList.includes(incomingObject.recordId)) {
          returnList.push(incomingObject.recordId);
        } else if (
          !tempCollapsedSelectedRows.includes(incomingObject.recordId)
        ) {
          tempCollapsedSelectedRows.push(incomingObject.recordId);
        }
      } else if (
        !allSelected &&
        (returnList.includes(incomingObject.recordId) ||
          tempCollapsedSelectedRows.includes(incomingObject.recordId))
      ) {
        const indexSelected = returnList.indexOf(incomingObject.recordId);
        if (indexSelected > -1) {
          returnList.splice(indexSelected, 1);
        }
        const indexCollapsed = tempCollapsedSelectedRows.indexOf(
          incomingObject.recordId
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
  handleScroll(event) {
    if (/*this.hasLoaded && */ !this.loadedProdcutsInfo.isCompleted) {
        //this.isLoaded = false;
        getProducts1({wrapper: this.loadedProdcutsInfo}).then(result => {
            if (result != null) {
                this.loadSelectedStates(result.products, this.savedProductSettings);
                this.gridData.push.apply(this.gridData, result.products);
                this.loadedProdcutsInfo.isCompleted = result.isCompleted;
                this.loadedProdcutsInfo.offsetCount += result.products.length;

                this.template.querySelector('c-omnichanneltheme-element-lightning-tree-grid').updateChanges();
            }
        }).catch(error => {
            console.log('Products: error' + error);
        });
    }
}

/*connectedCallback(){
  debugger;
  getProducts1({wrapper: this.loadedProdcutsInfo}).then(result => {
      if(result != null){

        ///
          console.log('products: '+JSON.stringify(result));
          this.loadSelectedStates(result.products, this.savedProductSettings);
          this.gridData = result.products;
          console.log('productsresult: '+JSON.stringify(result.products));
          console.log('griddata: '+this.gridData);
          
          this.loadedProdcutsInfo.isCompleted = result.isCompleted;
          this.loadedProdcutsInfo.offsetCount = result.products.length;
          this.hasLoaded = true;
      }
  }).catch(error => {
      console.log('Products: error' + error);
  });
}
loadSelectedStates(elements, savedProductSettings){
  elements.forEach(element => {
      if(savedProductSettings && savedProductSettings.hasOwnProperty(element.Id) && savedProductSettings[element.Id].email){
          element.selectedState = 'checked';
      }
      else{
          element.selectedState = 'unchecked';
      }
      if(element.children){
          this.loadSelectedStates(element.children, savedProductSettings)
      }
  });
}

@api getProductSettings(){
  return this.template.querySelector('c-oc_an_product-selection-tree-grid').getSelectedRows();
}
*/
}