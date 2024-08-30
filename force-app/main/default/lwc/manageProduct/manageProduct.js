import { LightningElement, track, api, wire} from 'lwc';
import { publish, MessageContext} from 'lightning/messageService';
import QUOTE_TOOL_CHANNEL from '@salesforce/messageChannel/quoteTool__c';
import addProduct from "@salesforce/label/c.AddProduct";
import cancelLabel from "@salesforce/label/c.CancelButtonLabel";
import previousLabel from "@salesforce/label/c.Previous";
import nextLabel from "@salesforce/label/c.Next";
import continueLabel from "@salesforce/label/c.ContinueLabel";
import getProducts from "@salesforce/apex/ManageProductController.getProducts";
import getNextProducts from "@salesforce/apex/ManageProductController.getNextProducts";
import getPreviousProducts from "@salesforce/apex/ManageProductController.getPreviousProducts";
import getTotalProducts from "@salesforce/apex/ManageProductController.getTotalProducts";
import addLineItems from "@salesforce/apex/ManageProductController.addLineItems";

const CLASS_CONSTANT = {
    HIDDEN : 'hidden',
    SELECTALLROWS : 'selectAllRows',
    DESELECTALLROWS : 'deselectAllRows',
    ROWSELECT : 'rowSelect',
    ROWDESELECT : 'rowDeselect',
    DATAIDSEARCH : `[data-id="searchBar"]`,
    BOTTOMMARGIN : 'bottom_margin',
    HIDEADDPRODUCT : 'hideaddproduct',
    SHOWNEWPRODUCT :'shownewproduct'
};

const EVENT_CONSTANT = {
    PRODUCTADD : 'productAdder',
    SPINNERTOOGLE : 'spinnerToogle',
};

const MESSAGE_CONSTANT = {
    PRODUCTSUCCESS : 'Product Added Successfully',
    ERRORAPEX : 'Error calling Apex method:',
    };

export default class ManageProduct extends LightningElement {

    @api quoteDetails;
    @api subgroupId;
    @api isMarrs;

    @track productDetails;
    @track selectedData;
    @track preSelectedRows = [];
    @track isLoading = false;
    @track firstProductName;
    @track lastProductName;
    @track disablePrevious = true;
    @track disableNext = false;
    
    searchValue = '';
    delayTimeout;
    totalPages;
    currentProductIndex;
    allSelectedRows = [];

    @wire(MessageContext)
    messageContext;

    columns = [
        { label: 'Product Name', fieldName: 'name'},
        { label: 'Product Code', fieldName: 'code'},
        // { label: 'List Price', fieldName: 'listPrice'},
        { label: 'Product Summary', fieldName: 'productSummary'},
        { label: 'Manufacturer', fieldName: 'manufacturer'},
        { label: 'Product Type', fieldName: 'productType'},
    ];

    label = {addProduct,
        cancelLabel,
        continueLabel,
        previousLabel,
        nextLabel
    }

    connectedCallback() {
        document.body.style.overflow = CLASS_CONSTANT.HIDDEN;
        this.currentProductIndex = 1;
        this.publishHandler(true);
        this.loadProductWrapper();
    }

    async loadProductWrapper() { 
        try {
            this.isLoading = true;
            const totalProducts = await getTotalProducts({ office: this.quoteDetails.office, searchKeyword: this.searchValue});
            this.totalPages = Math.floor(totalProducts / 20);
            const hasRemainder = totalProducts % 20 !== 0;
            this.disablePrevious = true;
            this.disableNext = false;
            
            if(hasRemainder) {
                this.totalPages += 1;
            }
            
            if(this.totalPages <= 1) {
                this.disableNext = true;
            }

            const response = await getProducts({ office: this.quoteDetails.office, searchKeyword: this.searchValue});
            this.productDetails = response;

            if(this.allSelectedRows.length !==0) {
                this.afterPreviousorNextClick();
            }

            if (response.length > 0) {
                this.firstProductName = response[0].name;
                this.lastProductName = response[response.length - 1].name;
            }

            this.isLoading = false;
            this.publishHandler(false);
        } catch (error) {
            this.publishHandler(false);
            console.error(MESSAGE_CONSTANT.ERRORAPEX, error);
        }
    }

    async loadNextProductWrapper() {
        try {
            this.isLoading = true;
            const response = await getNextProducts({office: this.quoteDetails.office, lastProductName: this.lastProductName, searchKeyword: this.searchValue});
            this.productDetails = response;
            this.currentProductIndex += 1;
            this.disablePrevious = false;
            
            if(response.length > 0) {
                this.firstProductName = response[0].name;
                this.lastProductName = response[response.length - 1].name;
            }

            if(this.currentProductIndex >= this.totalPages) {
                this.disableNext = true;
            }

            if(this.allSelectedRows.length !==0) {
                this.afterPreviousorNextClick();
            }

            this.isLoading = false;
        } catch (error) {
            this.isLoading = false;
            console.error(MESSAGE_CONSTANT.ERRORAPEX, error);
        }
    }

