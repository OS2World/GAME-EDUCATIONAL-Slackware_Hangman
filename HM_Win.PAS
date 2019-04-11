UNIT HM_Win;

(*                                                                      *)
(* AUTHOR: Michael G. Slack                    DATE WRITTEN: 1998/02/21 *)
(* ENVIRONMENT: Sibyl                                                   *)
(*                                                                      *)
(* Program plays a simple game of hangman.  Either picks a word from a  *)
(* list (loaded from HM_Words.TXT file) or allows for a word to be typed*)
(* in.  For best enjoyment, words should be at least 4 characters long  *)
(* and length is limited to 20 characters.                              *)
(* This unit defines the main window used by the program.               *)
(*                                                                      *)
(* -------------------------------------------------------------------- *)
(*                                                                      *)
(* REVISED: 1998/02/25 - Initial version complete.  (1.00)              *)
(*          1998/03/07 - Fixed tab order in dialogs.  (1.01)            *)
(*          1998/03/29 - Added in an option to allow a variable number  *)
(*                       guesses before drawing the next piece.  This   *)
(*                       option allows 1 - 3 guesses which will make it *)
(*                       easier for younger children.  (1.02)           *)
(*          1999/11/08 - Modified version/date.  Cleaned up code. (1.03)*)
(*                                                                      *)

INTERFACE

 USES Classes, Forms, Menus, Graphics, ExtCtrls, StdCtrls, Buttons, MMedia;

 TYPE THangWin = CLASS (TForm)
                  Bevel1      : TBevel; {frame around used letters}
                  UsedLetters : TLabel;
                  Label1      : TLabel;
                  Bevel2      : TBevel; {hang man picture}
                  HM_Pic      : TImage;
                  Label2      : TLabel;
                  Bevel3      : TBevel; {frame around word to guess}
                  WordToGuess : TLabel;
                  Label3      : TLabel; {score boxes}
                  NumG        : TLabel; {guessed}
                  Label4      : TLabel;
                  NumM        : TLabel; {missed}
                  StartBtn    : TBitBtn;
                  GuessBtn    : TBitBtn;
                  OptionBtn   : TBitBtn;
                  ExitBtn     : TBitBtn;
                  PU_Win      : TPopupMenu;
                  PU_AboutMI  : TMenuItem;
                  HM_Sound    : TAudioDevice;
                  Procedure HangWinOnCreate(Sender : TObject);
                  Procedure HangWinOnShow(Sender : TObject);
                  Procedure HangWinOnDestroy(Sender : TObject);
                  Procedure HangWinOnCloseQuery(Sender : TObject;
                                                Var CanClose : Boolean);
                  Procedure StartBtnOnClick(Sender : TObject);
                  Procedure GuessBtnOnClick(Sender : TObject);
                  Procedure OptionBtnOnClick(Sender : TObject);
                  Procedure PU_AboutMIOnClick(Sender : TObject);
                 PRIVATE
                  NumGuessed,
                  NumMissed,
                  B4_Draw,
                  PicNum,
                  OldTop,
                  OldLeft      : INTEGER;
                  FHiddenWord,
                  FWordToGuess : STRING[20];
                  FWordList    : TSTRINGLIST;
                  HM_Images    : TBITMAPLIST;
                  Ini_Fn,
                  EXE_Path     : STRING;
                  FNewFlg      : BOOLEAN;
                 PUBLIC
                  PROCEDURE ReadINI;
                  PROCEDURE WriteINI;
                  PROCEDURE ReadWordList;
                  FUNCTION  GetWordToUse : BOOLEAN;
                  FUNCTION  CheckLetter(Ch : CHAR) : BOOLEAN;
                  PROCEDURE Check_Done(F : BOOLEAN; TT : BYTE);
                  PROCEDURE DoTheSound(Which : INTEGER);
                 END;

 VAR HangWin : THangWin;

(************************************************************************)

