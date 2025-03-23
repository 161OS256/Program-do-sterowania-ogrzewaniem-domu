{--------------------------------------------------------------------------
 | Copyright (C) 1992-1998 Dallas Semiconductor Corporation.
 | All rights Reserved. Printed in U.S.A.
 | This software is protected by copyright laws of
 | the United States and of foreign countries.
 | This material may also be protected by patent laws of the United States
 | and of foreign countries.
 | This software is furnished under a license agreement and/or a
 | nondisclosure agreement and may only be used or copied in accordance
 | with the terms of those agreements.
 | The mere transfer of this software does not imply any licenses
 | of trade secrets, proprietary technology, copyrights, patents,
 | trademarks, maskwork rights, or any other form of intellectual
 | property whatsoever. Dallas Semiconductor retains all ownership rights.
 |--------------------------------------------------------------------------

   Some of the TMEX 3.10 functions.
}
Unit iBTMEXPW;

Interface

Type
   FileEntry = record
      name : Array[0..3] of Char;
      extension : Byte;
      startpage : Byte;
      numpages  : Byte;
      attribute : Byte;
      BitMap : Array[0..31] of Byte;
   end;
   PFileEntry = ^FileEntry;
   DirectoryPath = record
      NumEntries : Byte;
      Ref : Char;
      Entries : Array[0..9,0..3] of Char;
   end;
   PDirectoryPath = ^DirectoryPath;
   
 
Var
   StateBuf : Array[1..15360] of Byte;
   SHandle : Longint;
   CRC16 : Word;
   CRC8 :Byte;
Const
  { TMEX Error codes    }
      XNO_DEVICE             = -1 ;
      XWRONG_TYPE            = -2 ;
      XFILE_READ_ERR         = -3 ;
      XBUFFER_TOO_SMALL      = -4 ;
      XHANDLE_NOT_AVAIL      = -5 ;
      XFILE_NOT_FOUND        = -6 ;
      XREPEAT_FILE           = -7 ;
      XHANDLE_NOT_USED       = -8 ;
      XFILE_WRITE_ONLY       = -9 ;
      XOUT_OF_SPACE          = -10 ;
      XFILE_WRITE_ERR        = -11 ;
      XFILE_READ_ONLY        = -12 ;
      XFUNC_NOT_SUP          = -13 ;
      XBAD_FILENAME          = -14 ;
      XCANT_DEL_READ_ONLY    = -15 ;
      XHANDLE_NOT_EXIST      = -16 ;
      XONE_WIRE_PORT_ERROR   = -17 ;
      XINVALID_DIRECTORY     = -18 ;
      XDIRECTORY_NOT_EMPTY   = -19 ;
      XUNABLE_TO_CREATE_DIR  = -20 ;
      XNO_PROGRAM_JOB        = -21 ;
      XPROGRAM_WRITE_PROTECT = -22 ;
      XNON_PROGRAM_PARTS     = -23 ;
      XADDFILE_TERMINATED    = -24 ;
      XTIMEOUT               = -25 ;
      XINVALID_ARGUMENT      = -26 ;
      XBAD_ACK               = -27 ;
      XINVALID_SESSION       = -200;
      XNO_BASDRV_FOUND       = -201;

{ Basic physical level error codes   }
      BPORT_NOT_INITIALIZED  = -1 ;
      BPORT_NOT_EXIST        = -2 ;
      BNO_SUCH_FUNCTION      = -3 ;

{ Transport level error codes  }
      TERROR_READ_WRITE      = -4 ;
      TBUFFER_TOO_SMALL      = -5 ;
      TDEVICE_TOO_SMALL      = -6 ;
      TNO_DEVICE             = -7 ;
      TBLOCK_TOO_BIG         = -8 ;
      TWRONG_TYPE            = -9 ;
      TPAGE_REDIRECTED       = -10;
      TPROGRAM_NOT_POSSIBLE  = -11;
      BCOM_FAILURE           = -12;
      BCOM_EVENT             = -13;
{ other  }
      GENERAL_FAIL           = -2 ;

