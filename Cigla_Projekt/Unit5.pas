unit Unit5;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, idSocketHandle, WinSock,Forms,
  IdBaseComponent, IdTCPServer, IdCustomHTTPServer, IdHTTPServer,
  IdComponent, StdCtrls, Controls;

type
  TForm5 = class(TForm)
    HTTPServer: TIdHTTPServer;
    cbActive: TCheckBox;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    procedure acActivateExecute(Sender: TObject);
    procedure HTTPServerCommandGet(AThread: TIdPeerThread;
    RequestInfo: TIdHTTPRequestInfo; ResponseInfo: TIdHTTPResponseInfo);
    function LocalIP: string;
    function PortTCP_IsOpen(dwPort : Word; ipAddressStr:AnsiString) : boolean;
  private
    { Private declarations }
  public
    { Public declarations }
    EnableLog: boolean;
  end;

var
  Form5: TForm5;
   www : String;
implementation

uses FileCtrl, Unit1, IdStack;

{$R *.DFM}

procedure TForm5.acActivateExecute(Sender: TObject);
var
  Binding : TIdSocketHandle;

begin
  if not HTTPServer.Active then
  begin
    HTTPServer.Bindings.Clear;
    Binding := HTTPServer.Bindings.Add;
    Binding.Port := StrToIntDef(Edit1.text, 80);
    Binding.IP := LocalIP;
  end;
 if cbActive.Checked = True then
 begin
  if PortTCP_IsOpen(StrToInt(Edit1.text),LocalIP) then
  Form1.StatusBar1.Panels[1].Text:= ('Port ' + Edit1.text + ' zajêty' + ' Server nie Aktywny' ) else
  begin
  www := ExtractFilePath(Application.exename);
  HTTPServer.Active := true;
  Label3.Caption := (LocalIP + ':' + Edit1.text);
  Form1.StatusBar1.Panels[1].Text:= 'Server Aktywny';
  end;
 end else
 begin
 HTTPServer.Active := false;
 Label3.Caption := ' ';
 Form1.StatusBar1.Panels[1].Text:= 'Server nie Aktywny';
 end;
end;

procedure TForm5.HTTPServerCommandGet(AThread: TIdPeerThread;
  RequestInfo: TIdHTTPRequestInfo; ResponseInfo: TIdHTTPResponseInfo);
var
  LocalDoc: string;
begin
    LocalDoc := ExpandFilename(www + RequestInfo.Document);
    if not FileExists(LocalDoc) and DirectoryExists(LocalDoc) and FileExists(ExpandFileName(LocalDoc + '/index.html')) then
    LocalDoc := ExpandFileName(LocalDoc + '/index.html');
    HTTPServer.ServeFile(AThread, ResponseInfo, LocalDoc);
end;

 function TForm5.LocalIP: string;
type
   TaPInAddr = array [0..10] of PInAddr;
   PaPInAddr = ^TaPInAddr;
var
    phe: PHostEnt;
    pptr: PaPInAddr;
    Buffer: array [0..63] of char;
    i: Integer;
    GInitData: TWSADATA;
begin
    WSAStartup($101, GInitData);
    Result := '';
    GetHostName(Buffer, SizeOf(Buffer));
    phe :=GetHostByName(buffer);
    if phe = nil then Exit;
    pptr := PaPInAddr(Phe^.h_addr_list);
    i := 0;
    while pptr^[i] <> nil do
    begin
      result:=StrPas(inet_ntoa(pptr^[i]^));
      Inc(i);
    end;
    WSACleanup;
end;

function TForm5.PortTCP_IsOpen(dwPort : Word; ipAddressStr:AnsiString) : boolean;
var
  client : sockaddr_in;
  sock   : Integer;
 
  ret    : Integer;
  wsdata : WSAData;
begin
 Result:=False;
 ret := WSAStartup($0002, wsdata);
  if ret<>0 then exit;
  try
    client.sin_family      := AF_INET;  // (IPv4)
    client.sin_port        := htons(dwPort);
    client.sin_addr.s_addr := inet_addr(PAnsiChar(ipAddressStr));
    sock  :=socket(AF_INET, SOCK_STREAM, 0);
    Result:=connect(sock,client,SizeOf(client))=0;
  finally
  WSACleanup;
  end;
end;
end.
