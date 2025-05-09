unit Unit1;

interface

uses
Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
Dialogs, zlportio, StdCtrls, ComCtrls, ExtCtrls, msxmldom, MMSystem, jpeg,
Registry, ActiveX, ComObj, PSD016eu, INIFiles, iBTMEXPW, Sockets;

const
    kDMLRomIndexMax=6;
    NASTAWA_M=32.54;
    granica=46.00;
    granica2=30.00;
    histereza2=3.00;

type
  TForm1 = class(TForm)
  StatusBar1: TStatusBar;
  Timer1: TTimer;
  Image1: TImage;
  Image2: TImage;
  Label1: TLabel;
  Label2: TLabel;
  Label3: TLabel;
  Label4: TLabel;
  Label5: TLabel;
  Label6: TLabel;
  Label7: TLabel;
  Label8: TLabel;
  Label9: TLabel;
  Label10: TLabel;
  Label11: TLabel;
  Label12: TLabel;
  Label13: TLabel;
  Label14: TLabel;
  Label15: TLabel;
  Label16: TLabel;
  Label18: TLabel;
  Label17: TLabel;
  Button1: TButton;
  Button2: TButton;
  Button3: TButton;
  Button4: TButton;
  Button5: TButton;
  Button6: TButton;
  Edit1: TEdit;
  Button7: TButton;
  ProgressBar1: TProgressBar;
  ProgressBar2: TProgressBar;
  Label19: TLabel;
  Button8: TButton;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
  procedure Timer1Timer(Sender: TObject);
  procedure Button1Click(Sender: TObject);
  procedure Button2Click(Sender: TObject);
  procedure Button4Click(Sender: TObject);
  procedure Button5Click(Sender: TObject);
  procedure Button6Click(Sender: TObject);
  procedure Button3Click(Sender: TObject);
  procedure FormCreate(Sender: TObject);
  procedure FetchNDisplayTture(bWhich:byte);
  procedure Button7Click(Sender: TObject);
  procedure Button8Click(Sender: TObject);
  procedure CanClose(Sender: TObject; var CanClose: Boolean);


private

    saDMLRomID:array [0..kDMLRomIndexMax] of string[16];
    baDMLRomIDTable:array [0..kDMLRomIndexMax,0..7] of byte;
    baDMLRomIDofOne:array [0..7] of byte;
    FileName, sIniFileName, CiglaName, IndexName, Index_NocName, WykresName,
    Wstecz_WykresName, DelWykresName, BMPName, Aktualny_wykres_noc,
    Wczorajszy_wykres_noc, Aktualny_wykres, Wczorajszy_wykres,
    Index_ServisName, Index_ServisNocName :string;
    dfIniFile:TIniFile;
    iDMLPortNum,iDMLAdapterType,liDMLSHandle:longint;

    sTmp:string;
    iErr:integer;
    bTmp:byte;
    rTmp:real;

public

end;
var
  Form1: TForm1;
  BMP: TBitmap;
  JPG: TJPEGImage;
  INI : TIniFile;
  TF : TextFile;

  zn : char;

  woda_s, kl, sypialnia_s, x, de, nastawa_s, rTmp_s, HTML, Stan3, Stan2s, Stan4,
  Stans, Czas, Czas2, Czas3, Data, Data_wstecz, Del_Data, wygaszanie_s,
  dolot, ch1, ch2, ch3, tr, CiglaName, czek1, czek2, czek3, slep_s, kolor, text_error, text_servis : String;

  dwor_r, zasilanie_r, salon_c, reg_c, piec_c, piec_z, kominek, wygaszanie,
  histereza, nastawa_w, nastawa_k, ruznica2, ruznica3, ruznica1, utrata_c, idn,
  stk, calk, calk2, calk3, woda_cur, stp, skok, skok2 : currency;

  SleepTime, s, nr, k, akt, P, pomp, Ia, del, sp : Integer;

  B, C, Stan, Stan2, ster, h, m, g, obraz, wygaszanie2, z0, z1, z2, z3, z4, z12,
  z13, z14, z23, z24, z34, z123, z234, z124, z134, z1234, nk, T, hk, hp, trujnik_czek, st : byte;

  bar : Integer = 0;
  I : integer = 5;
  mp : byte = 0;
  serv : byte = 0;
  kolorek : byte = 0;
  licz_z : byte = 0;
  licz_o : byte = 0;
  kolor_alarm : string = 'red';
  kolor_podloga : string = 'lime';
  kolor_kominek : string = 'aqua';
  kolor_trujnik : string = 'blue';

implementation
 uses
 Unit2, Unit3, Unit4, Unit5, Unit6, Unit7, Unit8;

{$R *.dfm}

procedure PutCtrlInPanel(wCtrl: TWincontrol; StatusBar: TStatusBar; PANEL_ID: Integer);
var
  ARect: TRect;
begin
  StatusBar.Perform((WM_USER + 10), PANEL_ID, Integer(@ARect));
  wCtrl.Parent := StatusBar;
  wCtrl.BoundsRect := ARect;
end;

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

   
  procedure TForm1.FormCreate(Sender: TObject);
   var c1:byte;

   procedure CreateIniFile;
   begin
   dfIniFile:=TIniFile.create(sIniFileName);
      dfIniFile.WriteString('adapter','type','1');
      dfIniFile.WriteString('adapter','port','1');
      dfIniFile.WriteString('chips','0','Sensor Dw�r');
      dfIniFile.WriteString('chips','1','Sensor Sypialnia');
      dfIniFile.WriteString('chips','2','Sensor Podloga');
      dfIniFile.WriteString('chips','3','Sensor Salon');
      dfIniFile.WriteString('chips','4','Sensor Piec');
      dfIniFile.WriteString('chips','5','Sensor CUW');
      dfIniFile.WriteString('chips','6','Sensor Kominek');
   dfIniFile.free;
   end;

  function boIDValid(sTmp:string):boolean;
   begin
   result:=true;
   if sTmp='xx' then result:=false;
   if copy(sTmp,1,3)='you' then result:=false;
   if (copy(sTmp,15,2)<>'10')and(copy(sTmp,15,2)<>'28') then
   begin
    showmessage('Niedopowiedni identyfikator czujnika powin konczyc sie 10 lub 28');
    result:=false;
   end;
   end;


 begin
   if ZLIOStarted then
    StatusBar1.Panels[0].Text := '  Sterownik za�adowany poprawnie.'
   else
   begin
    StatusBar1.Panels[0].Text := '  Nie mo�na za�adowa� sterownika.';
    Exit;
   end;

   SleepTime:=(60);
   portwriteb($378,$0);
   Sleep(SleepTime);

   FileName:=ExtractFileDir(application.exename);
   sIniFileName:=FileName+'\Czujniki.ini';
   CiglaName:=FileName+'\Cigla.ini';
   IndexName:=FileName+'\mbdzien.html';
   Index_NocName:=FileName+'\mbnoc.html';
   Index_ServisName:=FileName+'\servisdzien.html';
   Index_ServisNocName:=FileName+'\servisnoc.html';
   BMPName:=FileName+'\Wykres.bmp';

   if not FileExists (sIniFileName) then
    begin
     CreateIniFile;
    end else
  begin
     dfIniFile:=TIniFile.create(sIniFileName);
     sTmp:=dfIniFile.ReadString('adapter','type','xx');
     val(sTmp,iDMLAdapterType,iErr);
     if iErr<>0 then
     begin
      showmessage('Typ Adapteru musi miec numer');
      application.terminate;
     end;

   sTmp:=dfIniFile.ReadString('adapter','port','yy');
   val(sTmp,iDMLPortNum,iErr);
    if iErr<>0 then
     begin
      showmessage('Port Adapteru musi miec numer');
      application.terminate;
     end;

   sTmp:=dfIniFile.ReadString('chips','0','xx');
    if not boIDValid(sTmp) then
     begin
      showmessage('Sensor Dw�r Nieaktualny.');
      application.terminate;
     end;
      saDMLRomID[0]:=sTmp;

   sTmp:=dfIniFile.ReadString('chips','1','xx');
    if not boIDValid(sTmp) then
     begin
      showmessage('Sensor Sypialnia Nieaktualny.');
      application.terminate;
     end;
      saDMLRomID[1]:=sTmp;

   sTmp:=dfIniFile.ReadString('chips','2','xx');
    if not boIDValid(sTmp) then
     begin
      showmessage('Sensor Podloga Nieaktualny.');
      application.terminate;
     end;
      saDMLRomID[2]:=sTmp;

   sTmp:=dfIniFile.ReadString('chips','3','xx');
    if not boIDValid(sTmp) then
     begin
      showmessage('Sensor Salon Nieaktualny.');
      application.terminate;
     end;
      saDMLRomID[3]:=sTmp;

   sTmp:=dfIniFile.ReadString('chips','4','xx');
    if not boIDValid(sTmp) then
     begin
      showmessage('Sensor Piec Co Nieaktualny.');
      application.terminate;
     end;
      saDMLRomID[4]:=sTmp;

   sTmp:=dfIniFile.ReadString('chips','5','xx');
    if not boIDValid(sTmp) then
     begin
      showmessage('Sensor CWU Nieaktualny');
      application.terminate;
     end;
      saDMLRomID[5]:=sTmp;

   sTmp:=dfIniFile.ReadString('chips','6','xx');
    if not boIDValid(sTmp) then
     begin
      showmessage('Sensor Kominek Nieaktualny.');
      application.terminate;
     end;
      saDMLRomID[6]:=sTmp;

    dfIniFile.free;

    for c1:=0 to kDMLRomIndexMax do 
	 begin
       sTmp:=saDMLRomID[c1];
         baDMLRomIDTable[c1,7]:=strtoint('$'+copy(sTmp,1,2));
         baDMLRomIDTable[c1,6]:=strtoint('$'+copy(sTmp,3,2));
         baDMLRomIDTable[c1,5]:=strtoint('$'+copy(sTmp,5,2));
         baDMLRomIDTable[c1,4]:=strtoint('$'+copy(sTmp,7,2));
         baDMLRomIDTable[c1,3]:=strtoint('$'+copy(sTmp,9,2));
         baDMLRomIDTable[c1,2]:=strtoint('$'+copy(sTmp,11,2));
         baDMLRomIDTable[c1,1]:=strtoint('$'+copy(sTmp,13,2));
         baDMLRomIDTable[c1,0]:=strtoint('$'+copy(sTmp,15,2));
     end;
  end;
 end;

  
