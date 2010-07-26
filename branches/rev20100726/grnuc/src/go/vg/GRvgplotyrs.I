/*
Name
        GRvg.GRplotyourself

Description
        This method gets the geometry, properties, symbologies, etc. of
        the object, creates an IGDS formatted element and writes it to
        the specified file for plotting.

Synopsis
        GRplotyourself(msg, md_env, dgn_buf, bs_buf, ele_buf, ele_size,
                       file_des, max_overflow, id_info, scale_factor)

        < long *msg              completion code
        > struct GRmd_env *md_env   structure containing context info
        > char *dgn_buf          buffer for output to IGDS design file
        > char *bs_buf           buffer to contain abstract geometry
        > char *ele_buf          buffer to contain IGDS formatted element
        > int *ele_size	    # bytes in IGDS element
        > int *file_des          pointer to IGDS design file created
        > double *max_overflow   max. abs. value of integer overflow
        > struct GRid *id_info      array of GRid structures
                                        id_info[0] = pointer to window to plot
                                        id_info[1] = pointer to temp object
                                                     used in the clip method
                                                     called for reference file
                                                     objects
        > double *scale_factor   scale factor extracted from the type 9

Functions Invoked
	GUmapclass_to_igds
	GUotype3
	GUotype4
	GUotype6
	GUotype15
	GUotype16
	GUotype717
	GUotype24
	GUotype27
	GUplotsymbol
	om$get_classname

Methods Invoked
	GRvg.GRgetsize
	GRvg.GRgetrang
	GRvg.GRgeomprops
	GRvg.GRgetattr
	GRvg.GRgetgeom
	GRvg.GRgetsymb
	GRconic.GRgetarc

Notes
        This method is only used to create a plottable IGDS design file.
        No intelligence is retained in the translation, i.e. no symbols,
        graphic groups, etc.

	The user should have allocated the buffers passed in like so:

		dgn_buf [ GUDGN_BUF_SIZ ]
		bs_buf  [ GUBSBUF_SIZE ]
		ele_buf [ GUELE_BUF_SIZ ]

	These constants can be found in "transdef.h".

	Also upon entering, the following input variables should
	be initialized:

		md_env	   - to the current module environment.
		ele_size   - to 0 first time, left alone thereafter.
		file_des   - to the opened IGDS design file.

	sb/gfs  10/20/86    Design date.
        mrm     09/20/91    Added user-defined linestyle logic
        Jack    02/04/92    Made fix for plotting elements that have
                            symbology overrides, but not in the view
                            being plotted.  They were not getting plotted.
                            Also, I don't send the scaled matrix to DEget
                            since the context object for the object in a
                            ref file will not have this scale applied to it.
                            Also, added #include <alloca.h>.
*/

class implementation GRvg;

#include <alloca.h>
#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "madef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "fontdef.h"
#include "ex.h"
#include "exmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include <sys/types.h>
#include "DEso.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"


from GRconic import GRgetarc;
from GRtext import GRgettxattr;
from GRfm import GRvirt_search;
from DEso import DEget;

extern int GUget_symb_level();

