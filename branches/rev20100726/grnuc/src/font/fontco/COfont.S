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
    CLASS NAME:  COfont
    SUBCLASS OF: super_cmd

    Abstract:  This is an abstract class.
----
%CD%

    CHANNELS DECLARED:

----
%MD%

    MESSAGES DECLARED:
                         none   
----
%NB%

 NOTES:

----
%CH%

 CHANGE HISTORY:  DEK 11/11/87 Design Date.
                  DEK 11/11/87 Creation Date.
----
%PD%
----------------------------------------------------------------------
                 C L A S S  D E S C R I P T I O N
----------------------------------------------------------------------

    This is an abstract class for the font server font command objects
to subclass under.
---- */

/*EH*/

class specification COfont (1:0) of super_cmd;

#include  "igrtypedef.h"
#include  "igetypedef.h"
#include  "igr.h"
#include  "gr.h"
#include  "codef.h"

instance COfont
{
    IGRint  action;                  /* action to take in the command object */
    IGRuchar Prompt[MAX_PROMPT_SIZE];      /* user input prompt */
};

override  delete;

end specification COfont;
