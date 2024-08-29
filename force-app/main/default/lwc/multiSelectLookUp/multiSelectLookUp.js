import { LightningElement, api, track } from 'lwc';
import retrieveRecords from '@salesforce/apex/MultiSelectLookupController.retrieveRecords';


let i=0;
export default class multiSelectLookUp extends LightningElement {
    
    @api recordId;
    @track globalSelectedItems = []; //holds all the selected checkbox items
    //start: following parameters to be passed from calling component
    @api preSelectedValues = [];
    //@api preSelectedValues = ["0013J000007aoIhQAI","0033J00000GmkOLQAZ"];
    @api labelName;
    @api index;
    @api objectLabel;
    @api objectApiName; // = 'Contact';
    @api fieldApiNames; // = 'Id,Name';
    @api filterFieldApiName;    // = 'Name';
    @api iconName;  // = 'standard:contact';
    @api compositeLabel;
    //end---->
    @track items = []; //holds all records retrieving from database
    @track selectedItems = []; //holds only selected checkbox items that is being displayed based on search

    //since values on checkbox deselection is difficult to track, so workaround to store previous values.
    //clicking on Done button, first previousSelectedItems items to be deleted and then selectedItems to be added into globalSelectedItems
    @track previousSelectedItems = []; 
    @track  value = [];  //this holds checkbox values (Ids) which will be shown as selected
    searchInput ='';    //captures the text to be searched from user input
    isDialogDisplay = false; //based on this flag dialog box will be displayed with checkbox items
    isDisplayMessage = false; //to show 'No records found' message

    
    connectedCallback(){
       console.log('in conncted call back');
       
       if (this.preSelectedValues != null && this.preSelectedValues.length > 0) {
           console.log('found pre-selected values');
           //retrieve records based on search input
            retrieveRecords({objectName: this.objectApiName,
                            fieldAPINames: this.fieldApiNames,
                            filterFieldAPIName: this.filterFieldApiName,
                            strInput: '',
                            preSelectedIds : this.preSelectedValues
                            })
            .then(result=>{ 
                this.items = []; //initialize the array before assigning values coming from apex
                this.value = [];
                this.previousSelectedItems = [];

                if(result.length>0){
                    console.log('found records='+result);
                    result.map(resElement=>{
                        //prepare items array using spread operator which will be used as checkbox options
                        if(this.objectApiName == 'Contact'){
                            this.compositeLabel = `${resElement.recordName} (${resElement.recordEmail}) - ${resElement.recordAccountName}`;
                        } else{
                            this.compositeLabel = `${resElement.recordName}`;
                        }
                        // this.compositeLabel = `${resElement.recordName} (${resElement.recordEmail}) - ${resElement.recordAccountName}`;
                        this.items = [...this.items,{value:resElement.recordId, 
                                                    label:this.compositeLabel}];
                        
                        /*since previously choosen items to be retained, so create value array for checkbox group.
                            This value will be directly assigned as checkbox value & will be displayed as checked.
                        */
                        this.globalSelectedItems.map(element =>{
                            if(element.value == resElement.recordId){
                                this.value.push(element.value);
                                this.previousSelectedItems.push(element);                      
                            }
                        });
                    });
                    //this.isDialogDisplay = true; //display dialog
                    //this.isDisplayMessage = false;
                    this.globalSelectedItems.push(...this.items);
                    console.log('preselected value are  ' , this.preSelectedValues);
                    
                    
                    //propagate event to parent component
                    const arrItems = this.globalSelectedItems;
                    const rowIndex = 0;
                    const evtCustomEvent = new CustomEvent('retrieve', { 
                            detail: {arrItems, rowIndex}
                        });
                    this.dispatchEvent(evtCustomEvent);

                } else{
                    //display No records found message
                    //this.isDialogDisplay = false;
                    //this.isDisplayMessage = true;                    
                }
            })
            .catch(error=>{
                this.error = error;
                this.items = undefined;
                this.isDialogDisplay = false;
                console.log('error in fetching preselected data ='+this.error );
            })            
        }
    } 



