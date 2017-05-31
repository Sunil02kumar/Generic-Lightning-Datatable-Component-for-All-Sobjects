<aura:application >
    <c:LightningJSONDataTable objAPIname="Contact" fieldsAPINameList="Name, Account.Name, Email"
                              columnsLabelList="Contact name, Account Name, Email"
                              sortingOrder="LastModifiedDate DESC" columnForHyperLink="Name"
                              filterCriteria="Email != null" recordsLimit="100"/>
</aura:application>