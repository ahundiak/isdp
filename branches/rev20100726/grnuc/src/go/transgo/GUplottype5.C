/*
Name
        GUplottype5

Description
        This function fills in the InterPlot type 5 level 4 element in
        an IGDS plotting metafile.

Notes
        This routine currently:
            o   assumes that the file is 3D
            o   has no reference file capability

        The graphic group number in the object header is treated by InterPlot
        as a version number.  Although the code has been updated to reference
        the new, larger IPPlotT5 structure, the new fields are not being
        filled in.  That needs to be rectified, but in the meantime everything
        works okay with the old version number in place.

History
        ???     ??/??/??    creation
        mrm     09/25/91    fixed to properly read the level symbology info
                02/18/92    updated to latest IPPlotT5 structure
                03/21/92    swap Sun color table to IGDS format
                04/02/92    remove unnecesary swapping from VWTRN read,
                            copy the entire level symbology element into
                            the type 5 (rather than just the first
                            word), convert the level symbology mask to
                            InterPlot format
        TW      05/26/92    Added code to plot a entire perspective window.
        dhm     10/07/92    changed dimension of a matrix passed to MA
                            routines to be a short and number of points passed
                            to MAptsxform to be a long.
	Satya   05/26/95    my_max is initialized to zero to avoid crash
			    TR# 119525761
*/

#include "exsysdep.h"
/*
#include "grimport.h"
*/
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igrdp.h"
#include "igr.h"
#include "gr.h"
#include "godef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "transerr.h"
#include "transdef.h"
#include "translate.h"
#include "transmacros.h"
#include "trans_ele.h"

extern IGRboolean MAidmx(), MAmulmx(), MAinvmx();
extern struct GRid GUwindow_being_plotted;


