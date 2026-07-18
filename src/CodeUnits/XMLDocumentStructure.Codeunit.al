/// <summary>
/// GMAS - Codeunit EIE XML Document Structure (ID 70501).
/// </summary>
codeunit 70501 "EIE XML Document Structure"
{
    trigger OnRun()
    var
    //TempBlob: Codeunit "Temp Blob";
    //TxtEncoding: TextEncoding;
    //FileOutStream: OutStream;
    //FileInStream: InStream;
    //FileName: Text;
    begin
        //FileName := 'PruevaEstructuraXml.xml';
        //TxtEncoding := TextEncoding::UTF8;

        XmlDoc := XmlDocument.Create();
        XmlDoc.Add(DocumentXmlElement);

        //TempBlob.CreateOutStream(FileOutStream, TxtEncoding);
        //XmlDoc.WriteTo(FileOutStream);
        //TempBlob.CreateInStream(FileInStream, TxtEncoding);
        //DownloadFromStream(FileInStream, '', '', '', FileName);
    end;

    var
        XmlDoc: XmlDocument;
        DocumentXmlElement: XmlElement;
        NombreEmisor: Text;
        NombreCompania: Text;
        NombreArchivo: Text;
        IdentificadorTransaccion: Text;
        IdEmpresa: Text;
        IdContrato: Text;
        Canal: Text;
        IpDevice: Text;
        Usuario: Text;
        FechaHoraTrx: Text;
        VersionDocumento: Text;
        RazonSocial: Text;
        NombreComercial: Text;
        Ruc: Text;
        CodDoc: Text;
        Estab: Text;
        PtoEmi: Text;
        Secuencial: Text;
        DirMatriz: Text;
        AgenteRetencion: Text;
        FechaEmision: Text;
        DirEstablecimiento: Text;
        TipoIdentificacionSujetoRetenido: Text;
        RazonSocialSujetoRetenido: Text;
        IdentificacionSujetoRetenido: Text;
        PeriodoFiscal: Text;
        DirPartida: Text;
        RazonSocialTransportista: Text;
        TipoIdentificacionTransportista: Text;
        RucTransportista: Text;
        FechaIniTransporte: Text;
        FechaFinTransporte: Text;
        Placa: Text;
        IdentificacionDestinatario: Text;
        DirDestinatario: Text;
        MotivoTraslado: Text;
        RazonSocialDestinatario: Text;
        TipoIdentificacionComprador: Text;
        TipoIdentificacionProveedor: Text;
        RazonSocialProveedor: Text;
        IdentificacionProveedor: Text;
        DireccionProveedor: Text;
        RazonsocialComprador: Text;
        Razon: Text;
        IdentificacionComprador: Text;
        Direccioncomprador: Text;
        ContribuyenteEspecial: Text;
        ObligadoContabilidad: Text;
        CodDocModificado: Text;
        NumDocModificado: Text;
        FechaEmisionDocSustento: Text;
        TotalSinImpuestos: Text;
        totalConImpuestos: Text;
        TotalDescuento: Text;
        ComercioExterior: Text;
        IncoTermFactura: Text;
        LugarIncoTerm: Text;
        PaisOrigen: Text;
        PuertoEmbarque: Text;
        PuertoDestino: Text;
        PaisDestino: Text;
        IncoTermTotalSinImpuestos: Text;
        PaisAdquisicion: Text;
        FleteInternacional: Text;
        SeguroInternacional: Text;
        GastosAduaneros: Text;
        GastosTransporteOtros: Text;
        ValorModificacion: Text;
        Moneda: Text;
        Propina: Text;
        ImporteTotal: Text;
        Codigo: Text;
        CodigoPorcentaje: Text;
        DescuentoAdicional: Text;
        CodigoRetencion: Text;
        PorcentajeRetener: Text;
        ValorRetenido: Text;
        CodDocSustento: Text;
        NumDocSustento: Text;
        TotalRetenido: Text;
        Concepto: Text;
        BaseImponible: Text;
        Tarifa: Text;
        Valor: Text;
        ValorTotal: Text;
        Motivo: Text;
        ValorTotal2: Text;
        CodigoPrincipal: Text;
        CodigoAuxiliar: Text;
        CodigoInterno: Text;
        CodigoAdicional: Text;
        LnItmSeq: Text;
        Descripcion: Text;
        UnidadMedida: Text;
        Cantidad: Text;
        PrecioUnitario: Text;
        Descuento: Text;
        PrecioTotalSinImpuesto: Text;
        CodigoImpItem: Text;
        CodigoPorcentajeItem: Text;
        TarifaImpItem: Text;
        BaseImponibleItem: Text;
        ValorImpItem: Text;
        MontoLetras: Text;
        Email: Text;
        Telefono: Text;
        DirAdq: Text;
        Ciudad: Text;
        Vencimiento: Text;
        CodCliente: Text;
        Ov: Text;
        Celular: Text;
        Otro: Text;
        //Informacion de reembolsos
        TipoIdentificacionProveedorReembolso: Text;
        IdentificacionProveedorReembolso: Text;
        CodPaisPagoProveedorReembolso: Text;
        TipoProveedorReembolso: Text;
        CodDocReembolso: Text;
        CodDocReemb: Text;
        TotalComprobantesReembolso: Text;
        TotalBaseImponibleReembolso: Text;
        TotalImpuestoReembolso: Text;
        EstabDocReembolso: Text;
        ptoEmiDocReembolso: Text;
        SecuencialDocReembolso: Text;
        FechaEmisionDocReembolso: Text;
        NumeroautorizacionDocReemb: Text;
        Dexrowid: Text;
        CodigoImpReemb: Text;
        CodigoPorcentajeReemb: Text;
        TarifaImpReemb: Text;
        BaseImponibleReembolso: Text;
        ImpuestoReembolso: Text;
        FormaPago: Text;
        Total: Text;
        Plazo: Text;
        UnidadTiempo: Text;
        DescTrabajo: Text;
        IdConductor: Text;
        NombreConductor: Text;
        AddDataXmlElement: XmlElement;
        AddDataLineXmlElement: XmlElement;
        TipoSujetoRetenido: Text;
        ParteRel: Text;
        CodSustento: Text;
        FechaRegistroContable: Text;
        NumAutDocSustento: Text;
        PagoLocExt: Text;
        TipoRegi: Text;
        PaisEfecPago: Text;
        AplicConvDobTrib: Text;
        PagExtSujRetNorLeg: Text;
        PagoRegFis: Text;
        FechaPagoDiv: Text;
        ImRentaSoc: Text;
        EjerFisUtDiv: Text;
        NumCajBan: Text;
        PrecCajBan: Text;
        BaseImponibleRet: Text;
        CodImpuestoDocSustento: Text;
        ValorImpuesto: Text;

    /// <summary>
    /// GetXmlDocument.
    /// </summary>
    /// <returns>Return value of type XmlDocument.</returns>
    procedure GetFileXmlDocument(): XmlDocument
    begin
        exit(XmlDoc);
    end;

    /// <summary>
    /// MyProcedure.
    /// </summary>
    /// <param name="FileName">Text.</param>
    procedure DownloadFileXml(FileName: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        FileOutStream: OutStream;
        FileInStream: InStream;
        TxtEncoding: TextEncoding;
    begin
        TxtEncoding := TextEncoding::UTF8;

        TempBlob.CreateOutStream(FileOutStream, TxtEncoding);
        XmlDoc.WriteTo(FileOutStream);
        TempBlob.CreateInStream(FileInStream, TxtEncoding);
        DownloadFromStream(FileInStream, '', '', '', FileName);
    end;

    /// <summary>
    /// SetData.
    /// </summary>
    procedure AddData()
    begin
        DocumentXmlElement.Add(GenerateData());
    end;

    /// <summary>
    /// AddAdicionalData.
    /// </summary>
    /// <param name="AttName">Text.</param>
    /// <param name="AttValue">Text.</param>
    procedure setAdicionalData(AttName: Text; AttValue: Text)
    var
        FieldXmlElement: XmlElement;
    begin
        if (AttName <> '') and (AttValue <> '') then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', attName);
            FieldXmlElement.Add(AttValue);
            AddDataXmlElement.Add(FieldXmlElement);
        end;
    end;

    /// <summary>
    /// AddAdicionalData.
    /// </summary>
    /// <param name="AttName">Text.</param>
    /// <param name="AttValue">Text.</param>
    procedure setAdicionalDataLine(AttName: Text; AttValue: Text)
    var
        FieldXmlElement: XmlElement;
    begin
        if (AttName <> '') and (AttValue <> '') then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', attName);
            FieldXmlElement.Add(AttValue);
            AddDataLineXmlElement.Add(FieldXmlElement);
        end;
    end;

    /// <summary>
    /// CreateNodeDocument.
    /// </summary>
    /// <param name="TipoDoc">Text.</param>
    procedure CreateNodeDocument(TipoDoc: Text)
    begin
        DocumentXmlElement := XmlElement.Create('Documento');
        DocumentXmlElement.SetAttribute('tipo', TipoDoc);
        AddDataXmlElement := XmlElement.Create('addData');
        AddDataLineXmlElement := XmlElement.Create('addDataLine');
    end;

    local procedure GenerateData(): XmlElement
    var
        DataXmlElement: XmlElement;
        FieldXmlElement: XmlElement;
        AddXmlNodeList: XmlNodeList;
        AddXmlNode: XmlNode;
    begin
        DataXmlElement := XmlElement.Create('data');

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'nombreemisor');
        if NombreEmisor <> '' then
            FieldXmlElement.Add(NombreEmisor);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'nombrecompania');
        if NombreCompania <> '' then
            FieldXmlElement.Add(NombreCompania);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'nombrearchivo');
        if NombreArchivo <> '' then
            FieldXmlElement.Add(NombreArchivo);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'identificadortransaccion');
        if IdentificadorTransaccion <> '' then
            FieldXmlElement.Add(IdentificadorTransaccion);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'idempresa');
        if IdEmpresa <> '' then
            FieldXmlElement.Add(IdEmpresa);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'idcontrato');
        if IdContrato <> '' then
            FieldXmlElement.Add(IdContrato);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'canal');
        if Canal <> '' then
            FieldXmlElement.Add(Canal);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'ipdevice');
        if IpDevice <> '' then
            FieldXmlElement.Add(IpDevice);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'usuario');
        if Usuario <> '' then
            FieldXmlElement.Add(Usuario);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'fechahoratrx');
        if FechaHoraTrx <> '' then
            FieldXmlElement.Add(FechaHoraTrx);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'versiondocumento');
        if VersionDocumento <> '' then
            FieldXmlElement.Add(VersionDocumento);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'razonsocial');
        if RazonSocial <> '' then
            FieldXmlElement.Add(RazonSocial);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'nombrecomercial');
        if NombreComercial <> '' then
            FieldXmlElement.Add(NombreComercial);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'ruc');
        if Ruc <> '' then
            FieldXmlElement.Add(Ruc);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'coddoc');
        if CodDoc <> '' then
            FieldXmlElement.Add(CodDoc);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'estab');
        if Estab <> '' then
            FieldXmlElement.Add(Estab);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'ptoemi');
        if PtoEmi <> '' then
            FieldXmlElement.Add(PtoEmi);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'secuencial');
        if Secuencial <> '' then
            FieldXmlElement.Add(Secuencial);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'dirmatriz');
        if DirMatriz <> '' then
            FieldXmlElement.Add(DirMatriz);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'agenteRetencion');
        if AgenteRetencion <> '' then
            FieldXmlElement.Add(AgenteRetencion);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'fechaemision');
        if FechaEmision <> '' then
            FieldXmlElement.Add(FechaEmision);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'direstablecimiento');
        if DirEstablecimiento <> '' then
            FieldXmlElement.Add(DirEstablecimiento);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'razonSocialSujetoRetenido');
        if RazonSocialSujetoRetenido <> '' then
            FieldXmlElement.Add(RazonSocialSujetoRetenido);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'tipoIdentificacionSujetoRetenido');
        if TipoIdentificacionSujetoRetenido <> '' then
            FieldXmlElement.Add(TipoIdentificacionSujetoRetenido);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'identificacionSujetoRetenido');
        if IdentificacionSujetoRetenido <> '' then
            FieldXmlElement.Add(IdentificacionSujetoRetenido);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'periodoFiscal');
        if PeriodoFiscal <> '' then
            FieldXmlElement.Add(PeriodoFiscal);
        DataXmlElement.Add(FieldXmlElement);

        if DirPartida <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'dirPartida');
            FieldXmlElement.Add(DirPartida);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if RazonSocialTransportista <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'razonSocialTransportista');
            FieldXmlElement.Add(RazonSocialTransportista);
            DataXmlElement.Add(FieldXmlElement);
        end;


        if TipoIdentificacionTransportista <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'tipoIdentificacionTransportista');
            FieldXmlElement.Add(TipoIdentificacionTransportista);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if RucTransportista <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'rucTransportista');
            FieldXmlElement.Add(RucTransportista);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if FechaIniTransporte <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'fechaIniTransporte');
            FieldXmlElement.Add(FechaIniTransporte);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if FechaFinTransporte <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'fechaFinTransporte');
            FieldXmlElement.Add(FechaFinTransporte);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if Placa <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'placa');
            FieldXmlElement.Add(Placa);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if IdentificacionDestinatario <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'identificacionDestinatario');
            FieldXmlElement.Add(IdentificacionDestinatario);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if RazonSocialDestinatario <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'razonSocialDestinatario');
            FieldXmlElement.Add(RazonSocialDestinatario);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if DirDestinatario <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'dirDestinatario');
            FieldXmlElement.Add(DirDestinatario);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if MotivoTraslado <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'motivoTraslado');
            FieldXmlElement.Add(MotivoTraslado);
            DataXmlElement.Add(FieldXmlElement);
        end;

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'tipoidentificacioncomprador');
        if TipoIdentificacionComprador <> '' then
            FieldXmlElement.Add(TipoIdentificacionComprador);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'tipoIdentificacionProveedor');
        if TipoIdentificacionProveedor <> '' then
            FieldXmlElement.Add(TipoIdentificacionProveedor);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'razonSocialProveedor');
        if RazonSocialProveedor <> '' then
            FieldXmlElement.Add(RazonSocialProveedor);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'identificacionProveedor');
        if IdentificacionProveedor <> '' then
            FieldXmlElement.Add(IdentificacionProveedor);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'direccionProveedor');
        if DireccionProveedor <> '' then
            FieldXmlElement.Add(DireccionProveedor);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'razonsocialcomprador');
        if RazonsocialComprador <> '' then
            FieldXmlElement.Add(RazonsocialComprador);
        DataXmlElement.Add(FieldXmlElement);

        if Razon <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'razon');
            FieldXmlElement.Add(Razon);
            DataXmlElement.Add(FieldXmlElement);
        end;

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'identificacioncomprador');
        if IdentificacionComprador <> '' then
            FieldXmlElement.Add(IdentificacionComprador);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'direccioncomprador');
        if Direccioncomprador <> '' then
            FieldXmlElement.Add(Direccioncomprador);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'contribuyenteespecial');
        if ContribuyenteEspecial <> '' then
            FieldXmlElement.Add(ContribuyenteEspecial);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'obligadocontabilidad');
        if ObligadoContabilidad <> '' then
            FieldXmlElement.Add(ObligadoContabilidad);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'totalConImpuestos');
        if TotalConImpuestos <> '' then
            FieldXmlElement.Add(TotalConImpuestos);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'coddocmodificado');
        if CodDocModificado <> '' then
            FieldXmlElement.Add(CodDocModificado);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'numdocmodificado');
        if NumDocModificado <> '' then
            FieldXmlElement.Add(NumDocModificado);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'fechaemisiondocsustento');
        if FechaEmisionDocSustento <> '' then
            FieldXmlElement.Add(FechaEmisionDocSustento);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'totalsinimpuestos');
        if TotalSinImpuestos <> '' then
            FieldXmlElement.Add(TotalSinImpuestos);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'totalDescuento');
        if TotalDescuento <> '' then
            FieldXmlElement.Add(TotalDescuento);
        DataXmlElement.Add(FieldXmlElement);

        if ComercioExterior <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'comercioExterior');
            FieldXmlElement.Add(ComercioExterior);
            DataXmlElement.Add(FieldXmlElement);
        end;
        if IncoTermFactura <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'incoTermFactura');
            FieldXmlElement.Add(IncoTermFactura);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if LugarIncoTerm <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'lugarIncoTerm');
            FieldXmlElement.Add(LugarIncoTerm);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if PaisOrigen <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'paisOrigen');
            FieldXmlElement.Add(PaisOrigen);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if PuertoEmbarque <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'puertoEmbarque');
            FieldXmlElement.Add(PuertoEmbarque);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if PuertoDestino <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'puertoDestino');
            FieldXmlElement.Add(PuertoDestino);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if PaisDestino <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'paisDestino');
            FieldXmlElement.Add(PaisDestino);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if IncoTermTotalSinImpuestos <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'incoTermTotalSinImpuestos');
            FieldXmlElement.Add(IncoTermTotalSinImpuestos);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if PaisAdquisicion <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'paisAdquisicion');
            FieldXmlElement.Add(PaisAdquisicion);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if FleteInternacional <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'fleteInternacional');
            FieldXmlElement.Add(FleteInternacional);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if SeguroInternacional <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'seguroInternacional');
            FieldXmlElement.Add(SeguroInternacional);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if GastosAduaneros <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'gastosAduaneros');
            FieldXmlElement.Add(GastosAduaneros);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if GastosTransporteOtros <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'gastosTransporteOtros');
            FieldXmlElement.Add(GastosTransporteOtros);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if CodDocReemb <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'codDocReemb');

            FieldXmlElement.Add(CodDocReemb);
            DataXmlElement.Add(FieldXmlElement);
        end;

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'totalComprobantesReembolso');
        if TotalComprobantesReembolso <> '' then
            FieldXmlElement.Add(TotalComprobantesReembolso);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'totalBaseImponibleReembolso');
        if TotalBaseImponibleReembolso <> '' then
            FieldXmlElement.Add(TotalBaseImponibleReembolso);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'totalImpuestoReembolso');
        if TotalImpuestoReembolso <> '' then
            FieldXmlElement.Add(TotalImpuestoReembolso);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'valormodificacion');
        if ValorModificacion <> '' then
            FieldXmlElement.Add(ValorModificacion);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'moneda');
        if Moneda <> '' then
            FieldXmlElement.Add(Moneda);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'formaPago');
        if FormaPago <> '' then
            FieldXmlElement.Add(FormaPago);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'total');
        if Total <> '' then
            FieldXmlElement.Add(Total);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'plazo');
        if plazo <> '' then
            FieldXmlElement.Add(plazo);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'unidadTiempo');
        if UnidadTiempo <> '' then
            FieldXmlElement.Add(UnidadTiempo);
        DataXmlElement.Add(FieldXmlElement);


        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', '_DescTrabajo');
        if DescTrabajo <> '' then
            FieldXmlElement.Add(DescTrabajo);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'propina');
        if Propina <> '' then
            FieldXmlElement.Add(Propina);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'importeTotal');
        if ImporteTotal <> '' then
            FieldXmlElement.Add(ImporteTotal);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'codigo');
        if Codigo <> '' then
            FieldXmlElement.Add(Codigo);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'codigoporcentaje');
        if CodigoPorcentaje <> '' then
            FieldXmlElement.Add(CodigoPorcentaje);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'descuentoAdicional');
        if DescuentoAdicional <> '' then
            FieldXmlElement.Add(DescuentoAdicional);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'baseimponible');
        if BaseImponible <> '' then
            FieldXmlElement.Add(BaseImponible);
        DataXmlElement.Add(FieldXmlElement);

        if BaseImponibleRet <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'baseImponibleRet');
            FieldXmlElement.Add(BaseImponibleRet);
            DataXmlElement.Add(FieldXmlElement);
        end;

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'tarifa');
        if Tarifa <> '' then
            FieldXmlElement.Add(Tarifa);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'valor');
        if Valor <> '' then
            FieldXmlElement.Add(Valor);
        DataXmlElement.Add(FieldXmlElement);

        if ValorTotal <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'valorTotal');
            FieldXmlElement.Add(ValorTotal);
            DataXmlElement.Add(FieldXmlElement);
        end;

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'codigoRetencion');
        if CodigoRetencion <> '' then
            FieldXmlElement.Add(CodigoRetencion);
        DataXmlElement.Add(FieldXmlElement);

        if CodImpuestoDocSustento <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'codImpuestoDocSustento');
            FieldXmlElement.Add(CodImpuestoDocSustento);
            DataXmlElement.Add(FieldXmlElement);
        end;

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'porcentajeRetener');
        if PorcentajeRetener <> '' then
            FieldXmlElement.Add(PorcentajeRetener);
        DataXmlElement.Add(FieldXmlElement);

        if ValorImpuesto <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'valorImpuesto');
            FieldXmlElement.Add(ValorImpuesto);
            DataXmlElement.Add(FieldXmlElement);
        end;

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'valorRetenido');
        if ValorRetenido <> '' then
            FieldXmlElement.Add(ValorRetenido);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'codDocSustento');
        if CodDocSustento <> '' then
            FieldXmlElement.Add(CodDocSustento);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'numDocSustento');
        if NumDocSustento <> '' then
            FieldXmlElement.Add(NumDocSustento);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'totalRetenido');
        if TotalRetenido <> '' then
            FieldXmlElement.Add(TotalRetenido);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'concepto');
        if Concepto <> '' then
            FieldXmlElement.Add(Concepto);
        DataXmlElement.Add(FieldXmlElement);

        if Motivo <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'motivo');
            FieldXmlElement.Add(Motivo);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if ValorTotal2 <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'valorTotal2');
            FieldXmlElement.Add(ValorTotal2);
            DataXmlElement.Add(FieldXmlElement);
        end;

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'codigoPrincipal');
        if CodigoPrincipal <> '' then
            FieldXmlElement.Add(CodigoPrincipal);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'codigoAuxiliar');
        if CodigoAuxiliar <> '' then
            FieldXmlElement.Add(CodigoAuxiliar);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'codigointerno');
        if CodigoInterno <> '' then
            FieldXmlElement.Add(CodigoInterno);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'codigoadicional');
        if CodigoAdicional <> '' then
            FieldXmlElement.Add(CodigoAdicional);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'lnitmseq');
        if LnItmSeq <> '' then
            FieldXmlElement.Add(LnItmSeq);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'descripcion');
        if Descripcion <> '' then
            FieldXmlElement.Add(Descripcion);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'unidadMedida');
        if UnidadMedida <> '' then
            FieldXmlElement.Add(UnidadMedida);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'cantidad');
        if Cantidad <> '' then
            FieldXmlElement.Add(Cantidad);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'preciounitario');
        if PrecioUnitario <> '' then
            FieldXmlElement.Add(PrecioUnitario);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'descuento');
        if Descuento <> '' then
            FieldXmlElement.Add(Descuento);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'preciototalsinimpuesto');
        if PrecioTotalSinImpuesto <> '' then
            FieldXmlElement.Add(PrecioTotalSinImpuesto);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'codigoimpitem');
        if CodigoImpItem <> '' then
            FieldXmlElement.Add(CodigoImpItem);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'codigoporcentajeitem');
        if CodigoPorcentajeItem <> '' then
            FieldXmlElement.Add(CodigoPorcentajeItem);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'tarifaimpitem');
        if TarifaImpItem <> '' then
            FieldXmlElement.Add(TarifaImpItem);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'baseimponibleitem');
        if BaseImponibleItem <> '' then
            FieldXmlElement.Add(BaseImponibleItem);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'valorimpitem');
        if ValorImpItem <> '' then
            FieldXmlElement.Add(ValorImpItem);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'montoletras');
        if MontoLetras <> '' then
            FieldXmlElement.Add(MontoLetras);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'email');
        if Email <> '' then
            FieldXmlElement.Add(Email);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', '_Telefono');
        if Telefono <> '' then
            FieldXmlElement.Add(Telefono);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', 'diradq');
        if DirAdq <> '' then
            FieldXmlElement.Add(DirAdq);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', '_Ciudad');
        if Ciudad <> '' then
            FieldXmlElement.Add(Ciudad);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', '_Vencimiento');
        if Vencimiento <> '' then
            FieldXmlElement.Add(Vencimiento);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', '_CodCliente');
        if CodCliente <> '' then
            FieldXmlElement.Add(CodCliente);
        DataXmlElement.Add(FieldXmlElement);

        FieldXmlElement := XmlElement.Create('campo');
        FieldXmlElement.SetAttribute('nombre', '_DirEnvio');
        if Ov <> '' then
            FieldXmlElement.Add(Ov);
        DataXmlElement.Add(FieldXmlElement);

        if Celular <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', '_Celular');
            FieldXmlElement.Add(Celular);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if Otro <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', '');

            FieldXmlElement.Add(Otro);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if TipoIdentificacionProveedorReembolso <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'tipoIdentificacionProveedorReembolso');

            FieldXmlElement.Add(TipoIdentificacionProveedorReembolso);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if IdentificacionProveedorReembolso <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'identificacionProveedorReembolso');

            FieldXmlElement.Add(IdentificacionProveedorReembolso);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if CodPaisPagoProveedorReembolso <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'codPaisPagoProveedorReembolso');

            FieldXmlElement.Add(CodPaisPagoProveedorReembolso);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if TipoProveedorReembolso <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'tipoProveedorReembolso');

            FieldXmlElement.Add(TipoProveedorReembolso);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if CodDocReembolso <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'codDocReembolso');

            FieldXmlElement.Add(CodDocReembolso);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if EstabDocReembolso <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'estabDocReembolso');

            FieldXmlElement.Add(EstabDocReembolso);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if PtoEmiDocReembolso <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'ptoEmiDocReembolso');

            FieldXmlElement.Add(PtoEmiDocReembolso);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if SecuencialDocReembolso <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'secuencialDocReembolso');

            FieldXmlElement.Add(SecuencialDocReembolso);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if FechaEmisionDocReembolso <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'fechaEmisionDocReembolso');

            FieldXmlElement.Add(FechaEmisionDocReembolso);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if Dexrowid <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'dexrowid');

            FieldXmlElement.Add(Dexrowid);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if NumeroautorizacionDocReemb <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'numeroautorizacionDocReemb');

            FieldXmlElement.Add(NumeroautorizacionDocReemb);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if CodigoImpReemb <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'codigoImpReemb');

            FieldXmlElement.Add(CodigoImpReemb);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if CodigoPorcentajeReemb <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'codigoPorcentajeReemb');

            FieldXmlElement.Add(CodigoPorcentajeReemb);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if TarifaImpReemb <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'tarifaImpReemb');

            FieldXmlElement.Add(TarifaImpReemb);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if BaseImponibleReembolso <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'baseImponibleReembolso');
            FieldXmlElement.Add(BaseImponibleReembolso);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if ImpuestoReembolso <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'impuestoReembolso');

            FieldXmlElement.Add(ImpuestoReembolso);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if IdConductor <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', '_IdConductor');
            FieldXmlElement.Add(IdConductor);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if NombreConductor <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', '_NombreConductor');
            FieldXmlElement.Add(NombreConductor);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if not AddDataXmlElement.IsEmpty then begin
            AddXmlNodeList := AddDataXmlElement.GetChildNodes();
            foreach AddXmlNode in AddXmlNodeList do
                DataXmlElement.Add(AddXmlNode.AsXmlElement());
        end;

        if not AddDataLineXmlElement.IsEmpty then begin
            AddXmlNodeList := AddDataLineXmlElement.GetChildNodes();
            foreach AddXmlNode in AddXmlNodeList do
                DataXmlElement.Add(AddXmlNode.AsXmlElement());
        end;

        if TipoSujetoRetenido <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'tipoSujetoRetenido');
            FieldXmlElement.Add(TipoSujetoRetenido);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if ParteRel <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'parteRel');
            FieldXmlElement.Add(ParteRel);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if CodSustento <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'codSustento');
            FieldXmlElement.Add(CodSustento);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if FechaRegistroContable <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'fechaRegistroContable');
            FieldXmlElement.Add(FechaRegistroContable);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if NumAutDocSustento <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'numAutDocSustento');
            FieldXmlElement.Add(NumAutDocSustento);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if PagoLocExt <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'pagoLocExt');
            FieldXmlElement.Add(PagoLocExt);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if TipoRegi <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'tipoRegi');
            FieldXmlElement.Add(TipoRegi);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if PaisEfecPago <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'paisEfecPago');
            FieldXmlElement.Add(PaisEfecPago);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if AplicConvDobTrib <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'aplicConvDobTrib');
            FieldXmlElement.Add(AplicConvDobTrib);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if PagExtSujRetNorLeg <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'pagExtSujRetNorLeg');
            FieldXmlElement.Add(PagExtSujRetNorLeg);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if PagoRegFis <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'pagoRegFis');
            FieldXmlElement.Add(PagoRegFis);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if FechaPagoDiv <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'fechaPagoDiv');
            FieldXmlElement.Add(FechaPagoDiv);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if ImRentaSoc <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'imRentaSoc');
            FieldXmlElement.Add(ImRentaSoc);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if EjerFisUtDiv <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'ejerFisUtDiv');
            FieldXmlElement.Add(EjerFisUtDiv);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if NumCajBan <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'numCajBan');
            FieldXmlElement.Add(NumCajBan);
            DataXmlElement.Add(FieldXmlElement);
        end;

        if PrecCajBan <> '' then begin
            FieldXmlElement := XmlElement.Create('campo');
            FieldXmlElement.SetAttribute('nombre', 'precCajBan');
            FieldXmlElement.Add(PrecCajBan);
            DataXmlElement.Add(FieldXmlElement);
        end;

        exit(DataXmlElement);
    end;

    /// <summary>
    /// SetNombreEmisor.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetNombreEmisor(ValueTxt: Text): Text
    begin
        NombreEmisor := ValueTxt;

        exit(NombreEmisor);
    end;

    /// <summary>
    /// SetNombreCompania.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetNombreCompania(ValueTxt: Text): Text
    begin
        NombreCompania := ValueTxt;

        exit(NombreCompania);
    end;

    /// <summary>
    /// SetNombreArchivo.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetNombreArchivo(ValueTxt: Text): Text
    begin
        NombreArchivo := ValueTxt;

        exit(NombreArchivo);
    end;

    /// <summary>
    /// SetIdentificadorTransaccion.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetIdentificadorTransaccion(ValueTxt: Text): Text
    begin
        IdentificadorTransaccion := ValueTxt;

        exit(IdentificadorTransaccion);
    end;

    /// <summary>
    /// SetIdEmpresa.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetIdEmpresa(ValueTxt: Text): Text
    begin
        IdEmpresa := ValueTxt;

        exit(IdEmpresa);
    end;

    /// <summary>
    /// SetIdContrato.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetIdContrato(ValueTxt: Text): Text
    begin
        IdContrato := ValueTxt;

        exit(IdContrato);
    end;

    /// <summary>
    /// SetCanal.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCanal(ValueTxt: Text): Text
    begin
        Canal := ValueTxt;

        exit(Canal);
    end;

    /// <summary>
    /// SetIpDevice.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetIpDevice(ValueTxt: Text): Text
    begin
        IpDevice := ValueTxt;

        exit(IpDevice);
    end;

    /// <summary>
    /// SetUsuario.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetUsuario(ValueTxt: Text): Text
    begin
        Usuario := ValueTxt;

        exit(Usuario);
    end;

    /// <summary>
    /// SetFechaHoraTrx.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetFechaHoraTrx(ValueTxt: Text): Text
    begin
        FechaHoraTrx := ValueTxt;

        exit(FechaHoraTrx);
    end;

    /// <summary>
    /// SetVersionDocumento.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetVersionDocumento(ValueTxt: Text): Text
    begin
        VersionDocumento := ValueTxt;

        exit(VersionDocumento);
    end;

    /// <summary>
    /// SetRazonSocial.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetRazonSocial(ValueTxt: Text): Text
    begin
        RazonSocial := ValueTxt;

        exit(RazonSocial);
    end;

    /// <summary>
    /// SetNombreComercial.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetNombreComercial(ValueTxt: Text): Text
    begin
        NombreComercial := ValueTxt;

        exit(NombreComercial);
    end;

    /// <summary>
    /// SetRuc.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetRuc(ValueTxt: Text): Text
    begin
        Ruc := ValueTxt;

        exit(Ruc);
    end;

    /// <summary>
    /// SetCodDoc.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodDoc(ValueTxt: Text): Text
    begin
        CodDoc := ValueTxt;

        exit(CodDoc);
    end;

    /// <summary>
    /// SetEstab.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetEstab(ValueTxt: Text): Text
    begin
        Estab := ValueTxt;

        exit(Estab);
    end;

    /// <summary>
    /// SetPtoEmi.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPtoEmi(ValueTxt: Text): Text
    begin
        PtoEmi := ValueTxt;

        exit(PtoEmi);
    end;

    /// <summary>
    /// SetSecuencial.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetSecuencial(ValueTxt: Text): Text
    begin
        Secuencial := ValueTxt;

        exit(Secuencial);
    end;

    /// <summary>
    /// SetDirMatriz.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetDirMatriz(ValueTxt: Text): Text
    begin
        DirMatriz := ValueTxt;

        exit(DirMatriz);
    end;

    /// <summary>
    /// SetAgenteRetencion.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetAgenteRetencion(ValueTxt: Text): Text
    begin
        AgenteRetencion := ValueTxt;

        exit(AgenteRetencion);
    end;

    /// <summary>
    /// SetFechaEmision.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetFechaEmision(ValueTxt: Text): Text
    begin
        FechaEmision := ValueTxt;

        exit(FechaEmision);
    end;

    /// <summary>
    /// SetDirEstablecimiento.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetDirEstablecimiento(ValueTxt: Text): Text
    begin
        DirEstablecimiento := ValueTxt;

        exit(DirEstablecimiento);
    end;

    //>>>>>Guía de Remisión<<<<<<
    /// <summary>
    /// SetDirPartida.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetDirPartida(ValueTxt: Text): Text
    begin
        DirPartida := ValueTxt;

        exit(DirPartida);
    end;

    /// <summary>
    /// SetrRzonSocialTransportista.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetRazonSocialTransportista(ValueTxt: Text): Text
    begin
        RazonSocialTransportista := ValueTxt;

        exit(RazonSocialTransportista);
    end;

    /// <summary>
    /// SetTipoIdentificacionTransportista.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTipoIdentificacionTransportista(ValueTxt: Text): Text
    begin
        TipoIdentificacionTransportista := ValueTxt;

        exit(TipoIdentificacionTransportista);
    end;
    /// <summary>
    /// SetRucTransportista.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetRucTransportista(ValueTxt: Text): Text
    begin
        RucTransportista := ValueTxt;

        exit(RucTransportista);
    end;

    /// <summary>
    /// SetFechaIniTransporte.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetFechaIniTransporte(ValueTxt: Text): Text
    begin
        FechaIniTransporte := ValueTxt;

        exit(FechaIniTransporte);
    end;

    /// <summary>
    /// SetFechaFinTransporte.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetFechaFinTransporte(ValueTxt: Text): Text
    begin
        FechaFinTransporte := ValueTxt;

        exit(FechaFinTransporte);
    end;

    /// <summary>
    /// SetPlaca.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPlaca(ValueTxt: Text): Text
    begin
        Placa := ValueTxt;

        exit(Placa);
    end;

    /// <summary>
    /// SetIdentificacionDestinatario.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetIdentificacionDestinatario(ValueTxt: Text): Text
    begin
        IdentificacionDestinatario := ValueTxt;

        exit(IdentificacionDestinatario);
    end;

    /// <summary>
    /// SetRazonSocialDestinatario.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetRazonSocialDestinatario(ValueTxt: Text): Text
    begin
        RazonSocialDestinatario := ValueTxt;

        exit(RazonSocialDestinatario);
    end;

    /// <summary>
    /// SetDirDestinatario.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetDirDestinatario(ValueTxt: Text): Text
    begin
        DirDestinatario := ValueTxt;

        exit(DirDestinatario);
    end;

    /// <summary>
    /// SetMotivoTraslado.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetMotivoTraslado(ValueTxt: Text): Text
    begin
        MotivoTraslado := ValueTxt;

        exit(MotivoTraslado);
    end;

    /// <summary>
    /// SetTipoIdentificacionComprador.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTipoIdentificacionComprador(ValueTxt: Text): Text
    begin
        TipoIdentificacionComprador := ValueTxt;

        exit(TipoIdentificacionComprador);
    end;

    /// <summary>
    /// SetTipoIdentificacionProveedor.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTipoIdentificacionProveedor(ValueTxt: Text): Text
    begin
        TipoIdentificacionProveedor := ValueTxt;

        exit(TipoIdentificacionProveedor);
    end;

    /// <summary>
    /// SetRazonSocialProveedor.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetRazonSocialProveedor(ValueTxt: Text): Text
    begin
        RazonSocialProveedor := ValueTxt;

        exit(RazonSocialProveedor);
    end;

    /// <summary>
    /// SetIdentificacionProveedor.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetIdentificacionProveedor(ValueTxt: Text): Text
    begin
        IdentificacionProveedor := ValueTxt;

        exit(IdentificacionProveedor);
    end;

    /// <summary>
    /// SetDireccionProveedor.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetDireccionProveedor(ValueTxt: Text): Text
    begin
        DireccionProveedor := ValueTxt;

        exit(DireccionProveedor);
    end;

    /// <summary>
    /// SetRazonsocialComprador.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetRazonsocialComprador(ValueTxt: Text): Text
    begin
        RazonsocialComprador := ValueTxt;

        exit(RazonsocialComprador);
    end;

    /// <summary>
    /// SetRazon.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetRazon(ValueTxt: Text): Text
    begin
        Razon := ValueTxt;

        exit(Razon);
    end;

    /// <summary>
    /// SetIdentificacionComprador.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetIdentificacionComprador(ValueTxt: Text): Text
    begin
        IdentificacionComprador := ValueTxt;

        exit(IdentificacionComprador);
    end;

    /// <summary>
    /// SetDireccioncomprador.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetDireccioncomprador(ValueTxt: Text): Text
    begin
        Direccioncomprador := ValueTxt;

        exit(Direccioncomprador);
    end;

    /// <summary>
    /// SetContribuyenteEspecial.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetContribuyenteEspecial(ValueTxt: Text): Text
    begin
        ContribuyenteEspecial := ValueTxt;

        exit(ContribuyenteEspecial);
    end;

    /// <summary>
    /// SetObligadoContabilidad.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetObligadoContabilidad(ValueTxt: Text): Text
    begin
        ObligadoContabilidad := ValueTxt;

        exit(ObligadoContabilidad);
    end;

    /// <summary>
    /// SetCodDocModificado.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodDocModificado(ValueTxt: Text): Text
    begin
        CodDocModificado := ValueTxt;

        exit(CodDocModificado);
    end;

    /// <summary>
    /// SetNumDocModificado.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetNumDocModificado(ValueTxt: Text): Text
    begin
        NumDocModificado := ValueTxt;

        exit(NumDocModificado);
    end;

    /// <summary>
    /// SetFechaEmisionDocSustento.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetFechaEmisionDocSustento(ValueTxt: Text): Text
    begin
        FechaEmisionDocSustento := ValueTxt;

        exit(FechaEmisionDocSustento);
    end;

    /// <summary>
    /// SetTotalSinImpuestos.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTotalSinImpuestos(ValueTxt: Text): Text
    begin
        TotalSinImpuestos := ValueTxt;

        exit(TotalSinImpuestos);
    end;

    /// <summary>
    /// SetTotalConImpuestos.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTotalConImpuestos(ValueTxt: Text): Text
    begin
        TotalConImpuestos := ValueTxt;

        exit(TotalConImpuestos);
    end;

    /// <summary>
    /// SetTotalDescuento.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTotalDescuento(ValueTxt: Text): Text
    begin
        TotalDescuento := ValueTxt;

        exit(TotalDescuento);
    end;


    /// <summary>
    /// SetComercioExterior.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetComercioExterior(ValueTxt: Text): Text
    begin
        ComercioExterior := ValueTxt;

        exit(ComercioExterior);
    end;

    /// <summary>
    /// SetIncoTermFactura.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetIncoTermFactura(ValueTxt: Text): Text
    begin
        IncoTermFactura := ValueTxt;

        exit(IncoTermFactura);
    end;

    /// <summary>
    /// SetLugarIncoTerm.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetLugarIncoTerm(ValueTxt: Text): Text
    begin
        LugarIncoTerm := ValueTxt;

        exit(LugarIncoTerm);
    end;

    /// <summary>
    /// SetPaisOrigen.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPaisOrigen(ValueTxt: Text): Text
    begin
        PaisOrigen := ValueTxt;

        exit(PaisOrigen);
    end;

    /// <summary>
    /// SetPuertoEmbarque.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPuertoEmbarque(ValueTxt: Text): Text
    begin
        PuertoEmbarque := ValueTxt;

        exit(PuertoEmbarque);
    end;

    /// <summary>
    /// SetPuertoDestino.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPuertoDestino(ValueTxt: Text): Text
    begin
        PuertoDestino := ValueTxt;

        exit(PuertoDestino);
    end;

    /// <summary>
    /// SetPaisDestino.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPaisDestino(ValueTxt: Text): Text
    begin
        PaisDestino := ValueTxt;

        exit(PaisDestino);
    end;

    /// <summary>
    /// SetIncoTermTotalSinImpuestos.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetIncoTermTotalSinImpuestos(ValueTxt: Text): Text
    begin
        IncoTermTotalSinImpuestos := ValueTxt;

        exit(IncoTermTotalSinImpuestos);
    end;

    /// <summary>
    /// SetPaisAdquisicion.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPaisAdquisicion(ValueTxt: Text): Text
    begin
        PaisAdquisicion := ValueTxt;

        exit(PaisAdquisicion);
    end;

    /// <summary>
    /// SetFleteInternacional.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetFleteInternacional(ValueTxt: Text): Text
    begin
        FleteInternacional := ValueTxt;

        exit(FleteInternacional);
    end;

    /// <summary>
    /// SetSeguroInternacional.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetSeguroInternacional(ValueTxt: Text): Text
    begin
        SeguroInternacional := ValueTxt;

        exit(SeguroInternacional);
    end;

    /// <summary>
    /// SetGastosAduaneros.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetGastosAduaneros(ValueTxt: Text): Text
    begin
        GastosAduaneros := ValueTxt;

        exit(GastosAduaneros);
    end;

    /// <summary>
    /// SetGastosTransporteOtros.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetGastosTransporteOtros(ValueTxt: Text): Text
    begin
        GastosTransporteOtros := ValueTxt;

        exit(GastosTransporteOtros);
    end;

    /// <summary>
    /// SetValorModificacion.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetValorModificacion(ValueTxt: Text): Text
    begin
        ValorModificacion := ValueTxt;

        exit(ValorModificacion);
    end;

    /// <summary>
    /// SetMoneda.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetMoneda(ValueTxt: Text): Text
    begin
        Moneda := ValueTxt;

        exit(Moneda);
    end;

    /// <summary>
    /// SetCodigo.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodigo(ValueTxt: Text): Text
    begin
        Codigo := ValueTxt;

        exit(Codigo);
    end;

    /// <summary>
    /// SetCodigoPorcentaje.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodigoPorcentaje(ValueTxt: Text): Text
    begin
        CodigoPorcentaje := ValueTxt;

        exit(CodigoPorcentaje);
    end;

    /// <summary>
    /// SetDescuentoAdicional.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetDescuentoAdicional(ValueTxt: Text): Text
    begin
        DescuentoAdicional := ValueTxt;

        exit(DescuentoAdicional);
    end;

    /// <summary>
    /// SetBaseImponible.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetBaseImponible(ValueTxt: Text): Text
    begin
        BaseImponible := ValueTxt;

        exit(BaseImponible);
    end;

    /// <summary>
    /// SetTarifa.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTarifa(ValueTxt: Text): Text
    begin
        Tarifa := ValueTxt;

        exit(Tarifa);
    end;

    /// <summary>
    /// SetValor.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetValor(ValueTxt: Text): Text
    begin
        Valor := ValueTxt;

        exit(Valor);
    end;
    /// <summary>
    /// SetValorTotal.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetValorTotal(ValueTxt: Text): Text
    begin
        ValorTotal := ValueTxt;

        exit(ValorTotal);
    end;

    /// <summary>
    /// SetPropina.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPropina(ValueTxt: Text): Text
    begin
        Propina := ValueTxt;

        exit(Propina);
    end;

    /// <summary>
    /// SetImporteTotal.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetImporteTotal(ValueTxt: Text): Text
    begin
        ImporteTotal := ValueTxt;

        exit(ImporteTotal);
    end;

    /// <summary>
    /// SetMotivo.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetMotivo(ValueTxt: Text): Text
    begin
        Motivo := ValueTxt;

        exit(Motivo);
    end;

    /// <summary>
    /// SetValorTotal2.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetValorTotal2(ValueTxt: Text): Text
    begin
        ValorTotal2 := ValueTxt;

        exit(ValorTotal2);
    end;

    /// <summary>
    /// SetCodigoPrincipal.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodigoPrincipal(ValueTxt: Text): Text
    begin
        CodigoPrincipal := ValueTxt;

        exit(CodigoPrincipal);
    end;


    /// <summary>
    /// SetCodigoAuxiliar.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodigoAuxiliar(ValueTxt: Text): Text
    begin
        CodigoAuxiliar := ValueTxt;

        exit(CodigoAuxiliar);
    end;

    /// <summary>
    /// SetCodigoInterno.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodigoInterno(ValueTxt: Text): Text
    begin
        CodigoInterno := ValueTxt;

        exit(CodigoInterno);
    end;

    /// <summary>
    /// SetCodigoAdicional.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodigoAdicional(ValueTxt: Text): Text
    begin
        CodigoAdicional := ValueTxt;

        exit(CodigoAdicional);
    end;

    /// <summary>
    /// SetLnItmSeq.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetLnItmSeq(ValueTxt: Text): Text
    begin
        LnItmSeq := ValueTxt;

        exit(LnItmSeq);
    end;

    /// <summary>
    /// SetDescripcion.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetDescripcion(ValueTxt: Text): Text
    begin
        Descripcion := ValueTxt;

        exit(Descripcion);
    end;

    /// <summary>
    /// SetUnidadMedida.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetUnidadMedida(ValueTxt: Text): Text
    begin
        UnidadMedida := ValueTxt;

        exit(UnidadMedida);
    end;

    /// <summary>
    /// SetCantidad.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCantidad(ValueTxt: Text): Text
    begin
        Cantidad := ValueTxt;

        exit(Cantidad);
    end;

    /// <summary>
    /// SetPrecioUnitario.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPrecioUnitario(ValueTxt: Text): Text
    begin
        PrecioUnitario := ValueTxt;

        exit(PrecioUnitario);
    end;

    /// <summary>
    /// SetDescuento.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetDescuento(ValueTxt: Text): Text
    begin
        Descuento := ValueTxt;

        exit(Descuento);
    end;

    /// <summary>
    /// SetPrecioTotalSinImpuesto.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPrecioTotalSinImpuesto(ValueTxt: Text): Text
    begin
        PrecioTotalSinImpuesto := ValueTxt;

        exit(PrecioTotalSinImpuesto);
    end;

    /// <summary>
    /// SetCodigoImpItem.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodigoImpItem(ValueTxt: Text): Text
    begin
        CodigoImpItem := ValueTxt;

        exit(CodigoImpItem);
    end;

    /// <summary>
    /// SetCodigoPorcentajeItem.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodigoPorcentajeItem(ValueTxt: Text): Text
    begin
        CodigoPorcentajeItem := ValueTxt;

        exit(CodigoPorcentajeItem);
    end;

    /// <summary>
    /// SetTarifaImpItem.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTarifaImpItem(ValueTxt: Text): Text
    begin
        TarifaImpItem := ValueTxt;

        exit(TarifaImpItem);
    end;

    /// <summary>
    /// SetBaseImponibleItem.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetBaseImponibleItem(ValueTxt: Text): Text
    begin
        BaseImponibleItem := ValueTxt;

        exit(BaseImponibleItem);
    end;

    /// <summary>
    /// SetValorImpItem.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetValorImpItem(ValueTxt: Text): Text
    begin
        ValorImpItem := ValueTxt;

        exit(ValorImpItem);
    end;

    /// <summary>
    /// SetMontoLetras.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetMontoLetras(ValueTxt: Text): Text
    begin
        MontoLetras := ValueTxt;

        exit(MontoLetras);
    end;

    /// <summary>
    /// SetEmail.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetEmail(ValueTxt: Text): Text
    begin
        Email := ValueTxt;

        exit(Email);
    end;

    /// <summary>
    /// SetTelefono.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTelefono(ValueTxt: Text): Text
    begin
        Telefono := ValueTxt;

        exit(Telefono);
    end;

    /// <summary>
    /// SetDirAdq.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetDirAdq(ValueTxt: Text): Text
    begin
        DirAdq := ValueTxt;

        exit(DirAdq);
    end;

    /// <summary>
    /// SetCiudad.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCiudad(ValueTxt: Text): Text
    begin
        Ciudad := ValueTxt;

        exit(Ciudad);
    end;

    /// <summary>
    /// SetVencimiento.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetVencimiento(ValueTxt: Text): Text
    begin
        Vencimiento := ValueTxt;

        exit(Vencimiento);
    end;

    /// <summary>
    /// SetCodCliente.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodCliente(ValueTxt: Text): Text
    begin
        CodCliente := ValueTxt;

        exit(CodCliente);
    end;

    /// <summary>
    /// SetOv.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetOv(ValueTxt: Text): Text
    begin
        Ov := ValueTxt;

        exit(Ov);
    end;

    /// <summary>
    /// SetCelular.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCelular(ValueTxt: Text): Text
    begin
        Celular := ValueTxt;

        exit(Celular);
    end;

    /// <summary>
    /// SetOtro.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetOtro(ValueTxt: Text): Text
    begin
        Otro := ValueTxt;

        exit(Otro);
    end;

    //Informacion para reembolsos de ventas
    /// <summary>
    /// SetTipoIdentificacionProveedorReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTipoIdentificacionProveedorReembolso(ValueTxt: Text): Text
    begin
        TipoIdentificacionProveedorReembolso := ValueTxt;

        exit(TipoIdentificacionProveedorReembolso);
    end;

    /// <summary>
    /// SetIdentificacionProveedorReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetIdentificacionProveedorReembolso(ValueTxt: Text): Text
    begin
        IdentificacionProveedorReembolso := ValueTxt;

        exit(IdentificacionProveedorReembolso);
    end;

    /// <summary>
    /// SetCodPaisPagoProveedorReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodPaisPagoProveedorReembolso(ValueTxt: Text): Text
    begin
        CodPaisPagoProveedorReembolso := ValueTxt;

        exit(CodPaisPagoProveedorReembolso);
    end;

    /// <summary>
    /// SetTipoProveedorReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTipoProveedorReembolso(ValueTxt: Text): Text
    begin
        TipoProveedorReembolso := ValueTxt;

        exit(TipoProveedorReembolso);
    end;

    /// <summary>
    /// SetCodDocReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodDocReembolso(ValueTxt: Text): Text
    begin
        CodDocReembolso := ValueTxt;

        exit(CodDocReembolso);
    end;

    /// <summary>
    /// SetCodDocReemb.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodDocReemb(ValueTxt: Text): Text
    begin
        CodDocReemb := ValueTxt;

        exit(CodDocReemb);
    end;

    /// <summary>
    /// TotalComprobantesReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTotalComprobantesReembolso(ValueTxt: Text): Text
    begin
        TotalComprobantesReembolso := ValueTxt;

        exit(TotalComprobantesReembolso);
    end;

    /// <summary>
    /// TotalBaseImponibleReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTotalBaseImponibleReembolso(ValueTxt: Text): Text
    begin
        TotalBaseImponibleReembolso := ValueTxt;

        exit(TotalBaseImponibleReembolso);
    end;

    /// <summary>
    /// TotalImpuestoReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTotalImpuestoReembolso(ValueTxt: Text): Text
    begin
        TotalImpuestoReembolso := ValueTxt;

        exit(TotalImpuestoReembolso);
    end;

    /// <summary>
    /// SetEstabDocReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetEstabDocReembolso(ValueTxt: Text): Text
    begin
        EstabDocReembolso := ValueTxt;

        exit(EstabDocReembolso);
    end;

    /// <summary>
    /// SetPtoEmiDocReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPtoEmiDocReembolso(ValueTxt: Text): Text
    begin
        PtoEmiDocReembolso := ValueTxt;

        exit(PtoEmiDocReembolso);
    end;

    /// <summary>
    /// SetSecuencialDocReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetSecuencialDocReembolso(ValueTxt: Text): Text
    begin
        SecuencialDocReembolso := ValueTxt;

        exit(SecuencialDocReembolso);
    end;

    /// <summary>
    /// SetFechaEmisionDocReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetFechaEmisionDocReembolso(ValueTxt: Text): Text
    begin
        FechaEmisionDocReembolso := ValueTxt;

        exit(FechaEmisionDocReembolso);
    end;

    /// <summary>
    /// SetNumeroautorizacionDocReemb.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetNumeroautorizacionDocReemb(ValueTxt: Text): Text
    begin
        NumeroautorizacionDocReemb := ValueTxt;

        exit(NumeroautorizacionDocReemb);
    end;

    /// <summary>
    /// SetDexrowid.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetDexrowid(ValueTxt: Text): Text
    begin
        Dexrowid := ValueTxt;

        exit(Dexrowid);
    end;

    /// <summary>
    /// SetCodigoImpReemb.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodigoImpReemb(ValueTxt: Text): Text
    begin
        CodigoImpReemb := ValueTxt;

        exit(CodigoImpReemb);
    end;

    /// <summary>
    /// SetCodigoPorcentajeReemb.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodigoPorcentajeReemb(ValueTxt: Text): Text
    begin
        CodigoPorcentajeReemb := ValueTxt;

        exit(CodigoPorcentajeReemb);
    end;

    /// <summary>
    /// SetTarifaImpReemb.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTarifaImpReemb(ValueTxt: Text): Text
    begin
        TarifaImpReemb := ValueTxt;

        exit(TarifaImpReemb);
    end;

    /// <summary>
    /// SetBaseImponibleReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetBaseImponibleReembolso(ValueTxt: Text): Text
    begin
        BaseImponibleReembolso := ValueTxt;

        exit(BaseImponibleReembolso);
    end;

    /// <summary>
    /// SetImpuestoReembolso.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetImpuestoReembolso(ValueTxt: Text): Text
    begin
        ImpuestoReembolso := ValueTxt;

        exit(ImpuestoReembolso);
    end;

    /// <summary>
    /// SetFormaPago.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetFormaPago(ValueTxt: Text): Text
    begin
        FormaPago := ValueTxt;

        exit(FormaPago);
    end;

    /// <summary>
    /// SetTotal.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTotal(ValueTxt: Text): Text
    begin
        Total := ValueTxt;

        exit(Total);
    end;

    /// <summary>
    /// SetPlazo.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPlazo(ValueTxt: Text): Text
    begin
        Plazo := ValueTxt;

        exit(Plazo);
    end;

    /// <summary>
    /// SetUnidadTiempo.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetUnidadTiempo(ValueTxt: Text): Text
    begin
        UnidadTiempo := ValueTxt;

        exit(UnidadTiempo);
    end;

    /// <summary>
    /// SetDescTrabajo.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetDescTrabajo(ValueTxt: Text): Text
    begin
        DescTrabajo := ValueTxt;

        exit(DescTrabajo);
    end;

    /// <summary>
    /// SetTipoIdentificacionSujetoRetenido.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTipoIdentificacionSujetoRetenido(ValueTxt: Text): Text
    begin
        TipoIdentificacionSujetoRetenido := ValueTxt;

        exit(TipoIdentificacionSujetoRetenido);
    end;

    /// <summary>
    /// SetRazonSocialSujetoRetenido.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetRazonSocialSujetoRetenido(ValueTxt: Text): Text
    begin
        RazonSocialSujetoRetenido := ValueTxt;

        exit(RazonSocialSujetoRetenido);
    end;

    /// <summary>
    /// SetIdentificacionSujetoRetenido.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetIdentificacionSujetoRetenido(ValueTxt: Text): Text
    begin
        IdentificacionSujetoRetenido := ValueTxt;

        exit(IdentificacionSujetoRetenido);
    end;

    /// <summary>
    /// SetPeriodoFiscal.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPeriodoFiscal(ValueTxt: Text): Text
    begin
        PeriodoFiscal := ValueTxt;

        exit(PeriodoFiscal);
    end;

    /// <summary>
    /// SetCodigoRetencion.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodigoRetencion(ValueTxt: Text): Text
    begin
        CodigoRetencion := ValueTxt;

        exit(CodigoRetencion);
    end;

    /// <summary>
    /// SetPorcentajeRetener.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPorcentajeRetener(ValueTxt: Text): Text
    begin
        PorcentajeRetener := ValueTxt;

        exit(PorcentajeRetener);
    end;

    /// <summary>
    /// SetValorRetenido.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetValorRetenido(ValueTxt: Text): Text
    begin
        ValorRetenido := ValueTxt;

        exit(ValorRetenido);
    end;

    /// <summary>
    /// SetCodDocSustento.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodDocSustento(ValueTxt: Text): Text
    begin
        CodDocSustento := ValueTxt;

        exit(CodDocSustento);
    end;

    /// <summary>
    /// SetNumDocSustento.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetNumDocSustento(ValueTxt: Text): Text
    begin
        NumDocSustento := ValueTxt;

        exit(NumDocSustento);
    end;

    /// <summary>
    /// SetTotalRetenido.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTotalRetenido(ValueTxt: Text): Text
    begin
        TotalRetenido := ValueTxt;

        exit(TotalRetenido);
    end;

    /// <summary>
    /// SetConcepto.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetConcepto(ValueTxt: Text): Text
    begin
        Concepto := ValueTxt;

        exit(Concepto);
    end;
    /// <summary>
    /// SetIdConductor.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetIdConductor(ValueTxt: Text): Text
    begin
        IdConductor := ValueTxt;

        exit(IdConductor);
    end;

    /// <summary>
    /// SetNombreConductor.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetNombreConductor(ValueTxt: Text): Text
    begin
        NombreConductor := ValueTxt;

        exit(NombreConductor);
    end;

    /// <summary>
    /// SetTipoSujetoRetenido.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTipoSujetoRetenido(ValueTxt: Text): Text
    begin
        TipoSujetoRetenido := ValueTxt;

        exit(TipoSujetoRetenido);
    end;

    /// <summary>
    /// SetParteRel.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetParteRel(ValueTxt: Text): Text
    begin
        ParteRel := ValueTxt;

        exit(ParteRel);
    end;

    /// <summary>
    /// SetCodSustento.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodSustento(ValueTxt: Text): Text
    begin
        CodSustento := ValueTxt;

        exit(CodSustento);
    end;

    /// <summary>
    /// SetFechaRegistroContable.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetFechaRegistroContable(ValueTxt: Text): Text
    begin
        FechaRegistroContable := ValueTxt;

        exit(FechaRegistroContable);
    end;

    /// <summary>
    /// SetNumAutDocSustento.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetNumAutDocSustento(ValueTxt: Text): Text
    begin
        NumAutDocSustento := ValueTxt;

        exit(NumAutDocSustento);
    end;

    /// <summary>
    /// SetPagoLocExt.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPagoLocExt(ValueTxt: Text): Text
    begin
        PagoLocExt := ValueTxt;

        exit(PagoLocExt);
    end;

    /// <summary>
    /// SetTipoRegi.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetTipoRegi(ValueTxt: Text): Text
    begin
        TipoRegi := ValueTxt;

        exit(TipoRegi);
    end;

    /// <summary>
    /// SetPaisEfecPago.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPaisEfecPago(ValueTxt: Text): Text
    begin
        PaisEfecPago := ValueTxt;

        exit(PaisEfecPago);
    end;

    /// <summary>
    /// SetAplicConvDobTrib.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetAplicConvDobTrib(ValueTxt: Text): Text
    begin
        AplicConvDobTrib := ValueTxt;

        exit(AplicConvDobTrib);
    end;

    /// <summary>
    /// SetPagExtSujRetNorLeg.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPagExtSujRetNorLeg(ValueTxt: Text): Text
    begin
        PagExtSujRetNorLeg := ValueTxt;

        exit(PagExtSujRetNorLeg);
    end;

    /// <summary>
    /// SetPagoRegFis.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPagoRegFis(ValueTxt: Text): Text
    begin
        PagoRegFis := ValueTxt;

        exit(PagoRegFis);
    end;

    /// <summary>
    /// SetFechaPagoDiv.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetFechaPagoDiv(ValueTxt: Text): Text
    begin
        FechaPagoDiv := ValueTxt;

        exit(FechaPagoDiv);
    end;

    /// <summary>
    /// SetImRentaSoc.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetImRentaSoc(ValueTxt: Text): Text
    begin
        ImRentaSoc := ValueTxt;

        exit(ImRentaSoc);
    end;

    /// <summary>
    /// SetEjerFisUtDiv.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetEjerFisUtDiv(ValueTxt: Text): Text
    begin
        EjerFisUtDiv := ValueTxt;

        exit(EjerFisUtDiv);
    end;

    /// <summary>
    /// SetNumCajBan.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetNumCajBan(ValueTxt: Text): Text
    begin
        NumCajBan := ValueTxt;

        exit(NumCajBan);
    end;

    /// <summary>
    /// SetPrecCajBan.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetPrecCajBan(ValueTxt: Text): Text
    begin
        PrecCajBan := ValueTxt;

        exit(PrecCajBan);
    end;

    /// <summary>
    /// BaseImponibleRet.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetBaseImponibleRet(ValueTxt: Text): Text
    begin
        BaseImponibleRet := ValueTxt;

        exit(BaseImponibleRet);
    end;

    /// <summary>
    /// CodImpuestoDocSustento.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetCodImpuestoDocSustento(ValueTxt: Text): Text
    begin
        CodImpuestoDocSustento := ValueTxt;

        exit(CodImpuestoDocSustento);
    end;

    /// <summary>
    /// ValorImpuesto.
    /// </summary>
    /// <param name="ValueTxt">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure SetValorImpuesto(ValueTxt: Text): Text
    begin
        ValorImpuesto := ValueTxt;

        exit(ValorImpuesto);
    end;

    procedure deleteAddDataLine()
    begin
        if not AddDataLineXmlElement.IsEmpty() then
            AddDataLineXmlElement := XmlElement.Create('addDataLine');
    end;
}