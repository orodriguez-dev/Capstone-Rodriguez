namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;

/// <summary>
/// PageExtension EIE Posted Transfer Shipment (ID 70508) extends Record Posted Transfer Shipment.
/// </summary>
pageextension 70508 "EIE Posted Transfer Shipment" extends "Posted Transfer Shipment"
{
    layout
    {
        // Add changes to page layout here
        addlast("GMAS Electronic Invoicing")
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
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin
                        if not (Rec."GMAS EI Electronic Doc. Status" in [Rec."GMAS EI Electronic Doc. Status"::Received, Rec."GMAS EI Electronic Doc. Status"::Sent, Rec."GMAS EI Electronic Doc. Status"::Authorized])
                        and (Rec."GMAS SRI Document Type Code" <> '') then begin
                            EIEElectronicInvoicing.AuthorizeTransferShipmentDocument(Rec);
                            CurrPage.Update(false);
                        end;
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
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin
                        if (Rec."EIE Id. Transaction Api" <> '') and (Rec."GMAS EI Electronic Doc. Status" <> Rec."GMAS EI Electronic Doc. Status"::Authorized)
                        and (Rec."GMAS SRI Document Type Code" <> '') then begin
                            EIEElectronicInvoicing.StatusTransferShipmenDocument(Rec);
                            CurrPage.Update(false);
                        end;
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
    }

    var
}