namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;

/// <summary>
/// PageExtension EIE Posted Transfer Shipments (ID 70507) extends Record Posted Transfer Shipments.
/// </summary>
pageextension 70507 "EIE Posted Transfer Shipments" extends "Posted Transfer Shipments"
{
    layout
    {
        // Add changes to page layout here
        addafter("GMAS SRI Authorization No.")
        {

            field("EIE Id. Transaction Api"; Rec."EIE Id. Transaction Api")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Id. Transaction Api field.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter("&Shipment")
        {
            group("EIE Electronic Invoicing")
            {
                Image = ElectronicDoc;
                Caption = 'Electronic Invoicing';

                action("EIE Send Electronic Document")
                {
                    Caption = 'Send Electronic Document';
                    Image = SendTo;
                    ApplicationArea = All;
                    ToolTip = 'Send electronic document to the GRUPOMAS interface for authorization';

                    trigger OnAction()
                    var
                        TransferShipmentHeader: Record "Transfer Shipment Header";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin
                        CurrPage.SetSelectionFilter(TransferShipmentHeader);
                        TransferShipmentHeader.SetFilter("GMAS EI Electronic Doc. Status", '%1|%2|%3|%4', Rec."GMAS EI Electronic Doc. Status"::" ",
                                                                                                          Rec."GMAS EI Electronic Doc. Status"::Error,
                                                                                                          Rec."GMAS EI Electronic Doc. Status"::"Not Authorized",
                                                                                                          Rec."GMAS EI Electronic Doc. Status"::Returned);
                        TransferShipmentHeader.SetFilter("GMAS SRI Document Type Code", '<>%1', '');
                        if TransferShipmentHeader.FindSet() then
                            repeat
                                if (TransferShipmentHeader."GMAS EI Electronic Doc. Status" <> Rec."GMAS EI Electronic Doc. Status"::Received) and (TransferShipmentHeader."GMAS EI Electronic Doc. Status" <> Rec."GMAS EI Electronic Doc. Status"::Sent) then
                                    EIEElectronicInvoicing.AuthorizeTransferShipmentDocument(TransferShipmentHeader);
                            until TransferShipmentHeader.Next() = 0;
                        CurrPage.Update(false);
                    end;
                }

                action("EIE Get Status Electronic Document")
                {
                    Caption = 'Get Status Electronic Document';
                    Image = Status;
                    ApplicationArea = All;
                    ToolTip = 'Get status electronic document to the GRUPOMAS interface for authorization';

                    trigger OnAction()
                    var
                        TransferShipmentHeader: Record "Transfer Shipment Header";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin
                        CurrPage.SetSelectionFilter(TransferShipmentHeader);
                        //TransferShipmentHeader.SetFilter("GMAS EI Electronic Doc. Status", '<>%1', Rec."GMAS EI Electronic Doc. Status"::Authorized);
                        TransferShipmentHeader.SetFilter("EIE Id. Transaction Api", '<>%1', '');
                        TransferShipmentHeader.SetFilter("GMAS SRI Document Type Code", '<>%1', '');
                        if TransferShipmentHeader.FindSet() then
                            repeat
                                EIEElectronicInvoicing.StatusTransferShipmenDocument(TransferShipmentHeader);
                            until TransferShipmentHeader.Next() = 0;
                        CurrPage.Update(false);
                    end;
                }

                action("EIE Download Electronic Document")
                {
                    Caption = 'Download Electronic Document';
                    Image = Download;
                    ApplicationArea = All;
                    ToolTip = 'Download electronic document to the GRUPOMAS interface for authorization';

                    trigger OnAction()
                    var
                        ResponsibilityCenter: Record "Responsibility Center";
                        GMASSRITabla20: Record "GMAS SRI Tabla 20";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin
                        if Rec."GMAS SRI Document Type Code" <> '' then begin
                            ResponsibilityCenter.Get(Rec."GMAS SRI Responsibility Center");
                            GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                            if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then
                                EIEElectronicInvoicing.DownloadTransferShipmenDocument(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
        }

        addlast(Promoted)
        {
            group("EIE Electronic Invoicing_Ref")
            {
                Image = ElectronicDoc;
                Caption = 'Electronic Invoicing';
                actionref(SendElectronicDocument_Promoted; "EIE Send Electronic Document") { }
                actionref(GetStatusElectronicDocument_Promoted; "EIE Get Status Electronic Document") { }
                actionref(DownloadElectronicDocument_Promoted; "EIE Download Electronic Document") { }
            }

        }
    }

    var
}