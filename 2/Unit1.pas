unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  nr, k : integer;
  zn : char;
  de : string;
  
implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  k := strtoint( edit1.text );

  for nr := 1 to length( edit2.text ) do
  begin
    zn := edit2.text[ nr ];
    de := de + chr( ord( zn ) xor ord( k ) );
  end;

  edit2.text := de;
  de := '';
end;

end.