{$IFDEF WIN32}
Function Get_Version(V: Pointer): SmallInt; StdCall;
Function TMGetTypeVersion(N: SmallInt; V: Pointer): SmallInt; StdCall;
Function TMStartSession(N: SmallInt): SmallInt; StdCall;
Function TMExtendedStartSession(P: SmallInt; T: SmallInt; Q: Pointer): LongInt; StdCall;
Function TMEndSession(H: LongInt): SmallInt; StdCall;
Function TMValidSession(H: LongInt): SmallInt; StdCall;
Function TMSetup(H: LongInt): SmallInt; StdCall;
Function TMTouchReset(H: LongInt): SmallInt; StdCall;
Function TMTouchByte(H: LongInt; B: SmallInt): SmallInt; StdCall;
Function TMTouchBit(H: LongInt; B: SmallInt): SmallInt; StdCall;
Function TMProgramPulse(H: Longint): Smallint; StdCall;
Function TMOneWireLevel (H: Longint; O: SmallInt; L: SmallInt; P: SmallInt): SmallInt; StdCall;
Function TMOneWireCom (H: Longint; O: SmallInt; T: SmallInt): SmallInt; StdCall;
Function TMClose (H: Longint): Smallint; StdCall;
Function TMFirst(H: LongInt; P: Pointer): SmallInt; StdCall;
Function TMNext(H: LongInt; P: Pointer): SmallInt; StdCall;
Function TMAccess(H: LongInt; P: Pointer): SmallInt; StdCall;
Function TMStrongAccess(H: LongInt; P: Pointer): SmallInt; StdCall;
Function TMStrongAlarmAccess(H: LongInt; P: Pointer): SmallInt; StdCall;
Function TMOverAccess (H: Longint; P: Pointer): Smallint;StdCall;
Function TMRom(H: Longint; P: Pointer; D: Pointer): Smallint;StdCall;
Function TMFirstAlarm(H: Longint; P: Pointer): Smallint; StdCall;
Function TMNextAlarm (H: Longint; P: Pointer): Smallint;StdCall;
Function TMFamilySearchSetup(H: Longint; P: Pointer; G: Smallint): Smallint; StdCall;
Function TMSkipFamily (H: Longint; P: Pointer): Smallint;StdCall;
Function TMReadPacket(H: LongInt; P: Pointer; G: SmallInt; D: Pointer; M: SmallInt): SmallInt; StdCall;
Function TMWritePacket(H: LongInt; P: Pointer; G: SmallInt; D: Pointer; L: SmallInt): SmallInt; StdCall;
Function TMBlockIO(H: Longint; P: Pointer; T: Pointer; N: Smallint ): Smallint; StdCall;
Function TMExtendedReadPage(H: LongInt; P: Pointer; G: SmallInt; D: Pointer; T: SmallInt): SmallInt; StdCall;
Function TMProgramByte(H: Longint;P: Pointer;M: Smallint;I : Pointer;N: Smallint;T:Pointer;Z: SmallInt):Smallint;StdCall;
Function TMFormat(H: LongInt; P: Pointer): SmallInt; StdCall;
Function TMFirstFile(H: LongInt; P: Pointer; F: Pointer): SmallInt; StdCall;
Function TMNextFile(H: LongInt; P: Pointer; F: Pointer): SmallInt; StdCall;
Function TMOpenFile(H: LongInt; P: Pointer; F: Pointer): SmallInt; StdCall;
Function TMDeleteFile(H: LongInt; P: Pointer; F: Pointer): SmallInt; StdCall;
Function TMCreateFile(H: LongInt; P: Pointer; L: Pointer; F: Pointer): SmallInt; StdCall;
Function TMReadFile(H: LongInt; P: Pointer; G: SmallInt; F: Pointer; M: SmallInt): SmallInt; StdCall;
Function TMWriteFile(H: LongInt; P: Pointer; G: SmallInt; F: Pointer; M: SmallInt): SmallInt; StdCall;
Function TMCloseFile(H: LongInt; P: Pointer; G: SmallInt): SmallInt; StdCall;
Function TMAttribute(H: LongInt; P: Pointer; A: SmallInt; F: Pointer): SmallInt; StdCall;
Function TMDirectoryMR(H: LongInt; P: Pointer; N: SmallInt; F: Pointer): SmallInt; StdCall;
Function TMChangeDirectory(H: LongInt; P: Pointer; N: SmallInt; F: Pointer): SmallInt; StdCall;
Function TMCreateProgramJob(H: LongInt; P: Pointer): SmallInt; StdCall;
Function TMDoProgramJob(H: LongInt; P: Pointer): SmallInt; StdCall;
Function TMWriteAddFile(H: LongInt; P: Pointer; G,O,S: SmallInt; F: Pointer; M: SmallInt): SmallInt; StdCall;
Function TMTerminateAddFile(H: Longint; P: Pointer; F: Pointer): Smallint; StdCall;
Function TMAutoOverDrive(H: LongInt; P: Pointer; M: SmallInt): SmallInt; StdCall;
Function TMReNameFile(H: LongInt; P: Pointer; A: SmallInt; F: Pointer): SmallInt; StdCall;
Function TMBlockStream(H: LongInt; P: Pointer; G: SmallInt): SmallInt; StdCall;  { (3.10) }
Procedure DoCRC16(X: Byte);
Procedure DoCRC8(X: Byte);
{$ELSE}
Function Get_Version(V: Pointer): SmallInt;
Function TMGetTypeVersion(N: SmallInt; V: Pointer): SmallInt;
Function TMStartSession(N: SmallInt): SmallInt;
Function TMExtendedStartSession(P: SmallInt; T: SmallInt; P: Pointer): LongInt;
Function TMEndSession(H: LongInt): SmallInt;
Function TMValidSession(H: LongInt): SmallInt;
Function TMSetup(H: LongInt): SmallInt;
Function TMTouchReset(H: LongInt): SmallInt;
Function TMTouchByte(H: LongInt; B: SmallInt): SmallInt;
Function TMTouchBit(H: LongInt; B: SmallInt): SmallInt;
Function TMProgramPulse(H: Longint): SmallInt;
Function TMOneWireLevel (H: Longint; O: SmallInt; L: SmallInt; P: SmallInt): SmallInt;
Function TMOneWireCom (H: Longint; O: SmallInt; T: SmallInt): SmallInt;
Function TMClose (H: Longint): SmallInt;
Function TMFirst(H: LongInt; P: Pointer): SmallInt;
Function TMNext(H: LongInt; P: Pointer): SmallInt;
Function TMAccess(H: LongInt; P: Pointer): SmallInt;
Function TMStrongAccess(H: LongInt; P: Pointer): SmallInt;
Function TMStrongAlarmAccess(H: LongInt; P: Pointer): SmallInt;
Function TMOverAccess (H: Longint; P: Pointer): SmallInt;
Function TMFirstAlarm(H: Longint; P: Pointer): SmallInt;
Function TMNextAlarm (H: Longint; P: Pointer): SmallInt;
Function TMFamilySearchSetup(H: Longint; P: Pointer; G: Integer): SmallInt;
Function TMSkipFamily (H: Longint; P: Pointer): SmallInt;
Function TMRom(H: LongInt; P: Pointer; D: Pointer): SmallInt;
Function TMReadPacket(H: LongInt; P: Pointer; G: SmallInt; D: Pointer; M: SmallInt): SmallInt;
Function TMWritePacket(H: LongInt; P: Pointer; G: SmallInt; D: Pointer; L: SmallInt): SmallInt;
Function TMBlockIO(H: Longint; P: Pointer; T: Pointer; N: SmallInt ): SmallInt;
Function TMProgramByte(H: Longint; P: Pointer; M: SmallInt; I : Pointer;  N: SmallInt; T:Pointer; Z: SmallInt): Integer;
Function TMExtendedReadPage(H: LongInt; P: Pointer; G: SmallInt; D: Pointer; T: SmallInt): SmallInt;
Function TMFormat(H: LongInt; P: Pointer): SmallInt;
Function TMFirstFile(H: LongInt; P: Pointer; F: Pointer): SmallInt;
Function TMNextFile(H: LongInt; P: Pointer; F: Pointer): SmallInt;
Function TMOpenFile(H: LongInt; P: Pointer; F: Pointer): SmallInt;
Function TMDeleteFile(H: LongInt; P: Pointer; F: Pointer): SmallInt;
Function TMCreateFile(H: LongInt; P: Pointer; L: Pointer; F: Pointer): SmallInt;
Function TMReadFile(H: LongInt; P: Pointer; G: SmallInt; F: Pointer; M: SmallInt): SmallInt;
Function TMWriteFile(H: LongInt; P: Pointer; G: SmallInt; F: Pointer; M: SmallInt): SmallInt;
Function TMCloseFile(H: LongInt; P: Pointer; G: SmallInt): SmallInt;
Function TMAttribute(H: LongInt; P: Pointer; A: SmallInt; F: Pointer): SmallInt;
Function TMTerminateAddFile(H: Longint; P: Pointer; F: Pointer): SmallInt;
Function TMDirectoryMR(H: LongInt; P: Pointer; N: SmallInt; F: Pointer): SmallInt;
Function TMChangeDirectory(H: LongInt; P: Pointer; N: SmallInt; F: Pointer): SmallInt;
Function TMCreateProgramJob(H: LongInt; P: Pointer): SmallInt;
Function TMDoProgramJob(H: LongInt; P: Pointer): SmallInt;
Function TMWriteAddFile(H: LongInt; P: Pointer; G,O,S: SmallInt; F: Pointer; M: SmallInt): SmallInt;
Function TMAutoOverDrive(H: LongInt; P: Pointer; M: SmallInt): SmallInt;
Function TMReNameFile(H: LongInt; P: Pointer; A: SmallInt; F: Pointer): SmallInt;
Function TMBlockStream(H: LongInt; P: Pointer; G: SmallInt): SmallInt;  { (3.10) }
Procedure DoCRC16(X: Byte);
Procedure DoCRC8(X: Byte);
{$ENDIF}

