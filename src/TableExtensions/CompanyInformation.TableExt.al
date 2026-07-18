/// <summary>
/// TableExtension EIE Company Information (ID 70500) extends Record Company Information.
/// </summary>
tableextension 70500 "EIE Company Information" extends "Company Information"
{
    fields
    {
        // Add changes to table fields here
        field(70500; "EIE Automatic Electronic Inv."; Boolean)
        {
            Caption = 'Automatic Electronic Invoicing';
        }
        field(70501; "EIE Authorization API URL"; Text[250])
        {
            Caption = 'Authorization API URL';
            ExtendedDatatype = URL;
        }
        field(70502; "EIE Consult API URL"; Text[250])
        {
            Caption = 'Consult API URL';
            ExtendedDatatype = URL;
        }
        field(70503; "EIE Token API"; Text[250])
        {
            Caption = 'Token API';
        }

        field(70504; "EIE Company Id"; Code[4])
        {
            Caption = 'Company Id';
        }
        field(70505; "EIE Contract Id"; Code[4])
        {
            Caption = 'Contract Id';
        }
    }

    var
}