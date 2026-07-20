namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Inventory.Location;
using Microsoft.Sales.History;

/// <summary>
/// PageExtension EIE Posted Sales Invoice (ID 70502) extends Record Posted Sales Invoice.
/// </summary>
pageextension 70502 "EIE Posted Sales Invoice" extends "Posted Sales Invoice"
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
        addafter("&Invoice")
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
                        GMASSRITabla02: Record "GMAS SRI Tabla 02";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin
                        if not (Rec."GMAS EI Electronic Doc. Status" in [Rec."GMAS EI Electronic Doc. Status"::Received, Rec."GMAS EI Electronic Doc. Status"::Sent, Rec."GMAS EI Electronic Doc. Status"::Authorized])
                            and (Rec."GMAS SRI Document Type Code" <> '') then begin
                            Rec.CalcFields("Amount Including VAT");
                            ResponsibilityCenter.Get(Rec."Responsibility Center");
                            GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                            if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then begin
                                GMASSRITabla02.Get(Rec."GMAS SRI Ident. Type Code");
                                if (GMASSRITabla02."EI Maximum Amount" = 0) or
                                    ((Rec."Amount Including VAT" <= GMASSRITabla02."EI Maximum Amount") and (GMASSRITabla02."EI Maximum Amount" <> 0)) then
                                    EIEElectronicInvoicing.AuthorizeSalesInvoiceDocument(Rec);
                                CurrPage.Update(false);
                            end;
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
                        if (Rec."EIE Id. Transaction Api" <> '')
                            and (Rec."GMAS EI Electronic Doc. Status" <> Rec."GMAS EI Electronic Doc. Status"::Authorized)
                            and (Rec."GMAS SRI Document Type Code" <> '') then begin
                            ResponsibilityCenter.Get(Rec."Responsibility Center");
                            GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                            if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then
                                EIEElectronicInvoicing.StatusSalesInvoiceDocument(Rec);
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
                            if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then
                                EIEElectronicInvoicing.DownloadSalesInvoiceDocument(Rec);
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