Implementation

{$IFDEF WIN32}
Function Get_Version; External 'IBFS32.DLL';
Function TMGetTypeVersion; External 'IBFS32.DLL';
Function TMStartSession; External 'IBFS32.DLL';
Function TMExtendedStartSession; External 'IBFS32.DLL';
Function TMEndSession; External 'IBFS32.DLL';
Function TMValidSession; External 'IBFS32.DLL';
Function TMSetup; External 'IBFS32.DLL';
Function TMTouchReset; External 'IBFS32.DLL';
Function TMTouchByte; External 'IBFS32.DLL';
Function TMTouchBit; External 'IBFS32.DLL';
Function TMProgramPulse; External 'IBFS32.DLL';
Function TMClose; External 'IBFS32.DLL';
Function TMOneWireLevel; External 'IBFS32.DLL';
Function TMOneWireCom; External 'IBFS32.DLL';
Function TMFirst; External 'IBFS32.DLL';
Function TMNext; External 'IBFS32.DLL';
Function TMAccess; External 'IBFS32.DLL';
Function TMStrongAccess; External 'IBFS32.DLL';
Function TMStrongAlarmAccess; External 'IBFS32.DLL';
Function TMOverAccess; External 'IBFS32.DLL';
Function TMFirstAlarm; External 'IBFS32.DLL';
Function TMNextAlarm; External 'IBFS32.DLL';
Function TMFamilySearchSetup; External 'IBFS32.DLL';
Function TMSkipFamily; External 'IBFS32.DLL';
Function TMRom; External 'IBFS32.DLL';
Function TMReadPacket; External 'IBFS32.DLL';
Function TMWritePacket; External 'IBFS32.DLL';
Function TMBlockIO; External 'IBFS32.DLL';
Function TMProgramByte; External 'IBFS32.DLL';
Function TMExtendedReadPage; External 'IBFS32.DLL';
Function TMFormat; External 'IBFS32.DLL';
Function TMFirstFile; External 'IBFS32.DLL';
Function TMNextFile; External 'IBFS32.DLL';
Function TMOpenFile; External 'IBFS32.DLL';
Function TMDeleteFile; External 'IBFS32.DLL';
Function TMCreateFile; External 'IBFS32.DLL';
Function TMReadFile; External 'IBFS32.DLL';
Function TMWriteFile; External 'IBFS32.DLL';
Function TMCloseFile; External 'IBFS32.DLL';
Function TMAttribute; External 'IBFS32.DLL';
Function TMDirectoryMR; External 'IBFS32.DLL';
Function TMChangeDirectory; External 'IBFS32.DLL';
Function TMCreateProgramJob; External 'IBFS32.DLL';
Function TMDoProgramJob; External 'IBFS32.DLL';
Function TMWriteAddFile; External 'IBFS32.DLL';
Function TMTerminateAddFile; External 'IBFS32.DLL';
Function TMAutoOverDrive; External 'IBFS32.DLL';
Function TMReNameFile; External 'IBFS32.DLL';
Function TMBlockStream; External 'IBFS32.DLL';  { (3.10) }
{$ELSE}
Function Get_Version; External 'IBFS';
Function TMGetTypeVersion; External 'IBFS';
Function TMStartSession; External 'IBFS';
Function TMExtendedStartSession; External 'IBFS';
Function TMEndSession; External 'IBFS';
Function TMValidSession; External 'IBFS';
Function TMSetup; External 'IBFS';
Function TMTouchReset; External 'IBFS';
Function TMTouchByte; External 'IBFS';
Function TMTouchBit; External 'IBFS';
Function TMOneWireLevel; External 'IBFS';
Function TMOneWireCom; External 'IBFS';
Function TMProgramPulse; External 'IBFS';
Function TMFirst; External 'IBFS';
Function TMNext; External 'IBFS';
Function TMClose; External 'IBFS';
Function TMAccess; External 'IBFS';
Function TMStrongAccess; External 'IBFS';
Function TMStrongAlarmAccess; External 'IBFS';
Function TMOverAccess; External 'IBFS';
Function TMFirstAlarm; External 'IBFS';
Function TMNextAlarm; External 'IBFS';
Function TMFamilySearchSetup; External 'IBFS';
Function TMSkipFamily; External 'IBFS';
Function TMRom; External 'IBFS';
Function TMReadPacket; External 'IBFS';
Function TMWritePacket; External 'IBFS';
Function TMBlockIO; External 'IBFS';
Function TMProgramByte; External 'IBFS';
Function TMExtendedReadPage; External 'IBFS';
Function TMFormat; External 'IBFS';
Function TMFirstFile; External 'IBFS';
Function TMNextFile; External 'IBFS';
Function TMOpenFile; External 'IBFS';
Function TMDeleteFile; External 'IBFS';
Function TMCreateFile; External 'IBFS';
Function TMReadFile; External 'IBFS';
Function TMWriteFile; External 'IBFS';
Function TMCloseFile; External 'IBFS';
Function TMAttribute; External 'IBFS';
Function TMDirectoryMR; External 'IBFS';
Function TMTerminateAddFile; External 'IBFS';
Function TMChangeDirectory; External 'IBFS';
Function TMCreateProgramJob; External 'IBFS';
Function TMDoProgramJob; External 'IBFS';
Function TMWriteAddFile; External 'IBFS';
Function TMAutoOverDrive; External 'IBFS';
Function TMReNameFile; External 'IBFS';
Function TMBlockStream; External 'IBFS';   { (3.10) }
{$ENDIF}


