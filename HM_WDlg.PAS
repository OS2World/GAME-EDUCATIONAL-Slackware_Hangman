UNIT HM_WDlg;

(*                                                                      *)
(* Unit defines the selection dialog for hangman.                       *)
(*  - Note: OK button is setup to return cmNull as its Modalresult.     *)
(*                                                                      *)
(* 1998/03/07 - Fixed tab order in dialog.                              *)
(*                                                                      *)

INTERFACE

 USES Classes, Forms, Graphics, Buttons, ExtCtrls, StdCtrls, MMedia;

 TYPE TWordDlg = CLASS(TForm)
                  Panel1    : TPanel;
                  CheckBox1 : TCheckBox;
                  Label1    : TLabel;
                  UserWord  : TEdit;
                  OKBtn     : TBitBtn;
                  CancelBtn : TBitBtn;
                  Sel_Snd   : TAudioDevice;
                  Procedure WordDlgOnShow(Sender : TObject);
                  Procedure OKBtnOnClick(Sender : TObject);
                 PRIVATE
                  {Insert private declarations here}
                 PUBLIC
                  {Insert public declarations here}
                 END;

 VAR WordDlg : TWordDlg;

(************************************************************************)

IMPLEMENTATION

 USES HM_Sup, SysUtils, Dialogs;

(************************************************************************)

 Procedure TWordDlg.WordDlgOnShow(Sender : TObject);
  Begin
   IF NOT(HaveAList)
    THEN BEGIN {no list, user must type in word}
          CheckBox1.Enabled := FALSE;
          CheckBox1.Checked := FALSE;
          UserWord.Focus;
         END {then}
   ELSE CheckBox1.Focus;
  End;

(************************************************************************)

 Procedure TWordDlg.OKBtnOnClick(Sender : TObject);
    VAR TT : STRING[20];
        I  : INTEGER;
        FF : BOOLEAN;
  Begin
   IF NOT(CheckBox1.Checked)
    THEN BEGIN {check word then}
          TT := Trim(UserWord.Text); FF := FALSE;
          FOR I := 1 TO Length(TT) DO
           IF NOT(TT[I] IN GoodASet) THEN FF := TRUE; {non letter found}
          IF (TT = '') OR (Length(TT) < 4) OR (FF)
           THEN BEGIN {error in word typed in}
                 IF UseSound
                  THEN BEGIN {beep them}
                        IF (sf_Beep = '') OR NOT(FileExists(sf_Beep))
                         THEN Beep(750,150)
                        ELSE BEGIN {try to play file}
                              Sel_Snd.FileName := sf_Beep;
                              Sel_Snd.Play;
                             END; {else}
                       END; {then}
                 MessageBox(eWordMsg,mtError,[mbOK]);
                 UserWord.Focus;
                END {then}
          ELSE BEGIN {setup and leave}
                UserWord.Text := TT;
                DismissDlg(mrOK);
               END; {else}
         END {then}
   ELSE DismissDlg(mrOK);
  End;

(************************************************************************)

INITIALIZATION
 RegisterClasses([TWordDlg, TPanel, TBitBtn,
                  TAudioDevice, TCheckBox, TLabel, TEdit]);
END. (*of unit*)
