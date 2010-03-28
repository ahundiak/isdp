/* #######################    APOGEE COMPILED   ######################## */





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

/*----
%GP%
----
%HD%
    CLASS NAME:  COrplfnt
    SUBCLASS OF: COfont

    Abstract:  This is an abstract class.
----
%CD%

    CHANNELS DECLARED:

----
%MD%

    MESSAGES DECLARED:
   
----
%NB%

 NOTES:

----
%CH%

 CHANGE HISTORY:  WBC 4/15/86 Creation Date.
                  SCW 5/08/92 ANSI conversion
----
%PD%
----------------------------------------------------------------------
                 C L A S S  D E S C R I P T I O N
----------------------------------------------------------------------

    This is an abstract class for the replace font command object.

---- */

/*EH*/

class specification COrplfnt (1:0) of COfont;

#include "fontdef.h"
#include "FS.h"
#include "FSOutl.h"

/*
 *  Instance data.
 */

instance COrplfnt
{
    IGRlong           mask;                   /* input mask                  */
    IGRshort          vfont_num;              /* virtual font number of font 
                                                 to replace                  */
    IGRuchar          logical_name[PATH_LEN]; /* locale logical name         */
    IGRshort          font_flags;             /* char/frac/symb font         */
};

override init, wakeup, sleep, execute;

end specification COrplfnt;
