namespace GMAS.ELectronicInvoicing.Ecuador;

using Microsoft.Finance.Currency;

/// <summary>
/// Codeunit EIE Format Number To Text (ID 70504).
/// </summary>
codeunit 70504 "EIE Format Number To Text"
{
    var
        OnesText: array[20] of Text[30];
        TensText: array[10] of Text[30];
        ExponentText: array[5] of Text[30];
        ExponentsText: array[5] of Text[30];
        ExponentHundredText: array[9] of Text[30];
        ZeroTxt: Label 'ZERO';
        HundredTxt: Label 'HUNDRED';
        AndTxt: Label 'AND';
        ResultsErr: Label '%1 results in a written number that is too long.', Comment = '%1 = Result';
        OneTxt: Label 'ONE';
        TwoTxt: Label 'TWO';
        ThreeTxt: Label 'THREE';
        FourTxt: Label 'FOUR';
        FiveTxt: Label 'FIVE';
        SixTxt: Label 'SIX';
        SevenTxt: Label 'SEVEN';
        EightTxt: Label 'EIGHT';
        NineTxt: Label 'NINE';
        TenTxt: Label 'TEN';
        ElevenTxt: Label 'ELEVEN';
        TwelveTxt: Label 'TWELVE';
        ThirteenTxt: Label 'THIRTEEN';
        FourteenTxt: Label 'FOURTEEN';
        FifteenTxt: Label 'FIFTEEN';
        SixteenTxt: Label 'SIXTEEN';
        SeventeenTxt: Label 'SEVENTEEN';
        EighteenTxt: Label 'EIGHTEEN';
        NineteenTxt: Label 'NINETEEN';
        TwentyTxt: Label 'TWENTY';
        ThirtyTxt: Label 'THIRTY';
        FortyTxt: Label 'FORTY';
        FiftyTxt: Label 'FIFTY';
        SixtyTxt: Label 'SIXTY';
        SeventyTxt: Label 'SEVENTY';
        EigntyTxt: Label 'EIGHTY';
        NinetyTxt: Label 'NINETY';
        ThousandTxt: Label 'THOUSAND';
        MillionTxt: Label 'MILLION';
        BillionTxt: Label 'BILLION';
        OneHundredTxt: Label 'ONE HUNDRED';
        TwoHundredTxt: Label 'TWO HUNDRED';
        ThreeHundredTxt: Label 'THREE HUNDRED';
        FourHundredTxt: Label 'FOUR HUNDRED';
        FiveHundredTxt: Label 'FIVE HUNDRED';
        SixHundredTxt: Label 'SIX HUNDRED';
        SevenHundredTxt: Label 'SEVEN HUNDRED';
        EightHundredTxt: Label 'EIGHT HUNDRED';
        NineHundredTxt: Label 'NINE HUNDRED';
        WithTxt: Label 'WITH';
        OneATxt: Label 'ONE';
        MillionsTxt: Label 'MILLION';
        BillionsTxt: Label 'BILLION';

    /// <summary>
    /// InitTextVariable.
    /// </summary>
    procedure InitTextVariable()
    begin
        OnesText[1] := OneTxt;
        OnesText[2] := TwoTxt;
        OnesText[3] := ThreeTxt;
        OnesText[4] := FourTxt;
        OnesText[5] := FiveTxt;
        OnesText[6] := SixTxt;
        OnesText[7] := SevenTxt;
        OnesText[8] := EightTxt;
        OnesText[9] := NineTxt;
        OnesText[10] := TenTxt;
        OnesText[11] := ElevenTxt;
        OnesText[12] := TwelveTxt;
        OnesText[13] := ThirteenTxt;
        OnesText[14] := FourteenTxt;
        OnesText[15] := FifteenTxt;
        OnesText[16] := SixteenTxt;
        OnesText[17] := SeventeenTxt;
        OnesText[18] := EighteenTxt;
        OnesText[19] := NineteenTxt;

        TensText[1] := '';
        TensText[2] := TwentyTxt;
        TensText[3] := ThirtyTxt;
        TensText[4] := FortyTxt;
        TensText[5] := FiftyTxt;
        TensText[6] := SixtyTxt;
        TensText[7] := SeventyTxt;
        TensText[8] := EigntyTxt;
        TensText[9] := NinetyTxt;

        ExponentText[1] := '';
        ExponentText[2] := ThousandTxt;
        ExponentText[3] := MillionTxt;
        ExponentText[4] := BillionTxt;

        ExponentsText[1] := '';
        ExponentsText[2] := ThousandTxt;
        ExponentsText[3] := MillionsTxt;
        ExponentsText[4] := BillionsTxt;

        ExponentHundredText[1] := HundredTxt;
        ExponentHundredText[2] := TwoHundredTxt;
        ExponentHundredText[3] := ThreeHundredTxt;
        ExponentHundredText[4] := FourHundredTxt;
        ExponentHundredText[5] := FiveHundredTxt;
        ExponentHundredText[6] := SixHundredTxt;
        ExponentHundredText[7] := SevenHundredTxt;
        ExponentHundredText[8] := EightHundredTxt;
        ExponentHundredText[9] := NineHundredTxt;
    end;

    /// <summary>
    /// FormatNoText.
    /// </summary>
    /// <param name="NoText">VAR array[2] of Text[80].</param>
    /// <param name="No">Decimal.</param>
    /// <param name="CurrencyCode">Code[10].</param>
    procedure FormatNoText(var NoText: array[2] of Text[80]; No: Decimal; CurrencyCode: Code[10])
    var
        PrintExponent: Boolean;
        Ones: Integer;
        Tens: Integer;
        Hundreds: Integer;
        Exponent: Integer;
        NoTextIndex: Integer;
        DecimalPosition: Decimal;
        DecimalPositionText: Text;
    begin
        Clear(NoText);
        NoTextIndex := 1;

        if No < 1 then
            AddToNoText(NoText, NoTextIndex, PrintExponent, ZeroTxt)
        else
            for Exponent := 4 downto 1 do begin
                PrintExponent := false;
                Ones := No div Power(1000, Exponent - 1);
                Hundreds := Ones div 100;
                Tens := (Ones mod 100) div 10;
                Ones := Ones mod 10;
                if Hundreds > 0 then
                    if ((Tens <> 0) or (Ones <> 0)) and (Hundreds = 1) then
                        AddToNoText(NoText, NoTextIndex, PrintExponent, OneHundredTxt)
                    else
                        AddToNoText(NoText, NoTextIndex, PrintExponent, ExponentHundredText[Hundreds]);
                if Tens >= 2 then begin
                    AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[Tens]);
                    if Ones > 0 then begin
                        AddToNoText(NoText, NoTextIndex, PrintExponent, AndTxt);
                        if (Ones = 1) and (Exponent > 1) then
                            AddToNoText(NoText, NoTextIndex, PrintExponent, OneATxt)
                        else
                            AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Ones]);
                    end;
                end else
                    if (Tens * 10 + Ones) > 0 then
                        if (Exponent > 1) and (Ones = 1) and (Tens = 0) then
                            AddToNoText(NoText, NoTextIndex, PrintExponent, OneATxt)
                        else
                            AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Tens * 10 + Ones]);
                if PrintExponent and (Exponent > 1) then
                    if (Tens * 10 + Ones) > 1 then
                        AddToNoText(NoText, NoTextIndex, PrintExponent, ExponentsText[Exponent])
                    else
                        AddToNoText(NoText, NoTextIndex, PrintExponent, ExponentText[Exponent]);
                No := No - (Hundreds * 100 + Tens * 10 + Ones) * Power(1000, Exponent - 1);
            end;

        AddToNoText(NoText, NoTextIndex, PrintExponent, WithTxt);
        DecimalPosition := GetAmtDecimalPosition(CurrencyCode);
        DecimalPosition := Round(DecimalPosition, 0.01);
        DecimalPositionText := Format(No * DecimalPosition);
        if StrLen(DecimalPositionText) = 1 then
            DecimalPositionText := '0' + DecimalPositionText;
        AddToNoText(NoText, NoTextIndex, PrintExponent, (DecimalPositionText + '/' + Format(DecimalPosition)));

        if CurrencyCode <> '' then
            AddToNoText(NoText, NoTextIndex, PrintExponent, CurrencyCode);
    end;

    local procedure AddToNoText(var NoText: array[2] of Text[80]; var NoTextIndex: Integer; var PrintExponent: Boolean; AddText: Text[30])
    begin
        PrintExponent := true;

        while StrLen(NoText[NoTextIndex] + ' ' + AddText) > MaxStrLen(NoText[1]) do begin
            NoTextIndex := NoTextIndex + 1;
            if NoTextIndex > ArrayLen(NoText) then
                Error(ResultsErr, AddText);
        end;

        NoText[NoTextIndex] := CopyStr(DelChr(NoText[NoTextIndex] + ' ' + AddText, '<'), 1, 80);
    end;

    local procedure GetAmtDecimalPosition(CurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
    begin
        if CurrencyCode = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(CurrencyCode);
            Currency.TestField("Amount Rounding Precision");
        end;

        exit(100/*1 / Currency."Amount Rounding Precision"*/);
    end;
}