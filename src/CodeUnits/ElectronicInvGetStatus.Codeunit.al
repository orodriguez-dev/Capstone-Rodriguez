codeunit 70505 "EIE Electronic Inv. Get Status"
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        case Rec."Parameter String" of
            'Ventas':
                begin
                    SalesInvoiceDocuments();
                    SalesCrMemoDocuments();
                    SalesShipmentDocuments();
                    TransferShipmentDocuments();
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
        ElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        SalesInvoiceHeader.SetCurrentKey("No.", "Posting Date");
        SalesInvoiceHeader.SetFilter("GMAS EI Electronic Doc. Status", '%1|%2', "GMAS EI Electronic Doc. Status"::Sent, "GMAS EI Electronic Doc. Status"::Received);
        SalesInvoiceHeader.SetFilter("EIE Id. Transaction Api", '<>%1', '');
        if SalesInvoiceHeader.FindSet() then
            repeat
                ElectronicInvoicing.StatusSalesInvoiceDocument(SalesInvoiceHeader);
            until SalesInvoiceHeader.Next() = 0;
    end;

    local procedure SalesCrMemoDocuments()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        SalesCrMemoHeader.SetCurrentKey("No.", "Posting Date");
        SalesCrMemoHeader.SetFilter("GMAS EI Electronic Doc. Status", '%1|%2', "GMAS EI Electronic Doc. Status"::Sent, "GMAS EI Electronic Doc. Status"::Received);
        SalesCrMemoHeader.SetFilter("EIE Id. Transaction Api", '<>%1', '');
        if SalesCrMemoHeader.FindSet() then
            repeat
                ElectronicInvoicing.StatusSalesCreditMemoDocument(SalesCrMemoHeader);
            until SalesCrMemoHeader.Next() = 0;
    end;

    local procedure SalesShipmentDocuments()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        SalesShipmentHeader.SetCurrentKey("No.", "Posting Date");
        SalesShipmentHeader.SetFilter("GMAS EI Electronic Doc. Status", '%1|%2', "GMAS EI Electronic Doc. Status"::Sent, "GMAS EI Electronic Doc. Status"::Received);
        SalesShipmentHeader.SetFilter("EIE Id. Transaction Api", '<>%1', '');
        if SalesShipmentHeader.FindSet() then
            repeat
                ElectronicInvoicing.StatusSalesShipmenDocument(SalesShipmentHeader);
            until SalesShipmentHeader.Next() = 0;
    end;

    local procedure TransferShipmentDocuments()
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        ElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        TransferShipmentHeader.SetCurrentKey("No.", "Posting Date");
        TransferShipmentHeader.SetFilter("GMAS EI Electronic Doc. Status", '%1|%2', "GMAS EI Electronic Doc. Status"::Sent, "GMAS EI Electronic Doc. Status"::Received);
        TransferShipmentHeader.SetFilter("EIE Id. Transaction Api", '<>%1', '');
        if TransferShipmentHeader.FindSet() then
            repeat
                ElectronicInvoicing.StatusTransferShipmenDocument(TransferShipmentHeader);
            until TransferShipmentHeader.Next() = 0;
    end;

    local procedure PurchInvDocuments()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        ElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        PurchInvHeader.SetCurrentKey("No.", "Posting Date");
        PurchInvHeader.SetFilter("GMAS EI Electronic Doc. Status", '%1|%2', "GMAS EI Electronic Doc. Status"::Sent, "GMAS EI Electronic Doc. Status"::Received);
        PurchInvHeader.SetFilter("EIE Id. Transaction Api", '<>%1', '');
        if PurchInvHeader.FindSet() then
            repeat
                ElectronicInvoicing.StatusPurchInvoiceDocument(PurchInvHeader);
            until PurchInvHeader.Next() = 0;
    end;

    local procedure PurchWithhDocuments()
    var
        PurchWithhHeader: Record "GMAS SRI Purch. Withh. Header";
        ElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
    begin
        PurchWithhHeader.SetCurrentKey("No.", "Posting Date");
        PurchWithhHeader.SetFilter("EI Electronic Doc. Status", '%1|%2', "GMAS EI Electronic Doc. Status"::Sent, "GMAS EI Electronic Doc. Status"::Received);
        PurchWithhHeader.SetFilter("EIE Id. Transaction Api", '<>%1', '');
        if PurchWithhHeader.FindSet() then
            repeat
                ElectronicInvoicing.StatusPurchWithholdingDocument(PurchWithhHeader);
            until PurchWithhHeader.Next() = 0;
    end;
}