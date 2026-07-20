namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Sales.History;

/// <summary>
/// TableExtension EIE Sales Shipment Header (ID 70503) extends Record Sales Shipment Header.
/// </summary>
tableextension 70503 "EIE Sales Shipment Header" extends "Sales Shipment Header"
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