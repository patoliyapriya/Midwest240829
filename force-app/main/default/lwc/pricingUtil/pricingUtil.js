export  {calculateSubGroupPrice, calculateOnChangeSubGroupPrice, onQuantityChange, onListPriceChange, onMultiplierChange, onMarginPercentageChange, onSalePriceChange, calculateGroupPrice, calculateQuotePrice, calculateMarrsSubGroupPrice, calculateMarrsGroupPrice, calculateMarrsQuotePrice, onLbsChange}

function calculateExtendedCost(lineItem) {
    return parseFloat((lineItem.quantity * lineItem.unitCost).toFixed(2));
}

function calculateSalePrice(lineItem) {
    if(lineItem.extendedCost > 0) {
        if ((1 - (lineItem.marginPercentage/100)) == 0 ) {
            return 0;
        }
        return parseFloat((lineItem.extendedCost / (1 - (lineItem.marginPercentage/100))).toFixed(2));
    }
    else {
        return lineItem.salePrice;
    }
}

function calculateUnitCost(lineItem) {
    return parseFloat((lineItem.multiplier * lineItem.listPrice).toFixed(2));
}

function calculateMarginPercentage(lineItem) {
    if(lineItem.salePrice == 0) { 
        return 0;
    }
    return parseFloat((100 - ((lineItem.extendedCost / lineItem.salePrice) * 100)).toFixed(2));
}

function calculateTLbs(lineItem) {
    if(lineItem.lbs == 0) {
        return 0.00;
    }
    return parseFloat((lineItem.quantity * lineItem.lbs).toFixed(2));
}

function onQuantityChange(lineItem) {
    lineItem.extendedCost = calculateExtendedCost(lineItem);
    lineItem.salePrice = calculateSalePrice(lineItem);
    return lineItem;
}

function onListPriceChange(lineItem) {
    lineItem.unitCost = calculateUnitCost(lineItem);
    lineItem.extendedCost = calculateExtendedCost(lineItem);
    lineItem.salePrice = calculateSalePrice(lineItem);
    return lineItem;
}

function onMultiplierChange(lineItem) {
    lineItem.unitCost = calculateUnitCost(lineItem);
    lineItem.extendedCost = calculateExtendedCost(lineItem);
    lineItem.salePrice = calculateSalePrice(lineItem);
    return lineItem;
}

function onMarginPercentageChange(lineItem) {
    lineItem.salePrice = calculateSalePrice(lineItem);
    return lineItem;
}

function onSalePriceChange(lineItem) {
    lineItem.marginPercentage = calculateMarginPercentage(lineItem);
    return lineItem;
}

function onLbsChange(lineItem) {
    lineItem.tLbs = calculateTLbs(lineItem);
    return lineItem;
}

function calculateSubGroupPrice(subGroupDetails) {

    var subGroupTotal = 0;
    var subGroupExtendedCost = 0;
    var subGroupTotalHours = 0;
    var commissionAndRebates = 0;
    
    subGroupDetails.lineItemDetails.forEach((element) => {

        if (element.alternate) {
            return;
        }

        if (element.salePrice != null && element.salePrice != '') {
            subGroupTotal += element.salePrice;
        } else {
            subGroupTotal += 0;
        }
 
        if (element.extendedCost != null && element.extendedCost != '') {
            subGroupExtendedCost += element.extendedCost;
        } else {
            subGroupTotal += 0;
        }

        if(element.saleType === 'C/R' && element.cr != null && element.cr != '') {
            commissionAndRebates += element.cr;
        }

        if(element.saleType == 'LAB') {
            subGroupTotalHours += element.quantity;
        }

    });

    subGroupDetails.subGroupTotal = parseFloat(subGroupTotal.toFixed(2));
    subGroupDetails.subGroupExtendedCost = parseFloat(subGroupExtendedCost.toFixed(2));
    subGroupDetails.subGroupTotalHours = subGroupTotalHours;
    subGroupDetails.projectMargin = commissionAndRebates + (subGroupTotal-subGroupExtendedCost);
    subGroupDetails.projectMarginPercent = (subGroupDetails.projectMargin / subGroupTotal) * 100;

    return subGroupDetails;

}

function calculateOnChangeSubGroupPrice(subGroupDetails, valueChange, field) {

    var subGroupExtendedCost = 0;
    var commissionAndRebates = 0;

    subGroupDetails.lineItemDetails.forEach((element) => {
 
        if (element.extendedCost != null && element.extendedCost != '') {
            subGroupExtendedCost += element.extendedCost;
        }
    
        if(element.saleType === 'C/R' && element.cr != null && element.cr != '') {
            commissionAndRebates += element.cr;
        }
    
    });

    if(field === 'subGroupTotal') {
        var changeSubGroupTotal = valueChange;
        
    
        subGroupDetails.subGroupTotal = changeSubGroupTotal;
        subGroupDetails.subGroupExtendedCost = parseFloat(subGroupExtendedCost.toFixed(2));
        subGroupDetails.projectMargin = parseFloat(commissionAndRebates + (changeSubGroupTotal-subGroupExtendedCost)).toFixed(2);
        subGroupDetails.projectMarginPercent = (subGroupDetails.projectMargin / changeSubGroupTotal) * 100;
    
        return subGroupDetails;
    }

    else if(field === 'projectMargin') {
        var changeProjectMargin = parseFloat(valueChange);

        subGroupDetails.subGroupExtendedCost = parseFloat(subGroupExtendedCost.toFixed(2));
        subGroupDetails.subGroupTotal = changeProjectMargin + subGroupDetails.subGroupExtendedCost - commissionAndRebates;
        subGroupDetails.projectMargin = changeProjectMargin;
        subGroupDetails.projectMarginPercent = (changeProjectMargin / subGroupDetails.subGroupTotal) * 100;
    
        return subGroupDetails;

    }
    else {
        var changeProjectMarginPercent = parseFloat(valueChange);

        var devider = (1 - (changeProjectMarginPercent)/100);
        subGroupDetails.subGroupExtendedCost = parseFloat(subGroupExtendedCost.toFixed(2));
        subGroupDetails.subGroupTotal = (subGroupDetails.subGroupExtendedCost - commissionAndRebates)/devider;
        subGroupDetails.projectMargin = parseFloat(commissionAndRebates + (subGroupDetails.subGroupTotal-subGroupDetails.subGroupExtendedCost)).toFixed(2);
        subGroupDetails.projectMarginPercent = changeProjectMarginPercent;

        return subGroupDetails;
    }   

}