IMPLEMENTATION

 USES SysUtils, IniFiles, Dialogs,
      HM_Sup, HM_WDlg, HM_GDlg, HM_SDlg, HM_About;

(************************************************************************)

 Procedure THangWin.HangWinOnCreate(Sender : TObject);
    CONST DirDiv : CHAR = '\';
    VAR I : INTEGER;
  Begin
   FNewFlg := FALSE; {game has not started yet}
   HM_Sound.AliasName := 'S_Audio_Main'; {change to not conflict with dlgs}
   {create string list object}
   FWordList := TSTRINGLIST.Create;
   FWordList.Sorted := TRUE;
   FWordList.Duplicates := dupIgnore;
   {create bitmap list}
   HM_Images := TBITMAPLIST.Create;
   {create exe path}
   EXE_Path := Application.ExeName;
   I := Length(EXE_Path);
   WHILE (I > 0) AND (EXE_Path[I] <> DirDiv) DO
    Dec(I);
   SetLength(EXE_Path,I);
   IF EXE_Path = '' THEN EXE_Path := '.\';
   IF EXE_Path[Length(EXE_Path)] <> DirDiv THEN EXE_Path := EXE_Path + DirDiv;
   WordListFn := EXE_Path + DefWrdLst;
   {load up images now}
   FOR I := bmid_0 TO bmid_6 DO
    HM_Images.AddResourceID(I); {[0] to [6] = gallow bitmaps}
   HM_Pic.Bitmap := HM_Images.Bitmaps[0]; {display empty gallow}
   {zero scores}
   NumGuessed := 0; NumMissed := 0;
  End;

(************************************************************************)

 Procedure THangWin.HangWinOnShow(Sender : TObject);
  Begin
   Top := (Screen.Height DIV 2) - (Height DIV 2); {default position}
   Left := (Screen.Width DIV 2) - (Width DIV 2);
   {initialize rest of stuff}
   Ini_Fn := GetDefaultINI;
   Randomize;
   ReadINI;
   OldTop := Top; OldLeft := Left; {save old position}
   ReadWordList;
  End;

(************************************************************************)

 Procedure THangWin.HangWinOnDestroy(Sender : TObject);
    VAR Ini : TINIFILE;
  Begin
   FWordList.Free; {delete word list}
   HM_Images.Free; {delete image list}
   {check if position needs to be saved or not}
   IF (Top <> OldTop) OR (Left <> OldLeft)
    THEN BEGIN {only save if changed}
          Ini := TINIFILE.Create(Ini_Fn);
          Ini.WriteInteger(Ini_Pos,Ini_PTop,Top);
          Ini.WriteInteger(Ini_Pos,Ini_PLeft,Left);
          Ini.Free;
         END; {then}
  End;

(************************************************************************)

 Procedure THangWin.HangWinOnCloseQuery(Sender : TObject;
                                        Var CanClose : Boolean);
    VAR Ret : TMSGDLGRETURN;
  Begin
   Ret := mrYes; {close if prompting is not on}
   IF PromptMe
    THEN BEGIN {prompt user}
          IF UseSound THEN DoTheSound(sid_Beep);
          Ret := MessageBox(mQuitM,mtConfirmation,[mbYes,mbNo]);
         END; {then}
   CanClose := Ret = mrYes;
  End;

