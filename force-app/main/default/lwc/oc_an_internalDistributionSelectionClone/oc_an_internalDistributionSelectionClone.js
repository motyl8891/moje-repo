import { LightningElement, api } from "lwc";
import getPublicGroups from "@salesforce/apex/OC_AN_InternalDistributionHandlerClone.getPublicGroups";
import getCountOfGroups from "@salesforce/apex/OC_AN_InternalDistributionHandlerClone.getCountOfGroups";
import associateInternalDistributionToBulletin from "@salesforce/apex/OC_AN_InternalDistributionHandlerClone.associateInternalDistributionToBulletin";
import getMorePublicGroupData from "@salesforce/apex/OC_AN_InternalDistributionHandlerClone.getMorePublicGroupData";
import getPrevPublicGroupData from "@salesforce/apex/OC_AN_InternalDistributionHandlerClone.getPrevPublicGroupData";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {allConstants, labels } from "./labels";

const START_PAGE_NUMBER = 1;
const PAGINATION_SIZE = 10;

export default class oc_an_internalDistributionSelection extends LightningElement {
  @api recordId;
  label = labels;
  constants = allConstants;

  searchString = "";

  isModalOpen = false;

  isLoading = false;

  selectedRoles = [];

  publicGroupDataMap = new Map();

  options = [];

  publicGroupDataWithPagination = [];
  publicGroupDataWithPaginationAllData = []
  preSelectedRows = [];
  toSetPreSelectedRows = [];

  numberOfPublicGroups;
  currentPageNumber;
  isDataRetrieved = false;
  publicGroupColoumns = [
    {
      label: this.label.oc_an_columnname_internaldistribution,
      fieldName: this.label.oc_an_columns_field_name,
      type: "text"
    }
  ];

  connectedCallback() {
    this.currentPageNumber = START_PAGE_NUMBER;
    this.getCountOfGroups();
    this.getPublicGroupData(
      START_PAGE_NUMBER,
      PAGINATION_SIZE,
      this.searchString
    );
  }

  getCountOfGroups() {
    getCountOfGroups()
      .then((result) => {
        this.numberOfPublicGroups = result;
      })
      .catch((error) => {
        this.error = error;
      });
  }

  

  handlePagination(event) {
    //let currentPgNo = 2;
    let pageSize = 10;
    this.currentPageNumber = this.currentPageNumber + 1;
    console.log('afternextpagenumber===>'+this.currentPageNumber);
    console.log('this.publicGroupDataWithPagination===>'+JSON.stringify(this.publicGroupDataWithPagination));
    const lastRowRecordId = this.publicGroupDataWithPagination[this.publicGroupDataWithPagination.length - 1]
    console.log('lastRowRecordId=====>'+lastRowRecordId);
    this.getMorePublicGroupData(this.currentPageNumber, pageSize, lastRowRecordId.Id);
  }
  handlePreviousPagination(event){
    this.currentPageNumber = this.currentPageNumber-1;
    console.log('this.START_PAGE_NUMBERPRev===>'+this.currentPageNumber);
    this.getPrevPublicGroupData(this.currentPageNumber);
  }

  getPrevPublicGroupData(cuurentPageNum){
    if(this.publicGroupDataMap.has(cuurentPageNum)){
      console.log('cuurentPageNum===>'+cuurentPageNum);
      console.log('this.publicGroupDataMapFromPrev===>'+JSON.stringify(this.publicGroupDataMap.get(cuurentPageNum)));
      this.publicGroupDataWithPagination = this.publicGroupDataMap.get(cuurentPageNum);
      this.preSelectedRows = this.toSetPreSelectedRows;
      this.template.querySelector(
        '[data-id="datarow"]'
      ).selectedRows = this.preSelectedRows;
    }
  }

  getMorePublicGroupData(currentPageNum, numofRecperPage, recordIdOfLastRow){
    getMorePublicGroupData({
      pageNumber : currentPageNum,
      pageSize :numofRecperPage,
      lastId : recordIdOfLastRow
    }) .then((result) => {
      this.publicGroupDataMap.set(currentPageNum, result);
      console.log('publicGroupDataMap====>'+JSON.stringify(this.publicGroupDataMap.get(currentPageNum)));
      this.publicGroupDataWithPagination = result;
      this.preSelectedRows = this.toSetPreSelectedRows;
      this.template.querySelector(
        '[data-id="datarow"]'
      ).selectedRows = this.preSelectedRows;
    }).catch((error) => {
    console.log('error loading data======>'+error);
    });
  }

  getPublicGroupData(currentPageNum, numofRecperPage, ssearchString) {
    getPublicGroups({
      pageNumber: currentPageNum,
      pageSize: numofRecperPage,
      searchString: ssearchString
    })
      .then((result) => {
        this.publicGroupDataMap.set(currentPageNum, result);
        this.publicGroupDataWithPagination = result;
        this.publicGroupDataWithPaginationAllData = result;
        this.isDataRetrieved = true;
        this.preSelectedRows = this.toSetPreSelectedRows;
        this.template.querySelector(
          '[data-id="datarow"]'
        ).selectedRows = this.preSelectedRows;
      })
      .catch((error) => {
      
        this.error = error;
      });
  }

  getSelectedIds(event) {
    let selectedRows = event.detail.selectedRows;
    // First step remove everything from this.toSetPreSelectedRows that is shown on this page
    for (let i = 0; i < this.publicGroupDataWithPagination.length; i++) {
      if (
        this.toSetPreSelectedRows.includes(
          this.publicGroupDataWithPagination[i].Id
        )
      ) {
        const indexToRemove = this.toSetPreSelectedRows.indexOf(
          this.publicGroupDataWithPagination[i].Id
        );
        if (indexToRemove > -1) {
          this.toSetPreSelectedRows.splice(indexToRemove, 1);
        }
      }
    }
    // Secondly add all the Id's that should be there...
    for (let i = 0; i < selectedRows.length; i++) {
      if (!this.toSetPreSelectedRows.includes(selectedRows[i].Id)) {
        this.toSetPreSelectedRows.push(selectedRows[i].Id);
      }
    }
  }

  handleOpenModal() {
    this.isModalOpen = true;
    this.getRolesForAlertsAndNotifications();
  }
  closeModal() {
    this.isModalOpen = false;
  }

  handleSelectedValues(event) {
    this.selectedRoles = event.detail.value;
  }

  handleAddInternaldistribution() {
    associateInternalDistributionToBulletin({
      listOFPublicGroupIds: this.toSetPreSelectedRows,
      bulletinId: this.recordId
    })
      .then((result) => {
        this.showToastMessage(
          this.constants.toast_Variant_Success,
          this.constants.toast_Variant_Success,
          this.label.AssociatedInternalDistributionToBulletinSuccessFullyToastMsg,
          2000
        );
      })
      .catch((error) => {
        
        this.showToastMessage(
          this.constants.toast_Variant_Error,
          this.constants.toast_Variant_Error,
          this.label.FailedToAssociateInternalDistributionToBulletinToastMsg,
          2000
        );
        this.dispatchEvent(
          new CustomEvent("handleafterfailed", {
            bubbles: true,
            composed: true
          })
        );
      });
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

  searchDataTable(event) {
    this.searchString = event.detail.toLowerCase();
    this.getPublicGroupData(
      START_PAGE_NUMBER,
      PAGINATION_SIZE,
      this.searchString
    );
  }
}