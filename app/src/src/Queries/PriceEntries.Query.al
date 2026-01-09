query 50046 "ARC Price Entries"
{
    Caption = 'Price Entries';

    elements
    {
        dataitem(PriceEntries; "ARC Price Entry")
        {
            column(entryNo; "Entry No.") { }
            column(shortcutDim1Code; "Shorcut Dimension 1 Code") { }
            column(shortcutDim2Code; "Shorcut Dimension 2 Code") { }
            column(entityType; "Entity Type") { }
            column(entityNo; "Entity No.") { }
            column(entityName; "Entity Name") { }
            column(type; Type) { }
            column(no; "No.") { }
            column(no2; "No. 2") { }
            column(description; Description) { }
            column(agencyInclude; "Agency Include") { }
            column(mcpInclude; "MCP Include") { }
            column(minimumQuantity; "Minimum Quantity") { }
            column(unitOfMeasureCode; "Unit of Measure Code") { }
            column(variantCode; "Variant Code") { }
            column(manufacturerCode; "Manufacturer Code") { }
            column(itemCategoryCode; "Item Category Code") { }
            column(method; Method) { }
            column(effectiveDate; "Effective Date") { }
            column(expirationDate; "Expiration Date") { }
            column(alwaysUse; "Always Use") { }
            column(comment; Comment) { }
            column(createdBy; "Created By") { }
            column(createdOn; "Created On") { }
            column(currencyCode; "Currency Code") { }
            column(modifiedBy; "Modified By") { }
            column(modifiedOn; "Modified On") { }
            column(netUnitPrice; "Net Unit Price") { }
            column(methodValue; "Method Value") { }
            column(status; Status) { }
            column(minimumPrice; "Minimum Price") { }
            column(vendorNo; "Vendor No.") { }
            column(markupValue; "Markup Value") { }
            column(deleteEntry;"Delete Entry") { }

            dataitem(Customer; Customer)
            {
                DataItemLink = "No." = PriceEntries."Entity No.";
                SqlJoinType = LeftOuterJoin;

                column(customerNo; "No.") { }
                column(customerName; Name) { }
                column(eCommerceEnabled; "ARC eCommerce Enabled") { }
            }
        }
    }

    trigger OnBeforeOpen();
    begin
    end;
}