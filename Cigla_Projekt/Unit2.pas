unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, INIFiles, zlportio, ComCtrls, MMSystem;

type
  TForm2 = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    Edit12: TEdit;
    Label10: TLabel;
    Edit4: TEdit;
    Label11: TLabel;
    Edit5: TEdit;
    Label12: TLabel;
    Label19: TLabel;
    Edit6: TEdit;
    Label13: TLabel;
    Edit7: TEdit;
    Label14: TLabel;
    Edit8: TEdit;
    Label15: TLabel;
    Edit9: TEdit;
    Label16: TLabel;
    Edit10: TEdit;
    Button8: TButton;
    Edit13: TEdit;
    GroupBox2: TGroupBox;
    Brak: TMemo;
    Button15: TButton;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Edit1: TEdit;
    Button4: TButton;
    Button5: TButton;
    Label5: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Label17: TLabel;
    Edit3: TEdit;
    Edit11: TEdit;
    Button2: TButton;
    Button3: TButton;
    Label6: TLabel;
    Button6: TButton;
    Button7: TButton;
    Label4: TLabel;
    Button16: TButton;
    Button17: TButton;
    Label18: TLabel;
    GroupBox4: TGroupBox;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Label7: TLabel;
    Edit14: TEdit;
    Label8: TLabel;
    Button18: TButton;
    Button19: TButton;
    Label20: TLabel;
    Edit15: TEdit;
    Button20: TButton;
    Button21: TButton;
    Label21: TLabel;
    Label22: TLabel;
    Edit16: TEdit;
    Button22: TButton;
    Button23: TButton;
    Label23: TLabel;
    Label9: TLabel;
    Edit17: TEdit;
    Edit18: TEdit;
    Label24: TLabel;
    Label25: TLabel;
    Edit19: TEdit;
    Edit20: TEdit;
    Label26: TLabel;
    Label27: TLabel;
    Edit21: TEdit;
    Label28: TLabel;
    Edit22: TEdit;
    Edit23: TEdit;
    Label29: TLabel;
    Edit24: TEdit;
    Label30: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure Button23Click(Sender: TObject);

  private

  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation
  uses Unit1;

{$R *.dfm}



procedure TForm2.Button4Click(Sender: TObject);
begin
 if utrata_c = 0.0 then utrata_c := 0;
 if utrata_c < 4.9 then
 begin
  utrata_c :=  utrata_c + 0.1;
  Form2.Edit1.Text:= CurrToStr(utrata_c);
 end;
end;

procedure TForm2.Button5Click(Sender: TObject);
begin
 if utrata_c = 0.0 then utrata_c := 0;
 if utrata_c > -4.9 then
 begin
  utrata_c :=  utrata_c - 0.1;
  Form2.Edit1.Text:= CurrToStr(utrata_c);
 end;
end;


procedure TForm2.Button2Click(Sender: TObject);
begin
 if histereza < 0.9 then
 begin
  histereza :=  histereza + 0.1;
  Form2.Edit2.Text:= CurrToStr(histereza);
 end;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
 if histereza > 0.2 then
 begin
  histereza :=  histereza - 0.1;
  Form2.Edit2.Text:= CurrToStr(histereza);
 end;
end;



procedure TForm2.Button6Click(Sender: TObject);
begin
 if Ia < 300 then
   begin
    Ia :=  Ia + 1;
    Form2.Edit3.Text:= CurrToStr(Ia);
   end;
end;

procedure TForm2.Button7Click(Sender: TObject);
begin
 if Ia > 60 then
   begin
    Ia :=  Ia - 1;
    Form2.Edit3.Text:= CurrToStr(Ia);
   end;
end;


procedure TForm2.Button16Click(Sender: TObject);
begin
 if P < 45 then
   begin
    P :=  P + 1;
    Form2.Edit11.Text:= CurrToStr(P);
   end;
end;

procedure TForm2.Button17Click(Sender: TObject);
begin
  if P > 25 then
   begin
    P :=  P - 1;
    Form2.Edit11.Text:= CurrToStr(P);
   end;
end;


procedure TForm2.Button18Click(Sender: TObject);
begin
 if nk < 60 then
   begin
    nk :=  nk + 1;
    Form2.Edit14.Text := CurrToStr(nk);
   end;
end;

procedure TForm2.Button19Click(Sender: TObject);
begin
  if nk > 45 then
   begin
    nk :=  nk - 1;
    Form2.Edit14.Text := CurrToStr(nk);
   end;
end;

procedure TForm2.Button20Click(Sender: TObject);
begin
   if hk < 4 then
   begin
    hk :=  hk + 1;
    Form2.Edit15.Text := CurrToStr(hk);
   end;
end;

procedure TForm2.Button21Click(Sender: TObject);
begin
    if hk > 1 then
   begin
    hk :=  hk - 1;
    Form2.Edit15.Text := CurrToStr(hk);
   end;
end;

