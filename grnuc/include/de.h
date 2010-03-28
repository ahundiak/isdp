




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

#ifndef de_include
#define de_include


/*
 *  an include file for detailing/soos
 */

enum  DEwindow_mode{
                DEall_windows,
/*
                DEall_soo_windows,
 */
                DEone_window,
/*
                DEone_soo_window,
                DEone_boundary
 */
		DEupdate_all_win,
		DEupdate_one_win
                           }; /* added so DEnptlocate would compile*/


struct DEsoo_struct
   {
      IGRint              boundaries;
      IGRdouble          *u_parms;
      struct IGRdisplay  *dis_attr;
      struct GRid         window;
   };


#endif /* de_include */
