namespace GMAS.ELectronicInvoicing.Ecuador;

/// <summary>
/// TableExtension EIE Purch. Withh. Header (ID 70506) extends Record GMAS SRI Purch. Withh. Header.
/// </summary>
tableextension 70506 "EIE Purch. Withh. Header" extends "GMAS SRI Purch. Withh. Header"
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