procedure TForm2.Button22Click(Sender: TObject);
begin
    if hp < 4 then
   begin
    hp :=  hp + 1;
    Form2.Edit16.Text := CurrToStr(hp);
   end;
end;

procedure TForm2.Button23Click(Sender: TObject);
begin
    if hp > 1 then
   begin
    hp :=  hp - 1;
    Form2.Edit16.Text := CurrToStr(hp);
   end;
end;


procedure TForm2.Button8Click(Sender: TObject);
begin
 T := portreadb($378+1);
 Form2.Edit13.Text := IntToStr(T);
end;



procedure TForm2.Button15Click(Sender: TObject);
begin
    Form2.Brak.Clear;
end;

procedure TForm2.CheckBox1Click(Sender: TObject);
begin
if Form2.CheckBox1.Checked = false then Form2.CheckBox1.Caption := 'OFF'
else Form2.CheckBox1.Caption := 'ON';
end;

procedure TForm2.CheckBox2Click(Sender: TObject);
begin
 if Form2.CheckBox2.Checked = false then Form2.CheckBox2.Caption := 'OFF'
 else Form2.CheckBox2.Caption := 'ON';
end;

procedure TForm2.CheckBox3Click(Sender: TObject);
begin
 if Form2.CheckBox3.Checked = false then Form2.CheckBox3.Caption := 'OFF'
 else Form2.CheckBox3.Caption := 'ON';
end;

procedure TForm2.Button9Click(Sender: TObject);
begin
   SleepTime:=(60);
		  begin
			portwriteb($378,$1);
			Sleep(SleepTime);
			portwriteb($378,$4);
			Sleep(SleepTime);
			portwriteb($378,$2);
			Sleep(SleepTime);
			portwriteb($378,$8);
      Sleep(SleepTime);
      portwriteb($378,$1);
			Sleep(SleepTime);
			portwriteb($378,$4);
			Sleep(SleepTime);
			portwriteb($378,$2);
			Sleep(SleepTime);
			portwriteb($378,$8);
      Sleep(SleepTime);
      portwriteb($378,$1);
			Sleep(SleepTime);
			portwriteb($378,$4);
			Sleep(SleepTime);
			portwriteb($378,$2);
			Sleep(SleepTime);
			portwriteb($378,$8);
      Sleep(SleepTime);
      portwriteb($378,$0);

      T := portreadb($378+1);
      Form2.Edit13.Text := IntToStr(T);
      end;
end;

procedure TForm2.Button10Click(Sender: TObject);
begin
 SleepTime:=(60);
  	 begin
      portwriteb($378,$8);
      Sleep(SleepTime);
      portwriteb($378,$2);
      Sleep(SleepTime);
      portwriteb($378,$4);
      Sleep(SleepTime);
      portwriteb($378,$1);
      Sleep(SleepTime);
      portwriteb($378,$8);
      Sleep(SleepTime);
      portwriteb($378,$2);
      Sleep(SleepTime);
      portwriteb($378,$4);
      Sleep(SleepTime);
      portwriteb($378,$1);
      Sleep(SleepTime);
      portwriteb($378,$8);
      Sleep(SleepTime);
      portwriteb($378,$2);
      Sleep(SleepTime);
      portwriteb($378,$4);
      Sleep(SleepTime);
      portwriteb($378,$1);
      Sleep(SleepTime);
      portwriteb($378,$0);

      T := portreadb($378+1);
      Form2.Edit13.Text := IntToStr(T);
      end;
end;

procedure TForm2.Button11Click(Sender: TObject);
begin
      SleepTime:=(300);
      begin
      portwriteb($378,$40);
      Sleep(SleepTime);
      portwriteb($378,$0);
      mp := 2;

      T := portreadb($378+1);
      Form2.Edit13.Text := IntToStr(T);
      end;
end;

