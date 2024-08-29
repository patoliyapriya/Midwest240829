function VerifyCalculation(){
    for(var i=0, iLen=-1; i>iLen; i++){
        var hidGrandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':hidGrandTotalGroup');
        
        if(hidGrandTotalGroup == null){
            break;
        }
        
        for(var j=0, jLen=-1; j>jLen; j++){
            var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':rptProductSubGroup:' + j + ':hidGrandTotalSubGroup');
            
            if(hidGrandTotalSubGroup == null){
                break;
            }
            
            for(var k=0, kLen=-1; k>kLen; k++){
                var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':rptProductSubGroup:' + j + ':rptProductSelected:' + k + ':';
    
                var txtQuantity = document.getElementById(tblAttributs + 'txtQuantity');
                
                if(txtQuantity == null){
                    break;
                }
                else{
                    CalculatePrice(i,j,k+1);
                }
            }
            
        }
        
    }
    alert('Calcution Data Validation successful.');
    return false;
}

function CalculateMarginPercentage(groupIndex, subGroupIndex, rowIndex) {
    var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + (rowIndex - 1) + ':';
    var textBoxSalesPrice = document.getElementById(tblAttributs + 'textBoxSalesPrice');
    var hidExtendedCost = document.getElementById(tblAttributs + 'hidExtendedCost');
    var txtMarginPercentage = document.getElementById(tblAttributs + 'txtMarginPercentage');

    var salePrice = textBoxSalesPrice.value;
    var extendedCost = hidExtendedCost.value;
    
    if(salePrice != null && salePrice != '' && salePrice != 0 && extendedCost != null && extendedCost != '') {
        var marginPercentage = 100 - ((extendedCost/salePrice)*100);
        txtMarginPercentage.value = marginPercentage.toFixed(2);
    } else {
        txtMarginPercentage.value = 0;
    }

}

function ChangeSalePrice(groupIndex, subGroupIndex, rowIndex){
    
    var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + (rowIndex - 1) + ':';
    
    var txtSalesPrice = document.getElementById(tblAttributs + 'txtSalesPrice');
    var textBoxSalesPrice = document.getElementById(tblAttributs + 'textBoxSalesPrice');
    
    var hidSalesPrice = document.getElementById(tblAttributs + 'hidSalesPrice');
    
    hidSalesPrice.value = parseFloat(textBoxSalesPrice.value);
    txtSalesPrice.innerText = '$' + hidSalesPrice.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    var salesType = document.getElementById(tblAttributs + 'txtSaleType');

    if(salesType.value != 'P/T') {
        CalculateMarginPercentage(groupIndex, subGroupIndex, rowIndex);
    }
    
    //calculateSalePriceOverride(groupIndex, subGroupIndex, rowIndex);
    calculateSubGroupPrice(groupIndex, subGroupIndex, rowIndex);
    calculateGroupPrice(groupIndex);
}
        
function CalculatePrice(groupIndex, subGroupIndex, rowIndex){

    var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + (rowIndex - 1) + ':';
    
    var txtQuantity = document.getElementById(tblAttributs + 'txtQuantity');
    var txtLBS = document.getElementById(tblAttributs + 'txtLBS');
    var txtTLBS = document.getElementById(tblAttributs + 'txtTLBS');
    var txtListPrice = document.getElementById(tblAttributs + 'txtListPrice');
    var txtMultiplier = document.getElementById(tblAttributs + 'txtMultiplier');
    var txtUnitCost = document.getElementById(tblAttributs + 'txtUnitCost');
    //var txtFreight = document.getElementById(tblAttributs + 'txtFreight');
    var txtExtendedCost = document.getElementById(tblAttributs + 'txtExtendedCost');
    var txtSalesPrice = document.getElementById(tblAttributs + 'txtSalesPrice');
    var textBoxSalesPrice = document.getElementById(tblAttributs + 'textBoxSalesPrice');
    var txtMarginPercentage = document.getElementById(tblAttributs + 'txtMarginPercentage');
    //var salesType = document.getElementById(tblAttributs + 'txtSaleType');
    var hidTLBS = document.getElementById(tblAttributs + 'hidTLBS');
    var hidUnitCost = document.getElementById(tblAttributs + 'hidUnitCost');
    var hidExtendedCost = document.getElementById(tblAttributs + 'hidExtendedCost');
    var hidSalesPrice = document.getElementById(tblAttributs + 'hidSalesPrice');
    //var hidFreightOverride = document.getElementById(tblAttributs + 'hidFreightOverride');
    var hidSalePriceOverride = document.getElementById(tblAttributs + 'hidSalePriceOverride');
    
    hidTLBS.value = (txtQuantity.value * txtLBS.value).toFixed(2);
    txtTLBS.innerText = hidTLBS.value;
    hidUnitCost.value = (txtMultiplier.value * txtListPrice.value).toFixed(2);
    txtUnitCost.innerText = '$' + hidUnitCost.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    /*
    if(hidFreightOverride.value != 'true'){
        txtFreight.value = (hidTLBS.value * 0.35).toFixed(2);
    }
    
    if(txtFreight.value != null && txtFreight.value != ''){
        hidExtendedCost.value = ((hidUnitCost.value * txtQuantity.value) + parseFloat(txtFreight.value)).toFixed(2);
    }
    else{
        hidExtendedCost.value = (hidUnitCost.value * txtQuantity.value).toFixed(2);
    }
    */
    hidExtendedCost.value = (hidUnitCost.value * txtQuantity.value).toFixed(2);

    txtExtendedCost.innerText = '$' + hidExtendedCost.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    if(hidSalePriceOverride.value != 'true' && hidExtendedCost.value > 0){
        hidSalesPrice.value = (hidExtendedCost.value/(1-(txtMarginPercentage.value/100))).toFixed(2);
        textBoxSalesPrice.value = parseFloat(hidSalesPrice.value);
    }
    
    //textBoxSalesPrice.value = hidSalesPrice.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    txtSalesPrice.innerText = '$' + hidSalesPrice.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    //textBoxSalesPrice.value = parseFloat(hidSalesPrice.value);
    //txtSalesPrice.innerText = 
    
    calculateSubGroupPrice(groupIndex, subGroupIndex, rowIndex);
    calculateGroupPrice(groupIndex);
}

function calculateSubGroupPrice(groupIndex, subGroupIndex, rowIndex){
    
    var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:';
    var grandTotal = 0;
    var grandTotalExtendedCost = 0;
    var quantityGrandTotal = 0;
    //var freightTotal = 0;
    
    for(var i=0, iLen=-1; i>iLen; i++){
        var hidSalesPrice = document.getElementById(tblAttributs + i + ':hidSalesPrice');
        var hidExtendedCost = document.getElementById(tblAttributs + i + ':hidExtendedCost');
        
        var txtQuantity = document.getElementById(tblAttributs + i + ':txtQuantity');
        var salesType = document.getElementById(tblAttributs + i + ':txtSaleType');
        //var txtFreight = document.getElementById(tblAttributs + i + ':txtFreight');
        var textBoxSalesPrice = document.getElementById(tblAttributs + i + ':textBoxSalesPrice');
        
        if(txtQuantity == null){
            break;
        }
        
        var isAlternateLineItem = document.getElementById(tblAttributs + i + ':checkAlternateQL');
        if(isAlternateLineItem.checked) {
            continue;
        }

        if(salesType.value == 'P/T' && textBoxSalesPrice != null && textBoxSalesPrice.value != null && textBoxSalesPrice.value != ''){
               grandTotal = grandTotal + parseFloat(textBoxSalesPrice.value);
           }
           else{
               if(hidSalesPrice.value != null && hidSalesPrice.value != ''){
                   grandTotal = grandTotal + parseFloat(hidSalesPrice.value);
               }
           }
           
        if(hidExtendedCost.value != null && hidExtendedCost.value != ''){
            grandTotalExtendedCost = grandTotalExtendedCost + parseFloat(hidExtendedCost.value);
        }
        /*
        if(txtFreight.value != null && txtFreight.value != ''){
            freightTotal = freightTotal + parseFloat(txtFreight.value);
        }
        */
        if(salesType.value == 'LAB'){
            quantityGrandTotal = quantityGrandTotal + parseInt(txtQuantity.value);
        }
        
    }
    
    var grandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':txtGrandTotalSubGroup');
    var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':hidGrandTotalSubGroup');
    
    var txtQuantityTotal = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':txtQuantityTotal');
    var hidQuantityTotal = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':hidQuantityTotal');
    
    //var grandTotalFreight = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':txtGrandTotalFreight');
    //var hidGrandTotalFreight = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':hidGrandTotalFreight');
    
    hidGrandTotalSubGroup.value = grandTotal.toFixed(2);
    grandTotalSubGroup.innerText = '$' + hidGrandTotalSubGroup.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    //hidGrandTotalFreight.value = freightTotal.toFixed(2);
    //grandTotalFreight.innerText = '$' + hidGrandTotalFreight.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    var grandTotalExtendedCostElement = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':txtGrandTotalExtendedCost');
    var hidGrandTotalExtendedCostElement = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':hidGrandTotalExtendedCost');
    
    hidGrandTotalExtendedCostElement.value = grandTotalExtendedCost.toFixed(2);
    grandTotalExtendedCostElement.innerText = '$' + hidGrandTotalExtendedCostElement.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    txtQuantityTotal.innerText = hidQuantityTotal.value = quantityGrandTotal;
    
}

