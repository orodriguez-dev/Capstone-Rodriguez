namespace GMAS.ELectronicInvoicing.Ecuador;

/// <summary>
/// Enum EIE Trace Action Type (ID 70511).
/// Action types recorded in the electronic invoicing traceability log.
/// </summary>
enum 70511 "EIE Trace Action Type"
{
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Send)
    {
        Caption = 'Send';
    }
    value(2; "Status Query")
    {
        Caption = 'Status Query';
    }
    value(3; "Resend")
    {
        Caption = 'Resend';
    }
    value(4; "XML Download")
    {
        Caption = 'XML Download';
    }
    value(5; "Validation Error")
    {
        Caption = 'Validation Error';
    }
    value(6; "API Response")
    {
        Caption = 'API Response';
    }
}