function calculateMarrsSubGroupPrice(subGroupDetails) {

    var subGroupTotal = 0;
    subGroupDetails.lineItemDetails.forEach((element) => {

        if (element.salePrice != null && element.salePrice != '') {
            subGroupTotal += element.salePrice;
        } else {
            subGroupTotal += 0;
        }

    });
    subGroupDetails.subGroupTotal = parseFloat(subGroupTotal.toFixed(2));
    return subGroupDetails;

}

function calculateGroupPrice(groupDetails) {
    var groupTotal = 0;
    var groupExtendedCost = 0;
    var groupTotalHours = 0;

    groupDetails.subGroupDetails.forEach((element) => {
        if(element.alternate) {
            return;
        }

        if(element.subGroupTotal != null && element.subGroupTotal != '') {
            groupTotal += element.subGroupTotal;
        }
 
        if(element.subGroupExtendedCost != null && element.subGroupExtendedCost != '') {
            groupExtendedCost += element.subGroupExtendedCost;
        }

        groupTotalHours += element.subGroupTotalHours;
    });

    groupDetails.groupTotal = groupTotal;
    groupDetails.groupExtendedCost = groupExtendedCost;
    groupDetails.totalHours = groupTotalHours;

    return groupDetails;
}

function calculateMarrsGroupPrice(groupDetails) {
    var groupTotal = 0;

    groupDetails.subGroupDetails.forEach((element) => {
    
        if(element.subGroupTotal != null && element.subGroupTotal != '') {
            groupTotal += element.subGroupTotal;
        }
    });

    groupDetails.groupTotal = groupTotal;


    return groupDetails;
}

function calculateQuotePrice(cartWrapper) {
    var extendedCost = 0;
    var directSellPrice = 0;
    var buyResellPrice = 0;
    var buyResellMargin = 0;
    var buyResellMarginPercent = 0;
    var sellPrice = 0;
    var buyResellExtendedCost = 0;
    var commissionAndRebates = 0;
    var projectMargin = 0;
    var projectMarginPercent = 0;

    cartWrapper.groupDetails.forEach((group) => {   
        if(group.alternate) {
            return;
        }
        if(group.groupExtendedCost != null && group.groupExtendedCost != '') {
            extendedCost += group.groupExtendedCost;
        }
        if(group.groupTotal != null && group.groupTotal != '') {
            sellPrice += group.groupTotal;
        }

        group.subGroupDetails.forEach((subGroup) => {
            if(subGroup.alternate) {
                return;
            }

            subGroup.lineItemDetails.forEach((lineItem) => {
                if(lineItem.alternate) {
                    return;
                }
                if(lineItem.saleType === 'D/S' && lineItem.salePrice != null && lineItem.salePrice != '') {
                    directSellPrice += lineItem.salePrice;
                }
                if(lineItem.saleType === 'B/R' || lineItem.saleType === 'LAB' || lineItem.saleType === 'P/T') {
                    if(lineItem.salePrice != null && lineItem.salePrice != '') {
                        buyResellPrice += lineItem.salePrice;
                    }
                    if(lineItem.extendedCost != null && lineItem.extendedCost != '') {
                        buyResellExtendedCost += lineItem.extendedCost;
                    }
                }
                if(lineItem.saleType === 'C/R' && lineItem.cr != null && lineItem.cr != '') {
                    commissionAndRebates += lineItem.cr;
                }
            });      
        });
    }); 

    buyResellMargin = buyResellPrice - buyResellExtendedCost;

    if(buyResellPrice != 0) {
        buyResellMarginPercent = (buyResellMargin/buyResellPrice) * 100;
    }

    projectMargin = commissionAndRebates + buyResellMargin;

    if(sellPrice != 0) {
        projectMarginPercent = (projectMargin / sellPrice) * 100;
    }

    cartWrapper.quoteDetails.extendedCost = extendedCost;
    cartWrapper.quoteDetails.sellPrice = sellPrice;
    cartWrapper.quoteDetails.directSellPrice = directSellPrice;
    cartWrapper.quoteDetails.buyResellPrice = buyResellPrice;
    cartWrapper.quoteDetails.buyResellMargin = buyResellMargin;
    cartWrapper.quoteDetails.buyResellMarginPercent = buyResellMarginPercent;
    cartWrapper.quoteDetails.commissionAndRebates = commissionAndRebates;
    cartWrapper.quoteDetails.projectMargin = projectMargin;
    cartWrapper.quoteDetails.projectMarginPercent = projectMarginPercent;

    return cartWrapper;
}

function calculateMarrsQuotePrice(cartWrapper) {
    var sellPrice = 0;

    cartWrapper.groupDetails.forEach((group) => {   

        if(group.groupTotal != null && group.groupTotal != '') {
            sellPrice += group.groupTotal;
        }

    }); 

    cartWrapper.quoteDetails.sellPrice = sellPrice;

    return cartWrapper;
}