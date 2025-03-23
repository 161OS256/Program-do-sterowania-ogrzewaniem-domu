unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, INIFiles;

type
  TForm4 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
   CiglaName:string;
  public
    { Public declarations }
  end;

var
  Form4: TForm4;
  INI : TIniFile;

implementation
 uses Unit2, Unit1;

{$R *.dfm}

procedure TForm4.Button1Click(Sender: TObject);
 var
  INI : TIniFile;
begin
  CiglaName:=ExtractFileDir(application.exename);
  CiglaName:=CiglaName+'\Cigla.ini';

  INI := TINIFile.Create(CiglaName);
  try
  INI.WriteString('Klucz Programu', 'Serial', Edit1.Text);
  finally
  INI.Free;
  Form4.Close;
end;
end;
end.
