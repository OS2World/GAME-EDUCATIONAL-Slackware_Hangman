PROGRAM HangMan;

(*                                                                      *)
(* AUTHOR: Michael G. Slack                    DATE WRITTEN: 1998/02/21 *)
(* ENVIRONMENT: Sibyl                                                   *)
(*                                                                      *)
(* Program to play the game of hangman.                                 *)
(*                                                                      *)

 USES Forms, Graphics, HM_Win, HM_WDlg, HM_GDlg, HM_SDlg, HM_About;

{$r HangMan.SCU}
{$IFDEF OS2}
 {$R HangMan.SRF}
{$ELSE}
 {$R HangMan.SRW}
{$ENDIF}

BEGIN (*main*)
 Application.Create;
 Application.CreateForm(THangWin, HangWin);
 Application.Run;
 Application.Destroy;
END. (*main*)