procedure TForm1.FetchNDisplayTture(bWhich:byte);
var c1,bTmp1,bTmp2,bTmp3:byte;
    iTmp:integer;
begin
 akt:=1;

 application.processmessages;

 DMLEstablishSession(iDMLPortNum,iDMLAdapterType,bTmp,liDMLSHandle);

 if bTmp<>0 then 
  begin
   if bWhich=0 then label1.caption:='Error';
   if bWhich=1 then label6.caption:='Error';
   if bWhich=2 then label4.caption:='Error';
   if bWhich=3 then label5.caption:='Error';
   if bWhich=4 then label2.caption:='Error';
   if bWhich=5 then label3.caption:='Error';
   if bWhich=6 then label20.caption:='Error';
   exit;
  end else
  
 begin
   for c1:=0 to 7 do
    baDMLRomIDofOne[c1]:=baDMLRomIDTable[bWhich,c1];
	
    DMLGet1820Tture(bTmp1,bTmp2,bTmp3,iTmp,liDMLSHandle,baDMLRomIDofOne);
	
    if bTmp3<>0 then
	begin
      showmessage('Problem z odczytem czujnika. '+
      'TKB Error: '+inttostr(bTmp3)+' , Dallas error: '+
      inttostr(iTmp));
      rTmp:=-999;
    end else 
	
	begin
     if baDMLRomIDOfOne[0]=$10 then rTmp:=rRawToC(bTmp1,bTmp2);
     if baDMLRomIDOfOne[0]=$28 then rTmp:=rRawToC18B20(bTmp1,bTmp2);
    end;

 if bWhich=0 then
  begin
   rTmp_s := floattostrf(rTmp,ffFixed,5,2);
   label1.caption := rTmp_s;
   dwor_r := StrToCurr(rTmp_s);
   ProgressBar1.Position := 1;
  end;

 if bWhich=1 then
  begin
   rTmp_s := floattostrf(rTmp,ffFixed,5,2);
   label6.caption:= rTmp_s;
   sypialnia_s := rTmp_s;
   ProgressBar1.Position := 2;
  end;

 if bWhich=2 then
  begin
   rTmp_s := floattostrf(rTmp,ffFixed,5,2);
   label4.caption := rTmp_s;
   zasilanie_r := StrToCurr(rTmp_s);
   ProgressBar1.Position := 3;
  end;

 if bWhich=3 then
  begin
   rTmp_s := floattostrf(rTmp,ffFixed,5,2);
   label5.caption := rTmp_s;
   salon_c := StrToCurr(rTmp_s);
   ProgressBar1.Position := 4;
  end;

 if bWhich=4 then
  begin
   rTmp_s := floattostrf(rTmp,ffFixed,5,2);
   label2.caption := rTmp_s;
   piec_c := StrToCurr(rTmp_s);
   ProgressBar1.Position := 5;
  end;

 if bWhich=5 then
  begin
   rTmp_s := floattostrf(rTmp,ffFixed,5,2);
   label3.caption := rTmp_s;
   woda_s := rTmp_s;
   woda_cur := StrToCurr(rTmp_s);
   ProgressBar1.Position := 6;
  end;

 if bWhich=6 then
  begin
   rTmp_s := floattostrf(rTmp,ffFixed,5,2);
   label20.caption := rTmp_s;
   kominek := StrToCurr(rTmp_s);
   ProgressBar1.Position := 7;
  end;

 end;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
 begin
 Czas3 := FormatDateTime('hh:mm', Time);
 label19.Caption:= Czas3;

  if akt = 1 then
  begin
    StatusBar1.Panels[4].Text:= 'Aktualizacja';
  end else
  begin
    StatusBar1.Panels[4].Text:= 'Aktualizacja za ' + IntToStr(I) + ' sek.';
    Dec(I);
    If I = 0 then Button2.Click;
  end;
  akt:=0;
 end;


