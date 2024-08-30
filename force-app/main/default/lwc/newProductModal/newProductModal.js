import { LightningElement , track ,wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from "lightning/navigation";
import getProductType from "@salesforce/apex/newProductModalController.getproductType";
import newProductSave from "@salesforce/apex/newProductModalController.newProductSave";
import MANUFACTURER_FIELD from '@salesforce/schema/Product2.Manufacturer__c';
import GROUPOFFICE_FIELD from '@salesforce/schema/Product2.Midwest_Group_Office__c';
import { ShowToastEvent } from "lightning/platformShowToastEvent";



const CLASS_CONSTANT = {
    HIDENEWPRODUCT : 'hidenewproduct',
}

export default class NewProductModal extends LightningElement {

    @track productName;
    @track ProductCode;
    @track manufacturer;
    @track productType;
    @track productSummary;
    @track isActive = true;
    @track productWeight;
    @track midwestGroupOffice=[];
    @track productDescription;
    @track manufacturerPickListValues;
    @track productTypePickListValues;
    @track groupOffice;
    @track isLoading = false;
    @track showProductType = false;

    allowedFormats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'align',
        'link',
        'image',
        'clean',
        'table',
        'header',
        'color',
        'background',
        'code',
        'code-block',
        'script',
        'blockquote',
        'direction',
    ];

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: MANUFACTURER_FIELD,
    })
    getPicklistValuesForManufacturer({ data, error }) {
        if (error) {
            console.log(error);
        } else if (data) {
            this.manufacturerPickListValues = [...data.values];
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: GROUPOFFICE_FIELD,
    })
    getPicklistValuesForMidwestOfficeGroup({ data, error }) {
        if (error) {
            console.log(error);
        } else if (data) {
            this.groupOffice = [...data.values];
        }
    }
    
    showNotification(titleText, messageText, variant) {
        const evt = new ShowToastEvent({
            title: titleText,
            message: messageText,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
   
      
  async handleSaveNewProduct(event){

        if(this.productName==null||this.productName=='' || this.manufacturer==null  || (this.showProductType==true && this.productType==null) || this.productSummary==null || this.productSummary=='' ||  this.productDescription==null || this.productDescription=='' || this.standardPrice==null || this.standardPrice==''){
            
            if(this.productName==null||this.productName==''){
                this.showNotification('Error', 'Enter Product Name', 'Error');
            }else if(this.manufacturer==null){
                this.showNotification('Error', 'Select Manufacturer From PickList', 'Error');
            }else if(this.showProductType==true && this.productType==null){
                this.showNotification('Error', 'Select Product Type From PickList', 'Error');
            }else if(this.productSummary==null || this.productSummary==''){
                this.showNotification('Error', 'Enter Product Summary', 'Error');
            }else if(this.productDescription==null || this.productDescription==''){
                this.showNotification('Error', 'Enter the Product Description', 'Error');
            }else {
                this.showNotification('Error', 'Enter the Standard Price ', 'Error');
            }
        }else{
        const newProductDetails = {
             productName : this.productName,
             ProductCode : this.ProductCode,
             manufacturer : this.manufacturer,
             productType : this.productType,
             productSummary : this.productSummary,
             productWeight : this.productWeight,
             isActive : this.isActive,
             midwestGroupOffice : this.midwestGroupOffice,
             productDescriptionescription : this.productDescription,
             standardPrice : this.standardPrice
        };

            await newProductSave({productDetail : JSON.stringify(newProductDetails)}); 
            this.showNotification('Saved', 'New Product Added Succesfully', 'success');
            this.isLoading=true;
            this.dispatchEvent(new CustomEvent(CLASS_CONSTANT.HIDENEWPRODUCT));
       }
    }



    handleProductName(event){
        this.productName = event.target.value;
    }

   async handleManufacturer(event){
        this.manufacturer = event.target.value;
        console.log('manufacturer : '+ this.manufacturer);
        
        let data = await getProductType({manufacturer:this.manufacturer});
        let options = [];
        data.forEach(element => {
            options.push({ label: element.Product_Type__c, value: element.Id  });
        });

        this.productTypePickListValues = options;
         
        if (this.productTypePickListValues !=null) {
            this.showProductType=true;
        }    
    }

    handleProductCode(event){
         this.ProductCode = event.target.value;
    }

    handleproductType(event){
        const productId= event.target.value;
        const selectedOption = this.productTypePickListValues.find(option => option.value === productId);

        this.productType = selectedOption ? selectedOption.label : '';
        console.log('productType:'+ this.productType);
        
         
    }

    handleProductSummary(event){
        this.productSummary = event.target.value;
    }

    handleActiveCheckbox(event){
        this.isActive = event.target.checked;
    }

    handleMidWestGroupOfficeChange(event){
        this.midwestGroupOffice = event.detail.value;
    }

    handleWeightChange(event){
        this.productWeight=event.target.value;
    }

    handlestandardPrice(event){
        this.standardPrice = event.target.value;
    }

    handleProductDescription(event){
       this.productDescription = event.target.value;
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent(CLASS_CONSTANT.HIDENEWPRODUCT));
    }
}