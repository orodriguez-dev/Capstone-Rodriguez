namespace GMAS.ELectronicInvoicing.Ecuador;

/// <summary>
/// PageExtension EIE GMAS SRI Tabla 04 (ID 70513) extends Record GMAS SRI Tabla 04.
/// </summary>
pageextension 70513 "EIE GMAS SRI Tabla 04" extends "GMAS SRI Tabla 04"
{
    layout
    {
        // Add changes to page layout here
        addafter(Default)
        {
            field("EIE Automatic Electronic Inv."; Rec."EIE Automatic Electronic Inv.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Automatic Electronic Invoicing field.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
}