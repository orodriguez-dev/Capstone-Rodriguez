namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Inventory.Location;

/// <summary>
/// PageExtension EIE Posted Purch. Withhs. (ID 70512) extends Record GMAS SRI Posted Purch. Withhs..
/// </summary>
pageextension 70512 "EIE Posted Purch. Withhs." extends "GMAS SRI Posted Purch. Withhs."
{
    layout
    {
        // Add changes to page layout here
        addafter("SRI Authorization No.")
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
                        GMASSRIPurchWithhHeader: Record "GMAS SRI Purch. Withh. Header";
                        ResponsibilityCenter: Record "Responsibility Center";
                        GMASSRITabla20: Record "GMAS SRI Tabla 20";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin

                        CurrPage.SetSelectionFilter(GMASSRIPurchWithhHeader);
                        GMASSRIPurchWithhHeader.SetFilter("EI Electronic Doc. Status", '<>%1', Rec."EI Electronic Doc. Status"::Authorized);
                        GMASSRIPurchWithhHeader.SetFilter("SRI Document Type Code", '<>%1', '');
                        if GMASSRIPurchWithhHeader.FindSet() then
                            repeat
                                ResponsibilityCenter.Get(GMASSRIPurchWithhHeader."Responsibility Center");
                                GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                                if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then
                                    if (GMASSRIPurchWithhHeader."EI Electronic Doc. Status" <> Rec."EI Electronic Doc. Status"::Received) and (GMASSRIPurchWithhHeader."EI Electronic Doc. Status" <> Rec."EI Electronic Doc. Status"::Sent) then
                                        EIEElectronicInvoicing.AuthorizePurchWithholdingDocument(GMASSRIPurchWithhHeader);
                            until GMASSRIPurchWithhHeader.Next() = 0;
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
                        GMASSRIPurchWithhHeader: Record "GMAS SRI Purch. Withh. Header";
                        ResponsibilityCenter: Record "Responsibility Center";
                        GMASSRITabla20: Record "GMAS SRI Tabla 20";
                        EIEElectronicInvoicing: Codeunit "EIE Electronic Invoicing";
                    begin
                        CurrPage.SetSelectionFilter(GMASSRIPurchWithhHeader);
                        //GMASSRIPurchWithhHeader.SetFilter("EI Electronic Doc. Status", '<>%1', Rec."EI Electronic Doc. Status"::Authorized);
                        GMASSRIPurchWithhHeader.SetFilter("EIE Id. Transaction Api", '<>%1', '');
                        GMASSRIPurchWithhHeader.SetFilter("SRI Document Type Code", '<>%1', '');
                        if GMASSRIPurchWithhHeader.FindSet() then
                            repeat
                                ResponsibilityCenter.Get(GMASSRIPurchWithhHeader."Responsibility Center");
                                GMASSRITabla20.Get(ResponsibilityCenter."GMAS SRI Emission Type Code");
                                if GMASSRITabla20."Emission Type" = Enum::"GMAS SRI Emission Type"::"Electronic Invoicing" then
                                    EIEElectronicInvoicing.StatusPurchWithholdingDocument(GMASSRIPurchWithhHeader);
                            until GMASSRIPurchWithhHeader.Next() = 0;
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