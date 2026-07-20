namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Foundation.Company;

/// <summary>
/// PageExtension EIE Company Information (ID 70500) extends Record Company Information.
/// </summary>
pageextension 70500 "EIE Company Information" extends "Company Information"
{
    layout
    {
        // Add changes to page layout here
        addafter(General)
        {
            group("EIE Electronic Invoicing")
            {
                Caption = 'Electronic Invoicing';

                field("EIE Automatic Electronic Inv."; Rec."EIE Automatic Electronic Inv.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Activate Electronic Invoicing field.';
                    Visible = false;
                }
                field("EIE Authorization API URL"; Rec."EIE Authorization API URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Authorization API URL field.';
                }
                field("EIE Consult API URL"; Rec."EIE Consult API URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Consult API URL field.';
                }
                field("EIE Token API"; Rec."EIE Token API")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Token URL field.';
                }
                field("EIE Company Id"; Rec."EIE Company Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Id field.';
                }
                field("EIE Contract Id"; Rec."EIE Contract Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contract Id field.';
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
}