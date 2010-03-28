




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                                < 1988 >

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

/* ems_plot_def.h */

/* defines for EMS plotting interpreter */

#ifndef EMS_PLOT_DEF_H
#define EMS_PLOT_DEF_H

/* ------- nurb curve flags ------- */
#define CV_PERIODIC_M		0x0001
#define CV_NON_UNIFORM_M	0x0002
#define CV_RATIONAL_M		0x0004
#define CV_PLANAR_M		0x0008
#define CV_PHY_CLOSED_M		0x0010

/* ------- nurb surface flags ------- */
#define SF_U_PERIODIC_M		0x0001
#define SF_V_PERIODIC_M		0x0002
#define SF_U_NON_UNIFORM_M	0x0004
#define SF_V_NON_UNIFORM_M	0x0008
#define SF_RATIONAL_M		0x0010
#define SF_PLANAR_M		0x0020
#define SF_U_CLOSED_M		0x0040
#define SF_V_CLOSED_M		0x0080
#define SF_ORIENTATION_M	0x0100
#define SF_SOLID_HOLE_M		0x0200

/* ------- useful macros ------- */
#define _str_eq(s1,s2) (!strcmp(s1,s2))
#define _str_lt(s1,s2) (strcmp(s1,s2)<0)
#define _str_gt(s1,s2) (strcmp(s1,s2)>0)
#define return_bad(status) if(!((status)&1))return(status)
#define if_bad(status)	   if(!((status)&1))

#ifdef DEBUG
#  define _debug(x) x
#  ifdef VERBOSE
#    define _verbose(x) x
#  else
#    define _verbose(x)
#  endif
#else
#  define _debug(x)
#  define _verbose(x)
#endif

#endif
