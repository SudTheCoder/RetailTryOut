import { api, LightningElement } from "lwc";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import { filterAcceptedFiles } from "c/asdacUtilCmp";
import ASDAC_WebformAttachmentUploadDisclaimerText from "@salesforce/label/c.ASDAC_WebformAttachmentUploadDisclaimerText";
import ASDAC_AttachmentFileSizeLimit from "@salesforce/label/c.ASDAC_AttachmentFileSizeLimit";
import ASDAC_AttachmentsTotalFileSizeLimit from "@salesforce/label/c.ASDAC_AttachmentsTotalFileSizeLimit";
import ASDAC_AttachmentFileSizeLimitExceededErrorMessage from "@salesforce/label/c.ASDAC_AttachmentFileSizeLimitExceededErrorMessage";
import ASDAC_AttachmentsTotalFileSizeLimitExceededErrorMessage from "@salesforce/label/c.ASDAC_AttachmentsTotalFileSizeLimitExceededErrorMessage";
import ASDAC_FileNameRestriction from "@salesforce/label/c.ASDAC_FileNameRestriction";

export default class AsdacUploadFileCmp extends LightningElement {
  @api name = 'attachments';
  @api label = 'Attach Documents';
  @api multiple = false;
  @api accept = '.png,.jpeg,.jpg';
  @api required = false;
  @api disabled = false;
  @api helpLabel = '';
  _contentVersions = [];
  attachments = [];
  loading = false;
  errorMessage = [];
  validity = true;
  
  get filePills() {
    if (!this.attachments || this.attachments.length === 0) {
      return [];
    }
    return this.attachments.map((file, index) => ({
      label: file.name,
      name: index
    }));
  }

  get attachmentUploadDisclaimer(){
    return ASDAC_WebformAttachmentUploadDisclaimerText;
  }

  @api
  get files() { 
    return this._contentVersions;
  }

  set files(contentVersions) {
    this._contentVersions = contentVersions;
    this.validity = true;
    this.errorMessage = [];
    let emptyFileNames = '';
    this.attachments = contentVersions.map((cv) => {
      if (!cv.VersionData) {
        // add error
        this.validity = false;
        emptyFileNames += ', '+cv.Title;
      }
      return { 
        name: cv.Title, contentVersion: cv 
      };
    });
      emptyFileNames && this.errorMessage.push('Empty file(s) - '+emptyFileNames.replace(',',''));
  }

  handleFileAdd(event) { 
    event.preventDefault();
    event.stopPropagation();
    const files = this.attachments || [];
    let selectedFiles = [...event.detail.files]; // Convert FileList to Array of Files
    selectedFiles = filterAcceptedFiles(selectedFiles,this.accept);// remove not accepted files
    let updatedFiles;
    if (!this.multiple) {
      updatedFiles = [selectedFiles[0]];
    } else {
      const newFiles = selectedFiles.filter((selectedFile) => {
        return !files.find((file) => file.name === selectedFile.name);
      });
      updatedFiles = files.concat(newFiles);
    }
    this.handleAttachments(updatedFiles);
  }

  handleFileRemove(event) {
    event.preventDefault();
    event.stopPropagation();
    const index = Number(event.detail.item.name);
    const files = [...this.attachments];
    files.splice(index, 1);
    this.handleAttachments(files);
  }

  async handleAttachments(documents) {
    this.loading = true;
    this.attachments  = documents;
    try {
      this.errorMessage = [];
      let emptyFileNames = '';
      this.validity = true;
      let thisThis = this;
      const files = await Promise.all(
        this.attachments.map(async function (file) {
          if (file.contentVersion) {
            return file.contentVersion;
          }
          let versionDataString = window.btoa(new Uint8Array(await file.arrayBuffer()).reduce((data, byte) => data + String.fromCharCode(byte), ""));
          if (!versionDataString) {
            // add error
            thisThis.validity = false;
            emptyFileNames += ', '+file.name;
          }
          return {
            FirstPublishLocationId: "",
            ContentLocation: "S",
            PathOnClient: file.name,
            Title: file.name,
            VersionData: versionDataString,
            ContentSize: file.size
          };
        })
      );
      emptyFileNames && thisThis.errorMessage.push('Empty file(s) - '+emptyFileNames.replace(',',''));
      this._contentVersions = files;
      const attributeChangeEvent = new FlowAttributeChangeEvent("files", files);
      this.dispatchEvent(attributeChangeEvent);
      this.loading = false;
    } catch (error) {
      this.loading = false;
      console.error(error);
    }
  }
  @api validate() {
    let totalFileSize = 0;
    let isAttachmentFileSizeLimitExceeded = false;
    let fileSizeLimitExceededAttachmentNames = '';
    let invalidFileNames = '';
    let isInvalidAttachmentTitleFlag = false;
    const attachmentNamePattern = /^[a-zA-Z0-9\s\-\.]+$/;

    for (let cv of this._contentVersions) {
      if(!attachmentNamePattern.test(cv.Title)){
        this.validity = false;
        invalidFileNames += ', '+cv.Title;
        isInvalidAttachmentTitleFlag=true;
      }
      if (cv.ContentSize > ASDAC_AttachmentFileSizeLimit) {
        this.validity = false;
        isAttachmentFileSizeLimitExceeded = true;
        fileSizeLimitExceededAttachmentNames += ', '+cv.Title;
      }
      totalFileSize = totalFileSize + cv.ContentSize;
    }

    isInvalidAttachmentTitleFlag && this.errorMessage.push(isInvalidAttachmentTitleFlag ? ASDAC_FileNameRestriction.replace('{}',invalidFileNames.replace(',','')) : '');

    isAttachmentFileSizeLimitExceeded && this.errorMessage.push(isAttachmentFileSizeLimitExceeded ? (ASDAC_AttachmentFileSizeLimitExceededErrorMessage+' -'+fileSizeLimitExceededAttachmentNames.replace(',',''))+'. ' : '');

    if (totalFileSize > ASDAC_AttachmentsTotalFileSizeLimit && this._contentVersions.length > 1) {
      this.validity = false;
      this.errorMessage.push(ASDAC_AttachmentsTotalFileSizeLimitExceededErrorMessage);
    }
    return { isValid: this.validity, errorMessage: this.errorMessage.join('<br>') };  
  }
}