function calculateGroupPrice(groupIndex){
    
    var grandTotal = 0;
    var grandTotalExtendedCost = 0;
    var grandTotalQuantity = 0;
    //var grandTotalFreight = 0;
    
    for(var i=0, iLen=-1; i>iLen; i++){
        
        var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + i + ':hidGrandTotalSubGroup');
        var hidGrandTotalExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + i + ':hidGrandTotalExtendedCost');
        var hidQuantityTotal = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + i + ':hidQuantityTotal');
        //var hidFreightTotal = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + i + ':hidGrandTotalFreight');
        
        if(hidGrandTotalSubGroup == null){
            break;
        }

        var isAlternate = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + i + ':subGroupAlternate');
        if(isAlternate.checked) {
            continue;
        }
        
        if(hidQuantityTotal.value != null && hidQuantityTotal.value != ''){
            grandTotalQuantity = grandTotalQuantity + parseFloat(hidQuantityTotal.value);
        }
        if(hidGrandTotalSubGroup.value != null && hidGrandTotalSubGroup.value != ''){
            grandTotal = grandTotal + parseFloat(hidGrandTotalSubGroup.value);
        }
        if(hidGrandTotalExtendedCost.value != null && hidGrandTotalExtendedCost.value != ''){
            grandTotalExtendedCost = grandTotalExtendedCost + parseFloat(hidGrandTotalExtendedCost.value);
        }
        /*
        if(hidFreightTotal.value != null && hidFreightTotal.value != ''){
            grandTotalFreight = grandTotalFreight + parseFloat(hidFreightTotal.value);
        }
        */
    }
    
    var txtGrandTotalQuantity = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':txtGrandTotalQuantity');
    var hidGrandTotalQuantity = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':hidGrandTotalQuantity');
    
    txtGrandTotalQuantity.innerText = hidGrandTotalQuantity.value = grandTotalQuantity; 
    
    var grandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':txtGrandTotalGroup');
    var hidGrandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':hidGrandTotalGroup');
    
    hidGrandTotalGroup.value = grandTotal.toFixed(2);
    grandTotalGroup.innerText = '$' + hidGrandTotalGroup.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    var txtTotalGroupExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':txtTotalGroupExtendedCost');
    var hidTotalGroupExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':hidTotalGroupExtendedCost');
    
    hidTotalGroupExtendedCost.value = grandTotalExtendedCost.toFixed(2);
    txtTotalGroupExtendedCost.innerText = '$' + hidTotalGroupExtendedCost.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    //var txtTotalGroupFreight = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':txtTotalGroupFreight');
    //var hidTotalGroupFreight = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':hidTotalGroupFreight');
    
    //hidTotalGroupFreight.value = grandTotalFreight.toFixed(2);
    //txtTotalGroupFreight.innerText = '$' + hidTotalGroupFreight.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    calculateGrandTotalsExtendedCostAndBaseBid();
}

function calculateGrandTotalsExtendedCostAndBaseBid(){

    var totalBaseBid = 0;
    var totalExtendedCost = 0;
    var totalQuantityQuote = 0;

    for(var i=0, iLen=-1; i>iLen; i++) {
        
        var hidGrandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':hidGrandTotalGroup');

        if(hidGrandTotalGroup == null){
            break;
        }

        //var isAlternate = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':parentGroupCheckBox');
        //if(isAlternate.checked) {
            //continue;
        //}

        for(var j=0, jLen=-1; j>jLen; j++) {
                    
            var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ i + ':rptProductSubGroup:' + j + ':hidGrandTotalSubGroup');
            var hidGrandTotalExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ i + ':rptProductSubGroup:' + j + ':hidGrandTotalExtendedCost');
        
            if(hidGrandTotalSubGroup == null){
                break;
            }
            
            var isAlternate = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':rptProductSubGroup:' + j + ':subGroupAlternate');
            if(isAlternate.checked) {
                continue;
            }

            if(hidGrandTotalSubGroup.value != null && hidGrandTotalSubGroup.value != ''){
                totalBaseBid = totalBaseBid + parseFloat(hidGrandTotalSubGroup.value);
            }
            if(hidGrandTotalExtendedCost.value != null && hidGrandTotalExtendedCost.value != ''){
                totalExtendedCost = totalExtendedCost + parseFloat(hidGrandTotalExtendedCost.value);
            }

        }

        var txtTotalBaseBidTotal = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:txtTotalBaseBidTotal');
        var hidTotalBaseBidTotal = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalBaseBidTotal');
        
        hidTotalBaseBidTotal.value = totalBaseBid.toFixed(2);
        txtTotalBaseBidTotal.innerText = '$' + hidTotalBaseBidTotal.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
        
        var txtTotalExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:txtTotalExtendedCost');
        var hidTotalExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalExtendedCost');
        
        hidTotalExtendedCost.value = totalExtendedCost.toFixed(2);
        txtTotalExtendedCost.innerText = '$' + hidTotalExtendedCost.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
        /*
        var txtTotalBaseBidTotal = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:txtQuantityTotalQuote');
        var hidTotalBaseBidTotal = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidQuantityTotalQuote');
        
        txtTotalBaseBidTotal.innerText = hidTotalBaseBidTotal.value = totalQuantityQuote;
        */
        calculateTotals();

    }

    /*
    var totalBaseBid = 0;
    var totalExtendedCost = 0;
    var totalQuantityQuote = 0;
    
    for(var i=0, iLen=-1; i>iLen; i++) {
        
        var hidGrandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':hidGrandTotalGroup');
        var hidTotalGroupExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':hidTotalGroupExtendedCost');
        var hidGrandTotalQuantity = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':hidGrandTotalQuantity');
        
        if(hidGrandTotalGroup == null){
            break;
        }

        var isAlternate = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':parentGroupCheckBox');
        if(isAlternate.checked) {
            continue;
        }

        if(hidGrandTotalQuantity.value != null && hidGrandTotalQuantity.value != ''){
            totalQuantityQuote = totalQuantityQuote + parseFloat(hidGrandTotalQuantity.value);
        }
        if(hidGrandTotalGroup.value != null && hidGrandTotalGroup.value != ''){
            totalBaseBid = totalBaseBid  + parseFloat(hidGrandTotalGroup.value);
        }
        if(hidTotalGroupExtendedCost.value != null && hidTotalGroupExtendedCost.value != ''){
            totalExtendedCost = totalExtendedCost + parseFloat(hidTotalGroupExtendedCost.value);
        }
        
    }
    
    var txtTotalBaseBidTotal = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:txtTotalBaseBidTotal');
    var hidTotalBaseBidTotal = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalBaseBidTotal');
    
    hidTotalBaseBidTotal.value = totalBaseBid.toFixed(2);
    txtTotalBaseBidTotal.innerText = '$' + hidTotalBaseBidTotal.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    var txtTotalExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:txtTotalExtendedCost');
    var hidTotalExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalExtendedCost');
    
    hidTotalExtendedCost.value = totalExtendedCost.toFixed(2);
    txtTotalExtendedCost.innerText = '$' + hidTotalExtendedCost.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    var txtTotalBaseBidTotal = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:txtQuantityTotalQuote');
    var hidTotalBaseBidTotal = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidQuantityTotalQuote');
    
    txtTotalBaseBidTotal.innerText = hidTotalBaseBidTotal.value = totalQuantityQuote;
    
    calculateTotals();
    */
}

function calculateCommissionAndRebate(){
    
    //var hidTotalBaseBidTotal = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalBaseBidTotal');
    //var hidTotalExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalExtendedCost');
    
    calculateTotals();
    
    return false;
}

function calculateTotals(){

    var totalCommisionAndRebate = 0;
    var totalDirectSellPrice = 0;
    var totalBuyResellPrice = 0;
    var totalBuyResellExtendedCost = 0;
    
    var totalBuyResellMarginDollar = 0;
    var totalBuyResellMarginPer = 0;
    
    var totalProjectMarginDollar = 0;
    var totalProjectMarginPer = 0;
    
    for(var i=0, iLen=-1; i>iLen; i++){
        
        var grandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':txtGrandTotalGroup');
                          
        if(grandTotalGroup == null){
            break;
        }
        
        var isAlternate = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':parentGroupCheckBox');
        if(isAlternate.checked) {
            continue;
        }

        for(var j=0, jLen=-1; j>jLen; j++){
                    
            var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ i + ':rptProductSubGroup:' + j + ':hidGrandTotalSubGroup');
        
            if(hidGrandTotalSubGroup == null){
                break;
            }
            
            var isAlternate = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':rptProductSubGroup:' + j + ':subGroupAlternate');
            if(isAlternate.checked) {
                continue;
            }

            for(var k=0, kLen=-1; k>kLen; k++){
                        
                var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':rptProductSubGroup:' + j + ':rptProductSelected:' + k + ':';
                
                var txtSaleType = document.getElementById(tblAttributs + 'txtSaleType');
                
                if(txtSaleType == null){
                    break;
                }
                
                var isAlternateLineItem = document.getElementById(tblAttributs + 'checkAlternateQL');
                if(isAlternateLineItem.checked) {
                    continue;
                }
                var hidSalesPrice = document.getElementById(tblAttributs + 'hidSalesPrice');
                var hidExtendedCost = document.getElementById(tblAttributs + 'hidExtendedCost');
                var txtCR = document.getElementById(tblAttributs + 'txtCR');
                var textBoxSalesPrice = document.getElementById(tblAttributs + 'textBoxSalesPrice');
                
                if(txtSaleType.value == 'D/S'){
                    totalDirectSellPrice = totalDirectSellPrice + + parseFloat(hidSalesPrice.value);
                }
                else if(txtSaleType.value == 'B/R' || txtSaleType.value == 'LAB' || txtSaleType.value == 'P/T'){
                    if(textBoxSalesPrice.value != null){
                        totalBuyResellPrice = totalBuyResellPrice + parseFloat(textBoxSalesPrice.value);
                    }
                    totalBuyResellExtendedCost = totalBuyResellExtendedCost + parseFloat(hidExtendedCost.value);
                }
                else if(txtSaleType.value == 'C/R' && txtCR.value != null && txtCR.value != ''){
                    totalCommisionAndRebate = totalCommisionAndRebate + parseFloat(txtCR.value);
                }
            }
        }
    }
    
    totalBuyResellMarginDollar = parseFloat(totalBuyResellPrice) - parseFloat(totalBuyResellExtendedCost);
    
    if(totalBuyResellPrice != 0){
        totalBuyResellMarginPer = (parseFloat(totalBuyResellMarginDollar)/parseFloat(totalBuyResellPrice)) * 100;
    }
    
    totalProjectMarginDollar = parseFloat(totalCommisionAndRebate) + parseFloat(totalBuyResellMarginDollar);
    
    var hidTotalBaseBidTotal = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalBaseBidTotal');
    if(hidTotalBaseBidTotal.value != '' && hidTotalBaseBidTotal.value != 0){
        totalProjectMarginPer = (parseFloat(totalProjectMarginDollar)/parseFloat(hidTotalBaseBidTotal.value)) * 100;
    }
    
    var txtTotalDirectSellPrice = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:txtTotalDirectSellPrice');
    var hidTotalDirectSellPrice = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalDirectSellPrice');
    
    hidTotalDirectSellPrice.value = totalDirectSellPrice.toFixed(2);
    txtTotalDirectSellPrice.innerText = '$' + hidTotalDirectSellPrice.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    var txtTotalBuyResellPrice = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:txtTotalBuyResellPrice');
    var hidTotalBuyResellPrice = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalBuyResellPrice');
    
    hidTotalBuyResellPrice.value = totalBuyResellPrice.toFixed(2);
    txtTotalBuyResellPrice.innerText = '$' + hidTotalBuyResellPrice.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    var txtTotalBuyResellMarginDollar = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:txtTotalMarginDollar');
    var hidTotalBuyResellMarginDollar = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalMarginDollar');
    
    hidTotalBuyResellMarginDollar.value = totalBuyResellMarginDollar.toFixed(2);
    txtTotalBuyResellMarginDollar.innerText = '$' + hidTotalBuyResellMarginDollar.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    var txtTotalBuyResellMarginPercentage = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:txtTotalMarginPercentage');
    var hidTotalBuyResellMarginPercentage = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalMarginPercentage');
    
    hidTotalBuyResellMarginPercentage.value = totalBuyResellMarginPer.toFixed(2);
    txtTotalBuyResellMarginPercentage.innerText = hidTotalBuyResellMarginPercentage.value + '%';
    
    var txtTotalProjectMarginDollar = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:txtTotalProjectMarginDollar');
    var hidTotalProjectMarginDollar = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalProjectMarginDollar');
    
    hidTotalProjectMarginDollar.value = totalProjectMarginDollar.toFixed(2);
    txtTotalProjectMarginDollar.innerText = '$' + hidTotalProjectMarginDollar.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    var txtTotalProjectMarginPercentage = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:txtTotalProjectMarginPercentage');
    var hidTotalProjectMarginPercentage = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalProjectMarginPercentage');
    
    hidTotalProjectMarginPercentage.value = totalProjectMarginPer.toFixed(2);
    txtTotalProjectMarginPercentage.innerText = hidTotalProjectMarginPercentage.value + '%';
    
    var txtCommissionsAndRebates = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:txtCommissionsAndRebates');
    var hidCommissionsAndRebates = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidCommissionsAndRebates');
    
    hidCommissionsAndRebates.value = totalCommisionAndRebate.toFixed(2);
    txtCommissionsAndRebates.innerText = '$' + hidCommissionsAndRebates.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
    var hidTotalBuyResellExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalBuyResellExtendedCost');
    hidTotalBuyResellExtendedCost.value = totalBuyResellExtendedCost.toFixed(2);
    
}