{----------------------------------------------------------------------------}
{  This procedure accumulates the CRC16 CRC of the data X in the
   global variable CRC16.
}
Procedure DoCRC16(X: Byte);
Var
   I : Byte;
   F : Boolean;
Begin
   For I := 1 to 8 do Begin
      F := Odd(X xor CRC16);
      CRC16 := CRC16 shr 1;
      X := X shr 1;
      If F then CRC16 := CRC16 xor $A001;
   End;
End;

{----------------------------------------------------------------------------}
{  This procedure calculates the cumulative Dallas Semiconductor
   one-wire CRC8 of all bytes passed to it.  The result accumulates
   in the global variable CRC8.
}
Procedure DoCRC8(X: Byte);
Const
   Table : Array[0..255] of Byte = (
        0, 94,188,226, 97, 63,221,131,194,156,126, 32,163,253, 31, 65,
      157,195, 33,127,252,162, 64, 30, 95,  1,227,189, 62, 96,130,220,
       35,125,159,193, 66, 28,254,160,225,191, 93,  3,128,222, 60, 98,
      190,224,  2, 92,223,129, 99, 61,124, 34,192,158, 29, 67,161,255,
       70, 24,250,164, 39,121,155,197,132,218, 56,102,229,187, 89,  7,
      219,133,103, 57,186,228,  6, 88, 25, 71,165,251,120, 38,196,154,
      101, 59,217,135,  4, 90,184,230,167,249, 27, 69,198,152,122, 36,
      248,166, 68, 26,153,199, 37,123, 58,100,134,216, 91,  5,231,185,
      140,210, 48,110,237,179, 81, 15, 78, 16,242,172, 47,113,147,205,
       17, 79,173,243,112, 46,204,146,211,141,111, 49,178,236, 14, 80,
      175,241, 19, 77,206,144,114, 44,109, 51,209,143, 12, 82,176,238,
       50,108,142,208, 83, 13,239,177,240,174, 76, 18,145,207, 45,115,
      202,148,118, 40,171,245, 23, 73,  8, 86,180,234,105, 55,213,139,
       87,  9,235,181, 54,104,138,212,149,203, 41,119,244,170, 72, 22,
      233,183, 85, 11,136,214, 52,106, 43,117,151,201, 74, 20,246,168,
      116, 42,200,150, 21, 75,169,247,182,232, 10, 84,215,137,107, 53);

Begin
   CRC8 := Table[CRC8 xor X];
End;



End.


