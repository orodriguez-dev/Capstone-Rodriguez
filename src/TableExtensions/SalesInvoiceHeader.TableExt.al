namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Sales.History;

/// <summary>
/// TableExtension EIE Sales Invoice Header (ID 70501) extends Record Sales Invoice Header.
/// </summary>
tableextension 70501 "EIE Sales Invoice Header" extends "Sales Invoice Header"
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