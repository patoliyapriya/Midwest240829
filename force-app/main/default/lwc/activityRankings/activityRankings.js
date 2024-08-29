import { LightningElement, track, wire } from 'lwc';
import getActivityRankings from'@salesforce/apex/SalesActivityCtrl.getRankings';
import buildUserHierarchy from'@salesforce/apex/SalesActivityCtrl.buildUserHierarchy';
import userId from '@salesforce/user/Id';
import { publish, MessageContext } from 'lightning/messageService';
import DASHBORAD_CHANNEL from "@salesforce/messageChannel/SelectedUser__c";

const columns = [
    { label: 'Sales Rep Name', fieldName: 'SalesRepName', hideDefaultActions: true }
];

export default class ActivityRankings extends LightningElement {
    @wire(MessageContext)
    MessageContext;

    columns = columns;
    @track topSalesRepByActivity = [];
    @track selectedValue = userId;
    @track optionData = [];
    @track options;
    title;
    year;
    year = new Date().getFullYear();
    title = this.year + " Activity Leaderboard";

    @wire(getActivityRankings) rankings(result) {    
        if(result.data) {
            this.topSalesRepByActivity = result.data;
        }
    }

    @wire(buildUserHierarchy, {salesRep: userId})
    wiredResult(result) { 
            var userDetails = result.data;
            
            for (var key in userDetails) {
                this.optionData.push({"label" : userDetails[key], 
                                        "value" : key });
            }
            var optionsInString = JSON.stringify(this.optionData);
            this.options = optionsInString;
            this.options = this.optionData.map( objPL => {
                return {
                    label: `${objPL.label}`,
                    value: `${objPL.value}`
                };
            });
    }
    
    handleChangeUser( event ) {
        //console.log('event.detail.value='+event.detail.value);
        var name = event.target.options.find(opt => opt.value === event.detail.value).label;
        //name = name.replace('_', '');
        //console.log('name of selected user=='+ name.replace('-', ''));
        const message = {
            newUserId: event.detail.value,
            newUserName : name
        }
        publish(this.MessageContext, DASHBORAD_CHANNEL, message);
        //console.log( 'New Value selected is ' + JSON.stringify( event.detail.value ) );   

    }

}