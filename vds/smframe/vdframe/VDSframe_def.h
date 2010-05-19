/* $Id: VDSframe_def.h,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smframe/vdframe / VDSframe_def.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSframe_def.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#ifndef VDSframe_def
#define VDSframe_def

#include "DIdef.h"

#define NO_FRAME   -9999
#define NO_OFFSET  -9999
#define NO_REINF   -999999
#define NO_SPACING  0

#define NO_REV_DIST -999999

/* These defines are uses with the status field of the struct "frame_obj"
/* specifying the status of each frame.
/* */
#define SAME_FRAME 	0x00000000
#define CRT_FRAME 	0x00000001
#define MOD_FRAME 	0x00000010
#define DEL_FRAME 	0x00000100
#define DISP_FRAME	0x00001000
#define COMP_FRAME	0x00010000
#define NAME_FRAME	0x00100000

struct sect_info
 {
  IGRint 		fr;
  IGRint		to;
  IGRdouble		spacing;
  IGRint		reinf; 
  IGRshort		offset;
  IGRshort		reverse;
 };
 
struct main_info
 {
  IGRchar 		axis;
  IGRchar		orient;
  IGRchar		justif[3];
  IGRchar		annot[10];
  IGRdouble		rev_dist;
  IGRdouble		plane_size;
  IGRdouble		reinf_size;
  IGRdouble		offset_dist;
  IGRshort		state;
 };

struct frame
 {
  IGRint		number;
  IGRchar		name[16];
  IGRdouble		rel_pos;
  IGRdouble		abs_pos;
  IGRshort		offset_layer;
  IGRint		reinf;
  /* IGRshort		 reverse; */
 };

struct frame_def
 {
  IGRint 		 nb_sect;
  struct main_info 	 main_info;
  struct sect_info	*sect_info;
 };


struct frame_obj
 {
  IGRint	status;
  IGRint	new_frame_number;
  IGRint	old_frame_number;
  IGRchar	frame_name[16];
  struct GRid	frame;
  struct GRid	expression;
 };

struct glob_frame_obj
 {
  struct GRid		cs;
  struct GRid		frame_def;
  struct GRid		frame_info;
  struct frame_obj     *frame_obj;
  char                  bas_dir[PATH_MAX];
  IGRshort		state;
 };

#endif
