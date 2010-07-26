/* #######################    APOGEE COMPILED   ######################## */
class implementation GRvg;

#include "exsysdep.h"
#include <stdio.h>
#include "coimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "transdef.h"
#include "translate.h"
#include "transmacros.h"
#include "msdef.h"
#include "OMmacros.h"
#include "OMindex.h"
#include "refdef.h"
#include "ref.h"
#include "OMprimitives.h"
#include "ctype.h"

/*
 *  The following structure should be in translate.h
 */

struct IGDS_ref_file
{
	struct GUcommon_header_info header;
	IGRshort 	num_chars;
	IGRchar  	filename[65];
	IGRchar		att_num;
	IGRshort	fbopt;
	IGRshort	fdopt;
	IGRshort	display_flags[8];
	IGRshort	level_mask[32];
	IGRlong		rf_origin[3];
	short unsigned 	matrix[36];
	short unsigned 	conv[4];
	IGRlong		mf_origin[3];
	IGRshort	num_chars_log;
	IGRchar		log_name[21];
	IGRchar		pad1;
	IGRshort	num_chars_descript;
	IGRchar		descript[41];
	IGRchar		pad2;
	IGRshort	lv_sym_mask;
	IGRshort	lv_sym_tbl[63];
	IGRlong		z_delta;
	IGRshort	num_points;
	IGRchar		clipping_polygon[256];
};

#define GURFDPON 0x080
#define GURFFBOPT_SNAP_LOCK 0x020
#define GURFFBOPT_LOCATE_LOCK 0x040
 
from GRreffile import GRchgfilename, GRchglevels, GRupdrefrng;

IGRint COcvt_type5lv9 ( msg, ref, db_type, scale_factor, 
			         object_info, current_env )

IGRlong		     *msg;
struct IGDS_ref_file *ref;
IGRint		     *db_type;
IGRdouble 	     *scale_factor;
struct GRid 	     *object_info;
struct GRmd_env      *current_env;

{
	IGRint		status;
	IGRint		sts;
	IGRint		start = 0;
	IGRuint		ref_properties = 0;
	IGRint		dp_levels[35];
	IGRlong 	mess;
	IGRlong		i, j, tempdummy;
	IGRlong 	temp[64];
	IGRint		has_link;
	IGRshort	flag = 2;
	IGRshort	dim = 4;
	IGRshort	set = 1;
	IGRushort 	props = GRIS_DISPLAYABLE;
	IGRchar		*name_ptr;
	IGRchar		attachname[257];
	IGRchar		ele_name[257];
	IGRchar 	filename[66];
	IGRchar 	log_name[22];
	IGRchar 	descript[42];
	IGRchar 	*classname = "GRreffile";
	IGRchar		*ptr1,*ptr2;
	IGRdouble 	knots[34];		/* max poles is 32 	*/
	IGRdouble 	rf_origin[3];
	IGRdouble 	rf_matrix[9];
	IGRdouble 	conv;
	IGRdouble 	mf_origin[3];
	IGRdouble 	z_delta;
	IGRdouble 	new_scale;
	IGRdouble 	clipping_polygon[32*3];
	IGRdouble 	local_polygon[64*3];	/* hold two faces	*/
	IGRdouble	world_to_local[16],invmx[16];
	IGRchar		*typeface = NULL;
	IGRchar		*charmap = NULL;

	struct IGRcv_prism 	cv_prism;
	struct IGRlbsys 	lbsys;
	struct IGRpolyline 	py;
	struct GRrf_info 	rf_info;


	status = TRUE;
	*msg = MSSUCC;

#ifdef BIG_ENDIAN
       GRswap_type5vl9_ele(ref);
#endif

/*
 *  Get strings from buffer and add null-terminator.
 */

	OM_BLOCK_MOVE(ref->filename,filename,ref->num_chars);
	filename[ref->num_chars] = '\0';
	OM_BLOCK_MOVE(ref->log_name,log_name,ref->num_chars_log);
	log_name[ref->num_chars_log] = '\0';
	OM_BLOCK_MOVE(ref->descript,descript,ref->num_chars_descript);
	descript[ref->num_chars_descript] = '\0';

/*
 *  Get IGDS geometry from buffer.
 */

	fltvax_to_flt32(9,ref->matrix,rf_matrix);
	fltvax_to_flt32(1,ref->conv,&conv);

	new_scale = conv / *scale_factor;

	for (i = 0; i < 3; i++)
	{
	  GUswapint(&(ref->rf_origin[i]),&tempdummy);
          rf_origin[i] = (IGRdouble) tempdummy;
	  GUswapint(&(ref->mf_origin[i]),&tempdummy);
          mf_origin[i] = (IGRdouble) tempdummy;
	  rf_origin[i] /= *scale_factor;
	  mf_origin[i] /= *scale_factor;
	}