procedure TForm1.Button2Click(Sender: TObject);
 begin
  woda_s:= '0';
  sypialnia_s:= '0';

   Data := FormatDateTime('yyyy-mm-dd', Date);
   Data_wstecz := FormatDateTime('yyyy-mm-dd', Date -1);
   Del_Data := FormatDateTime('yyyy-mm-dd', Date -2);

   WykresName:=FileName+'\'+Data+'.jpg';
   Wstecz_WykresName:=FileName+'\'+Data_wstecz+'.jpg';
   DelWykresName:=FileName+'\'+Del_Data+'.jpg';
   Aktualny_wykres_noc:=FileName+'\Aktualny_wykres_noc.'+Data+'.html';
   Wczorajszy_wykres_noc:=FileName+'\Wczorajszy_wykres_noc.'+Data_wstecz+'.html';
   Aktualny_wykres:=FileName+'\Aktualny_wykres.'+Data+'.html';
   Wczorajszy_wykres:=FileName+'\Wczorajszy_wykres.'+Data_wstecz+'.html';

  PutCtrlInPanel(ProgressBar1, StatusBar1, 2);
  PutCtrlInPanel(ProgressBar2, StatusBar1, 3);


  CiglaName:=ExtractFileDir(application.exename);
  CiglaName:=CiglaName+'\Cigla.ini';
  
  INI := TINIFile.Create(CiglaName);
   try
    I := StrToInt(INI.ReadString('Ustawienia', 'Aktualizacja co', '180'));
  	kl := (INI.ReadString('Klucz Programu', 'Serial', ' '));
   finally
	INI.Free;
   end;

  de := '';
  k := 13;

  for nr := 1 to length( kl ) do
   begin
    zn := kl[ nr ];
    de := de + chr( ord( zn ) xor ord( k ));
   end;

  GetMotherBoardSerial;

  if de <> x then
   begin
  	Form4.Show;
	  Exit;
   end;

  FetchNDisplayTture(0);
  FetchNDisplayTture(1);
  FetchNDisplayTture(2);
  FetchNDisplayTture(3);
  FetchNDisplayTture(4);
  FetchNDisplayTture(5);
  FetchNDisplayTture(6);
  FetchNDisplayTture(7);

  reg_c := StrToCurr(Edit1.Text);

  CiglaName:=ExtractFileDir(application.exename);
  CiglaName:=CiglaName+'\Cigla.ini';

  INI := TINIFile.Create(CiglaName);
  try
   utrata_c := StrToCurr(INI.ReadString('Ustawienia', 'Utrata Ciepla', '-1'));
	 histereza := StrToCurr(INI.ReadString('Ustawienia', 'Histereza', '0,5'));
	 I := StrToInt(INI.ReadString('Ustawienia', 'Aktualizacja co', '180'));
   pomp := StrToInt(INI.ReadString('Ustawienia', 'Start Pompa', '35'));
   nk := StrToInt(INI.ReadString('Ustawienia', 'nastawa', '0'));
   hk := StrToInt(INI.ReadString('Ustawienia', 'nastawa_h', '0'));
   hp := StrToInt(INI.ReadString('Ustawienia', 'nastawa_h_p', '0'));
   czek1 := INI.ReadString('Ustawienia', 'podloga', '0');
   czek2 := INI.ReadString('Ustawienia', 'kominek', '0');
   czek3 := INI.ReadString('Ustawienia', 'zawor', '0');

   z0 := StrToInt(INI.ReadString('Control', 'Stan Rozwarty', '0'));
   z1 := StrToInt(INI.ReadString('Control', 'Sterownik Podloga', '0'));
   z2 := StrToInt(INI.ReadString('Control', 'Kontrolka Zbiornik', '0'));
   z3 := StrToInt(INI.ReadString('Control', 'Sterownik Trujnik', '0'));
   z4 := StrToInt(INI.ReadString('Control', 'Sterownik Kominek', '0'));

   z12 := StrToInt(INI.ReadString('Control', '1+2', '0'));
   z13 := StrToInt(INI.ReadString('Control', '1+3', '0'));
   z14 := StrToInt(INI.ReadString('Control', '1+4', '0'));
   z23 := StrToInt(INI.ReadString('Control', '2+3', '0'));
   z24 := StrToInt(INI.ReadString('Control', '2+4', '0'));
   z34 := StrToInt(INI.ReadString('Control', '3+4', '0'));

   z123 := StrToInt(INI.ReadString('Control', '1+2+3', '0'));
   z234 := StrToInt(INI.ReadString('Control', '2+3+4', '0'));
   z124 := StrToInt(INI.ReadString('Control', '1+2+4', '0'));
   z134 := StrToInt(INI.ReadString('Control', '1+3+4', '0'));

   z1234 := StrToInt(INI.ReadString('Control', '1+2+3+4', '0'));


   mp := StrToInt(INI.ReadString('Odczyt', 'mp', '0'));
   wygaszanie := StrToCurr(INI.ReadString('Odczyt', 'Piec', '0'));
   obraz := StrToInt(INI.ReadString('Ustawienia', 'Obraz', '0'));
   wygaszanie2 := StrToInt(INI.ReadString('Odczyt', 'Wygaszanie', '0'));
   trujnik_czek := StrToInt(INI.ReadString('Odczyt', 'trujnik_czek', '0'));
   stk := StrToCurr(INI.ReadString('Odczyt', 'stk', '0'));
   stp := StrToCurr(INI.ReadString('Odczyt', 'stp', '0'));
  finally
	INI.Free;
  end;

  piec_z := 0;

  if ( piec_c < granica ) then
   if ( piec_c < granica2 ) then wygaszanie2 := 3 else
   begin
      if ( piec_c > ( wygaszanie + histereza2 )) then
      begin
      wygaszanie2 := 1;
      piec_z := 1;
      end;

      if ( piec_c < ( wygaszanie - histereza2 )) then
      begin
      wygaszanie2 := 2;
      piec_z := 1;
      end;
   end else
      begin
      piec_z := 2;
      wygaszanie2 := 0;
      end;

  if wygaszanie2 = 2 then
  C:=portreadb($378+1);
  if ( C <> z4 ) or ( C <> z14) or ( C <> z24) or ( C <> z34) or ( C <> z234) or ( C <> z124) or ( C <> z134) or ( C <> z1234) then
  
  begin
  SleepTime:=(400);
  portwriteb($378,$80);
  Sleep(SleepTime);
  portwriteb($378,$0);
  end;

  if wygaszanie2 = 0 then wygaszanie_s := ' ';
  if wygaszanie2 = 1 then wygaszanie_s := 'Rozpalanie';
  if wygaszanie2 = 2 then wygaszanie_s := 'Wygaszanie';
  if wygaszanie2 = 3 then wygaszanie_s := 'Wygaszone';

  Label17.Caption:= wygaszanie_s;

  Stan4:= ' ';
  Label18.Caption:= Stan4;


  for st:=0 to Form2.Brak.Lines.Count -1 do
  begin
  if Pos(Data, AnsiLowerCase(Form2.Brak.Lines.Strings[0])) = 0 then
  if Pos(Data_wstecz, AnsiLowerCase(Form2.Brak.Lines.Strings[0])) = 0 then
  if Pos(Del_data, AnsiLowerCase(Form2.Brak.Lines.Strings[0])) > 0 then Break else Form2.Brak.Lines.Delete(0);
  end;


  If czek3 = 'OFF' then
  begin
  tr := 'Trujnik_OFF';
  Label24.Caption := tr;
  end else
  begin

    if trujnik_czek = 1 then tr := 'Trujnik_Kominek' else tr := 'Trujnik_Piec';
    Label24.Caption := tr;

    C:=portreadb($378+1);
    if (kominek > piec_c) and (kominek > (pomp - 3)) and (trujnik_czek = 0) and ((kominek - stk) < 20) then
      begin
         SleepTime:=(400);

         portwriteb($378,$20);
         Sleep(SleepTime);
         portwriteb($378,$20);
         Sleep(SleepTime);
         portwriteb($378,$0);

          C:=portreadb($378+1);
          if ( C = z3 ) or ( C = z13) or ( C = z123) or ( C = z23) or ( C = z34) or ( C = z234) or ( C = z134) or ( C = z1234) then
          begin
          Stan4:= 'Brak_zejscia_z_czujnika_T/K';
          Label18.Caption:= Stan4;
		      PlaySound('Alarm2.wav', 0, SND_FILENAME);
          Form2.Brak.Lines.Add(Data + ' ' + Czas3);
          Form8.Brak.Lines.Add('<span style="color:' + kolor_trujnik + ';">' + Data + ' ' + Czas3 + '.');

		      Form2.Brak.Lines.Add('Tempo_' + CurrToStr(kominek - stk) + '�C.');
          Form8.Brak.Lines.Add('Tempo_' + CurrToStr(kominek - stk) + '�C.');

          Form2.Brak.Lines.Add('Brak_zejscia_z_czujnika_T/K' + #13#10);
          Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Brak_zejscia_z_czujnika_T/K</span></span>..' + #13#10);
          end else
          begin
            for st:=0 to 10 do
            begin
            portwriteb($378,$20);
            Sleep(SleepTime);
            portwriteb($378,$0);

            C:=portreadb($378+1);
            if ( C = z3 ) or ( C = z13) or ( C = z123) or ( C = z23) or ( C = z34) or ( C = z234) or ( C = z134) or ( C = z1234) then
             begin
             Form2.Brak.Lines.Add(Data + ' ' + Czas3);
             Form8.Brak.Lines.Add('<span style="color:' + kolor_trujnik + ';">' + Data + ' ' + Czas3 + '.');

			       Form2.Brak.Lines.Add('Tempo_' + CurrToStr(kominek - stk) + '�C');
             Form8.Brak.Lines.Add('Tempo_' + CurrToStr(kominek - stk) + '�C.');

             Form2.Brak.Lines.Add('P�tla_ok _');
             Form8.Brak.Lines.Add('P�tla_ok _');
             Break;
             end;
            end;

            if ( C = z3 ) or ( C = z13) or ( C = z123) or ( C = z23) or ( C = z34) or ( C = z234) or ( C = z134) or ( C = z1234) then
            begin
            tr := 'Trujnik_Kominek';
            Label24.Caption := tr;
            trujnik_czek := 1;
            Form2.Brak.Lines.Add(tr + #13#10);
            Form8.Brak.Lines.Add(tr + '</span>..' + #13#10);
            end else
            begin
            tr := 'Trujnik_Kominrk_Error';
            Label24.Caption := tr;
            Form2.Brak.Lines.Add(Data + ' ' + Czas3);
            Form8.Brak.Lines.Add(Data + ' ' + Czas3 + '.');

            Form2.Brak.Lines.Add('Trujnik_Kominrk_Error' + #13#10);
            Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Trujnik_Kominrk_Error</span></span>..' + #13#10);
            end;
          end;
      end;

    C:=portreadb($378+1);
    if  (kominek < (piec_c - 3)) and (piec_c > (pomp - 3)) and (trujnik_czek = 1) and ((piec_c - stp) < 20) then
      begin
        SleepTime:=(400);

        portwriteb($378,$10);
        Sleep(SleepTime);
        portwriteb($378,$10);
        Sleep(SleepTime);
        portwriteb($378,$0);

          C:=portreadb($378+1);
          if ( C = z3 ) or ( C = z13) or ( C = z123) or ( C = z23) or ( C = z34) or ( C = z234) or ( C = z134) or ( C = z1234) then
          begin
          Stan4:= 'Brak_zejscia_z_czujnika_T\P';
          Label18.Caption:= Stan4;
		  PlaySound('Alarm2.wav', 0, SND_FILENAME);
          Form2.Brak.Lines.Add(Data + ' ' + Czas3);
          Form8.Brak.Lines.Add('<span style="color:' + kolor_trujnik + ';">' + Data + ' ' + Czas3 + '.');

		      Form2.Brak.Lines.Add('Tempo_' + CurrToStr(piec_c - stp) + '.');
          Form8.Brak.Lines.Add('Tempo_' + CurrToStr(piec_c - stp) + '.');

          Form2.Brak.Lines.Add('Brak_zejscia_z_czujnika_T\P' + #13#10);
          Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Brak_zejscia_z_czujnika_T\P</span></span>..' + #13#10);
          end else
          begin
            for st:=0 to 10 do
            begin
            portwriteb($378,$10);
            Sleep(SleepTime);
            portwriteb($378,$0);

            C:=portreadb($378+1);
            if ( C = z3 ) or ( C = z13) or ( C = z123) or ( C = z23) or ( C = z34) or ( C = z234) or ( C = z134) or ( C = z1234) then
             begin
             Form2.Brak.Lines.Add(Data + ' ' + Czas3);
             Form8.Brak.Lines.Add('<span style="color:' + kolor_trujnik + ';">' + Data + ' ' + Czas3 + '.');

			       Form2.Brak.Lines.Add('Tempo_' + CurrToStr(piec_c - stp) + '.');
             Form8.Brak.Lines.Add('Tempo_' + CurrToStr(piec_c - stp) + '.');

             Form2.Brak.Lines.Add('P�tla_ok_');
             Form8.Brak.Lines.Add('P�tla_ok_');
             Break;
             end;
            end;

            if ( C = z3 ) or ( C = z13) or ( C = z123) or ( C = z23) or ( C = z34) or ( C = z234) or ( C = z134) or ( C = z1234) then
            begin
            tr := 'Trujnik_Piec';
            Label24.Caption := tr;
            trujnik_czek := 0;
            Form2.Brak.Lines.Add(tr + #13#10);
            Form8.Brak.Lines.Add(tr + '</span>..' + #13#10);
            end else
            begin
            tr := 'Trujnik_Piec_Error';
            Label24.Caption := tr;
            Form2.Brak.Lines.Add(Data + ' ' + Czas3);
            Form8.Brak.Lines.Add(Data + ' ' + Czas3 + '.');

            Form2.Brak.Lines.Add('Trujnik_Piec_Error' + #13#10);
            Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Trujnik_Piec_Error</span></span>..' + #13#10);
            end;
          end;
      end;
   end;

if (mp = 0) then
    begin
    dolot := 'Otwarty';
    Label23.Caption:= dolot;
    end;

if (kominek >= (nk - hk)) then
begin
  dolot := 'Napalone';
  Label23.Caption:= dolot;
end;




if czek2 = 'ON' then
begin

       C:=portreadb($378+1);
       if ( ((kominek - pomp) >= hp) or ((piec_c > 65) and ((piec_c - stp) < 20))) and (mp = 0) and ((kominek - stk) < 20) then
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
         Form2.Brak.Lines.Add(Data + ' ' + Czas3);
         Form8.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

         Form2.Brak.Lines.Add('Pompa_ON_Kominek_' + CurrToStr(kominek) + '�C_0>>>1' + #13#10);
         Form8.Brak.Lines.Add('Pompa_ON_Kominek_' + CurrToStr(kominek) + '�C_0>>>1</span>..' + #13#10);
         end else
         begin
         Stan4:= 'Brak_zejscia_z_czujnika';
         Label18.Caption:= Stan4;
	       PlaySound('Alarm2.wav', 0, SND_FILENAME);
         dolot := 'Pompa_ON_Error';
         Label23.Caption:= dolot;
         Form2.Brak.Lines.Add(Data + ' ' + Czas3);
         Form8.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

         Form2.Brak.Lines.Add('Brak_zejscia_z_czujnika_Pompa_ON_Error_0' + #13#10);
         Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Brak_zejscia_z_czujnika_Pompa_ON_Error_0</span></span>..' + #13#10);
         end;
	      end;
       end;




       if (((kominek - pomp) <= 0) and (piec_c < 65)) and (mp = 1) and ((stk - kominek) < 20) then
       begin
         SleepTime:=(400);
         portwriteb($378,$80);
         Sleep(SleepTime);
         portwriteb($378,$0);

         C:=portreadb($378+1);
         if ( C = z4 ) or ( C = z14) or ( C = z24) or ( C = z34) or ( C = z234) or ( C = z124) or ( C = z134) or ( C = z1234) then
         begin
         dolot := 'Otwarty';
         Label23.Caption:= dolot;
         mp := 0;
         Form2.Brak.Lines.Add(Data + ' ' + Czas3);
         Form8.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

         Form2.Brak.Lines.Add(dolot + '_' + CurrToStr(kominek) + '�C_1>>>0' + #13#10);
         Form8.Brak.Lines.Add(dolot + '_' + CurrToStr(kominek) + '�C_1>>>0</span>..' + #13#10);
         end else
         begin
         Stan4:= 'Brak_zejscia_z_czujnika';
         Label18.Caption:= Stan4;
	     PlaySound('Alarm2.wav', 0, SND_FILENAME);
         dolot := 'Otwieranie_Error';
         Label23.Caption:= dolot;
         Form2.Brak.Lines.Add(Data + ' ' + Czas3);
         Form8.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

		     Form2.Brak.Lines.Add('Brak_zejscia_z_czujnika_Otwieranie_Error_1' + #13#10);
         Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Brak_zejscia_z_czujnika_Otwieranie_Error_1</span></span>..' + #13#10);
         end;
       end;


   if (((kominek > nk) and ((stk - kominek) <= 1)) or ((trujnik_czek = 0) and (kominek > 40))) or ((kominek > (nk - 10)) and ((kominek - stk) >= 5)) and ((kominek - stk) < 20) then
   begin
     if ( C = z4 ) or ( C = z14) or ( C = z24) or ( C = z34) or ( C = z234) or ( C = z124) or ( C = z134) or ( C = z1234) or (trujnik_czek = 0) then
     begin
      dolot := 'Zamkni�ty';
	  Label23.Caption:= dolot;
     end else
     begin
      if ((kominek - stk) >= 5) then
      calk3 := ((15 - (nk - kominek)) * (kominek - stk) * 10) else
      begin
      if ((kominek - nk) < 1) then calk := 1 else calk := kominek - nk;
      if ((kominek - stk) < 1) then calk2 := 1 else calk2 := kominek - stk;
      if ((calk2 * calk * 20) < 100) then calk3 := 100 else calk3 := calk2 * calk * 20;
      end;
      mp := 2;

      slep_s := IntToStr(Round(calk3));

      SleepTime:=Round(calk3);
      portwriteb($378,$40);
      Sleep(SleepTime);
      portwriteb($378,$40);
      Sleep(SleepTime);
      portwriteb($378,$0);

      C:=portreadb($378+1);
      if ( C = z4 ) or ( C = z14) or ( C = z24) or ( C = z34) or ( C = z234) or ( C = z124) or ( C = z134) or ( C = z1234) then
      begin
      dolot := 'Zamkni�ty';
	  Label23.Caption:= dolot;

      if trujnik_czek = 0 then
      begin
      Form2.Brak.Lines.Add(Data + ' ' + Czas3);
      Form8.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

      Form2.Brak.Lines.Add('Zamkni�ty_Awaryjnie_2' + #13#10);
      Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Zamkni�ty_Awaryjnie_2</span></span>..' + #13#10)
      end else
      begin
      Form2.Brak.Lines.Add(Data + ' ' + Czas3);
      Form8.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

      Form2.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C.');
      Form8.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C.');

      Form2.Brak.Lines.Add('Tempo_' + CurrToStr(kominek - stk) + '�C_S='+ slep_s + '_2' + #13#10);
      Form8.Brak.Lines.Add('Tempo_' + CurrToStr(kominek - stk) + '�C_S='+ slep_s + '_2</span>..' + #13#10);
      end;
      end else
      begin
      dolot := 'Zamykanie';
      Label23.Caption:= dolot;
      if trujnik_czek = 0 then
      begin
      Form2.Brak.Lines.Add(Data + ' ' + Czas3);
      Form2.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

      Form2.Brak.Lines.Add('Zamykanie_Awaryjnie_2' + #13#10);
      Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Zamykanie_Awaryjnie_2</span></span>..' + #13#10)
      end else
      begin
      Form2.Brak.Lines.Add(Data + ' ' + Czas3);
      Form8.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

      Form2.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C.');
      Form8.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C.');

      Form2.Brak.Lines.Add('Tempo_' + CurrToStr(kominek - stk) + '�C_S='+ slep_s + '_2' + #13#10);
      Form8.Brak.Lines.Add('Tempo_' + CurrToStr(kominek - stk) + '�C_S='+ slep_s + '_2</span>..' + #13#10);
      end;
      end;
	   end;
   end;



    if (kominek < (nk - hk)) and (mp = 2) and ((kominek - stk) < 0.5) and ((stk - kominek) < 20) then
    begin
      if ((nk - kominek) < 1) then calk := 1 else calk := nk - kominek;
      if ((stk - kominek) < 1) then calk2 := 1 else calk2 := stk - kominek;
      if ((calk2 * calk * 20) < 100) then calk3 := 100 else calk3 := calk2 * calk * 20;

      slep_s := IntToStr(Round(calk3));

      SleepTime:=Round(calk3);
      portwriteb($378,$80);
      Sleep(SleepTime);
      portwriteb($378,$80);
      Sleep(SleepTime);
      portwriteb($378,$0);

      C:=portreadb($378+1);
      if ( C = z4 ) or ( C = z14) or ( C = z24) or ( C = z34) or ( C = z234) or ( C = z124) or ( C = z134) or ( C = z1234) then
      begin

       if ((kominek - pomp) >= hp) then
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
           Form2.Brak.Lines.Add(Data + ' ' + Czas3);
           Form8.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

           Form2.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C.');
           Form8.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C.');

           Form2.Brak.Lines.Add('Tempo_' + CurrToStr(stk - kominek) + '�C_S='+ slep_s + '_2>>>1' + #13#10);
           Form8.Brak.Lines.Add('Tempo_' + CurrToStr(stk - kominek) + '�C_S='+ slep_s + '_2>>>1</span>..' + #13#10);
           end else
           begin
           Stan4:= 'Brak_zejscia_z_czujnika';
           Label18.Caption:= Stan4;
	       PlaySound('Alarm2.wav', 0, SND_FILENAME);
           dolot := 'Pompa_ON_Error';
           Label23.Caption:= dolot;
           Form2.Brak.Lines.Add(Data + ' ' + Czas3);
           Form8.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

           Form2.Brak.Lines.Add('Brak_zejscia_z_czujnika_Pompa_ON_Error_2' + #13#10);
           Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Brak_zejscia_z_czujnika_Pompa_ON_Error_2</span></span>..' + #13#10);
           end;

       end else
       begin
       dolot := 'Otwarty';
       Label23.Caption:= dolot;
       mp := 0;
       Form2.Brak.Lines.Add(Data + ' ' + Czas3);
       Form8.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

       Form2.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C.');
       Form8.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C.');

       Form2.Brak.Lines.Add('Tempo_' + CurrToStr(stk - kominek) + '�C_S='+ slep_s + '_2>>>0' + #13#10);
       Form8.Brak.Lines.Add('Tempo_' + CurrToStr(stk - kominek) + '�C_S='+ slep_s + '_2>>>0</span>..' + #13#10);
       end;

      end else
      begin
      dolot := 'Otwieranie';
      Label23.Caption:= dolot;
      Form2.Brak.Lines.Add(Data + ' ' + Czas3);
      Form8.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

      Form2.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C.');
      Form8.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C.');

      Form2.Brak.Lines.Add('Tempo_' + CurrToStr(stk - kominek) + '�C_S='+ slep_s + '_2</span>..' + #13#10);
      Form2.Brak.Lines.Add('Tempo_' + CurrToStr(stk - kominek) + '�C_S='+ slep_s + '_2</span>..' + #13#10);
      end;
    end;

end else
begin
 dolot := 'OFF';
 Label23.Caption:= dolot;
end;

  if (((kominek - piec_c) >= 25) and (mp <> 0)) then
    begin
      if ((kominek - stk) >= 5) then
      calk3 := ((15 - (nk - kominek)) * (kominek - stk) * 10) else
      begin
      if ((kominek - nk) < 1) then calk := 1 else calk := kominek - nk;
      if ((kominek - stk) < 1) then calk2 := 1 else calk2 := kominek - stk;
      if ((calk2 * calk * 20) < 100) then calk3 := 100 else calk3 := calk2 * calk * 20;
      end;
      mp := 2;

      slep_s := IntToStr(Round(calk3));

      SleepTime:=Round(calk3);
      portwriteb($378,$40);
      Sleep(SleepTime);
      portwriteb($378,$40);
      Sleep(SleepTime);
      portwriteb($378,$0);

      C:=portreadb($378+1);
      if ( C = z4 ) or ( C = z14) or ( C = z24) or ( C = z34) or ( C = z234) or ( C = z124) or ( C = z134) or ( C = z1234) then
      begin
      dolot := 'Awaryjnie zamkni�ty';
	  Label23.Caption:= dolot;
	  
      Form2.Brak.Lines.Add(Data + ' ' + Czas3);
      Form8.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

	    Form2.Brak.Lines.Add('Awaria czujnika dolotu.');
      Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Awaria czujnika dolotu.');

      Form2.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C');
      Form8.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C</span>.');

      Form2.Brak.Lines.Add('Tempo_' + CurrToStr(kominek - stk) + '�C_S='+ slep_s + '_2' + #13#10);
      Form8.Brak.Lines.Add('Tempo_' + CurrToStr(kominek - stk) + '�C_S='+ slep_s + '_2</span>..' + #13#10);
      end else
      begin
      dolot := 'Awaryjne zamykanie';
      Label23.Caption:= dolot;

	    Form2.Brak.Lines.Add(Data + ' ' + Czas3);
      Form8.Brak.Lines.Add('<span style="color:' + kolor_kominek + ';">' + Data + ' ' + Czas3 + '.');

	    Form2.Brak.Lines.Add('Awaria czujnika dolotu.');
      Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Awaria czujnika dolotu.');

      Form2.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C');
      Form8.Brak.Lines.Add(dolot + '_Kominek_' + CurrToStr(kominek) + '�C</span>.');

      Form2.Brak.Lines.Add('Tempo_' + CurrToStr(kominek - stk) + '�C_S='+ slep_s + '_2' + #13#10);
      Form8.Brak.Lines.Add('Tempo_' + CurrToStr(kominek - stk) + '�C_S='+ slep_s + '_2</span>..' + #13#10);
      end;
	end;

  stk := kominek;
  stp := piec_c;

  ruznica1 :=  reg_c - salon_c;

  if ruznica1 < 0 then ruznica1 := (ruznica1 * 2);

  if ruznica1 <= -4 then ruznica1 := -4;

  if ruznica1 >= 4 then ruznica1 := 4;

  if dwor_r >= 5 then nastawa_w := 0;
  if dwor_r < 5 then nastawa_w := 0.21;
  if dwor_r < 4 then nastawa_w := 0.42;
  if dwor_r < 3 then nastawa_w := 0.63;
  if dwor_r < 2 then nastawa_w := 0.84;
  if dwor_r < 1 then nastawa_w := 1.05;
  if dwor_r < 0 then nastawa_w := 1.26;
  if dwor_r < -1 then nastawa_w := 1.47;
  if dwor_r < -2 then nastawa_w := 1.68;
  if dwor_r < -3 then nastawa_w := 1.89;
  if dwor_r < -4 then nastawa_w := 2.1;
  if dwor_r < -5 then nastawa_w := 2.31;
  if dwor_r < -6 then nastawa_w := 2.52;
  if dwor_r < -7 then nastawa_w := 2.73;
  if dwor_r < -8 then nastawa_w := 2.94;
  if dwor_r < -9 then nastawa_w := 3.15;
  if dwor_r < -10 then nastawa_w := 3.36;
  if dwor_r < -11 then nastawa_w := 3.57;
  if dwor_r < -12 then nastawa_w := 3.78;
  if dwor_r < -13 then nastawa_w := 3.99;
  if dwor_r < -14 then nastawa_w := 4.2;
  if dwor_r < -15 then nastawa_w := 4.41;
  if dwor_r < -16 then nastawa_w := 4.62;
  if dwor_r < -17 then nastawa_w := 4.83;
  if dwor_r < -18 then nastawa_w := 5.04;
  if dwor_r < -19 then nastawa_w := 5.25;
  if dwor_r < -20 then nastawa_w := 5.46;

  nastawa_k := NASTAWA_M + utrata_c + nastawa_w + (ruznica1 / 2);

  ruznica2 := zasilanie_r - nastawa_k;

  ruznica3 := piec_c - nastawa_k;

  nastawa_s:=floattostrf(nastawa_k,ffFixed,5,2);

  Label7.Caption := nastawa_s;

  Stan:=portreadb($378+1);



  if ( Stan = z12 ) or ( Stan = z123 ) or ( Stan = z23 ) or ( Stan = z2 ) or ( Stan = z24 )or ( Stan = z234 )or ( Stan = z124 )or ( Stan = z1234 ) then
  begin
   Stans := 'Pusto';
   Label8.Caption := Stans;
  end else
  begin
   Stans := 'OK';
   Label8.Caption:= Stans;
  end;

  Stan2:= 0;
  Stan3:= ' ';
  Stan4:= ' ';
  Stan2s:= ' ';

   If czek1 = 'OFF' then
   begin
   Stan2s := 'OFF';
   Label25.Caption := Stan2s;
   end else
   begin
   Stan2s := '';
   Label25.Caption := Stan2s;
   end;

  if obraz = 0 then Image2.Picture.LoadFromFile('pusto.jpg') else Image2.Picture.LoadFromFile('pusto_noc.jpg');

  if (ruznica2 <= -histereza) and (ruznica1 > 0) and (piec_c > granica) and (czek1 = 'ON') and ((piec_c - stp) < 20) then
   begin
	  if ruznica3 >= 1 then
	  begin
	    SleepTime:=(60);
		  begin
			portwriteb($378,$1);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$4);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$2);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$8);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$1);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$4);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$2);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$8);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$1);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$4);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$2);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$8);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$1);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$4);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$2);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$8);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$1);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$4);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$2);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$8);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$0);
      bar := bar + 1; ProgressBar2.Position := bar;
	      end;

	    C:=portreadb($378+1);

	if ( C = z1 ) or ( C = z12 ) or ( C = z13 ) or ( C = z123 ) or ( C = z14 ) or ( C = z124 ) or ( C = z134 ) or ( C = z1234 ) then
	  begin
        Stan4:= 'Brak_zejscia_z_czujnika_odkr�canie';
        Label18.Caption:= Stan4;
	    PlaySound('Alarm2.wav', 0, SND_FILENAME);
		Form2.Brak.Lines.Add(Data + ' ' + Czas3);
    Form8.Brak.Lines.Add('<span style="color:' + kolor_podloga + ';">' + Data + ' ' + Czas3 + '.');

		Form2.Brak.Lines.Add('Pod�oga_' + CurrToStr(zasilanie_r) + '�C');
    Form8.Brak.Lines.Add('Pod�oga_' + CurrToStr(zasilanie_r) + '�C.');

    Form2.Brak.Lines.Add('Brak_zejscia_z_czujnika_odkr�canie' + #13#10);
    Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Brak_zejscia_z_czujnika_odkr�canie</span></span>..' + #13#10);
	  end else
    begin
     Stan4:= ' ';
     Label18.Caption:= Stan4;
     Form2.Brak.Lines.Add(Data + ' ' + Czas3);
     Form8.Brak.Lines.Add('<span style="color:' + kolor_podloga + ';">' + Data + ' ' + Czas3 + '.');

	   Form2.Brak.Lines.Add('Pod�oga_' + CurrToStr(zasilanie_r) + '�C.');
     Form8.Brak.Lines.Add('Pod�oga_' + CurrToStr(zasilanie_r) + '�C.');

     Form2.Brak.Lines.Add('Zejscie_z_czujnika_odkr�canie. ');
     Form8.Brak.Lines.Add('Zejscie_z_czujnika_odkr�canie. ');
	    for s:=0 to 80 do
      begin
			portwriteb($378,$1);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$4);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$2);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$8);
      bar := bar + 1; ProgressBar2.Position := bar;
			Sleep(SleepTime);
			portwriteb($378,$0);
      bar := bar + 1; ProgressBar2.Position := bar;

			B:=portreadb($378+1);

       if ( B = z1 ) or ( B = z12 ) or ( B = z13 ) or ( B = z123 ) or ( B = z14 ) or ( B = z124 ) or ( B = z134 ) or ( B = z1234 ) then
       begin
       Form2.Brak.Lines.Add('P�tla_ok_odkr�canie' + #13#10);
       Form8.Brak.Lines.Add('P�tla_ok_odkr�canie</span>..' + #13#10);
       licz_o := licz_o + 1;
       licz_z := 0;
       Break;
       end;
	   end;
    end;

	 if ( B <> z1 ) and ( B <> z12 ) and ( B <> z13 ) and ( B <> z123 ) and ( B <> z14 ) and ( B <> z124 ) and ( B <> z134 ) and ( B <> z1234 ) then
	 begin
      if obraz = 0 then
        begin
	     Image2.Picture.LoadFromFile('gora_err.jpg');
	     Stan2:= 1;
         Stan2s:= '&#8593;!';
         Form2.Brak.Lines.Add('Odkr�canie_Error' + #13#10);
         Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Odkr�canie_Error</span></span>..' + #13#10);
        end else
        begin
       Image2.Picture.LoadFromFile('gora_err_noc.jpg');
	     Stan2:= 1;
       Stan2s:= '&#8593;!';
       Form2.Brak.Lines.Add('Odkr�canie_Error' + #13#10);
       Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Odkr�canie_Error</span></span>..' + #13#10);
        end;
	 end else
	 begin
      if obraz = 0 then
        begin
	     Image2.Picture.LoadFromFile('gora.jpg');
         Stan2:= 2;
         Stan2s:= '&#8593;';
        end else
        begin
        Image2.Picture.LoadFromFile('gora_noc.jpg');
        Stan2:= 2;
        Stan2s:= '&#8593;';
        end;
	 end;
	end;
   end;



 if (ruznica2 >= histereza) and (czek1 = 'ON') and (piec_c > granica) and ((piec_c - stp) < 20) then
 begin
	if ruznica3 >= 1 then
	begin
	 SleepTime:=(60);

  	 begin
      portwriteb($378,$8);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$2);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$4);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$1);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$8);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$2);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$4);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$1);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$8);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$2);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$4);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$1);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$8);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$2);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$4);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$1);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$8);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$2);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$4);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$1);
      bar := bar + 1; ProgressBar2.Position := bar;
      Sleep(SleepTime);
      portwriteb($378,$0);
      bar := bar + 1; ProgressBar2.Position := bar;
	 end;
	
	  C:=portreadb($378+1);

	  if ( C = z1 ) or ( C = z12 ) or ( C = z13 ) or ( C = z123 ) or ( C = z14 ) or ( C = z124 ) or ( C = z134 ) or ( C = z1234 ) then
    begin
        Stan4:= 'Brak_zejscia_z_czujnika_przykr�canie';
        Label18.Caption:= Stan4;
		    PlaySound('Alarm2.wav', 0, SND_FILENAME);
        Form2.Brak.Lines.Add(Data + ' ' + Czas3);
        Form8.Brak.Lines.Add('<span style="color:' + kolor_podloga + ';">' + Data + ' ' + Czas3 + '.');

	    	Form2.Brak.Lines.Add('Pod�oga_' + CurrToStr(zasilanie_r) + '�C');
        Form8.Brak.Lines.Add('Pod�oga_' + CurrToStr(zasilanie_r) + '�C.');

        Form2.Brak.Lines.Add(Stan4 + #13#10);
        Form8.Brak.Lines.Add(Stan4 + '</span>..' + #13#10);

		end else
    begin
         Stan4:= ' ';
         Label18.Caption:= Stan4;
         Form2.Brak.Lines.Add(Data + ' ' + Czas3);
         Form8.Brak.Lines.Add('<span style="color:' + kolor_podloga + ';">' + Data + ' ' + Czas3 + '.');

		     Form2.Brak.Lines.Add('Pod�oga_' + CurrToStr(zasilanie_r) + '�C');
         Form8.Brak.Lines.Add('Pod�oga_' + CurrToStr(zasilanie_r) + '�C.');

         Form2.Brak.Lines.Add('Zejscie_z_czujnika_przykr�canie. ');
         Form8.Brak.Lines.Add('Zejscie_z_czujnika_przykr�canie. ');
         for s:=0 to 80 do

	      begin
            portwriteb($378,$8);
            bar := bar + 1; ProgressBar2.Position := bar;
            Sleep(SleepTime);
            portwriteb($378,$2);
            bar := bar + 1; ProgressBar2.Position := bar;
            Sleep(SleepTime);
            portwriteb($378,$4);
            bar := bar + 1; ProgressBar2.Position := bar;
            Sleep(SleepTime);
            portwriteb($378,$1);
            bar := bar + 1; ProgressBar2.Position := bar;
            Sleep(SleepTime);
            portwriteb($378,$0);
            bar := bar + 1; ProgressBar2.Position := bar;

            B:=portreadb($378+1);

            if ( B = z1 ) or ( B = z12 ) or ( B = z13 ) or ( B = z123 ) or ( B = z14 ) or ( B = z124 ) or ( B = z134 ) or ( B = z1234 ) then
            begin
            Form2.Brak.Lines.Add('P�tla_ok_przykr�canie' + #13#10);
            Form8.Brak.Lines.Add('P�tla_ok_przykr�canie</span>..' + #13#10);
            licz_z := licz_z + 1;
            licz_o := 0;
            Break;
	          end;
        end;
    end;

	      if ( B <> z1 ) and ( B <> z12 ) and ( B <> z13 ) and ( B <> z123 ) and ( B <> z14 ) and ( B <> z124 ) and ( B <> z134 ) and ( B <> z1234 ) then
	      begin
           if obraz = 0 then
             begin
	          Image2.Picture.LoadFromFile('dol_err.jpg');
	          Stan2:= 3;
            Stan2s:= '&#8595;!';
            Form2.Brak.Lines.Add('Przykr�canie Error' + #13#10);
            Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Przykr�canie Error</span>..' + #13#10);
             end else
             begin
            Image2.Picture.LoadFromFile('dol_err_noc.jpg');
	          Stan2:= 3;
            Stan2s:= '&#8595;!';
            Form2.Brak.Lines.Add('Przykr�canie Error' + #13#10);
            Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Przykr�canie Error</span>..' + #13#10);
             end;
	      end else
	      begin
           if obraz = 0 then
             begin
	          Image2.Picture.LoadFromFile('dol.jpg');
	          Stan2:= 4;
            Stan2s:= '&#8595;';
             end else
             begin
            Image2.Picture.LoadFromFile('dol_noc.jpg');
	          Stan2:= 4;
            Stan2s:= '&#8595;';
             end;
	      end;
  	end;
  end;

  skok := piec_c - stp;
  skok2 := kominek - stk;

  if (piec_c >= 70) then
   begin
    Label17.Caption:= 'ALARM';
   	PlaySound('Alarm.wav', 0, SND_FILENAME);
  	Stan3:= 'Alarm_P';
    Form2.Brak.Lines.Add(Data + ' ' + Czas3);
    Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">' + Data + ' ' + Czas3 + '.');

    Form2.Brak.Lines.Add(Stan3 + '_' + CurrToStr(piec_c) + '�C_Skok_' + CurrToStr(skok) + #13#10);
    Form8.Brak.Lines.Add(Stan3 + '_' + CurrToStr(piec_c) + '�C_Skok_' + CurrToStr(skok) + '</span>..' + #13#10);
   end;

   if (kominek >= 70) then
   begin
    Label17.Caption:= 'ALARM';
   	PlaySound('Alarm.wav', 0, SND_FILENAME);
  	Stan3:= 'Alarm_K';
    Form2.Brak.Lines.Add(Data + ' ' + Czas3);
    Form8.Brak.Lines.Add('<span style="color:' + kolor_podloga + ';">' + Data + ' ' + Czas3 + '.');

    Form2.Brak.Lines.Add(Stan3 + '_' + CurrToStr(kominek) + '�C_Skok_' + CurrToStr(skok2) + #13#10);
    Form8.Brak.Lines.Add(Stan3 + '_' + CurrToStr(kominek) + '�C_Skok_' + CurrToStr(skok2) + '</span>..' + #13#10);
   end;


  if (licz_o = 15) then
  begin
  Form2.Brak.Lines.Add(Data + ' ' + Czas3);
  Form8.Brak.Lines.Add('<span style="color:' + kolor_podloga + ';">' + Data + ' ' + Czas3 + '.');

  Form2.Brak.Lines.Add('Pod�oga_' + CurrToStr(zasilanie_r) + '�C.');
  Form8.Brak.Lines.Add('Pod�oga_' + CurrToStr(zasilanie_r) + '�C.');

  Form2.Brak.Lines.Add('Odkr�canie_15x_Podloga_OFF' + #13#10);
  Form8.Brak.Lines.Add('<span style="color:' + kolor_alarm + ';">Odkr�canie_15x_Podloga_OFF</span></span>..' + #13#10);
  czek1 := 'OFF';
  licz_o := 0;
  end;

  if (licz_z = 15) then
  begin
  Form2.Brak.Lines.Add(Data + ' ' + Czas3);
  Form8.Brak.Lines.Add('<span style="color:' + kolor_podloga + ';">' + Data + ' ' + Czas3 + '.');

  Form2.Brak.Lines.Add('Pod�oga_' + CurrToStr(zasilanie_r) + '�C.');
  Form8.Brak.Lines.Add('Pod�oga_' + CurrToStr(zasilanie_r) + '�C.');

  Form2.Brak.Lines.Add('Przykr�canie_15x_Podloga_OFF' + #13#10);
  Form8.Brak.Lines.Add('<span style="color:' + kolor_podloga + ';">Przykr�canie_15x_Podloga_OFF</span></span>..' + #13#10);
  czek1 := 'OFF';
  licz_z := 0;
  end;

  CiglaName:=ExtractFileDir(application.exename);
  CiglaName:=CiglaName+'\Cigla.ini';

   INI := TINIFile.Create(CiglaName);
   try
	 INI.WriteInteger('Odczyt', 'Sterownik', Stan2 );
     INI.WriteInteger('Odczyt', 'Wygaszanie', wygaszanie2 );
     if (piec_z = 1) then INI.WriteFloat('Odczyt', 'Piec', piec_c );
     if (piec_z = 2) then INI.WriteFloat('Odczyt', 'Piec', 48.00 );
     INI.WriteInteger('Odczyt', 'mp', mp );
     INI.WriteInteger('Odczyt', 'trujnik_czek', trujnik_czek );
     INI.WriteFloat('Odczyt', 'stk', stk );
     INI.WriteFloat('Odczyt', 'stp', stp );
     INI.WriteString('Ustawienia', 'podloga', czek1);
   finally
	 INI.Free;
   end;

  text_error := '';
  text_servis := '';

  for sp := 0 to Form2.Brak.Lines.Count - 1 do
  begin
  if Pos('Brak_zejscia_z_czujnika_T/K', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Trujnik_Kominrk_Error' , Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Brak_zejscia_z_czujnika_T\P', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Trujnik_Piec_Error', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Brak_zejscia_z_czujnika_0', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Pompa_ON_Error', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Brak_zejscia_z_czujnika_1', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Otwieranie_Error', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Brak_zejscia_z_czujnika_2', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Brak_zejscia_z_czujnika_odkr�canie', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Odkr�canie_Error', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Brak_zejscia_z_czujnika_przykr�canie', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Przykr�canie Error', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Alarm.', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Awaria czujnika dolotu.', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  if Pos('Awaria czujnika dolotu.', Form8.Brak.Lines.Strings[sp]) > 0 then text_error := text_error + Form8.Brak.Lines[sp];
  end;

  text_error := StringReplace(text_error, '.', '<br>',[rfReplaceAll, rfIgnoreCase]);
  text_servis := StringReplace(Form8.Brak.Text, '.', '<br>',[rfReplaceAll, rfIgnoreCase]);



  if Form5.HTTPServer.Active then Form5.HTTPServer.Active := false;

  HTML := '<html><head><title>Marek Bartocha</title></head><body><head><meta http-equiv="Refresh" content="180" /></head>' +
          '<meta http-equiv="Content-type" content="text/html; charset=iso-8859-2">' +
          '<div style="position: absolute; left: 345px;"><img src="domek.jpg" width="880" alt="Aktualizuje si�" /></div>' +
          '<div style="position: absolute; left: 550px; top:100px"><a style="color: Black" href="mbnoc.html"><big><big><big>Kolor Noc</big></big></big></a></div>' +
          '<div style="position: absolute; left: 595px; top:330px;"><big>' + Stans + '</big></div>' +
          '<div style="position: absolute; left: 865px; top:300px;"><big><big><big>' + sypialnia_s + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 685px; top:435px;"><big>' + nastawa_s + '�C</big></div>' +
          '<div style="position: absolute; left: 865px; top:435px;"><big>' + CurrToStr(reg_c) + ' �C</big></div>' +
          '<div style="position: absolute; left: 650px; top:490px;"><big><big><big>' + CurrToStr(zasilanie_r) + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 930px; top:490px;"><big><big><big>' + CurrToStr(salon_c) + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 650px; top:620px;"><big><big><big>' + CurrToStr(piec_c) + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 617px; top:590px;"><big><big><big>' + wygaszanie_s + '</big></big></big></div>' +
          '<div style="position: absolute; left: 930px; top:620px;"><big><big><big>' + woda_s + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 465px; top:170px;"><big><big><big>' + CurrToStr(dwor_r) + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 645px; top:460px;"><big><big><big>' + Stan2s + '</big></big></big></div>' +
          '<div style="position: absolute; left: 960px; top:100px;"><big><big><big>' + Czas3 + '</big></big></big></div>' +
          '<div style="position: absolute; left: 635px; top:590px; color: red;"><big><big><big>' + Stan3 + '</big></big></big></div>' +
          '<div style="position: absolute; left: 10px; top:10px;"><a style="color: Black" href="Aktualny_wykres.' + Data + '.html"><big><big><big>Aktualny_Wykres</big></big></big></a></div>' +
          '<div style="position: absolute; left: 1270px; top:10px;"><a style="color: Black" href="Wczorajszy_wykres.' + Data_Wstecz + '.html"><big><big><big>Wczorajszy_Wykres</big></big></big></a></div>' +
          '<div style="position: absolute; left: 950px; top:420px;"><button type="button" value="Refresh Page" onClick="location.href=location.href"><h3>Odswie�</h3></button>' +
          '<div style="position: absolute; left: 200px; top:10px;"><big><big><big>Kominek</big></big></big></div>' +
          '<div style="position: absolute; left: 200px; top:40px;"><big><big><big>' + dolot + '</big></big></big></div>' +
          '<div style="position: absolute; left: 200px; top:70px;"><big><big><big>' + CurrToStr(kominek) + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 200px; top:100px;"><big><big><big>' + tr + '</big></big></big></div>' +
          '<div style="position: absolute; left: 200px; top:130px;"><a style="color: Black" href="servisdzien.html"><big><big><big>Rejestr</big></big></big></a></div>' +
          '<div style="position: absolute; left: -500px; top:360px;"><big><big><big style="color: red">' + text_error + '</big></big></big></div>';
  AssignFile(TF, IndexName);
  ReWrite(TF);
  Writeln(TF, HTML);
  CloseFile(TF);

  HTML := '<html><head><title>Marek Bartocha</title></head><body><head><meta http-equiv="Refresh" content="180" /></head>' +
          '<meta http-equiv="Content-type" content="text/html; charset=iso-8859-2">' +
          '<style type="text/css">body {background-color: DimGray;} </style>' +
          '<div style="position: absolute; left: 10px; top:10px; "><big><big><big>' + text_servis + '</big></big></big></div>';
  AssignFile(TF, Index_ServisName);
  ReWrite(TF);
  Writeln(TF, HTML);
  CloseFile(TF);


  HTML := '<html><head><title>Marek Bartocha</title></head><body><head><meta http-equiv="Refresh" content="180" /></head>' +
          '<meta http-equiv="Content-type" content="text/html; charset=iso-8859-2">' +
          '<style type="text/css">body {background-color: Black;} </style>' +
          '<div style="position: absolute; left: 345px;"><img src="domek_noc.jpg" width="880" alt="Aktualizuje si�" /></div>' +
          '<div style="position: absolute; left: 550px; top:100px"><a style="color: white" href="mbdzien.html"><big><big><big>Kolor Dzie�</big></big></big></a></div>' +
          '<div style="position: absolute; left: 595px; top:330px;"><big style="color: white">' + Stans + '</big></div>' +
          '<div style="position: absolute; left: 865px; top:300px;"><big><big><big style="color: white">' + sypialnia_s + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 685px; top:435px;"><big style="color: white">' + nastawa_s + '�C</big></div>' +
          '<div style="position: absolute; left: 865px; top:435px;"><big style="color: white">' + CurrToStr(reg_c) + '�C</big></div>' +
          '<div style="position: absolute; left: 650px; top:490px;"><big><big><big style="color: white">' + CurrToStr(zasilanie_r) + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 930px; top:490px;"><big><big><big style="color: white">' + CurrToStr(salon_c) + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 650px; top:620px;"><big><big><big style="color: white">' + CurrToStr(piec_c) + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 617px; top:590px;"><big><big><big style="color: white">' + wygaszanie_s + '</big></big></big></div>' +
          '<div style="position: absolute; left: 930px; top:620px;"><big><big><big style="color: white">' + woda_s + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 465px; top:170px;"><big><big><big style="color: white">' + CurrToStr(dwor_r) + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 645px; top:460px;"><big><big><big style="color: white">' + Stan2s + '</big></big></big></div>' +
          '<div style="position: absolute; left: 960px; top:100px;"><big><big><big style="color: white">' + Czas3 + '</big></big></big></div>' +
          '<div style="position: absolute; left: 635px; top:590px; color: red;"><big><big><big style="color: white">' + Stan3 + '</big></big></big></div>' +
          '<div style="position: absolute; left: 10px; top:10px;"><a style="color: white" href="Aktualny_wykres_noc.' + Data + '.html"><big><big><big>Aktualny_Wykres</big></big></big></a></div>' +
          '<div style="position: absolute; left: 1270px; top:10px;"><a style="color: white" href="Wczorajszy_wykres_noc.' + Data_Wstecz + '.html"><big><big><big>Wczorajszy_Wykres </big></big></big></a></div>' +
          '<div style="position: absolute; left: 950px; top:420px;"><button style="color:green" type="button" value="Refresh Page" onClick="location.href=location.href"><h3>Odswie�</h3></button>' +
          '<div style="position: absolute; left: 200px; top:10px;"><big><big><big style="color: white">Kominek</big></big></big></div>' +
          '<div style="position: absolute; left: 200px; top:40px;"><big><big><big style="color: white">' + dolot + '</big></big></big></div>' +
          '<div style="position: absolute; left: 200px; top:70px;"><big><big><big style="color: white">' + CurrToStr(kominek) + '�C</big></big></big></div>' +
          '<div style="position: absolute; left: 200px; top:100px;"><big><big><big style="color: white">' + tr + '</big></big></big></div>' +
          '<div style="position: absolute; left: 200px; top:130px;"><a style="color: white" href="servisnoc.html"><big><big><big>Rejestr</big></big></big></a></div>' +
          '<div style="position: absolute; left: -500px; top:360px;"><big><big><big style="color: red">' + text_error + '</big></big></big></div>';
  AssignFile(TF, Index_NocName);
  ReWrite(TF);
  Writeln(TF, HTML);
  CloseFile(TF);

  HTML := '<html><head><title>Marek Bartocha</title></head><body><head><meta http-equiv="Refresh" content="180" /></head>' +
          '<meta http-equiv="Content-type" content="text/html; charset=iso-8859-2">' +
          '<style type="text/css">body {background-color: Black;} </style>' +
          '<div style="position: absolute; left: 10px; top:10px;"><big><big><big style="color: white">' + text_servis + '</big></big></big></div>';
  AssignFile(TF, Index_ServisNocName);
  ReWrite(TF);
  Writeln(TF, HTML);
  CloseFile(TF);

  HTML := '<html><head><title>Marek Bartocha</title></head><body><head><meta http-equiv="Refresh" content="180" /></head>' +
          '<style type="text/css">body {background-color: Black;}</style>' +
          '<img src="' + Data + '.jpg" width="1520" height="730"/>';

  AssignFile(TF, Aktualny_wykres_noc);
  ReWrite(TF);
  Writeln(TF, HTML);
  CloseFile(TF);

  if FileExists (Wstecz_WykresName) then
  begin
  HTML := '<html><head><title>Marek Bartocha</title></head><body><head><meta http-equiv="Refresh" content="180" /></head>' +
          '<style type="text/css">body {background-color: Black;}</style>' +
          '<img src="' + Data_Wstecz + '.jpg" width="1520" height="730"/>';
  end else
  begin
  HTML := '<html><head><title>Marek Bartocha</title></head><body><head><meta http-equiv="Refresh" content="180" /></head>' +
          '<style type="text/css">body {background-color: Black;}</style>';
  end;

  AssignFile(TF, Wczorajszy_wykres_noc);
  ReWrite(TF);
  Writeln(TF, HTML);
  CloseFile(TF);

  HTML := '<html><head><title>Marek Bartocha</title></head><body><head><meta http-equiv="Refresh" content="180" /></head>' +
          '<img src="' + Data + '.jpg" width="1520" height="730"/>';

  AssignFile(TF, Aktualny_wykres);
  ReWrite(TF);
  Writeln(TF, HTML);
  CloseFile(TF);

  if FileExists (Wstecz_WykresName) then
  begin
  HTML := '<html><head><title>Marek Bartocha</title></head><body><head><meta http-equiv="Refresh" content="180" /></head>' +
          '<img src="' + Data_Wstecz + '.jpg" width="1520" height="730"/>';
  end else
  begin
  HTML := '<html><head><title>Marek Bartocha</title></head><body><head><meta http-equiv="Refresh" content="180" /></head>';
  end;

  AssignFile(TF, Wczorajszy_wykres);
  ReWrite(TF);
  Writeln(TF, HTML);
  CloseFile(TF);

 ProgressBar1.Position := 0;
 ProgressBar2.Position := 0;
 bar := 0;

 if kolorek = 0 then
 begin

  if obraz =0 then
  begin
   Image1.Picture.LoadFromFile('Domek.jpg');
   Color := ClWhite;
   Label1.Font.Color := ClBlack;
   Label2.Font.Color := ClBlack;
   Label3.Font.Color := ClBlack;
   Label4.Font.Color := ClBlack;
   Label5.Font.Color := ClBlack;
   Label6.Font.Color := ClBlack;
   Label7.Font.Color := ClBlack;
   Label9.Font.Color := ClBlack;
   Label10.Font.Color := ClBlack;
   Label11.Font.Color := ClBlack;
   Label12.Font.Color := ClBlack;
   Label13.Font.Color := ClBlack;
   Label14.Font.Color := ClBlack;
   Label15.Font.Color := ClBlack;
   Label16.Font.Color := ClBlack;
   Label17.Font.Color := ClBlack;
   Label19.Font.Color := ClBlack;
   Label20.Font.Color := ClBlack;
   Label21.Font.Color := ClBlack;
   Label22.Font.Color := ClBlack;
   Label23.Font.Color := ClBlack;
   Label24.Font.Color := ClBlack;
   Label25.Font.Color := ClBlack;
   Edit1.Font.Color := ClBlack;
   Edit1.Color := ClWhite;
  end else
  begin
   Image1.Picture.LoadFromFile('Domek_noc.jpg');
   Color := ClBlack;
   Label1.Font.Color := ClWhite;
   Label2.Font.Color := ClWhite;
   Label3.Font.Color := ClWhite;
   Label4.Font.Color := ClWhite;
   Label5.Font.Color := ClWhite;
   Label6.Font.Color := ClWhite;
   Label7.Font.Color := ClWhite;
   Label9.Font.Color := ClWhite;
   Label10.Font.Color := ClWhite;
   Label11.Font.Color := ClWhite;
   Label12.Font.Color := ClWhite;
   Label13.Font.Color := ClWhite;
   Label14.Font.Color := ClWhite;
   Label15.Font.Color := ClWhite;
   Label16.Font.Color := ClWhite;
   Label17.Font.Color := ClWhite;
   Label19.Font.Color := ClWhite;
   Label20.Font.Color := ClWhite;
   Label21.Font.Color := ClWhite;
   Label22.Font.Color := ClWhite;
   Label23.Font.Color := ClWhite;
   Label24.Font.Color := ClWhite;
   Label25.Font.Color := ClWhite;
   Edit1.Font.Color := ClWhite;
   Edit1.Color := ClBlack;
  end;

 kolorek:= 1;
 end;

  h:= 0;
  m:= 0;
  g:= 0;
  idn:= 0;

 Czas := FormatDateTime('h:m', Time);

 Czas2:= IntToStr(h) + ':' + IntToStr(m);

  while Czas <> Czas2 do
  begin
   m := m + 1;
   g := g + 1;

   if m > 59 then
   begin
   m:= 0;
   h:= h + 1;
   end;

   if g = 3 then
   begin
    g := 0;
    idn := idn + 0.05;
   end;

   Czas2:= IntToStr(h) + ':' + IntToStr(m);

  end;

  if not FileExists (WykresName) then
  begin
  Form3.Series1.Clear;
  Form3.Series2.Clear;
  Form3.Series3.Clear;
  Form3.Series4.Clear;
  Form3.Series5.Clear;
  Form3.Series6.Clear;
  end;

  Form3.Series1.AddXY(idn, salon_c);
  Form3.Series2.AddXY(idn, dwor_r);
  Form3.Series3.AddXY(idn, piec_c);
  Form3.Series4.AddXY(idn, StrToCurr(woda_s));
  Form3.Series5.AddXY(idn, StrToCurr(sypialnia_s));
  Form3.Series6.AddXY(idn, kominek);
  
  BMP := TBitmap.Create;
  JPG := TJPEGImage.Create;

  Form3.Chart1.SaveToBitmapFile(BMPName);
  BMP.LoadFromFile(BMPName);
  JPG.CompressionQuality := 100;
  JPG.Assign(BMP);
  JPG.SaveToFile(WykresName);
  JPG.Free;
  BMP.Free;

  DeleteFile(DelWykresName);
  DeleteFile('Aktualny_wykres.' + Data_Wstecz + '.html');
  DeleteFile('Aktualny_wykres_noc.' + Data_Wstecz + '.html');

  DeleteFile('Wczorajszy_wykres.' + Del_Data + '.html');
  DeleteFile('Wczorajszy_wykres_noc.' + Del_Data + '.html');

  if Form5.cbActive.Checked = True then Form5.HTTPServer.Active := true;

  if serv = 0 then
  begin
  Form5.cbActive.Checked := true;
  serv := 1;
  end;

  Form6.Image1.Picture.LoadFromFile(WykresName);

  if FileExists (Wstecz_WykresName) then  Form7.Image1.Picture.LoadFromFile(Wstecz_WykresName);

end;

procedure TForm1.Button1Click(Sender: TObject);
 begin
  CiglaName:=ExtractFileDir(application.exename);
  CiglaName:=CiglaName+'\Cigla.ini';

    INI := TINIFile.Create(CiglaName);
	  try
     utrata_c := StrToCurr(INI.ReadString('Ustawienia', 'Utrata Ciepla', '-1'));
     histereza := StrToCurr(INI.ReadString('Ustawienia', 'Histereza', '0,5'));
     Ia := StrToInt(INI.ReadString('Ustawienia', 'Aktualizacja co', '180'));
     pomp := StrToInt(INI.ReadString('Ustawienia', 'Start Pompa', '35'));
     nk := StrToInt(INI.ReadString('Ustawienia', 'nastawa', '50'));
     hk := StrToInt(INI.ReadString('Ustawienia', 'nastawa_h', '2'));
     hp := StrToInt(INI.ReadString('Ustawienia', 'nastawa_h_p', '2'));

     ch1 := INI.ReadString('Ustawienia', 'podloga', 'OFF');
     ch2 := INI.ReadString('Ustawienia', 'kominek', 'OFF');
     ch3 := INI.ReadString('Ustawienia', 'zawor', 'OFF');

     z0 := StrToInt(INI.ReadString('Control', 'Stan Rozwarty', '0'));
     z1 := StrToInt(INI.ReadString('Control', 'Sterownik Podloga', '0'));
     z2 := StrToInt(INI.ReadString('Control', 'Kontrolka Zbiornik', '0'));
     z3 := StrToInt(INI.ReadString('Control', 'Sterownik Trujnik', '0'));
     z4 := StrToInt(INI.ReadString('Control', 'Sterownik Kominek', '0'));

     z12 := StrToInt(INI.ReadString('Control', '1+2', '0'));
     z13 := StrToInt(INI.ReadString('Control', '1+3', '0'));
     z14 := StrToInt(INI.ReadString('Control', '1+4', '0'));
     z23 := StrToInt(INI.ReadString('Control', '2+3', '0'));
     z24 := StrToInt(INI.ReadString('Control', '2+4', '0'));
     z34 := StrToInt(INI.ReadString('Control', '3+4', '0'));

     z123 := StrToInt(INI.ReadString('Control', '1+2+3', '0'));
     z234 := StrToInt(INI.ReadString('Control', '2+3+4', '0'));
     z124 := StrToInt(INI.ReadString('Control', '1+2+4', '0'));
     z134 := StrToInt(INI.ReadString('Control', '1+3+4', '0'));

     z1234 := StrToInt(INI.ReadString('Control', '1+2+3+4', '0'));

   	finally
    INI.Free;
    end;
	
   Form2.Show;
   Form2.Edit1.Text:= CurrToStr(utrata_c);
   Form2.Edit2.Text:= CurrToStr(histereza);
   Form2.Edit3.Text:= IntToStr(Ia);
   Form2.Edit11.Text:= IntToStr(pomp);
   Form2.Edit14.Text:= IntToStr(nk);
   Form2.Edit15.Text:= IntToStr(hk);
   Form2.Edit16.Text:= IntToStr(hp);

   if (ch1 = 'ON') then Form2.CheckBox1.Checked := true else Form2.CheckBox1.Checked := false;
   if (ch2 = 'ON') then Form2.CheckBox2.Checked := true else Form2.CheckBox2.Checked := false;
   if (ch3 = 'ON') then Form2.CheckBox3.Checked := true else Form2.CheckBox3.Checked := false;

   Form2.Edit12.Text:= IntToStr(z0);
   Form2.Edit4.Text:= IntToStr(z1);
   Form2.Edit5.Text:= IntToStr(z2);
   Form2.Edit6.Text:= IntToStr(z3);
   Form2.Edit17.Text:= IntToStr(z4);

   Form2.Edit7.Text:= IntToStr(z12);
   Form2.Edit8.Text:= IntToStr(z13);
   Form2.Edit18.Text:= IntToStr(z14);
   Form2.Edit9.Text:= IntToStr(z23);
   Form2.Edit19.Text:= IntToStr(z24);
   Form2.Edit24.Text:= IntToStr(z34);

   Form2.Edit10.Text:= IntToStr(z123);
   Form2.Edit20.Text:= IntToStr(z234);
   Form2.Edit21.Text:= IntToStr(z124);
   Form2.Edit22.Text:= IntToStr(z134);

   Form2.Edit23.Text:= IntToStr(z1234);


 end;

procedure TForm1.Button4Click(Sender: TObject);
  var  INI : TIniFile;
   begin
  CiglaName:=ExtractFileDir(application.exename);
  CiglaName:=CiglaName+'\Cigla.ini';

    INI := TINIFile.Create(CiglaName);
 	  try
     obraz := StrToInt(INI.ReadString('Ustawienia', 'Obraz', '0'));
     ster := StrToInt(INI.ReadString('Odczyt', 'Sterownik', '0'));
     wygaszanie2 := StrToInt(INI.ReadString('Odczyt', 'Wygaszanie', '0'));
 	  finally
 	  INI.Free;

 if obraz = 0 then
  begin
   if ster = 1 then Image2.Picture.LoadFromFile('gora_err.jpg');
   if ster = 2 then Image2.Picture.LoadFromFile('gora.jpg');
   if ster = 3 then Image2.Picture.LoadFromFile('dol_err.jpg');
   if ster = 4 then Image2.Picture.LoadFromFile('dol.jpg');

   Image1.Picture.LoadFromFile('Domek_noc.jpg');
   Color := ClBlack;
   Label1.Font.Color := ClWhite;
   Label2.Font.Color := ClWhite;
   Label3.Font.Color := ClWhite;
   Label4.Font.Color := ClWhite;
   Label5.Font.Color := ClWhite;
   Label6.Font.Color := ClWhite;
   Label7.Font.Color := ClWhite;
   Label9.Font.Color := ClWhite;
   Label10.Font.Color := ClWhite;
   Label11.Font.Color := ClWhite;
   Label12.Font.Color := ClWhite;
   Label13.Font.Color := ClWhite;
   Label14.Font.Color := ClWhite;
   Label15.Font.Color := ClWhite;
   Label16.Font.Color := ClWhite;
   Label17.Font.Color := ClWhite;
   Label19.Font.Color := ClWhite;
   Label20.Font.Color := ClWhite;
   Label21.Font.Color := ClWhite;
   Label22.Font.Color := ClWhite;
   Label23.Font.Color := ClWhite;
   Label24.Font.Color := ClWhite;
   Label25.Font.Color := ClWhite;
   Edit1.Font.Color := ClWhite;
   Edit1.Color := ClBlack;
   obraz:= 1;
  end else
  begin
   if ster = 1 then Image2.Picture.LoadFromFile('gora_err_noc.jpg');
   if ster = 2 then Image2.Picture.LoadFromFile('gora_noc.jpg');
   if ster = 3 then Image2.Picture.LoadFromFile('dol_err_noc.jpg');
   if ster = 4 then Image2.Picture.LoadFromFile('dol_noc.jpg');

   Image1.Picture.LoadFromFile('Domek.jpg');
   Color := ClWhite;
   Label1.Font.Color := ClBlack;
   Label2.Font.Color := ClBlack;
   Label3.Font.Color := ClBlack;
   Label4.Font.Color := ClBlack;
   Label5.Font.Color := ClBlack;
   Label6.Font.Color := ClBlack;
   Label7.Font.Color := ClBlack;
   Label9.Font.Color := ClBlack;
   Label10.Font.Color := ClBlack;
   Label11.Font.Color := ClBlack;
   Label12.Font.Color := ClBlack;
   Label13.Font.Color := ClBlack;
   Label14.Font.Color := ClBlack;
   Label15.Font.Color := ClBlack;
   Label16.Font.Color := ClBlack;
   Label17.Font.Color := ClBlack;
   Label19.Font.Color := ClBlack;
   Label20.Font.Color := ClBlack;
   Label21.Font.Color := ClBlack;
   Label22.Font.Color := ClBlack;
   Label23.Font.Color := ClBlack;
   Label24.Font.Color := ClBlack;
   Label25.Font.Color := ClBlack;
   Edit1.Font.Color := ClBlack;
   Edit1.Color := ClWhite;
   obraz:= 0;
  end;

      CiglaName:=ExtractFileDir(application.exename);
      CiglaName:=CiglaName+'\Cigla.ini';

    INI := TINIFile.Create(CiglaName);
 	  try
     INI.WriteInteger('Ustawienia', 'Obraz', obraz );
 	  finally
   	INI.Free;
    end;

    if obraz = 0 then Image2.Picture.LoadFromFile('pusto.jpg') else Image2.Picture.LoadFromFile('pusto_noc.jpg');

    if wygaszanie2 = 1 then Label17.Caption:= 'Rozpalanie';
    if wygaszanie2 = 2 then Label17.Caption:= 'Wygaszanie';
    if wygaszanie2 = 3 then Label17.Caption:= 'Wyga�ni�te';
    end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
 if reg_c < 24 then
   begin
    reg_c :=  reg_c + 0.1;
    Edit1.Text:= CurrToStr(reg_c);
   end;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
 if reg_c > 20 then
   begin
    reg_c :=  reg_c - 0.1;
    Edit1.Text:= CurrToStr(reg_c);
   end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
 Form6.Show;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
 	Form5.Show;
end;
procedure TForm1.Button8Click(Sender: TObject);
begin
 Form7.Show;
end;

procedure TForm1.CanClose(Sender: TObject; var CanClose: Boolean);
begin
CanClose := MessageBox(Handle, 'Czy na pewno chcesz zamkn�� program?', 'Potwierd�', MB_ICONWARNING + MB_YESNO) = mrYes;
end;

end.



