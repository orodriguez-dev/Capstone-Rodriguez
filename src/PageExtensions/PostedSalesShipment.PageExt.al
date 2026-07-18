/// <summary>
/// PageExtension EIE Posted Sales Shipment (ID 70506) extends Record Posted Sales Shipment.
/// </summary>
pageextension 70506 "EIE Posted Sales Shipment" extends "Posted Sales Shipment"
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
                        ResponsibilityCenter: Record "Responsibility Center";
                        GMASSRITabla20: Record "GMAS SRI Tabla 20";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin
                        if not (Rec."GMAS EI Electronic Doc. Status" in [Rec."GMAS EI Electronic Doc. Status"::Received, Rec."GMAS EI Electronic Doc. Status"::Sent, Rec."GMAS EI Electronic Doc. Status"::Authorized])
                            and (Rec."GMAS SRI Document Type Code" <> '') then begin
                            ResponsibilityCenter.Get(Rec."Responsibility Center");
                            GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                            if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then
                                EIEElectronicInvoicing.AuthorizeSalesShipmentDocument(Rec);
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
                        ResponsibilityCenter: Record "Responsibility Center";
                        GMASSRITabla20: Record "GMAS SRI Tabla 20";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin
                        if (Rec."EIE Id. Transaction Api" <> '') and (Rec."GMAS EI Electronic Doc. Status" <> Rec."GMAS EI Electronic Doc. Status"::Authorized)
                        and (Rec."GMAS SRI Document Type Code" <> '') then begin
                            ResponsibilityCenter.Get(Rec."Responsibility Center");
                            GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                            if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then
                                EIEElectronicInvoicing.StatusSalesShipmenDocument(Rec);
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
                            ResponsibilityCenter.Get(Rec."Responsibility Center");
                            GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                            if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then
                                EIEElectronicInvoicing.DownloadSalesShipmenDocument(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
        }
    }

    var
}