	GUswapint(&(ref->z_delta),&tempdummy);
        z_delta = (IGRdouble) tempdummy;
	z_delta /= *scale_factor; 

/*    Kludge to convert the 2-d reference file matrices into 3-d.
 *    Setting z_delta to a small value so that the reference file
 *    is not flat
 */

	if ( *db_type == GU_2I )
	{
		rf_matrix[4] = rf_matrix[3];
		rf_matrix[3] = 0;
		rf_matrix[8] = 1;
		z_delta = 2;
	}
	
	OM_BLOCK_MOVE(ref->clipping_polygon,temp,ref->num_points*8);
	for (i = 0; i < ref->num_points; i++)
	{
	  GUswapint(&(temp[i*2]), &tempdummy);
          clipping_polygon[i*3] = (IGRdouble) tempdummy;
	  clipping_polygon[i*3] /= *scale_factor;
	  GUswapint(&(temp[i*2+1]), &tempdummy);
          clipping_polygon[i*3+1] = (IGRdouble) tempdummy;
	  clipping_polygon[i*3+1] /= *scale_factor;
	  clipping_polygon[3*i+2] = 0;
	}

/*
 *  Form the local bounded system representing the ref file volume
 *  and the curve prism representing the clipping polygon.  Since
 *  IGDS clipping polygons are 'view independent', the DRAFT one
 *  will be set-up for a top view only.
 */

	py.points = clipping_polygon;
	py.num_points = ref->num_points;

	lbsys.matrix[0] = conv * rf_matrix[0];
	lbsys.matrix[1] = conv * rf_matrix[1];
	lbsys.matrix[2] = conv * rf_matrix[2];
	lbsys.matrix[3] = mf_origin[0] -
			  (lbsys.matrix[0] * rf_origin[0] +
			   lbsys.matrix[1] * rf_origin[1] +
			   lbsys.matrix[2] * rf_origin[2]);
	lbsys.matrix[4] = conv * rf_matrix[3];
	lbsys.matrix[5] = conv * rf_matrix[4];
	lbsys.matrix[6] = conv * rf_matrix[5];
	lbsys.matrix[7] = mf_origin[1] -  
			  (lbsys.matrix[4] * rf_origin[0] +
			   lbsys.matrix[5] * rf_origin[1] +
			   lbsys.matrix[6] * rf_origin[2]);
	lbsys.matrix[8] = conv * rf_matrix[6];
	lbsys.matrix[9] = conv * rf_matrix[7];
	lbsys.matrix[10] = conv * rf_matrix[8];
	lbsys.matrix[11] = mf_origin[2] -
			   (lbsys.matrix[8] * rf_origin[0] +
			    lbsys.matrix[9] * rf_origin[1] +
			    lbsys.matrix[10] * rf_origin[2]);
	lbsys.matrix[12] = 0;
	lbsys.matrix[13] = 0;
	lbsys.matrix[14] = 0;
	lbsys.matrix[15] = 1;

	MAidmx(&mess,cv_prism.matrix);
	cv_prism.matrix[3] = mf_origin[0];
	cv_prism.matrix[7] = mf_origin[1];
	cv_prism.matrix[11] = mf_origin[2] - z_delta;

	MAinvmx(&mess,&dim,lbsys.matrix,invmx);
	MAmulmx(&mess,&dim,&dim,&dim,invmx,cv_prism.matrix,world_to_local);
	MAptsxform(&mess,&py.num_points,world_to_local,
		   clipping_polygon,local_polygon);

	for (i = 0; i < py.num_points; i++)
	{
	  local_polygon[(py.num_points + i) * 3] = 
	    clipping_polygon[3*i];
	  local_polygon[(py.num_points + i) * 3 + 1] = 
	    clipping_polygon[3*i+1];
	  local_polygon[(py.num_points + i) * 3 + 2] = 
	    clipping_polygon[3*i+2] + 2 * z_delta;
	}

	MAptsxform(&mess,&py.num_points,world_to_local,
		   &local_polygon[py.num_points*3],
		   &local_polygon[py.num_points*3]);

	py.num_points *= 2;
	py.points = local_polygon;
	MApyextents(&mess,&py,lbsys.diag_pt1,lbsys.diag_pt2);
	py.num_points /= 2;
	
	cv_prism.curve.poles = clipping_polygon;
	cv_prism.curve.knots = knots;
	cv_prism.curve.weights = 0;
	cv_prism.curve.bdrys = 0;

	py.points = clipping_polygon;
	MApytobc(&mess,&py,&cv_prism.curve);
	cv_prism.height = 2 * z_delta;

/*
 *  Construct the reference file attachment.  Use a null filename at
 *  construct time since we don't know what the object space file
 *  name is going to be (the user can "fix that up" later) and since
 *  an invalid non-null name causes construct to error out.  Since 
 *  IGDS reference files don't occur on a master file level, set the
 *  level to 1 as a default.
 */

