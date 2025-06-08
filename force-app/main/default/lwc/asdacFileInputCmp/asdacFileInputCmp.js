import { api, LightningElement } from "lwc";
import { filterAcceptedFiles } from "c/asdacUtilCmp";

export default class AsdacFileInputCmp extends LightningElement {
  @api name;
  @api label;
  @api value;
  @api multiple;
  @api accept;
  @api required;
  @api disabled;
  @api helpLabel;

  get filePills() {
    if (!this.value || this.value.length === 0) {
      return false;
    }
    return this.value.map((file, index) => ({
      label: file.name,
      name: index
    }));
  }

  handleFileAdd(event) {
    event.preventDefault();
    event.stopPropagation();

    const files = this.value || [];
    const selectedFiles = [...event.detail.files]; // Convert FileList to Array of Files
    let updatedFiles;
    filterAcceptedFiles(selectedFiles,this.accept);
      if (!this.multiple) {
        updatedFiles = [selectedFiles[0]];
      } else {
        const newFiles = selectedFiles.filter((selectedFile) => {
          return !files.find((file) => file.name === selectedFile.name);
        });
        updatedFiles = files.concat(newFiles);
      }
      const newEvent = new CustomEvent("change", {
        detail: { value: updatedFiles }
      });
      this.dispatchEvent(newEvent);
  }

  handleFileRemove(event) {
    event.preventDefault();
    event.stopPropagation();

    const index = Number(event.detail.item.name);
    const files = [...this.value];
    files.splice(index, 1);
    const newEvent = new CustomEvent("change", {
      detail: { value: files }
    });
    this.dispatchEvent(newEvent);
  }
}