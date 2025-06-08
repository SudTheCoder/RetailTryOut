import { LightningElement, api } from 'lwc';

export default class AsdacQuickTipCmp extends LightningElement {
    @api title = '';
    @api quickTip='';

    get showQuickTip() {
        return this.quickTip?.trim().length;
    }

    renderedCallback() {
        if (this.quickTip !== undefined) this.renderRichTextWithLinks();
    }

    renderRichTextWithLinks() {
        const container = this.template.querySelector('.quickTip');
        container.innerHTML = this.quickTip;
        // Add click event listeners to the hyperlinks and handle them
        const links = container.querySelectorAll('a');
        links.forEach(link => {
            link.addEventListener('click', this.handleHyperlinkClick.bind(this));
        });
    }

    handleHyperlinkClick(event) {
        event.preventDefault();
        this.dispatchEvent(new CustomEvent('quicktiplinkclick', { detail: event }));
    }
}