    async loadPreviousProductWrapper() {
        try {
            this.isLoading = true;
            const response = await getPreviousProducts({office: this.quoteDetails.office, firstProductName: this.firstProductName, searchKeyword: this.searchValue});
            response.sort((a, b) => a.name.localeCompare(b.name));
            this.productDetails = response;
            this.currentProductIndex -= 1;
            this.disableNext = false;
            
            if (response.length > 0) {
                this.firstProductName = response[0].name;
                this.lastProductName = response[response.length - 1].name;
            }

            if(this.currentProductIndex <= 1){
                this.disablePrevious = true;
            }

            if(this.allSelectedRows.length !==0) {
                this.afterPreviousorNextClick();
            }
            
            this.isLoading = false;
        } catch (error) {
            this.isLoading = false;
            console.error(MESSAGE_CONSTANT.ERRORAPEX, error);
        }
    }

    handleRowSelection(event) {
        this.selectedData = event.detail.selectedRows;
        const currentID = event.detail.config.value;
        const selectedProductIds = this.selectedData.map(row => String(row.productId));
        
        switch (event.detail.config.action) {
            
            case CLASS_CONSTANT.SELECTALLROWS :
                for (let i = 0; i < this.selectedData.length; i++) {
                    if (!this.allSelectedRows.includes(this.selectedData[i].productId)) {
                        this.allSelectedRows.push({name: this.selectedData[i].name, productId: this.selectedData[i].productId});
                    }
                }
                break;
            
            case CLASS_CONSTANT.DESELECTALLROWS :
                this.allSelectedRows = this.allSelectedRows.filter(item => !this.preSelectedRows.includes(item.productId));
                break;
            
            case CLASS_CONSTANT.ROWSELECT :
                this.selectedData.forEach((selectedRow) => {
                    if (currentID === selectedRow.productId) {
                        this.allSelectedRows.push({name: selectedRow.name, productId: currentID});
                    }
                });
                break;
            
            case CLASS_CONSTANT.ROWDESELECT :
                const index = this.allSelectedRows.findIndex(item => item.productId === currentID);
                if (index !== -1) {
                    this.allSelectedRows.splice(index, 1);
                }
                break;

            default:
                break;
        }

        this.preSelectedRows = selectedProductIds;
        const searchBar = this.template.querySelector(CLASS_CONSTANT.DATAIDSEARCH);

        if (this.selectedData.length > 0) {
            searchBar.classList.remove(CLASS_CONSTANT.BOTTOMMARGIN);
        } else {
            searchBar.classList.add(CLASS_CONSTANT.BOTTOMMARGIN);
        }
    }

    handleRemovePill(event) {
        const productId = event.target.dataset.productId;

        if (productId) {
            const index = this.allSelectedRows.findIndex(item => item.productId === productId);
            
            if (index !== -1) {
                this.allSelectedRows.splice(index, 1);
            }

            this.selectedData = this.selectedData.filter(item => item.productId !== productId);
            this.preSelectedRows = this.selectedData.map(row => String(row.productId));
            const searchBar = this.template.querySelector(CLASS_CONSTANT.DATAIDSEARCH);
            
            if (this.selectedData.length === 0) {
                searchBar.classList.add(CLASS_CONSTANT.BOTTOMMARGIN);
            }
        }
    }

    publishHandler(isLoading) {
        const message = {
            messageSender : EVENT_CONSTANT.SPINNERTOOGLE,
            messageToSend : isLoading
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    disconnectedCallback() {
        document.body.style.overflow = '';
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent(CLASS_CONSTANT.HIDEADDPRODUCT));
    }

    handleNext() {
        this.loadNextProductWrapper();
    }

    getAllKeyFields() {
        let keyFields = [];
        this.productDetails.forEach(row => {
            keyFields.push(row.productId);
        });
        return keyFields;
    }

    getCommonValues(array1, array2) {
        return array1.filter(value => array2.includes(value));
    }

    afterPreviousorNextClick() {
        const allValues = this.getAllKeyFields();
        const productIdArray = this.allSelectedRows.map(row => row.productId);
        const commonValues = this.getCommonValues(allValues, productIdArray);
        this.preSelectedRows = commonValues;
    }

    handlePrevious() {
        this.loadPreviousProductWrapper();
    }

    handleSearch(event) {
        this.searchValue = event.target.value;
        clearTimeout(this.delayTimeout);

        this.delayTimeout = setTimeout(() => {
            this.loadProductWrapper();
        }, 3000);
    }

    handleContinue() {
        this.saveProductsToLineItem();
    }

    handleNewProductButton(){
        this.dispatchEvent(new CustomEvent(CLASS_CONSTANT.SHOWNEWPRODUCT));    
    }

    async saveProductsToLineItem() {
        try {
            this.isLoading = true;
            let productIdsArray = this.allSelectedRows.map(row => row.productId);
            if (productIdsArray.length === 0) {
                this.handleClose();
                return false;
            }
            await addLineItems({productIds: productIdsArray, subGroupId: this.subgroupId, quoteId: this.quoteDetails.quoteId, isMarrs: this.isMarrs});
            this.handleClose();
            this.publishAddProductComplete(MESSAGE_CONSTANT.PRODUCTSUCCESS);
            this.isLoading = false;
        } catch (error) {
            this.isLoading = false;
            console.error(MESSAGE_CONSTANT.ERRORAPEX, error);
        }
    }

    publishAddProductComplete(toastMessage) {
        const message = {
            messageSender : EVENT_CONSTANT.PRODUCTADD,
            messageToSend : toastMessage
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }
}