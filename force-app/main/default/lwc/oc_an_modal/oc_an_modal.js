import { LightningElement, api } from "lwc";
export default class OC_AN_Modal extends LightningElement {
  @api modalTitle;
  @api displayBody;
  @api displayFooter;
  @api footerButtonOneLabel;
  @api footerButtonTwoLabel;
  @api footerButtonThreeLabel;
  @api footerButtonOneVariant;
  @api footerButtonTwoVariant;
  @api footerButtonThreeVariant;
  get showHeader() {
    return Boolean(this.modalTitle);
  }
  get showBody() {
    return Boolean(this.displayBody);
  }
  get showFooter() {
    return Boolean(this.displayFooter);
  }
  get isButtonOneReq() {
    return Boolean(this.footerButtonOneLabel);
  }
  get isButtonTwoReq() {
    return Boolean(this.footerButtonTwoLabel);
  }
  get isButtonThreeReq() {
    return Boolean(this.footerButtonThreeLabel);
  }
  get buttonOneVariant() {
    return Boolean(this.footerButtonOneVariant)
      ? this.footerButtonOneVariant
      : "brand";
  }
  get buttonTwoVariant() {
    return Boolean(this.footerButtonTwoVariant)
      ? this.footerButtonTwoVariant
      : "brand";
  }
  get buttonThreeVariant() {
    return Boolean(this.footerButtonThreeVariant)
      ? this.footerButtonThreeVariant
      : "brand";
  }
  handleButtonOne() {
    this.dispatchEvent(
      new CustomEvent("handlebuttonone", { bubbles: true, composed: true })
    );
  }
  handleButtonTwo() {
    this.dispatchEvent(
      new CustomEvent("handlebuttontwo", { bubbles: true, composed: true })
    );
  }

  handleThirdButton() {
    this.dispatchEvent(
      new CustomEvent("handlebuttonthree", { bubbles: true, composed: true })
    );
  }
}