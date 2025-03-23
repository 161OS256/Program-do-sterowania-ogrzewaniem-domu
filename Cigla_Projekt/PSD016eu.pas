unit PSD016eu;

(*PROBLEM: In "WaitAWhile" (dubious at best), there was a remmed
out application.processmessages at 24Aug06. Try to fix!!!!*)

interface

uses iBTMEXPW, WINDOWS, dialogs {only for showmessage... should go};

const version='25 Aug 06';

(*For pasting to calling program....
PSD016eu provides....

function ver:string;
//returns version of PSD016eu

//"DML": Dallas MicroLan related routines and variables
//In the calling program, things like iPortNum probably best
//   held in variables named, e.g., iDMLPortNum

procedure DMLEstablishSession(iPortNum,iAdapterType:longint;
                              var bTKBErr:byte; var liHandle:longint);
//Call to set up connection to TMEX api,
//   to fill liHandle for subsequent DML calls.
//Only iPortNum and iAdapterType need values to pass to the procedure.
//This often called prior to other routines.
//On Exit...
//  if bTKBErr=0 then all was well, and a valid session handle is
//       established in liHandle
//  if bTKBErr=1 then TMExtendedStartSession failed, and error
//       code from Dallas returned in liHandle
//  if bTKBErr=2 then TMSetUp failed, and error
//       code from Dallas returned in liHandle


procedure DMLGet1820Tture(
      var bTtureHi,bTtureLo,bTKBErr:byte;
      var iDalErr:integer;
      liHandle:longint;
      baRomID:array of byte);
//Call this to access the "inner core" of the code to read temperature
//sensor spec'd by baRomID. This procedure should probably be
//"wrapped" in an outer procedure to check that the chip is
//of the right type, and "translate" bTtureHi and bTtureLo
//into a temperature in conventional units.
//Code is suitable for chips with family codes $10 and $28.
//N.B. baRomID, in calling program, is of type array[0..7] of byte;
//   (The passing of arrays to procedures is done minus the "[0..7]"
//Slow?
//
//Before calling  DMLGet1820Tture, call DMLEstablishSession,
//   which puts a value in liHandle, amoung other things.
//After calling DMLGet1820Tture:
//  bTtureHi and bTtureLo will hold the temperature sensed,
//  bTKBErr will be 0 if all was well, flag an error otherwise
//  if bTKBErr<>0 then iDalErr will hold the error returned by
//  the TMEX api.

function rRawToC(bHi,bLo:byte):real;
//Convert the two bytes returned by DMLGet1820Tture
//  when called for a DS1820 (family code $10)
//  to Celcius

function rRawToC18B20(bHi,bLo:byte):real;
//Convert the two bytes returned by DMLGet1820Tture
//  when called for a DS18B20 (family code $28)
//  to Celcius

function CtoF(rTmp:single):single;
//Returns the Fahrenheit equivalent of a Celsius tture.
*)

function ver:string;

procedure DMLEstablishSession(iPortNum,iAdapterType:longint;
                              var bTKBErr:byte; var liHandle:longint);

procedure DMLGet1820Tture(
      var bTtureHi,bTtureLo,bTKBErr:byte;
      var iDalErr:integer;
      liHandle:longint;
      baRomID:array of byte);

function rRawToC(bHi,bLo:byte):real;

function rRawToC18B20(bHi,bLo:byte):real;

function CtoF(rTmp:single):single;

(*===Here begins "implementation"=========*)

var    siaDMLRom:array[0..8] of smallint;(*Yes: 9 bytes.
       the last isn't used every time, but I think
       it IS used sometimes.

       A curiosity: The type MUST(?) BE SMALLINT...
       I accidentally had this as byte and got
       GPFaults during TMRom call. (Problem
       stuffing $FF into an element?)*)

       baDMLStateBuffer:array[0..15361] of byte;
      (*15360 might do, but for one byte, I covered
       the possiblilty that I was misunderstanding
       something in the Dallas docs*)

       liHandle:longint;

implementation

function ver:string;
begin
result:=version;
end;

procedure DMLEstablishSession(iPortNum,iAdapterType:longint;
                              var bTKBErr:byte; var liHandle:longint);
