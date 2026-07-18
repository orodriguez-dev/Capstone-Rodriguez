/// <summary>
/// PageExtension EIE Posted Purchase Invoices (ID 70509) extends Record Posted Purchase Invoices.
/// </summary>
pageextension 70509 "EIE Posted Purchase Invoices" extends "Posted Purchase Invoices"
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
                        PurchInvHeader: Record "Purch. Inv. Header";
                        ResponsibilityCenter: Record "Responsibility Center";
                        GMASSRITabla20: Record "GMAS SRI Tabla 20";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin

                        CurrPage.SetSelectionFilter(PurchInvHeader);
                        PurchInvHeader.SetFilter("GMAS EI Electronic Doc. Status", '<>%1', Rec."GMAS EI Electronic Doc. Status"::Authorized);
                        PurchInvHeader.SetFilter("GMAS SRI Document Type Code", '%1', '03');
                        if PurchInvHeader.FindSet() then
                            repeat
                                ResponsibilityCenter.Get(PurchInvHeader."Responsibility Center");
                                GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                                if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then
                                    if (PurchInvHeader."GMAS EI Electronic Doc. Status" <> Rec."GMAS EI Electronic Doc. Status"::Received) and (PurchInvHeader."GMAS EI Electronic Doc. Status" <> Rec."GMAS EI Electronic Doc. Status"::Sent) then
                                        EIEElectronicInvoicing.AuthorizePurchInvoiceDocument(PurchInvHeader);
                            until PurchInvHeader.Next() = 0;
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
                        PurchInvHeader: Record "Purch. Inv. Header";
                        ResponsibilityCenter: Record "Responsibility Center";
                        GMASSRITabla20: Record "GMAS SRI Tabla 20";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin
                        CurrPage.SetSelectionFilter(PurchInvHeader);
                        PurchInvHeader.SetFilter("GMAS EI Electronic Doc. Status", '<>%1', Rec."GMAS EI Electronic Doc. Status"::Authorized);
                        PurchInvHeader.SetFilter("EIE Id. Transaction Api", '<>%1', '');
                        PurchInvHeader.SetFilter("GMAS SRI Document Type Code", '%1', '03');
                        if PurchInvHeader.FindSet() then
                            repeat
                                ResponsibilityCenter.Get(PurchInvHeader."Responsibility Center");
                                GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                                if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then
                                    EIEElectronicInvoicing.StatusPurchInvoiceDocument(PurchInvHeader);
                            until PurchInvHeader.Next() = 0;
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
                        if Rec."GMAS SRI Document Type Code" = '03' then begin
                            ResponsibilityCenter.Get(Rec."Responsibility Center");
                            GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                            if GMASSRITabla20."Emission Type" = "GMAS SRI Emission Type"::"Electronic Invoicing" then
                                EIEElectronicInvoicing.DownloadPurchInvoiceDocument(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
        }
    }

    var
}