object Form1: TForm1
  Left = 192
  Top = 124
  Width = 213
  Height = 203
  Caption = 'Szyfrator'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Edit1: TEdit
    Left = 40
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '5---30'
  end
  object Edit2: TEdit
    Left = 40
    Top = 64
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'Serial---Klijent'
  end
  object Button1: TButton
    Left = 64
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 2
    OnClick = Button1Click
  end
end
