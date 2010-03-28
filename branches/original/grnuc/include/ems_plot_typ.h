




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

/* ems_plot_typ.h */

/* ------- typedefs for EMS plotting interpreter */

#ifndef EMS_PLOT_TYP_DOT_H
#define EMS_PLOT_TYP_DOT_H

/* ------- numeric data by size --------------------------------------------- */

/****
 *
 *  These are normally defined in odi.h, but on some systems this may
 *  not be available, so they are defined here again.  Now, to prevent
 *  any collision when odi.h is present, I've put the conditional 
 *  compile around the typedef's.  _PLOT_STD_TYPEDEFS comes from odi.h
 *
 *  Mike Lanier 1/30/95
 *
 ****/

#ifndef _PLOT_STD_TYPEDEFS
#define _PLOT_STD_TYPEDEFS

typedef char		int8;
typedef unsigned char	uint8;
typedef short		int16;
typedef unsigned short	uint16;
typedef int		int32;
typedef unsigned int	uint32;
typedef float		real32;
typedef double		real64;

#endif

/* ------- general data union for simple types ------------------------------ */

typedef union
{
  int8		  i8;
  uint8		  u8;
  int16		  i16;
  uint16	  u16;
  int32		  i32;
  uint32	  u32;
  real32	  flo;
  real64	  dbl;
  char		* ptr;
} simple_union;

#endif
