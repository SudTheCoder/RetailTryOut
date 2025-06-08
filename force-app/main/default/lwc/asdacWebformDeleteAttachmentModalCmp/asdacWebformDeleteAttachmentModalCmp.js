import { LightningElement ,api} from 'lwc';

export default class AsdacWebformDeleteAttachmentModalCmp extends LightningElement {
@api showModal;
@api deleteButtonLabel;
@api attachmentModalText;
@api cancelButtonLabel;

deleteAttachment(){
    this.fireEvent(true);
}

closeModal(){
    this.fireEvent(false);
}
fireEvent(attachmentToBeDeleted){
    this.dispatchEvent(new CustomEvent('attachmentmodalaction', {
        detail: {deleteAttachment:attachmentToBeDeleted}
    }));
}
}