	rf_info.filename = NULL;
	rf_info.named_view = NULL;
	if (descript[0] != '\0')
	{
	  rf_info.description = descript;
	}
	else
	{
	  rf_info.description = NULL;
	}
	rf_info.clip_poly = &cv_prism;
	if (cv_prism.curve.num_poles == 5)
	{
	  rf_info.prism_classname = "GR3dorthpoly";
	}
	else
	{
	  rf_info.prism_classname = "GR3dpolygon";
	}
	rf_info.ref_properties = &ref_properties;
	rf_info.scale = NULL;

	ref_properties = GRRF_IS_READ_ONLY | GRIS_SKEW;

	new_scale = 1;

	has_link = GUattr_link (&mess, ref, ele_name,
				&ref->header.symbology, typeface, charmap);
	ref->header.level = 1;
	sts = GUconstruct(&lbsys,object_info,classname,&ref->header.level,
		    &ref->header.symbology,&ref->header.properties,
		    &rf_info,&new_scale,current_env);


/*
 *  Now that the attachment has been constructed, we need to determine
 *  our default file name to call it.  We use the IGDS name without
 *  any VAX directory information in it.  Then we need to change the
 *  the name stored in the attachment to that name.  Ignore any errors
 *  returned from the reference file since there will probably not be
 *  a valid object space present with this name.  Also, need to update
 *  the scan range of the object.
 */

	start = 0;
	i = 0;
	while (filename[i] != '\0')
	{
	  if ((filename[i] == ']') ||	/* end of directory spec	*/
	      (filename[i] == ':'))
	  {
	    i++;
	    start = i;
	  }
	  i++;
	}

	i = start;
	j = 0;
	while (filename[i] != '\0')
	{
	      filename[j] = tolower(filename[i]);
	      i ++;
	      j ++;
	}
	filename[j] = '\0';



/*
 *  If there is an element name defined in the attribute linkage it is
 *  used for the attachment name.  If not, use the IGDS Reference File 
 *  Logical name . If a logical name is also not defined, then the 
 *  IGDS file name converted to lower case is used.
 */

	if (has_link & HAS_NAME_TYPE)
	{
	 	i = 0;
		while ( ele_name[i] != '\0' )
		{
		      attachname[i] = tolower(ele_name[i]);
		      i++;
		} 
		attachname[i] = '\0';
		name_ptr = attachname;
	}	
	else
	{
 		if (log_name[0] != '\0')
		{
	  		i = 0;
	  		while (log_name[i] != '\0')
	  		{
	    		      attachname[i] = tolower(log_name[i]);
	    		      i++;
	  		}
			attachname[i] = '\0';
			name_ptr = attachname;
	 	}
		else
		{
			name_ptr = NULL;
		}
	}




	sts = om$send(msg = message GRreffile.GRchgfilename
					 (&mess, filename, name_ptr),
			   senderid = NULL_OBJID,
			   targetid = object_info->objid,
			   targetos = object_info->osnum);

	sts = om$send(msg = message GRreffile.GRupdrefrng
			      (&mess,&current_env->md_env.matrix_type,
			       current_env->md_env.matrix),
			   senderid = NULL_OBJID,
			   targetid = object_info->objid,
			   targetos = object_info->osnum);

/*
 *    Since the reference file object has been constructed as not 
 * displayable (so that the clipping polygon is not displayed), we
 * now need to set the properties bit so that the other graphics
 * is displayable.
 */ 


	sts = om$send(msg = message GRgraphics.GRchgprops
					(&mess, &set, (IGRshort *)&props),
			   senderid = NULL_OBJID,
			   targetid = object_info->objid,
			   targetos = object_info->osnum);

	
/*
 *  Since IGDS reference files have levels on in a per view basis,
 *  DRAFT has "global" levels,  we need to set views on based the
 *  the combination of all the IGDS views.
 */

	for (i = 0; i < 8; i++)		/* 8 IGDS views		*/
	{
	  ref->level_mask[0] |= ref->level_mask[4*i];
	  ref->level_mask[1] |= ref->level_mask[4*i+1];
	  ref->level_mask[2] |= ref->level_mask[4*i+2];
	  ref->level_mask[3] |= ref->level_mask[4*i+3];
	}

	for (i = 0; i < 35; i++)
	{
	  dp_levels[i] = 0;
	}

	ptr1 = (IGRchar *) ref->level_mask;
	ptr2 = (IGRchar *) dp_levels;
	for (i = 0; i < 64; i++)
	{
	  if ((ptr1[(i >> 3)] & (1 << (i & 0x7))) ? 1 : 0)
	  {
	    ptr2 [((i+1) >> 3)] |= (1 << ((i+1) & 0x7)) ;	
	  }
	}
		
	sts = om$send(msg = message GRreffile.GRchglevels
					 (&mess,&flag,dp_levels),
			   senderid = NULL_OBJID,
			   targetid = object_info->objid,
			   targetos = object_info->osnum);

/*
 *  Left To Do:
 *
 *	1) If locate is locked, set the attachment to non-locatable.
 *
 */

	return ( sts );
	
}

end implementation GRvg;
