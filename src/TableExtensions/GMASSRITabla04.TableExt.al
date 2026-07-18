/// <summary>
/// TableExtension EIE GMAS SRI Tabla 04 (ID 70507) extends Record GMAS SRI Tabla 04.
/// </summary>
tableextension 70507 "EIE GMAS SRI Tabla 04" extends "GMAS SRI Tabla 04"
{
    fields
    {
        // Add changes to table fields here
        field(70500; "EIE Automatic Electronic Inv."; Boolean)
        {
            Caption = 'Automatic Electronic Invoicing';
        }
    }

    var
}