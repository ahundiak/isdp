 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*\
	COcpattrdef.h
\*/

#ifndef COcpattrdef.h
#define COcpattrdef.h

/* Forms Index */
#define COPYSYMB        91
#define COPYTXSYMB      92
#define LISTNAMES       93
#define LISTNAMESOID    94

/* Error Codes */
#define INVALIDINPUT  	1001
#define FILEEXISTS	1003
#define FILENOTOPEN	1005
#define FILEISDIR	1007

/* Copy Symbology Gadget Labels */
#define LyInt       23
#define LyAlp       18
#define LyBoo       21
#define CoInt       12
#define CoAlp       13
#define CoBoo       19
#define WtInt       14
#define WtBoo       20
#define StInt       16
#define StBoo       22
#define FtBoo       28
#define FtAlp       27
#define HtBoo       31
#define HtAlp       43
#define WdBoo       33
#define WdAlp       42
#define CsBoo       36
#define CsDou       40
#define LsBoo       35
#define LsDou       39
#define TjBoo       32
#define TjInt       37
#define TjAlp       38
#define ViBoo       50
#define ViSta       51

/* Copy Symbology Form Function Labels */
#define CSHelp       4        /* Help Button                */
#define CSQuit       1        /* Quit Button                */
#define CSMsg       10        /* Message Field              */
#define GetSymb     23        /* Extract Symbology          */
#define CopySymb    24        /* Copy Symb to Element       */
#define MakeActSymb 25        /* Copy Symb to Active Symb   */

/* Copy Symbology Status for no active button. */
#define CSNONEACT   51
#define CSGETSYMB   53
#define CSCOPYSYMB  55
#define CSQUIT      57

/* Toggles for Setting CS_mask (IGRulong) */
#define LyTog       0x1       /* .... .... ....  .... ...1  LEVEL             */
#define CoTog       0x2       /* .... .... ....  .... ..1.  COLOR             */
#define WtTog       0x4       /* .... .... ....  .... .1..  WEIGHT            */
#define StTog       0x8       /* .... .... ....  .... 1...  STYLE             */
#define FtTog       0x10      /* .... .... ....  ...1 ....  FONT              */
#define HtTog       0x40      /* .... .... ....  .1.. ....  TEXT HEIGHT       */
#define WdTog       0x80      /* .... .... ....  1... ....  TEXT WIDTH        */
#define CsTog       0x100     /* .... .... ...1  .... ....  CHARACTER SPAC    */
#define LsTog       0x200     /* .... .... ..1.  .... ....  LINE SPAC         */
#define TjTog       0x400     /* .... .... .1..  .... ....  TEXT JUSTIF       */
#define TiTog       0x800     /* .... .... 1...  .... ....  TEXT VIEW INDEP   */
#define ExTog       0x1000    /* .... ...1 ....  .... ....  EXTRACT           */
#define CpTog       0x2000    /* .... ..1. ....  .... ....  COPY              */
#define ViTog	    0x4000    /* .... .1.. ....  .... ....  VIEW INDEPENDENT  */
#define QuitTog     0x8000    /* .... 1... ....  .... ....  QUIT BUTTON       */
#define HelpTog     0x10000   /* ...1 .... ....  .... ....  HELP BUTTON       */
#define MakeTog     0x20000   /* ..1. .... ....  .... ....  MAKE BUTTON       */

#define CS_UPD_MASK      (LyTog | CoTog | WtTog | StTog)
#define CTS_UPD_MASK     (LyTog | CoTog | WtTog | FtTog | HtTog | WdTog | CsTog | LsTog | TjTog )

/* Macros for manipulating CS_mask */
#define   _active(x)     ( me->CS_mask & (x) )
#define   _toggle(x)       me->CS_mask ^= (x)
#define   _on(x)           me->CS_mask |= (x)
#define   _is_on(x,y)    ( (x)  & (y) )
#define   _off(x)          me->CS_mask &= ( ~(x) )
#define   _function      ( me->CS_mask & 0xF000 )
#define   _parameters    ( me->CS_mask & 0x0FFF )
 

/* Misc Definitions */
#define TRUE  1
#define FALSE 0
#define LO_JUST  0
#define HI_JUST  14
#define LO_SIZE  0

#endif