procedure TForm2.Button12Click(Sender: TObject);
begin
      SleepTime:=(300);
      begin
      portwriteb($378,$80);
      Sleep(SleepTime);
      portwriteb($378,$0);

       C:=portreadb($378+1);
       if (((kominek - pomp) >= hp) or (piec_c > 65)) and (mp = 0) then
       begin
       C:=portreadb($378+1);
       if ( C = z4 ) or ( C = z14) or ( C = z24) or ( C = z34) or ( C = z234) or ( C = z124) or ( C = z134) or ( C = z1234) then
       begin
         SleepTime:=(300);
         portwriteb($378,$40);
         Sleep(SleepTime);
         portwriteb($378,$0);

         C:=portreadb($378+1);
         if ( C <> z4 ) or ( C <> z14) or ( C <> z24) or ( C <> z34) or ( C <> z234) or ( C <> z124) or ( C <> z134) or ( C <> z1234) then
         begin
         dolot := 'Pompa_ON';
         Label23.Caption:= dolot;
         mp := 1;
         Form2.Brak.Lines.Add(Data + ' ' + Czas3 + '. Pompa_ON_Kominek_' + CurrToStr(kominek) + '_°C_0>>>1..' + #13#10);
         end else
         begin
         Stan4:= 'Brak_zejscia_z_czujnika';
         Label18.Caption:= Stan4;
	       PlaySound('Alarm2.wav', 0, SND_FILENAME);
         dolot := 'Pompa_ON_Error';
         Label23.Caption:= dolot;
         Form2.Brak.Lines.Add(Data + ' ' + Czas3 + '. ' + Stan4 + '_' + dolot + '_0..' + #13#10);
         end;
         end;
	     end;
      end;
 T := portreadb($378+1);
 Form2.Edit13.Text := IntToStr(T);      
end;

procedure TForm2.Button13Click(Sender: TObject);
begin
      SleepTime:=(400);

      portwriteb($378,$20);
      Sleep(SleepTime);
      portwriteb($378,$20);
      Sleep(SleepTime);
      portwriteb($378,$0);
      trujnik_czek := 1;

      T := portreadb($378+1);
      Form2.Edit13.Text := IntToStr(T);
end;

procedure TForm2.Button14Click(Sender: TObject);
begin
      SleepTime:=(400);

      portwriteb($378,$10);
      Sleep(SleepTime);
      portwriteb($378,$10);
      Sleep(SleepTime);
      portwriteb($378,$0);
      trujnik_czek := 0;

      T := portreadb($378+1);
      Form2.Edit13.Text := IntToStr(T);
end;

procedure TForm2.Button1Click(Sender: TObject);
 begin
  CiglaName:=ExtractFileDir(application.exename);
  CiglaName:=CiglaName+'\Cigla.ini';

  INI := TINIFile.Create(CiglaName);
  try
  INI.WriteString('Ustawienia', 'Utrata Ciepla', Edit1.Text);
  INI.WriteString('Ustawienia', 'Histereza', Edit2.Text);
  INI.WriteString('Ustawienia', 'Aktualizacja co', Edit3.Text);
  INI.WriteString('Ustawienia', 'Start Pompa', Edit11.Text);
  INI.WriteString('Ustawienia', 'nastawa', Edit14.Text);
  INI.WriteString('Ustawienia', 'nastawa_h', Edit15.Text);
  INI.WriteString('Ustawienia', 'nastawa_h_p', Edit16.Text);

  INI.WriteString('Ustawienia', 'podloga', Form2.CheckBox1.Caption);
  INI.WriteString('Ustawienia', 'kominek', Form2.CheckBox2.Caption);
  INI.WriteString('Ustawienia', 'zawor', Form2.CheckBox3.Caption);

  INI.WriteString('Control', 'Stan Rozwarty', Edit12.Text);
  INI.WriteString('Control', 'Sterownik Podloga', Edit4.Text);
  INI.WriteString('Control', 'Kontrolka Zbiornik', Edit5.Text);
  INI.WriteString('Control', 'Sterownik Trujnik', Edit6.Text);
  INI.WriteString('Control', 'Sterownik Kominek', Edit17.Text);

  INI.WriteString('Control', '1+2', Edit7.Text);
  INI.WriteString('Control', '1+3', Edit8.Text);
  INI.WriteString('Control', '1+4', Edit18.Text);
  INI.WriteString('Control', '2+3', Edit9.Text);
  INI.WriteString('Control', '2+4', Edit19.Text);
  INI.WriteString('Control', '3+4', Edit24.Text);

  INI.WriteString('Control', '1+2+3', Edit10.Text);
  INI.WriteString('Control', '2+3+4', Edit20.Text);
  INI.WriteString('Control', '1+2+4', Edit21.Text);
  INI.WriteString('Control', '1+3+4', Edit22.Text);

  INI.WriteString('Control', '1+2+3+4', Edit23.Text);

  INI.WriteInteger('Odczyt', 'trujnik_czek', trujnik_czek );
  INI.WriteInteger('Odczyt', 'mp', mp );
  finally
  INI.Free;
  Form2.Close;
 end;
 end;

begin
  CiglaName:=ExtractFileDir(application.exename);
  CiglaName:=CiglaName+'\Cigla.ini';

  INI := TINIFile.Create(CiglaName);
  try
   utrata_c := StrToCurr(INI.ReadString('Ustawienia', 'Utrata Ciepla', '-1'));
	 histereza := StrToCurr(INI.ReadString('Ustawienia', 'Histereza', '0,5'));
	 Ia := StrToInt(INI.ReadString('Ustawienia', 'Aktualizacja co', '180'));
   P := StrToInt(INI.ReadString('Ustawienia', 'Start Pompa', '35'));
   nk := StrToInt(INI.ReadString('Ustawienia', 'nastawa', '50'));
   hk := StrToInt(INI.ReadString('Ustawienia', 'nastawa_h', '2'));
   hp := StrToInt(INI.ReadString('Ustawienia', 'nastawa_h_p', '2'));

  finally
	INI.Free;
end;

end.