/*
function calculateFreightOverride(groupIndex, subGroupIndex, rowIndex){

    var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + (rowIndex - 1) + ':';
    
    var hidFreightOverride = document.getElementById(tblAttributs + 'hidFreightOverride');
    hidFreightOverride.value = 'true';
    
    CalculatePrice(groupIndex, subGroupIndex, rowIndex);
    
}      
*/

function calculateSalePriceOverride(groupIndex, subGroupIndex, rowIndex){

    var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + (rowIndex - 1) + ':';
    
    var hidSalePriceOverride = document.getElementById(tblAttributs + 'hidSalePriceOverride');
    hidSalePriceOverride.value = 'true';
    
    CalculatePrice(groupIndex, subGroupIndex, rowIndex);
    
}      
  
function validateCalculationsData(){
    
    var isRequiredBlank = false;
    
    for(var i=0, iLen=-1; i>iLen; i++){
        
        var grandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':txtGrandTotalGroup');
                  
        if(grandTotalGroup == null){
            break;
        }
        
        for(var j=0, jLen=-1; j>jLen; j++){
            
            var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ i + ':rptProductSubGroup:' + j + ':hidGrandTotalSubGroup');
        
            if(hidGrandTotalSubGroup == null){
                break;
            }
            
            for(var k=0, kLen=-1; k>kLen; k++){
                
                var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':rptProductSubGroup:' + j + ':rptProductSelected:' + k + ':';
                
                var txtQuantity = document.getElementById(tblAttributs + 'txtQuantity');
                
                if(txtQuantity == null){
                    break;
                }
                
                var txtListPrice = document.getElementById(tblAttributs + 'txtListPrice');
                var txtMultiplier = document.getElementById(tblAttributs + 'txtMultiplier');
                var txtLBS = document.getElementById(tblAttributs + 'txtLBS');
                //var txtFreight = document.getElementById(tblAttributs + 'txtFreight');
                var txtMarginPercentage = document.getElementById(tblAttributs + 'txtMarginPercentage');
                var txtSaleType = document.getElementById(tblAttributs + 'txtSaleType');
                var txtCR = document.getElementById(tblAttributs + 'txtCR');
                
                if(txtCR.value == null || txtCR.value == ''){
                    txtCR.className = txtCR.className + " error";
                    isRequiredBlank = true;
                }
                else{
                    txtCR.className = txtCR.className.replace(" error", "");
                }
                
                if(txtSaleType.value == null || txtSaleType.value == ''){
                    txtSaleType.className = txtSaleType.className + " error";
                    isRequiredBlank = true;
                }
                else{
                    txtSaleType.className = txtSaleType.className.replace(" error", "");
                }
                
                if(txtQuantity.value == null || txtQuantity.value == ''){
                    txtQuantity.className = txtQuantity.className + " error";
                    isRequiredBlank = true;
                }
                else{
                    txtQuantity.className = txtQuantity.className.replace(" error", "");
                }
                
                if(txtListPrice.value == null || txtListPrice.value == ''){
                    txtListPrice.className = txtListPrice.className + " error";
                    isRequiredBlank = true;
                }
                else{
                    txtListPrice.className = txtListPrice.className.replace(" error", "");
                }
                
                if(txtMultiplier.value == null || txtMultiplier.value == ''){
                    txtMultiplier.className = txtMultiplier.className + " error";
                    isRequiredBlank = true;
                }
                else{
                    txtMultiplier.className = txtMultiplier.className.replace(" error", "");
                }
                /*
                if(txtLBS.value == null || txtLBS.value == ''){
                    txtLBS.className = txtLBS.className + " error";
                    isRequiredBlank = true;
                }
                else{
                    txtLBS.className = txtLBS.className.replace(" error", "");
                }
                
                if(txtFreight.value == null || txtFreight.value == ''){
                    txtFreight.className = txtFreight.className + " error";
                    isRequiredBlank = true;
                }
                else{
                    txtFreight.className = txtFreight.className.replace(" error", "");
                }
                */
                if(txtMarginPercentage.value == null || txtMarginPercentage.value == ''){
                    txtMarginPercentage.className = txtMarginPercentage.className + " error";
                    isRequiredBlank = true;
                }
                else{
                    txtMarginPercentage.className = txtMarginPercentage.className.replace(" error", "");
                }
            }
        }
    }
    
    if(isRequiredBlank == true){
        var answer = confirm("There are some calculation data missing, still you want to continue?");
        if (answer) {
            return true;
        }
        else {
            return false;
        }
    }
    
}

function popupTotalValuesOfReverseMargin(){
    
    //var hidTotalExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalExtendedCost');
    var hidTotalBaseBid = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalBaseBidTotal');
    var hidTotalProjectMarginDollar = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalProjectMarginDollar');
    var hidTotalProjectMarginPercentage = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalProjectMarginPercentage');
    
    var txtOriginalTotal = document.getElementById('pageId:formId:txtOriginalTotal');
    var txtOriginalTotalProjectMarginDollar = document.getElementById('pageId:formId:txtOriginalTotalProjectMarginDollar');
    var txtOriginalOriginalMarginPer = document.getElementById('pageId:formId:txtOriginalOriginalMarginPer');
    
    txtOriginalTotal.innerText = '$' + hidTotalBaseBid.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    txtOriginalTotalProjectMarginDollar.innerText = '$' + hidTotalProjectMarginDollar.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    txtOriginalOriginalMarginPer.innerText = hidTotalProjectMarginPercentage.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,') + '%';
    
    var txtNegotiationsTotal = document.getElementById('pageId:formId:txtNegotiationsTotal');
    var txtNegotiationsTotalProjectMarginDollar = document.getElementById('pageId:formId:txtNegotiationsTotalProjectMarginDollar');
    var txtNegotiationsTotalProjectMarginPer = document.getElementById('pageId:formId:txtNegotiationsTotalProjectMarginPer');
    var txtOriginalChangeMarginPer = document.getElementById('pageId:formId:txtOriginalChangeMarginPer');
    
    txtNegotiationsTotal.value = '';
    txtNegotiationsTotalProjectMarginDollar.value = '';
    txtNegotiationsTotalProjectMarginPer.value = '';
    txtOriginalChangeMarginPer.innerText = '';
}

function popupTotalValuesOfReverseMarginSubGroup(isFrom, groupIndex, subGroupIndex){
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    
    hidGroupIndex.value = groupIndex;
    hidSubGroupIndex.value = subGroupIndex;
    
    var hidSalePriceTotal = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':hidGrandTotalSubGroup');
    var hidExtendedCostTotal = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':hidGrandTotalExtendedCost');
    
    var totalCR = getCommitionAndRebates(groupIndex, subGroupIndex);
    
    var projectMarginDollar = parseFloat(hidSalePriceTotal.value) - parseFloat(hidExtendedCostTotal.value) + totalCR;
    
    var marginProject = (projectMarginDollar/parseFloat(hidSalePriceTotal.value)) * 100;
    marginProject = marginProject.toFixed(6);
    
    var txtOriginalTotal = document.getElementById('pageId:formId:txtOriginalTotal');
    var txtOriginalTotalProjectMarginDollar = document.getElementById('pageId:formId:txtOriginalTotalProjectMarginDollar');
    var txtOriginalOriginalMarginPer = document.getElementById('pageId:formId:txtOriginalOriginalMarginPer');
    
    txtOriginalTotal.innerText = '$' + hidSalePriceTotal.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    txtOriginalTotalProjectMarginDollar.innerText = '$' + projectMarginDollar.toString().replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    txtOriginalOriginalMarginPer.innerText = marginProject.toString().replace(/(\d)(?=(\d{3})+\.)/g, '$1,') + '%';
    
    var txtNegotiationsTotal = document.getElementById('pageId:formId:txtNegotiationsTotal');
    var txtNegotiationsTotalProjectMarginDollar = document.getElementById('pageId:formId:txtNegotiationsTotalProjectMarginDollar');
    var txtNegotiationsTotalProjectMarginPer = document.getElementById('pageId:formId:txtNegotiationsTotalProjectMarginPer');
    var txtOriginalChangeMarginPer = document.getElementById('pageId:formId:txtOriginalChangeMarginPer');
    
    txtNegotiationsTotal.value = '';
    txtNegotiationsTotalProjectMarginDollar.value = '';
    txtNegotiationsTotalProjectMarginPer.value = '';
    txtOriginalChangeMarginPer.innerText = '';
    
    
}

