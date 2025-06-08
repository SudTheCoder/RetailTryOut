import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import ASDAC_WebformAttachmentUploadDisclaimerText from "@salesforce/label/c.ASDAC_WebformAttachmentUploadDisclaimerText";

export default class AsdacWebformAttachmentUploaderCmp extends LightningElement {
    @api deleteButtonLabel;
    @api attachmentModalText;
    @api cancelButtonLabel;
    @api uploadAttachmentLabel;
    imageSrc;
    imageTitle;
    fileData;
    showDeleteAttachmentModal;
    _contentVersions = [];

    get attachmentUploadDisclaimer(){
        return ASDAC_WebformAttachmentUploadDisclaimerText;
    }

    @api
    get files() {
        return this._contentVersions;
    }

    set files(contentVersions) {
        this._contentVersions = contentVersions;
        this.attachments = contentVersions.map((cv) => ({ name: cv.Title, contentVersion: cv }));
    }

    openfileUpload(event) {
        const imageFiles = (event.detail && event.detail.isJest)?event.detail.files:[...event.target.files];
        if (imageFiles.length > 0) {
            this.imageSrc = URL.createObjectURL(imageFiles[0]);
            this.imageTitle = imageFiles[0].name;
            this.fileData = true;
            this.handleAttachments(imageFiles);
        }
        event.target.value = null;
    }
    openDeleteModal() {
        this.showDeleteAttachmentModal = true;
    }
    handleAttachmentModalEvent(event) {
        let attachMentToBeDeleted = event.detail.deleteAttachment;
        if (attachMentToBeDeleted) {
            this.imageSrc = URL.revokeObjectURL(this.imageSrc);
            this.fileData = false;
        }
        this.showDeleteAttachmentModal = false;
    }
    uploadFile(event) {
        event.preventDefault();
        this.template.querySelector('.file-input').click();
    }

    async handleAttachments(attachment) {
        this.attachments = attachment;
        try {
            const files = await Promise.all(
                this.attachments.map(async function (file) {
                    if (file.contentVersion) {
                        return file.contentVersion;
                    }
                    return {
                        FirstPublishLocationId: "",
                        ContentLocation: "S",
                        PathOnClient: file.name,
                        Title: file.name,
                        VersionData: window.btoa(new Uint8Array(await file.arrayBuffer()).reduce((data, byte) => data + String.fromCharCode(byte), ""))
                    };
                })
            );
            this._contentVersions = files;
            const attributeChangeEvent = new FlowAttributeChangeEvent("files", files);
            this.dispatchEvent(attributeChangeEvent);
        } catch (error) {
            console.error(error);
        }
    }
}