method GRplotyourself(long *msg; struct GRmd_env *md_env; 
		      char *dgn_buf; char *bs_buf;
		      char *ele_buf; int *ele_size; int *file_des;
		      double *max_overflow; struct GRid *id_info;
		      double *scale_factor)
{
    char	*bs_ptr;
    char	class_name[OM_K_MAXCLASS_LEN];
    IGRboolean	reference_flag;
    IGRboolean	world = TRUE;
    IGRboolean  dealloc_flag = FALSE;
    IGRboolean	chk_status;
    IGRboolean	has_name = FALSE;
    IGRboolean	fill_bit = FALSE;
    IGRboolean  convert = FALSE;
    int	ele_type;
    long	status;
    long	object_size;
    long	six = 6;
    GRrange	range;
    unsigned char	*text_string;
    unsigned char	font_name[128];
    struct GRid		symbol_id;
    struct GRsymbology	symbology;
    struct GRprops	geo_props;
    struct IGRarc	arc;    
    struct IGResbc	bsc_attr;
    struct IGResbs	bss_attr;
    struct IGRestx	text_attr;
    struct GRmd_env	temp_env;
    struct GRmd_env	new_env;
    IGRmatrix		identity_mx;
    IGRmatrix		scale_matrix;
    short		num_rc = 4;
    short		mx_type = MAIDMX;
    short            temp_properties;
    double		x_ratio;
    double		y_ratio;
    double		w1,w2,h1,h2;
    double		tmp_bounds[4];
    struct IGRlbsys	text_lbs;
    struct IGRlbsys     *lbsys_ptr;
    IGRpoint		t1,t2,t3,t4;
    long		OMmsg;
    GRname		name;
    GRobjid		fontid;
    struct IGRbsp_curve	*my_curve;
    int              already_plotted_with_so = 0;  

    /* initialization */

    OMmsg = OM_S_SUCCESS; 
    bs_ptr = bs_buf;
    lbsys_ptr = (struct IGRlbsys *)bs_buf;

    if (GRFILLED_DISPLAY & me->properties)
    {
	fill_bit = TRUE;
    }

    /* get class name of the object */

    status = om$get_classname(classname = class_name, object = me);
    if (!(1 & status))
    {
	goto wrap_up;
    }

    /* map IGE class name to an IGDS element type */

    status = GUmapclass_to_igds (class_name, &ele_type);

    if (status != OM_S_SUCCESS)
    {
	goto wrap_up;
    }

    /* set-up scale matrix for IGE to IGDS working units */

    scale_matrix[0] = *scale_factor;
    scale_matrix[1] = 0.0;
    scale_matrix[2] = 0.0;
    scale_matrix[3] = 0.0;
    scale_matrix[4] = 0.0;
    scale_matrix[5] = *scale_factor;
    scale_matrix[6] = 0.0;
    scale_matrix[7] = 0.0;
    scale_matrix[8] = 0.0;
    scale_matrix[9] = 0.0;
    scale_matrix[10] = *scale_factor;
    scale_matrix[11] = 0.0;
    scale_matrix[12] = 0.0;
    scale_matrix[13] = 0.0;
    scale_matrix[14] = 0.0;
    scale_matrix[15] = 1.0;

    new_env = *md_env;

    MAmulmx(msg, &num_rc, &num_rc, &num_rc, scale_matrix,
            md_env->md_env.matrix, new_env.md_env.matrix);

    MAtypemx(msg, new_env.md_env.matrix, &new_env.md_env.matrix_type);


    /* get the symbology, range and properties of the object */

    status = om$send(mode = OM_e_wrt_object, 
                     msg = message GRvg.GRgetrang
                          (msg, &new_env.md_env.matrix_type, 
                           new_env.md_env.matrix, &world, range), 
                     senderid = my_id, 
                     targetid = my_id);

    /* check to see if this element will cause integer overflow */

    chk_status = GUcheck_overflow (msg, &six, range, max_overflow);

    if (!chk_status)
    {
      	/* this object will cause integer overflow, skip it */

	goto wrap_up;
    }

    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRvg.GRgetsymb(msg, &symbology),
                     senderid = my_id,
                     targetid = my_id);

    GUget_symb_level(msg, &symbology);

    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRvg.GRgeomprops
                          (msg, &new_env.md_env.matrix_type,
                           new_env.md_env.matrix, &geo_props),
                     senderid = my_id,
                     targetid = my_id);

    /*
        Get buffer size required by the b-spline representation of the
        object and allocate a new buffer if the standard buffer is not
        large enough.
    */

    status = om$send(mode = OM_e_wrt_object, 
                     msg = message GRvg.GRgetsize
                          (msg, &new_env.md_env.matrix_type, 
                           new_env.md_env.matrix, &object_size), 
                     senderid = my_id, 
                     targetid = my_id);

    if ((1 & status) && (object_size > GUBSBUF_SIZE))
    {
	/* buffer is not large enough */
	
#ifdef NO_ALLOCA
	bs_ptr = om$malloc(size = object_size);
	dealloc_flag = TRUE;
#else
        bs_ptr = (char *)alloca(object_size);
#endif
    }

    om$send(mode = OM_e_wrt_object,
            msg = message GRvg.GRgetname(msg, name),
            senderid = my_id,
            targetid = my_id);

    has_name = 1 & *msg;	

    /* check for user-defined linestyle */

    /* If object has a SO, then divide object into pieces */
    if ( me->properties & DEHAS_OVERRIDE )
    {
             int     *types;
             double  *boundary_parms;
             IGRboolean  show_it;
      struct GRid        soo;
      struct IGRdisplay *display_attributes;
      struct IGRdisplay  orig_ele_attr;
             int      count;

     /*
      * If the property bit for SO is set as true, but we do not get a valid soo
      *  object, then treat the case as though the object does not have a
      *  Symbology Override -- TR# 119415769 - -- Satya
      */
      DEget_soo( &soo.objid,
                 &soo.osnum,
                  OM_Gw_current_OS );

      if(soo.objid == NULL_OBJID)
        {
        IGRushort  osnum,mod_osnum;
        GRobjid temp_soo=NULL_OBJID, mod_id;
        char    name[1024],
          tmp_name[1024];
        osnum = OM_Gw_current_OS;

        ex$get_cur_mod ( id = &mod_id, osnum = &mod_osnum );
        strcpy ( name, "soo_" );
        if (osnum == mod_osnum)
        {
          status = OM_S_SUCCESS;
          strcpy ( &name [4], "master" );
        }
        else
        {
          status = om$os_number_to_name ( osnum = osnum, osname = tmp_name );
          if (status & 1)
          {
            /* om$os_number_to_name may return a full path name for the osname.
               This will put only the osname into name[4].
             */ 
           DEfind_refname (tmp_name, name);
          }
        }
        if (!(status & 1))
          {
            *msg = MSFAIL;
            return status;
          }
 
          ex$get_super ( mod_id = mod_id,
                 mod_osnum = mod_osnum,
                 super_name = name,
                 super_class = "DEso",
                 super_id = &temp_soo );

          if(temp_soo == NULL_OBJID) 
            {
            printf("get super failed hands upppppp \n");
            goto cont;
            }
          else soo.objid = temp_soo;

        }
      status = gr$get_active_display( buffer = &orig_ele_attr );

      /* Get a list of all the SOs that are on the object */
      status = om$send( msg = message DEso.DEget(
                   msg,
                  &types,
                  &boundary_parms,
                  &count,
                  &display_attributes,
                  &orig_ele_attr,
                   my_id,
                   id_info[0].objid,
                  &md_env->md_env.matrix_type,
                   md_env->md_env.matrix,                   
                   0,
                   1 ),
             targetid = soo.objid,
             targetos = soo.osnum );

      if (status != OM_S_SUCCESS)
      {
	goto wrap_up;
      }
       
      /* if there is a least one SO */
      if (count)
      {
	int i;

        already_plotted_with_so = 1;
        
        status = om$send( mode = OM_e_wrt_object,
                          msg = message GRvg.GRgetgeom(
                                msg, &new_env.md_env.matrix_type,
                                new_env.md_env.matrix, bs_ptr ),
                          senderid = my_id,
                          targetid = my_id );

        if (!(1 & status))
        {
            goto wrap_up;
        }

	my_curve = (struct IGRbsp_curve *)bs_ptr;

        status = om$send(msg = message GRvg.GRgetattr
                              (msg, (char *)&bsc_attr),
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        /****************************************************************/
	/* Use a 2-pass process to write to the plotfile.  The first    */
	/* pass writes the element itself.  So if there is a SO         */
	/* boundary, it will leave a gap in the element.  The second    */
	/* pass will then write just the SOs to the plotfile.  As you   */
	/* can tell, INVISIBLE SOs boundaries can thus be ignored.      */
        /****************************************************************/

#define CHECK_BOUNDARY 1
#if     CHECK_BOUNDARY
	if ( my_curve->num_boundaries )
	{
	  printf( "GRvg.GRplotyourself - The curve should not have" );
	  printf( " boundaries but it does. WHY ???\n" );
	}
#endif

        my_curve->bdrys = boundary_parms;
        my_curve->num_boundaries = count;

        GUsplit_curve( msg,
                       file_des,
                       dgn_buf,
                       ele_buf,
                       ele_size,
                       class_name,
                       my_curve,
                       range,
                      &symbology,
                      &geo_props,
                      &me->properties,
                      &bsc_attr );

        tmp_bounds[0] = 0.0;
        tmp_bounds[3] = 1.0;

        my_curve->bdrys = tmp_bounds;
        my_curve->num_boundaries = 2;

        for ( i=0; i<count; i++ )
        {
	  show_it = TRUE;

          tmp_bounds[1] = boundary_parms[i*2];
          tmp_bounds[2] = boundary_parms[i*2+1];
          symbology.display_attr = display_attributes[i];
          
          if (types[i] & DE_VIS)
          { 
				/*
				symbology.display_attr = orig_ele_attr;
				*/
              /** query the object for its symbology to be written on to 
               the plotfile -- fix TR #119602228 (inconsistency between
               the display and plot when visible symbology override is
               applied) -oo Anand oo-
               **/

             om$send(mode = OM_e_wrt_object,
                msg = message GRvg.GRgetsymb(msg, &symbology),
                senderid = my_id,
                targetid = my_id);         
          }
          else
            if (types[i] & DE_HIDDEN)
            {
              IGRboolean hidden_on;

              status = gr$get_hidden_so_on( msg    =  msg,
                                            buffer = &hidden_on );

              if (hidden_on)
              {
                struct GRhesym heattr;

                status = gr$get_hidden_edge_sym( msg    =  msg,
                                                 buffer = &heattr );

                if (heattr.flags & DPB_USE_ORIG_COLOR)
                  symbology.display_attr.color = orig_ele_attr.color;
                else
                  symbology.display_attr.color = heattr.color;

                if (heattr.flags & DPB_USE_ORIG_WEIGHT)
                  symbology.display_attr.weight = orig_ele_attr.weight;
                else
                  symbology.display_attr.weight = heattr.weight;

                if (heattr.flags & DPB_USE_ORIG_STYLE)
                  symbology.display_attr.style = orig_ele_attr.style;
                else
                  symbology.display_attr.style = heattr.style;
              }
	      else
		show_it = FALSE;
            }
            else
              if (types[i] & DE_INVIS)
              {
                IGRboolean invis_on;

                status = gr$get_invis_so_on( msg    =  msg,
                                             buffer = &invis_on );

                if (! invis_on)
                  symbology.display_attr = orig_ele_attr;
		else
		  show_it = FALSE;
              }

	  if ( show_it )
            GUsplit_curve( msg,
                           file_des,
                           dgn_buf,
                           ele_buf,
                           ele_size,
                           class_name,
                           my_curve,
                           range,
                          &symbology,
                          &geo_props,
                          &me->properties,
                          &bsc_attr );
        }
      }
    }

cont:
   if(!already_plotted_with_so)
    {
    /*
        For each element type supported, get the objects geometry and
        format an element buffer.
    */

    status = TRUE;

    switch (ele_type)
    {
      case GU_SYMBOL:

        status = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgetgeom 
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, bs_ptr),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        temp_env = new_env;

        memcpy((void *)temp_env.md_env.matrix, (void *)lbsys_ptr->matrix, 
               sizeof(double) * 16);
	
        MAtypemx (msg, temp_env.md_env.matrix,
                  &temp_env.md_env.matrix_type);

        reference_flag = 1;

        symbol_id.objid = my_id;
        symbol_id.osnum = OM_Gw_current_OS;

        GUplot_symbol(msg, &temp_env, dgn_buf, bs_ptr, ele_buf,
                      ele_size, file_des, max_overflow, id_info,
                      &symbol_id, &reference_flag);
        break;

      case GU_LINE:

          status = om$send(mode = OM_e_wrt_object,
                           msg = message GRvg.GRgetgeom
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

        status = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgetgeom
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

      case GU_SHAPE:
	
        status = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgetgeom
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

        temp_properties = me->properties;
        MAidmx(msg, identity_mx);

        status = om$send(mode = OM_e_wrt_object, 
                         msg = message GRvg.GRgetgeom
                              (msg, &mx_type, identity_mx,
                               (char *)&text_lbs), 
                         senderid = my_id, 
                         targetid = my_id);

        status = om$send(mode = OM_e_wrt_object, 
                         msg = message GRvg.GRgetgeom
                              (msg, &new_env.md_env.matrix_type, 
                               new_env.md_env.matrix, bs_ptr), 
                         senderid = my_id, 
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        /* if this is a view independent text element, find the rotation of
         * the view the text is being plotted in, get the inverse of that
         * matrix (just get the tranpose of the matrix since we know it's just
         * a rotation matrix) and multiply the text's matrix by this
         * matrix; this is done to cancel out the view'w rotation when it's
         * applied at plotting time, which we have to do for now instead of
         * marking the text as view independent because plotting does not
         * currently support view independent text plotted with FontServer,
         * which means we also need to clear the view independent properties
         * bit sent to the conversion function so that the text won't be
         * marked as view independent
         */

        if (ME.GRgraphics->properties & GRIS_VIEW_INDEP)
        {
            double        view_rot_matrix[16],
                             view_indep_matrix[16],
                             origin_matrix[16],
                             temp_matrix[16];
            long          which_error,
                             bytes_ret;
            int           index;
            struct var_list  var_list[2];
            struct IGRlbsys  *lbsys;
            short         dimension = 4;

            var_list[0].var = VIEW_ROTATION;
            var_list[0].var_ptr = (char *) view_rot_matrix;
            var_list[0].num_bytes = sizeof(double) * 16;
            var_list[0].bytes_returned = &bytes_ret;
            var_list[1].var = END_PARAM;

            dp$inq_set_gragad(msg = msg,
                              osnum = id_info[0].osnum,
                              gragad_objid = id_info[0].objid,
                              which_error = &which_error,
                              var_list = var_list);

            MAtrnmx(msg, &dimension, view_rot_matrix, view_rot_matrix);

            /* create an identity matrix that has the negative of the symbol's
             * origin
             */

            MAidmx(msg, origin_matrix);
            lbsys = (struct IGRlbsys *) bs_ptr;

            for (index = 0; index < 3; index++)
                origin_matrix[(index * 4) + 3] =
                               -lbsys->matrix[(index * 4) + 3];

            MAmulmx(msg, &dimension, &dimension, &dimension, origin_matrix,
                    lbsys->matrix, view_indep_matrix);
            MAmulmx(msg, &dimension, &dimension, &dimension, view_rot_matrix,
                    view_indep_matrix, temp_matrix);

            for (index = 0; index < 3; index++)
                origin_matrix[(index * 4) + 3] *= -1;

            MAmulmx(msg, &dimension, &dimension, &dimension, origin_matrix,
                    temp_matrix, lbsys->matrix);

            temp_properties &= ~GRIS_VIEW_INDEP;
        }

        status = om$send(mode = OM_e_wrt_object,
                         msg = message GRtext.GRgettxattr
                              (msg, &text_attr, NULL, &text_string),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status & *msg))
        {
            goto wrap_up;
        }

        /* check whether the text_attr.font is valid -- MADHU 90N1277 */

        ex$get_objid_from_NOD(NODname = FONTMGR_NOD,
                              objname = FONTMGR_NO_NAME,
                              pobjid = &fontid,
                              modid = md_env->md_id.objid,
                              mod_osnum = md_env->md_id.osnum);

        status = om$send(mode = OM_e_wrt_object, 
                         msg = message GRfm.GRvirt_search
                              (msg, font_name, &text_attr.font), 
                         senderid = md_env->md_id.objid, 
                         targetid = fontid,
                         from = NULL, 
                         to = NULL);

	
        if (!(1 & status & *msg))
        {
            goto wrap_up;
        }

        /* 
            Determine the ratio between the box around the original text
            and the box around the scaled text.
         
            The ratio in width and the ratio in height are calculated
            and passed to the text function where the IGDS length and
            height multipliers are adjusted.
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

        MA2ptdis (msg, t1, t3, &w2);
        MA2ptdis (msg, t2, t4, &h2);

        w1 = MAabsolute(text_lbs.diag_pt1[0] - text_lbs.diag_pt2[0]);
        h1 = MAabsolute(text_lbs.diag_pt1[1] - text_lbs.diag_pt2[1]);

        x_ratio = w2 / w1;
        y_ratio = h2 / h1;

        GUotype717(msg, file_des, dgn_buf, ele_buf, ele_size, 
                   class_name, bs_ptr, range, &symbology, 
                   &temp_properties, &text_attr, text_string, 
                   &new_env, &x_ratio, &y_ratio, &has_name, name,
                   &fill_bit, &convert, scale_factor);
			
        om$dealloc(ptr = text_string);
	
        break;

      case GU_ELLIPSE:

        status = om$send(mode = OM_e_wrt_object,
                         msg = message GRconic.GRgetarc
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, &arc),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }


        GUotype15(msg, file_des, dgn_buf, ele_buf, ele_size,
                  class_name, &arc, range, &symbology, &geo_props,
                  &me->properties, &has_name, name, &fill_bit);
        break;

      case GU_ARC:

        status = om$send(mode = OM_e_wrt_object,
                         msg = message GRconic.GRgetarc
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, &arc),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        GUotype16(msg, file_des, dgn_buf, ele_buf, ele_size,
                  class_name, &arc, range, &symbology, &geo_props,
                  &me->properties, &has_name, name, &fill_bit);
        break;

      case GU_BS_SURF_HEADER:

        status = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgetgeom
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, bs_ptr),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        status = om$send(msg = message GRvg.GRgetattr
                              (msg, (char *)&bss_attr),
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

        status = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgetgeom
                              (msg, &new_env.md_env.matrix_type,
                               new_env.md_env.matrix, bs_ptr),
                         senderid = my_id,
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        status = om$send(msg = message GRvg.GRgetattr
                              (msg, (char *)&bsc_attr),
                         targetid = my_id);

        if (!(1 & status))
        {
            goto wrap_up;
        }

        GUotype27(msg, file_des, dgn_buf, ele_buf, ele_size,
                  class_name, bs_ptr, range, &symbology, &geo_props,
                  &me->properties, &bsc_attr, &has_name, name,
                  &fill_bit);
        break;
    }
    }

wrap_up:

#ifdef NO_ALLOCA
    if (dealloc_flag)
    {
        om$dealloc (ptr = bs_ptr);
    }
#endif

    return (OM_S_SUCCESS);

}

end implementation GRvg;