function getCommitionAndRebates(groupIndex, subGroupIndex){

    var totalCommisionAndRebate = 0;
    
    for(var k=0, kLen=-1; k>kLen; k++){
                        
        var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + k + ':';
        var txtCR = document.getElementById(tblAttributs + 'txtCR');
        var txtSaleType = document.getElementById(tblAttributs + 'txtSaleType');
        
        if(txtSaleType == null){
            break;
        }
        
        if(txtSaleType.value == 'C/R' && txtCR.value != null && txtCR.value != ''){
            totalCommisionAndRebate = totalCommisionAndRebate + parseFloat(txtCR.value);
        }
    }
    
    return totalCommisionAndRebate;
}

function getPassThroughTotalCostProject(){
    
    var totalPassThroughCost = 0;
    
    for(var i=0, iLen=-1; i>iLen; i++){
        
        var grandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':txtGrandTotalGroup');
                  
        if(grandTotalGroup == null){
            break;
        }
        
        for(var j=0, jLen=-1; j>jLen; j++){
            
            var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ i + ':rptProductSubGroup:' + j + ':hidGrandTotalSubGroup');
        
            if(hidGrandTotalSubGroup == null){
                break;
            }
            
            totalPassThroughCost += getPassThroughTotalCost(i, j);
           }
      }
    
    return totalPassThroughCost;
    
}

function getPassThroughTotalSellProject(){
    
    var totalPassThroughSell = 0;
    
    for(var i=0, iLen=-1; i>iLen; i++){
        
        var grandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':txtGrandTotalGroup');
                  
        if(grandTotalGroup == null){
            break;
        }
        
        for(var j=0, jLen=-1; j>jLen; j++){
            
            var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ i + ':rptProductSubGroup:' + j + ':hidGrandTotalSubGroup');
        
            if(hidGrandTotalSubGroup == null){
                break;
            }
            
            totalPassThroughSell += getPassThroughTotalSell(i, j);
           }
      }
    
    return totalPassThroughSell;
}

function getPassThroughTotalCost(groupIndex, subGroupIndex){
    
    var totalPassThroughCost = 0;
    
    for(var k=0, kLen=-1; k>kLen; k++){
                        
        var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + k + ':';
        
        var txtSaleType = document.getElementById(tblAttributs + 'txtSaleType');
        
        if(txtSaleType == null){
            break;
        }
        
        var hidExtendedCost = document.getElementById(tblAttributs + 'hidExtendedCost');
        
        if(txtSaleType.value == 'P/T'){
            totalPassThroughCost = totalPassThroughCost + parseFloat(hidExtendedCost.value);
        }
        
    }
    
    return totalPassThroughCost;
    
}

function getPassThroughTotalSell(groupIndex, subGroupIndex){

    var totalPassThroughSell = 0;
    
    for(var k=0, kLen=-1; k>kLen; k++){
                        
        var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + k + ':';
        
        var txtSaleType = document.getElementById(tblAttributs + 'txtSaleType');
        
        if(txtSaleType == null){
            break;
        }
        
        var textBoxSalesPrice = document.getElementById(tblAttributs + 'textBoxSalesPrice');
        
        if(txtSaleType.value == 'P/T' && textBoxSalesPrice != null){
            totalPassThroughSell = totalPassThroughSell + parseFloat(textBoxSalesPrice.value);
        }
        
    }
    
    return totalPassThroughSell;
}

function getTotalDirectSellPriceProject(){
    
    var totalDirectSellPrice = 0;
    
    for(var i=0, iLen=-1; i>iLen; i++){
        
        var grandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':txtGrandTotalGroup');
                  
        if(grandTotalGroup == null){
            break;
        }
        
        for(var j=0, jLen=-1; j>jLen; j++){
            
            var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ i + ':rptProductSubGroup:' + j + ':hidGrandTotalSubGroup');
        
            if(hidGrandTotalSubGroup == null){
                break;
            }
            
            totalDirectSellPrice += getTotalDirectSellPrice(i, j);
           }
      }
    
    return totalDirectSellPrice;
}

function calculateNegotiations(isFrom){

    var txtNegotiationsTotal = document.getElementById('pageId:formId:txtNegotiationsTotal');
    var txtNegotiationsTotalProjectMarginDollar = document.getElementById('pageId:formId:txtNegotiationsTotalProjectMarginDollar');
    var txtNegotiationsTotalProjectMarginPer = document.getElementById('pageId:formId:txtNegotiationsTotalProjectMarginPer');
    var hidMarginPercentage = document.getElementById('pageId:formId:hidMarginPercentage');
    var reverseMarginPopupHeader = document.getElementById('pageId:formId:txtReverseMarginHeader');
    var hidChangeMarginPer = document.getElementById('pageId:formId:hidChangeMarginPer');
    var txtOriginalChangeMarginPer = document.getElementById('pageId:formId:txtOriginalChangeMarginPer');
    
    if(reverseMarginPopupHeader.innerText == 'Subgroup Negotiation'){
    
        var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
        var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
        
        var hidSalePriceTotal = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + hidGroupIndex.value + ':rptProductSubGroup:' + hidSubGroupIndex.value + ':hidGrandTotalSubGroup');
        var hidExtendedCostTotal = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ hidGroupIndex.value + ':rptProductSubGroup:' + hidSubGroupIndex.value + ':hidGrandTotalExtendedCost');
        
        var totalCR = getCommitionAndRebates(hidGroupIndex.value, hidSubGroupIndex.value);
        
        if(isFrom == 'Total Sell Price'){
            if(txtNegotiationsTotal.value == null || txtNegotiationsTotal.value == ''){
                return;
            }
            
            var projectMarginDollar = parseFloat(hidSalePriceTotal.value) - parseFloat(hidExtendedCostTotal.value) + totalCR;
            
            txtNegotiationsTotalProjectMarginDollar.value = parseFloat(txtNegotiationsTotal.value) - parseFloat(hidSalePriceTotal.value) + projectMarginDollar;
            
            var totalProjectMarginDollar = parseFloat(txtNegotiationsTotalProjectMarginDollar.value);
            txtNegotiationsTotalProjectMarginDollar.value = totalProjectMarginDollar.toFixed(2);
            
            var marginProject = (txtNegotiationsTotalProjectMarginDollar.value/parseFloat(txtNegotiationsTotal.value)) * 100;
            txtNegotiationsTotalProjectMarginPer.value = marginProject;
        }
        else if(isFrom == 'BuyResellMarginDollar'){
            
            if(txtNegotiationsTotalProjectMarginDollar.value == null || txtNegotiationsTotalProjectMarginDollar.value == ''){
                return;
            }
            
            var projectMarginDollar = parseFloat(hidSalePriceTotal.value) - parseFloat(hidExtendedCostTotal.value) + totalCR;
            
            txtNegotiationsTotal.value = parseFloat(txtNegotiationsTotalProjectMarginDollar.value) - parseFloat(projectMarginDollar) + parseFloat(hidSalePriceTotal.value);
                                
            txtNegotiationsTotal.value = parseFloat(txtNegotiationsTotal.value).toFixed(2);
            
            var marginProject = (txtNegotiationsTotalProjectMarginDollar.value/parseFloat(txtNegotiationsTotal.value)) * 100;
            txtNegotiationsTotalProjectMarginPer.value = marginProject;
            
        }
        else{
            
            if(txtNegotiationsTotalProjectMarginPer.value == null || txtNegotiationsTotalProjectMarginPer.value == ''){
                return;
            }
            
            var devider = (1 - (parseFloat(txtNegotiationsTotalProjectMarginPer.value)/100));
            txtNegotiationsTotal.value = ((parseFloat(hidExtendedCostTotal.value) - totalCR)/devider);

            txtNegotiationsTotal.value = parseFloat(txtNegotiationsTotal.value).toFixed(2);
            
            txtNegotiationsTotalProjectMarginDollar.value = txtNegotiationsTotal.value - parseFloat(hidExtendedCostTotal.value) + parseFloat(totalCR);
            
            txtNegotiationsTotalProjectMarginDollar.value = parseFloat(txtNegotiationsTotalProjectMarginDollar.value).toFixed(2);
            
        }
        
        var passThroughTotalCost = getPassThroughTotalCost(hidGroupIndex.value,hidSubGroupIndex.value);
        var passThroughTotalSell = getPassThroughTotalSell(hidGroupIndex.value,hidSubGroupIndex.value);
        var totalDirectSellPrice = getTotalDirectSellPrice(hidGroupIndex.value, hidSubGroupIndex.value);
        
        var changeMargin = ((txtNegotiationsTotal.value - parseFloat(hidExtendedCostTotal.value)) +
                             (passThroughTotalCost - passThroughTotalSell)) /
                             (txtNegotiationsTotal.value - parseFloat(hidExtendedCostTotal.value) + passThroughTotalCost - passThroughTotalSell +
                              parseFloat(hidExtendedCostTotal.value) - totalDirectSellPrice - passThroughTotalCost) * 100;
        
        hidChangeMarginPer.value = changeMargin;
        txtOriginalChangeMarginPer.innerText = hidChangeMarginPer.value + '%';
        
        //var totalDirectSellPrice = getTotalDirectSellPrice(hidGroupIndex.value, hidSubGroupIndex.value);
        //var totalBuyResellExtendedCost = getBuyResellExtendedCost(hidGroupIndex.value, hidSubGroupIndex.value);
        
        //alert('totalBuyResellExtendedCost--'+totalBuyResellExtendedCost);
        //alert('txtNegotiationsTotal.value--'+txtNegotiationsTotal.value);
        //alert('totalDirectSellPrice--'+totalDirectSellPrice);
        
        //var changeMargin =  (1 - (parseFloat(totalBuyResellExtendedCost)/(parseFloat(txtNegotiationsTotal.value) - parseFloat(totalDirectSellPrice)))) * 100;
        //hidChangeMarginPer.value = changeMargin.toFixed(6);
        //txtOriginalChangeMarginPer.innerText = hidChangeMarginPer.value + '%';
        
    }
    else{
        var hidTotalExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalExtendedCost');
        var hidMarginPercentage = document.getElementById('pageId:formId:hidMarginPercentage');
        
        var hidCommissionsAndRebates = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidCommissionsAndRebates');
        
        if(isFrom == 'Total Sell Price'){
            
            if(txtNegotiationsTotal.value == null || txtNegotiationsTotal.value == ''){
                return;
            }
            
            if(hidCommissionsAndRebates.value != '' && hidCommissionsAndRebates.value != null){
                txtNegotiationsTotalProjectMarginDollar.value = (parseFloat(txtNegotiationsTotal.value) - parseFloat(hidTotalExtendedCost.value)) + parseFloat(hidCommissionsAndRebates.value);
            }
            else{
                txtNegotiationsTotalProjectMarginDollar.value = parseFloat(txtNegotiationsTotal.value) - parseFloat(hidTotalExtendedCost.value);
            }
            
            var totalProjectMarginDollar = parseFloat(txtNegotiationsTotalProjectMarginDollar.value);
            txtNegotiationsTotalProjectMarginDollar.value = totalProjectMarginDollar.toFixed(2);
            
            var marginProject = (txtNegotiationsTotalProjectMarginDollar.value/parseFloat(txtNegotiationsTotal.value)) * 100;
            txtNegotiationsTotalProjectMarginPer.value = marginProject;
            
        }
        else if(isFrom == 'BuyResellMarginDollar'){
            
            if(txtNegotiationsTotalProjectMarginDollar.value == null || txtNegotiationsTotalProjectMarginDollar.value == ''){
                return;
            }
            
            if(hidCommissionsAndRebates.value != '' && hidCommissionsAndRebates.value != null){
                txtNegotiationsTotal.value = (parseFloat(txtNegotiationsTotalProjectMarginDollar.value) + parseFloat(hidTotalExtendedCost.value)) - parseFloat(hidCommissionsAndRebates.value);
            }
            else{
                txtNegotiationsTotal.value = parseFloat(txtNegotiationsTotalProjectMarginDollar.value) + parseFloat(hidTotalExtendedCost.value);
            }
            
            txtNegotiationsTotal.value = parseFloat(txtNegotiationsTotal.value).toFixed(2);
            
            var marginProject = (txtNegotiationsTotalProjectMarginDollar.value/parseFloat(txtNegotiationsTotal.value)) * 100;
            txtNegotiationsTotalProjectMarginPer.value = marginProject;
            
        }
        else{
            
            if(txtNegotiationsTotalProjectMarginPer.value == null || txtNegotiationsTotalProjectMarginPer.value == ''){
                return;
            }
            
            var devider = (1 - (parseFloat(txtNegotiationsTotalProjectMarginPer.value)/100));
            if(hidCommissionsAndRebates.value != '' && hidCommissionsAndRebates.value != null){
                txtNegotiationsTotal.value = ((parseFloat(hidTotalExtendedCost.value) - parseFloat(hidCommissionsAndRebates.value))/devider);
            }
            else{
                txtNegotiationsTotal.value = (parseFloat(hidTotalExtendedCost.value)/devider);
            }
            
            txtNegotiationsTotal.value = parseFloat(txtNegotiationsTotal.value).toFixed(2);
            
            if(hidCommissionsAndRebates.value != '' && hidCommissionsAndRebates.value != null){
                txtNegotiationsTotalProjectMarginDollar.value = txtNegotiationsTotal.value - parseFloat(hidTotalExtendedCost.value) + parseFloat(hidCommissionsAndRebates.value);
            }
            else{
                txtNegotiationsTotalProjectMarginDollar.value = txtNegotiationsTotal.value - parseFloat(hidTotalExtendedCost.value);
            }
            
            txtNegotiationsTotalProjectMarginDollar.value = parseFloat(txtNegotiationsTotalProjectMarginDollar.value).toFixed(2);
            
        }
        
        //var hidTotalDirectSellPrice = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalDirectSellPrice');
        //var hidTotalBuyResellExtendedCost = document.getElementById('pageId:formId:pbSelectedProducts:pbsSummary:hidTotalBuyResellExtendedCost');
        
        var passThroughTotalCostProject = getPassThroughTotalCostProject();
        var passThroughTotalSellProject = getPassThroughTotalSellProject();
        var totalDirectSellPriceProject = getTotalDirectSellPriceProject();
        
        var changeMargin = ((txtNegotiationsTotal.value - parseFloat(hidTotalExtendedCost.value)) +
                             (passThroughTotalCostProject - passThroughTotalSellProject)) /
                             (txtNegotiationsTotal.value - parseFloat(hidTotalExtendedCost.value) + passThroughTotalCostProject - passThroughTotalSellProject +
                              parseFloat(hidTotalExtendedCost.value) - totalDirectSellPriceProject - passThroughTotalCostProject) * 100;
        
        //var changeMargin =  (1 - (parseFloat(hidTotalBuyResellExtendedCost.value)/(parseFloat(txtNegotiationsTotal.value) - parseFloat(hidTotalDirectSellPrice.value)))) * 100;
        hidChangeMarginPer.value = changeMargin;
        txtOriginalChangeMarginPer.innerText = hidChangeMarginPer.value + '%';
    }
    
}

