namespace GMAS.ELectronicInvoicing.Ecuador;
using System.Integration.Excel;

/// <summary>
/// Page EIE Electronic Trace Log (ID 70510).
/// Displays the traceability history of the electronic invoicing process.
/// Read-only page: does not allow manual insertion, editing, or deletion.
/// </summary>
page 70510 "EIE Electronic Trace Log"
{
    ApplicationArea = All;
    Caption = 'Electronic Invoicing Trace Log';
    PageType = List;
    SourceTable = "EIE Electronic Trace Log";
    UsageCategory = Administration;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTableView = sorting("Date Time") order(descending);

    layout
    {
        area(Content)
        {
            repeater(TraceLogLines)
            {
                field("Date Time"; Rec."Date Time")
                {
                    ApplicationArea = All;
                    StyleExpr = ReceivedStatusStyle;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Vendor Name"; Rec."Customer Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Action Type"; Rec."Action Type")
                {
                    ApplicationArea = All;
                }
                field("API Consumed"; Rec."API Consumed")
                {
                    ApplicationArea = All;
                }
                field("Received Status"; Rec."Received Status")
                {
                    ApplicationArea = All;
                    StyleExpr = ReceivedStatusStyle;
                }
                field("Response Message"; Rec."Response Message")
                {
                    ApplicationArea = All;
                }
                field("API Transaction ID"; Rec."API Transaction ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                Caption = 'Refresh';
                ApplicationArea = All;
                image = Refresh;
                ToolTip = 'Refreshes the trace log to display the most recent records.';
                trigger OnAction()
                begin
                    CurrPage.Update();
                end;
            }
        }
        area(Promoted)
        {
            actionref(Refresh_Promoted; Refresh) { }
        }
    }

    var
        ReceivedStatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        SetReceivedStatusStyle();
    end;

    /// <summary>
    /// Applies a color style to the "Received Status" column based on the received value.
    /// </summary>
    local procedure SetReceivedStatusStyle()
    begin
        case Rec."Received Status" of
            Rec."Received Status"::Authorized:
                ReceivedStatusStyle := 'Favorable';
            Rec."Received Status"::Received:
                ReceivedStatusStyle := 'StrongAccent';
            Rec."Received Status"::Sent:
                ReceivedStatusStyle := 'Ambiguous';
            Rec."Received Status"::Error,
            Rec."Received Status"::"Not Authorized":
                ReceivedStatusStyle := 'Unfavorable';
            else
                ReceivedStatusStyle := 'Standard';
        end;
    end;
}
