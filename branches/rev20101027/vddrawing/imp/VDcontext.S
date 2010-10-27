/* $Id: VDcontext.S,v 1.1.1.1 2001/01/04 21:08:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/imp / VDcontext.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDcontext.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/18  08:09:22  pinnacle
# Replaced: vddrawing/imp/VDcontext.S for: CR 179603526 by smpathak for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/04/21  16:24:04  pinnacle
# Replaced: vddrawing/imp/VDcontext.S for:  by azuurhou for vds.240
#
# Revision 1.3  1995/03/19  22:19:46  pinnacle
# Replaced: vddrawing/imp/VDcontext.S by azuurhou r#
#
# Revision 1.2  1995/03/03  23:02:28  pinnacle
# Replaced: vddrawing/imp/VDcontext.S by azuurhou r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
   context object to capture soem meore info than the regular graphic
   context 
*/

class specification VDcontext (0:1) of GRcontext;

instance VDcontext
{

	int			level[32];		/* Ref Levels.     */
	struct IGRlbsys		lbs;			/* Conetext Range. */
	variable IGRchar	filename[];		/* Setup File Name */
	variable IGRchar	osname[];		/* Set Name	*/
	double			point[3],		/* PRoject Point */
				vector[3];		/* Project Vector */
};

override	GRupdatectx ;

/* Get/set level active in the reference file attachement */

message VDset_level(int *level);
message VDget_level(int *level);

/* Get/set lbs describing reference file attachement */

message VDset_lbs(struct IGRlbsys *lbs);
message VDget_lbs(struct IGRlbsys *lbs);

/* Get/set file name */

message VDset_setup_name(char *name);
message VDget_setup_name(char *name);
message VDget_setup_name_size( int *size);

/* Get/set os name */

message VDset_osname(char *name);
message VDget_osname(char *name);

/* Get/set view info */

message VDset_proj_view(double *point,*vector);
message VDget_proj_view(double *point,*vector);

/* Get information used for drawing extraction */

message VDget_extract_info(struct GRid **obj_list;int *nb_obj;
			   double *vector,*point;
			   int *obj_level;
			   struct IGRlbsys *lbs);


end specification VDcontext;
