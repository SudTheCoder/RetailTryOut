import { LightningElement, api, track } from "lwc";

export default class AsdacWebformAddProductItemCmp extends LightningElement {
    @api maxProducts = 10;
    @api maxProductQuantity = 999;
    @api orderId;
    @api productType;
    @api orderTotal;
    @track _products = [];

    productName;
    productQuantity;
    securityOnTagItemQuantity;
    brandType;
    isSecurityonTagItemReturned;
    asdaLoveMeFlag = false;
    asdaLovedProductMark = 'Asda Try Me, Love Me product';

    itemPrice = 0.00;
    itemRefundReturned;
    itemReasonForReturn;
    itemReturnCode;
    itemLostReturnsReceipt = false;
    label;

    connectedCallback() {
        this.label = {
            productName: this.productType === 'Check status of refund request' ? 'Item name' : 'Product name',
            productQuantity: this.productType === 'Check status of refund request' ? 'Item quantity' : 'Product size',
            brandType: "Is it an Asda product or another brand?",
            asdaLoveMeFlag: "Asda Try Me, Love Me product",
            isSecurityonTagItemReturned: "Have you returned the product to a store or driver?",
            addItemButtonLabel: "Add item",
            securityOnTagItemQuantity: "Quantity",
            itemPrice: "Item price",
            itemRefundReturned: "How did you return your item?",
            itemReasonForReturn: "Reason for return",
            itemReturnCode: "Return code (from your returns receipt)",
            itemLostReturnsReceipt: "I lost my returns receipt"
        };
    }

    returnItemOptions = [
        { label: 'Handed the item(s) back to the driver', value: 'Handed the item(s) back to the driver' },
        { label: 'Requested through self serve online', value: 'Requested through self serve online' },
        { label: 'Spoke to the Asda Contact Centre', value: 'Spoke to the Asda Contact Centre' },

    ];

    get isGeorgeProductScreen() {

        return this.productType === 'George.com' || this.productType === 'Security tag on item';
    }
    get showCommonElement() {
        return this.isGeorgeProductScreen || this.isRefundRequestScreen;
    }
    get showBrandProductScreen() {

        return this.productType === 'In store' || this.productType === 'Online groceries';
    }
    get isSecurityonTagItemScreen() {
        return this.productType === 'Security tag on item';
    }
    get isRefundRequestScreen() {

        return this.productType === 'Check status of refund request';
    }
    get quantityValidation() {
        return `Product Quantity can't be greater than ${this.maxProductQuantity} or less than 1`;
    }
    get disableAddItem() {
        return this._products.length >= this.maxProducts;
    }
    get orderDetail() {
        return `Order ${this.orderId}`;
    }
    get showASDAProductDetail() {
        return this.brandType === 'Asda product';
    }

    get brandOptions() {
        return [
            { label: 'Asda product', value: 'Asda product' },
            { label: 'Other brand', value: 'Other brand' },
        ];
    }
    get securityOnTagItemOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    @api
    get products() {
        const products = this._products.map(({ id,name, quantity, brandType, itemRefundReturned, isSecurityonTagItemReturned, asdaLoveMeFlag, itemLostReturnsReceipt }) => ({ id,name, quantity, brandType, itemRefundReturned, isSecurityonTagItemReturned, asdaLoveMeFlag, itemLostReturnsReceipt }));
        return JSON.stringify(products);
    }

    set products(productsJson) {
        const products = JSON.parse(productsJson);
        this._products = products;
    }

    @api
    get isProductReturned() {
        return !this._products.filter(item => item.isSecurityonTagItemReturned === false).length > 0;
    }


    handleChange(event) {
        const key = event.target.name;
        this[key] = event.detail.value;

        if (event.target.type === "number") {
            this[key] = Number(event.detail.value);
        }
        else if (event.target.type === "checkbox") {
            this[key] = event.detail.checked;
        }

    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('lightning-input,lightning-radio-group');
        inputFields.forEach(inputField => {
            if (inputField.type === 'text') {
                if (!inputField.value || !inputField.value.trim()) {
                    inputField.value = "";
                    setTimeout(() => {
                        inputField.reportValidity();
                    }, 50);
                    isValid = false;
                }
            }
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    addItem() {
        if (this.disableAddItem) {
            return;
        }
        if (this.isInputValid()) {
            const product = {
                id: window.crypto.randomUUID(),
                name: this.productName,
                quantity: this.productQuantity,
                brandType: this.brandType,
                isSecurityonTagItemReturned: this.isSecurityonTagItemReturned === 'Yes',
                ordertotal: this.orderTotal,
                itemPrice: this.itemPrice,
                itemRefundReturned: this.itemRefundReturned,
                itemReasonForReturn: this.itemReasonForReturn,
                itemReturnCode: this.itemReturnCode,
                itemLostReturnsReceipt: this.itemLostReturnsReceipt,
                securityOnTagItemQuantity: this.securityOnTagItemQuantity,
                asdaLoveMeFlag: (this.brandType === 'Asda product') && this.asdaLoveMeFlag
            };


            if (!this._products.filter((e) => e.name === product.name).length > 0) {
                this._products.push(product);
            }
            this.handleReset();
        }
    }

    @api validate() {
        if (this._products.length === 0) {
            return { isValid: false, errorMessage: "Please add atleast one item!" };
        }
        for (let product of this._products) {
            if (this.productType === 'George.com' && !(product.name && product.quantity > 0 && product.quantity <= this.maxProductQuantity)) {
                return { isValid: false, errorMessage: "Please enter required details" };
            }
        }
        return { isValid: true };
    }

    removeProduct(event) {
        const index = event.target.dataset.index;
        this._products.splice(index, 1);
    }

    handleReset() {
        this.productName = "";
        this.productQuantity = "";
        this.securityOnTagItemQuantity = "";
        this.brandType = "";
        this.isSecurityonTagItemReturned = "";
        this.asdaLoveMeFlag = false;
        this.itemPrice = 0.00;
        this.itemRefundReturned = "";
        this.itemReasonForReturn = "";
        this.itemReturnCode = "";
        this.itemLostReturnsReceipt = false;
        window.scrollTo({ left: 0, top: 0 });
    }

}