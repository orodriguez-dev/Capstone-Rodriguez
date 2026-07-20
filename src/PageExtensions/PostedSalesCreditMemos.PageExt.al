namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Inventory.Location;
using Microsoft.Sales.History;

/// <summary>
/// PageExtension EIE Posted Sales Credit Memos (ID 70503) extends Record Posted Sales Credit Memos.
/// </summary>
pageextension 70503 "EIE Posted Sales Credit Memos" extends "Posted Sales Credit Memos"
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
        addafter("&Credit Memo")
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
                        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                        ResponsibilityCenter: Record "Responsibility Center";
                        GMASSRITabla20: Record "GMAS SRI Tabla 20";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin

                        CurrPage.SetSelectionFilter(SalesCrMemoHeader);
                        SalesCrMemoHeader.SetFilter("GMAS EI Electronic Doc. Status", '%1|%2|%3|%4', Rec."GMAS EI Electronic Doc. Status"::" ",
                                                                                                     Rec."GMAS EI Electronic Doc. Status"::Error,
                                                                                                     Rec."GMAS EI Electronic Doc. Status"::"Not Authorized",
                                                                                                     Rec."GMAS EI Electronic Doc. Status"::Returned);
                        SalesCrMemoHeader.SetFilter("GMAS SRI Document Type Code", '<>%1', '');
                        if SalesCrMemoHeader.FindSet() then
                            repeat
                                ResponsibilityCenter.Get(SalesCrMemoHeader."Responsibility Center");
                                GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                                if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then
                                    if (SalesCrMemoHeader."GMAS EI Electronic Doc. Status" <> Rec."GMAS EI Electronic Doc. Status"::Received) and (SalesCrMemoHeader."GMAS EI Electronic Doc. Status" <> Rec."GMAS EI Electronic Doc. Status"::Sent) then
                                        EIEElectronicInvoicing.AuthorizeSalesCreditMemoDocument(SalesCrMemoHeader);
                            until SalesCrMemoHeader.Next() = 0;
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
                        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                        ResponsibilityCenter: Record "Responsibility Center";
                        GMASSRITabla20: Record "GMAS SRI Tabla 20";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin

                        CurrPage.SetSelectionFilter(SalesCrMemoHeader);
                        //SalesCrMemoHeader.SetFilter("GMAS EI Electronic Doc. Status", '<>%1', Rec."GMAS EI Electronic Doc. Status"::Authorized);
                        SalesCrMemoHeader.SetFilter("EIE Id. Transaction Api", '<>%1', '');
                        SalesCrMemoHeader.SetFilter("GMAS SRI Document Type Code", '<>%1', '');
                        if SalesCrMemoHeader.FindSet() then
                            repeat
                                ResponsibilityCenter.Get(SalesCrMemoHeader."Responsibility Center");
                                GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                                if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then
                                    EIEElectronicInvoicing.StatusSalesCreditMemoDocument(SalesCrMemoHeader);
                            until SalesCrMemoHeader.Next() = 0;
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
                                EIEElectronicInvoicing.DownloadSalesCreditMemoDocument(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
        }
    }

    var
}