(*On Exit...
  if bTKBErr=0 then all was well, and a valid session handle is
       established in liHandle
  if bTKBErr=1 then TMExtendedStartSession failed, and error
       code from Dallas returned in liHandle
  if bTKBErr=2 then TMSetUp failed, and error
       code from Dallas returned in liHandle*)
var iDMLTmpResult:longint;
begin
bTKBErr:=0;
liHandle:=TMExtendedStartSession(iPortNum,iAdapterType,nil);
if liHandle<0 then bTKBErr:=1;
if bTKBErr=0 then begin
   iDMLTmpResult:=TMSetUp(liHandle);
   if iDMLTmpResult<>1 then begin
      bTKBErr:=2;
      liHandle:=iDMLTmpResult;
      end;(*iDMLTmpResult<>0*)
   end;(*bTKBErr=0*)
end;//DMLEstablishSession

procedure DMLGet1820Tture(
      var bTtureHi,bTtureLo,bTKBErr:byte;
      var iDalErr:integer;
      liHandle:longint;
      baRomID:array of byte);

// Here begins....
// A LONG bit of code!...
// AND BAD if remmed out "application.processmessages"  in WaitAWhile
// not fixed or replaced yet.

//This code "ain't pretty", but I believe that the header is a
//   basis which can be built on. It is about my third attempt...

//Code is suitable for chips with family codes $10 and $28.


var iDMLTmpResult:integer;
    //boSetup:boolean;

(*This DMLGet1820Tture derived from
  DMLGet1820TtureJly06, which had significant changes from
  the older DMLGet1820Tture, even though it started from there.

AT PRESENT (12Jly06), it SHOULD work with ds1820's which are
supplied with 5v non-parasitically. It will even work with
parasitically powered 1820s, sometimes, but to make it work
reliably using only parasitic power, the software is supposed
to provide strong pull up...
which not all(?) adapters can do...*)

(*KEEP THIS AND dmlGet18B20Tture TUTORIAL/DS code IN STEP

THIS (in PSD016) modified from
"THIS" (in DS025) modified 10jly06, but it should still have the
"new at 10jly06" feature that even if tkbErr<>0,
procedure still releases session at end of call.
Calls TMEndSession. (line is remmed.)

ALSO added a TMReset block

Other old (at 7/06) "read Dallas chip" routines probably
  need similar.

In the Dallas "read a temperature" demo code, there
  seems to be a number of places where the code says
  "Couldn't do that first time? Try a few times more"
  In this code, we work through the stages of reading
  a temperature, and if we get a snag at any point,
  we give up. It is up to the calling program to
  re-call this as often as it deems worthwhile.

  N.B. This code does not check that the device it has
  been sent to read is in fact a DS1820 (family code $10,
  or compatible device). That check should be made before
  this routine is called.*)

procedure WaitAWhile;
(*NOT a good idea, on several fronts.. but it works, and
  the program has been constructed so that a better
  solution can be implemented with few side effects.

Error codes may be confused, and non-unique, but working
towards....
nnnn.1110: A CheckSession failure
... otherwise, MSB carries info from last stages of routine,
   LSB info from earlier parts

*)
var lwTmp:cardinal;//used longword in Delphi 7
begin
//Add 'WINDOWS' to the unit's USES clause in order to use "GetTickCount"
//This routine was once in the main unit of an application. Since
//    the time it was moved into a subordinate unit,
//    application.processmessages;
//    has not been possible.
//Originally there was one loop....
//     lwTmp:=GetTickCount+1800;(*lwTmp:=lwTmp+500; here causes a 500ms delay*)
//     repeat
//       application.processmessages;
//     until GetTickCount>lwTmp;
//The delay is now made up of several shorter loops in
//     hopes of not crashing Windows through
//     excessive non-release.
//Not the best thing to do, even the old way, but
//     the best I've found so far to meet the needs
//     of the application!

//Doing 4x400 plus 1x200, total 1800, 1.8 seconds delay
lwTmp:=GetTickCount+400;(*lwTmp:=lwTmp+500; here causes a 500ms delay*)
repeat
until GetTickCount>lwTmp;

lwTmp:=GetTickCount+400;
repeat
until GetTickCount>lwTmp;

lwTmp:=GetTickCount+400;
repeat
until GetTickCount>lwTmp;

lwTmp:=GetTickCount+400;
repeat
until GetTickCount>lwTmp;

