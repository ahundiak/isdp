/*
Name
        GRvg.GRformatele

Description
        This method gets the geometry, properties, symbologies, etc. of the
        object, creates an IGDS formatted element and writes it to the
        specified file.

Synopsis
        GRformatele(msg, md_env, dgn_buf, bs_buf, ele_buf, ele_size,
                    file_des, max_overflow, scale_factor)

        < IGRlong *msg	  	    completion code
                                        - OM_S_SUCCESS
        > struct GRmd_env *md_env   structure containing context info
        > IGRchar *dgn_buf          buffer for output to IGDS design file
        > IGRchar *bs_buf           buffer to contain abstract geometry
        > IGRchar *ele_buf          buffer to contain IGDS formatted element
        > IGRint *ele_size          # bytes in IGDS element
        > IGRint *file_des          pointer to IGDS design file created
        > IGRdouble *max_overflow   max. abs. value of an overflow
        > IGRdouble *scale_factor   scale factor extracted from the type 9

Modules Invoked
	GUmapclass_to_igds
	GUotype2
	GUotype3
	GUotype4
	GUotype6
	GUotype15
	GUotype16
	GUotype717
	GUotype24
	GUotype27
	GUprocess_symbol
	om$get_classname

Methods Invoked
	GRvg.GRgetsize
	GRvg.GRgetrang
	GRvg.GRgeomprops
	GRvg.GRgetattr
	GRvg.GRgetgeom
	GRvg.GRgetname
	GRvg.GRgetsymb
	GRconic.GRgetarc
        GRreffile.GRgetrfprops

Notes
	This is not a stand alone routine. It should be executed only
        from the COtransigds command object.

History
	sb/gfs  10/20/86    Design date
        mrm     02/13/92    change to handle group data (reference files
                            in particular)
        rlw     03/03/92    Fixed a call to om$is_ancestry_valid in which
                            a classid was passed as a class name.
*/

class implementation GRvg;

#include <alloca.h>
#include "grimport.h"
#include "OMmacros.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"
#include "msdef.h"
#include "grsymdef.h"
#include "vardef.h"
#include "var.h"
#include "mapriv.h"
#include "refdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

from GRconic import GRgetarc;
from GRtext import GRgettxattr;
from GRsymbol import GRset_inq_symbol;
from GRreffile import GRgetrfprops;

extern IGRboolean GUcpxhandler();
extern IGRint GUget_symb_level();

extern OMuword OPP_GRcircle_class_id, OPP_GRcirarc_class_id;

static struct GRmd_env new_env;
static IGRmatrix scale_matrix;

%safe
static int old_scale=0;
static IGRshort	old_type=-1;
%endsafe

