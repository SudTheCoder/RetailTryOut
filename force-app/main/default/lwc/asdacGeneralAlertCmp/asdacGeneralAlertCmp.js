import { api, LightningElement } from 'lwc';

const ASSISTIVE_TEXT_INFORMATIVE = 'Information';
const ASSISTIVE_TEXT_WARNING = 'Warning';
const ASSISTIVE_TEXT_CRISIS = 'Important';

const PLACEMENT_CONTAINER_BASE_CLASS = 'asdac-general-alert-placement-container';
const PLACEMENT_CONTAINER_INLINE_CLASS = 'asdac-general-alert-placement-container-inline';
const PLACEMENT_CONTAINER_NAVIGATION_CLASS = 'asdac-general-alert-placement-container-navigation';
const PLACEMENT_CONTAINER_BOTTOM_CLASS = 'asdac-general-alert-placement-container-bottom';

const CONTAINER_BASE_CLASS = 'slds-notify slds-notify_alert asdac-general-alert-container';
const CONTAINER_VARIANT_INFORMATIVE_CLASS = 'asdac-general-alert-container-variant-informative';
const CONTAINER_VARIANT_WARNING_CLASS = 'asdac-general-alert-container-variant-warning';
const CONTAINER_VARIANT_CRISIS_CLASS = 'asdac-general-alert-container-variant-crisis';
const CONTAINER_PLACEMENT_INLINE_CLASS = 'asdac-general-alert-container-placement-inline';
const CONTAINER_PLACEMENT_NAVIGATION_CLASS = 'asdac-general-alert-container-placement-navigation';
const CONTAINER_PLACEMENT_BOTTOM_CLASS = 'asdac-general-alert-container-placement-bottom';
const CONTAINER_DISMISSABLE_CLASS = 'asdac-general-alert-container-dismissable';

export default class AsdacGeneralAlertCmp extends LightningElement {
  VARIANT = {
    INFORMATIVE: { value: 'INFORMATIVE', assistiveText: ASSISTIVE_TEXT_INFORMATIVE, containerClass: CONTAINER_VARIANT_INFORMATIVE_CLASS }, // default
    WARNING: { value: 'WARNING', assistiveText: ASSISTIVE_TEXT_WARNING, containerClass: CONTAINER_VARIANT_WARNING_CLASS },
    CRISIS: { value: 'CRISIS', assistiveText: ASSISTIVE_TEXT_CRISIS, containerClass: CONTAINER_VARIANT_CRISIS_CLASS },
  };
  PLACEMENT = {
    INLINE: { value: 'INLINE', dismissableDefault: false, containerClass: CONTAINER_PLACEMENT_INLINE_CLASS, placementContainerClass: PLACEMENT_CONTAINER_INLINE_CLASS }, // default
    NAVIGATION: { value: 'NAVIGATION', dismissableDefault: false, containerClass: CONTAINER_PLACEMENT_NAVIGATION_CLASS, placementContainerClass: PLACEMENT_CONTAINER_NAVIGATION_CLASS },
    BOTTOM: { value: 'BOTTOM', dismissableDefault: true, containerClass: CONTAINER_PLACEMENT_BOTTOM_CLASS, placementContainerClass: PLACEMENT_CONTAINER_BOTTOM_CLASS },
  };

  @api id;
  @api message = '';
  @api variant = this.VARIANT.INFORMATIVE.value;
  @api placement = this.PLACEMENT.INLINE.value;
  @api dismissable = this.PLACEMENT.INLINE.dismissableDefault;
  show = true;

  connectedCallback() {
    this.variant = this.variant.toUpperCase().trim();
    if (!this.VARIANT[this.variant]) {
      this.variant = this.VARIANT.INFORMATIVE.value;
    }

    this.placement = this.placement.toUpperCase().trim();
    if (!this.PLACEMENT[this.placement]) {
      this.placement = this.PLACEMENT.INLINE.value;
    }

    if (this.PLACEMENT[this.placement].dismissableDefault) {
      this.dismissable = true;
    }
  }

  get getPlacementContainerClass() {
    let classes = [PLACEMENT_CONTAINER_BASE_CLASS];
    classes.push(this.PLACEMENT[this.placement].placementContainerClass);
    return classes.join(' ');
  }

  get getContainerClass() {
    let classes = [CONTAINER_BASE_CLASS];
    classes.push(this.VARIANT[this.variant].containerClass);
    classes.push(this.PLACEMENT[this.placement].containerClass);
    if (this.dismissable) {
      classes.push(CONTAINER_DISMISSABLE_CLASS);
    }
    return classes.join(' ');
  }

  get getAssistiveText() {
    return this.VARIANT[this.variant].assistiveText;
  }

  get isInformative() {
    return this.VARIANT.INFORMATIVE.value === this.variant;
  }

  get isWarning() {
    return this.VARIANT.WARNING.value === this.variant;
  }

  get isCrisis() {
    return this.VARIANT.CRISIS.value === this.variant;
  }

  closeAlert() {
    this.show = false;
    const closeEvent = new CustomEvent('close', {
      detail: { id: this.id }
    });
    this.dispatchEvent(closeEvent);
  }
}