UNIT HM_Sup;

(*                                                                      *)
(* Unit defines the global constants used by hangman.                   *)
(* - All text and localization values should be located here.           *)
(*                                                                      *)
(* 1998/03/29 - Added new option (NumB4Draw) to global list.            *)
(*                                                                      *)

INTERFACE

 CONST bmid_0 = 1000; {empty gallow}
       bmid_1 = 1001; {with head}
       bmid_2 = 1002; {with body}
       bmid_3 = 1003; {with one arm}
       bmid_4 = 1004; {with both arms}
       bmid_5 = 1005; {with one leg}
       bmid_6 = 1006; {hung!}
       {sound constants}
       sid_Beep   = 0;
       sid_Hung   = 1;
       sid_Finish = 2;
       sid_GoodG  = 3;
       sid_BadG   = 4;
       {sound files}
       sf_Beep   : STRING = '';
       sf_Hung   : STRING = '';
       sf_Finish : STRING = '';
       sf_GoodG  : STRING = '';
       sf_BadG   : STRING = '';
       {ini string constants (application/key)}
       Ini_Pos   : STRING[14] = 'WindowPosition';
       Ini_PTop  : STRING[3]  = 'Top';
       Ini_PLeft : STRING[4]  = 'Left';
       Ini_Opt   : STRING[7]  = 'Options';
       Ini_OWrds : STRING[8]  = 'WordList';
       Ini_OPrmt : STRING[9]  = 'PromptsOn';
       Ini_OSnd  : STRING[8]  = 'UseSound';
       Ini_ONum  : STRING[9]  = 'NumB4Draw';
       Ini_Snds  : STRING[6]  = 'Sounds';
       Ini_SKey1 : STRING[9]  = 'BeepSound';
       Ini_SKey2 : STRING[9]  = 'HungSound';
       Ini_SKey3 : STRING[11] = 'FinishSound';
       Ini_SKey4 : STRING[9]  = 'GoodGuess';
       Ini_SKey5 : STRING[8]  = 'BadGuess';
       {global options/default values}
       DefWrdLst : STRING[12] = 'HM_Words.TXT';
       PromptMe  : BOOLEAN = FALSE;
       UseSound  : BOOLEAN = TRUE;
       NumB4Draw : INTEGER = 1;
       HaveAList : BOOLEAN = TRUE;
       {various constants used}
       MaxAlphas = 26;
       GoodASet  = ['A'..'Z'];
       FirstLet  = BYTE('A');
       NewBtnTxt : STRING[4]  = '~New';
       StartBTxt : STRING[6]  = '~Start';
       {prompt and error strings}
       pStartNew : STRING[15] = 'Start new word?';
       eWordMsg  : STRING[21] = 'Invalid word entered!';
       eGNeedMsg : STRING[22] = 'Need to enter a guess.';
       eGOnlyMsg : STRING[30] = 'Can only enter letter or word.';
       eGAlready : STRING[39] = 'Letter guessed already used, try again.';
       eCNotLet  : STRING[36] = 'Not a letter in the word, try again.';
       eCNotWord : STRING[24] = 'Not the word, try again.';
       eCHung    : STRING[41] = 'Whoops, you are now swinging in the wind.';
       mCDone    : STRING[25] = 'You''ve guessed the word!';
       mCGoodLet : STRING[22] = 'Good letter, go again.';
       mQuitM    : STRING[12] = 'Really quit?';

 VAR WordListFn   : STRING;
     FUsedLetters : STRING[30];

(************************************************************************)

IMPLEMENTATION

(************************************************************************)

END. (*of unit*)
