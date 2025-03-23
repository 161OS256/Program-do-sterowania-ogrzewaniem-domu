unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Registry, StdCtrls, ActiveX, ComObj;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
    dl_textu, nr, k : integer;
    zn : char;
    de, df : string;
    x : string;

implementation

{$R *.dfm}





function GetMotherBoardSerial:String;
var
  objWMIService : OLEVariant;
  colItems      : OLEVariant;
  colItem       : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;

  function GetWMIObject(const objectName: String): IDispatch;
  var
    chEaten: Integer;
    BindCtx: IBindCtx;
    Moniker: IMoniker;
  begin
    OleCheck(CreateBindCtx(0, bindCtx));
    OleCheck(MkParseDisplayName(BindCtx, StringToOleStr(objectName), chEaten, Moniker));
    OleCheck(Moniker.BindToObject(BindCtx, nil, IDispatch, Result));
  end;

begin
  Result:='';
  objWMIService := GetWMIObject('winmgmts:\\localhost\root\cimv2');
  colItems      := objWMIService.ExecQuery('SELECT SerialNumber FROM Win32_BaseBoard','WQL',0);
  oEnum         := IUnknown(colItems._NewEnum) as IEnumVariant;
  if oEnum.Next(1, colItem, iValue) = 0 then
  Result:=VarToStr(colItem.SerialNumber);
   x:= Result;
end;





procedure TForm1.Button1Click(Sender: TObject);
begin
 k:=11;

 GetMotherBoardSerial;

  dl_textu := length( x );

  for nr := 1 to dl_textu do
  begin
    zn := x[ nr ];
    df := df + chr( ord( zn ) xor ord( k ) );
  end;

  for nr := 1 to dl_textu do
  begin
    zn := df [nr ];
    de := de + chr( ord( zn ) xor ord( k ) );
  end;

  if ( x = de ) then
    form1.caption := 'status - OK'
  else
    df := df + '--';
   
  edit1.text := df;
  button1.Enabled := false;


end;

end.
