import { LightningElement } from "lwc";

export default class Oc_customSearchComponent extends LightningElement {
  handleOnChange(event) {
    const custEvent = new CustomEvent("handlesearch", {
      detail: event.target.value.toUpperCase()
    });
    this.dispatchEvent(custEvent);
  }
}