method GRformatele(IGRlong *msg; struct GRmd_env *md_env; 
                   IGRchar *dgn_buf; IGRchar *bs_buf;
                   IGRchar *ele_buf; IGRint *ele_size; IGRint *file_des;
                   IGRdouble *max_overflow; IGRdouble *scale_factor)
{
    GRname	name;
    IGRchar	IGDSclass = 0;
    IGRchar	*bs_ptr;
    IGRchar	class_name[OM_K_MAXCLASS_LEN];
    IGRchar	cell_name[MAX_SYMBOL_DEF_NAME];
    IGRuchar	*text_string;
    IGRboolean	reference_flag;
    IGRboolean	world = TRUE;
    IGRboolean  fill_bit = FALSE;
    IGRboolean  has_name = FALSE;
    IGRboolean	overflow_stat;
    IGRboolean	format;
    IGRboolean	mark_as_cpx;
    IGRboolean	cpx_calling = FALSE;
    IGRboolean	convert = TRUE;
    IGRboolean  hidden_so_flag, hidden_so_off = 0;
    IGRshort	num_rc = 4;
    IGRshort	mx_type = MAIDMX;
    IGRint	ele_type;
    IGRint	set_inq = 0;
    IGRlong	bytes_returned;
    IGRlong	status;
    IGRlong	object_size;
    IGRlong	num_values = 6;
    IGRlong	OMmsg;
    IGRulong    refprops = 0;
    IGRdouble	roundoff = MAETA * 100000;
    IGRdouble	x_ratio;
    IGRdouble	y_ratio;
    IGRdouble	w1,w2,h1,h2;
    IGRpoint	t1,t2,t3,t4;
    IGRmatrix	identity_mx;
    GRrange	range;
    struct IGRarc	arc;    
    struct IGResbc	bsc_attr;
    struct IGResbs	bss_attr;
    struct IGRestx	text_attr;
    struct IGRlbsys     text_lbs;
    struct IGRlbsys     *lbsys_ptr;
    struct GRid         id;
    struct GRsymbology	symbology;
    struct GRprops	geo_props;
    struct GRmd_env	temp_env;
    struct GRvar_list	var_list[2];

    /*
     *  Initialization.
     */

    OMmsg = OM_S_SUCCESS; 
    bs_ptr = bs_buf;
    lbsys_ptr = (struct IGRlbsys *)bs_buf;
 
    /*
     *  Get class name of the object.
     */

    status = om$get_classname(classname = class_name, object = me);

    if (!(1 & status))
    {
	goto wrap_up;
    }
    
    /*
     *  Map IGE class name to an IGDS element type.
     */

    status = GUmapclass_to_igds(class_name, &ele_type);

    if (status != OM_S_SUCCESS)
    {
	goto wrap_up;
    }

    if (*scale_factor ==  1)
    {
	new_env = *md_env;
	old_scale = *scale_factor;
	old_type = md_env->md_env.matrix_type;
    }
    else
    {
        new_env.md_id = md_env->md_id;

        if (!((*scale_factor == old_scale) &&
              (old_type == MAIDMX)  && 
              (new_env.md_env.matrix_type == MAIDMX)))
        {
            if (*scale_factor != old_scale)
            {
            	/*
                 *  set-up scale matrix for IGE to IGDS working units
                 */

	    	scale_matrix[0] = scale_matrix[5] = scale_matrix[10] = 
                    *scale_factor;
	    	scale_matrix[1] = scale_matrix[2] = scale_matrix[3] = 0.0;
	    	scale_matrix[4] = scale_matrix[6] = scale_matrix[7] = 0.0;
	    	scale_matrix[8] = scale_matrix[9] = scale_matrix[11] = 0.0;
	    	scale_matrix[12]= scale_matrix[13] = scale_matrix[14] = 0.0;
	    	scale_matrix[15] = 1.0;

	    	old_scale = *scale_factor;
	    }
            if (new_env.md_env.matrix_type == MAIDMX)
	    {
                OM_BLOCK_MOVE(scale_matrix, new_env.md_env.matrix,
                              sizeof(IGRdouble) * 16);
	    }
	    else
	    {
	        MAmulmx(msg, &num_rc, &num_rc, &num_rc, scale_matrix,
                        md_env->md_env.matrix, new_env.md_env.matrix);
	    }

            MAtypemx(msg,new_env.md_env.matrix,
                     &new_env.md_env.matrix_type);

   	    old_type = md_env->md_env.matrix_type; /* use input value	*/
	}
    }

    /*
     *  Get the symbology, range, and geometric properties
     *	of the object.
     */

    status = om$send(msg = message GRvg.GRgetrang
                          (msg, &new_env.md_env.matrix_type, 
                           new_env.md_env.matrix, &world, range), 
                     senderid = my_id, 
                     targetid = my_id);

    /*
     *  Check to see if this element will cause integer overflow.
     */

    overflow_stat = GUcheck_overflow(msg, &num_values, range, max_overflow);
    if (!overflow_stat)
    {
	/*
         *  This object will cause integer overflow, skip it.
         */

	goto wrap_up;
    }
 	
    status = om$send(msg = message GRvg.GRgetsymb(msg, &symbology),
                     senderid = my_id,
                     targetid = my_id);

    GUget_symb_level(msg, &symbology);

    /*
     *  Call the complex handler to determine whether or not to continue
     *  the formatting of this object.
     */

    id.osnum = OM_Gw_current_OS;
    id.objid = my_id;

    if ((ele_type == GU_CELL) || (ele_type == GU_CPX_STRING))
    {
	cpx_calling = TRUE;
    }

    if (!GUcpxhandler(msg, &cpx_calling, md_env, dgn_buf, bs_buf, 
                      ele_buf, ele_size, file_des, max_overflow, 
                      scale_factor, &IGDSclass, &me->properties, 
                      &symbology.level, &id, &format, &mark_as_cpx))
    {
	*msg = MSSUCC;
	goto wrap_up;
    }

    if (!format)
    {
	goto wrap_up;
    }

    status = om$send(msg = message GRvg.GRgeomprops
                          (msg, &new_env.md_env.matrix_type,
                           new_env.md_env.matrix, &geo_props),
  	             senderid = my_id,
    	             targetid = my_id);

    /*
     *  Get buffer size required by the b-spline representation
     *  of the object and allocate a new buffer if the standard
     *  buffer is not large enough.
     */

    status = om$send(msg = message GRvg.GRgetsize
                          (msg, &new_env.md_env.matrix_type, 
                           new_env.md_env.matrix, &object_size), 
                     senderid = my_id, 
                     targetid = my_id);

    if ((1 & status) && (object_size > GUBSBUF_SIZE))
    {
	/*
         *  Buffer is not large enough.
         */
        bs_ptr = (IGRchar*)alloca(object_size);
    }

    om$send(msg = message GRvg.GRgetname(msg, name),
            senderid = my_id,
            targetid = my_id);

    has_name = 1 & *msg;	

    /*
     *  For each element type supported, get the object's
     *  geometry and format an element buffer.
     */

    status = TRUE;

    switch (ele_type)
    {
      case GU_CELL:

        status = om$send(msg = message GRvg.GRgetgeom
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, bs_ptr),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        var_list[0].var = GR_SYMBOL_NAME;
        var_list[0].var_ptr = cell_name;
        var_list[0].num_bytes = MAX_SYMBOL_DEF_NAME;
        var_list[0].bytes_returned = &bytes_returned;
        var_list[1].var = END_PARAM;
        var_list[1].var_ptr = NULL;
        var_list[1].num_bytes = NULL;
        var_list[1].bytes_returned = &bytes_returned;
		
        status = om$send(msg = message GRsymbol.GRset_inq_symbol
                              (msg, set_inq, &var_list[0]),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        reference_flag = 1;

        GUotype2(msg, file_des, dgn_buf, ele_buf, ele_size,
                 class_name, bs_ptr, range, &symbology, &geo_props,
                 &me->properties, &id, &reference_flag, 
                 &new_env, bs_buf, cell_name, &has_name, name);
        break;

      case GU_SYMBOL:

        status = om$send(msg = message GRvg.GRgetgeom
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, bs_ptr),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }
		
        temp_env.md_id = new_env.md_id;

        OM_BLOCK_MOVE(lbsys_ptr->matrix, temp_env.md_env.matrix,
                      sizeof(IGRdouble) * 16);
	
        MAtypemx(msg, temp_env.md_env.matrix, &temp_env.md_env.matrix_type);

        reference_flag = 1;

        GUprocess_symbol(msg, &temp_env, dgn_buf, bs_ptr, ele_buf,
                         ele_size, file_des, max_overflow,
                         &id, &reference_flag);
        break;

      case GU_LINE:

        status = om$send(msg = message GRvg.GRgetgeom
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, bs_ptr),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        GUotype3(msg, file_des, dgn_buf, ele_buf, ele_size,
                 class_name, bs_ptr, range, &symbology, &geo_props,
                 &me->properties, &has_name, name);
        break;

      case GU_LINE_STRING:

        status = om$send(msg = message GRvg.GRgetgeom
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, bs_ptr),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        GUotype4(msg, file_des, dgn_buf, ele_buf, ele_size,
                 class_name, bs_ptr, range, &symbology, &geo_props,
                 &me->properties, &has_name, name, &fill_bit);
        break;

      case GU_GROUP_DATA:
        break;

      case GU_REFERENCE_FILE:

        /* check whether hidden symbologies are suppressed */
        om$send(msg = message GRreffile.GRgetrfprops(msg,&refprops),
                targetid = my_id);
        if (refprops & GRHIDDEN_OFF)
        {
            /* save the current setting and turn them off */
            gr$get_hidden_so_on(msg = msg, buffer = &hidden_so_flag);
            gr$put_hidden_so_on(msg = msg, buffer = &hidden_so_off);
        }

        /* convert the reference file objects */
        GUotype5lv9(msg, my_id, OM_Gw_current_OS, md_env, file_des, dgn_buf,
                    bs_buf, ele_buf, ele_size, scale_factor, max_overflow);

        /* restore hidden symbology flag */
        if (refprops & GRHIDDEN_OFF)
            gr$put_hidden_so_on(msg = msg, buffer = &hidden_so_flag);

        break;

      case GU_SHAPE:
	
        status = om$send(msg = message GRvg.GRgetgeom
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, bs_ptr),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        GUotype6(msg, file_des, dgn_buf, ele_buf, ele_size,
                 class_name, bs_ptr, range, &symbology, &geo_props,
                 &me->properties, &has_name, name, &fill_bit);
        break;

      case GU_TEXT_NODE:

        MAidmx(msg, identity_mx);

        status = om$send(msg = message GRvg.GRgetgeom
                              (msg, &mx_type, identity_mx,
                               (IGRchar *)&text_lbs),
                         senderid = my_id,
                         targetid = my_id);

        status = om$send(msg = message GRvg.GRgetgeom
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, bs_ptr),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }
	
        status = om$send(msg = message GRtext.GRgettxattr
                              (msg, &text_attr, NULL, &text_string), 
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        /*
         *  Determine the ratio between the box around the
         *  original text and the box around the scaled text.
         *
         *  The ratio in width and the ratio in height are
         *  calculated and passed to the text function where
         *  the IGDS length and height multipliers are adjusted.
         */
	
        t1[0] = lbsys_ptr->matrix[0] * lbsys_ptr->diag_pt1[0];
        t1[1] = lbsys_ptr->matrix[4] * lbsys_ptr->diag_pt1[0];
        t1[2] = lbsys_ptr->matrix[8] * lbsys_ptr->diag_pt1[0];

        t2[0] = lbsys_ptr->matrix[1] * lbsys_ptr->diag_pt1[1];
        t2[1] = lbsys_ptr->matrix[5] * lbsys_ptr->diag_pt1[1];
        t2[2] = lbsys_ptr->matrix[9] * lbsys_ptr->diag_pt1[1];

        t3[0] = lbsys_ptr->matrix[0] * lbsys_ptr->diag_pt2[0];
        t3[1] = lbsys_ptr->matrix[4] * lbsys_ptr->diag_pt2[0];
        t3[2] = lbsys_ptr->matrix[8] * lbsys_ptr->diag_pt2[0];

        t4[0] = lbsys_ptr->matrix[1] * lbsys_ptr->diag_pt2[1];
        t4[1] = lbsys_ptr->matrix[5] * lbsys_ptr->diag_pt2[1];
        t4[2] = lbsys_ptr->matrix[9] * lbsys_ptr->diag_pt2[1];

        MA2ptdis(msg, t1, t3, &w2);
        MA2ptdis(msg, t2, t4, &h2);

        w1 = MAabsolute(text_lbs.diag_pt1[0] - text_lbs.diag_pt2[0]);
        h1 = MAabsolute(text_lbs.diag_pt1[1] - text_lbs.diag_pt2[1]);

        x_ratio = w2 / w1;
        y_ratio = h2 / h1;

        GUotype717(msg, file_des, dgn_buf, ele_buf, ele_size,
                   class_name, bs_ptr, range, &symbology,
                   &me->properties, &text_attr, text_string, 
                   &new_env, &x_ratio, &y_ratio, &has_name, name,
                   &fill_bit, &convert, scale_factor);
		
        om$dealloc(ptr = text_string);
	
        break;

      case GU_ELLIPSE:

        status = om$send(msg = message GRconic.GRgetarc
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, &arc),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        status = om$is_ancestry_valid(subclassname = class_name,
                                      superclassid = OPP_GRcircle_class_id);

        if (status == OM_S_SUCCESS)
        {
            if ((arc.prim_axis != arc.sec_axis) &&
                (MAabsolute(arc.prim_axis - arc.sec_axis) 
                 < roundoff * arc.prim_axis))
            {
                arc.prim_axis = (arc.prim_axis + arc.sec_axis) / 2.0;
                arc.sec_axis = arc.prim_axis;
            }
        }

        GUotype15(msg, file_des, dgn_buf, ele_buf, ele_size,
                  class_name, &arc, range, &symbology, &geo_props,
                  &me->properties, &has_name, name, &fill_bit);
        break;

      case GU_ARC:

        status = om$send(msg = message GRconic.GRgetarc
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, &arc),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        status = om$is_ancestry_valid(subclassname = class_name,
                                      superclassid = OPP_GRcirarc_class_id);

        if (status == OM_S_SUCCESS)
        {
            if ((arc.prim_axis != arc.sec_axis) &&
                (MAabsolute(arc.prim_axis - arc.sec_axis) 
                 < roundoff * arc.prim_axis))
            {
                arc.prim_axis = (arc.prim_axis + arc.sec_axis) / 2.0;
                arc.sec_axis = arc.prim_axis;
            }
        }

        GUotype16(msg, file_des, dgn_buf, ele_buf, ele_size,
                  class_name, &arc, range, &symbology, &geo_props,
                  &me->properties, &has_name, name, &fill_bit);
        break;

      case GU_BS_SURF_HEADER:

        status = om$send(msg = message GRvg.GRgetgeom
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, bs_ptr),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        status = om$send(msg = message GRvg.GRgetattr
                              (msg, (IGRchar *)&bss_attr),
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        GUotype24(msg, file_des, dgn_buf, ele_buf, ele_size,
                  class_name, bs_ptr, range, &symbology, &geo_props,
                  &me->properties, &bss_attr, &has_name, name);
        break;


      case GU_BS_CURVE_HEADER:

        status = om$send(msg = message GRvg.GRgetgeom
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, bs_ptr),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        status = om$send (msg = message GRvg.GRgetattr
                               (msg, (IGRchar *)&bsc_attr),
                          targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        GUotype27(msg, file_des, dgn_buf, ele_buf, ele_size,
                  class_name, bs_ptr, range, &symbology, &geo_props,
                  &me->properties, &bsc_attr, &has_name, name, &fill_bit);
        break;

      case GU_CPX_STRING:

        GUotype1214(msg, file_des, dgn_buf, ele_buf, ele_size,
                    class_name, range, &symbology, &geo_props,
                    &me->properties, &id, &new_env, bs_buf,
                    &has_name, name);

        break;
    }

wrap_up:

    return(OM_S_SUCCESS);
}

end implementation GRvg;