lwTmp:=GetTickCount+200;
repeat
until GetTickCount>lwTmp;


end;

function FillBufferNResetNAccess:byte;
var c1,bTmpErrLToFillNAcc:byte;
sChipId:string;
//generalize this for big DML library...
//BEFORE calling it, TMExtendedSession and TMSetup need
//   to have executed okay.
//BEFORE calling, baRomID must hold chip's ID. As long as
//   FillBuff... is inside DMLGet1820Tture this will be okay.
//It takes care of moving Dallas ID spec to buffer inside TMEX driver,
//   resetting the MicroLan (part of TMAccess),
//   and then accessing that chip, i.e. shutting down all the rest.
//   TMAccess does not guarantee that a chip of the id you looked for was
//      present, only that SOME chip was present.
//    See... I think... StrongAccess if you need to KNOW chip present.
//    (Different from Strong Pull Up.)
//Returns 0 if all went well, error code otherwise.
begin  //FillBufferNAccess
  bTmpErrLToFillNAcc:=0;//ERRor-flagLocalTo-Fill...
  for c1:=0 to 7 do siaDMLRom[c1]:=baRomID[c1];
  (*Prepare to pass chip ID to a buffer in TMEX driver.
    It MAY not always be necessary to repeatedly refill
    this buffer, but doing so makes this code more generally
    useful.*)
  try (*You could introduce other try... except... end blocks.
        I only put them in where I needed them to work past
        various errors in my code, errors which I hope are
        now gone!*)
  iDMLTmpResult:=TMRom(liHandle,@baDMLStateBuffer,@siaDMLRom);
  //previous returns 1 when all well.
  except
{  on EGPFault do begin
          bTmpErrLToFillNAcc:=31;
          iDalErr:=0;
          iDMLTmpResult:=1;
          end;}
  end;//except
  if iDMLTmpResult<>1 then begin
    bTmpErrLToFillNAcc:=3;
    iDalErr:=iDMLTmpResult;
    end;

  if bTmpErrLToFillNAcc=0 then begin //x1
  iDMLTmpResult:=TMAccess(liHandle,@baDMLStateBuffer);
  //TMAccess does MicroLan reset prior to shutting down other chips.
  //Returns 1 is all well. (Can be fooled if chip of spec'd ID not on MivroLan)
  if iDMLTmpResult<>1 then begin
    bTmpErrLToFillNAcc:=4;
    iDalErr:=iDMLTmpResult;
    end //no ; here
    else bTmpErrLToFillNAcc:=0;//Turn TMEX "no problem" into TKB "no problem"
  end;//x1

result:=bTmpErrLToFillNAcc;
end;//FillBufferNAccess

begin (*DMLGet1820TtureJly06*)
bTKBErr:=0;
bTtureHi:=0;
bTtureLo:=0;

bTKBErr:=FillBufferNResetNAccess;//rework error codes and how things pass

if bTKBErr=0 (*CSess*) then begin
        iDMLTmpResult:=TMValidSession(liHandle);
(*Check to see that liHandle, the session handle, is still
    valid*)
if iDMLTmpResult<>1 then begin
    bTKBErr:=14;// 0000.1110
    iDalErr:=iDMLTmpResult;
    end;
end;

(*Note "22Jun02": See DD17dU1 for possible enhancing code
 involving invoking strong pull up here.. the other half
 of this idea is flagged below with a ref to 22Jun03

 7/06: Hardware probably NEEDS strong pull up here,
     if DS1820's may be parasitically powered....
 (8/06)...but  they WILL work sometimes, even
     parasitically powered.

 7/06... this note may now be in wrong place*)

{if bTKBErr=0 (*CSess*) then begin
        iDMLTmpResult:=TMValidSession(liHandle);
if iDMLTmpResult<>1 then begin
    bTKBErr:=16+14;//MSB says WHICH CSess, LSB of 1110 says "A CSess failed"
    iDalErr:=iDMLTmpResult;
    end;
  end;
  }

  // HERE IS where "go into strong pull-up after next op" should(?) be (7/06 note)

(*Now send message to chip telling it to take a reading*)
if bTKBErr=0 then begin
  iDMLTmpResult:=TMTouchByte(liHandle,$44);//ConvertT cmnd
  if iDMLTmpResult<0 then begin
    bTKBErr:=5;
    iDalErr:=iDMLTmpResult;(*-1 flags shorted ML*)
    end;
  end;

