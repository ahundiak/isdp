




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

class specification IGEabsdig (1:0) of IGEwsys;

#include <igrtypedef.h>

instance IGEabsdig
{
   int fm;   /* floating menu = 1 digitizer = 0 */
   int x1,y1,x2,y2;  /* saved screen track area */
   int rno;  /* Stores the number representing the region info.       */
             /* This is required for the delete call.                 */
             /* Added this for a problem reported by Mike Heatherly.  */
             /*                                            - Srikanth */
};

override convert_pnt;
override activate;
override delete;

message create( int fm ); /* init instance data */

end specification IGEabsdig;
