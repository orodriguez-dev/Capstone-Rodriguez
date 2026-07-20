namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Inventory.Transfer;

/// <summary>
/// TableExtension EIE Transfer Shipment Header (ID 70504) extends Record Transfer Shipment Header.
/// </summary>
tableextension 70504 "EIE Transfer Shipment Header" extends "Transfer Shipment Header"
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