if bTKBErr=0 then WaitAWhile;
(*The above causes a delay so that the chip can complete
the process of taking a tture reading. There are better
ways to make a delay, and even better, there's a way
to ask the chip if the conversion is completed. Hey! This
is still worth what you paid me for it!

How long is long enough? That depends... It's probably worth
using the iButtonViewer (s/w supplied with SDK) to see
what sort of delays your chip is needing.

There is much talk in the literature about the "need" for
the master to put the ML into a string pull up state
during the conversion.... but the hardware I had (DS9097E+
DS1820) worked, even though I don't think I was able to have
a string pull up from the DS9097E. Go figger.

In a related, I suspect, vein: If in doubt, if possible, avoid
parasitic powering of devices. What's an extra wire for something
that works?! "One-Wire" was already two, with the ground wire.

After conversion, the tture should be in bytes 0 and 1 of
the scratchpad, lsb/msb respectively.*)

if bTKBErr=0 (*CSess*) then begin
        iDMLTmpResult:=TMValidSession(liHandle);
if iDMLTmpResult<>1 then begin
    bTKBErr:=32+14;
    iDalErr:=iDMLTmpResult;
    end;
  end;


//HERE insert "leave strong pull up state" (7/06 note)
(*See note 22Jun03 above re...
See DD017d for the other half of the strong pull up stuff.*)

{reserved for cancel strong pull up...

if bTKBErr=0 then begin
err:=60
  end;

if bTKBErr=0 (*CSess*) then begin
        iDMLTmpResult:=TMValidSession(liHandle);
if iDMLTmpResult then begin
    bTKBErr:=62;
    iDalErr:=iDMLTmpResult;
    end;
  end;         }

(*Now we start near the top of the sequence, this time
  to access the tture reading...*)
if bTKBErr=0 then begin
  bTKBErr:=FillBufferNResetNAccess;//need to refine error messageing
  end;

if bTKBErr=0 (*CSess*) then begin
        iDMLTmpResult:=TMValidSession(liHandle);
if iDMLTmpResult<>1 then begin
    bTKBErr:=32+16+14;
    iDalErr:=iDMLTmpResult;
    end;
  end;

if bTKBErr=0 then begin
  iDMLTmpResult:=TMTouchByte(liHandle,$BE);//Send Read Scratchpad cmnd
  if iDMLTmpResult<0 then begin
    bTKBErr:=8;//(7 may still be avail... jumped to 8 from 6)
    iDalErr:=iDMLTmpResult;
    end;
  end;

{No Check Session in DD17d... Would adding one wreck things?
if bTKBErr=0 (*CSess*) then begin
        iDMLTmpResult:=TMValidSession(liHandle);
if iDMLTmpResult<>1 then begin
    bTKBErr:=82;
    iDalErr:=iDMLTmpResult;
    end;
  end;         }

//Start reading 9 bytes from DS1820... 1st holds low byte of TTure
if bTKBErr=0 then begin
  iDMLTmpResult:=TMTouchByte(liHandle,$FF);
  bTtureLo:=iDMLTmpResult and $FF;
  if iDMLTmpResult<0 then begin
    bTKBErr:=8+1;//error codes get hairy if you go for remaining 7 data
    iDalErr:=iDMLTmpResult;
    end;
  end;

if bTKBErr=0 (*CSess*) then begin
        iDMLTmpResult:=TMValidSession(liHandle);
if iDMLTmpResult<>1 then begin
    bTKBErr:=64+14;
    iDalErr:=iDMLTmpResult;
    end;
  end;

//Read 2nd byte of datastream from 1820- high byte of TTure
if bTKBErr=0 then begin
  iDMLTmpResult:=TMTouchByte(liHandle,$FF);
  bTtureHi:=iDMLTmpResult and $FF;
  if iDMLTmpResult<0 then begin
    bTKBErr:=8+2;
    iDalErr:=iDMLTmpResult;
    end;
  end;

//That's the tture data read. For a more robust application,
//read the following 7 bytes, too, as the last holds a CRC
//for testing whether data valid.

