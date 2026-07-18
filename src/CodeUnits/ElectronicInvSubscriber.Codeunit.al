/// <summary>
/// Codeunit EIE Electronic Inv. Subscriber (ID 70503).
/// </summary>
codeunit 70503 "EIE Electronic Inv. Subscriber"
{
    #region EventSubscriber Codeunit Sales-Post. OnAfterPostSalesDoc
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean);
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        GMASSRITabla20: Record "GMAS SRI Tabla 20";
        GMASSRITabla04: Record "GMAS SRI Tabla 04";
        GMASSRITabla02: Record "GMAS SRI Tabla 02";
        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        if not PreviewMode then begin
            if (SalesInvHdrNo <> '') and (not WhseShip) then begin
                SalesInvoiceHeader.Get(SalesInvHdrNo);
                if SalesInvoiceHeader."GMAS SRI Document Type Code" <> '' then begin
                    GMASSRITabla04.Get(SalesInvoiceHeader."GMAS SRI Document Type Code");
                    if GMASSRITabla04."EIE Automatic Electronic Inv." and GMASSRITabla20.Get(SalesInvoiceHeader."GMAS SRI Emission Type Code") then
                        if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then begin
                            SalesInvoiceHeader.CalcFields("Amount Including VAT");
                            GMASSRITabla02.Get(SalesInvoiceHeader."GMAS SRI Ident. Type Code");
                            if (GMASSRITabla02."EI Maximum Amount" = 0) or
                                ((SalesInvoiceHeader."Amount Including VAT" <= GMASSRITabla02."EI Maximum Amount") and (GMASSRITabla02."EI Maximum Amount" <> 0)) then begin
                                EIEElectronicInvoicing.AuthorizeSalesInvoiceDocument(SalesInvoiceHeader);
                                Commit();
                            end
                        end;
                end;
            end;
            if SalesCrMemoHdrNo <> '' then begin
                SalesCrMemoHeader.Get(SalesCrMemoHdrNo);
                if SalesCrMemoHeader."GMAS SRI Document Type Code" <> '' then begin
                    GMASSRITabla04.Get(SalesCrMemoHeader."GMAS SRI Document Type Code");
                    if GMASSRITabla04."EIE Automatic Electronic Inv." and GMASSRITabla20.Get(SalesCrMemoHeader."GMAS SRI Emission Type Code") then
                        if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then begin
                            EIEElectronicInvoicing.AuthorizeSalesCreditMemoDocument(SalesCrMemoHeader);
                            Commit();
                        end;
                end;
            end;
            if (SalesShptHdrNo <> '') and WhseShip then begin
                SalesShipmentHeader.Get(SalesShptHdrNo);
                if SalesShipmentHeader."GMAS SRI Document Type Code" <> '' then begin
                    GMASSRITabla04.Get(SalesShipmentHeader."GMAS SRI Document Type Code");
                    if GMASSRITabla04."EIE Automatic Electronic Inv." and GMASSRITabla20.Get(SalesShipmentHeader."GMAS SRI Emission Type Code") then
                        if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then begin
                            EIEElectronicInvoicing.AuthorizeSalesShipmentDocument(SalesShipmentHeader);
                            Commit();
                        end;
                end;
            end;
        end;
    end;
    #endregion EventSubscriber Codeunit Sales-Post. OnAfterPostSalesDoc

    #region EventSubscriber Codeunit Purch.-Post. OnAfterPostPurchaseDoc
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]; CommitIsSupressed: Boolean)
    var
        //CompanyInformation: Record "Company Information";
        PurchInvHeader: Record "Purch. Inv. Header";
        GMASSRITabla20: Record "GMAS SRI Tabla 20";
        GMASSRITabla04: Record "GMAS SRI Tabla 04";
        GMASSRIPurchWithhHeader: Record "GMAS SRI Purch. Withh. Header";
        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        if PurchInvHdrNo <> '' then begin
            PurchInvHeader.Get(PurchInvHdrNo);
            if GMASSRIPurchWithhHeader.Get(PurchInvHeader."GMAS SRI Withholding No.") then begin
                GMASSRITabla04.Get(GMASSRIPurchWithhHeader."SRI Document Type Code");
                if GMASSRITabla04."EIE Automatic Electronic Inv." and GMASSRITabla20.Get(GMASSRIPurchWithhHeader."SRI Emission Type Code") then
                    if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then
                        EIEElectronicInvoicing.AuthorizePurchWithholdingDocument(GMASSRIPurchWithhHeader);
            end;

            if PurchInvHeader."GMAS SRI Document Type Code" = '03' then begin
                GMASSRITabla04.Get(PurchInvHeader."GMAS SRI Document Type Code");
                if GMASSRITabla04."EIE Automatic Electronic Inv." and GMASSRITabla20.Get(PurchInvHeader."GMAS SRI Emission Type Code") then
                    if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then
                        EIEElectronicInvoicing.AuthorizePurchInvoiceDocument(PurchInvHeader);
            end;
        end;
    end;
    #endregion EventSubscriber Codeunit Purch.-Post. OnAfterPostPurchaseDoc
}