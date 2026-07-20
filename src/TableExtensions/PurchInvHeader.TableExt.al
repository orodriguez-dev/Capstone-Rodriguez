namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Purchases.History;

/// <summary>
/// TableExtension EIE Purch. Inv. Header (ID 70505) extends Record Purch. Inv. Header.
/// </summary>
tableextension 70505 "EIE Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        // Add changes to table fields here
        field(70500; "EIE Id. Transaction Api"; Code[20])
        {
            Caption = 'Id. Transaction Api';
            Editable = false;
        }
    }

    var
}