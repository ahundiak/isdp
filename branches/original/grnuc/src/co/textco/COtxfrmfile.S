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
    CLASS NAME:  COtxfrmfile
    SUBCLASS OF: COroot

----
%CD%

    CHANNELS DECLARED:

----
%MD%

    MESSAGES DECLARED:

    MESSAGE OVERRIDDEN: COwakeup
                        COexecute   
----
%NB%

 NOTES:

----
%CH%

 CHANGE HISTORY:     WBC 03/30/88 : Design date.
                     WBC 03/30/88 : Creation Date.
		     jjm  3/10/93 : overrode pre_sleep method, added 
				    instance data flag

----
%PD%
----------------------------------------------------------------------
                 C L A S S  D E S C R I P T I O N
----------------------------------------------------------------------

    This is a class for the input generator to put text from a file
on the software queue.
---- */

/*EH*/

class specification COtxfrmfile (1:0) of COroot;

instance COtxfrmfile
{
   int flag;
};

override pre_wakeup, wakeup, execute;

end specification COtxfrmfile;