function getTotalDirectSellPrice(groupIndex, subGroupIndex){
    
    var totalDirectSellPrice = 0;
    
    for(var k=0, kLen=-1; k>kLen; k++){
                        
        var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + k + ':';
        
        var txtSaleType = document.getElementById(tblAttributs + 'txtSaleType');
        
        if(txtSaleType == null){
            break;
        }
        
        var hidSalesPrice = document.getElementById(tblAttributs + 'hidSalesPrice');
        var hidExtendedCost = document.getElementById(tblAttributs + 'hidExtendedCost');
        var txtCR = document.getElementById(tblAttributs + 'txtCR');
        
        if(txtSaleType.value == 'D/S'){
            totalDirectSellPrice = totalDirectSellPrice + parseFloat(hidSalesPrice.value);
        }
        
    }
    
    return totalDirectSellPrice;
    
}

function getBuyResellExtendedCost(groupIndex, subGroupIndex){
    
    var totalBuyResellExtendedCost = 0;
    
    for(var k=0, kLen=-1; k>kLen; k++){
                        
        var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + k + ':';
        
        var txtSaleType = document.getElementById(tblAttributs + 'txtSaleType');
        
        if(txtSaleType == null){
            break;
        }
        
        var hidExtendedCost = document.getElementById(tblAttributs + 'hidExtendedCost');
        var txtCR = document.getElementById(tblAttributs + 'txtCR');
        
        if(txtSaleType.value == 'B/R' || txtSaleType.value == 'LAB' || txtSaleType.value == 'P/T'){
            totalBuyResellExtendedCost = totalBuyResellExtendedCost + parseFloat(hidExtendedCost.value);
        }
    }
    
    return totalBuyResellExtendedCost;
}

function validateBeforeAcceptNegotiations(){

    var txtNegotiationsTotal = document.getElementById('pageId:formId:txtNegotiationsTotal');
    var txtNegotiationsTotalProjectMarginDollar = document.getElementById('pageId:formId:txtNegotiationsTotalProjectMarginDollar');
    var txtNegotiationsTotalProjectMarginPer = document.getElementById('pageId:formId:txtNegotiationsTotalProjectMarginPer');
    
    var isRequired = false;
    
    if(txtNegotiationsTotal.value == null || txtNegotiationsTotal.value == ''){
        txtNegotiationsTotal.className = txtNegotiationsTotal.className + " error";
        isRequired = true;
    }
    else{
        txtNegotiationsTotal.className = txtNegotiationsTotal.className.replace(" error", "");
    }
    
    if(txtNegotiationsTotalProjectMarginDollar.value == null || txtNegotiationsTotalProjectMarginDollar.value == ''){
        txtNegotiationsTotalProjectMarginDollar.className = txtNegotiationsTotalProjectMarginDollar.className + " error";
        isRequired = true;
    }
    else{
        txtNegotiationsTotalProjectMarginDollar.className = txtNegotiationsTotalProjectMarginDollar.className.replace(" error", "");
    }
    
    if(txtNegotiationsTotalProjectMarginPer.value == null || txtNegotiationsTotalProjectMarginPer.value == ''){
        txtNegotiationsTotalProjectMarginPer.className = txtNegotiationsTotalProjectMarginPer.className + " error";
        isRequired = true;
    }
    else{
        txtNegotiationsTotalProjectMarginPer.className = txtNegotiationsTotalProjectMarginPer.className.replace(" error", "");
    }
    
    return isRequired;
    
}

function acceptNegotiations(){
    var reverseMarginPopupHeader = document.getElementById('pageId:formId:txtReverseMarginHeader');
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    
    if(reverseMarginPopupHeader.innerText == 'Subgroup Negotiation'){
        acceptNegotiationsSubGroup(hidGroupIndex.value, hidSubGroupIndex.value);
    } else {
        acceptNegotiationsProject();
    }
    
    return false;
}

function acceptNegotiationsSubGroup(groupIndex, subGroupIndex){
    
    var hidChangeMarginPer = document.getElementById('pageId:formId:hidChangeMarginPer');
    var grandTotal = 0;
    
    var isValidate = validateBeforeAcceptNegotiations();
    
    if(!isValidate){
    
        for(var k=0, kLen=-1; k>kLen; k++){
                        
            var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + k + ':';
            
            var txtMarginPercentage = document.getElementById(tblAttributs + 'txtMarginPercentage');
            
            if(txtMarginPercentage == null){
                break;
            }
            else{
                var saleType = document.getElementById(tblAttributs + 'txtSaleType');
                if(saleType.value == 'B/R' || saleType.value == 'LAB' || saleType.value == ''){
                    txtMarginPercentage.value = hidChangeMarginPer.value;
                }
                else{
                    txtMarginPercentage.value = 0;
                }
                var hidExtendedCost = document.getElementById(tblAttributs + 'hidExtendedCost');
                var hidSalesPrice = document.getElementById(tblAttributs + 'hidSalesPrice');
                var txtSalesPrice = document.getElementById(tblAttributs + 'txtSalesPrice');
                var textBoxSalesPrice = document.getElementById(tblAttributs + 'textBoxSalesPrice');
                
                hidSalesPrice.value = (hidExtendedCost.value/(1-(txtMarginPercentage.value/100))).toFixed(2);
                txtSalesPrice.innerText = '$' + hidSalesPrice.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
                
                if(saleType.value == 'P/T'){
                    grandTotal = grandTotal + parseFloat(textBoxSalesPrice.value);
                }
                else{
                    grandTotal = grandTotal + parseFloat(hidSalesPrice.value);
                }
            
                
            }
        }
        
        var grandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':txtGrandTotalSubGroup');
        var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':hidGrandTotalSubGroup');
        
        hidGrandTotalSubGroup.value = grandTotal.toFixed(2);
        grandTotalSubGroup.innerText = '$' + hidGrandTotalSubGroup.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
        
        //calculateGrandTotalsExtendedCostAndBaseBid();
        //VerifyCalculation();
        
        for(var i=0, iLen=-1; i>iLen; i++){
            var hidGrandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':hidGrandTotalGroup');
            
            if(hidGrandTotalGroup == null){
                break;
            }
            
            for(var j=0, jLen=-1; j>jLen; j++){
                var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':rptProductSubGroup:' + j + ':hidGrandTotalSubGroup');
                
                if(hidGrandTotalSubGroup == null){
                    break;
                }
                
                for(var k=0, kLen=-1; k>kLen; k++){
                    var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':rptProductSubGroup:' + j + ':rptProductSelected:' + k + ':';
        
                    var txtQuantity = document.getElementById(tblAttributs + 'txtQuantity');
                    
                    if(txtQuantity == null){
                        break;
                    }
                    else{
                        CalculatePrice(i,j,k+1);
                    }
                }
                
            }
            
        }
        
        closeReverseMarginPopup();
        
    } else {
        return false;
    }
    
    
}

