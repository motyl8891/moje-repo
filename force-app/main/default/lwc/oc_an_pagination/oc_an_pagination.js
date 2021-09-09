import { LightningElement, api } from "lwc";
export default class Oc_an_pagination extends LightningElement {
  @api numOfTotalRecords;
  @api currentPageNumber;
  @api numOfRecordsPerPage;
  numOfTotalPages;
  pageNumbersList;
  disablePreviousButton = true;
  disableNextButton = false;
  activePageCssClass = "activePageNumber";
  connectedCallback() {
    this.calculateNumOfTotalPages();
    this.setPageNumbersList();
  }
  get totalRecordsSize() {
    return Boolean(this.numOfTotalRecords)
      ? parseInt(this.numOfTotalRecords)
      : 1;
  }
  get currentpageNum() {
    return Boolean(this.currentPageNumber)
      ? parseInt(this.currentPageNumber)
      : 1;
  }
  get recordsPerPage() {
    return Boolean(this.numOfRecordsPerPage)
      ? parseInt(this.numOfRecordsPerPage)
      : 10;
  }
  calculateNumOfTotalPages() {
    this.numOfTotalPages = Math.ceil(
      this.totalRecordsSize / this.recordsPerPage
    );
  }
  handlePrevious() {
    this.currentPageNumber = parseInt(this.currentpageNum) - 1;
    console.log("Previous PageNumber ==>" + this.currentPageNumber);
    this.handlePagination(null, this.currentPageNumber);
  }
  handleNext() {
    this.currentPageNumber = parseInt(this.currentpageNum) + 1;
    console.log("Next PageNumber ==>" + this.currentPageNumber);
    this.handlePagination(null, this.currentPageNumber);
  }
  setPageNumbersList() {
    let totalNumOfPages = this.numOfTotalPages;
    let currentPageNo = this.currentpageNum;
    let PageNumList = [];
    this.pageNumbersList = [];
    this.currentPageNumber = parseInt(currentPageNo);
    console.log("totalNumOfPages ==>" + totalNumOfPages);
    console.log("currentPageNo ==>" + currentPageNo);
    if (currentPageNo < 7) {
      for (var i = 1; i <= 7; i++) {
        if (i < totalNumOfPages) {
          if (i === currentPageNo) {
            PageNumList.push({ name: i, style: this.activePageCssClass });
          } else {
            PageNumList.push({ name: i });
          }
        } else {
          break;
        }
      }
      if (totalNumOfPages > 7) {
        PageNumList.push({ name: "..." });
      }
      if (currentPageNo === totalNumOfPages) {
        PageNumList.push({
          name: totalNumOfPages,
          style: this.activePageCssClass
        });
      } else {
        PageNumList.push({ name: totalNumOfPages });
      }
    } else {
      PageNumList.push({ name: "1" });
      PageNumList.push({ name: "..." });
      if (
        currentPageNo == totalNumOfPages ||
        currentPageNo == totalNumOfPages - 1 ||
        currentPageNo == totalNumOfPages - 2 ||
        currentPageNo == totalNumOfPages - 3
      ) {
        for (let i = currentPageNo - 4; i <= currentPageNo + 2; i++) {
          if (i < totalNumOfPages) {
            if (i === currentPageNo) {
              PageNumList.push({ name: i, style: this.activePageCssClass });
            } else {
              PageNumList.push({ name: i });
            }
          } else {
            break;
          }
        }
      } else {
        for (let i = currentPageNo - 3; i <= currentPageNo + 2; i++) {
          if (i === currentPageNo) {
            PageNumList.push({ name: i, style: this.activePageCssClass });
          } else {
            PageNumList.push({ name: i });
          }
        }
        PageNumList.push({ name: "..." });
      }
      if (totalNumOfPages === currentPageNo) {
        PageNumList.push({
          name: totalNumOfPages,
          style: this.activePageCssClass
        });
      } else {
        PageNumList.push({ name: totalNumOfPages });
      }
    }
    this.pageNumbersList = PageNumList;
    this.disableNavigationButtons();
    //console.log('PageNumList ==>'+PageNumList);
  }
  handlePagination(event, pageNum) {
    /* let currentPageNumber = Boolean(event)
      ? event.currentTarget.dataset.value
      : Boolean(pageNum)
      ? pageNum
      : null; */
      let currentPageNumber = (Boolean(event)) ? event.currentTarget.dataset.value : (Boolean(pageNum) ? parseInt(pageNum) : null);
      console.log("currentPageNumber executing1===>" + currentPageNumber);
    if (!isNaN(currentPageNumber)) {
      console.log("currentPageNumber executing===>" + currentPageNumber);
      let paginationAttributes = {
        pageNumber: currentPageNumber,
        pageSize: this.recordsPerPage
      };
      this.currentPageNumber = parseInt(currentPageNumber);
      // this.disableNavigationButtons();
      this.setPageNumbersList();
      this.dispatchEvent(
        new CustomEvent("paginate", { detail: paginationAttributes })
      );
    }
  }
  disableNavigationButtons() {
    console.log("this.currentPageNumber" + this.currentPageNumber);
    this.disablePreviousButton = this.currentPageNumber == 1 ? true : false;
    this.disableNextButton =
      this.currentPageNumber === this.numOfTotalPages ? true : false;
  }
}