{DD17d had no CSess here, based, I believe, on Dallas sample code
 would one hurt? matter?
if bTKBErr=0 (*CSess*) then begin
        iDMLTmpResult:=TMValidSession(liHandle);
if iDMLTmpResult<>1 then begin
    bTKBErr:=102;
    iDalErr:=iDMLTmpResult;
    end;
  end;      }

(*Following is NEW (in DS025) 10Jly06, and if successful needs
  adding to Tut versions, etc*)

(*Even if bTKBErr<>0....
  Reset perhaps not strictly necessary, as any access chould START with
     a reset. Waste of cycles? Tidy?*)

{ 12Jly06: IT MIGHT SEEM LIKE A GOOD IDEA TO RESET THE MICROLAN,
   AND THE DEVICES ON IT, READY FOR NEXT READ CYCLE... BUT IF
   YOU DO, ALL SORTS OF PROBLEMS ARISE FOR SUBSEQUENT TMSETUPs.
   TIME NEEDED AFTER TMTOUCHRESET BEFORE A TMSETUP CAN BE ISSUED?
   WHATEVER.... REMOVING THIS TMTOUCHRESET MADE A WHOLE BUNCH
   OF PROBLEMS GO AWAY!!

if boSetup then begin //reset microlan
iDMLTmpResult:=TMTouchReset(liHandle);//Done. Reset devices on the
         //Microlan so they are ready for whatever comes next.
  if (iDMLTmpResult<>1)and(iDMLTmpResult<>2) then begin
    ReportError('Problem in DMLGet1820TtureJly06 10jly06b.');
    bTKBErr:=64+bTKBErr;
    iDalErr:=iDMLTmpResult;
    end;
end;// of "if boSetup..."
}

{EVEN if bTKBErr<>0 then.... <-mod of 10jly06... and what follows expanded...}
iDMLTmpResult:=TMEndSession(liHandle);
  if iDMLTmpResult<>1 then begin
    //replace somehow ReportError('Problem in DMLGet1820TtureJly06 10jly06a.');
    bTKBErr:=128+bTkbErr;//64 bit may already be set.
    //needed???boErrorReported:=true;
    iDalErr:=iDMLTmpResult;
    end;

(*I suppose that in some circumstances, leaving the
  session running continuously might work. I opted
  for the simpler and more general answer: Start it
  just before each use, shut it down as soon as not
  needed immediately. There is an entry in the TMEX
  help file suggesting that leaving a session
  running is a bad idea.

  Puzzle....
     Is there a way to do TMExtendedStartSession
     and TMSetUp just once, and then access the api
     multiple times, each with an TMEndSession??
     One attempt at that failed miserably, but I
     think I'd doing just that in some other program.
     Maybe something that only works if only one
     running program is accessing the api?*)

end;(*DMLGet1820Tture*)

function rRawToC(bHi,bLo:byte):real;
(*This little routine is NOT critical to reading the DS1820...
 but you'll probably want it, as it converts the raw two
 bytes returned by DMLGet1820TtureJly06 into a temperature in
 Celsius.

 IT HAS NOT BEEN TESTED AS THOROGHLY as DMLGet1820TtureJly06...
 And I (and others!) have had trouble with the code for
 this conversion in the past, with it not working right
 for negatives or other special cases.

 (BTW.. the DS1820 returns a rogue value sometimes to
 say "I couldn't"... 85 degrees, I think)

 The DS1820 works, essentially, in Celsius. If you want
 Fahrenheit, you're still better converting the raw bytes
 to C, and from there go to F*)

(*This code for handling the two bytes from a DS1820,
 LSB of chip ID: $10. Examples taken from Dallas docs...
 I hope correctly... If code doesn't give these results,
 it is more likely the code that is wrong.

 $0001 is 0.5 degree C
 $0005 is 3.5 d C
 $FFFF is -0.5 d C

 This algorithm only interprets the tture to 0.5 degree C.
 See data sheet for how to get greater resolution.

 This was written from scratch for DS016, routine started
 24 June 03. Ver: 23 June 03...

 It was tested by slowly warming and cooling a DS1820,
 and seemed to work! (Well... over -5 to +5, anyway,
 including dealing with the half degrees properly.

 How do you get negative ttures? Very cold ice, salt,
 alcohol. Pity about the salt, but I suppose I shouldn't
 have drunk the used rubbing alcohol at the end, anyway...
 Actually, I used some (pure?) isopropanol I had on hand
 for circuit board cleaning. Rubbing alcohol, or even a
 bit of wine... and maybe you don't NEED it... should do.
 Put your freeze-mix in an insulated coffee mug for best
 results.

 Oh yes! The system "worked" as far as the DS1820's idea
 of the tture is concerned. The devices are probably
 reliable in that they will always give the same answer
 for the same tture, but there have been reports that
 you may need to calibrate.. i.e. some consistently read
 a few degrees high or low. For all I know, the offset
 between actual and reported is not constant across the
 device's range (-55 to 127, I think it is. More than I'll
 ever use!)*)
