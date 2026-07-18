codeunit 70506 "EIE Electronic Inv. Send Doc."
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        case Rec."Parameter String" of
            'Ventas':
                begin
                    SalesInvoiceDocuments();
                    SalesCrMemoDocuments();
                    //SalesShipmentDocuments();
                    //TransferShipmentDocuments();
                end;
            'Compras':
                begin
                    PurchInvDocuments();
                    PurchWithhDocuments();
                end;
            else
                Error(ParameterErr);
        end;
    end;

    var
        ParameterErr: Label 'A parameter must be defined to select the module to be executed: "Ventas" or "Compras".';

    local procedure SalesInvoiceDocuments()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GMASSRITabla20: Record "GMAS SRI Tabla 20";
        GMASSRITabla02: Record "GMAS SRI Tabla 02";
        ElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        SalesInvoiceHeader.SetCurrentKey("No.", "Posting Date");
        SalesInvoiceHeader.SetRange("GMAS EI Electronic Doc. Status", "GMAS EI Electronic Doc. Status"::" ");
        SalesInvoiceHeader.SetFilter("GMAS SRI Document Type Code", '<>%1', '');
        if SalesInvoiceHeader.FindSet() then
            repeat
                Clear(ElectronicInvoicing);
                SalesInvoiceHeader.CalcFields("Amount Including VAT");
                GMASSRITabla20.Get(SalesInvoiceHeader."GMAS SRI Emission Type Code");
                if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then begin
                    GMASSRITabla02.Get(SalesInvoiceHeader."GMAS SRI Ident. Type Code");
                    if (GMASSRITabla02."EI Maximum Amount" = 0) or
                        ((SalesInvoiceHeader."Amount Including VAT" <= GMASSRITabla02."EI Maximum Amount") and (GMASSRITabla02."EI Maximum Amount" <> 0)) then
                        ElectronicInvoicing.AuthorizeSalesInvoiceDocument(SalesInvoiceHeader);
                end;
            until SalesInvoiceHeader.Next() = 0;
    end;

    local procedure SalesCrMemoDocuments()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        GMASSRITabla20: Record "GMAS SRI Tabla 20";
        ElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        SalesCrMemoHeader.SetCurrentKey("No.", "Posting Date");
        SalesCrMemoHeader.SetRange("GMAS EI Electronic Doc. Status", "GMAS EI Electronic Doc. Status"::" ");
        SalesCrMemoHeader.SetFilter("GMAS SRI Document Type Code", '<>%1', '');
        if SalesCrMemoHeader.FindSet() then
            repeat
                Clear(ElectronicInvoicing);
                GMASSRITabla20.Get(SalesCrMemoHeader."GMAS SRI Emission Type Code");
                if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then
                    ElectronicInvoicing.AuthorizeSalesCreditMemoDocument(SalesCrMemoHeader);
            until SalesCrMemoHeader.Next() = 0;
    end;

    /*local procedure SalesShipmentDocuments()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        GMASSRITabla20: Record "GMAS SRI Tabla 20";
        ElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        SalesShipmentHeader.SetCurrentKey("No.", "Posting Date");
        SalesShipmentHeader.SetRange("GMAS EI Electronic Doc. Status", "GMAS EI Electronic Doc. Status"::" ");
        SalesShipmentHeader.SetFilter("GMAS SRI Document Type Code", '<>%1', '');
        if SalesShipmentHeader.FindSet() then
            repeat
                Clear(ElectronicInvoicing);
                GMASSRITabla20.Get(SalesShipmentHeader."GMAS SRI Emission Type Code");
                if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then
                    ElectronicInvoicing.AuthorizeSalesShipmentDocument(SalesShipmentHeader);
            until SalesShipmentHeader.Next() = 0;
    end;*/

    /*local procedure TransferShipmentDocuments()
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        GMASSRITabla20: Record "GMAS SRI Tabla 20";
        ElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        TransferShipmentHeader.SetCurrentKey("No.", "Posting Date");
        TransferShipmentHeader.SetRange("GMAS EI Electronic Doc. Status", "GMAS EI Electronic Doc. Status"::" ");
        TransferShipmentHeader.SetFilter("GMAS SRI Document Type Code", '<>%1', '');
        if TransferShipmentHeader.FindSet() then
            repeat
                Clear(ElectronicInvoicing);
                GMASSRITabla20.Get(TransferShipmentHeader."GMAS SRI Emission Type Code");
                if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then
                    ElectronicInvoicing.AuthorizeTransferShipmentDocument(TransferShipmentHeader);
            until TransferShipmentHeader.Next() = 0;
    end;*/

    local procedure PurchInvDocuments()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        GMASSRITabla20: Record "GMAS SRI Tabla 20";
        ElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        PurchInvHeader.SetCurrentKey("No.", "Posting Date");
        PurchInvHeader.SetRange("GMAS EI Electronic Doc. Status", "GMAS EI Electronic Doc. Status"::" ");
        PurchInvHeader.SetFilter("GMAS SRI Document Type Code", '%1', '03');
        if PurchInvHeader.FindSet() then
            repeat
                Clear(ElectronicInvoicing);
                GMASSRITabla20.Get(PurchInvHeader."GMAS SRI Emission Type Code");
                if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then
                    ElectronicInvoicing.AuthorizePurchInvoiceDocument(PurchInvHeader);
            until PurchInvHeader.Next() = 0;
    end;

    local procedure PurchWithhDocuments()
    var
        PurchWithhHeader: Record "GMAS SRI Purch. Withh. Header";
        GMASSRITabla20: Record "GMAS SRI Tabla 20";
        ElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        PurchWithhHeader.SetCurrentKey("No.", "Posting Date");
        PurchWithhHeader.SetRange("EI Electronic Doc. Status", "GMAS EI Electronic Doc. Status"::" ");
        PurchWithhHeader.SetFilter("SRI Document Type Code", '<>%1', '');
        if PurchWithhHeader.FindSet() then
            repeat
                GMASSRITabla20.Get(PurchWithhHeader."SRI Emission Type Code");
                if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then
                    ElectronicInvoicing.AuthorizePurchWithholdingDocument(PurchWithhHeader);
            until PurchWithhHeader.Next() = 0;
    end;
}