IGRlong GUplottype5(msg, cvtbuf, block, byte, extents, scale_factor)
IGRlong *msg;
struct GUcvt_bufs *cvtbuf;
IGRint *block;
IGRint *byte;
IGRdouble extents[];
IGRdouble *scale_factor;
{
    IGRboolean read_status;
    IGRboolean ext_type_nine = FALSE;
    IGRboolean chk_status;
    IGRshort dim = 4, four = 4;
    IGRshort write_mode = GUWRITE;
    IGRshort font=0;
    IGRint   count;
    IGRshort igds_mask, ip_mask;
#ifdef BIG_ENDIAN
    IGRshort  *p_short;
#endif
    IGRlong *long_ptr;
    IGRlong num_vals = 3;
    IGRlong status;
    IGRlong byte_offset;
    IGRlong bit_offset;
    IGRlong i;
    IGRlong index;
    IGRlong offset;
    IGRlong vw_origin[3];
    IGRulong vw_extent[3];
    IGRulong vw2_origin[3];
    IGRulong scratch[2];
    IGRdouble IGDS_scale = 1.0;
    IGRdouble my_max;
    IGRdouble chk_array[3];
    IGRdouble rotate[9];
    IGRmatrix tempmtrx;
    IGRmatrix padmtrx;
    IGRmatrix xform;
    IGRmatrix inverse;
    IPPlotT5 plot5;

    struct DPgra_gad gg;
    struct var_list  inq_array[2];
    IGRlong which_error,num_ret;
    IGRdouble trans[4][4],wld_to_view[4][4],shear[4][4],view_to_plot[4][4];
    IGRlong one=1;
    IGRdouble far,near,shear_x,shear_y,D,window_length,window_width;
    IGRdouble vw_near[3],z_factor,proj_near;
    IGRdouble pers_clip_xhigh = 0.0, pers_clip_yhigh = 0.0;
    IGRdouble pers_clip_zhigh = 0.0;
    IGRdouble pers_xform[16];
    IGRdouble tan();
    
    /* my_max is being initialised, as it is used without further 
       assignments in the calling function -- TR# 119525761 **/ 
    my_max = 0;

    /* initialized the view_extents for TR#119701697      */
    /* also initialised font and plot5.font_mask          */ 
    /*                                      - jeff & Jaya */

vw_extent[0]=0;
vw_extent[1]=0;
vw_extent[2]=0;

    /* position file pointers to beginning of IGDS file */

    status = lseek(cvtbuf->file_des, 0, 0);

    read_status = TRUE;

    /* initialize header information */

    memset((char *)&plot5, 0, sizeof(IPPlotT5));
    plot5.type_level = 0x0504;
    plot5.words_to_follow = 662;        /* needs to be updated */
    plot5.xlow = 0;
    plot5.ylow = 0;
    plot5.zlow = 0;
    plot5.xhigh = GRDGNLIMITS_MAX_I;
    plot5.yhigh = GRDGNLIMITS_MAX_I;
    plot5.zhigh = GRDGNLIMITS_MAX_I;
    plot5.graphic_group = 0;            /* InterPlot version number */
    plot5.attr_linkage = 0;
    plot5.properties_mask = 0;
    plot5.display_symb_mask = 0;


    /* If the view is perspective, calculate the transformation matrix.
       (Put this part outside the while() loop is to save time.)

       This matrix can transform points from IGDS world coordinate system
       to the ploting coordinate (NDC) system. The perspective view corn
       in IGDS system is transformed to a rectangular box in ploting system in
       this way: if you stand at the eye_point, the left-down corner of the
       far-cliping plane is transformed to the origin (one corner of the box),
       and the upper-right corner of the near plane is transformed to the
       other corner of the box.(xhigh,yhigh,zhigh)

       In short, ploting routines can use this Homogenious matrix exactly
       the SAME way as in parallel view case: get a pt from IGDS file,
       transform it to ploting space, and cliped by the (0,0,0),and (xhigh,
       yhigh,zhigh) box. [TW]

    */

    inq_array[0].var = GRAGAD_STRUCT;
    inq_array[0].var_ptr = (IGRchar *)&gg;
    inq_array[0].num_bytes = sizeof(struct DPgra_gad);
    inq_array[0].bytes_returned = &num_ret;

    inq_array[1].var = END_PARAM;
    inq_array[1].var_ptr = NULL;
    inq_array[1].num_bytes = 0;
    inq_array[1].bytes_returned = NULL;

    dp$inq_set_gragad(msg = msg,
                inq0_set1 = 0,
                    osnum = GUwindow_being_plotted.osnum,
             gragad_objid = GUwindow_being_plotted.objid,
              which_error = &which_error,
                 var_list = inq_array);

    if(gg.flags & IS_PERSP) {

       /* prepare the transformation matrix for persp ploting */

          /* step 1: get wld_to_view matrix */

          MAidmx(msg,trans);
          trans[0][3] = -gg.eye_pt[0]* *scale_factor;
          trans[1][3] = -gg.eye_pt[1]* *scale_factor;
          trans[2][3] = -gg.eye_pt[2]* *scale_factor;
          MAmulmx(msg,&four,&four,&four,gg.rotation,trans,wld_to_view);

          /* step 2: add shear */

          far  = gg.vw_volume[5]* *scale_factor;
          near = gg.vw_volume[2]* *scale_factor;
          if(near < 1.0) near = 1.0;  /* avoid near plane proj to infinity */

          window_width = gg.dit_clip_range[3] - gg.dit_clip_range[0];
          window_length = gg.dit_clip_range[4] - gg.dit_clip_range[1];
          if(window_length < window_width) {
              shear_y = tan(gg.vw_angle/2.0);
              shear_x = shear_y * window_width / window_length;
          }
          else {
              shear_x = tan(gg.vw_angle/2.0);
              shear_y = shear_x * window_length / window_width;
          }
          MAidmx(msg,shear);            /* shear matrix */
          shear[0][2] = -shear_x;
          shear[1][2] = -shear_y;

          /* step 3: move origin from eye_pt to far plane */

          D = far;
          MAidmx(msg,trans);            /* trans2[][] * shear[][] */
          trans[2][3] = D;
          MAmulmx(msg,&four,&four,&four,trans,shear,tempmtrx);

          /* step 4: add projection part */
          /* if near is very small, near plane will be projected to too
          far (eye_pt will go to infinity !). This may out of the range of
          the ploting space.  Now I reduce the projected z depth, making it
          proportional to the x,y direction of the original perspective view
          pyramid. */

          MAidmx(msg,trans);            /* proj[] * trans2[][] * shear[][] */
          trans[3][2] = -1.0/D;         /* proj part */

          proj_near = far - near;       /* scale factor on z-direction */
          proj_near = D*proj_near / (D-proj_near);
          z_factor = (far-near) / proj_near;
          trans[2][2] = z_factor;

          MAmulmx(msg,&four,&four,&four,trans,tempmtrx,view_to_plot);

/*
          vw_near[0] = near * shear_x;
          vw_near[1] = near * shear_y;
          vw_near[2] = -near;
          MAptsxform(msg,&one,view_to_plot,vw_near,vw_near);

          factor = (far - near) / vw_near[2];
          view_to_plot[2][0] *= factor;
          view_to_plot[2][1] *= factor;
          view_to_plot[2][2] *= factor;
          view_to_plot[2][3] *= factor;
*/

          /* final pers_xform[][] */

          MAmulmx(msg,&four,&four,&four,view_to_plot,wld_to_view,pers_xform);

          /* calculate plot5.clip_high */

          vw_near[0] = near * shear_x;
          vw_near[1] = near * shear_y;
          vw_near[2] = -near;

          MAptsxform(msg,&one,view_to_plot,vw_near,vw_near);

          pers_clip_xhigh = vw_near[0];
          pers_clip_yhigh = vw_near[1];
          pers_clip_zhigh = vw_near[2];

      } /* end if IS_PERSP */


    /* search for type 9, text, and text node elements */

    while (read_status == TRUE)
    {
	read_status = GUget_next_ele(msg, cvtbuf);

        /*  added this because, if we get a FALSE read_status, it's a good bet */
        /*  that we don't have anything reasonable to process */
        /*  Mike Lanier: 01/20/98 */

        if( read_status != TRUE ) continue;

	cvtbuf->ele_type = (cvtbuf->ele_buf[1] & 0x7f);

	if (cvtbuf->ele_type == GU_DGN_FILE_HEADER && !ext_type_nine)
	{
	    ext_type_nine = TRUE;

            /*
                determine the NDC Coodinate Space Clipping Limits
                    point(low) = 0.0
		    point(high) = view extents
            */

	    plot5.clip_xlow = 0.0;
	    plot5.clip_ylow = 0.0;
	    plot5.clip_zlow = 0.0;

            /* set plot5.clip_?high */

            if(gg.flags & IS_PERSP) {

                /* For perspecitve view, vw_extent[] has bad (seem undefined)
                   number. So if pers_clip_xhigh etc are too big, I can't
                   use the vw_extent[], as in the parallel view case. In
                   addition, maybe because of the bad number of vw_extent[],
                   the tolerance of the ploting is not correct. So sometimes
                   a sphere plotted is not very round. Something must be done
                   to fix this BUG !!!!. [TW] */

                if(pers_clip_xhigh < (double)GRDGNLIMITS_MAX_I)
                        plot5.clip_xhigh = (IPuint32)pers_clip_xhigh;
                else
                        plot5.clip_xhigh = GRDGNLIMITS_MAX_I;

                if(pers_clip_yhigh < (double)GRDGNLIMITS_MAX_I)
                        plot5.clip_yhigh = (IPuint32)pers_clip_yhigh;
                else
                        plot5.clip_yhigh = GRDGNLIMITS_MAX_I;

                if(pers_clip_zhigh < (double)GRDGNLIMITS_MAX_I)
                        plot5.clip_zhigh = (IPuint32)pers_clip_zhigh;
                else
                        plot5.clip_zhigh = GRDGNLIMITS_MAX_I;
/*
printf("pers_zhigh=%f\n",pers_clip_zhigh);
printf("plot5.zhigh=%ld, MAX=%ld\n",plot5.clip_zhigh,(double)GRDGNLIMITS_MAX_I)\
;
*/

                /* prepare the rotate[] with gragad's rotation matrix */

                for (i = 0; i < 3; ++i) {
                        rotate[i * 3] = gg.rotation[i][0];
                        rotate[(i * 3) + 1] = gg.rotation[i][1];
                        rotate[(i * 3) + 2] = gg.rotation[i][2];
                    }

                for(i=0; i<16; i++) {
                        xform[i] = pers_xform[i];
                    }

               /* fill in the scale field */

               long_ptr = (IGRlong *) &plot5.scale_DB_to_plot;
               GRFlt32ToFltVax(1, &IGDS_scale, long_ptr);

            }

            else { /* parallel view  processing */

            /* grab the view extents from View 1 (VXOR, VYOR, VZOR) */

	    for (i = 0; i < 3; ++i)
	    {
		OM_BLOCK_MOVE(&cvtbuf->ele_buf[26 + 42 + (i * 4)], 
                              &vw_extent[i], 4);
#ifdef BIG_ENDIAN
                GRconv_int(&vw_extent[i], &vw_extent[i]);
#endif
		GUswapint(&vw_extent[i], &vw_extent[i]);
	    }

	    /* use the extents in view coordinates */

	    chk_array[0] = *scale_factor * (extents[9] - extents[6]);
	    chk_array[1] = *scale_factor * (extents[10] - extents[7]);
	    chk_array[2] = *scale_factor * (extents[11] - extents[8]);

	    chk_status = GUcheck_overflow(msg, &num_vals, chk_array, &my_max);

	    if (!chk_status)
	    {
		plot5.clip_xhigh = vw_extent[0];
		plot5.clip_yhigh = vw_extent[1];
		plot5.clip_zhigh = vw_extent[2];
	    }
	    else
	    {
		plot5.clip_xhigh = chk_array[0];
		plot5.clip_yhigh = chk_array[1];
		plot5.clip_zhigh = chk_array[2];
	    }

            /* fill in the scale field */

            long_ptr = (IGRlong *) &plot5.scale_DB_to_plot;
	    GRFlt32ToFltVax(1, &IGDS_scale, long_ptr);

            /* fill in transformation data (use VWTRN of View 1) */

	    index = 26 + 54;

	    for (i = 0; i < 9; ++i)
	    {
		OM_BLOCK_MOVE(&cvtbuf->ele_buf[(i * 8) + index], scratch, 8);
		GRFltVaxToFlt32(1, scratch, &rotate[i]);
	    }

            /* use (identity w/neg origin) * (vwtrn(view 1)) */

	    MAidmx(msg, tempmtrx);

            /*  
                calculate the origin of the plotting view (fence, or window)
                lower left point in world coordinates * scale factor
            */

	    chk_array[0] = extents[0] * *scale_factor;
	    chk_array[1] = extents[1] * *scale_factor;
	    chk_array[2] = extents[2] * *scale_factor;

	    vw_origin[0] = (IGRlong) chk_array[0];
	    vw_origin[1] = (IGRlong) chk_array[1];
	    vw_origin[2] = (IGRlong) chk_array[2];

	    chk_status = GUcheck_overflow(msg, &num_vals, chk_array, &my_max);

	    if (!chk_status)
	    {
		for (i = 0; i < 3; ++i)
		{
		    OM_BLOCK_MOVE(&cvtbuf->ele_buf[26 + 30 + (i * 4)],
				  &vw2_origin[i], 4);
#ifdef BIG_ENDIAN
                    GRconv_int(&vw2_origin[i], &vw2_origin[i]);
#endif
		    GUswapint(&vw2_origin[i], &vw_origin[i]);
		}
	    }

            /* load the negative of the origin */

	    tempmtrx[3] = 0.0 - vw_origin[0];
	    tempmtrx[7] = 0.0 - vw_origin[1];
	    tempmtrx[11] = 0.0 - vw_origin[2];

            /* pad the rotation matrix; 3 X 3 -> 4 X 4 */

	    for (i = 0; i < 3; ++i)
	    {
		padmtrx[i * 4] = rotate[i * 3];
		padmtrx[(i * 4) + 1] = rotate[(i * 3) + 1];
		padmtrx[(i * 4) + 2] = rotate[(i * 3) + 2];
		padmtrx[(i * 4) + 3] = 0.0;
		padmtrx[i + 12] = 0.0;
	    }

	    padmtrx[15] = 1.0;

	    if (!MAmulmx(msg, &dim, &dim, &dim, padmtrx, tempmtrx, &xform[0]))
	    {
		status = OM_E_ABORT;
		goto wrapup;
	    }

            } /* end parallel view matrix preparation */




            /* calculate the inverse of the xform_to_NDC matrix */

	    if (!MAinvmx(msg, &dim, xform, inverse))
	    {
		status = OM_E_ABORT;
		goto wrapup;
	    }

            /*
                store the matrices in the type 5 using the vax floating
                point format
            */


	    dim = 3;
	    MAtrnmx(msg, &dim, rotate, rotate);

	    dim = 4;
	    MAtrnmx(msg, &dim, xform, xform);
	    MAtrnmx(msg, &dim, inverse, inverse);

	    for (i = 0; i < 9; ++i)
	    {
                long_ptr = (IGRlong *) &plot5.rotate_DB_to_plot[i];
                GRFlt32ToFltVax(1, &rotate[i], long_ptr);

                long_ptr = (IGRlong *) &plot5.xform_DB_to_plot[i];
                GRFlt32ToFltVax(1, &xform[i], long_ptr);

                long_ptr = (IGRlong *) &plot5.xform_plot_to_DB[i];
                GRFlt32ToFltVax(1, &inverse[i], long_ptr);
	    }

	    for (i = 9; i < 16; ++i)
	    {
                long_ptr = (IGRlong *) &plot5.xform_DB_to_plot[i];    
                GRFlt32ToFltVax(1, &xform[i], long_ptr);

                long_ptr = (IGRlong *) &plot5.xform_plot_to_DB[i];
                GRFlt32ToFltVax(1, &inverse[i], long_ptr);
	    }

            /* fill in display information */
	
	    /* extract from type/level word  */
	    OM_BLOCK_MOVE(&cvtbuf->ele_buf[0], &plot5.dimension, 2);
#ifdef BIG_ENDIAN
            GRconv_short(&plot5.dimension, &plot5.dimension);
#endif
	    plot5.dimension = (plot5.dimension & 0xC0) >> 6;

	    /* TCB variable VWLEV(view#) */
	    for (i = 0; i < 4; ++i)
	    {
                OM_BLOCK_MOVE(&cvtbuf->ele_buf[26 + 22 + (i * 2)],
                              &plot5.level_mask[i], 2);
#ifdef BIG_ENDIAN
                GRconv_short(&plot5.level_mask[i], &plot5.level_mask[i]);
#endif
	    }

	    /* TCB variable VWFLG(view#) */
	    OM_BLOCK_MOVE(&cvtbuf->ele_buf[26 + 20],
			  &plot5.display_flags, 2);
#ifdef BIG_ENDIAN
            GRconv_short(&plot5.display_flags, &plot5.display_flags);
#endif

	    /* TCB variable FBFDCN (bit 8) */
	    OM_BLOCK_MOVE(&cvtbuf->ele_buf[26 + 1306 - 118],
			  &plot5.extended_dflags, 2);
#ifdef BIG_ENDIAN
            GRconv_short(&plot5.extended_dflags, &plot5.extended_dflags);
#endif
	    plot5.extended_dflags = 
                (unsigned short)(plot5.extended_dflags & 0x0100) >> 8;

	    /* set default color table information */

	    plot5.co_tab_attached = 1;
	    GUplotctb(msg, plot5.color_table);

#ifdef BIG_ENDIAN
            /* swap the color table from Sun to IGDS format */
            for (i = 0, p_short = (IGRshort *)plot5.color_table;
                 i < ((256 * 3) / 2);
                 i++, p_short++)
            {
                GRconv_short(p_short, p_short);
            }
#endif
	}
	else if ((cvtbuf->ele_type == GU_TEXT) ||
                 (cvtbuf->ele_type == GU_TEXT_NODE))
        {
            if (cvtbuf->ele_type == GU_TEXT)
            {
                font = cvtbuf->ele_buf[36];
            }
            else
            {
                font = cvtbuf->ele_buf[44];
            }

/*  Removed this because, I believe, it is not needed.  Debugging shows  */
/*  that the value in 'font' is correct before it is converted and the  */
/*  value for byte_offset computed from the converted, incorrect value */
/*  causes us to step outside the 'font_mask' array. */
/*  Mike Lanier: 01/20/98: TR 119701697 */

#ifdef xBIG_ENDIAN
            GRconv_short(&font, &font);
#endif

            byte_offset = font / 8;
            bit_offset = font % 8;
            
            for(count=0;count<16;count++)
                plot5.font_mask[count]=0;

            plot5.font_mask[byte_offset] |= (1 << bit_offset);
	}
        else if (cvtbuf->ele_type == GU_LEVEL_SYMBOLOGY)
        {
            /*
                Put the level symbology information into the type 5.
                Note that InterPlot will not interpret this unless the
                level symbology bit is set in the display_flags field.
                Therefore, the user should set that bit in the VWFLG for
                view 1 in the IGDS seedfile to activate the level
                symbology information.
            */

            /*
                get the symbology mask from the first word of the
                element's zhi coordinate
            */

            OM_BLOCK_MOVE(&cvtbuf->ele_buf[26], &igds_mask, 2);

            /*
                convert the mask from IGDS format to InterPlot format

                IGDS mask definition            InterPlot mask definition
                1000 0000 0000 0cws             cccc cccc wwww wsss

                c == 1 => override color        c == 1 => override color
                w == 1 => override weight       w == 1 => override weight
                s == 0 => override style        s == 1 => override style
                          (yes, zero)
            */

            ip_mask = 0;
            if (igds_mask & 0x04)    ip_mask |= 0xff00;
            if (igds_mask & 0x02)    ip_mask |= 0x00f8;
            if (!(igds_mask & 0x01)) ip_mask |= 0x0007;

            /* copy the level symbology table into the type 5 */

            OM_BLOCK_MOVE(&cvtbuf->ele_buf[28], plot5.symbology,
                          63 * sizeof(IPint16));
        }
    }

    /* write updated type 5 back into file */

    offset = (*block * 512) + *byte;
    status = lseek(cvtbuf->file_des, offset, 0);

    cvtbuf->ele_type = 5;
    cvtbuf->ele_size = 1328;

#ifdef BIG_ENDIAN
    GRswap_type5lv4_ele(&plot5);
#endif

    status = GUwrite_element(msg, cvtbuf->dgn_buf, &plot5,
			     &cvtbuf->ele_type, &cvtbuf->ele_size,
			     &cvtbuf->file_des, &write_mode,
			     block, byte);

    /* flush the buffers to be sure the type 5 is written to the file */

    write_mode = GUFLUSH;
    status = GUwrite_element(msg, cvtbuf->dgn_buf, &plot5,
			     &cvtbuf->ele_type, &cvtbuf->ele_size,
			     &cvtbuf->file_des, &write_mode,
			     block, byte);

wrapup:

    return (status);
}