var bHths:byte;
begin
if (bLo and 1)=1 then
  bHths:=50 else bHths:=0;
if bHi=$FF then begin (*negative tture*)
  bLo:=NOT bLo;
  bLo:=bLo+1;
  rRawToC:=((bLo div 2)+(bHths / 100))*-1;
end (*no ; here*)
else begin (*+ve tture*)
  rRawToC:=(bLo div 2)+(bHths / 100);
end;(*else*)
end;(*rRawToC*)

function rRawToC18B20(bHi,bLo:byte):real;
(*Crude clone of rRawToC...

 This little routine is NOT critical to reading the DS18B20...
 but you'll probably want it, as it converts the raw two
 bytes returned by DMLGet1820Tturejly06 (which is one routine, shared by
 DS1820s and 18B20s) into a temperature in
 Celsius.

 IT HAS NOT BEEN TESTED AS THOROGHLY as DMLGet1820TtureJly06...
 And I (and others!) have had trouble with the code for
 this conversion in the past, with it not working right
 for negatives or other special cases.

 (BTW.. the DS1820 returns a rogue value sometimes to
 say "I couldn't"... 85 degrees, I think. I presume the
 18B20 does the same.)

 The DS18B20 works, essentially, in Celsius. If you want
 Fahrenheit, you're still better converting the raw bytes
 to C, and from there go to F*)

(*This code for handling the two bytes from a DS18B20,
 LSB of chip ID: $28. Examples taken from Dallas docs...
 I hope correctly... If code doesn't give these results,
 it is more likely the code that is wrong.

 $0008 is 0.5 degree C
 $0550 is 85 d C
 $FFF8 is -0.5 d C  (This and the previous two HAVE been
                      edited to be right for 18B20)

 This algorithm only interprets the tture to 0.0625 degree C.,
 the power up default resolution for the sensor.

 This derives from code written from scratch for DS016, routine started
 24 June 03. Ver: 23 June 03...

 For testing:

 How do you get negative ttures? Very cold ice, salt,
 alcohol. Pity about the salt, but I suppose I shouldn't
 have drunk the used rubbing alcohol at the end, anyway...
 Actually, I used some (pure?) isopropanol I had on hand
 for circuit board cleaning. Rubbing alcohol, or even a
 bit of wine... and maybe you don't NEED it... should do.
 Put your freeze-mix in an insulated coffee mug for best
 results.

 Oh yes! The system "worked" as far as the DS1820's idea
 of the tture is concerned. The devices are probably
 reliable in that they will always give the same answer
 for the same tture, but there have been reports that
 you may need to calibrate.. i.e. some consistently read
 a few degrees high or low. For all I know, the offset
 between actual and reported is not constant across the
 device's range (-55 to 127, I think it is. More than I'll
 ever use!)*)
var rTmp:single;
    liTmp:longint;
begin
liTmp:=bHi;
liTmp:=liTmp*256+bLo;
rTmp:=liTmp;
if ((bHi and $F0)=$F0) then begin (*negative tture << THIS CODE SOMEWHAT SUSPECT!!*)
  liTmp:=(not liTmp)and $FFFF;
  liTmp:=liTmp+1;
  rTmp:=liTmp*-1;
  rRawToC18B20:=rTmp/16;
end (*no ; here*)
else begin (*+ve tture*)
  rRawToC18B20:=rTmp/16
end;(*else*)
end;(*rRawToC18B20*)

function CtoF(rTmp:single):single;
begin
rTmp:=(rTmp*1.8)+32;
result:=rTmp;
end;

end.
