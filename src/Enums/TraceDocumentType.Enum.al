namespace GMAS.ELectronicInvoicing.Ecuador;

/// <summary>
/// Enum EIE Trace Document Type (ID 70510).
/// Electronic tax document types supported by the extension.
/// </summary>
enum 70510 "EIE Trace Document Type"
{
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Sales Invoice")
    {
        Caption = 'Sales Invoice';
    }
    value(2; "Sales Credit Memo")
    {
        Caption = 'Sales Credit Memo';
    }
    value(3; "Sales Shipment")
    {
        Caption = 'Sales Shipment';
    }
    value(4; "Purchase Invoice")
    {
        Caption = 'Purchase Settlement';
    }
    value(5; "Purchase Withholding")
    {
        Caption = 'Purchase Withholding';
    }
}