function acceptNegotiationsProject(){
    
    var isValidate = validateBeforeAcceptNegotiations();
    
    if(!isValidate){
        var txtNegotiationsMarginPer = document.getElementById('pageId:formId:txtNegotiationsMarginPer');
        var hidMarginPercentage = document.getElementById('pageId:formId:hidMarginPercentage');
        var hidChangeMarginPer = document.getElementById('pageId:formId:hidChangeMarginPer');
        
        for(var i=0, iLen=-1; i>iLen; i++){
            
            var greatGrandTotal = 0;
            var grandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':txtGrandTotalGroup');
                      
            if(grandTotalGroup == null){
                break;
            }
            
            for(var j=0, jLen=-1; j>jLen; j++){
                
                var grandTotal = 0;
                var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ i + ':rptProductSubGroup:' + j + ':hidGrandTotalSubGroup');
            
                if(hidGrandTotalSubGroup == null){
                    break;
                }
                
                for(var k=0, kLen=-1; k>kLen; k++){
                    
                    var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':rptProductSubGroup:' + j + ':rptProductSelected:' + k + ':';
                    
                    var txtMarginPercentage = document.getElementById(tblAttributs + 'txtMarginPercentage');
                    var textBoxSalesPrice = document.getElementById(tblAttributs + 'textBoxSalesPrice');
                    
                    if(txtMarginPercentage == null){
                        break;
                    }
                    else{
                        var saleType = document.getElementById(tblAttributs + 'txtSaleType');
                        if(saleType.value == 'B/R' || saleType.value == 'LAB' || saleType.value == ''){
                            txtMarginPercentage.value = hidChangeMarginPer.value;
                        }
                        else{
                            txtMarginPercentage.value = 0;
                        }
                        var hidExtendedCost = document.getElementById(tblAttributs + 'hidExtendedCost');
                        var hidSalesPrice = document.getElementById(tblAttributs + 'hidSalesPrice');
                        var txtSalesPrice = document.getElementById(tblAttributs + 'txtSalesPrice');
                        
                        hidSalesPrice.value = (hidExtendedCost.value/(1-(txtMarginPercentage.value/100))).toFixed(2);
                        txtSalesPrice.innerText = '$' + hidSalesPrice.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
                        
                        if(saleType.value == 'P/T' || saleType.value == 'B/R' || saleType.value == 'LAB'){
                            grandTotal = grandTotal + parseFloat(textBoxSalesPrice.value);
                        }
                        else{
                            grandTotal = grandTotal + parseFloat(hidSalesPrice.value);
                        }
                    
                        
                    }
                }
                
                var grandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ i + ':rptProductSubGroup:' + j + ':txtGrandTotalSubGroup');
                var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ i + ':rptProductSubGroup:' + j + ':hidGrandTotalSubGroup');
                
                hidGrandTotalSubGroup.value = grandTotal.toFixed(2);
                grandTotalSubGroup.innerText = '$' + hidGrandTotalSubGroup.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
                
                greatGrandTotal = greatGrandTotal + parseFloat(hidGrandTotalSubGroup.value);
            }
            
            var grandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':txtGrandTotalGroup');
            var hidGrandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':hidGrandTotalGroup');
            
            hidGrandTotalGroup.value = greatGrandTotal.toFixed(2);
            grandTotalGroup.innerText = '$' + hidGrandTotalGroup.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
        }
        
        calculateGrandTotalsExtendedCostAndBaseBid();
        
        closeReverseMarginPopup();
        
        return false;
    }
    else{
        return false;
    }
    
}

function changeMultiplier(groupIndex, subGroupIndex,isFrom){
    
    var txtHeaderMultiplier = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':txtHeaderMultiplier');
    var txtHeaderMarginPercentage = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':txtHeaderMarginPercentage');
    var txtHeaderRelease = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':txtHeaderRelease');
           
    for(var k=0, kLen=-1; k>kLen; k++){
                        
        var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + k + ':';
        
        var txtMarginPercentage = document.getElementById(tblAttributs + 'txtMarginPercentage');
        var txtMultiplier = document.getElementById(tblAttributs + 'txtMultiplier');
        var txtRelease = document.getElementById(tblAttributs + 'txtRelease');
        
        if(txtMarginPercentage == null){
            break;
        }
        else{
            var saleType = document.getElementById(tblAttributs + 'txtSaleType');
            if(isFrom == 'Margin Percentage'){
                if(saleType.value == 'B/R' || saleType.value == '' || saleType.value == 'LAB'){
                    txtMarginPercentage.value = txtHeaderMarginPercentage.value;    
                }
                else{
                    txtMarginPercentage.value = 0;
                }
            }
            else if(isFrom == 'Release'){
                txtRelease.value = txtHeaderRelease.value;
            }
            else{
                if(saleType.value != 'C/R' && saleType.value != 'P/T' && saleType.value != 'D/S'){
                    txtMultiplier.value = txtHeaderMultiplier.value;
                }
                else{
                    txtMultiplier.value = 0;
                }
                
            }
            
            if(isFrom != 'Release'){
                CalculatePrice(groupIndex, subGroupIndex,k+1);
            }
            
            
            //calculateFreightOverride(groupIndex, subGroupIndex,k+1);
        }   
    }
    
    txtHeaderMarginPercentage.value = '';
    
}

function EnableDisableColumns(groupIndex, subGroupIndex, rowIndex, saleType){
                        
    var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + (rowIndex - 1) + ':';
    var txtCR = document.getElementById(tblAttributs + 'txtCR');
    var txtMarginPercentage = document.getElementById(tblAttributs + 'txtMarginPercentage');
    
    var txtListPrice = document.getElementById(tblAttributs + 'txtListPrice');
    var txtMultiplier = document.getElementById(tblAttributs + 'txtMultiplier');
    var txtLBS = document.getElementById(tblAttributs + 'txtLBS');
    var txtTLBS = document.getElementById(tblAttributs + 'txtTLBS');
    var txtUnitCost = document.getElementById(tblAttributs + 'txtUnitCost');
    //var txtFreight = document.getElementById(tblAttributs + 'txtFreight');
    var txtExtendedCost = document.getElementById(tblAttributs + 'txtExtendedCost');
    var txtSalesPrice = document.getElementById(tblAttributs + 'txtSalesPrice');
    
    var textBoxSalesPrice = document.getElementById(tblAttributs + 'textBoxSalesPrice');
    
    var hidTLBS = document.getElementById(tblAttributs + 'hidTLBS');
    var hidUnitCost = document.getElementById(tblAttributs + 'hidUnitCost');
    var hidExtendedCost = document.getElementById(tblAttributs + 'hidExtendedCost');
    var hidSalesPrice = document.getElementById(tblAttributs + 'hidSalesPrice');
    
    if(saleType.value == 'B/R' || saleType.value == 'LAB'){
        txtCR.value = 0;
        txtCR.style.display = 'none';
        
        textBoxSalesPrice.style.display = 'block';
        
        txtListPrice.style.display = 'block';
        txtMultiplier.style.display = 'block';
        txtLBS.style.display = 'block';
        //txtFreight.style.display = 'block';
        txtMarginPercentage.style.display = 'block';
        txtSalesPrice.style.display = 'none';
    }
    else if(saleType.value == 'P/T'){
        txtCR.value = 0;
        txtCR.style.display = 'none';
        
        txtMarginPercentage.value = 0;
        txtMarginPercentage.style.display = 'none';
        txtSalesPrice.style.display = 'none';
        txtListPrice.style.display = 'block';
        txtMultiplier.style.display = 'block';
        txtLBS.style.display = 'block';
        //txtFreight.style.display = 'block';
        textBoxSalesPrice.style.display = 'block';
    }
    else if(saleType.value == 'D/S'){
        
        txtCR.value = 0;
        txtMarginPercentage.value = 0;
        
        txtCR.style.display = 'none';
        txtMarginPercentage.style.display = 'none';
        textBoxSalesPrice.style.display = 'none';
        
        txtSalesPrice.style.display = 'block';
        txtListPrice.style.display = 'block';
        txtMultiplier.style.display = 'block';
        txtLBS.style.display = 'block';
        //txtFreight.style.display = 'block';
    }
    else if(saleType.value == 'C/R'){
        txtListPrice.value = 0;
        txtMultiplier.value = 0;
        txtLBS.value = 0;
        //txtFreight.value = 0;
        txtMarginPercentage.value = 0;
        
        txtListPrice.style.display = 'none';
        txtMultiplier.style.display = 'none';
        txtLBS.style.display = 'none';
        //txtFreight.style.display = 'none';
        txtMarginPercentage.style.display = 'none';
        textBoxSalesPrice.style.display = 'none';
        
        hidTLBS.value = 0;
        hidUnitCost.value = 0; 
        hidExtendedCost.value = 0; 
        hidSalesPrice.value = 0; 
        
        txtTLBS.innerText = '';
        txtUnitCost.innerText = '';
        txtExtendedCost.innerText = '';
        txtSalesPrice.innerText = '';
        
        txtCR.style.display = 'block';
    }
    else{
        txtCR.style.display = 'block';
        txtListPrice.style.display = 'block';
        txtMultiplier.style.display = 'block';
        txtLBS.style.display = 'block';
        //txtFreight.style.display = 'block';
        txtMarginPercentage.style.display = 'block';
        txtSalesPrice.style.display = 'block';
        textBoxSalesPrice.style.display = 'none';
    }
    
    CalculatePrice(groupIndex, subGroupIndex, rowIndex);
}

