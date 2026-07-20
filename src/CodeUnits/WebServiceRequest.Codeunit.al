namespace GMAS.ELectronicInvoicing.Ecuador;

/// <summary>
/// GMAS - Codeunit EIE Web Service Request (ID 70500).
/// </summary>
codeunit 70500 "EIE Web Service Request"
{
    trigger OnRun()
    begin
    end;

    var
        SendErr: Label 'GMAS: The web service call is unsuccessful';
        ResultResponseErr: Label 'GMAS: The Web Service has returned the following error:\Cod. Status: %1\Description: %2\Detail: %3', Comment = '%1 = Status Code, %2 = Description, %3 = Detail';

    /// <summary>
    /// TestWebService.
    /// </summary>
    /// <param name="JsonBody">JsonObject.</param>
    /// <param name="APIUrl">Text.</param>
    /// <param name="Token">Text.</param>
    /// <param name="ResponseText">VAR Text.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure RequestWebService(JsonBody: JsonObject; APIUrl: Text; Token: Text; var ResponseText: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        JsonRequestText: Text;
        ResponseError: Text;
        ResponseJson: JsonToken;
        ResponseToken: JsonToken;
        AuthToken: Text;
    begin
        AuthToken := 'Bearer ' + Token;

        Clear(ResponseText);

        JsonBody.WriteTo(JsonRequestText);

        HttpContent.Clear();
        HttpContent.WriteFrom(JsonRequestText);
        HttpContent.GetHeaders(HttpHeaders);

        if HttpHeaders.Contains('Content-Type') then
            HttpHeaders.Remove('Content-Type');

        HttpHeaders.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content(HttpContent);
        HttpRequestMessage.Method('POST');
        HttpRequestMessage.SetRequestUri(APIUrl);

        HttpClient.DefaultRequestHeaders().Add('Authorization', AuthToken);

        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            //Message(SendErr);
            Message(ResultResponseErr, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase, SendErr);
            exit(false);
        end;

        if not HttpResponseMessage.IsSuccessStatusCode then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            ResponseJson.ReadFrom(ResponseText);

            if ResponseJson.SelectToken('errors', ResponseToken) then
                ResponseToken.WriteTo(ResponseError);

            Message(ResultResponseErr, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase, ResponseError);
            exit(false);
        end;

        HttpResponseMessage.Content.ReadAs(ResponseText);
        exit(true);
    end;
}