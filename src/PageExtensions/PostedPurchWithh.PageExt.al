namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Inventory.Location;

/// <summary>
/// PageExtension EIE Posted Purch. Withh. (ID 70511) extends Record GMAS SRI Posted Purch. Withh..
/// </summary>
pageextension 70511 "EIE Posted Purch. Withh." extends "GMAS SRI Posted Purch. Withh."
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
        addfirst(Processing)
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
                        if not (Rec."EI Electronic Doc. Status" in [Rec."EI Electronic Doc. Status"::Received, Rec."EI Electronic Doc. Status"::Sent, Rec."EI Electronic Doc. Status"::Authorized])
                            and (Rec."SRI Document Type Code" <> '') then begin
                            ResponsibilityCenter.Get(Rec."Responsibility Center");
                            GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                            if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then
                                EIEElectronicInvoicing.AuthorizePurchWithholdingDocument(Rec);
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
                        if (Rec."EIE Id. Transaction Api" <> '') and (Rec."EI Electronic Doc. Status" <> Rec."EI Electronic Doc. Status"::Authorized)
                            and (Rec."SRI Document Type Code" <> '') then begin
                            ResponsibilityCenter.Get(Rec."Responsibility Center");
                            GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                            if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then
                                EIEElectronicInvoicing.StatusPurchWithholdingDocument(Rec);
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
                        if Rec."SRI Document Type Code" <> '' then begin
                            ResponsibilityCenter.Get(Rec."Responsibility Center");
                            GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                            if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then
                                EIEElectronicInvoicing.DownloadPurchWithholdingDocument(Rec);
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