function calculateScratchPad(rowIndex){
    
    var tblAttributs = 'pageId:formId:pbSelectedProducts:pbsScratchPad:rptScratchPad:' + (rowIndex - 1) + ':';
    
    var txtQuantity = document.getElementById(tblAttributs + 'txtScratchQuantity');
    var txtLBS = document.getElementById(tblAttributs + 'txtScratchLBS');
    var txtTLBS = document.getElementById(tblAttributs + 'txtScratchTLBS');
    var txtListPrice = document.getElementById(tblAttributs + 'txtScratchListPrice');
    var txtMultiplier = document.getElementById(tblAttributs + 'txtScratchMultiplier');
    var txtUnitCost = document.getElementById(tblAttributs + 'txtScratchUnitCost');
    //var txtFreight = document.getElementById(tblAttributs + 'txtScratchFreight');
    var txtExtendedCost = document.getElementById(tblAttributs + 'txtScratchExtendedCost');
    var txtSalesPrice = document.getElementById(tblAttributs + 'txtScratchSalesPrice');
    var txtMarginPercentage = document.getElementById(tblAttributs + 'txtScratchMarginPercentage');
    var hidTLBS = document.getElementById(tblAttributs + 'hidScratchTLBS');
    var hidUnitCost = document.getElementById(tblAttributs + 'hidScratchUnitCost');
    var hidExtendedCost = document.getElementById(tblAttributs + 'hidScratchExtendedCost');
    var hidSalesPrice = document.getElementById(tblAttributs + 'hidScratchSalesPrice');
    //var hidFreightOverride = document.getElementById(tblAttributs + 'hidScratchFreightOverride');
    
    hidTLBS.value = (txtQuantity.value * txtLBS.value).toFixed(2);
    txtTLBS.innerText = hidTLBS.value;
    hidUnitCost.value = (txtMultiplier.value * txtListPrice.value).toFixed(2);
    txtUnitCost.innerText = '$' + hidUnitCost.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    /*
    if(hidFreightOverride.value != 'true'){
        txtFreight.value = (hidTLBS.value * 0.35).toFixed(2);
    }
    */
    //hidExtendedCost.value = ((hidUnitCost.value * txtQuantity.value) + parseFloat(txtFreight.value)).toFixed(2);
    hidExtendedCost.value = (hidUnitCost.value * txtQuantity.value);
    txtExtendedCost.innerText = '$' + hidExtendedCost.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    hidSalesPrice.value = (hidExtendedCost.value/(1-(txtMarginPercentage.value/100))).toFixed(2);
    txtSalesPrice.innerText = '$' + hidSalesPrice.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    
}

/*
function calculateScratchFreightOverride(rowIndex){
    
    var tblAttributs = 'pageId:formId:pbSelectedProducts:pbsScratchPad:rptScratchPad:' + (rowIndex - 1) + ':';
    
    var hidFreightOverride = document.getElementById(tblAttributs + 'hidScratchFreightOverride');
    hidFreightOverride.value = 'true';
    
    calculateScratchPad(rowIndex);
    
}
*/

function startSplash() {                        
    var divObj = document.getElementById('divLoading');            
    divObj.style.display='block';                                                   
}
  
function endSplash() {              
    document.getElementById('divLoading').style.display='none';                      
}

function cloneGroup(groupIndex){
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    hidGroupIndex.value = groupIndex;
    
    cloneGroupActionFunction();
    
    return false;
}

function cloneGroup(groupIndex){
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    hidGroupIndex.value = groupIndex;
    
    cloneGroupActionFunction();
    
    return false;
}

function newSubGroup(groupIndex){
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    hidGroupIndex.value = groupIndex;
    
    newSubGroupActionFunction();
    
    return false;
}

function dltGroup(groupIndex){
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    hidGroupIndex.value = groupIndex;
    
    deleteGroup();
    
    return false;
    
}

function addProducts(groupIndex,subGroupIndex){
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    
    hidGroupIndex.value = groupIndex;
    hidSubGroupIndex.value = subGroupIndex;
    
    addProductsActionFunction();
    
    return false;
}

function createSubGroup(groupIndex,subGroupIndex){
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    
    hidGroupIndex.value = groupIndex;
    hidSubGroupIndex.value = subGroupIndex;
    
    createSubGroupActionFunction();
    
    return false;
}

function dltSubGroup(groupIndex,subGroupIndex){
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    
    hidGroupIndex.value = groupIndex;
    hidSubGroupIndex.value = subGroupIndex;
    
    // deleteSubGroupActionFunction();
    // return false;

    // warning box when user delete a subgroup like items
        var result = confirm("Are you sure you want to delete?");
        if (result) {
            deleteSubGroupActionFunction();
        }
     return false;
    
}

function cloneSubGroup(groupIndex,subGroupIndex){

    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    
    hidGroupIndex.value = groupIndex;
    hidSubGroupIndex.value = subGroupIndex;
    
    cloneSubGroupActionFunction();
    
    return false;
    
}

function DeleteSelectedProductRow(groupIndex, subGroupIndex, productRowIndex, isFrom){
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    var hidProductRowIndex = document.getElementById('pageId:formId:hidProductRowIndex');
    
    hidGroupIndex.value = groupIndex;
    hidSubGroupIndex.value = subGroupIndex;
    hidProductRowIndex.value = productRowIndex - 1;
    
    if(isFrom == 'delete'){
        var result = confirm("Are you Sure to delete?");
        if (result) {
            deleteProductRowActionFunction();
        }
    }
    else{
        cloneProductRowActionFunction();
    }
    
    return false;
}

function openDescriptionPopup(groupIndex, subGroupIndex, rowIndex){
    
    var descBody = document.getElementById('cke_pageId:formId:txtAreaDescription');
    
    var divObj = document.getElementById('divDescriptionPopup');            
    divObj.style.display='block'; 
    
    var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:' + (rowIndex - 1) + ':';
    
    var txtDescription = document.getElementById(tblAttributs + 'hidDescription');
    var txtPopUpDescription = document.getElementById('pageId:formId:txtAreaDescription');
    
    //txtPopUpDescription.value = txtDescription.value;
    
    var iframeElement = descBody.childNodes[1].childNodes[1].childNodes[1];
    iframeElement.contentDocument.body.innerHTML = txtDescription.value;
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    var hidProductRowIndex = document.getElementById('pageId:formId:hidProductRowIndex');
    
    hidGroupIndex.value = groupIndex;
    hidSubGroupIndex.value = subGroupIndex;
    hidProductRowIndex.value = rowIndex - 1;
}

function updateDescription(){
    
    var descBody = document.getElementById('cke_pageId:formId:txtAreaDescription');
    
    var iframeElement = descBody.childNodes[1].childNodes[1].childNodes[1];
    
    var hidRichTextAreaDescriptions = document.getElementById('pageId:formId:hidRichTextAreaDescriptions');
    hidRichTextAreaDescriptions.value = iframeElement.contentDocument.body.innerHTML;
    
    closePopupDescription();
    
    updateDescriptionActionFunction();
    
    return false;
    
}

function validateGroupAndSubGroupName(isFrom){
    
    var isRequiredBlank = false;
               
    for(var i=0, iLen=-1; i>iLen; i++){
        
        var grandTotalGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':txtGrandTotalGroup');
                  
        if(grandTotalGroup == null){
            break;
        }
        
        var txtGroupName = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':txtGroupName');
        if(txtGroupName.value == '' || txtGroupName.value == null){
            txtGroupName.className = txtGroupName.className + " error";
            isRequiredBlank = true;
        }
        else{
            txtGroupName.className = txtGroupName.className.replace(" error", "");
        }
        
        for(var j=0, jLen=-1; j>jLen; j++){
            
            var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ i + ':rptProductSubGroup:' + j + ':hidGrandTotalSubGroup');
        
            if(hidGrandTotalSubGroup == null){
                break;
            }
           
            var txtSubGroupName = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + i + ':rptProductSubGroup:' + j + ':txtSubGroupName');
            
            if(txtSubGroupName.value == '' || txtSubGroupName.value == null){
                txtSubGroupName.className = txtSubGroupName.className + " error";
                isRequiredBlank = true;
            }
            else{
                txtSubGroupName.className = txtSubGroupName.className.replace(" error", "");
            }
        }
        
    }
    
    if(isRequiredBlank == true){
        alert("Group Name and Sub-Group Name is Required.");
        return false;
    }
    else{
        if(isFrom == 'quickSave'){
            quickSaveActionFunction();
        }
        else if(isFrom == 'preview'){
            previewActionFunction();
        }
        else{
            var retValue = validateCalculationsData();
            return retValue;
        }
        
    }
    
}

function closePopupDescription(){
    var divObj = document.getElementById('divDescriptionPopup');            
    divObj.style.display='none'; 
    return false;
}

function setBaseBidGroupName(groupName,groupIndex){
    
    var txtGroupNameBaseBidTotal = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':txtGroupNameBaseBidTotal');
    txtGroupNameBaseBidTotal.innerText = groupName.value;
    
}

function setSubGroupName(subGroupName, groupIndex, subGroupIndex){
    
    var txtSubGroupName = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':txtSubGroupNameTotal');
    txtSubGroupName.innerText = subGroupName.value;
    
}

function openReverseMarginPopup(isFrom ,groupIndex, subGroupIndex){
    
    var reverseMarginPopupHeader = document.getElementById('pageId:formId:txtReverseMarginHeader');
    
    if(isFrom == 'SubGroup'){
        popupTotalValuesOfReverseMarginSubGroup(isFrom ,groupIndex, subGroupIndex);
        
        reverseMarginPopupHeader.innerText = 'Subgroup Negotiation';
    }
    else{
        reverseMarginPopupHeader.innerText = 'Project Margin Negotiation';
        popupTotalValuesOfReverseMargin();
    }
                
    var divRevMargin = document.getElementById('divReverseMarginPopup');
    divRevMargin.style.display = 'block';
    return false;
    
} 

function closeReverseMarginPopup(){
    
    var divRevMargin = document.getElementById('divReverseMarginPopup');
    divRevMargin.style.display = 'none';
    return false;
    
}

function deleteAdditionDeduction(rowIndex){
    
    var hidProductRowIndex = document.getElementById('pageId:formId:hidProductRowIndex');
    hidProductRowIndex.value = rowIndex-1;
    
    deleteAdditionDeductionActionFunction();
    
    return false;
    
}

function upDownProductLineItem(groupIndex,subGroupIndex,rowIndex,upDown){
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    var hidProductRowIndex = document.getElementById('pageId:formId:hidProductRowIndex');
    
    hidGroupIndex.value = groupIndex;
    hidSubGroupIndex.value = subGroupIndex;
    hidProductRowIndex.value = rowIndex - 1;
    
    if(upDown == 'up'){
        upProductLineItemActionFunction();
    }
    else{
        downProductLineItemActionFunction();
    }
    
    return false;
    
}

