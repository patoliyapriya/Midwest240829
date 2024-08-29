<aura:application extends="force:slds">
   <aura:attribute name="quoteId" type="String"></aura:attribute>
    <aura:handler name="init" value="{!this}" action="{!c.handleInit}"/>
	<c:quoteContainer quoteId="{!v.quoteId}"></c:quoteContainer>
</aura:application>