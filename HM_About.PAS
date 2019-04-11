UNIT HM_About;

(*                                                                      *)
(* Unit defines the about dialog for HangMan.                           *)
(*                                                                      *)
(* 1998/03/07 - Changed version number and date.                        *)
(* 1998/03/29 -  " " "   " " "   " "    "   "                           *)
(* 1999/11/08 -  " " "   " " "   " "    "   "                           *)
(* 2000/06/16 -  " " "   " " "   " "    "   "                           *)
(* 2001/03/27 -  " " "   " " "   " "    "   "                           *)
(*                                                                      *)

INTERFACE

 USES Classes, Forms, Graphics, ExtCtrls, Buttons, StdCtrls;

 TYPE TAboutBox1 = CLASS(TForm)
                    Panel1      : TPanel;
                    ProgramIcon : TImage;
                    OkButton    : TBitBtn;
                    ProductName : TLabel;
                    Version     : TLabel;
                    Copyright   : TLabel;
                    Comment     : TLabel;
                   PRIVATE
                    {Insert private declarations here}
                   PUBLIC
                    {Insert public declarations here}
                   END;

 VAR AboutBox1: TAboutBox1;

(************************************************************************)

IMPLEMENTATION

(************************************************************************)

INITIALIZATION
 RegisterClasses([TAboutBox1, TPanel, TImage, TBitBtn, TLabel]);
END.
