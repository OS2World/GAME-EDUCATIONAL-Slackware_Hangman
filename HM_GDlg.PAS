UNIT HM_GDlg;

(*                                                                      *)
(* Unit defines the guess dialog used by HangMan.                       *)
(*  - Note: OK button is set to return cmNull in ModalResult.           *)
(*                                                                      *)
(* 1998/03/07 - Fixed label focus to edit boxes.                        *)
(*                                                                      *)

INTERFACE

 USES Classes, Forms, Graphics, Buttons, ExtCtrls, StdCtrls, MMedia;

 TYPE TGuessDlg = CLASS(TForm)
                   Label1    : TLabel;
                   LetterG   : TEdit;
                   Label2    : TLabel;
                   Label3    : TLabel;
                   WordG     : TEdit;
                   Guess_Snd : TAudioDevice;
                   OKBtn     : TBitBtn;
                   CancelBtn : TBitBtn;
                   Procedure GuessDlgOnShow(Sender : TObject);
                   Procedure OKBtnOnClick(Sender : TObject);
                  PRIVATE
                   PROCEDURE Do_Sound;
                  PUBLIC
                   {Insert public declarations here}
                  END;

 VAR GuessDlg : TGuessDlg;

(************************************************************************)

IMPLEMENTATION

 USES SysUtils, Dialogs, HM_Sup;

(************************************************************************)

 Procedure TGuessDlg.GuessDlgOnShow(Sender : TObject);
  Begin
   LetterG.Focus;
  End;

(************************************************************************)

 Procedure TGuessDlg.OKBtnOnClick(Sender : TObject);
    VAR T1 : STRING[1];
        T2 : STRING[20];
        Ch : BYTE;
  Begin
   T1 := Trim(LetterG.Text);
   T2 := Trim(WordG.Text);
   IF (T1 = '') AND (T2 = '')
    THEN BEGIN {need to enter guess}
          IF UseSound THEN Do_Sound;
          MessageBox(eGNeedMsg,mtError,[mbOK]);
          LetterG.Focus;
          Exit;
         END; {then}
   IF (T1 <> '') AND (T2 <> '')
    THEN BEGIN {can only enter one}
          IF UseSound THEN Do_Sound;
          MessageBox(eGOnlyMsg,mtError,[mbOK]);
          LetterG.Focus;
          Exit;
         END; {then}
   IF T1 <> ''
    THEN BEGIN {check letter to make sure not used}
          Ch := BYTE(T1[1]) - FirstLet + 1;
          IF FUsedLetters[Ch] <> ' '
           THEN BEGIN {already used - message them}
                 IF UseSound THEN Do_Sound;
                 MessageBox(eGAlready,mtError,[mbOK]);
                 LetterG.Focus;
                 Exit;
                END {then}
          ELSE FUsedLetters[Ch] := T1[1];
         END; {then}
   LetterG.Text := T1;
   WordG.Text := T2;
   DismissDlg(mrOK);
  End;

(************************************************************************)

 PROCEDURE TGuessDlg.Do_Sound;
     (* procedure to run sound if wanted *)

  BEGIN (*tguessdlg.do_sound*)
   IF (sf_Beep = '') OR NOT(FileExists(sf_Beep))
    THEN Beep(750,150)
   ELSE BEGIN {try to play file}
         Guess_Snd.FileName := sf_Beep;
         Guess_Snd.Play;
        END; {else}
  END; (*tguessdlg.do_sound*)

(************************************************************************)

INITIALIZATION
 RegisterClasses([TGuessDlg, TBitBtn, TLabel, TEdit, TAudioDevice]);
END. (*of unit*)
