namespace GMAS.ELectronicInvoicing.Ecuador;

/// <summary>
/// Enum EIE Trace API Consumed (ID 70512).
/// Identifies which API service was consumed in each traceability action.
/// </summary>
enum 70512 "EIE Trace API Consumed"
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
    value(2; Consult)
    {
        Caption = 'Consult';
    }
    value(3; "Download")
    {
        Caption = 'Download';
    }
}