function openNewProductDiv(){
    
    var txtProductName = document.getElementById('pageId:formId:pb:pbs:pbsiProductName:txtProductName');
    var txtProductCode = document.getElementById('pageId:formId:pb:pbs:txtProductCode');
    var txtManufacturer = document.getElementById('pageId:formId:pb:pbs:pbsiManufacturer:txtManufacturer');
    var txtProductType = document.getElementById('pageId:formId:pb:pbs:pbsiProductType:txtProductType');
    var txtWeight = document.getElementById('pageId:formId:pb:pbs:txtWeight');
    var txtIsActive = document.getElementById('pageId:formId:pb:pbs:txtIsActive');
    //var txtDescription = document.getElementById('pageId:formId:txtDescription');
    var txtStandardPrice = document.getElementById('pageId:formId:pb:pbsStandardPrice:pbsi:txtStandardPrice');
    var txtProductSummary = document.getElementById('pageId:formId:pb:pbs:pbsiProductSummary:txtProductSummary');
   
    txtProductName.value = '';
    txtProductCode.value = '';
    txtManufacturer.value = '';
    txtProductType.value = '';
    txtIsActive.checked = true;
    txtWeight.value = '';
    txtStandardPrice.value = '';
    txtProductSummary.value = '';
    
    var descBody = document.getElementById('cke_pageId:formId:pb:pbsDesc:pbsiDesc:txtDescription:textAreaDelegate_Product_Description__c');
    
    var iframeElement = descBody.childNodes[1].childNodes[1].childNodes[1];
    iframeElement.contentDocument.body.innerHTML = '';
    
    var divNewProduct = document.getElementById('divNewProductPopup');
    divNewProduct.style.display = 'block';
    return false;
}

function saveNewProduct(){
    
    if(validateNewProduct() == true) {
        insertNewProductActionFunction();
        closeAddNewProductDiv();
        return true;
    } else {
        alert('Please fill required fields prior to save');
        return false;
    }

}

function validateNewProduct() {
    
    var txtProductName = document.getElementById('pageId:formId:pb:pbs:pbsiProductName:txtProductName');
    var txtManufacturer = document.getElementById('pageId:formId:pb:pbs:pbsiManufacturer:txtManufacturer');
    var txtProductType = document.getElementById('pageId:formId:pb:pbs:pbsiProductType:txtProductType');
    var txtStandardPrice = document.getElementById('pageId:formId:pb:pbsStandardPrice:pbsi:txtStandardPrice');
    var txtProductSummary = document.getElementById('pageId:formId:pb:pbs:pbsiProductSummary:txtProductSummary');
    var descBody = document.getElementById('cke_pageId:formId:pb:pbsDesc:pbsiDesc:txtDescription:textAreaDelegate_Product_Description__c');
    
    var iframeElement = descBody.childNodes[1].childNodes[1].childNodes[1];
   

   if(txtProductName.value == ''
        || txtProductSummary.value == '' 
        || txtManufacturer.value == ''
        || txtStandardPrice.value == ''
        || iframeElement.contentDocument.body.innerHTML == ''
        || (txtProductType.disabled == false && txtProductType.value == '')
        ) {
        return false;
    } else {
        return true;
    }

    
}

function vlidateIntegers(fieldToValidate) {
    var fieldId = fieldToValidate.id;
    fieldToValidate.value = parseInt(fieldToValidate.value);
    if(fieldToValidate.value == 'NaN') {
        fieldToValidate.value = 0;
    }
}

function closeAddNewProductDiv(){
    var divNewProduct = document.getElementById('divNewProductPopup');
    divNewProduct.style.display = 'none';
    return false;
}

function scratchAddProduct(){
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    
    hidGroupIndex.value = -1;
    hidSubGroupIndex.value = -1;
    
    scratchAddProductActionFunction();
    
    return false;
            
}

function scratchAddCustomProduct(){
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    
    hidGroupIndex.value = -1;
    hidSubGroupIndex.value = -1;
    
    scratchAddCustomProductActionFunction();
    
    return false;
    
}

function DeleteScratchPadRow(rowIndex){
    
    var hidProductRowIndex = document.getElementById('pageId:formId:hidProductRowIndex');
    hidProductRowIndex.value = rowIndex - 1;
    
    scratchDeleteProductRowActionFunction();
    
    return false;
    
}

function upDownSubGroup(groupIndex, subGroupIndex, upDown){
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    
    hidGroupIndex.value = groupIndex;
    hidSubGroupIndex.value = subGroupIndex;
    
    if(upDown == 'up'){
        upSubGroupActionFunction();
    }
    else{
        downSubGroupActionFunction();
    }
    
    return false;
    
}

function checkAllCheckBox(groupIndex, subGroupIndex, isFrom){
    
    var checkHideCodeHeader = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':checkHideCodeHeader');
    var checkHideAmountHeader = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':checkHideAmountHeader');
    var checkHideLineHeader = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':checkHideLineHeader');
    var checkHideQuantityHeader = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':checkHideQuantityHeader');
    
    var tblAttributs = 'pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':rptProductSelected:';
    
    if(isFrom == 'Hide Code'){
    
        for(var k=0, kLen=-1; k>kLen; k++){
            var checkHideCode = document.getElementById(tblAttributs  + k + ':checkHideCode');
            if(checkHideCodeHeader.checked){
                checkHideCode.checked = true;
            }
            else{
                checkHideCode.checked = false;
            }
        }
        
    }
    else if(isFrom == 'Hide Amount'){
        
        for(var k=0, kLen=-1; k>kLen; k++){
            var checkHideAmount = document.getElementById(tblAttributs  + k + ':checkHideAmount');
            if(checkHideAmount == null){
                break;
            }
            if(checkHideAmountHeader.checked){
                checkHideAmount.checked = true;
            }
            else{
                checkHideAmount.checked = false;
            }
        }
        
    }
    else if(isFrom == 'Hide Line'){
    
        for(var k=0, kLen=-1; k>kLen; k++){
            var checkHideLine = document.getElementById(tblAttributs  + k + ':checkHideLine');
            if(checkHideLineHeader.checked){
                checkHideLine.checked = true;
            }
            else{
                checkHideLine.checked = false;
            }
        }
        
    }
    else{
        
        for(var k=0, kLen=-1; k>kLen; k++){
            var checkHideQuantity = document.getElementById(tblAttributs  + k + ':checkHideQuantity');
            if(checkHideQuantityHeader.checked){
                checkHideQuantity.checked = true;
            }
            else{
                checkHideQuantity.checked = false;
            }
        }
        
    }
    
}

function previewDocument(quoteId){
    var url = '/apex/generatequotedocument?Id='+quoteId;
    window.open(url, '_blank');
    return false;
}

function addCustomProduct(groupIndex, subGroupIndex){
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    
    hidGroupIndex.value = groupIndex;
    hidSubGroupIndex.value = subGroupIndex;
    
    addCustomProductActionFunction();
    
    return false;
}

function MoveLineItemToSubGroup(groupIndex, subGroupIndex, rowIndex){
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    var hidProductRowIndex = document.getElementById('pageId:formId:hidProductRowIndex');
    
    hidGroupIndex.value = groupIndex;
    hidSubGroupIndex.value = subGroupIndex;
    hidProductRowIndex.value = rowIndex - 1;
    
    quickSaveMoveLineItemActionFunction();
    
    return false;
}

function OpenMoveLineItemPopup(){
    
    var divMoveProductLineItem = document.getElementById('divMoveLineItem');
    divMoveProductLineItem.style.display = 'block';
    
    return false;
    
}

function CloseMoveLineItemPopup(){
    var divMoveProductLineItem = document.getElementById('divMoveLineItem');
    divMoveProductLineItem.style.display = 'none';
    return false;
}

function SelectedRowMoveLineItem(selectedRow, subGroupId, destGroupIndex, destSubGroupIndex){
    
    var tableGroupNames = document.getElementById('tblMoveLineItem');
    var hidSubGroupId = document.getElementById('pageId:formId:hidSubGroupId');
    var hidGroupIndexMoveLineItem = document.getElementById('pageId:formId:hidGroupIndexMoveLineItem');
    var hidSubGroupIndexMoveLineItem = document.getElementById('pageId:formId:hidSubGroupIndexMoveLineItem');
    
    for(var i = 0; i<tableGroupNames.rows.length;i++){
        tableGroupNames.rows[i].className = '';
    }
    
    selectedRow.className = 'selected';
    
    hidSubGroupId.value = subGroupId;
    hidGroupIndexMoveLineItem.value = destGroupIndex;
    hidSubGroupIndexMoveLineItem.value = destSubGroupIndex;
    
    return false;
}

function CalculateMoveLineItemPricing(){
    var hidGroupIndexMoveLineItem = document.getElementById('pageId:formId:hidGroupIndexMoveLineItem');
    var hidSubGroupIndexMoveLineItem = document.getElementById('pageId:formId:hidSubGroupIndexMoveLineItem');
    
    var hidGroupIndex = document.getElementById('pageId:formId:hidGroupIndex');
    var hidSubGroupIndex = document.getElementById('pageId:formId:hidSubGroupIndex');
    
    calculateSubGroupPrice(hidGroupIndexMoveLineItem.value, hidSubGroupIndexMoveLineItem.value, 0);
    calculateGroupPrice(hidGroupIndexMoveLineItem.value);
    
    calculateSubGroupPrice(hidGroupIndex.value, hidSubGroupIndex.value , 0);
    calculateGroupPrice(hidGroupIndex.value);
    
    CloseMoveLineItemPopup();
}

function roundOff(groupIndex, subGroupIndex){
    var hidGrandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:' + groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':hidGrandTotalSubGroup');
    var grandTotalSubGroup = document.getElementById('pageId:formId:pbSelectedProducts:rptSelectedProductsGroup:'+ groupIndex + ':rptProductSubGroup:' + subGroupIndex + ':txtGrandTotalSubGroup');
    
    if(hidGrandTotalSubGroup.value != null && hidGrandTotalSubGroup.value != ''){
        var roundOffTotal = Math.round(hidGrandTotalSubGroup.value);
        hidGrandTotalSubGroup.value = roundOffTotal.toFixed(2);
        grandTotalSubGroup.innerText = '$' + hidGrandTotalSubGroup.value.replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
    }
    
    calculateGroupPrice(groupIndex);
    
    return false;
}