(************************************************************************)

 Procedure THangWin.StartBtnOnClick(Sender : TObject);
    VAR Ret : TMSGDLGRETURN;
        I   : INTEGER;
  Begin
   IF FNewFlg AND PromptMe
    THEN BEGIN {prompt user to start with new word}
          IF UseSound THEN DoTheSound(sid_Beep);
          Ret := MessageBox(pStartNew,mtConfirmation,[mbYes,mbNo]);
          IF Ret <> mrYes THEN Exit; {don't start new word}
         END; {then}
   IF NOT(GetWordToUse) THEN Exit; {canceled word to use dlg}
   {reset gallows}
   PicNum := 0; B4_Draw := 0;
   HM_Pic.Bitmap := HM_Images.Bitmaps[PicNum];
   FWordToGuess := '';
   FOR I := 1 TO Length(FHiddenWord) DO
    FWordToGuess := FWordToGuess + '-'; {set display word to '_'}
   FUsedLetters := '';
   FOR I := 1 TO MaxAlphas DO
    FUsedLetters := FUsedLetters + ' '; {set to all spaces}
   UsedLetters.Caption := FUsedLetters;
   WordToGuess.Caption := FWordToGuess;
   StartBtn.Caption := NewBtnTxt;
   GuessBtn.Enabled := TRUE;
   GuessBtn.Focus;
  End;

(************************************************************************)

 Procedure THangWin.GuessBtnOnClick(Sender : TObject);
    VAR Ret : TMSGDLGRETURN;
        T1  : STRING[1];
        T2  : STRING[20];
        I   : BYTE;
        F   : BOOLEAN;
  Begin
   GuessDlg := TGUESSDLG.Create(Self);
   GuessDlg.Left := Left + 30; GuessDlg.Top := Top + 166;
   Ret := GuessDlg.ShowModal;
   IF Ret = mrOK
    THEN BEGIN {save off guess}
          T1 := GuessDlg.LetterG.Text;
          T2 := GuessDlg.WordG.Text;
         END; {then}
   GuessDlg.Free;
   IF Ret = mrOK
    THEN BEGIN {check guess now}
          IF T1 <> ''
           THEN BEGIN {check letter entered}
                 I := 1;
                 UsedLetters.Caption := FUsedLetters;
                 F := CheckLetter(T1[1]);
                END {then}
          ELSE BEGIN {checkword}
                I := 2;
                F := T2 = FHiddenWord;
                IF F THEN FWordToGuess := T2;
               END; {else}
          Check_Done(F,I);
         END; {then}
  End;

(************************************************************************)

 Procedure THangWin.OptionBtnOnClick(Sender : TObject);
    VAR Ret   : TMSGDLGRETURN;
        SavFn : STRING;
  Begin
   SavFn := WordListFn; {save off a copy}
   SettingsDlg := TSETTINGSDLG.Create(Self);
   SettingsDlg.Left := Left + 2; SettingsDlg.Top := Top + 20;
   Ret := SettingsDlg.ShowModal;
   SettingsDlg.Free;
   IF Ret = mrOK
    THEN BEGIN {good dialog return}
          WriteINI; {save settings}
          IF Copy(SavFn,1,Length(SavFn)) <> WordListFn
           THEN ReadWordList; {reload list - changed files}
         END; {then}
  End;

(************************************************************************)

 Procedure THangWin.PU_AboutMIOnClick(Sender : TObject);
  Begin
   AboutBox1 := TABOUTBOX1.Create(Self);
   AboutBox1.Left := Left + 1; AboutBox1.Top := Top + 50;
   AboutBox1.ShowModal;
   AboutBox1.Free;
  End;

(************************************************************************)

 PROCEDURE THangWin.ReadINI;
     (* procedure to read the ini entries at startup *)

    VAR Ini : TINIFILE;

  BEGIN (*thangwin.readini*)
   Ini := TINIFILE.Create(Ini_Fn);
   {read in window position (just top and left)}
   Top := Ini.ReadInteger(Ini_Pos,Ini_PTop,Top);
   Left := Ini.ReadInteger(Ini_Pos,Ini_PLeft,Left);
   {read in options}
   WordListFn := Ini.ReadString(Ini_Opt,Ini_OWrds,WordListFn);
   PromptMe := Ini.ReadBool(Ini_Opt,Ini_OPrmt,PromptMe);
   UseSound := Ini.ReadBool(Ini_Opt,Ini_OSnd,UseSound);
   NumB4Draw := Ini.ReadInteger(Ini_Opt,Ini_ONum,NumB4Draw);
   {read in sound files picked}
   sf_Beep := Ini.ReadString(Ini_Snds,Ini_SKey1,sf_Beep);
   sf_Hung := Ini.ReadString(Ini_Snds,Ini_SKey2,sf_Hung);
   sf_Finish := Ini.ReadString(Ini_Snds,Ini_SKey3,sf_Finish);
   sf_GoodG := Ini.ReadString(Ini_Snds,Ini_SKey4,sf_GoodG);
   sf_BadG := Ini.ReadString(Ini_Snds,Ini_SKey5,sf_BadG);
   Ini.Free;
  END; (*thangwin.readini*)

(************************************************************************)

 PROCEDURE THangWin.WriteINI;
     (* procedure to write out to the ini file the options *)

    VAR Ini : TINIFILE;

  BEGIN (*thangwin.writeini*)
   Ini := TINIFILE.Create(Ini_Fn);
   {write out options}
   Ini.WriteString(Ini_Opt,Ini_OWrds,WordListFn);
   Ini.WriteBool(Ini_Opt,Ini_OPrmt,PromptMe);
   Ini.WriteBool(Ini_Opt,Ini_OSnd,UseSound);
   Ini.WriteInteger(Ini_Opt,Ini_ONum,NumB4Draw);
   {write out sounds}
   Ini.WriteString(Ini_Snds,Ini_SKey1,sf_Beep);
   Ini.WriteString(Ini_Snds,Ini_SKey2,sf_Hung);
   Ini.WriteString(Ini_Snds,Ini_SKey3,sf_Finish);
   Ini.WriteString(Ini_Snds,Ini_SKey4,sf_GoodG);
   Ini.WriteString(Ini_Snds,Ini_SKey5,sf_BadG);
   Ini.Free;
  END; (*thangwin.writeini*)

(************************************************************************)

 PROCEDURE THangWin.ReadWordList;
     (* procedure to read in word list file into string list *)

    VAR F : TEXTFILE;
        S : STRING;
        W : STRING[20];

  BEGIN (*thangwin.readwordlist*)
   FWordList.Clear; {empty the word list}
   HaveAList := FALSE;
   System.Assign(F,WordListFn);
   {$I-} Reset(F); {$I+}
   IF IOResult <> 0 THEN Exit;
   WHILE NOT(EOF(F)) DO
    BEGIN {read word list file}
     Readln(F,S); W := UpperCase(Copy(S,1,20));
     FWordList.Add(Trim(W));
    END; {while}
   System.Close(F);
   HaveAList := FWordList.Count > 9; {list should have more than 10 words}
  END; (*thangwin.readwordlist*)

(************************************************************************)

 FUNCTION THangWin.GetWordToUse : BOOLEAN;
     (* function to run word to use dialog *)

    FUNCTION GetWordFromList : STRING;
        (* local to random select word from word list *)
       VAR I, J : INTEGER;
     BEGIN (*getwordfromlist*)
      I := FWordList.Count;
      J := Random(I); {j = 0 to count-1}
      Result := FWordList[J]; {pick word off list at j}
     END; (*getwordfromlist*)

    VAR Ret : TMSGDLGRETURN;

  BEGIN (*thangwin.getwordtouse*)
   WordDlg := TWORDDLG.Create(Self);
   WordDlg.Left := Left + 25; WordDlg.Top := Top + 70;
   Ret := WordDlg.ShowModal;
   IF Ret = mrOK
    THEN BEGIN {save off stuff}
          IF WordDlg.CheckBox1.Checked
           THEN FHiddenWord := GetWordFromList
          ELSE FHiddenWord := WordDlg.UserWord.Text;
         END; {then}
   WordDlg.Free;
   Result := Ret = mrOK;
  END; (*thangwin.getwordtouse*)

(************************************************************************)

 FUNCTION THangWin.CheckLetter(Ch : CHAR) : BOOLEAN;
     (* function to check letter entered *)

    VAR I : INTEGER;

  BEGIN (*thangwin.checkletter*)
   Result := FALSE;
   FOR I := 1 TO Length(FHiddenWord) DO
    IF FHiddenWord[I] = Ch
     THEN BEGIN {found match}
           Result := TRUE;
           FWordToGuess[I] := Ch;
          END; {then}
  END; (*thangwin.checkletter*)

(************************************************************************)

 PROCEDURE THangWin.Check_Done(F : BOOLEAN; TT : BYTE);
     (* procedure to see if end of guess cycle or not *)

    VAR SS : STRING[80];
        FF : BOOLEAN;

  BEGIN (*thangwin.check_done*)
   WordToGuess.Caption := FWordToGuess; FF := FALSE;
   IF NOT(F)
    THEN BEGIN {bad guess}
          Inc(B4_Draw);
          IF B4_Draw >= NumB4Draw
           THEN BEGIN {inc pic num/show next picture/reset b4_draw}
                 Inc(PicNum); B4_Draw := 0;
                 {show next picture}
                 HM_Pic.Bitmap := HM_Images.Bitmaps[PicNum];
                END; {then}
          CASE TT OF
           1 : SS := eCNotLet;
           2 : SS := eCNotWord;
          END; {case}
          IF PicNum = 6
           THEN BEGIN {all done - well hung now}
                 SS := eCHung; FF := TRUE; Inc(NumMissed);
                 WordToGuess.Caption := FHiddenWord;
                END; {then}
         END {then}
   ELSE BEGIN {good guess - is word complete}
         IF FHiddenWord = Copy(FWordToGuess,1,Length(FHiddenWord))
          THEN BEGIN {all done - word filled in}
                SS := mCDone; FF := TRUE; Inc(NumGuessed);
               END {then}
         ELSE SS := mCGoodLet;
        END; {else}
   IF UseSound
    THEN BEGIN {play sound}
          IF FF
           THEN BEGIN {hung or finished}
                 IF F THEN DoTheSound(sid_Finish) ELSE DoTheSound(sid_Hung);
                END {then}
          ELSE BEGIN {good or wrong guess of letter then}
                IF F THEN DoTheSound(sid_GoodG) ELSE DoTheSound(sid_BadG);
               END; {else}
         END; {then}
   NumG.Caption := IntToStr(NumGuessed);
   NumM.Caption := IntToStr(NumMissed);
   MessageBox(SS,mtInformation,[mbOK]);
   IF FF
    THEN BEGIN {reset buttons}
          StartBtn.Focus;
          GuessBtn.Enabled := FALSE;
         END; {then}
  END; (*thangwin.check_done*)

(************************************************************************)

 PROCEDURE THangWin.DoTheSound(Which : INTEGER);
     (* procedure to setup and play the sound *)

    VAR SS : STRING;

  BEGIN (*thangwin.dothesound*)
   {check for sound playing from before and stop it}
   IF HM_Sound.DeviceMode = dmPlaying THEN HM_Sound.Stop;
   SS := '';
   CASE Which OF
    sid_Beep   : SS := sf_Beep;
    sid_Hung   : SS := sf_Hung;
    sid_Finish : SS := sf_Finish;
    sid_GoodG  : SS := sf_GoodG;
    sid_BadG   : SS := sf_BadG;
   END; {case}
   IF (SS = '') OR NOT(FileExists(SS))
    THEN Beep(750,150)
   ELSE BEGIN {try to play file}
         HM_Sound.FileName := SS;
         HM_Sound.Play;
        END; {else}
  END; (*thangwin.dothesound*)

(************************************************************************)

INITIALIZATION
 RegisterClasses([THangWin, TBevel, TLabel, TBitBtn, TImage, TPopupMenu,
                  TMenuItem, TAudioDevice]);
END. (*of unit*)
