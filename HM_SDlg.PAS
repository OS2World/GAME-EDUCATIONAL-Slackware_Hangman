UNIT HM_SDlg;

(*                                                                      *)
(* Unit defines the options/settings dialog for HangMan.                *)
(*                                                                      *)
(* 1998/03/07 - Fixed tab order on settings pages.                      *)
(* 1998/03/29 - Added a trackbar to set difficulty level (number of     *)
(*              guesses before drawing next piece to hangman.           *)
(* 2001/02/20 - Removed a click event from one of the sound file edit   *)
(*              fields.  Prevented user from manually changing the file *)
(*              name.                                                   *)
(*                                                                      *)

INTERFACE

 USES Classes, Forms, Graphics, TabCtrls, Buttons, Dialogs, StdCtrls, ComCtrls;

 TYPE TSettingsDlg = CLASS(TForm)
                      SettingsTNB : TTabbedNotebook;
                      {page 1}
                      Label1      : TLabel;
                      WordF       : TEdit;
                      WLBtn       : TButton;
                      PromptCB    : TCheckBox;
                      CB_Sound    : TCheckBox;
                      Label7      : TLabel;
                      TB_Dif      : TTrackBar;
                      Label8      : TLabel;
                      Label9      : TLabel;
                      Label10     : TLabel;
                      {page 2}
                      Label2      : TLabel;
                      BeepEdit    : TEdit;
                      BeepBtn     : TButton;
                      Label3      : TLabel;
                      HungEdit    : TEdit;
                      HungBtn     : TButton;
                      Label4      : TLabel;
                      FinEdit     : TEdit;
                      FinBtn      : TButton;
                      Label5      : TLabel;
                      GG_Edit     : TEdit;
                      GG_Btn      : TButton;
                      Label6      : TLabel;
                      WG_Edit     : TEdit;
                      WG_Btn      : TButton;
                      {other dialog controls}
                      OKBtn       : TBitBtn;
                      CancelBtn   : TBitBtn;
                      OpenDlg     : TOpenDialog;
                      SndODlg     : TOpenDialog;
                      Procedure SettingsDlgOnShow(Sender : TObject);
                      Procedure OKBtnOnClick(Sender : TObject);
                      Procedure WLBtnOnClick(Sender : TObject);
                      Procedure SFBtnOnClick(Sender : TObject);
                     PRIVATE
                      {Insert private declarations here}
                     PUBLIC
                      {Insert public declarations here}
                     END;

 VAR SettingsDlg : TSettingsDlg;

(************************************************************************)

IMPLEMENTATION

 USES SysUtils, HM_Sup;

(************************************************************************)

 Procedure TSettingsDlg.SettingsDlgOnShow(Sender : TObject);
  Begin
   WordF.Text := WordListFn;
   PromptCB.Checked := PromptMe;
   CB_Sound.Checked := UseSound;
   TB_Dif.Position := NumB4Draw;
   WordF.Focus; {set focus on first control}
   {set up sound edits}
   BeepEdit.Text := sf_Beep;
   HungEdit.Text := sf_Hung;
   FinEdit.Text := sf_Finish;
   GG_Edit.Text := sf_GoodG;
   WG_Edit.Text := sf_BadG;
  End;

(************************************************************************)

 Procedure TSettingsDlg.OKBtnOnClick(Sender : TObject);
    VAR TT : STRING;
  Begin
   UseSound := CB_Sound.Checked; {settings/page 1}
   PromptMe := PromptCB.Checked;
   NumB4Draw := TB_Dif.Position;
   TT := Trim(WordF.Text);
   IF FileExists(TT) THEN WordListFn := TT;
   {settings page 2 save}
   TT := Trim(BeepEdit.Text);
   IF FileExists(TT) THEN sf_Beep := TT;
   TT := Trim(HungEdit.Text);
   IF FileExists(TT) THEN sf_Hung := TT;
   TT := Trim(FinEdit.Text);
   IF FileExists(TT) THEN sf_Finish := TT;
   TT := Trim(GG_Edit.Text);
   IF FileExists(TT) THEN sf_GoodG := TT;
   TT := Trim(WG_Edit.Text);
   IF FileExists(TT) THEN sf_BadG := TT;
   DismissDlg(mrOK);
  End;

(************************************************************************)

 Procedure TSettingsDlg.WLBtnOnClick(Sender : TObject);
  Begin
   OpenDlg.FileName := WordF.Text;
   IF OpenDlg.Execute THEN WordF.Text := OpenDlg.FileName;
  End;

(************************************************************************)

 Procedure TSettingsDlg.SFBtnOnClick(Sender : TObject);
     (* procedure used generically by all the sound buttons *)
    VAR SS : STRING;
  Begin
   SS := '';
   IF Sender = BeepBtn
    THEN SS := BeepEdit.Text
   ELSE IF Sender = HungBtn
         THEN SS := HungEdit.Text
        ELSE IF Sender = FinBtn
              THEN SS := FinEdit.Text
             ELSE IF Sender = GG_Btn
                   THEN SS := GG_Edit.Text
                  ELSE IF Sender = WG_Btn
                        THEN SS := WG_Edit.Text;
   IF (SS <> '') AND (FileExists(SS))
    THEN SndODlg.FileName := SS;
   IF SndODlg.Execute
    THEN BEGIN {save new file name}
          SS := Trim(SndODlg.FileName);
          IF (SS <> '') AND NOT(FileExists(SS)) THEN SS := '';
          IF Sender = BeepBtn
           THEN BeepEdit.Text := SS
          ELSE IF Sender = HungBtn
                THEN HungEdit.Text := SS
               ELSE IF Sender = FinBtn
                     THEN FinEdit.Text := SS
                    ELSE IF Sender = GG_Btn
                          THEN GG_Edit.Text := SS
                         ELSE IF Sender = WG_Btn
                               THEN WG_Edit.Text := SS;
         END; {then}
  End;

(************************************************************************)

INITIALIZATION
 RegisterClasses([TSettingsDlg, TTabbedNotebook, TBitBtn, TOpenDialog, TLabel,
                  TEdit, TButton, TCheckBox, TTrackBar]);
END. (*of unit*)
