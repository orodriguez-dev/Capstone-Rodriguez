/// <summary>
/// GMAS - Codeunit EIE Electronic Invoicing (ID 70502).
/// </summary>
codeunit 70502 "EIE Electronic Invoicing"
{
    Permissions = tabledata "Sales Invoice Header" = rimd,
                  tabledata "Sales Cr.Memo Header" = rimd,
                  tabledata "Purch. Inv. Header" = rimd,
                  tabledata "Sales Shipment Header" = rimd,
                  tabledata "Transfer Shipment Header" = rimd,
                  tabledata "GMAS SRI Purch. Withh. Header" = rimd;

    trigger OnRun()
    begin
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ResponsibilityCenter: Record "Responsibility Center";
        CountryRegion: Record "Country/Region";
        Currency: Record Currency;
        XmlDoc: XmlDocument;
        TransactionDateTimeTxt: Text;
        TransactionIdTxt: Text;
        PostingDateTxt: Text;
        DueDateTxt: Text;
        NombreEmisorTxt: label 'NombreEmisor', Locked = true;
        NombreCompaniaTxt: label 'NombreCompania', Locked = true;
        TipoDocumentoTxt: label 'TipoDocumento', Locked = true;
        NumeroDocumentoTxt: label 'NumeroDocumento', Locked = true;
        DocSustentoTxt: label 'DocSustento', Locked = true;
        IdReceptorTxt: label 'IdReceptor', Locked = true;
        FechaDocumentoTxt: label 'FechaDocumento', Locked = true;
        EmpresaTxt: label 'Empresa', Locked = true;
        ContratoTxt: label 'Contrato', Locked = true;
        UsuarioTxt: label 'Usuario', Locked = true;
        DataDocumentoTxt: label 'DataDocumento', Locked = true;
        IdTransaccionTxt: label 'IdentificadorTransaccion', Locked = true;
        TransactionFormatLbl: label '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2><Second>', Locked = true;
        TransactionDateFormatLbl: label '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>', Locked = true;
        PostingDateFormatLbl: label '<Day,2>/<Month,2>/<Year4>', Locked = true;
        Amount0FormatLbl: label '<Precision,0:0><Sign><Integer><Decimals><Comma,.>', Locked = true;
        AmountFormatLbl: label '<Precision,2:2><Sign><Integer><Decimals><Comma,.>', Locked = true;
        QuantityFormatLbl: label '<Precision,2:5><Sign><Integer><Decimals><Comma,.>', Locked = true;
        UnitPriceFormatLbl: label '<Precision,2:6><Sign><Integer><Decimals><Comma,.>', Locked = true;

    /// <summary>
    /// AuthorizeSalesInvoiceDocument.
    /// </summary>
    /// <param name="SalesInvoiceHeader">VAR Record "Sales Invoice Header".</param>
    procedure AuthorizeSalesInvoiceDocument(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        EIEWebServiceRequest: codeunit "EIE Web Service Request";
        JsonBody: JsonObject;
        ResponseJson: JsonObject;
        ResponseToken: JsonToken;
        DocumentTypeCode: Code[3];
        IdentificadorTransaccion: Code[20];
        GMASEIElectronicDocStatus: Enum "GMAS EI Electronic Doc. Status";
        Estado: Text;
        XmlDocText: Text;
        CodigoError: Text;
        ResponseText: Text;
        DescripcionError: Text;
    begin
        CompanyInformation.Get();

        XmlDoc := GenerateSalesInvoiceDocument(SalesInvoiceHeader).GetFileXmlDocument();
        XmlDoc.WriteTo(XmlDocText);

        if XmlDocText <> '' then begin
            Customer.Get(SalesInvoiceHeader."Bill-to Customer No.");

            DocumentTypeCode := SalesInvoiceHeader."GMAS SRI Document Type Code";
            if DocumentTypeCode in ['18', '41', '16', '21'] then
                DocumentTypeCode := '01';

            JsonBody.Add(NombreEmisorTxt, CompanyName);
            JsonBody.Add(NombreCompaniaTxt, CompanyName);
            JsonBody.Add(TipoDocumentoTxt, DocumentTypeCode);
            JsonBody.Add(NumeroDocumentoTxt, SalesInvoiceHeader."No.");
            JsonBody.Add(DocSustentoTxt, DelChr(SalesInvoiceHeader."No.", '=', '-'));
            JsonBody.Add(IdReceptorTxt, Customer."VAT Registration No.");
            JsonBody.Add(FechaDocumentoTxt, Format(SalesInvoiceHeader."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>'));
            JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
            JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
            JsonBody.Add(UsuarioTxt, UserId());
            JsonBody.Add(DataDocumentoTxt, XmlDocText);
            JsonBody.Add(IdTransaccionTxt, TransactionIdTxt);

            //Envia el documento al APi de facturación electrónica
            if EIEWebServiceRequest.RequestWebService(JsonBody, CompanyInformation."EIE Authorization API URL", CompanyInformation."EIE Token API", ResponseText) then begin
                ResponseJson.ReadFrom(ResponseText);
                if ResponseJson.Get('estado', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        Estado := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('codigoError', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        CodigoError := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('descripcionError', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        DescripcionError := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('identificadorTransaccion', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        IdentificadorTransaccion := CopyStr(ResponseToken.AsValue().AsText(), 1, 20);

                GMASEIElectronicDocStatus := GetElectronicStatus(Estado);

                SalesInvoiceHeader."GMAS EI Electronic Doc. Status" := GMASEIElectronicDocStatus;
                SalesInvoiceHeader."EIE Id. Transaction Api" := IdentificadorTransaccion;
                SalesInvoiceHeader."GMAS EI Error Code" := CopyStr(CodigoError, 1, 10);
                SalesInvoiceHeader.SetErrorDescription(DescripcionError);
                SalesInvoiceHeader.Modify();

                if Estado = '01' then begin
                    Clear(JsonBody);
                    JsonBody.Add(TipoDocumentoTxt, DocumentTypeCode);
                    JsonBody.Add(NumeroDocumentoTxt, SalesInvoiceHeader."No.");
                    JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
                    JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
                    JsonBody.Add(IdTransaccionTxt, TransactionIdTxt);

                    Sleep(3000);
                    StatusSalesInvoiceDocument(SalesInvoiceHeader);
                end;
            end;
        end;
    end;

    local procedure GenerateSalesInvoiceDocument(SalesInvoiceHeader: Record "Sales Invoice Header") EIEXMLDocumentStructure: codeunit "EIE XML Document Structure"
    var
        CompanyInformation: Record "Company Information";
        SalesInvoiceLine: Record "Sales Invoice Line";
        CustomerPostingGroup: Record "Customer Posting Group";
        Customer: Record Customer;
        VATEntry: Record "VAT Entry";
        TaxDetail: Record "Tax Detail";
        TaxAreaLine: Record "Tax Area Line";
        TaxJurisdiction: Record "Tax Jurisdiction";
        PaymentMethod: Record "Payment Method";
        TempVATEntry: Record "VAT Entry" temporary;
        GMASSRISalesInvReimbur: Record "GMAS SRI Sales Inv. Reimbur.";
        GMASSRITabla02: Record "GMAS SRI Tabla 02";
        GMASEITabla06: Record "GMAS EI Tabla 06";
        BillToContact: Record Contact;
        CountryRegionAdq: Record "Country/Region";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Item: Record Item;
        SalesCommentLine: Record "Sales Comment Line";
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        EITabla17: Record "GMAS EI Tabla 17";
        FormatNumberToText: Codeunit "EIE Format Number To Text";
        ItemTrackingDocManagement: Codeunit "Item Tracking Doc. Management";
        DocumentTypeCode: Code[3];
        EMail: Text[80];
        PhoneNo: Text[30];
        MobilePhoneNo: Text[30];
        PaymentMethodCode: Text;
        CustomerName: Text;
        CompanyName: Text;
        CompanyAddress: Text;
        BilltoAddress: Text;
        ResponsibilityCenterAddress: Text;
        Description: Text;
        WorkDescription: Text;
        SalesInvReimburRow: Integer;
        TotalBaseImponibleReembolso: Decimal;
        TotalImpuestoReembolso: Decimal;
        NoText: array[2] of Text[80];
        NumberToText: Text;
        AppliestoDocNo: Code[20];
        AppliestoDocTypeCode: Code[3];
        AppliestoDocDate: Text;
        InvoiceRoundingAccount: Code[20];
        ItemCode: Code[20];
        TagAdd: List of [Text];
        TagName: Text;
        TagValue: Text;
        EIRateTaxCode: Code[10];
        LotNo: Text;
        ExpirationDate: Text;
        CompanyType: Text;
        CommentCount: Integer;
    begin
        TransactionIdTxt := Format(CurrentDateTime(), 0, TransactionFormatLbl);
        TransactionDateTimeTxt := Format(SalesInvoiceHeader.SystemCreatedAt, 0, TransactionDateFormatLbl);
        PostingDateTxt := Format(SalesInvoiceHeader."Posting Date", 0, PostingDateFormatLbl);
        DueDateTxt := Format(SalesInvoiceHeader."Due Date", 0, PostingDateFormatLbl);
        DocumentTypeCode := SalesInvoiceHeader."GMAS SRI Document Type Code";
        if DocumentTypeCode in ['18', '41', '16', '21'] then
            DocumentTypeCode := '01';

        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
        Customer.Get(SalesInvoiceHeader."Bill-to Customer No.");
        if (SalesInvoiceHeader."Bill-to Contact No." <> '') and Customer."GMAS SRI Use Customer E-mail" then begin
            BillToContact.Get(SalesInvoiceHeader."Bill-to Contact No.");
            EMail := BillToContact."E-Mail";
            PhoneNo := BillToContact."Phone No.";
            MobilePhoneNo := BillToContact."Mobile Phone No.";
        end else begin
            EMail := Customer."E-Mail";
            PhoneNo := Customer."Phone No.";
            MobilePhoneNo := Customer."Mobile Phone No."
        end;

        Clear(AppliestoDocNo);
        Clear(AppliestoDocTypeCode);
        Clear(AppliestoDocDate);
        Clear(CompanyType);

        if CompanyInformation."GMAS EI Foreign Trade" <> '' then
            CompanyType := 'EXPORTADORES HABITUALES DE BIENES RESOLUCIÓN No. ' + CompanyInformation."GMAS EI Foreign Trade";

        if SalesInvoiceHeader."GMAS SRI Document Type Code" = '05' then
            if (SalesInvoiceHeader."Applies-to Doc. Type" = "Gen. Journal Document Type"::"Credit Memo") and (SalesInvoiceHeader."Applies-to Doc. No." <> '')
            and (StrLen(SalesInvoiceHeader."External Document No.") <> 17) then begin
                if SalesCrMemoHeader.Get(SalesInvoiceHeader."Applies-to Doc. No.") and (SalesCrMemoHeader."GMAS SRI Document Type Code" <> '') then begin
                    AppliestoDocNo := SalesCrMemoHeader."No.";
                    AppliestoDocTypeCode := SalesCrMemoHeader."GMAS SRI Document Type Code";
                    if SalesInvoiceHeader."GMAS SRI Applies-to Doc. Date" <> 0D then
                        AppliestoDocDate := Format(SalesInvoiceHeader."GMAS SRI Applies-to Doc. Date", 0, PostingDateFormatLbl)
                    else
                        AppliestoDocDate := Format(SalesCrMemoHeader."Posting Date", 0, PostingDateFormatLbl);
                end else begin
                    AppliestoDocNo := '000-000-000000000';
                    AppliestoDocTypeCode := '00';
                    if SalesInvoiceHeader."GMAS SRI Applies-to Doc. Date" <> 0D then
                        AppliestoDocDate := Format(SalesInvoiceHeader."GMAS SRI Applies-to Doc. Date", 0, PostingDateFormatLbl)
                    else
                        AppliestoDocDate := Format(WorkDate(), 0, PostingDateFormatLbl);
                end;
            end else
                if (SalesInvoiceHeader."External Document No." <> '') and (StrLen(SalesInvoiceHeader."External Document No.") = 17) then begin
                    AppliestoDocNo := CopyStr(SalesInvoiceHeader."External Document No.", 1, 20);
                    AppliestoDocTypeCode := '01';
                    if SalesInvoiceHeader."GMAS SRI Applies-to Doc. Date" <> 0D then
                        AppliestoDocDate := Format(SalesInvoiceHeader."GMAS SRI Applies-to Doc. Date", 0, PostingDateFormatLbl)
                    else
                        AppliestoDocDate := Format(WorkDate(), 0, PostingDateFormatLbl);
                end else begin
                    AppliestoDocNo := '000-000-000000000';
                    AppliestoDocTypeCode := '00';
                    if SalesInvoiceHeader."GMAS SRI Applies-to Doc. Date" <> 0D then
                        AppliestoDocDate := Format(SalesInvoiceHeader."GMAS SRI Applies-to Doc. Date", 0, PostingDateFormatLbl)
                    else
                        AppliestoDocDate := Format(WorkDate(), 0, PostingDateFormatLbl);
                end;

        ResponsibilityCenter.Get(SalesInvoiceHeader."Responsibility Center");
        SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT", "Invoice Discount Amount");
        if SalesInvoiceHeader."Currency Code" = '' then
            Currency.Get(GeneralLedgerSetup."LCY Code")
        else
            Currency.Get(SalesInvoiceHeader."Currency Code");

        Clear(NoText);
        FormatNumberToText.InitTextVariable();
        FormatNumberToText.FormatNoText(NoText, SalesInvoiceHeader."Amount Including VAT", SalesInvoiceHeader."Currency Code");
        NumberToText := NoText[1] + ' ' + NoText[2];

        GMASSRITabla02.Get(Customer."GMAS SRI Ident. Type Code");
        GMASEITabla06.Reset();
        GMASEITabla06.SetRange("Identification Type", GMASSRITabla02."Identification Type");
        GMASEITabla06.FindFirst();

        if CustomerPostingGroup.Get(Customer."Customer Posting Group") then
            InvoiceRoundingAccount := CustomerPostingGroup."Invoice Rounding Account";

        SalesInvoiceLine.Reset();
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetFilter(Type, '<>%1', "Sales Line Type"::" ");
        SalesInvoiceLine.SetFilter("No.", '<>%1', InvoiceRoundingAccount);
        SalesInvoiceLine.CalcSums("Line Discount Amount", Amount);

        PaymentMethodCode := '20';

        CustomerName := Customer.Name;
        ReplaceSpecialChar(CustomerName);

        CompanyName := CompanyInformation.Name;
        ReplaceSpecialChar(CompanyName);

        CompanyAddress := CompanyInformation.Address;
        ReplaceSpecialChar(CompanyAddress);

        BilltoAddress := SalesInvoiceHeader."Bill-to Address";
        ReplaceSpecialChar(BilltoAddress);

        ResponsibilityCenterAddress := ResponsibilityCenter.Address;
        ReplaceSpecialChar(ResponsibilityCenterAddress);

        WorkDescription := CopyStr(SalesInvoiceHeader.GetWorkDescription(), 1, 300);
        ReplaceSpecialChar(WorkDescription);

        if SalesInvoiceHeader."Payment Method Code" <> '' then begin
            PaymentMethod.Get(SalesInvoiceHeader."Payment Method Code");
            if PaymentMethod."GMAS SRI Payment Method Code" <> '' then
                PaymentMethodCode := PaymentMethod."GMAS SRI Payment Method Code";
        end;

        GMASSRISalesInvReimbur.Reset();
        GMASSRISalesInvReimbur.SetRange("Document No.", SalesInvoiceHeader."No.");
        if GMASSRISalesInvReimbur.FindSet() then
            repeat
                TotalBaseImponibleReembolso += GMASSRISalesInvReimbur."SRI Taxable Base VAT Diff. 0" + GMASSRISalesInvReimbur."SRI Taxable Base VAT 0";
                TotalImpuestoReembolso += GMASSRISalesInvReimbur."SRI VAT Amount";
            until GMASSRISalesInvReimbur.Next() = 0;

        TempVATEntry.Reset();
        TempVATEntry.DeleteAll();

        VATEntry.Reset();
        VATEntry.SetCurrentKey("Document No.", "Posting Date", "Tax Jurisdiction Code");
        VATEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        VATEntry.SetRange("Posting Date", SalesInvoiceHeader."Posting Date");
        VATEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
        if VATEntry.FindSet() then
            repeat
                TaxDetail.Reset();
                TaxDetail.SetRange("Tax Group Code", VATEntry."Tax Group Code");
                TaxDetail.SetRange("Tax Jurisdiction Code", VATEntry."Tax Jurisdiction Code");
                TaxDetail.SetFilter("Effective Date", '<=%1', VATEntry."Posting Date");
                TaxDetail.SetRange("Tax Type", TaxDetail."Tax Type"::"Sales Tax");
                TaxDetail.SetRange("GMAS SRI Tax Type", "GMAS SRI Tax Type"::VAT);
                if TaxDetail.FindLast() then begin
                    TaxDetail.TestField("GMAS EI Rate Tax Code");
                    TaxJurisdiction.Get(VATEntry."Tax Jurisdiction Code");
                    EIRateTaxCode := TaxDetail."GMAS EI Rate Tax Code";

                    TempVATEntry.Reset();
                    TempVATEntry.SetRange("Document No.", VATEntry."Document No.");
                    TempVATEntry.SetRange("Posting Date", VATEntry."Posting Date");
                    TempVATEntry.SetRange("Tax Area Code", VATEntry."Tax Area Code");
                    TempVATEntry.SetRange("Internal Ref. No.", EIRateTaxCode);
                    if not TempVATEntry.FindFirst() then begin
                        TempVATEntry.Copy(VATEntry);
                        TempVATEntry."Internal Ref. No." := EIRateTaxCode;
                        TempVATEntry."External Document No." := TaxJurisdiction."GMAS EI Tax Code";
                        TempVATEntry."VAT Base Discount %" := TaxDetail."Tax Below Maximum";
                        TempVATEntry.Insert();
                    end else begin
                        TempVATEntry.Base += VATEntry.Base;
                        TempVATEntry.Amount += VATEntry.Amount;
                        TempVATEntry.Modify();
                    end;
                end;
            until VATEntry.Next() = 0;

        EIEXMLDocumentStructure.CreateNodeDocument('Factura');
        TempVATEntry.Reset();
        if TempVATEntry.FindSet() then
            repeat
                CountryRegion.Get(CompanyInformation."Country/Region Code");
                EIEXMLDocumentStructure.SetNombreEmisor(CompanyName);
                EIEXMLDocumentStructure.SetNombreCompania(CompanyName);
                EIEXMLDocumentStructure.SetNombreArchivo(DelChr(SalesInvoiceHeader."No.", '=', '-') + '.txt');
                EIEXMLDocumentStructure.SetIdentificadorTransaccion(TransactionIdTxt);
                EIEXMLDocumentStructure.SetIdEmpresa(CompanyInformation."EIE Company Id");
                EIEXMLDocumentStructure.SetIdContrato(CompanyInformation."EIE Contract Id");
                EIEXMLDocumentStructure.SetCanal('ws');
                EIEXMLDocumentStructure.SetIpDevice(Database.TenantId());
                EIEXMLDocumentStructure.SetUsuario(UserId());
                EIEXMLDocumentStructure.SetFechaHoraTrx(TransactionDateTimeTxt);
                EIEXMLDocumentStructure.SetVersionDocumento('1.0.0.0');
                EIEXMLDocumentStructure.SetRazonSocial(CompanyName); // Preguntar
                EIEXMLDocumentStructure.SetNombreComercial(CompanyInformation."GMAS SRI Commercial Name"); // Preguntar
                EIEXMLDocumentStructure.SetRuc(CompanyInformation."VAT Registration No.");
                EIEXMLDocumentStructure.SetCodDoc(DocumentTypeCode);
                EIEXMLDocumentStructure.SetEstab(SalesInvoiceHeader."GMAS SRI Establishment Code");
                EIEXMLDocumentStructure.SetPtoEmi(SalesInvoiceHeader."GMAS SRI Emission Point Code");
                EIEXMLDocumentStructure.SetSecuencial(CopyStr(DelChr(SalesInvoiceHeader."No.", '=', '-'), 7, 9));
                EIEXMLDocumentStructure.SetDirMatriz(CompanyAddress);
                EIEXMLDocumentStructure.SetAgenteRetencion(CompanyInformation."GMAS SRI Withholding Agent");
                EIEXMLDocumentStructure.SetFechaEmision(PostingDateTxt);
                EIEXMLDocumentStructure.SetDirEstablecimiento(ResponsibilityCenterAddress);
                EIEXMLDocumentStructure.SetTipoIdentificacionComprador(GMASEITabla06.code);
                EIEXMLDocumentStructure.SetRazonsocialComprador(CustomerName);
                EIEXMLDocumentStructure.SetIdentificacionComprador(Customer."VAT Registration No.");
                EIEXMLDocumentStructure.SetDireccioncomprador(BilltoAddress);
                EIEXMLDocumentStructure.SetContribuyenteEspecial(CompanyInformation."GMAS SRI Special Contributor");
                EIEXMLDocumentStructure.SetObligadoContabilidad(GetBooleanValue(CompanyInformation."GMAS SRI Obligation Keep Acc."));

                if SalesInvoiceHeader."GMAS SRI Document Type Code" = '05' then begin
                    EIEXMLDocumentStructure.SetCodDocModificado(AppliestoDocTypeCode);
                    EIEXMLDocumentStructure.SetNumDocModificado(AppliestoDocNo);
                    EIEXMLDocumentStructure.SetValorTotal(Format(SalesInvoiceHeader."Amount Including VAT", 0, AmountFormatLbl));
                    EIEXMLDocumentStructure.SetRazon(SalesInvoiceHeader."Posting Description");
                    //EIEXMLDocumentStructure.SetValorTotal2(Format(SalesInvoiceHeader.Amount, 0, AmountFormatLbl));
                    EIEXMLDocumentStructure.SetValorTotal2(Format(SalesInvoiceLine.Amount, 0, AmountFormatLbl))
                end;

                EIEXMLDocumentStructure.SetFechaEmisionDocSustento(AppliestoDocDate);
                //EIEXMLDocumentStructure.SetTotalSinImpuestos(Format(SalesInvoiceHeader.Amount, 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetTotalSinImpuestos(Format(SalesInvoiceLine.Amount, 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetTotalDescuento(Format(SalesInvoiceLine."Line Discount Amount" + SalesInvoiceHeader."Invoice Discount Amount", 0, AmountFormatLbl));

                if GMASSRITabla02."Transaction Type" = "GMAS SRI Transaction Type"::Export then begin
                    EIEXMLDocumentStructure.SetComercioExterior(UpperCase(CompanyInformation."GMAS EI Foreign Trade"));
                    EIEXMLDocumentStructure.SetIncoTermFactura(Format(SalesInvoiceHeader."GMAS EI Icon Term Invoice"));
                    EIEXMLDocumentStructure.SetLugarIncoTerm(SalesInvoiceHeader."GMAS EI Place Incon Term");
                    EIEXMLDocumentStructure.SetPaisOrigen(CountryRegion."GMAS SRI Contry Code");
                    EIEXMLDocumentStructure.SetPuertoEmbarque(SalesInvoiceHeader."GMAS EI Shipment Port");
                    EIEXMLDocumentStructure.SetPuertoDestino(SalesInvoiceHeader."GMAS EI Destination Port");
                    EIEXMLDocumentStructure.SetIncoTermTotalSinImpuestos(UpperCase(SalesInvoiceHeader."GMAS EI Icon Term Tot With Tax"));
                    EIEXMLDocumentStructure.SetFleteInternacional(Format(SalesInvoiceHeader."GMAS EI International Freight", 0, AmountFormatLbl));
                    EIEXMLDocumentStructure.SetSeguroInternacional(Format(SalesInvoiceHeader."GMAS EI Internat. Insurance", 0, AmountFormatLbl));
                    EIEXMLDocumentStructure.SetGastosAduaneros(Format(SalesInvoiceHeader."GMAS EI Customs Expenses", 0, AmountFormatLbl));
                    EIEXMLDocumentStructure.SetGastosTransporteOtros(Format(SalesInvoiceHeader."GMAS EI Other Trans. Expenses", 0, AmountFormatLbl));
                    if CountryRegionAdq.Get(SalesInvoiceHeader."GMAS Country/Region Code") then begin
                        EIEXMLDocumentStructure.SetPaisAdquisicion(CountryRegionAdq."GMAS SRI Contry Code");
                        EIEXMLDocumentStructure.SetPaisDestino(CountryRegionAdq."GMAS SRI Contry Code");
                    end;
                end;

                GMASSRISalesInvReimbur.Reset();
                GMASSRISalesInvReimbur.SetRange("Document No.", SalesInvoiceHeader."No.");
                if not GMASSRISalesInvReimbur.IsEmpty then begin
                    EIEXMLDocumentStructure.SetCodDocReemb('41');
                    EIEXMLDocumentStructure.SetTotalComprobantesReembolso(Format(Abs(TotalBaseImponibleReembolso + TotalImpuestoReembolso), 0, AmountFormatLbl));
                    EIEXMLDocumentStructure.SetTotalBaseImponibleReembolso(Format(Abs(TotalBaseImponibleReembolso), 0, AmountFormatLbl));
                    EIEXMLDocumentStructure.SetTotalImpuestoReembolso(Format(Abs(TotalImpuestoReembolso), 0, AmountFormatLbl));
                end;

                EIEXMLDocumentStructure.SetMoneda(Currency.Description);

                EIEXMLDocumentStructure.SetCodigo(TempVATEntry."External Document No.");
                EIEXMLDocumentStructure.SetCodigoPorcentaje(TempVATEntry."Internal Ref. No.");
                EIEXMLDocumentStructure.SetBaseImponible(Format(Abs(TempVATEntry.Base), 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetTarifa(Format(TempVATEntry."VAT Base Discount %", 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetValor(Format(Abs(TempVATEntry.Amount), 0, AmountFormatLbl));

                EIEXMLDocumentStructure.SetPropina(Format(0.00, 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetImporteTotal(Format(SalesInvoiceHeader."Amount Including VAT", 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetMontoLetras(NumberToText);
                EIEXMLDocumentStructure.SetEmail(EMail);
                EIEXMLDocumentStructure.SetTelefono(PhoneNo);
                EIEXMLDocumentStructure.SetDirAdq('');
                EIEXMLDocumentStructure.SetCiudad(SalesInvoiceHeader."Bill-to City");
                EIEXMLDocumentStructure.SetVencimiento(DueDateTxt);
                EIEXMLDocumentStructure.SetCodCliente(Customer."No.");
                EIEXMLDocumentStructure.SetOv(BilltoAddress);
                EIEXMLDocumentStructure.SetOtro('');
                EIEXMLDocumentStructure.SetFormaPago(PaymentMethodCode);
                EIEXMLDocumentStructure.SetTotal(Format(SalesInvoiceHeader."Amount Including VAT", 0, AmountFormatLbl));

                EIEXMLDocumentStructure.SetPlazo(Format(SalesInvoiceHeader."Due Date" - SalesInvoiceHeader."Document Date"));
                EIEXMLDocumentStructure.SetUnidadTiempo('DIAS');

                EIEXMLDocumentStructure.SetDescTrabajo(WorkDescription);
                EIEXMLDocumentStructure.SetCelular(MobilePhoneNo);

                if CompanyType <> '' then
                    EIEXMLDocumentStructure.setAdicionalData('_TipoEmpresa', CompanyType);

                if SalesInvoiceHeader."Payment Terms Code" <> '' then
                    AddQuotasSalesDocument(EIEXMLDocumentStructure, SalesInvoiceHeader);

                SalesCommentLine.Reset();
                SalesCommentLine.SetRange("Document Type", SalesCommentLine."Document Type"::"Posted Invoice");
                SalesCommentLine.SetRange("No.", SalesInvoiceHeader."No.");
                SalesCommentLine.SetRange("Document Line No.", 0);
                if SalesCommentLine.FindSet() then
                    repeat
                        TagAdd := SalesCommentLine.Comment.Split(':');
                        if TagAdd.Get(1, TagName) then;
                        if TagAdd.Get(2, TagValue) then;
                        ReplaceSpecialChar(TagName);
                        ReplaceSpecialChar(TagValue);
                        EIEXMLDocumentStructure.setAdicionalData(TagName.Trim(), TagValue.Trim());
                    until SalesCommentLine.Next() = 0;

                SalesInvoiceLine.Reset();
                SalesInvoiceLine.SetCurrentKey("No.", "Posting Date");
                SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                SalesInvoiceLine.SetFilter(Type, '<>%1', "Sales Line Type"::" ");
                SalesInvoiceLine.SetFilter(Quantity, '<>%1', 0);
                if SalesInvoiceLine.FindSet() then
                    repeat
                        if not ((InvoiceRoundingAccount <> '') and (Round(Abs(SalesInvoiceLine.Amount), 0.01) = 0) and (SalesInvoiceLine.Type = "Sales Line Type"::"G/L Account") and (SalesInvoiceLine."No." = InvoiceRoundingAccount)) then begin
                            EIEXMLDocumentStructure.deleteAddDataLine();
                            Clear(LotNo);
                            Clear(ExpirationDate);
                            TempItemLedgerEntry.Reset();
                            TempItemLedgerEntry.DeleteAll();
                            Clear(TaxJurisdiction);
                            Clear(EIRateTaxCode);
                            TaxAreaLine.Reset();
                            TaxAreaLine.SetRange("Tax Area", SalesInvoiceLine."Tax Area Code");
                            if TaxAreaLine.FindSet() then
                                repeat
                                    TaxDetail.Reset();
                                    TaxDetail.SetRange("Tax Jurisdiction Code", TaxAreaLine."Tax Jurisdiction Code");
                                    TaxDetail.SetRange("Tax Group Code", SalesInvoiceLine."Tax Group Code");
                                    TaxDetail.SetFilter("Effective Date", '<=%1', SalesInvoiceLine."Posting Date");
                                    TaxDetail.SetRange("Tax Type", TaxDetail."Tax Type"::"Sales Tax");
                                    TaxDetail.SetRange("GMAS SRI Tax Type", "GMAS SRI Tax Type"::VAT);
                                    if TaxDetail.FindLast() then begin
                                        TaxDetail.TestField("GMAS EI Rate Tax Code");
                                        TaxJurisdiction.Get(TaxDetail."Tax Jurisdiction Code");
                                        EIRateTaxCode := TaxDetail."GMAS EI Rate Tax Code";
                                        break;
                                    end;
                                until TaxAreaLine.Next() = 0;

                            Description := SalesInvoiceLine.Description;
                            ReplaceSpecialChar(Description);
                            if Description = '' then
                                Description := SalesInvoiceLine."No.";

                            //if (TempVATEntry."Internal Ref. No." = TaxJurisdiction."GMAS EI Rate Tax Code") and (TempVATEntry."External Document No." = TaxJurisdiction."GMAS EI Tax Code") then begin
                            if (TempVATEntry."Internal Ref. No." = EIRateTaxCode) and (TempVATEntry."External Document No." = TaxJurisdiction."GMAS EI Tax Code") then begin
                                ItemCode := SalesInvoiceLine."No.";

                                if SalesInvoiceLine.Type = "Sales Line Type"::Item then begin
                                    Item.Get(SalesInvoiceLine."No.");
                                    if Item.GTIN <> '' then
                                        ItemCode := Item.GTIN;
                                end;

                                EIEXMLDocumentStructure.SetCodigoPrincipal(ItemCode);
                                EIEXMLDocumentStructure.SetCodigoAuxiliar(Item."Common Item No.");
                                EIEXMLDocumentStructure.SetCodigoInterno(SalesInvoiceLine."No.");
                                EIEXMLDocumentStructure.SetCodigoAdicional(SalesInvoiceLine."No.");
                                EIEXMLDocumentStructure.SetLnItmSeq(Format(SalesInvoiceLine."Line No."));
                                EIEXMLDocumentStructure.SetDescripcion(Description);
                                EIEXMLDocumentStructure.SetCantidad(Format(SalesInvoiceLine.Quantity, 0, QuantityFormatLbl));
                                EIEXMLDocumentStructure.SetPrecioUnitario(Format(Abs(SalesInvoiceLine."Unit Price"), 0, UnitPriceFormatLbl));
                                EIEXMLDocumentStructure.SetDescuento(Format(SalesInvoiceLine."Line Discount Amount" + SalesInvoiceLine."Inv. Discount Amount", 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.SetPrecioTotalSinImpuesto(Format(SalesInvoiceLine.Amount, 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.SetCodigoImpItem(TaxJurisdiction."GMAS EI Tax Code");
                                EIEXMLDocumentStructure.SetCodigoPorcentajeItem(EIRateTaxCode);
                                EIEXMLDocumentStructure.SetTarifaImpItem(Format(TaxDetail."Tax Below Maximum", 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.SetBaseImponibleItem(Format(SalesInvoiceLine."VAT Base Amount", 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.SetValorImpItem(Format(SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine.Amount, 0, AmountFormatLbl));

                                ItemTrackingDocManagement.RetrieveEntriesFromPostedInvoice(TempItemLedgerEntry, SalesInvoiceLine.RowID1());// RetrieveEntriesFromShptRcpt(TempItemLedgerEntry, DATABASE::"Sales Invoice Line", 0, SalesInvoiceLine."Document No.", '', 0, SalesInvoiceLine."Line No.");
                                if TempItemLedgerEntry.FindSet() then
                                    repeat
                                        if TempItemLedgerEntry."Lot No." <> '' then
                                            if LotNo = '' then begin
                                                LotNo := TempItemLedgerEntry."Lot No.";
                                                ExpirationDate := Format(TempItemLedgerEntry."Expiration Date", 0, PostingDateFormatLbl);
                                            end else begin
                                                LotNo += ', ' + TempItemLedgerEntry."Lot No.";
                                                ExpirationDate += ', ' + Format(TempItemLedgerEntry."Expiration Date", 0, PostingDateFormatLbl);
                                            end;

                                    until TempItemLedgerEntry.Next() = 0;

                                if LotNo <> '' then
                                    EIEXMLDocumentStructure.setAdicionalDataLine('det_col5_lote', CopyStr(LotNo, 1, 300));

                                if ExpirationDate <> '' then
                                    EIEXMLDocumentStructure.setAdicionalDataLine('det_col6_vence', CopyStr(ExpirationDate, 1, 300));

                                CommentCount := 0;

                                SalesCommentLine.Reset();
                                SalesCommentLine.SetRange("Document Type", SalesCommentLine."Document Type"::"Posted Invoice");
                                SalesCommentLine.SetRange("No.", SalesInvoiceHeader."No.");
                                SalesCommentLine.SetRange("Document Line No.", SalesInvoiceLine."Line No.");
                                SalesCommentLine.SetFilter(Comment, '<>%1', '');
                                if SalesCommentLine.FindSet() then
                                    repeat
                                        CommentCount += 1;
                                        EIEXMLDocumentStructure.setAdicionalDataLine('det_comment' + Format(CommentCount), SalesCommentLine.Comment);
                                    until SalesCommentLine.Next() = 0;

                                Clear(SalesInvReimburRow);
                                GMASSRISalesInvReimbur.Reset();
                                GMASSRISalesInvReimbur.SetRange("Document No.", SalesInvoiceHeader."No.");
                                if GMASSRISalesInvReimbur.FindSet() then
                                    repeat
                                        CountryRegion.Get(GMASSRISalesInvReimbur."SRI Country/Region Code");

                                        GMASSRITabla02.Get(GMASSRISalesInvReimbur."SRI Identification Type Code");
                                        GMASEITabla06.Reset();
                                        GMASEITabla06.SetRange("Identification Type", GMASSRITabla02."Identification Type");
                                        GMASEITabla06.FindFirst();

                                        EIEXMLDocumentStructure.SetTipoIdentificacionProveedorReembolso(GMASEITabla06.Code);
                                        EIEXMLDocumentStructure.SetIdentificacionProveedorReembolso(GMASSRISalesInvReimbur."SRI Identification No.");
                                        EIEXMLDocumentStructure.SetCodPaisPagoProveedorReembolso(CountryRegion."GMAS SRI Contry Code");
                                        EIEXMLDocumentStructure.SetTipoProveedorReembolso(GMASSRISalesInvReimbur."SRI Customer Type Code");
                                        EIEXMLDocumentStructure.SetCodDocReembolso(GMASSRISalesInvReimbur."SRI Document Type Code");
                                        EIEXMLDocumentStructure.SetEstabDocReembolso(CopyStr(GMASSRISalesInvReimbur."SRI Reimbursement No.", 1, 3));
                                        EIEXMLDocumentStructure.SetPtoEmiDocReembolso(CopyStr(GMASSRISalesInvReimbur."SRI Reimbursement No.", 5, 3));
                                        EIEXMLDocumentStructure.SetSecuencialDocReembolso(CopyStr(GMASSRISalesInvReimbur."SRI Reimbursement No.", 9, 9));
                                        EIEXMLDocumentStructure.SetFechaEmisionDocReembolso(Format(GMASSRISalesInvReimbur."SRI Reimbursement Date", 0, PostingDateFormatLbl));
                                        EIEXMLDocumentStructure.SetNumeroautorizacionDocReemb(GMASSRISalesInvReimbur."SRI Authorization Number");

                                        if GMASSRISalesInvReimbur."SRI Taxable Base VAT Diff. 0" <> 0.00 then begin
                                            SalesInvReimburRow += 1;
                                            EITabla17.Reset();
                                            EITabla17.SetRange("VAT %", GMASSRISalesInvReimbur."SRI VAT %");
                                            if EITabla17.FindFirst() then;
                                            EIEXMLDocumentStructure.SetDexrowid(Format(SalesInvReimburRow));
                                            EIEXMLDocumentStructure.SetCodigoImpReemb('2');
                                            EIEXMLDocumentStructure.SetCodigoPorcentajeReemb(EITabla17.Code);
                                            EIEXMLDocumentStructure.SetTarifaImpReemb(Format(GMASSRISalesInvReimbur."SRI VAT %", 0, Amount0FormatLbl));
                                            EIEXMLDocumentStructure.SetBaseImponibleReembolso(Format(GMASSRISalesInvReimbur."SRI Taxable Base VAT Diff. 0", 0, AmountFormatLbl));
                                            EIEXMLDocumentStructure.SetImpuestoReembolso(Format(GMASSRISalesInvReimbur."SRI VAT Amount", 0, AmountFormatLbl));
                                            EIEXMLDocumentStructure.AddData();
                                        end;
                                        if GMASSRISalesInvReimbur."SRI Taxable Base VAT 0" <> 0.00 then begin
                                            SalesInvReimburRow += 1;
                                            EIEXMLDocumentStructure.SetDexrowid(Format(SalesInvReimburRow));
                                            EIEXMLDocumentStructure.SetCodigoImpReemb('2');
                                            EIEXMLDocumentStructure.SetCodigoPorcentajeReemb('0');
                                            EIEXMLDocumentStructure.SetTarifaImpReemb('0');
                                            EIEXMLDocumentStructure.SetBaseImponibleReembolso(Format(GMASSRISalesInvReimbur."SRI Taxable Base VAT 0", 0, AmountFormatLbl));
                                            EIEXMLDocumentStructure.SetImpuestoReembolso('0.00');
                                            EIEXMLDocumentStructure.AddData();
                                        end;
                                        if GMASSRISalesInvReimbur."SRI Taxable Base Not Subj. VAT" <> 0.00 then begin
                                            SalesInvReimburRow += 1;
                                            EIEXMLDocumentStructure.SetDexrowid(Format(SalesInvReimburRow));
                                            EIEXMLDocumentStructure.SetCodigoImpReemb('2');
                                            EIEXMLDocumentStructure.SetCodigoPorcentajeReemb('6');
                                            EIEXMLDocumentStructure.SetTarifaImpReemb('0');
                                            EIEXMLDocumentStructure.SetBaseImponibleReembolso(Format(GMASSRISalesInvReimbur."SRI Taxable Base Not Subj. VAT", 0, AmountFormatLbl));
                                            EIEXMLDocumentStructure.SetImpuestoReembolso('0.00');
                                            EIEXMLDocumentStructure.AddData();
                                        end;
                                        if GMASSRISalesInvReimbur."SRI Taxable Base Exempt VAT" <> 0.00 then begin
                                            SalesInvReimburRow += 1;
                                            EIEXMLDocumentStructure.SetDexrowid(Format(SalesInvReimburRow));
                                            EIEXMLDocumentStructure.SetCodigoImpReemb('2');
                                            EIEXMLDocumentStructure.SetCodigoPorcentajeReemb('7');
                                            EIEXMLDocumentStructure.SetTarifaImpReemb('0');
                                            EIEXMLDocumentStructure.SetBaseImponibleReembolso(Format(GMASSRISalesInvReimbur."SRI Taxable Base Exempt VAT", 0, AmountFormatLbl));
                                            EIEXMLDocumentStructure.SetImpuestoReembolso('0.00');
                                            EIEXMLDocumentStructure.AddData();
                                        end;
                                    until GMASSRISalesInvReimbur.Next() = 0;

                                GMASSRISalesInvReimbur.Reset();
                                GMASSRISalesInvReimbur.SetRange("Document No.", SalesInvoiceHeader."No.");
                                if GMASSRISalesInvReimbur.IsEmpty then
                                    EIEXMLDocumentStructure.AddData();
                            end;
                        end;
                    until SalesInvoiceLine.Next() = 0;
            until TempVATEntry.Next() = 0;

        EIEXMLDocumentStructure.Run();
    end;

    local procedure AddQuotasSalesDocument(var EIEXMLDocumentStructure: Codeunit "EIE XML Document Structure"; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        PaymentTerms: Record "Payment Terms";
        DateFormulatValue: DateFormula;
        ValueList: List of [Text];
        ValueText: Text;
        QuotasNumbers: Integer;
        Control: Integer;
        AmountQuota: Decimal;
        AmountDifQuota: Decimal;
    begin
        PaymentTerms.Get(SalesInvoiceHeader."Payment Terms Code");

        Clear(Control);
        Clear(DateFormulatValue);

        ValueList := PaymentTerms.Description.Split('/');
        QuotasNumbers := ValueList.Count();
        AmountQuota := Round(SalesInvoiceHeader."Amount Including VAT" / QuotasNumbers, 0.01);
        AmountDifQuota := SalesInvoiceHeader."Amount Including VAT";

        foreach ValueText in ValueList do begin
            Control += 1;

            if Evaluate(DateFormulatValue, ValueText) then begin
                PaymentTerms.Reset();
                PaymentTerms.SetFilter("Due Date Calculation", '%1', DateFormulatValue);
                //PaymentTerms.SetRange("GMAS Quotas", false);
                if PaymentTerms.FindFirst() then begin
                    AmountDifQuota := AmountDifQuota - AmountQuota;
                    if Control = QuotasNumbers then
                        AmountQuota := AmountQuota + AmountDifQuota;

                    EIEXMLDocumentStructure.setAdicionalData('_CUOTA' + Format(Control), 'F. Vencimiento: ' + Format(CalcDate(PaymentTerms."Due Date Calculation", SalesInvoiceHeader."Document Date"), 0, PostingDateFormatLbl) + ', ' + Format(AmountQuota, 0, AmountFormatLbl));
                end;
            end;
        end;
    end;

    /// <summary>
    /// DownloadSalesInvoiceDocument.
    /// </summary>
    /// <param name="SalesInvoiceHeader">Record "Sales Invoice Header".</param>
    procedure DownloadSalesInvoiceDocument(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        GenerateSalesInvoiceDocument(SalesInvoiceHeader).DownloadFileXml(SalesInvoiceHeader."No." + '.xml');
    end;

    /// <summary>
    /// StatusSalesInvoiceDocument.
    /// </summary>
    /// <param name="SalesInvoiceHeader">VAR Record "Sales Invoice Header".</param>
    procedure StatusSalesInvoiceDocument(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        CompanyInformation: Record "Company Information";
        EIEWebServiceRequest: Codeunit "EIE Web Service Request";
        GMASEIElectronicDocStatus: Enum "GMAS EI Electronic Doc. Status";
        DocumentTypeCode: Code[3];
        ResponseText: Text;
        Estado: Text;
        CodigoError: Text;
        DescripcionError: Text;
        NumeroAutorizacion: Text;
        ClaveAcceso: Text;
        FechaAutorizacionSRI: Text;
        JsonBody: JsonObject;
        ResponseJson: JsonObject;
        ResponseToken: JsonToken;
        AuthorizationDateTime: DateTime;
    begin
        CompanyInformation.Get();
        DocumentTypeCode := SalesInvoiceHeader."GMAS SRI Document Type Code";
        if DocumentTypeCode in ['18', '41', '16', '21'] then
            DocumentTypeCode := '01';

        JsonBody.Add(TipoDocumentoTxt, DocumentTypeCode);
        JsonBody.Add(NumeroDocumentoTxt, SalesInvoiceHeader."No.");
        JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
        JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
        JsonBody.Add(IdTransaccionTxt, SalesInvoiceHeader."EIE Id. Transaction Api");

        if EIEWebServiceRequest.RequestWebService(JsonBody, CompanyInformation."EIE Consult API URL", CompanyInformation."EIE Token API", ResponseText) then begin
            ResponseJson.ReadFrom(ResponseText);
            if ResponseJson.Get('estado', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    Estado := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('codigoError', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    CodigoError := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('descripcionError', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    DescripcionError := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('numeroAutorizacion', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    NumeroAutorizacion := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('claveAcceso', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    ClaveAcceso := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('fechaAutorizacionSRI', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    FechaAutorizacionSRI := ResponseToken.AsValue().AsText();

            if FechaAutorizacionSRI <> '' then
                if StrPos(FechaAutorizacionSRI, 'Z') = 0 then
                    Evaluate(AuthorizationDateTime, FechaAutorizacionSRI + 'Z')
                else
                    Evaluate(AuthorizationDateTime, FechaAutorizacionSRI);

            GMASEIElectronicDocStatus := GetElectronicStatus(Estado);

            SalesInvoiceHeader."GMAS EI Electronic Doc. Status" := GMASEIElectronicDocStatus;
            SalesInvoiceHeader."GMAS EI Error Code" := CopyStr(CodigoError, 1, 10);
            SalesInvoiceHeader."GMAS SRI Authorization No." := CopyStr(NumeroAutorizacion, 1, 49);
            SalesInvoiceHeader."GMAS SRI Authorization Date" := AuthorizationDateTime;
            SalesInvoiceHeader.SetErrorDescription(DescripcionError);
            SalesInvoiceHeader.Modify();
        end;
    end;

    /// <summary>
    /// AuthorizeSalesCreditMemoDocument.
    /// </summary>
    /// <param name="SalesCrMemoHeader">VAR Record "Sales Cr.Memo Header".</param>
    procedure AuthorizeSalesCreditMemoDocument(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        EIEWebServiceRequest: Codeunit "EIE Web Service Request";
        IdentificadorTransaccion: Text[20];
        GMASEIElectronicDocStatus: Enum "GMAS EI Electronic Doc. Status";
        Estado: Text;
        XmlDocText: Text;
        CodigoError: Text;
        ResponseText: Text;
        DescripcionError: Text;
        JsonBody: JsonObject;
        ResponseJson: JsonObject;
        ResponseToken: JsonToken;
    begin
        CompanyInformation.Get();

        XmlDoc := GenerateSalesCreditMemoDocument(SalesCrMemoHeader).GetFileXmlDocument();
        XmlDoc.WriteTo(XmlDocText);

        if XmlDocText <> '' then begin
            Customer.Get(SalesCrMemoHeader."Bill-to Customer No.");

            JsonBody.Add(NombreEmisorTxt, CompanyName);
            JsonBody.Add(NombreCompaniaTxt, CompanyName);
            JsonBody.Add(TipoDocumentoTxt, SalesCrMemoHeader."GMAS SRI Document Type Code");
            JsonBody.Add(NumeroDocumentoTxt, SalesCrMemoHeader."No.");
            JsonBody.Add(DocSustentoTxt, DelChr(SalesCrMemoHeader."No.", '=', '-'));
            JsonBody.Add(IdReceptorTxt, Customer."VAT Registration No.");
            JsonBody.Add(FechaDocumentoTxt, Format(SalesCrMemoHeader."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>'));
            JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
            JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
            JsonBody.Add(UsuarioTxt, UserId());
            JsonBody.Add(DataDocumentoTxt, XmlDocText);
            JsonBody.Add(IdTransaccionTxt, TransactionIdTxt);

            //Envia el documento al APi de facturación electrónica
            if EIEWebServiceRequest.RequestWebService(JsonBody, CompanyInformation."EIE Authorization API URL", CompanyInformation."EIE Token API", ResponseText) then begin
                ResponseJson.ReadFrom(ResponseText);
                if ResponseJson.Get('estado', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        Estado := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('codigoError', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        CodigoError := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('descripcionError', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        DescripcionError := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('identificadorTransaccion', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        IdentificadorTransaccion := CopyStr(ResponseToken.AsValue().AsText(), 1, 20);

                GMASEIElectronicDocStatus := GetElectronicStatus(Estado);

                SalesCrMemoHeader."GMAS EI Electronic Doc. Status" := GMASEIElectronicDocStatus;
                SalesCrMemoHeader."EIE Id. Transaction Api" := IdentificadorTransaccion;
                SalesCrMemoHeader."GMAS EI Error Code" := CopyStr(CodigoError, 1, 10);
                SalesCrMemoHeader.SetErrorDescription(DescripcionError);
                SalesCrMemoHeader.Modify();

                if Estado = '01' then begin
                    Clear(JsonBody);
                    JsonBody.Add(TipoDocumentoTxt, SalesCrMemoHeader."GMAS SRI Document Type Code");
                    JsonBody.Add(NumeroDocumentoTxt, SalesCrMemoHeader."No.");
                    JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
                    JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
                    JsonBody.Add(IdTransaccionTxt, TransactionIdTxt);

                    StatusSalesCreditMemoDocument(SalesCrMemoHeader);
                end;
            end;
        end;
    end;

    local procedure GenerateSalesCreditMemoDocument(SalesCrMemoHeader: Record "Sales Cr.Memo Header") EIEXMLDocumentStructure: Codeunit "EIE XML Document Structure";
    var
        CompanyInformation: Record "Company Information";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        CustomerPostingGroup: Record "Customer Posting Group";
        Customer: Record Customer;
        VATEntry: Record "VAT Entry";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TempVATEntry: Record "VAT Entry" temporary;
        GMASSRITabla02: Record "GMAS SRI Tabla 02";
        GMASEITabla06: Record "GMAS EI Tabla 06";
        Item: Record Item;
        SalesCommentLine: Record "Sales Comment Line";
        FormatNumberToText: Codeunit "EIE Format Number To Text";
        AppliestoDocNo: Code[20];
        AppliestoDocTypeCode: Code[3];
        CompanyName: Text;
        Description: Text;
        CustomerName: Text;
        SelltoAddress: Text;
        CompanyAddress: Text;
        AppliestoDocDate: Text;
        WorkDescription: Text;
        ResponsibilityCenterAddress: Text;
        NoText: array[2] of Text[80];
        NumberToText: Text;
        InvoiceRoundingAccount: Code[20];
        ItemCode: Code[20];
        TagAdd: List of [Text];
        TagName: Text;
        TagValue: Text;
        EIRateTaxCode: Code[10];
        CodigoAdicional: Code[20];
        CompanyType: Text;
        CommentCount: Integer;
    begin
        TransactionIdTxt := Format(CurrentDateTime(), 0, TransactionFormatLbl);
        TransactionDateTimeTxt := Format(SalesCrMemoHeader.SystemCreatedAt, 0, TransactionDateFormatLbl);
        PostingDateTxt := Format(SalesCrMemoHeader."Posting Date", 0, PostingDateFormatLbl);
        DueDateTxt := Format(SalesCrMemoHeader."Due Date", 0, PostingDateFormatLbl);

        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
        Customer.Get(SalesCrMemoHeader."Bill-to Customer No.");
        ResponsibilityCenter.Get(SalesCrMemoHeader."Responsibility Center");
        SalesCrMemoHeader.CalcFields(Amount, "Amount Including VAT", "Invoice Discount Amount");
        if SalesCrMemoHeader."Currency Code" = '' then
            Currency.Get(GeneralLedgerSetup."LCY Code")
        else
            Currency.Get(SalesCrMemoHeader."Currency Code");

        Clear(NoText);
        FormatNumberToText.InitTextVariable();
        FormatNumberToText.FormatNoText(NoText, SalesCrMemoHeader."Amount Including VAT", SalesCrMemoHeader."Currency Code");
        NumberToText := NoText[1] + ' ' + NoText[2];

        GMASSRITabla02.Get(Customer."GMAS SRI Ident. Type Code");
        GMASEITabla06.Reset();
        GMASEITabla06.SetRange("Identification Type", GMASSRITabla02."Identification Type");
        GMASEITabla06.FindFirst();

        if (SalesCrMemoHeader."Applies-to Doc. Type" = "Gen. Journal Document Type"::Invoice) and (SalesCrMemoHeader."Applies-to Doc. No." <> '')
            and (StrLen(SalesCrMemoHeader."External Document No.") <> 17) then begin
            if SalesInvoiceHeader.Get(SalesCrMemoHeader."Applies-to Doc. No.") and (SalesInvoiceHeader."GMAS SRI Document Type Code" <> '') then begin
                AppliestoDocNo := SalesInvoiceHeader."No.";
                AppliestoDocTypeCode := '01';
                if SalesCrMemoHeader."GMAS SRI Applies-to Doc. Date" <> 0D then
                    AppliestoDocDate := Format(SalesCrMemoHeader."GMAS SRI Applies-to Doc. Date", 0, PostingDateFormatLbl)
                else
                    AppliestoDocDate := Format(SalesInvoiceHeader."Posting Date", 0, PostingDateFormatLbl);
            end else begin
                AppliestoDocNo := '000-000-000000000';
                AppliestoDocTypeCode := '00';
                if SalesCrMemoHeader."GMAS SRI Applies-to Doc. Date" <> 0D then
                    AppliestoDocDate := Format(SalesCrMemoHeader."GMAS SRI Applies-to Doc. Date", 0, PostingDateFormatLbl)
                else
                    AppliestoDocDate := Format(WorkDate(), 0, PostingDateFormatLbl);
            end;
        end else
            if (SalesCrMemoHeader."External Document No." <> '') and (StrLen(SalesCrMemoHeader."External Document No.") = 17) then begin
                AppliestoDocNo := CopyStr(SalesCrMemoHeader."External Document No.", 1, 20);
                AppliestoDocTypeCode := '01';
                if SalesCrMemoHeader."GMAS SRI Applies-to Doc. Date" <> 0D then
                    AppliestoDocDate := Format(SalesCrMemoHeader."GMAS SRI Applies-to Doc. Date", 0, PostingDateFormatLbl)
                else
                    AppliestoDocDate := Format(WorkDate(), 0, PostingDateFormatLbl);
            end else begin
                AppliestoDocNo := '000-000-000000000';
                AppliestoDocTypeCode := '00';
                if SalesCrMemoHeader."GMAS SRI Applies-to Doc. Date" <> 0D then
                    AppliestoDocDate := Format(SalesCrMemoHeader."GMAS SRI Applies-to Doc. Date", 0, PostingDateFormatLbl)
                else
                    AppliestoDocDate := Format(WorkDate(), 0, PostingDateFormatLbl);
            end;

        CompanyName := CompanyInformation.Name;
        ReplaceSpecialChar(CompanyName);

        CompanyAddress := CompanyInformation.Address;
        ReplaceSpecialChar(CompanyAddress);

        CustomerName := Customer.Name;
        ReplaceSpecialChar(CustomerName);

        SelltoAddress := SalesCrMemoHeader."Bill-to Address";
        ReplaceSpecialChar(SelltoAddress);

        ResponsibilityCenterAddress := ResponsibilityCenter.Address;
        ReplaceSpecialChar(ResponsibilityCenterAddress);

        WorkDescription := CopyStr(SalesCrMemoHeader.GetWorkDescription(), 1, 300);
        ReplaceSpecialChar(WorkDescription);

        if CustomerPostingGroup.Get(Customer."Customer Posting Group") then
            InvoiceRoundingAccount := CustomerPostingGroup."Invoice Rounding Account";

        SalesCrMemoLine.Reset();
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter(Type, '<>%1', "Sales Line Type"::" ");
        SalesCrMemoLine.SetFilter("No.", '<>%1', InvoiceRoundingAccount);
        SalesCrMemoLine.CalcSums("Line Discount Amount", Amount);

        TempVATEntry.Reset();
        TempVATEntry.DeleteAll();

        VATEntry.Reset();
        VATEntry.SetCurrentKey("Document No.", "Posting Date", "Tax Jurisdiction Code");
        VATEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        VATEntry.SetRange("Posting Date", SalesCrMemoHeader."Posting Date");
        VATEntry.SetRange("Document Type", "Gen. Journal Document Type"::"Credit Memo");
        if VATEntry.FindSet() then
            repeat
                TaxDetail.Reset();
                TaxDetail.SetRange("Tax Group Code", VATEntry."Tax Group Code");
                TaxDetail.SetRange("Tax Jurisdiction Code", VATEntry."Tax Jurisdiction Code");
                TaxDetail.SetFilter("Effective Date", '<=%1', VATEntry."Posting Date");
                TaxDetail.SetRange("Tax Type", TaxDetail."Tax Type"::"Sales Tax");
                TaxDetail.SetRange("GMAS SRI Tax Type", "GMAS SRI Tax Type"::VAT);
                if TaxDetail.FindLast() then begin
                    TaxDetail.TestField("GMAS EI Rate Tax Code");
                    TaxJurisdiction.Get(VATEntry."Tax Jurisdiction Code");
                    EIRateTaxCode := TaxDetail."GMAS EI Rate Tax Code";

                    TempVATEntry.Reset();
                    TempVATEntry.SetRange("Document No.", VATEntry."Document No.");
                    TempVATEntry.SetRange("Posting Date", VATEntry."Posting Date");
                    TempVATEntry.SetRange("Tax Area Code", VATEntry."Tax Area Code");
                    TempVATEntry.SetRange("Internal Ref. No.", EIRateTaxCode);
                    if not TempVATEntry.FindFirst() then begin
                        TempVATEntry.Copy(VATEntry);
                        TempVATEntry."Internal Ref. No." := EIRateTaxCode;
                        TempVATEntry."External Document No." := TaxJurisdiction."GMAS EI Tax Code";
                        TempVATEntry."VAT Base Discount %" := TaxDetail."Tax Below Maximum";
                        TempVATEntry.Insert();
                    end else begin
                        TempVATEntry.Base += VATEntry.Base;
                        TempVATEntry.Amount += VATEntry.Amount;
                        TempVATEntry.Modify();
                    end;
                end;
            until VATEntry.Next() = 0;

        Clear(CompanyType);

        if CompanyInformation."GMAS EI Foreign Trade" <> '' then
            CompanyType := 'EXPORTADORES HABITUALES DE BIENES RESOLUCIÓN No. ' + CompanyInformation."GMAS EI Foreign Trade";

        EIEXMLDocumentStructure.CreateNodeDocument('Notas Credito');

        TempVATEntry.Reset();
        if TempVATEntry.FindSet() then
            repeat
                EIEXMLDocumentStructure.SetNombreEmisor(CompanyName);
                EIEXMLDocumentStructure.SetNombreCompania(CompanyName);
                EIEXMLDocumentStructure.SetNombreArchivo(DelChr(SalesCrMemoHeader."No.", '=', '-') + '.txt');
                EIEXMLDocumentStructure.SetIdentificadorTransaccion(TransactionIdTxt);
                EIEXMLDocumentStructure.SetIdEmpresa(CompanyInformation."EIE Company Id");
                EIEXMLDocumentStructure.SetIdContrato(CompanyInformation."EIE Contract Id");
                EIEXMLDocumentStructure.SetCanal('ws');
                EIEXMLDocumentStructure.SetIpDevice(Database.TenantId());
                EIEXMLDocumentStructure.SetUsuario(UserId());
                EIEXMLDocumentStructure.SetFechaHoraTrx(TransactionDateTimeTxt);
                EIEXMLDocumentStructure.SetVersionDocumento('1.0.0.0');
                EIEXMLDocumentStructure.SetRazonSocial(CompanyName);
                EIEXMLDocumentStructure.SetNombreComercial(CompanyInformation."GMAS SRI Commercial Name");
                EIEXMLDocumentStructure.SetRuc(CompanyInformation."VAT Registration No.");
                EIEXMLDocumentStructure.SetCodDoc(SalesCrMemoHeader."GMAS SRI Document Type Code");
                EIEXMLDocumentStructure.SetEstab(SalesCrMemoHeader."GMAS SRI Establishment Code");
                EIEXMLDocumentStructure.SetPtoEmi(SalesCrMemoHeader."GMAS SRI Emission Point Code");
                EIEXMLDocumentStructure.SetSecuencial(CopyStr(DelChr(SalesCrMemoHeader."No.", '=', '-'), 7, 9));
                EIEXMLDocumentStructure.SetDirMatriz(CompanyAddress);
                EIEXMLDocumentStructure.SetAgenteRetencion(CompanyInformation."GMAS SRI Withholding Agent");
                EIEXMLDocumentStructure.SetFechaEmision(PostingDateTxt);
                EIEXMLDocumentStructure.SetDirEstablecimiento(ResponsibilityCenterAddress);
                EIEXMLDocumentStructure.SetTipoIdentificacionComprador(GMASEITabla06.Code);
                EIEXMLDocumentStructure.SetRazonsocialComprador(CustomerName);
                EIEXMLDocumentStructure.SetIdentificacionComprador(Customer."VAT Registration No.");
                EIEXMLDocumentStructure.SetDireccioncomprador(SelltoAddress);
                EIEXMLDocumentStructure.SetContribuyenteEspecial(CompanyInformation."GMAS SRI Special Contributor");
                EIEXMLDocumentStructure.SetObligadoContabilidad(GetBooleanValue(CompanyInformation."GMAS SRI Obligation Keep Acc."));
                EIEXMLDocumentStructure.SetCodDocModificado(AppliestoDocTypeCode);
                EIEXMLDocumentStructure.SetNumDocModificado(AppliestoDocNo);
                //EIEXMLDocumentStructure.SetTotalConImpuestos(Format(SalesCrMemoHeader."Amount Including VAT", 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetFechaEmisionDocSustento(AppliestoDocDate);
                //EIEXMLDocumentStructure.SetTotalSinImpuestos(Format(SalesCrMemoHeader.Amount, 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetTotalSinImpuestos(Format(SalesCrMemoLine.Amount, 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetTotalDescuento(Format(SalesCrMemoLine."Line Discount Amount" + SalesCrMemoHeader."Invoice Discount Amount", 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetValorModificacion(Format(SalesCrMemoHeader."Amount Including VAT", 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetMoneda(Currency.Description);

                EIEXMLDocumentStructure.SetCodigo(TempVATEntry."External Document No.");
                EIEXMLDocumentStructure.SetCodigoPorcentaje(TempVATEntry."Internal Ref. No.");
                EIEXMLDocumentStructure.SetBaseImponible(Format(Abs(TempVATEntry.Base), 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetTarifa(Format(TempVATEntry."VAT Base Discount %", 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetValor(Format(Abs(TempVATEntry.Amount), 0, AmountFormatLbl));

                EIEXMLDocumentStructure.SetMotivo(SalesCrMemoHeader."Posting Description");
                EIEXMLDocumentStructure.SetMontoLetras(NumberToText);
                EIEXMLDocumentStructure.SetEmail(SalesCrMemoHeader."Sell-to E-Mail");
                EIEXMLDocumentStructure.SetTelefono(SalesCrMemoHeader."Sell-to Phone No.");
                EIEXMLDocumentStructure.SetDirAdq('');
                EIEXMLDocumentStructure.SetCiudad(SalesCrMemoHeader."Sell-to City");
                EIEXMLDocumentStructure.SetVencimiento(DueDateTxt);
                EIEXMLDocumentStructure.SetCodCliente(Customer."No.");
                EIEXMLDocumentStructure.SetOv(SelltoAddress);
                EIEXMLDocumentStructure.SetOtro('');
                EIEXMLDocumentStructure.SetDescTrabajo(WorkDescription);

                if CompanyType <> '' then
                    EIEXMLDocumentStructure.setAdicionalData('_TipoEmpresa', CompanyType);

                SalesCommentLine.Reset();
                SalesCommentLine.SetRange("Document Type", SalesCommentLine."Document Type"::"Posted Credit Memo");
                SalesCommentLine.SetRange("No.", SalesCrMemoHeader."No.");
                SalesCommentLine.setrange("Document Line No.", 0);
                if SalesCommentLine.FindSet() then
                    repeat
                        TagAdd := SalesCommentLine.Comment.Split(':');
                        if TagAdd.Get(1, TagName) then;
                        if TagAdd.Get(2, TagValue) then;
                        ReplaceSpecialChar(TagName);
                        ReplaceSpecialChar(TagValue);
                        EIEXMLDocumentStructure.setAdicionalData(TagName.Trim(), TagValue.Trim());
                    until SalesCommentLine.Next() = 0;

                SalesCrMemoLine.SetCurrentKey("No.", "Posting Date");
                SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                SalesCrMemoLine.SetFilter(Type, '<>%1', "Sales Line Type"::" ");
                SalesCrMemoLine.SetFilter(Quantity, '<>%1', 0);
                if SalesCrMemoLine.FindSet() then
                    repeat
                        Clear(EIRateTaxCode);
                        if not ((InvoiceRoundingAccount <> '') and (Round(Abs(SalesCrMemoLine.Amount), 0.01) = 0) and (SalesCrMemoLine.Type = "Sales Line Type"::"G/L Account") and (SalesCrMemoLine."No." = InvoiceRoundingAccount)) then begin
                            TaxAreaLine.Reset();
                            TaxAreaLine.SetRange("Tax Area", SalesCrMemoLine."Tax Area Code");
                            if TaxAreaLine.FindSet() then
                                repeat
                                    TaxDetail.Reset();
                                    TaxDetail.SetRange("Tax Jurisdiction Code", TaxAreaLine."Tax Jurisdiction Code");
                                    TaxDetail.SetRange("Tax Group Code", SalesCrMemoLine."Tax Group Code");
                                    TaxDetail.SetFilter("Effective Date", '<=%1', SalesCrMemoLine."Posting Date");
                                    TaxDetail.SetRange("Tax Type", TaxDetail."Tax Type"::"Sales Tax");
                                    TaxDetail.SetRange("GMAS SRI Tax Type", "GMAS SRI Tax Type"::VAT);
                                    if TaxDetail.FindLast() then begin
                                        TaxDetail.TestField("GMAS EI Rate Tax Code");
                                        TaxJurisdiction.Get(TaxDetail."Tax Jurisdiction Code");
                                        EIRateTaxCode := TaxDetail."GMAS EI Rate Tax Code";
                                        break;
                                    end;
                                until TaxAreaLine.Next() = 0;

                            Description := SalesCrMemoLine.Description;
                            ReplaceSpecialChar(Description);
                            if Description = '' then
                                Description := SalesCrMemoLine."No.";

                            if (TempVATEntry."Internal Ref. No." = EIRateTaxCode) and (TempVATEntry."External Document No." = TaxJurisdiction."GMAS EI Tax Code") then begin
                                EIEXMLDocumentStructure.deleteAddDataLine();
                                ItemCode := SalesCrMemoLine."No.";

                                if SalesCrMemoLine.Type = "Sales Line Type"::Item then begin
                                    Item.Get(SalesCrMemoLine."No.");
                                    if Item.GTIN <> '' then
                                        ItemCode := Item.GTIN;
                                end;

                                CodigoAdicional := SalesCrMemoLine."No.";
                                if Item."Common Item No." <> '' then
                                    CodigoAdicional := Item."Common Item No.";

                                CommentCount := 0;

                                SalesCommentLine.Reset();
                                SalesCommentLine.SetRange("Document Type", SalesCommentLine."Document Type"::"Posted Credit Memo");
                                SalesCommentLine.SetRange("No.", SalesCrMemoHeader."No.");
                                SalesCommentLine.SetRange("Document Line No.", SalesCrMemoLine."Line No.");
                                SalesCommentLine.SetFilter(Comment, '<>%1', '');
                                if SalesCommentLine.FindSet() then
                                    repeat
                                        CommentCount += 1;
                                        EIEXMLDocumentStructure.setAdicionalDataLine('det_comment' + Format(CommentCount), SalesCommentLine.Comment);
                                    until SalesCommentLine.Next() = 0;

                                EIEXMLDocumentStructure.SetCodigoPrincipal(ItemCode);
                                EIEXMLDocumentStructure.SetCodigoInterno(SalesCrMemoLine."No.");
                                EIEXMLDocumentStructure.SetCodigoAdicional(CodigoAdicional);
                                EIEXMLDocumentStructure.SetLnItmSeq(Format(SalesCrMemoLine."Line No."));
                                EIEXMLDocumentStructure.SetDescripcion(Description);
                                EIEXMLDocumentStructure.SetCantidad(Format(SalesCrMemoLine.Quantity, 0, QuantityFormatLbl));
                                EIEXMLDocumentStructure.SetPrecioUnitario(Format(Abs(SalesCrMemoLine."Unit Price"), 0, UnitPriceFormatLbl));
                                EIEXMLDocumentStructure.SetDescuento(Format(SalesCrMemoLine."Line Discount Amount" + SalesCrMemoLine."Inv. Discount Amount", 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.SetPrecioTotalSinImpuesto(Format(SalesCrMemoLine.Amount, 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.SetCodigoImpItem(TaxJurisdiction."GMAS EI Tax Code");
                                EIEXMLDocumentStructure.SetCodigoPorcentajeItem(EIRateTaxCode);
                                EIEXMLDocumentStructure.SetTarifaImpItem(Format(TaxDetail."Tax Below Maximum", 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.SetBaseImponibleItem(Format(SalesCrMemoLine."VAT Base Amount", 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.SetValorImpItem(Format(SalesCrMemoLine."Amount Including VAT" - SalesCrMemoLine.Amount, 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.AddData();
                            end;
                        end;
                    until SalesCrMemoLine.Next() = 0;
            until TempVATEntry.Next() = 0;

        EIEXMLDocumentStructure.Run();
    end;

    /// <summary>
    /// DownloadSalesCreditMemoDocument.
    /// </summary>
    /// <param name="SalesCrMemoHeader">Record "Sales Cr.Memo Header".</param>
    procedure DownloadSalesCreditMemoDocument(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        GenerateSalesCreditMemoDocument(SalesCrMemoHeader).DownloadFileXml(SalesCrMemoHeader."No." + '.xml');
    end;

    /// <summary>
    /// StatusSalesCreditMemoDocument.
    /// </summary>
    /// <param name="SalesCrMemoHeader">VAR Record "Sales Cr.Memo Header".</param>
    procedure StatusSalesCreditMemoDocument(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        CompanyInformation: Record "Company Information";
        EIEWebServiceRequest: Codeunit "EIE Web Service Request";
        GMASEIElectronicDocStatus: Enum "GMAS EI Electronic Doc. Status";
        ResponseText: Text;
        Estado: Text;
        CodigoError: Text;
        DescripcionError: Text;
        NumeroAutorizacion: Text;
        ClaveAcceso: Text;
        FechaAutorizacionSRI: Text;
        JsonBody: JsonObject;
        ResponseJson: JsonObject;
        ResponseToken: JsonToken;
        AuthorizationDateTime: DateTime;
    begin
        CompanyInformation.Get();

        JsonBody.Add(TipoDocumentoTxt, SalesCrMemoHeader."GMAS SRI Document Type Code");
        JsonBody.Add(NumeroDocumentoTxt, SalesCrMemoHeader."No.");
        JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
        JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
        JsonBody.Add(IdTransaccionTxt, SalesCrMemoHeader."EIE Id. Transaction Api");

        if EIEWebServiceRequest.RequestWebService(JsonBody, CompanyInformation."EIE Consult API URL", CompanyInformation."EIE Token API", ResponseText) then begin
            ResponseJson.ReadFrom(ResponseText);
            if ResponseJson.Get('estado', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    Estado := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('codigoError', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    CodigoError := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('descripcionError', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    DescripcionError := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('numeroAutorizacion', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    NumeroAutorizacion := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('claveAcceso', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    ClaveAcceso := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('fechaAutorizacionSRI', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    FechaAutorizacionSRI := ResponseToken.AsValue().AsText();

            GMASEIElectronicDocStatus := GetElectronicStatus(Estado);

            if FechaAutorizacionSRI <> '' then
                if StrPos(FechaAutorizacionSRI, 'Z') = 0 then
                    Evaluate(AuthorizationDateTime, FechaAutorizacionSRI + 'Z')
                else
                    Evaluate(AuthorizationDateTime, FechaAutorizacionSRI);

            SalesCrMemoHeader."GMAS EI Electronic Doc. Status" := GMASEIElectronicDocStatus;
            SalesCrMemoHeader."GMAS EI Error Code" := CopyStr(CodigoError, 1, 10);
            SalesCrMemoHeader."GMAS SRI Authorization No." := CopyStr(NumeroAutorizacion, 1, 49);
            SalesCrMemoHeader."GMAS SRI Authorization Date" := AuthorizationDateTime;
            SalesCrMemoHeader.SetErrorDescription(DescripcionError);
            SalesCrMemoHeader.Modify();
        end;
    end;

    /// <summary>
    /// AuthorizeSalesShipmentDocument.
    /// </summary>
    /// <param name="SalesShipmentHeader">VAR Record "Sales Shipment Header".</param>
    procedure AuthorizeSalesShipmentDocument(var SalesShipmentHeader: Record "Sales Shipment Header")
    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        EIEWebServiceRequest: Codeunit "EIE Web Service Request";
        XmlDocText: Text;
        ResponseText: Text;
        Estado: Text;
        CodigoError: Text;
        DescripcionError: Text;
        GMASEIElectronicDocStatus: Enum "GMAS EI Electronic Doc. Status";
        IdentificadorTransaccion: Text[20];
        JsonBody: JsonObject;
        ResponseJson: JsonObject;
        ResponseToken: JsonToken;

    begin
        CompanyInformation.Get();

        XmlDoc := GenerateSalesShipmentDocument(SalesShipmentHeader).GetFileXmlDocument();
        XmlDoc.WriteTo(XmlDocText);

        if XmlDocText <> '' then begin
            Customer.Get(SalesShipmentHeader."Bill-to Customer No.");

            JsonBody.Add(NombreEmisorTxt, CompanyName);
            JsonBody.Add(NombreCompaniaTxt, CompanyName);
            JsonBody.Add(TipoDocumentoTxt, SalesShipmentHeader."GMAS SRI Document Type Code");
            JsonBody.Add(NumeroDocumentoTxt, SalesShipmentHeader."No.");
            JsonBody.Add(DocSustentoTxt, DelChr(SalesShipmentHeader."No.", '=', '-'));
            JsonBody.Add(IdReceptorTxt, Customer."VAT Registration No.");
            JsonBody.Add(FechaDocumentoTxt, Format(SalesShipmentHeader."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>'));
            JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
            JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
            JsonBody.Add(UsuarioTxt, UserId());
            JsonBody.Add(DataDocumentoTxt, XmlDocText);
            JsonBody.Add(IdTransaccionTxt, TransactionIdTxt);

            //Envia el documento al APi de facturación electrónica
            if EIEWebServiceRequest.RequestWebService(JsonBody, CompanyInformation."EIE Authorization API URL", CompanyInformation."EIE Token API", ResponseText) then begin
                ResponseJson.ReadFrom(ResponseText);
                if ResponseJson.Get('estado', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        Estado := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('codigoError', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        CodigoError := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('descripcionError', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        DescripcionError := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('identificadorTransaccion', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        IdentificadorTransaccion := CopyStr(ResponseToken.AsValue().AsText(), 1, 20);

                GMASEIElectronicDocStatus := GetElectronicStatus(Estado);

                SalesShipmentHeader."GMAS EI Electronic Doc. Status" := GMASEIElectronicDocStatus;
                SalesShipmentHeader."EIE Id. Transaction Api" := IdentificadorTransaccion;
                SalesShipmentHeader."GMAS EI Error Code" := CopyStr(CodigoError, 1, 10);
                SalesShipmentHeader.SetErrorDescription(DescripcionError);
                SalesShipmentHeader.Modify();

                if Estado = '01' then begin
                    Clear(JsonBody);
                    JsonBody.Add(TipoDocumentoTxt, SalesShipmentHeader."GMAS SRI Document Type Code");
                    JsonBody.Add(NumeroDocumentoTxt, SalesShipmentHeader."No.");
                    JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
                    JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
                    JsonBody.Add(IdTransaccionTxt, TransactionIdTxt);

                    Sleep(3000);

                    StatusSalesShipmenDocument(SalesShipmentHeader);
                end;
            end;
        end;
    end;

    local procedure GenerateSalesShipmentDocument(SalesShipmentHeader: Record "Sales Shipment Header") EIEXMLDocumentStructure: Codeunit "EIE XML Document Structure"
    var
        CompanyInformation: Record "Company Information";
        SalesShipmentLine: Record "Sales Shipment Line";
        Location: Record Location;
        ShippingAgent: Record "Shipping Agent";
        Customer: Record Customer;
        GMASSRITabla02: Record "GMAS SRI Tabla 02";
        GMASEITabla06: Record "GMAS EI Tabla 06";
        SalesCommentLine: Record "Sales Comment Line";
        Item: Record Item;
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        ItemTrackingDocManagement: Codeunit "Item Tracking Doc. Management";
        CompanyName: Text;
        CompanyAddress: Text;
        BilltoAddress: Text;
        ShipToAdreess: Text;
        ResponsibilityCenterAddress: Text;
        Description: Text;
        ShippingAgentName: Text;
        CustomerName: Text;
        TagAdd: List of [Text];
        TagName: Text;
        TagValue: Text;
        CodigoAdicional: Code[20];
        SerialNo: Text;
        CompanyType: Text;
    begin
        TransactionIdTxt := Format(CurrentDateTime(), 0, TransactionFormatLbl);
        TransactionDateTimeTxt := Format(SalesShipmentHeader.SystemCreatedAt, 0, TransactionDateFormatLbl);
        PostingDateTxt := Format(SalesShipmentHeader."Posting Date", 0, PostingDateFormatLbl);
        DueDateTxt := Format(SalesShipmentHeader."Due Date", 0, PostingDateFormatLbl);

        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
        Customer.Get(SalesShipmentHeader."Bill-to Customer No.");
        ResponsibilityCenter.Get(SalesShipmentHeader."Responsibility Center");
        if SalesShipmentHeader."Shipping Agent Code" <> '' then
            ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
        if SalesShipmentHeader."Currency Code" = '' then
            Currency.Get(GeneralLedgerSetup."LCY Code")
        else
            Currency.Get(SalesShipmentHeader."Currency Code");

        CompanyName := CompanyInformation.Name;
        ReplaceSpecialChar(CompanyName);

        CompanyAddress := CompanyInformation.Address;
        ReplaceSpecialChar(CompanyAddress);

        ShippingAgentName := ShippingAgent.Name;
        ReplaceSpecialChar(ShippingAgentName);

        if SalesShipmentHeader."Location Code" <> '' then begin
            Location.Get(SalesShipmentHeader."Location Code");
            BilltoAddress := Location.Address;
            ReplaceSpecialChar(BilltoAddress);
        end;

        if BilltoAddress = '' then begin
            BilltoAddress := CompanyInformation.Address;
            ReplaceSpecialChar(BilltoAddress);
        end;

        ShipToAdreess := SalesShipmentHeader."Ship-to Address";
        ReplaceSpecialChar(ShipToAdreess);

        ResponsibilityCenterAddress := ResponsibilityCenter.Address;
        ReplaceSpecialChar(ResponsibilityCenterAddress);

        CustomerName := Customer.Name;
        ReplaceSpecialChar(CustomerName);

        GMASSRITabla02.Get(ShippingAgent."GMAS SRI Carrier Comp. Id Type");
        GMASEITabla06.Reset();
        GMASEITabla06.SetRange("Identification Type", GMASSRITabla02."Identification Type");
        GMASEITabla06.FindFirst();

        Clear(CompanyType);

        if CompanyInformation."GMAS EI Foreign Trade" <> '' then
            CompanyType := 'EXPORTADORES HABITUALES DE BIENES RESOLUCIÓN No. ' + CompanyInformation."GMAS EI Foreign Trade";

        EIEXMLDocumentStructure.CreateNodeDocument('Guía Remisión');
        EIEXMLDocumentStructure.SetContribuyenteEspecial(CompanyInformation."GMAS SRI Special Contributor");
        EIEXMLDocumentStructure.SetObligadoContabilidad(GetBooleanValue(CompanyInformation."GMAS SRI Obligation Keep Acc."));
        EIEXMLDocumentStructure.SetRazonSocial(CompanyName);
        EIEXMLDocumentStructure.SetNombreComercial(CompanyInformation."GMAS SRI Commercial Name");
        EIEXMLDocumentStructure.SetRuc(CompanyInformation."VAT Registration No.");
        EIEXMLDocumentStructure.SetCodDoc(SalesShipmentHeader."GMAS SRI Document Type Code");
        EIEXMLDocumentStructure.SetEstab(SalesShipmentHeader."GMAS SRI Establishment Code");
        EIEXMLDocumentStructure.SetPtoEmi(SalesShipmentHeader."GMAS SRI Emission Point Code");
        EIEXMLDocumentStructure.SetSecuencial(CopyStr(DelChr(SalesShipmentHeader."No.", '=', '-'), 7, 9));
        EIEXMLDocumentStructure.SetDirMatriz(CompanyAddress);
        EIEXMLDocumentStructure.SetAgenteRetencion(CompanyInformation."GMAS SRI Withholding Agent");
        EIEXMLDocumentStructure.SetDirEstablecimiento(ResponsibilityCenterAddress);
        EIEXMLDocumentStructure.SetDirPartida(BilltoAddress);
        EIEXMLDocumentStructure.SetRazonSocialTransportista(ShippingAgentName);
        EIEXMLDocumentStructure.SetTipoIdentificacionTransportista(GMASEITabla06.Code);
        EIEXMLDocumentStructure.SetRucTransportista(ShippingAgent."GMAS SRI Carrier Comp. Id. No.");
        EIEXMLDocumentStructure.SetFechaIniTransporte(Format(SalesShipmentHeader."Shipment Date", 0, PostingDateFormatLbl));
        EIEXMLDocumentStructure.SetFechaFinTransporte(Format(SalesShipmentHeader."Shipment Date", 0, PostingDateFormatLbl));
        EIEXMLDocumentStructure.SetPlaca(SalesShipmentHeader."Shipping Agent Service Code");
        EIEXMLDocumentStructure.SetIdentificacionDestinatario(Customer."VAT Registration No.");
        EIEXMLDocumentStructure.SetRazonSocialDestinatario(CustomerName);
        EIEXMLDocumentStructure.SetDirDestinatario(ShipToAdreess);
        EIEXMLDocumentStructure.SetMotivoTraslado(SalesShipmentHeader."Shipment Method Code");
        EIEXMLDocumentStructure.SetIdConductor(SalesShipmentHeader."GMAS SRI Shipping Agent Id No.");
        EIEXMLDocumentStructure.SetNombreConductor(SalesShipmentHeader."GMAS SRI Shipping Agent Name");

        if CompanyType <> '' then
            EIEXMLDocumentStructure.setAdicionalData('_TipoEmpresa', CompanyType);

        SalesCommentLine.Reset();
        SalesCommentLine.SetRange("Document Type", SalesCommentLine."Document Type"::Shipment);
        SalesCommentLine.SetRange("No.", SalesShipmentHeader."No.");
        SalesCommentLine.setrange("Document Line No.", 0);
        if SalesCommentLine.FindSet() then
            repeat
                TagAdd := SalesCommentLine.Comment.Split(':');
                if TagAdd.Get(1, TagName) then;
                if TagAdd.Get(2, TagValue) then;
                ReplaceSpecialChar(TagName);
                ReplaceSpecialChar(TagValue);
                EIEXMLDocumentStructure.setAdicionalData(TagName.Trim(), TagValue.Trim());
            until SalesCommentLine.Next() = 0;

        SalesShipmentLine.SetCurrentKey("No.", "Posting Date");
        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
        SalesShipmentLine.SetFilter(Type, '<>%1', "Sales Line Type"::" ");
        SalesShipmentLine.SetFilter(Quantity, '<>%1', 0);
        if SalesShipmentLine.FindSet() then
            repeat
                EIEXMLDocumentStructure.deleteAddDataLine();
                Clear(SerialNo);
                TempItemLedgerEntry.Reset();
                TempItemLedgerEntry.DeleteAll();
                Item.Get(SalesShipmentLine."No.");
                Description := SalesShipmentLine.Description;
                ReplaceSpecialChar(Description);
                if Description = '' then
                    Description := SalesShipmentLine."No.";

                CodigoAdicional := SalesShipmentLine."No.";
                if Item."Common Item No." <> '' then
                    CodigoAdicional := Item."Common Item No.";

                EIEXMLDocumentStructure.SetCodigoInterno(SalesShipmentLine."No.");
                EIEXMLDocumentStructure.SetCodigoAdicional(CodigoAdicional);
                EIEXMLDocumentStructure.SetLnItmSeq(Format(SalesShipmentLine."Line No."));
                EIEXMLDocumentStructure.SetDescripcion(Description);
                EIEXMLDocumentStructure.SetCantidad(Format(SalesShipmentLine.Quantity, 0, QuantityFormatLbl));

                ItemTrackingDocManagement.RetrieveEntriesFromShptRcpt(TempItemLedgerEntry, DATABASE::"Sales Shipment Line", 0, SalesShipmentLine."Document No.", '', 0, SalesShipmentLine."Line No.");
                if TempItemLedgerEntry.FindSet() then
                    repeat
                        if TempItemLedgerEntry."Serial No." <> '' then
                            if SerialNo = '' then
                                SerialNo := TempItemLedgerEntry."Serial No."
                            else
                                SerialNo += ', ' + TempItemLedgerEntry."Serial No.";
                    until TempItemLedgerEntry.Next() = 0;

                if SerialNo <> '' then
                    EIEXMLDocumentStructure.setAdicionalDataLine('detAdicional_Serie', CopyStr(SerialNo, 1, 300));

                EIEXMLDocumentStructure.AddData();
            until SalesShipmentLine.Next() = 0;

        EIEXMLDocumentStructure.Run();
    end;

    /// <summary>
    /// DownloadSalesShipmenDocument.
    /// </summary>
    /// <param name="SalesShipmentHeader">Record "Sales Shipment Header".</param>
    procedure DownloadSalesShipmenDocument(SalesShipmentHeader: Record "Sales Shipment Header")
    var
    begin
        GenerateSalesShipmentDocument(SalesShipmentHeader).DownloadFileXml(SalesShipmentHeader."No." + '.xml');
    end;

    /// <summary>
    /// StatusSalesShipmenDocument.
    /// </summary>
    /// <param name="SalesShipmentHeader">VAR Record "Sales Shipment Header".</param>
    procedure StatusSalesShipmenDocument(var SalesShipmentHeader: Record "Sales Shipment Header")
    var
        CompanyInformation: Record "Company Information";
        EIEWebServiceRequest: Codeunit "EIE Web Service Request";
        GMASEIElectronicDocStatus: Enum "GMAS EI Electronic Doc. Status";
        ResponseText: Text;
        Estado: Text;
        CodigoError: Text;
        DescripcionError: Text;
        NumeroAutorizacion: Text;
        ClaveAcceso: Text;
        FechaAutorizacionSRI: Text;
        JsonBody: JsonObject;
        ResponseJson: JsonObject;
        ResponseToken: JsonToken;
        AuthorizationDateTime: DateTime;
    begin
        CompanyInformation.Get();

        JsonBody.Add(TipoDocumentoTxt, SalesShipmentHeader."GMAS SRI Document Type Code");
        JsonBody.Add(NumeroDocumentoTxt, SalesShipmentHeader."No.");
        JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
        JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
        JsonBody.Add(IdTransaccionTxt, SalesShipmentHeader."EIE Id. Transaction Api");

        if EIEWebServiceRequest.RequestWebService(JsonBody, CompanyInformation."EIE Consult API URL", CompanyInformation."EIE Token API", ResponseText) then begin
            ResponseJson.ReadFrom(ResponseText);
            if ResponseJson.Get('estado', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    Estado := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('codigoError', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    CodigoError := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('descripcionError', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    DescripcionError := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('numeroAutorizacion', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    NumeroAutorizacion := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('claveAcceso', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    ClaveAcceso := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('fechaAutorizacionSRI', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    FechaAutorizacionSRI := ResponseToken.AsValue().AsText();

            GMASEIElectronicDocStatus := GetElectronicStatus(Estado);

            if FechaAutorizacionSRI <> '' then
                if StrPos(FechaAutorizacionSRI, 'Z') = 0 then
                    Evaluate(AuthorizationDateTime, FechaAutorizacionSRI + 'Z')
                else
                    Evaluate(AuthorizationDateTime, FechaAutorizacionSRI);

            SalesShipmentHeader."GMAS EI Electronic Doc. Status" := GMASEIElectronicDocStatus;
            SalesShipmentHeader."GMAS EI Error Code" := CopyStr(CodigoError, 1, 10);
            SalesShipmentHeader."GMAS SRI Authorization No." := CopyStr(NumeroAutorizacion, 1, 49);
            SalesShipmentHeader."GMAS SRI Authorization Date" := AuthorizationDateTime;
            SalesShipmentHeader.SetErrorDescription(DescripcionError);
            SalesShipmentHeader.Modify();
        end;
    end;

    /// <summary>
    /// AuthorizeTransferShipmentDocument.
    /// </summary>
    /// <param name="TransferShipmentHeader">VAR Record "Transfer Shipment Header".</param>
    procedure AuthorizeTransferShipmentDocument(var TransferShipmentHeader: Record "Transfer Shipment Header")
    var
        CompanyInformation: Record "Company Information";
        EIEWebServiceRequest: Codeunit "EIE Web Service Request";
        GMASEIElectronicDocStatus: Enum "GMAS EI Electronic Doc. Status";
        IdentificadorTransaccion: Text[20];
        DescripcionError: Text;
        ResponseText: Text;
        CodigoError: Text;
        CompanyName: Text;
        XmlDocText: Text;
        Estado: Text;
        JsonBody: JsonObject;
        ResponseJson: JsonObject;
        ResponseToken: JsonToken;

    begin
        CompanyInformation.Get();

        XmlDoc := GenerateTransferShipmentDocument(TransferShipmentHeader).GetFileXmlDocument();
        XmlDoc.WriteTo(XmlDocText);

        if XmlDocText <> '' then begin
            CompanyName := CompanyName();
            ReplaceSpecialChar(CompanyName);

            JsonBody.Add(NombreEmisorTxt, CompanyName);
            JsonBody.Add(NombreCompaniaTxt, CompanyName);
            JsonBody.Add(TipoDocumentoTxt, TransferShipmentHeader."GMAS SRI Document Type Code");
            JsonBody.Add(NumeroDocumentoTxt, TransferShipmentHeader."No.");
            JsonBody.Add(DocSustentoTxt, DelChr(TransferShipmentHeader."No.", '=', '-'));
            JsonBody.Add(IdReceptorTxt, CompanyInformation."VAT Registration No.");
            JsonBody.Add(FechaDocumentoTxt, Format(TransferShipmentHeader."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>'));
            JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
            JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
            JsonBody.Add(UsuarioTxt, UserId());
            JsonBody.Add(DataDocumentoTxt, XmlDocText);
            JsonBody.Add(IdTransaccionTxt, TransactionIdTxt);

            //Envia el documento al APi de facturación electrónica
            if EIEWebServiceRequest.RequestWebService(JsonBody, CompanyInformation."EIE Authorization API URL", CompanyInformation."EIE Token API", ResponseText) then begin
                ResponseJson.ReadFrom(ResponseText);
                if ResponseJson.Get('estado', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        Estado := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('codigoError', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        CodigoError := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('descripcionError', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        DescripcionError := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('identificadorTransaccion', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        IdentificadorTransaccion := CopyStr(ResponseToken.AsValue().AsText(), 1, 20);

                GMASEIElectronicDocStatus := GetElectronicStatus(Estado);

                TransferShipmentHeader."GMAS EI Electronic Doc. Status" := GMASEIElectronicDocStatus;
                TransferShipmentHeader."EIE Id. Transaction Api" := IdentificadorTransaccion;
                TransferShipmentHeader."GMAS EI Error Code" := CopyStr(CodigoError, 1, 10);
                TransferShipmentHeader.SetErrorDescription(DescripcionError);
                TransferShipmentHeader.Modify();

                if Estado = '01' then begin
                    Clear(JsonBody);
                    JsonBody.Add(TipoDocumentoTxt, TransferShipmentHeader."GMAS SRI Document Type Code");
                    JsonBody.Add(NumeroDocumentoTxt, TransferShipmentHeader."No.");
                    JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
                    JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
                    JsonBody.Add(IdTransaccionTxt, TransactionIdTxt);

                    StatusTransferShipmenDocument(TransferShipmentHeader);
                end;
            end;
        end;
    end;

    local procedure GenerateTransferShipmentDocument(TransferShipmentHeader: Record "Transfer Shipment Header") EIEXMLDocumentStructure: Codeunit "EIE XML Document Structure"
    var
        CompanyInformation: Record "Company Information";
        TransferShipmentLine: Record "Transfer Shipment Line";
        ShippingAgent: Record "Shipping Agent";
        GMASSRITabla02: Record "GMAS SRI Tabla 02";
        GMASEITabla06: Record "GMAS EI Tabla 06";
        InventoryCommentLine: Record "Inventory Comment Line";
        Item: Record Item;
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        ItemTrackingDocManagement: Codeunit "Item Tracking Doc. Management";
        ResponsibilityCenterAddress: Text;
        TransferFromAddress: Text;
        TransferToAddress: Text;
        CompanyAddress: Text;
        Description: Text;
        CompanyName: Text;
        ShippingAgentName: Text;
        TagAdd: List of [Text];
        TagName: Text;
        TagValue: Text;
        CodigoAdicional: Code[20];
        SerialNo: Text;
        CompanyType: Text;
    begin
        TransactionIdTxt := Format(CurrentDateTime(), 0, TransactionFormatLbl);
        TransactionDateTimeTxt := Format(TransferShipmentHeader.SystemCreatedAt, 0, TransactionDateFormatLbl);
        PostingDateTxt := Format(TransferShipmentHeader."Posting Date", 0, PostingDateFormatLbl);
        DueDateTxt := Format(TransferShipmentHeader."Shipment Date", 0, PostingDateFormatLbl);

        CompanyInformation.Get();
        GeneralLedgerSetup.Get();

        if TransferShipmentHeader."Shipping Agent Code" <> '' then
            ShippingAgent.Get(TransferShipmentHeader."Shipping Agent Code");

        TransferFromAddress := TransferShipmentHeader."Transfer-from Address";
        ReplaceSpecialChar(TransferFromAddress);

        TransferToAddress := TransferShipmentHeader."Transfer-to Address";
        ReplaceSpecialChar(TransferToAddress);

        CompanyName := CompanyInformation.Name;
        ReplaceSpecialChar(CompanyName);

        CompanyAddress := CompanyInformation.Address;
        ReplaceSpecialChar(CompanyAddress);

        ShippingAgentName := ShippingAgent.Name;
        ReplaceSpecialChar(ShippingAgentName);

        GMASSRITabla02.Get(ShippingAgent."GMAS SRI Carrier Comp. Id Type");
        GMASEITabla06.Reset();
        GMASEITabla06.SetRange("Identification Type", GMASSRITabla02."Identification Type");
        GMASEITabla06.FindFirst();

        Clear(CompanyType);

        if CompanyInformation."GMAS EI Foreign Trade" <> '' then
            CompanyType := 'EXPORTADORES HABITUALES DE BIENES RESOLUCIÓN No. ' + CompanyInformation."GMAS EI Foreign Trade";

        EIEXMLDocumentStructure.CreateNodeDocument('Guía Remisión');
        EIEXMLDocumentStructure.SetContribuyenteEspecial(CompanyInformation."GMAS SRI Special Contributor");
        EIEXMLDocumentStructure.SetObligadoContabilidad(GetBooleanValue(CompanyInformation."GMAS SRI Obligation Keep Acc."));
        EIEXMLDocumentStructure.SetRazonSocial(CompanyName);
        EIEXMLDocumentStructure.SetNombreComercial(CompanyInformation."GMAS SRI Commercial Name");
        EIEXMLDocumentStructure.SetRuc(CompanyInformation."VAT Registration No.");
        EIEXMLDocumentStructure.SetCodDoc(TransferShipmentHeader."GMAS SRI Document Type Code");
        EIEXMLDocumentStructure.SetEstab(TransferShipmentHeader."GMAS SRI Establishment Code");
        EIEXMLDocumentStructure.SetPtoEmi(TransferShipmentHeader."GMAS SRI Emission Point Code");
        EIEXMLDocumentStructure.SetSecuencial(CopyStr(DelChr(TransferShipmentHeader."No.", '=', '-'), 7, 9));
        EIEXMLDocumentStructure.SetDirMatriz(CompanyAddress);
        EIEXMLDocumentStructure.SetAgenteRetencion(CompanyInformation."GMAS SRI Withholding Agent");
        EIEXMLDocumentStructure.SetDirEstablecimiento(ResponsibilityCenterAddress);
        EIEXMLDocumentStructure.SetDirPartida(TransferFromAddress);
        EIEXMLDocumentStructure.SetRazonSocialTransportista(ShippingAgentName);
        EIEXMLDocumentStructure.SetTipoIdentificacionTransportista(GMASEITabla06.Code);
        EIEXMLDocumentStructure.SetRucTransportista(ShippingAgent."GMAS SRI Carrier Comp. Id. No.");
        EIEXMLDocumentStructure.SetFechaIniTransporte(Format(TransferShipmentHeader."Shipment Date", 0, PostingDateFormatLbl));
        EIEXMLDocumentStructure.SetFechaFinTransporte(Format(TransferShipmentHeader."Shipment Date", 0, PostingDateFormatLbl));
        EIEXMLDocumentStructure.SetPlaca(TransferShipmentHeader."Shipping Agent Service Code");
        EIEXMLDocumentStructure.SetIdentificacionDestinatario(CompanyInformation."VAT Registration No.");
        EIEXMLDocumentStructure.SetRazonSocialDestinatario(CompanyName);
        EIEXMLDocumentStructure.SetDirDestinatario(TransferToAddress);
        EIEXMLDocumentStructure.SetMotivoTraslado('VENTA');
        EIEXMLDocumentStructure.SetIdConductor(TransferShipmentHeader."GMAS SRI Shipping Agent Id No.");
        EIEXMLDocumentStructure.SetNombreConductor(TransferShipmentHeader."GMAS SRI Shipping Agent Name");

        if CompanyType <> '' then
            EIEXMLDocumentStructure.setAdicionalData('_TipoEmpresa', CompanyType);

        InventoryCommentLine.Reset();
        InventoryCommentLine.SetRange("Document Type", InventoryCommentLine."Document Type"::"Posted Transfer Shipment");
        InventoryCommentLine.SetRange("No.", TransferShipmentHeader."No.");
        if InventoryCommentLine.FindSet() then
            repeat
                TagAdd := InventoryCommentLine.Comment.Split(':');
                if TagAdd.Get(1, TagName) then;
                if TagAdd.Get(2, TagValue) then;
                ReplaceSpecialChar(TagName);
                ReplaceSpecialChar(TagValue);
                EIEXMLDocumentStructure.setAdicionalData(TagName.Trim(), TagValue.Trim());
            until InventoryCommentLine.Next() = 0;

        TransferShipmentLine.SetCurrentKey("Document No.", "Line No.");
        TransferShipmentLine.SetRange("Document No.", TransferShipmentHeader."No.");
        if TransferShipmentLine.FindSet() then
            repeat
                EIEXMLDocumentStructure.deleteAddDataLine();
                Item.Get(TransferShipmentLine."Item No.");
                Description := TransferShipmentLine.Description;
                ReplaceSpecialChar(Description);
                if Description = '' then
                    Description := TransferShipmentLine."Item No.";

                CodigoAdicional := TransferShipmentLine."Item No.";
                if Item."Common Item No." <> '' then
                    CodigoAdicional := Item."Common Item No.";

                EIEXMLDocumentStructure.SetCodigoInterno(TransferShipmentLine."Item No.");
                EIEXMLDocumentStructure.SetCodigoAdicional(CodigoAdicional);
                EIEXMLDocumentStructure.SetLnItmSeq(Format(TransferShipmentLine."Line No."));
                EIEXMLDocumentStructure.SetDescripcion(Description);
                EIEXMLDocumentStructure.SetCantidad(Format(TransferShipmentLine.Quantity, 0, QuantityFormatLbl));

                ItemTrackingDocManagement.RetrieveEntriesFromShptRcpt(TempItemLedgerEntry, DATABASE::"Transfer Shipment Line", 0, TransferShipmentLine."Document No.", '', 0, TransferShipmentLine."Line No.");
                if TempItemLedgerEntry.FindSet() then
                    repeat
                        if TempItemLedgerEntry."Serial No." <> '' then
                            if SerialNo = '' then
                                SerialNo := TempItemLedgerEntry."Serial No."
                            else
                                SerialNo += ', ' + TempItemLedgerEntry."Serial No.";
                    until TempItemLedgerEntry.Next() = 0;

                if SerialNo <> '' then
                    EIEXMLDocumentStructure.setAdicionalDataLine('detAdicional_Serie', CopyStr(SerialNo, 1, 300));

                EIEXMLDocumentStructure.AddData();
            until TransferShipmentLine.Next() = 0;

        EIEXMLDocumentStructure.Run();
    end;

    /// <summary>
    /// DownloadTransferShipmenDocument.
    /// </summary>
    /// <param name="TransferShipmentHeader">Record "Transfer Shipment Header".</param>
    procedure DownloadTransferShipmenDocument(TransferShipmentHeader: Record "Transfer Shipment Header")
    begin
        GenerateTransferShipmentDocument(TransferShipmentHeader).DownloadFileXml(TransferShipmentHeader."No." + 'xml');
    end;

    /// <summary>
    /// StatusTransferShipmenDocument.
    /// </summary>
    /// <param name="TransferShipmentHeader">Record "Transfer Shipment Header".</param>
    procedure StatusTransferShipmenDocument(var TransferShipmentHeader: Record "Transfer Shipment Header")
    var
        CompanyInformation: Record "Company Information";
        EIEWebServiceRequest: Codeunit "EIE Web Service Request";
        GMASEIElectronicDocStatus: Enum "GMAS EI Electronic Doc. Status";
        AuthorizationDateTime: DateTime;
        FechaAutorizacionSRI: Text;
        NumeroAutorizacion: Text;
        DescripcionError: Text;
        ResponseText: Text;
        ClaveAcceso: Text;
        CodigoError: Text;
        Estado: Text;
        JsonBody: JsonObject;
        ResponseJson: JsonObject;
        ResponseToken: JsonToken;

    begin
        CompanyInformation.Get();

        JsonBody.Add(TipoDocumentoTxt, TransferShipmentHeader."GMAS SRI Document Type Code");
        JsonBody.Add(NumeroDocumentoTxt, TransferShipmentHeader."No.");
        JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
        JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
        JsonBody.Add(IdTransaccionTxt, TransferShipmentHeader."EIE Id. Transaction Api");

        if EIEWebServiceRequest.RequestWebService(JsonBody, CompanyInformation."EIE Consult API URL", CompanyInformation."EIE Token API", ResponseText) then begin
            ResponseJson.ReadFrom(ResponseText);
            if ResponseJson.Get('estado', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    Estado := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('codigoError', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    CodigoError := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('descripcionError', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    DescripcionError := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('numeroAutorizacion', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    NumeroAutorizacion := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('claveAcceso', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    ClaveAcceso := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('fechaAutorizacionSRI', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    FechaAutorizacionSRI := ResponseToken.AsValue().AsText();

            GMASEIElectronicDocStatus := GetElectronicStatus(Estado);

            if FechaAutorizacionSRI <> '' then
                if StrPos(FechaAutorizacionSRI, 'Z') = 0 then
                    Evaluate(AuthorizationDateTime, FechaAutorizacionSRI + 'Z')
                else
                    Evaluate(AuthorizationDateTime, FechaAutorizacionSRI);

            TransferShipmentHeader."GMAS EI Electronic Doc. Status" := GMASEIElectronicDocStatus;
            TransferShipmentHeader."GMAS EI Error Code" := CopyStr(CodigoError, 1, 10);
            TransferShipmentHeader."GMAS SRI Authorization No." := CopyStr(NumeroAutorizacion, 1, 49);
            TransferShipmentHeader."GMAS SRI Authorization Date" := AuthorizationDateTime;
            TransferShipmentHeader.SetErrorDescription(DescripcionError);
            TransferShipmentHeader.Modify();
        end;
    end;

    /// <summary>
    /// AuthorizePurchInvoiceDocument.
    /// </summary>
    /// <param name="PurchInvHeader">VAR Record "Purch. Inv. Header".</param>
    procedure AuthorizePurchInvoiceDocument(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        CompanyInformation: Record "Company Information";
        Vendor: Record Vendor;
        EIEWebServiceRequest: Codeunit "EIE Web Service Request";
        GMASEIElectronicDocStatus: Enum "GMAS EI Electronic Doc. Status";
        IdentificadorTransaccion: Text[20];
        DescripcionError: Text;
        ResponseText: Text;
        CodigoError: Text;
        CompanyName: Text;
        XmlDocText: Text;
        Estado: Text;
        JsonBody: JsonObject;
        ResponseJson: JsonObject;
        ResponseToken: JsonToken;
    begin
        CompanyInformation.Get();

        XmlDoc := GeneratePurchInvoiceDocument(PurchInvHeader).GetFileXmlDocument();
        XmlDoc.WriteTo(XmlDocText);

        if XmlDocText <> '' then begin
            CompanyName := CompanyName();
            ReplaceSpecialChar(CompanyName);

            Vendor.Get(PurchInvHeader."Buy-from Vendor No.");

            JsonBody.Add(NombreEmisorTxt, CompanyName);
            JsonBody.Add(NombreCompaniaTxt, CompanyName);
            JsonBody.Add(TipoDocumentoTxt, PurchInvHeader."GMAS SRI Document Type Code");
            JsonBody.Add(NumeroDocumentoTxt, PurchInvHeader."Vendor Invoice No.");
            JsonBody.Add(DocSustentoTxt, DelChr(PurchInvHeader."Vendor Invoice No.", '=', '-'));
            JsonBody.Add(IdReceptorTxt, Vendor."VAT Registration No.");
            JsonBody.Add(FechaDocumentoTxt, Format(PurchInvHeader."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>'));
            JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
            JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
            JsonBody.Add(UsuarioTxt, UserId());
            JsonBody.Add(DataDocumentoTxt, XmlDocText);
            JsonBody.Add(IdTransaccionTxt, TransactionIdTxt);

            //Envia el documento al APi de facturación electrónica
            if EIEWebServiceRequest.RequestWebService(JsonBody, CompanyInformation."EIE Authorization API URL", CompanyInformation."EIE Token API", ResponseText) then begin
                ResponseJson.ReadFrom(ResponseText);
                if ResponseJson.Get('estado', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        Estado := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('codigoError', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        CodigoError := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('descripcionError', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        DescripcionError := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('identificadorTransaccion', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        IdentificadorTransaccion := CopyStr(ResponseToken.AsValue().AsText(), 1, 20);

                GMASEIElectronicDocStatus := GetElectronicStatus(Estado);

                PurchInvHeader."GMAS EI Electronic Doc. Status" := GMASEIElectronicDocStatus;
                PurchInvHeader."EIE Id. Transaction Api" := IdentificadorTransaccion;
                PurchInvHeader."GMAS EI Error Code" := CopyStr(CodigoError, 1, 10);
                PurchInvHeader.SetErrorDescription(DescripcionError);
                PurchInvHeader.Modify();

                if Estado = '01' then begin
                    Clear(JsonBody);
                    JsonBody.Add(TipoDocumentoTxt, PurchInvHeader."GMAS SRI Document Type Code");
                    JsonBody.Add(NumeroDocumentoTxt, PurchInvHeader."Vendor Invoice No.");
                    JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
                    JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
                    JsonBody.Add(IdTransaccionTxt, TransactionIdTxt);

                    StatusPurchInvoiceDocument(PurchInvHeader);
                end;
            end;
        end;
    end;

    local procedure GeneratePurchInvoiceDocument(PurchInvHeader: Record "Purch. Inv. Header") EIEXMLDocumentStructure: Codeunit "EIE XML Document Structure"
    var
        CompanyInformation: Record "Company Information";
        PurchInvLine: Record "Purch. Inv. Line";
        VendorPostingGroup: Record "Vendor Posting Group";
        Vendor: Record Vendor;
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        TaxJurisdiction: Record "Tax Jurisdiction";
        VATEntry: Record "VAT Entry";
        GMASSRIPurchInvReimbur: Record "GMAS SRI Purch. Inv. Reimbur.";
        GMASSRITabla02: Record "GMAS SRI Tabla 02";
        GMASEITabla06: Record "GMAS EI Tabla 06";
        Item: Record Item;
        PurchCommentLine: Record "Purch. Comment Line";
        EITabla17: Record "GMAS EI Tabla 17";
        FormatNumberToText: Codeunit "EIE Format Number To Text";
        CompanyName: Text;
        CompanyAddress: Text;
        BuyfromAddress: Text;
        ResponsibilityCenterAddress: Text;
        Description: Text;
        VATAmount: Decimal;
        VATBase: Decimal;
        TotalBaseImponibleReembolso: Decimal;
        TotalImpuestoReembolso: Decimal;
        EITaxCode: Code[10];
        EIRateTaxCode: Code[10];
        NoText: array[2] of Text[80];
        NumberToText: Text;
        InvoiceRoundingAccount: Code[20];
        ItemCode: Code[20];
        TagAdd: List of [Text];
        TagName: Text;
        TagValue: Text;
        TaxBelowMaximum: Decimal;
        CompanyType: Text;
    begin
        TransactionIdTxt := Format(CurrentDateTime(), 0, TransactionFormatLbl);
        TransactionDateTimeTxt := Format(PurchInvHeader.SystemCreatedAt, 0, TransactionDateFormatLbl);
        PostingDateTxt := Format(PurchInvHeader."Posting Date", 0, PostingDateFormatLbl);
        DueDateTxt := Format(PurchInvHeader."Due Date", 0, PostingDateFormatLbl);

        Clear(TotalImpuestoReembolso);
        Clear(TotalBaseImponibleReembolso);

        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
        Vendor.Get(PurchInvHeader."Buy-from Vendor No.");
        ResponsibilityCenter.Get(PurchInvHeader."Responsibility Center");
        PurchInvHeader.CalcFields(Amount, "Amount Including VAT");
        if PurchInvHeader."Currency Code" = '' then
            Currency.Get(GeneralLedgerSetup."LCY Code")
        else
            Currency.Get(PurchInvHeader."Currency Code");

        CompanyName := CompanyInformation.Name;
        ReplaceSpecialChar(CompanyName);

        CompanyAddress := CompanyInformation.Address;
        ReplaceSpecialChar(CompanyAddress);

        BuyfromAddress := PurchInvHeader."Buy-from Address";
        ReplaceSpecialChar(BuyfromAddress);

        ResponsibilityCenterAddress := ResponsibilityCenter.Address;
        ReplaceSpecialChar(ResponsibilityCenterAddress);

        GMASSRITabla02.Get(Vendor."GMAS SRI Ident. Type Code");
        GMASEITabla06.Reset();
        GMASEITabla06.SetRange("Identification Type", GMASSRITabla02."Identification Type");
        GMASEITabla06.FindFirst();

        if VendorPostingGroup.Get(Vendor."Vendor Posting Group") then
            InvoiceRoundingAccount := VendorPostingGroup."Invoice Rounding Account";

        Clear(VATAmount);
        Clear(VATBase);

        VATEntry.Reset();
        VATEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
        VATEntry.SetRange("Document No.", PurchInvHeader."No.");
        VATEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
        if VATEntry.FindSet() then
            repeat
                TaxJurisdiction.Get(VATEntry."Tax Jurisdiction Code");
                if TaxJurisdiction."GMAS SRI Tax Type" = "GMAS SRI Tax Type"::VAT then begin
                    VATAmount += VATEntry.Amount;
                    VATBase += VATEntry.Base;
                end;
            until VATEntry.Next() = 0;

        Clear(NoText);
        FormatNumberToText.InitTextVariable();
        FormatNumberToText.FormatNoText(NoText, Abs(PurchInvHeader.Amount + VATAmount), PurchInvHeader."Currency Code");
        NumberToText := NoText[1] + ' ' + NoText[2];

        GMASSRIPurchInvReimbur.Reset();
        GMASSRIPurchInvReimbur.SetRange("Document No.", PurchInvHeader."No.");
        if GMASSRIPurchInvReimbur.FindSet() then
            repeat
                //TotalComprobantesReembolso += GMASSRIPurchInvReimbur."SRI Total Amount Reimbursement";
                TotalBaseImponibleReembolso += GMASSRIPurchInvReimbur."SRI Taxable Base VAT Diff. 0" + GMASSRIPurchInvReimbur."SRI Taxable Base VAT 0";
                TotalImpuestoReembolso += GMASSRIPurchInvReimbur."SRI VAT Amount";
            until GMASSRIPurchInvReimbur.Next() = 0;

        Clear(CompanyType);

        if CompanyInformation."GMAS EI Foreign Trade" <> '' then
            CompanyType := 'EXPORTADORES HABITUALES DE BIENES RESOLUCIÓN No. ' + CompanyInformation."GMAS EI Foreign Trade";

        EIEXMLDocumentStructure.CreateNodeDocument('Liquidación de Compra');
        EIEXMLDocumentStructure.SetNombreEmisor(CompanyName);
        EIEXMLDocumentStructure.SetNombreCompania(CompanyName);
        EIEXMLDocumentStructure.SetNombreArchivo(DelChr(PurchInvHeader."Vendor Invoice No.", '=', '-') + '.txt');
        EIEXMLDocumentStructure.SetIdentificadorTransaccion(TransactionIdTxt);
        EIEXMLDocumentStructure.SetIdEmpresa(CompanyInformation."EIE Company Id");
        EIEXMLDocumentStructure.SetIdContrato(CompanyInformation."EIE Contract Id");
        EIEXMLDocumentStructure.SetCanal('ws');
        EIEXMLDocumentStructure.SetIpDevice(Database.TenantId());
        EIEXMLDocumentStructure.SetUsuario(UserId());
        EIEXMLDocumentStructure.SetFechaHoraTrx(TransactionDateTimeTxt);
        EIEXMLDocumentStructure.SetVersionDocumento('1.0.0.0');
        EIEXMLDocumentStructure.SetRazonSocial(CompanyName); // Preguntar
        EIEXMLDocumentStructure.SetNombreComercial(CompanyInformation."GMAS SRI Commercial Name"); // Preguntar
        EIEXMLDocumentStructure.SetRuc(CompanyInformation."VAT Registration No.");
        EIEXMLDocumentStructure.SetCodDoc(PurchInvHeader."GMAS SRI Document Type Code");
        EIEXMLDocumentStructure.SetEstab(PurchInvHeader."GMAS SRI Establishment Code");
        EIEXMLDocumentStructure.SetPtoEmi(PurchInvHeader."GMAS SRI Emission Point Code");
        EIEXMLDocumentStructure.SetSecuencial(CopyStr(DelChr(PurchInvHeader."Vendor Invoice No.", '=', '-'), 7, 9));
        EIEXMLDocumentStructure.SetDirMatriz(CompanyAddress);
        EIEXMLDocumentStructure.SetAgenteRetencion(CompanyInformation."GMAS SRI Withholding Agent");
        EIEXMLDocumentStructure.SetFechaEmision(PostingDateTxt);
        EIEXMLDocumentStructure.SetDirEstablecimiento(ResponsibilityCenterAddress);
        EIEXMLDocumentStructure.SetContribuyenteEspecial(CompanyInformation."GMAS SRI Special Contributor");
        EIEXMLDocumentStructure.SetObligadoContabilidad(GetBooleanValue(CompanyInformation."GMAS SRI Obligation Keep Acc."));
        EIEXMLDocumentStructure.SetTipoIdentificacionProveedor(GMASEITabla06.Code);
        EIEXMLDocumentStructure.SetRazonSocialProveedor(Vendor.Name);
        EIEXMLDocumentStructure.SetIdentificacionProveedor(Vendor."VAT Registration No.");
        EIEXMLDocumentStructure.SetDireccionProveedor(BuyfromAddress);
        EIEXMLDocumentStructure.SetTotalSinImpuestos(Format(Abs(PurchInvHeader.Amount), 0, AmountFormatLbl));
        EIEXMLDocumentStructure.SetTotalDescuento(Format(Abs(PurchInvHeader."Invoice Discount Amount"), 0, AmountFormatLbl));
        EIEXMLDocumentStructure.SetEmail(Vendor."E-Mail");

        if CompanyType <> '' then
            EIEXMLDocumentStructure.setAdicionalData('_TipoEmpresa', CompanyType);

        PurchCommentLine.Reset();
        PurchCommentLine.SetRange("Document Type", PurchCommentLine."Document Type"::"Posted Invoice");
        PurchCommentLine.SetRange("No.", PurchInvHeader."No.");
        if PurchCommentLine.FindSet() then
            repeat
                TagAdd := PurchCommentLine.Comment.Split(':');
                if TagAdd.Get(1, TagName) then;
                if TagAdd.Get(2, TagValue) then;
                ReplaceSpecialChar(TagName);
                ReplaceSpecialChar(TagValue);
                EIEXMLDocumentStructure.setAdicionalData(TagName.Trim(), TagValue.Trim());
            until PurchCommentLine.Next() = 0;

        GMASSRIPurchInvReimbur.Reset();
        GMASSRIPurchInvReimbur.SetRange("Document No.", PurchInvHeader."No.");
        if not GMASSRIPurchInvReimbur.IsEmpty then begin
            EIEXMLDocumentStructure.SetCodDocReembolso('41');
            EIEXMLDocumentStructure.SetTotalComprobantesReembolso(Format(Abs(TotalBaseImponibleReembolso + TotalImpuestoReembolso), 0, AmountFormatLbl));
            EIEXMLDocumentStructure.SetTotalBaseImponibleReembolso(Format(Abs(TotalBaseImponibleReembolso), 0, AmountFormatLbl));
            EIEXMLDocumentStructure.SetTotalImpuestoReembolso(Format(Abs(TotalImpuestoReembolso), 0, AmountFormatLbl));
        end;

        EIEXMLDocumentStructure.SetImporteTotal(Format(Abs(PurchInvHeader.Amount + VATAmount), 0, AmountFormatLbl));
        EIEXMLDocumentStructure.SetDescuentoAdicional(Format(0.00, 0, AmountFormatLbl));
        EIEXMLDocumentStructure.SetMoneda(Currency.Description);
        EIEXMLDocumentStructure.SetFormaPago('20');
        EIEXMLDocumentStructure.SetTotal(Format(Abs(PurchInvHeader.Amount + VATAmount), 0, AmountFormatLbl));
        EIEXMLDocumentStructure.SetMontoLetras(NumberToText);
        EIEXMLDocumentStructure.SetPlazo('0');
        EIEXMLDocumentStructure.SetUnidadTiempo('DIAS');

        PurchInvLine.Reset();
        PurchInvLine.SetCurrentKey("Document No.", "Line No.");
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        PurchInvLine.SetFilter(Type, '<>%1', PurchInvLine.Type::" ");
        PurchInvLine.SetFilter(Quantity, '<>%1', 0);
        if PurchInvLine.FindSet() then
            repeat
                if not ((InvoiceRoundingAccount <> '') and (Round(Abs(PurchInvLine.Amount), 0.01, '<') = 0) and (PurchInvLine.Type = "Purchase Line Type"::"G/L Account") and (PurchInvLine."No." = InvoiceRoundingAccount)) then begin
                    Clear(VATBase);
                    Clear(VATAmount);
                    Clear(EITaxCode);
                    Clear(EIRateTaxCode);

                    //Calculo de impuestos para la cabecera;
                    VATEntry.Reset();
                    VATEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
                    VATEntry.SetRange("Document No.", PurchInvHeader."No.");
                    VATEntry.SetRange("Tax Group Code", PurchInvLine."Tax Group Code");
                    VATEntry.SetRange("Tax Area Code", PurchInvLine."Tax Area Code");
                    VATEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
                    if VATEntry.FindSet() then
                        repeat
                            TaxDetail.Reset();
                            TaxDetail.SetRange("Tax Jurisdiction Code", VATEntry."Tax Jurisdiction Code");
                            TaxDetail.SetRange("Tax Group Code", VATEntry."Tax Group Code");
                            TaxDetail.SetFilter("Effective Date", '<=%1', VATEntry."Posting Date");
                            TaxDetail.SetRange("Tax Type", TaxDetail."Tax Type"::"Sales Tax");
                            TaxDetail.SetRange("GMAS SRI Tax Type", "GMAS SRI Tax Type"::VAT);
                            if TaxDetail.FindLast() then begin
                                TaxDetail.TestField("GMAS EI Rate Tax Code");
                                TaxJurisdiction.Get(VATEntry."Tax Jurisdiction Code");

                                EITaxCode := TaxJurisdiction."GMAS EI Tax Code";
                                EIRateTaxCode := TaxDetail."GMAS EI Rate Tax Code";
                                VATAmount += VATEntry.Amount;
                                VATBase += VATEntry.Base;
                                TaxBelowMaximum := TaxDetail."Tax Below Maximum";
                            end;
                        until VATEntry.Next() = 0;

                    EIEXMLDocumentStructure.SetCodigo(EITaxCode);
                    EIEXMLDocumentStructure.SetCodigoPorcentaje(EIRateTaxCode);
                    EIEXMLDocumentStructure.SetBaseImponible(Format(Abs(VATBase), 0, AmountFormatLbl));
                    EIEXMLDocumentStructure.SetTarifa(Format(TaxBelowMaximum, 0, AmountFormatLbl));
                    EIEXMLDocumentStructure.SetValor(Format(Abs(VATAmount), 0, AmountFormatLbl));

                    Clear(VATBase);
                    Clear(VATAmount);
                    Clear(EIRateTaxCode);

                    TaxAreaLine.Reset();
                    TaxAreaLine.SetRange("Tax Area", PurchInvLine."Tax Area Code");
                    if TaxAreaLine.FindSet() then
                        repeat
                            TaxDetail.Reset();
                            TaxDetail.SetRange("Tax Jurisdiction Code", TaxAreaLine."Tax Jurisdiction Code");
                            TaxDetail.SetRange("Tax Group Code", PurchInvLine."Tax Group Code");
                            TaxDetail.SetFilter("Effective Date", '<=%1', PurchInvLine."Posting Date");
                            TaxDetail.SetRange("Tax Type", TaxDetail."Tax Type"::"Sales Tax");
                            TaxDetail.SetRange("GMAS SRI Tax Type", "GMAS SRI Tax Type"::VAT);
                            if TaxDetail.FindLast() then begin
                                TaxDetail.TestField("GMAS EI Rate Tax Code");
                                TaxJurisdiction.Get(TaxDetail."Tax Jurisdiction Code");
                                EIRateTaxCode := TaxDetail."GMAS EI Rate Tax Code";

                                VATAmount := Round(PurchInvLine.Amount * TaxDetail."Tax Below Maximum" / 100);
                                VATBase := PurchInvLine.Amount;
                                break;
                            end;
                        until TaxAreaLine.Next() = 0;

                    Description := PurchInvLine.Description;
                    ReplaceSpecialChar(Description);
                    if Description = '' then
                        Description := PurchInvLine."No.";

                    ItemCode := PurchInvLine."No.";

                    if PurchInvLine.Type = "Purchase Line Type"::Item then begin
                        Item.Get(PurchInvLine."No.");
                        if Item.GTIN <> '' then
                            ItemCode := Item.GTIN;
                    end;

                    EIEXMLDocumentStructure.SetCodigoPrincipal(ItemCode);
                    EIEXMLDocumentStructure.SetCodigoAuxiliar(PurchInvLine."No.");
                    EIEXMLDocumentStructure.SetLnItmSeq(Format(PurchInvLine."Line No."));
                    EIEXMLDocumentStructure.SetDescripcion(Description);
                    EIEXMLDocumentStructure.SetUnidadTiempo('UNIDAD');
                    EIEXMLDocumentStructure.SetCantidad(Format(PurchInvLine.Quantity, 0, QuantityFormatLbl));
                    EIEXMLDocumentStructure.SetPrecioUnitario(Format(Abs(PurchInvLine."Unit Cost"), 0, UnitPriceFormatLbl));
                    EIEXMLDocumentStructure.SetDescuento(Format(Abs(PurchInvLine."Line Discount Amount"), 0, AmountFormatLbl));
                    EIEXMLDocumentStructure.SetPrecioTotalSinImpuesto(Format(Abs(PurchInvLine.Amount), 0, AmountFormatLbl));
                    EIEXMLDocumentStructure.SetCodigoImpItem(TaxJurisdiction."GMAS EI Tax Code");
                    EIEXMLDocumentStructure.SetCodigoPorcentajeItem(EIRateTaxCode);
                    EIEXMLDocumentStructure.SetTarifaImpItem(Format(TaxDetail."Tax Below Maximum", 0, AmountFormatLbl));
                    EIEXMLDocumentStructure.SetBaseImponibleItem(Format(Abs(VATBase), 0, AmountFormatLbl));
                    EIEXMLDocumentStructure.SetValorImpItem(Format(Abs(VATAmount), 0, AmountFormatLbl));

                    GMASSRIPurchInvReimbur.Reset();
                    GMASSRIPurchInvReimbur.SetRange("Document No.", PurchInvHeader."No.");
                    if GMASSRIPurchInvReimbur.FindSet() then
                        repeat
                            CountryRegion.Get(GMASSRIPurchInvReimbur."SRI Country/Region Code");

                            GMASSRITabla02.Get(GMASSRIPurchInvReimbur."SRI Identification Type Code");
                            GMASEITabla06.Reset();
                            GMASEITabla06.SetRange("Identification Type", GMASSRITabla02."Identification Type");
                            GMASEITabla06.FindFirst();

                            EIEXMLDocumentStructure.SetTipoIdentificacionProveedorReembolso(GMASEITabla06.Code);
                            EIEXMLDocumentStructure.SetIdentificacionProveedorReembolso(GMASSRIPurchInvReimbur."SRI Identification No.");
                            EIEXMLDocumentStructure.SetCodPaisPagoProveedorReembolso(CountryRegion."GMAS SRI Contry Code");
                            EIEXMLDocumentStructure.SetTipoProveedorReembolso(GMASSRIPurchInvReimbur."SRI Customer Type Code");
                            //EIEXMLDocumentStructure.SetCodDocReembolso(GMASSRIPurchInvReimbur."SRI Document Type Code");
                            EIEXMLDocumentStructure.SetEstabDocReembolso(CopyStr(GMASSRIPurchInvReimbur."SRI Reimbursement No.", 1, 3));
                            EIEXMLDocumentStructure.SetPtoEmiDocReembolso(CopyStr(GMASSRIPurchInvReimbur."SRI Reimbursement No.", 5, 3));
                            EIEXMLDocumentStructure.SetSecuencialDocReembolso(CopyStr(GMASSRIPurchInvReimbur."SRI Reimbursement No.", 9, 9));
                            EIEXMLDocumentStructure.SetFechaEmisionDocReembolso(Format(GMASSRIPurchInvReimbur."SRI Reimbursement Date", 0, PostingDateFormatLbl));
                            EIEXMLDocumentStructure.SetNumeroautorizacionDocReemb(GMASSRIPurchInvReimbur."SRI Authorization Number");

                            if GMASSRIPurchInvReimbur."SRI Taxable Base VAT Diff. 0" <> 0.00 then begin
                                EITabla17.Reset();
                                EITabla17.SetRange("VAT %", GMASSRIPurchInvReimbur."SRI VAT %");
                                if EITabla17.FindFirst() then;
                                EIEXMLDocumentStructure.SetCodigoImpReemb('2');
                                EIEXMLDocumentStructure.SetCodigoPorcentajeReemb(EITabla17.Code);
                                EIEXMLDocumentStructure.SetTarifaImpReemb(Format(GMASSRIPurchInvReimbur."SRI VAT %", 0, Amount0FormatLbl));
                                EIEXMLDocumentStructure.SetBaseImponibleReembolso(Format(GMASSRIPurchInvReimbur."SRI Taxable Base VAT Diff. 0", 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.SetImpuestoReembolso(Format(GMASSRIPurchInvReimbur."SRI VAT Amount", 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.AddData();
                            end;
                            if GMASSRIPurchInvReimbur."SRI Taxable Base VAT 0" <> 0.00 then begin
                                EIEXMLDocumentStructure.SetCodigoImpReemb('2');
                                EIEXMLDocumentStructure.SetCodigoPorcentajeReemb('0');
                                EIEXMLDocumentStructure.SetTarifaImpReemb('0');
                                EIEXMLDocumentStructure.SetBaseImponibleReembolso(Format(GMASSRIPurchInvReimbur."SRI Taxable Base VAT 0", 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.SetImpuestoReembolso('0.00');
                                EIEXMLDocumentStructure.AddData();
                            end;
                            if GMASSRIPurchInvReimbur."SRI Taxable Base Not Subj. VAT" <> 0.00 then begin
                                EIEXMLDocumentStructure.SetCodigoImpReemb('2');
                                EIEXMLDocumentStructure.SetCodigoPorcentajeReemb('6');
                                EIEXMLDocumentStructure.SetTarifaImpReemb('0');
                                EIEXMLDocumentStructure.SetBaseImponibleReembolso(Format(GMASSRIPurchInvReimbur."SRI Taxable Base Not Subj. VAT", 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.SetImpuestoReembolso('0.00');
                                EIEXMLDocumentStructure.AddData();
                            end;
                            if GMASSRIPurchInvReimbur."SRI Taxable Base Exempt VAT" <> 0.00 then begin
                                EIEXMLDocumentStructure.SetCodigoImpReemb('2');
                                EIEXMLDocumentStructure.SetCodigoPorcentajeReemb('7');
                                EIEXMLDocumentStructure.SetTarifaImpReemb('0');
                                EIEXMLDocumentStructure.SetBaseImponibleReembolso(Format(GMASSRIPurchInvReimbur."SRI Taxable Base Exempt VAT", 0, AmountFormatLbl));
                                EIEXMLDocumentStructure.SetImpuestoReembolso('0.00');
                                EIEXMLDocumentStructure.AddData();
                            end;
                        until GMASSRIPurchInvReimbur.Next() = 0;

                    GMASSRIPurchInvReimbur.Reset();
                    GMASSRIPurchInvReimbur.SetRange("Document No.", PurchInvHeader."No.");
                    if GMASSRIPurchInvReimbur.IsEmpty then
                        EIEXMLDocumentStructure.AddData();
                end;
            until PurchInvLine.Next() = 0;

        EIEXMLDocumentStructure.Run();
    end;

    /// <summary>
    /// DownloadPurchInvoiceDocument.
    /// </summary>
    /// <param name="PurchInvHeader">Record "Purch. Inv. Header".</param>
    procedure DownloadPurchInvoiceDocument(PurchInvHeader: Record "Purch. Inv. Header")
    begin
        GeneratePurchInvoiceDocument(PurchInvHeader).DownloadFileXml(PurchInvHeader."No." + '.xml');
    end;

    /// <summary>
    /// StatusPurchInvoiceDocument.
    /// </summary>
    /// <param name="PurchInvHeader">VAR Record "Purch. Inv. Header".</param>
    procedure StatusPurchInvoiceDocument(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        CompanyInformation: Record "Company Information";
        EIEWebServiceRequest: Codeunit "EIE Web Service Request";
        GMASEIElectronicDocStatus: Enum "GMAS EI Electronic Doc. Status";
        ResponseText: Text;
        Estado: Text;
        CodigoError: Text;
        DescripcionError: Text;
        NumeroAutorizacion: Text;
        ClaveAcceso: Text;
        FechaAutorizacionSRI: Text;
        JsonBody: JsonObject;
        ResponseJson: JsonObject;
        ResponseToken: JsonToken;
        AuthorizationDateTime: DateTime;
    begin
        CompanyInformation.Get();

        JsonBody.Add(TipoDocumentoTxt, PurchInvHeader."GMAS SRI Document Type Code");
        JsonBody.Add(NumeroDocumentoTxt, PurchInvHeader."Vendor Invoice No.");
        JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
        JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
        JsonBody.Add(IdTransaccionTxt, PurchInvHeader."EIE Id. Transaction Api");

        if EIEWebServiceRequest.RequestWebService(JsonBody, CompanyInformation."EIE Consult API URL", CompanyInformation."EIE Token API", ResponseText) then begin
            ResponseJson.ReadFrom(ResponseText);
            if ResponseJson.Get('estado', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    Estado := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('codigoError', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    CodigoError := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('descripcionError', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    DescripcionError := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('numeroAutorizacion', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    NumeroAutorizacion := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('claveAcceso', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    ClaveAcceso := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('fechaAutorizacionSRI', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    FechaAutorizacionSRI := ResponseToken.AsValue().AsText();

            GMASEIElectronicDocStatus := GetElectronicStatus(Estado);

            if FechaAutorizacionSRI <> '' then
                if StrPos(FechaAutorizacionSRI, 'Z') = 0 then
                    Evaluate(AuthorizationDateTime, FechaAutorizacionSRI + 'Z')
                else
                    Evaluate(AuthorizationDateTime, FechaAutorizacionSRI);

            PurchInvHeader."GMAS EI Electronic Doc. Status" := GMASEIElectronicDocStatus;
            PurchInvHeader."GMAS EI Error Code" := CopyStr(CodigoError, 1, 10);
            PurchInvHeader."GMAS SRI Authorization No." := CopyStr(NumeroAutorizacion, 1, 49);
            PurchInvHeader."GMAS SRI Authorization Date" := AuthorizationDateTime;
            PurchInvHeader.SetErrorDescription(DescripcionError);
            PurchInvHeader.Modify();
        end;
    end;

    /// <summary>
    /// AuthorizePurchWithholdingDocument.
    /// </summary>
    /// <param name="GMASSRIPurchWithhHeader">VAR Record "GMAS SRI Purch. Withh. Header".</param>
    procedure AuthorizePurchWithholdingDocument(var GMASSRIPurchWithhHeader: Record "GMAS SRI Purch. Withh. Header")
    var
        CompanyInformation: Record "Company Information";
        Vendor: Record Vendor;
        EIEWebServiceRequest: Codeunit "EIE Web Service Request";
        GMASEIElectronicDocStatus: Enum "GMAS EI Electronic Doc. Status";
        IdentificadorTransaccion: Text[20];
        DescripcionError: Text;
        ResponseText: Text;
        CodigoError: Text;
        XmlDocText: Text;
        Estado: Text;
        CompanyName: Text;
        JsonBody: JsonObject;
        ResponseJson: JsonObject;
        ResponseToken: JsonToken;
    begin
        CompanyInformation.Get();

        XmlDoc := GeneratePurchWithholdingDocument(GMASSRIPurchWithhHeader).GetFileXmlDocument();
        XmlDoc.WriteTo(XmlDocText);

        if XmlDocText <> '' then begin
            CompanyName := CompanyName();
            ReplaceSpecialChar(CompanyName);

            Vendor.Get(GMASSRIPurchWithhHeader."Buy-from Vendor No.");

            JsonBody.Add(NombreEmisorTxt, CompanyName);
            JsonBody.Add(NombreCompaniaTxt, CompanyName);
            JsonBody.Add(TipoDocumentoTxt, GMASSRIPurchWithhHeader."SRI Document Type Code");
            JsonBody.Add(NumeroDocumentoTxt, GMASSRIPurchWithhHeader."No.");
            JsonBody.Add(DocSustentoTxt, DelChr(GMASSRIPurchWithhHeader."No.", '=', '-'));
            JsonBody.Add(IdReceptorTxt, Vendor."VAT Registration No.");
            JsonBody.Add(FechaDocumentoTxt, Format(GMASSRIPurchWithhHeader."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>'));
            JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
            JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
            JsonBody.Add(UsuarioTxt, UserId());
            JsonBody.Add(DataDocumentoTxt, XmlDocText);
            JsonBody.Add(IdTransaccionTxt, TransactionIdTxt);

            //Envia el documento al APi de facturación electrónica
            if EIEWebServiceRequest.RequestWebService(JsonBody, CompanyInformation."EIE Authorization API URL", CompanyInformation."EIE Token API", ResponseText) then begin
                ResponseJson.ReadFrom(ResponseText);
                if ResponseJson.Get('estado', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        Estado := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('codigoError', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        CodigoError := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('descripcionError', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        DescripcionError := ResponseToken.AsValue().AsText();
                if ResponseJson.Get('identificadorTransaccion', ResponseToken) then
                    if not ResponseToken.AsValue().IsNull then
                        IdentificadorTransaccion := CopyStr(ResponseToken.AsValue().AsText(), 1, 20);

                GMASEIElectronicDocStatus := GetElectronicStatus(Estado);

                GMASSRIPurchWithhHeader."EI Electronic Doc. Status" := GMASEIElectronicDocStatus;
                GMASSRIPurchWithhHeader."EIE Id. Transaction Api" := IdentificadorTransaccion;
                GMASSRIPurchWithhHeader."EI Error Code" := CopyStr(CodigoError, 1, 10);
                GMASSRIPurchWithhHeader.SetErrorDescription(DescripcionError);
                GMASSRIPurchWithhHeader.Modify();

                if Estado = '01' then begin
                    Clear(JsonBody);
                    JsonBody.Add(TipoDocumentoTxt, GMASSRIPurchWithhHeader."SRI Document Type Code");
                    JsonBody.Add(NumeroDocumentoTxt, GMASSRIPurchWithhHeader."No.");
                    JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
                    JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
                    JsonBody.Add(IdTransaccionTxt, TransactionIdTxt);

                    Sleep(3000);
                    StatusPurchWithholdingDocument(GMASSRIPurchWithhHeader);
                end;
            end;
        end;
    end;

    local procedure GeneratePurchWithholdingDocument(GMASSRIPurchWithhHeader: Record "GMAS SRI Purch. Withh. Header") EIEXMLDocumentStructure: Codeunit "EIE XML Document Structure"
    var
        CompanyInformation: Record "Company Information";
        Vendor: Record Vendor;
        PurchInvHeader: Record "Purch. Inv. Header";
        GMASSRIPurchWithhLine: Record "GMAS SRI Purch. Withh. Line";
        TempGMASSRIPurchWithhLine: Record "GMAS SRI Purch. Withh. Line" temporary;
        GMASSRIPurchInvReimbur: Record "GMAS SRI Purch. Inv. Reimbur.";
        GMASSRITabla02: Record "GMAS SRI Tabla 02";
        GMASEITabla06: Record "GMAS EI Tabla 06";
        EITabla17: Record "GMAS EI Tabla 17";
        TaxJurisdiction: Record "Tax Jurisdiction";
        VATEntry: Record "VAT Entry";
        TempVATEntry: Record "VAT Entry" temporary;
        PaymentMethod: Record "Payment Method";
        TaxDetail: Record "Tax Detail";
        EITabla20: Record "GMAS EI Tabla 20";
        FormatNumberToText: Codeunit "EIE Format Number To Text";
        ResponsibilityCenterAddress: Text;
        CompanyAddress: Text;
        CompanyName: Text;
        VendorName: Text;
        NoText: array[2] of Text[80];
        NumberToText: Text;
        TotalBaseImponibleReembolso: Decimal;
        TotalImpuestoReembolso: Decimal;
        VATAmount: Decimal;
        VATPercent: Decimal;
        EIRateTaxCode: Code[10];
        EITaxCode: Code[10];
        PaymentMethodCode: Code[2];
        CompanyType: Text;
    begin
        TransactionIdTxt := Format(CurrentDateTime(), 0, TransactionFormatLbl);
        TransactionDateTimeTxt := Format(GMASSRIPurchWithhHeader.SystemCreatedAt, 0, TransactionDateFormatLbl);
        PostingDateTxt := Format(GMASSRIPurchWithhHeader."VAT Reporting Date", 0, PostingDateFormatLbl);

        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
        PurchInvHeader.Get(GMASSRIPurchWithhHeader."Document No.");
        PurchInvHeader.CalcFields(Amount, "Amount Including VAT");
        Vendor.Get(GMASSRIPurchWithhHeader."Buy-from Vendor No.");
        ResponsibilityCenter.Get(GMASSRIPurchWithhHeader."Responsibility Center");
        GMASSRIPurchWithhHeader.CalcFields("Tax Amount Total");

        Clear(NoText);
        FormatNumberToText.InitTextVariable();
        FormatNumberToText.FormatNoText(NoText, Round(GMASSRIPurchWithhHeader."Tax Amount Total", 0.01), PurchInvHeader."Currency Code");
        NumberToText := NoText[1] + ' ' + NoText[2];

        VendorName := Vendor.Name;
        ReplaceSpecialChar(VendorName);

        CompanyName := CompanyInformation.Name;
        ReplaceSpecialChar(CompanyName);

        CompanyAddress := CompanyInformation.Address;
        ReplaceSpecialChar(CompanyAddress);

        ResponsibilityCenterAddress := ResponsibilityCenter.Address;
        ReplaceSpecialChar(ResponsibilityCenterAddress);

        GMASSRITabla02.Get(Vendor."GMAS SRI Ident. Type Code");
        GMASEITabla06.Reset();
        GMASEITabla06.SetRange("Identification Type", GMASSRITabla02."Identification Type");
        GMASEITabla06.FindFirst();

        Clear(CompanyType);

        if CompanyInformation."GMAS EI Foreign Trade" <> '' then
            CompanyType := 'EXPORTADORES HABITUALES DE BIENES RESOLUCIÓN No. ' + CompanyInformation."GMAS EI Foreign Trade";

        EIEXMLDocumentStructure.CreateNodeDocument('Retencion');
        EIEXMLDocumentStructure.SetNombreEmisor(CompanyName);
        EIEXMLDocumentStructure.SetNombreCompania(CompanyName);
        EIEXMLDocumentStructure.SetNombreArchivo(DelChr(GMASSRIPurchWithhHeader."No.", '=', '-') + '.txt');
        EIEXMLDocumentStructure.SetIdentificadorTransaccion(TransactionIdTxt);
        EIEXMLDocumentStructure.SetIdEmpresa(CompanyInformation."EIE Company Id");
        EIEXMLDocumentStructure.SetIdContrato(CompanyInformation."EIE Contract Id");
        EIEXMLDocumentStructure.SetCanal('ws');
        EIEXMLDocumentStructure.SetIpDevice(Database.TenantId());
        EIEXMLDocumentStructure.SetUsuario(UserId());
        EIEXMLDocumentStructure.SetFechaHoraTrx(TransactionDateTimeTxt);
        EIEXMLDocumentStructure.SetVersionDocumento('2.0.0');
        EIEXMLDocumentStructure.SetRazonSocial(CompanyName);
        EIEXMLDocumentStructure.SetNombreComercial(CompanyInformation."GMAS SRI Commercial Name");
        EIEXMLDocumentStructure.SetRuc(CompanyInformation."VAT Registration No.");
        EIEXMLDocumentStructure.SetCodDoc(GMASSRIPurchWithhHeader."SRI Document Type Code");
        EIEXMLDocumentStructure.SetEstab(GMASSRIPurchWithhHeader."SRI Establishment Code");
        EIEXMLDocumentStructure.SetPtoEmi(GMASSRIPurchWithhHeader."SRI Emission Point Code");
        EIEXMLDocumentStructure.SetSecuencial(CopyStr(DelChr(GMASSRIPurchWithhHeader."No.", '=', '-'), 7, 9));
        EIEXMLDocumentStructure.SetDirMatriz(CompanyAddress);
        EIEXMLDocumentStructure.SetAgenteRetencion(CompanyInformation."GMAS SRI Withholding Agent");
        EIEXMLDocumentStructure.SetFechaEmision(PostingDateTxt);
        EIEXMLDocumentStructure.SetDirEstablecimiento(ResponsibilityCenterAddress);
        EIEXMLDocumentStructure.SetTipoIdentificacionSujetoRetenido(GMASEITabla06.Code);
        EIEXMLDocumentStructure.SetRazonSocialSujetoRetenido(VendorName);
        EIEXMLDocumentStructure.SetIdentificacionSujetoRetenido(Vendor."VAT Registration No.");
        //EIEXMLDocumentStructure.SetPeriodoFiscal(Format(GMASSRIPurchWithhHeader."Posting Date", 0, '<Month,2>/<Year4>'));
        EIEXMLDocumentStructure.SetPeriodoFiscal(Format(PurchInvHeader."Document Date", 0, '<Month,2>/<Year4>'));
        EIEXMLDocumentStructure.SetContribuyenteEspecial(CompanyInformation."GMAS SRI Special Contributor");
        EIEXMLDocumentStructure.SetObligadoContabilidad(GetBooleanValue(CompanyInformation."GMAS SRI Obligation Keep Acc."));
        EIEXMLDocumentStructure.SetMontoLetras(NumberToText);
        EIEXMLDocumentStructure.SetEmail(Vendor."E-Mail");
        EIEXMLDocumentStructure.SetTelefono(Vendor."Phone No.");
        EIEXMLDocumentStructure.SetCodDocSustento(PurchInvHeader."GMAS SRI Document Type Code");
        EIEXMLDocumentStructure.SetNumDocSustento(DelChr(PurchInvHeader."Vendor Invoice No.", '=', '-.'));
        EIEXMLDocumentStructure.SetFechaEmisionDocSustento(Format(PurchInvHeader."Document Date", 0, PostingDateFormatLbl));
        EIEXMLDocumentStructure.SetTotalRetenido(Format(GMASSRIPurchWithhHeader."Tax Amount Total", 0, AmountFormatLbl));
        EIEXMLDocumentStructure.SetConcepto('');

        if CompanyType <> '' then
            EIEXMLDocumentStructure.setAdicionalData('_TipoEmpresa', CompanyType);

        //Retencion 2.0.0

        if PurchInvHeader."Payment Method Code" <> '' then begin
            PaymentMethod.Get(PurchInvHeader."Payment Method Code");
            if PaymentMethod."GMAS SRI Payment Method Code" <> '' then
                PaymentMethodCode := PaymentMethod."GMAS SRI Payment Method Code";
        end;

        GMASSRIPurchInvReimbur.Reset();
        GMASSRIPurchInvReimbur.SetRange("Document No.", PurchInvHeader."No.");
        if GMASSRIPurchInvReimbur.FindSet() then
            repeat
                TotalBaseImponibleReembolso += GMASSRIPurchInvReimbur."SRI Taxable Base VAT Diff. 0" + GMASSRIPurchInvReimbur."SRI Taxable Base VAT 0";
                TotalImpuestoReembolso += GMASSRIPurchInvReimbur."SRI VAT Amount";
            until GMASSRIPurchInvReimbur.Next() = 0;

        EIEXMLDocumentStructure.SetCodSustento(PurchInvHeader."GMAS SRI Substan. Voucher Code");
        EIEXMLDocumentStructure.SetTipoSujetoRetenido(Vendor."GMAS SRI Vendor Type Code");
        EIEXMLDocumentStructure.SetParteRel(GetBooleanValue(Vendor."GMAS SRI Related Party"));
        EIEXMLDocumentStructure.SetFechaRegistroContable(Format(PurchInvHeader."Posting Date", 0, PostingDateFormatLbl));
        EIEXMLDocumentStructure.SetNumAutDocSustento(PurchInvHeader."GMAS SRI Authorization No.");
        EIEXMLDocumentStructure.SetPagoLocExt(PurchInvHeader."GMAS SRI Payment Type Code");
        EIEXMLDocumentStructure.SetTipoRegi(PurchInvHeader."GMAS SRI Regimen Type Code");


        if PurchInvHeader."GMAS SRI Payment Type Code" = '02' then begin
            if PurchInvHeader."GMAS SRI Regimen Type Code" = '01' then
                EIEXMLDocumentStructure.SetPaisEfecPago(PurchInvHeader."GMAS SRI General Regime");
            if PurchInvHeader."GMAS SRI Regimen Type Code" = '02' then
                EIEXMLDocumentStructure.SetPaisEfecPago(PurchInvHeader."GMAS SRI Tax Haven Code");
            if PurchInvHeader."GMAS SRI Regimen Type Code" = '03' then
                EIEXMLDocumentStructure.SetPaisEfecPago(PurchInvHeader."GMAS SRI General Regime");

            EIEXMLDocumentStructure.SetAplicConvDobTrib(GetBooleanValue(PurchInvHeader."GMAS SRI Double Taxation Agre."));
            if not PurchInvHeader."GMAS SRI Double Taxation Agre." then
                EIEXMLDocumentStructure.SetPagExtSujRetNorLeg(GetBooleanValue(PurchInvHeader."GMAS SRI Payment Subject With."));
            EIEXMLDocumentStructure.SetPagoRegFis('SI');
        end;

        GMASSRIPurchInvReimbur.Reset();
        GMASSRIPurchInvReimbur.SetRange("Document No.", PurchInvHeader."No.");
        if not GMASSRIPurchInvReimbur.IsEmpty then begin
            EIEXMLDocumentStructure.SetTotalComprobantesReembolso(Format(Abs(TotalBaseImponibleReembolso + TotalImpuestoReembolso), 0, AmountFormatLbl));
            EIEXMLDocumentStructure.SetTotalBaseImponibleReembolso(Format(Abs(TotalBaseImponibleReembolso), 0, AmountFormatLbl));
            EIEXMLDocumentStructure.SetTotalImpuestoReembolso(Format(Abs(TotalImpuestoReembolso), 0, AmountFormatLbl));
        end;

        VATEntry.Reset();
        VATEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
        VATEntry.SetRange("Document No.", PurchInvHeader."No.");
        VATEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
        //VATEntry.SetFilter(Amount, '<>%1', 0);
        if VATEntry.FindSet() then
            repeat
                TaxJurisdiction.Get(VATEntry."Tax Jurisdiction Code");
                if TaxJurisdiction."GMAS SRI Tax Type" = "GMAS SRI Tax Type"::VAT then begin

                    TaxDetail.Reset();
                    TaxDetail.SetRange("Tax Jurisdiction Code", VATEntry."Tax Jurisdiction Code");
                    TaxDetail.SetFilter("Tax Group Code", '%1', VATEntry."Tax Group Code");
                    TaxDetail.SetFilter("Effective Date", '<=%1', VATEntry."Posting Date");
                    TaxDetail.SetRange("Tax Type", VATEntry."Tax Type");
                    TaxDetail.SetRange("GMAS SRI Tax Type", "GMAS SRI Tax Type"::VAT);
                    if TaxDetail.FindLast() then begin
                        TaxDetail.TestField("GMAS EI Rate Tax Code");
                        TaxJurisdiction.Get(TaxDetail."Tax Jurisdiction Code");

                        VATPercent := TaxDetail."Tax Below Maximum";
                        EIRateTaxCode := TaxDetail."GMAS EI Rate Tax Code";
                        EITaxCode := TaxJurisdiction."GMAS EI Tax Code";
                    end;

                    TempVATEntry.Reset();
                    TempVATEntry.SetRange("External Document No.", EIRateTaxCode);
                    TempVATEntry.SetRange("Additional-Currency Amount", VATPercent);

                    if not TempVATEntry.FindFirst() then begin
                        TempVATEntry.Init();
                        TempVATEntry."Entry No." := VATEntry."Entry No.";
                        TempVATEntry.Amount := VATEntry.Amount;
                        TempVATEntry.Base := VATEntry.Base;
                        TempVATEntry."Additional-Currency Amount" := VATPercent;
                        TempVATEntry."External Document No." := EIRateTaxCode;
                        TempVATEntry.Insert();
                    end else begin
                        TempVATEntry.Amount += VATEntry.Amount;
                        TempVATEntry.Base += VATEntry.Base;
                        TempVATEntry.Modify();
                    end;

                    VATAmount += VATEntry.Amount;
                end;
            until VATEntry.Next() = 0;

        if TempVATEntry.IsEmpty then begin
            TempVATEntry."Entry No." := 1;
            TempVATEntry.Insert();
        end;


        EIEXMLDocumentStructure.SetTotalSinImpuestos(Format(Abs(PurchInvHeader.Amount), 0, AmountFormatLbl));
        EIEXMLDocumentStructure.SetImporteTotal(Format(Abs(PurchInvHeader.Amount + VATAmount), 0, AmountFormatLbl));
        //EIEXMLDocumentStructure.SetBaseImponible(Format(VATBase, 0, AmountFormatLbl));
        //EIEXMLDocumentStructure.SetCodigoPorcentaje(EIRateTaxCode);
        //EIEXMLDocumentStructure.setCodImpuestoDocSustento(EITaxCode);
        EIEXMLDocumentStructure.SetFormaPago(PaymentMethodCode);
        //EIEXMLDocumentStructure.SetTarifa(Format(VATPercent, 0, AmountFormatLbl));
        EIEXMLDocumentStructure.SetTotal(Format(Abs(PurchInvHeader.Amount + VATAmount), 0, AmountFormatLbl));
        //EIEXMLDocumentStructure.SetValorImpuesto(Format(VATAmount, 0, AmountFormatLbl));

        //Retencion 2.0.0 Cuendo CodSustento 10
        EIEXMLDocumentStructure.SetFechaPagoDiv('');
        EIEXMLDocumentStructure.SetImRentaSoc('');
        EIEXMLDocumentStructure.SetEjerFisUtDiv('');
        //compraCajBanano
        EIEXMLDocumentStructure.SetNumCajBan('');
        EIEXMLDocumentStructure.SetPrecCajBan('');

        GMASSRIPurchWithhLine.SetRange("Document No.", GMASSRIPurchWithhHeader."No.");
        if GMASSRIPurchWithhLine.FindSet() then
            repeat
                TempGMASSRIPurchWithhLine.Reset();
                TempGMASSRIPurchWithhLine.SetRange("Document No.", GMASSRIPurchWithhLine."Document No.");
                TempGMASSRIPurchWithhLine.SetRange("Tax Jurisdiction Code", GMASSRIPurchWithhLine."Tax Jurisdiction Code");
                TempGMASSRIPurchWithhLine.SetRange("Tax %", GMASSRIPurchWithhLine."Tax %");
                if TempGMASSRIPurchWithhLine.FindFirst() then begin
                    TempGMASSRIPurchWithhLine."Tax Amount" += GMASSRIPurchWithhLine."Tax Amount";
                    TempGMASSRIPurchWithhLine."Tax Base" += GMASSRIPurchWithhLine."Tax Base";
                    TempGMASSRIPurchWithhLine.Modify();
                end else begin
                    TempGMASSRIPurchWithhLine.Init();
                    TempGMASSRIPurchWithhLine.Copy(GMASSRIPurchWithhLine);
                    TempGMASSRIPurchWithhLine.Insert();
                end;
            until GMASSRIPurchWithhLine.Next() = 0;

        TempVATEntry.Reset();
        if TempVATEntry.FindSet() then
            repeat
                EIEXMLDocumentStructure.SetBaseImponible(Format(TempVATEntry.Base, 0, AmountFormatLbl));
                EIEXMLDocumentStructure.SetCodigoPorcentaje(TempVATEntry."External Document No.");
                EIEXMLDocumentStructure.SetTarifa(Format(TempVATEntry."Additional-Currency Amount", 0, AmountFormatLbl));
                EIEXMLDocumentStructure.setCodImpuestoDocSustento(EITaxCode);
                EIEXMLDocumentStructure.SetValorImpuesto(Format(TempVATEntry.Amount, 0, AmountFormatLbl));
                TempGMASSRIPurchWithhLine.Reset();
                if TempGMASSRIPurchWithhLine.FindSet() then
                    repeat
                        EIEXMLDocumentStructure.SetCodigo(TempGMASSRIPurchWithhLine."Tax Code");
                        EIEXMLDocumentStructure.SetCodigoRetencion(TempGMASSRIPurchWithhLine."Rate Tax Code");
                        EIEXMLDocumentStructure.SetBaseImponibleRet(Format(TempGMASSRIPurchWithhLine."Tax Base", 0, AmountFormatLbl));
                        EIEXMLDocumentStructure.SetPorcentajeRetener(Format(TempGMASSRIPurchWithhLine."Tax %", 0, AmountFormatLbl));
                        EIEXMLDocumentStructure.SetValorRetenido(Format(TempGMASSRIPurchWithhLine."Tax Amount", 0, AmountFormatLbl));

                        //Dividendos
                        EITabla20.Get(TempGMASSRIPurchWithhLine."Rate Tax Code");
                        if EITabla20."Dividend Information" then begin
                            EIEXMLDocumentStructure.SetFechaPagoDiv(Format(PurchInvHeader."GMAS SRI Dividend Payment Date", 0, PostingDateFormatLbl));
                            EIEXMLDocumentStructure.SetImRentaSoc(Format(PurchInvHeader."GMAS SRI IR Associatd Dividend", 0, AmountFormatLbl));
                            EIEXMLDocumentStructure.SetEjerFisUtDiv(Format(PurchInvHeader."GMAS SRI Year Dividend Gnrated"));
                        end;

                        //Rentencion 2.0.0 Comprobantes de reembolso
                        if PurchInvHeader."GMAS SRI Document Type Code" = '41' then begin
                            GMASSRIPurchInvReimbur.Reset();
                            GMASSRIPurchInvReimbur.SetRange("Document No.", PurchInvHeader."No.");
                            if GMASSRIPurchInvReimbur.FindSet() then
                                repeat
                                    CountryRegion.Get(GMASSRIPurchInvReimbur."SRI Country/Region Code");

                                    GMASSRITabla02.Get(GMASSRIPurchInvReimbur."SRI Identification Type Code");
                                    GMASEITabla06.Reset();
                                    GMASEITabla06.SetRange("Identification Type", GMASSRITabla02."Identification Type");
                                    GMASEITabla06.FindFirst();

                                    EIEXMLDocumentStructure.SetTipoIdentificacionProveedorReembolso(GMASEITabla06.Code);
                                    EIEXMLDocumentStructure.SetIdentificacionProveedorReembolso(GMASSRIPurchInvReimbur."SRI Identification No.");
                                    EIEXMLDocumentStructure.SetCodPaisPagoProveedorReembolso(CountryRegion."GMAS SRI Contry Code");
                                    EIEXMLDocumentStructure.SetTipoProveedorReembolso(GMASSRIPurchInvReimbur."SRI Customer Type Code");
                                    EIEXMLDocumentStructure.SetCodDocReembolso(GMASSRIPurchInvReimbur."SRI Document Type Code");
                                    EIEXMLDocumentStructure.SetEstabDocReembolso(CopyStr(GMASSRIPurchInvReimbur."SRI Reimbursement No.", 1, 3));
                                    EIEXMLDocumentStructure.SetPtoEmiDocReembolso(CopyStr(GMASSRIPurchInvReimbur."SRI Reimbursement No.", 5, 3));
                                    EIEXMLDocumentStructure.SetSecuencialDocReembolso(CopyStr(GMASSRIPurchInvReimbur."SRI Reimbursement No.", 9, 9));
                                    EIEXMLDocumentStructure.SetFechaEmisionDocReembolso(Format(GMASSRIPurchInvReimbur."SRI Reimbursement Date", 0, PostingDateFormatLbl));
                                    EIEXMLDocumentStructure.SetNumeroautorizacionDocReemb(GMASSRIPurchInvReimbur."SRI Authorization Number");

                                    //Impuestos Reembolso
                                    if GMASSRIPurchInvReimbur."SRI Taxable Base VAT Diff. 0" <> 0.00 then begin
                                        EITabla17.Reset();
                                        EITabla17.SetRange("VAT %", GMASSRIPurchInvReimbur."SRI VAT %");
                                        if EITabla17.FindFirst() then;
                                        EIEXMLDocumentStructure.SetCodigoImpReemb('2');
                                        EIEXMLDocumentStructure.SetCodigoPorcentajeReemb(EITabla17.Code);
                                        EIEXMLDocumentStructure.SetTarifaImpReemb(Format(GMASSRIPurchInvReimbur."SRI VAT %", 0, Amount0FormatLbl));
                                        EIEXMLDocumentStructure.SetBaseImponibleReembolso(Format(GMASSRIPurchInvReimbur."SRI Taxable Base VAT Diff. 0", 0, AmountFormatLbl));
                                        EIEXMLDocumentStructure.SetImpuestoReembolso(Format(GMASSRIPurchInvReimbur."SRI VAT Amount", 0, AmountFormatLbl));
                                        EIEXMLDocumentStructure.AddData();
                                    end;
                                    if GMASSRIPurchInvReimbur."SRI Taxable Base VAT 0" <> 0.00 then begin
                                        EIEXMLDocumentStructure.SetCodigoImpReemb('2');
                                        EIEXMLDocumentStructure.SetCodigoPorcentajeReemb('0');
                                        EIEXMLDocumentStructure.SetTarifaImpReemb('0');
                                        EIEXMLDocumentStructure.SetBaseImponibleReembolso(Format(GMASSRIPurchInvReimbur."SRI Taxable Base VAT 0", 0, AmountFormatLbl));
                                        EIEXMLDocumentStructure.SetImpuestoReembolso('0.00');
                                        EIEXMLDocumentStructure.AddData();
                                    end;
                                    if GMASSRIPurchInvReimbur."SRI Taxable Base Not Subj. VAT" <> 0.00 then begin
                                        EIEXMLDocumentStructure.SetCodigoImpReemb('2');
                                        EIEXMLDocumentStructure.SetCodigoPorcentajeReemb('6');
                                        EIEXMLDocumentStructure.SetTarifaImpReemb('0');
                                        EIEXMLDocumentStructure.SetBaseImponibleReembolso(Format(GMASSRIPurchInvReimbur."SRI Taxable Base Not Subj. VAT", 0, AmountFormatLbl));
                                        EIEXMLDocumentStructure.SetImpuestoReembolso('0.00');
                                        EIEXMLDocumentStructure.AddData();
                                    end;
                                    if GMASSRIPurchInvReimbur."SRI Taxable Base Exempt VAT" <> 0.00 then begin
                                        EIEXMLDocumentStructure.SetCodigoImpReemb('2');
                                        EIEXMLDocumentStructure.SetCodigoPorcentajeReemb('7');
                                        EIEXMLDocumentStructure.SetTarifaImpReemb('0');
                                        EIEXMLDocumentStructure.SetBaseImponibleReembolso(Format(GMASSRIPurchInvReimbur."SRI Taxable Base Exempt VAT", 0, AmountFormatLbl));
                                        EIEXMLDocumentStructure.SetImpuestoReembolso('0.00');
                                        EIEXMLDocumentStructure.AddData();
                                    end;
                                until GMASSRIPurchInvReimbur.Next() = 0;
                            //Fin Imp Reembolso
                            //fin
                            GMASSRIPurchInvReimbur.Reset();
                            GMASSRIPurchInvReimbur.SetRange("Document No.", PurchInvHeader."No.");
                            if GMASSRIPurchInvReimbur.IsEmpty then
                                EIEXMLDocumentStructure.AddData();
                        end else
                            EIEXMLDocumentStructure.AddData();
                    until TempGMASSRIPurchWithhLine.Next() = 0;
            until TempVATEntry.Next() = 0;

        EIEXMLDocumentStructure.Run();
    end;

    /// <summary>
    /// DownloadPurchWithholdingDocument.
    /// </summary>
    /// <param name="GMASSRIPurchWithhHeader">Record "GMAS SRI Purch. Withh. Header".</param>
    procedure DownloadPurchWithholdingDocument(GMASSRIPurchWithhHeader: Record "GMAS SRI Purch. Withh. Header")
    begin
        GeneratePurchWithholdingDocument(GMASSRIPurchWithhHeader).DownloadFileXml(GMASSRIPurchWithhHeader."No." + '.xml');
    end;

    /// <summary>
    /// StatusPurchWithholdingDocument.
    /// </summary>
    /// <param name="GMASSRIPurchWithhHeader">VAR Record "GMAS SRI Purch. Withh. Header".</param>
    procedure StatusPurchWithholdingDocument(var GMASSRIPurchWithhHeader: Record "GMAS SRI Purch. Withh. Header")
    var
        CompanyInformation: Record "Company Information";
        EIEWebServiceRequest: Codeunit "EIE Web Service Request";
        GMASEIElectronicDocStatus: Enum "GMAS EI Electronic Doc. Status";
        ResponseText: Text;
        Estado: Text;
        CodigoError: Text;
        DescripcionError: Text;
        NumeroAutorizacion: Text;
        ClaveAcceso: Text;
        FechaAutorizacionSRI: Text;
        JsonBody: JsonObject;
        ResponseJson: JsonObject;
        ResponseToken: JsonToken;
        AuthorizationDateTime: DateTime;
    begin
        CompanyInformation.Get();

        JsonBody.Add(TipoDocumentoTxt, GMASSRIPurchWithhHeader."SRI Document Type Code");
        JsonBody.Add(NumeroDocumentoTxt, GMASSRIPurchWithhHeader."No.");
        JsonBody.Add(EmpresaTxt, CompanyInformation."EIE Company Id");
        JsonBody.Add(ContratoTxt, CompanyInformation."EIE Contract Id");
        JsonBody.Add(IdTransaccionTxt, GMASSRIPurchWithhHeader."EIE Id. Transaction Api");

        if EIEWebServiceRequest.RequestWebService(JsonBody, CompanyInformation."EIE Consult API URL", CompanyInformation."EIE Token API", ResponseText) then begin
            ResponseJson.ReadFrom(ResponseText);
            if ResponseJson.Get('estado', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    Estado := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('codigoError', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    CodigoError := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('descripcionError', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    DescripcionError := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('numeroAutorizacion', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    NumeroAutorizacion := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('claveAcceso', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    ClaveAcceso := ResponseToken.AsValue().AsText();
            if ResponseJson.Get('fechaAutorizacionSRI', ResponseToken) then
                if not ResponseToken.AsValue().IsNull then
                    FechaAutorizacionSRI := ResponseToken.AsValue().AsText();

            GMASEIElectronicDocStatus := GetElectronicStatus(Estado);

            if FechaAutorizacionSRI <> '' then
                if StrPos(FechaAutorizacionSRI, 'Z') = 0 then
                    Evaluate(AuthorizationDateTime, FechaAutorizacionSRI + 'Z')
                else
                    Evaluate(AuthorizationDateTime, FechaAutorizacionSRI);

            GMASSRIPurchWithhHeader."EI Electronic Doc. Status" := GMASEIElectronicDocStatus;
            GMASSRIPurchWithhHeader."EI Error Code" := CopyStr(CodigoError, 1, 10);
            GMASSRIPurchWithhHeader."SRI Authorization No." := CopyStr(NumeroAutorizacion, 1, 49);
            GMASSRIPurchWithhHeader."SRI Authorization Date" := AuthorizationDateTime;
            GMASSRIPurchWithhHeader.SetErrorDescription(DescripcionError);
            GMASSRIPurchWithhHeader.Modify();
        end;
    end;

    local procedure GetBooleanValue(BooleaValue: Boolean): Code[2]
    begin
        if BooleaValue then
            exit('SI')
        else
            exit('NO');
    end;

    local procedure GetElectronicStatus(Estado: Text): Enum "GMAS EI Electronic Doc. Status"
    var
        GMASEIElectronicDocStatus: Enum "GMAS EI Electronic Doc. Status";
    begin
        case Estado of
            '00':
                GMASEIElectronicDocStatus := GMASEIElectronicDocStatus::" ";
            '01':
                GMASEIElectronicDocStatus := GMASEIElectronicDocStatus::Sent;
            '02':
                GMASEIElectronicDocStatus := GMASEIElectronicDocStatus::Received;
            '03':
                GMASEIElectronicDocStatus := GMASEIElectronicDocStatus::Error;
            '98':
                GMASEIElectronicDocStatus := GMASEIElectronicDocStatus::"Not Authorized";
            '99':
                GMASEIElectronicDocStatus := GMASEIElectronicDocStatus::Authorized;
        end;

        exit(GMASEIElectronicDocStatus);
    end;

    /// <summary>
    /// ReplaceSpecialChar.
    /// </summary>
    /// <param name="TextToConvert">VAR Text.</param>
    procedure ReplaceSpecialChar(var TextToConvert: Text)
    var

        CHARText: Text[3];
    begin
        CHARText[1] := 10;
        CHARText[2] := 11;
        CHARText[3] := 13;



        TextToConvert := TextToConvert.Replace('á', 'a');
        TextToConvert := TextToConvert.Replace('é', 'e');
        TextToConvert := TextToConvert.Replace('í', 'i');
        TextToConvert := TextToConvert.Replace('ó', 'o');
        TextToConvert := TextToConvert.Replace('ú', 'u');
        TextToConvert := TextToConvert.Replace('Á', 'A');
        TextToConvert := TextToConvert.Replace('É', 'E');
        TextToConvert := TextToConvert.Replace('Í', 'I');
        TextToConvert := TextToConvert.Replace('Ó', 'O');
        TextToConvert := TextToConvert.Replace('Ú', 'U');

        TextToConvert := TextToConvert.Replace('à', 'a');
        TextToConvert := TextToConvert.Replace('è', 'e');
        TextToConvert := TextToConvert.Replace('ì', 'i');
        TextToConvert := TextToConvert.Replace('ò', 'o');
        TextToConvert := TextToConvert.Replace('ù', 'u');
        TextToConvert := TextToConvert.Replace('À', 'A');
        TextToConvert := TextToConvert.Replace('È', 'E');
        TextToConvert := TextToConvert.Replace('Ì', 'I');
        TextToConvert := TextToConvert.Replace('Ò', 'O');
        TextToConvert := TextToConvert.Replace('Ù', 'U');

        TextToConvert := TextToConvert.Replace('ä', 'a');
        TextToConvert := TextToConvert.Replace('ë', 'e');
        TextToConvert := TextToConvert.Replace('ï', 'i');
        TextToConvert := TextToConvert.Replace('ö', 'o');
        TextToConvert := TextToConvert.Replace('ü', 'u');
        TextToConvert := TextToConvert.Replace('Ä', 'A');
        TextToConvert := TextToConvert.Replace('Ë', 'E');
        TextToConvert := TextToConvert.Replace('Ï', 'I');
        TextToConvert := TextToConvert.Replace('Ö', 'O');
        TextToConvert := TextToConvert.Replace('Ü', 'U');

        TextToConvert := TextToConvert.Replace('â', 'a');
        TextToConvert := TextToConvert.Replace('ê', 'e');
        TextToConvert := TextToConvert.Replace('î', 'i');
        TextToConvert := TextToConvert.Replace('ô', 'o');
        TextToConvert := TextToConvert.Replace('û', 'u');
        TextToConvert := TextToConvert.Replace('Â', 'A');
        TextToConvert := TextToConvert.Replace('Ê', 'E');
        TextToConvert := TextToConvert.Replace('Î', 'I');
        TextToConvert := TextToConvert.Replace('Ô', 'O');
        TextToConvert := TextToConvert.Replace('Û', 'U');

        TextToConvert := TextToConvert.Replace('ã', 'a');
        TextToConvert := TextToConvert.Replace('õ', 'o');
        TextToConvert := TextToConvert.Replace('Ã', 'A');
        TextToConvert := TextToConvert.Replace('Õ', 'O');

        TextToConvert := TextToConvert.Replace('å', 'a');
        TextToConvert := TextToConvert.Replace('Å', 'A');

        TextToConvert := TextToConvert.Replace('ñ', 'n');
        TextToConvert := TextToConvert.Replace('Ñ', 'N');
        TextToConvert := TextToConvert.Replace('š', 's');
        TextToConvert := TextToConvert.Replace('Š', 'S');
        TextToConvert := TextToConvert.Replace('ý', 'y');
        TextToConvert := TextToConvert.Replace('ÿ', 'y');
        TextToConvert := TextToConvert.Replace('Ý', 'Y');
        TextToConvert := TextToConvert.Replace('Ÿ', 'Y');
        TextToConvert := TextToConvert.Replace('ž', 'z');
        TextToConvert := TextToConvert.Replace('Ž', 'Z');

        TextToConvert := TextToConvert.Replace('º', 'o');
        TextToConvert := TextToConvert.Replace('°', 'o');
        TextToConvert := TextToConvert.Replace('ª', 'o');
        TextToConvert := TextToConvert.Replace('¢', 'C');
        TextToConvert := TextToConvert.Replace('¹', '2');
        TextToConvert := TextToConvert.Replace('²', '2');
        TextToConvert := TextToConvert.Replace('³', '3');
        TextToConvert := TextToConvert.Replace('…', '...');

        TextToConvert := TextToConvert.Replace(CHARText[1], '');
        TextToConvert := TextToConvert.Replace(CHARText[2], ' ');
        TextToConvert := TextToConvert.Replace(CHARText[3], ' ');

        TextToConvert := DelChr(TextToConvert, '=', '''');
        TextToConvert := DelChr(TextToConvert, '=', '£');
        TextToConvert := DelChr(TextToConvert, '=', 'ß');
        TextToConvert := DelChr(TextToConvert, '=', 'ð');
        TextToConvert := DelChr(TextToConvert, '=', '®');
        TextToConvert := DelChr(TextToConvert, '=', 'þ');
        TextToConvert := DelChr(TextToConvert, '=', '«');
        TextToConvert := DelChr(TextToConvert, '=', '»');
        TextToConvert := DelChr(TextToConvert, '=', '¬');
        TextToConvert := DelChr(TextToConvert, '=', '⌐');
        TextToConvert := DelChr(TextToConvert, '=', 'ø');
        TextToConvert := DelChr(TextToConvert, '=', '¶');
        TextToConvert := DelChr(TextToConvert, '=', '¥');
        TextToConvert := DelChr(TextToConvert, '=', '§');
        TextToConvert := DelChr(TextToConvert, '=', 'ƒ');
        TextToConvert := DelChr(TextToConvert, '=', '½');
        TextToConvert := DelChr(TextToConvert, '=', '¼');
        TextToConvert := DelChr(TextToConvert, '=', '¾');
        TextToConvert := DelChr(TextToConvert, '=', 'ⁿ');
        TextToConvert := DelChr(TextToConvert, '=', '€');
        TextToConvert := DelChr(TextToConvert, '=', 'æ');
        TextToConvert := DelChr(TextToConvert, '=', 'ç');
        TextToConvert := DelChr(TextToConvert, '=', 'µ');
        TextToConvert := DelChr(TextToConvert, '=', 'Š');
        TextToConvert := DelChr(TextToConvert, '=', '‰');
        TextToConvert := DelChr(TextToConvert, '=', 'œ');
        TextToConvert := DelChr(TextToConvert, '=', 'Œ');
        TextToConvert := DelChr(TextToConvert, '=', 'φ');
        TextToConvert := DelChr(TextToConvert, '=', 'ε');
        TextToConvert := DelChr(TextToConvert, '=', 'σ');
        TextToConvert := DelChr(TextToConvert, '=', 'π');
        TextToConvert := DelChr(TextToConvert, '=', '±');
        TextToConvert := DelChr(TextToConvert, '=', '®');
        TextToConvert := DelChr(TextToConvert, '=', '≈');
        TextToConvert := DelChr(TextToConvert, '=', '∙');
        TextToConvert := DelChr(TextToConvert, '=', '·');
        TextToConvert := DelChr(TextToConvert, '=', '©');
        TextToConvert := DelChr(TextToConvert, '=', '≥');
        TextToConvert := DelChr(TextToConvert, '=', '≤');
        TextToConvert := DelChr(TextToConvert, '=', '¨');
        TextToConvert := DelChr(TextToConvert, '=', '¤');
        TextToConvert := DelChr(TextToConvert, '=', '¦');
        TextToConvert := DelChr(TextToConvert, '=', '¸');
        TextToConvert := DelChr(TextToConvert, '=', '˜');
        TextToConvert := DelChr(TextToConvert, '=', 'ˆ');
        TextToConvert := DelChr(TextToConvert, '=', '“');
        TextToConvert := DelChr(TextToConvert, '=', '”');
        TextToConvert := DelChr(TextToConvert, '=', '„');
        TextToConvert := DelChr(TextToConvert, '=', '‘');
        TextToConvert := DelChr(TextToConvert, '=', '’');
        TextToConvert := DelChr(TextToConvert, '=', '‚');
        TextToConvert := DelChr(TextToConvert, '=', '†');
        TextToConvert := DelChr(TextToConvert, '=', '‡');
        TextToConvert := DelChr(TextToConvert, '=', '‹');
        TextToConvert := DelChr(TextToConvert, '=', '›');
        //TextToConvert := DelChr(TextToConvert, '=', '-');
        TextToConvert := DelChr(TextToConvert, '=', ',');
        TextToConvert := DelChr(TextToConvert, '=', '(');
        TextToConvert := DelChr(TextToConvert, '=', ')');
        //TextToConvert := DelChr(TextToConvert, '=', '&');
    end;
}