    //This method is called when user enters search input. It displays the data from database.
    onchangeSearchInput(event){
        this.searchInput = event.target.value;
        if(this.searchInput.trim().length <= 0) {
            this.searchInput = '*';
        }
        if(this.searchInput.trim().length>0){
            //retrieve records based on search input
            retrieveRecords({objectName: this.objectApiName,
                            fieldAPINames: this.fieldApiNames,
                            filterFieldAPIName: this.filterFieldApiName,
                            strInput: this.searchInput,
                            retrieveRecords : null
                            })
            .then(result=>{ 
                this.items = []; //initialize the array before assigning values coming from apex
                this.value = [];
                this.previousSelectedItems = [];

                if(result.length>0){
                    result.map(resElement=>{
                        //prepare items array using spread operator which will be used as checkbox options
                        if(this.objectApiName == 'Contact'){
                            this.compositeLabel = `${resElement.recordName} (${resElement.recordEmail}) - ${resElement.recordAccountName}`;
                        } else{
                            this.compositeLabel = `${resElement.recordName}`;
                        }
                        
                        this.items = [...this.items,{value:resElement.recordId, 
                                                    label:this.compositeLabel}];
                        
                        /*since previously choosen items to be retained, so create value array for checkbox group.
                            This value will be directly assigned as checkbox value & will be displayed as checked.
                        */
                        this.globalSelectedItems.map(element =>{
                            if(element.value == resElement.recordId){
                                this.value.push(element.value);
                                this.previousSelectedItems.push(element);                      
                            }
                        });
                    });
                    this.isDialogDisplay = true; //display dialog
                    this.isDisplayMessage = false;
                
                }
                else{
                    //display No records found message
                    this.isDialogDisplay = false;
                    this.isDisplayMessage = true;                    
                }
            })
            .catch(error=>{
                this.error = error;
                this.items = undefined;
                this.isDialogDisplay = false;
            })
        }else{
            this.isDialogDisplay = false;
        }  
        
        if(this.searchInput == '*') {
            this.searchInput = '';
        }
    }

    //This method is called during checkbox value change
   
    handleCheckboxChange(event){
        let selectItemTemp = event.detail.value;
        
        //all the chosen checkbox items will come as follows: selectItemTemp=0032v00002x7UE9AAM,0032v00002x7UEHAA2
        console.log(' handleCheckboxChange  value=', event.detail.value);  
   
        this.selectedItems = []; //it will hold only newly selected checkbox items.

        /* find the value in items array which has been prepared during database call
           and push the key/value inside selectedItems array           
        */
        selectItemTemp.map(p=>{            
            let arr = this.items.find(element => element.value == p);
            //arr = value: "0032v00002x7UEHAA2", label: "Arthur Song
            if(arr != undefined){
                this.selectedItems.push(arr);
                console.log('this.selectedItems='+this.selectedItems);
                console.log('this.selectedItems='+JSON.stringify(this.selectedItems));
            }
        });     
    }

    //this method removes the pill item
    handleRemoveRecord(event){        
        const removeItem = event.target.dataset.item; //"0032v00002x7UEHAA2"
        
        //this will prepare globalSelectedItems array excluding the item to be removed.
        this.globalSelectedItems = this.globalSelectedItems.filter(item => item.value  != removeItem);
        const arrItems = this.globalSelectedItems;
        const rowIndex = this.index;

        //initialize values again
        this.initializeValues();
        this.value =[]; 

        //propagate event to parent component
        const evtCustomEvent = new CustomEvent('remove', {   
            detail: {removeItem,arrItems,rowIndex}
            });
        this.dispatchEvent(evtCustomEvent);
    }

    //Done dialog button click event prepares globalSelectedItems which is used to display pills
    handleDoneClick(event){
        console.log('Inside handledoneClick: '+this.preSelectedValues);
        //remove previous selected items first as there could be changes in checkbox selection
        this.previousSelectedItems.map(p=>{
            this.globalSelectedItems = this.globalSelectedItems.filter(item => item.value != p.value);
        });
        console.log('After processing prev selected items: '+this.globalSelectedItems);
        console.log('Selected items: '+this.selectedItems);
        
        //now add newly selected items to the globalSelectedItems
        this.globalSelectedItems.push(...this.selectedItems);
        console.log('Global Selected items: '+this.globalSelectedItems);        
        const arrItems = this.globalSelectedItems;
        const rowIndex = this.index;
        //store current selection as previousSelectionItems
        this.previousSelectedItems = this.selectedItems;
        this.initializeValues();
        
        //propagate event to parent component
        const evtCustomEvent = new CustomEvent('retrieve', { 
            detail: {arrItems, rowIndex}
            });
        this.dispatchEvent(evtCustomEvent);
    }

    //Cancel button click hides the dialog
    handleCancelClick(event){
        this.initializeValues();
    }

    //this method initializes values after performing operations
    initializeValues(){
        this.searchInput = '';        
        this.isDialogDisplay = false;


    }
}