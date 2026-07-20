namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Sales.History;

/// <summary>
/// TableExtension EIE Sales Cr.Memo Header (ID 70502) extends Record Sales Cr.Memo Header.
/// </summary>
tableextension 70502 "EIE Sales Cr.Memo Header" extends "Sales Cr.Memo Header"
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