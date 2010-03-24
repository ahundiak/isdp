




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

class specification IGEdigwin (1:0) of IGEwsys;

#include <igrtypedef.h>
#include <OMerrordef.h>

instance IGEdigwin
{
   int fm;   /* floating menu = 1 digitizer = 0 */
   int org_x,org_y; /* lower left corner of paper menu */
   int ext_x,ext_y;
   int num_of_cmds; 
   struct EX_paper_cmd  *p_cmd;
   int rno;  /* Stores the number representing the region info.       */
             /* This is required for the delete call.                 */
             /* Added this for a problem reported by Mike Heatherly.  */
             /*                                            - Srikanth */


};

override convert_pnt, delete, activate;

/* convert_pnt will send throught the channel a */
/* convert_pnt                                  */

/* delete will delete the hardware region       */


/* create  will "create" a hardware region on the */
/* digitizer board, fill in instance data, read in paper menu file  */
/* set up table for search.    path is the full path name for paper_menu  */
/*  if cmdptr is not null then the memory already allocated in previous   */
/*  attachment. we need not to realloc the memory                         */

message create (IGRint   fm;
                IGRint   org_x;
                IGRint   org_y;
		IGRchar  *path;
	        IGRint   *num_cmd;
     struct EX_paper_cmd **cmdptr);

end specification IGEdigwin;
