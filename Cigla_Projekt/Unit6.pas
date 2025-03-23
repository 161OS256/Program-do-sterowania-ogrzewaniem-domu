unit Unit6;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, StdCtrls;

type
  TForm6 = class(TForm)
    Image1: TImage;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form6: TForm6;
  Bitmap : TBitmap;

implementation
  uses
 Unit1;
{$R *.dfm}


procedure TForm6.Button1Click(Sender: TObject);
begin
Form6.Close;
end;

end.
