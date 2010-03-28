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
    CLASS NAME:  COdynamics
    SUBCLASS OF: COdisplay

    Abstract: zoom in/out of a window

----
%CD%
    CHANNELS DECLARED:

----
%SC%

----
%EN%
    ON ENTRY:

    NAME          DATA TYPE               DESCRIPTION
 -------------   -----------    --------------------------------------

----
%EX%
    ON EXIT:

    NAME          DATA TYPE             DESCRIPTION
  --------       -----------    --------------------------------------

----
%MD%
    MESSAGES DECLARED:

    messages overriden:
      wakeup, execute
   
----
%NB%
 NOTES:

----
%CH%
 CHANGE HISTORY:

           HT 6/xx/86 : design date
----
%PD%
----------------------------------------------------------------------
                 C L A S S  D E S C R I P T I O N
----------------------------------------------------------------------

         zoom in/out of a window
---- */

/*EH*/


/*----------------------------------------------------------------------*/
/*	Specification file of COdynamics class				*/
/*----------------------------------------------------------------------*/

class specification COdynamics (1:1) of super_cmd;

#include "dpfile.h"

instance COdynamics
{
    int	mask;
    
    struct GRevent event1;
 };

override wakeup, delete, execute;

end specification COdynamics;
