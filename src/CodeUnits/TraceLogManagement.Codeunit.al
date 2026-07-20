namespace GMAS.ELectronicInvoicing.Ecuador;

/// <summary>
/// Codeunit EIE Trace Log Management (ID 70510).
/// Gestiona la inserción de registros en el log de trazabilidad de facturación electrónica.
/// Este codeunit debe ser llamado desde las codeunits de envío, consulta de estado,
/// reenvío y descarga XML, para mantener un historial completo del proceso.
/// </summary>
codeunit 70510 "EIE Trace Log Management"
{
    trigger OnRun()
    begin
    end;

    /// <summary>
    /// Inserta un registro de trazabilidad en la tabla EIE Electronic Trace Log.
    /// Llamar este procedimiento desde cualquier codeunit que ejecute una operación
    /// relacionada con facturación electrónica.
    /// </summary>
    /// <param name="DocumentType">Tipo de documento tributario electrónico.</param>
    /// <param name="DocumentNo">Número del documento origen en Business Central.</param>
    /// <param name="CustomerVendorNo">Código del cliente o proveedor.</param>
    /// <param name="CustomerVendorName">Nombre del cliente o proveedor.</param>
    /// <param name="ActionType">Tipo de acción realizada (envío, consulta, reenvío, etc.).</param>
    /// <param name="APIConsumed">Servicio API consumido.</param>
    /// <param name="ReceivedStatus">Estado devuelto por la plataforma externa.</param>
    /// <param name="ResponseMessage">Mensaje de respuesta de la API o de la extensión.</param>
    /// <param name="APITransactionID">Identificador de transacción devuelto por GrupoMAS.</param>
    /// <param name="SourceTableID">ID de la tabla origen del documento en Business Central.</param>
    procedure InsertTraceLog(
        DocumentType: Enum "EIE Trace Document Type";
        DocumentNo: Code[20];
        CustomerVendorNo: Code[20];
        CustomerVendorName: Text[100];
        ActionType: Enum "EIE Trace Action Type";
        APIConsumed: Enum "EIE Trace API Consumed";
        ReceivedStatus: Enum "GMAS EI Electronic Doc. Status";
        ResponseMessage: Text;
        APITransactionID: Code[50];
        SourceTableID: Integer)
    var
        TraceLog: Record "EIE Electronic Trace Log";
    begin
        TraceLog.Init();
        // Entry No. es AutoIncrement — no se asigna manualmente
        TraceLog."Date Time" := CurrentDateTime();
        TraceLog."User ID" := CopyStr(UserId(), 1, MaxStrLen(TraceLog."User ID"));
        TraceLog."Document Type" := DocumentType;
        TraceLog."Document No." := DocumentNo;
        TraceLog."Customer Vendor No." := CustomerVendorNo;
        TraceLog."Customer Vendor Name" := CustomerVendorName;
        TraceLog."Action Type" := ActionType;
        TraceLog."API Consumed" := APIConsumed;
        TraceLog."Received Status" := ReceivedStatus;
        TraceLog."Response Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TraceLog."Response Message"));
        TraceLog."API Transaction ID" := APITransactionID;
        TraceLog."Source Table ID" := SourceTableID;
        TraceLog.Insert(true);
    end;
}
