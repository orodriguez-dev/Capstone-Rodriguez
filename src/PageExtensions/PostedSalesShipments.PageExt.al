namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Inventory.Location;
using Microsoft.Sales.History;

/// <summary>
/// PageExtension EIE Posted Sales Shipments (ID 70505) extends Record Posted Sales Shipments.
/// </summary>
pageextension 70505 "EIE Posted Sales Shipments" extends "Posted Sales Shipments"
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
                        SalesShipmentHeader: Record "Sales Shipment Header";
                        ResponsibilityCenter: Record "Responsibility Center";
                        GMASSRITabla20: Record "GMAS SRI Tabla 20";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin
                        CurrPage.SetSelectionFilter(SalesShipmentHeader);
                        SalesShipmentHeader.SetFilter("GMAS EI Electronic Doc. Status", '%1|%2|%3|%4', Rec."GMAS EI Electronic Doc. Status"::" ",
                                                                                                       Rec."GMAS EI Electronic Doc. Status"::Error,
                                                                                                       Rec."GMAS EI Electronic Doc. Status"::"Not Authorized",
                                                                                                       Rec."GMAS EI Electronic Doc. Status"::Returned);
                        SalesShipmentHeader.SetFilter("GMAS SRI Document Type Code", '<>%1', '');
                        if SalesShipmentHeader.FindSet() then
                            repeat
                                ResponsibilityCenter.Get(SalesShipmentHeader."Responsibility Center");
                                GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                                if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then
                                    if (SalesShipmentHeader."GMAS EI Electronic Doc. Status" <> Rec."GMAS EI Electronic Doc. Status"::Received) and (SalesShipmentHeader."GMAS EI Electronic Doc. Status" <> Rec."GMAS EI Electronic Doc. Status"::Sent) then
                                        EIEElectronicInvoicing.AuthorizeSalesShipmentDocument(SalesShipmentHeader);
                            until SalesShipmentHeader.Next() = 0;
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
                        SalesShipmentHeader: Record "Sales Shipment Header";
                        ResponsibilityCenter: Record "Responsibility Center";
                        GMASSRITabla20: Record "GMAS SRI Tabla 20";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin
                        CurrPage.SetSelectionFilter(SalesShipmentHeader);
                        //SalesShipmentHeader.SetFilter("GMAS EI Electronic Doc. Status", '<>%1', Rec."GMAS EI Electronic Doc. Status"::Authorized);
                        SalesShipmentHeader.SetFilter("EIE Id. Transaction Api", '<>%1', '');
                        SalesShipmentHeader.SetFilter("GMAS SRI Document Type Code", '<>%1', '');
                        if SalesShipmentHeader.FindSet() then
                            repeat
                                ResponsibilityCenter.Get(SalesShipmentHeader."Responsibility Center");
                                GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                                if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then
                                    EIEElectronicInvoicing.StatusSalesShipmenDocument(SalesShipmentHeader);
                            until SalesShipmentHeader.Next() = 0;
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
                            ResponsibilityCenter.Get(Rec."Responsibility Center");
                            GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                            if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then
                                EIEElectronicInvoicing.DownloadSalesShipmenDocument(Rec);
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