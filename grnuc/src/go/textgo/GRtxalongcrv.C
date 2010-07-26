/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME    GRtext_along_curve
 
     Abstract:

            This function takes a B-spline curve, a starting point on the
        curve (with its u-parameter), a view rotation matrix, a text string
        and calculates the origin and orientation of each character so the
        characters lie along the curve.
-----
%SC%

     VALUE =  GRtext_along_curve(msg, curve, start_pt, side_pt, preferred_dir,
                                 view_matrix, text_string, font_info,
                                 text_width, text_height, char_spacing,
                                 line_spacing, text_length, num_pts, origin,
                                 orient_matrix, out_flags)
                                 
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                        DESCRIPTION
     ----------   -------------------   --------------------------------------
     *curve       struct IGRbsp_curve   B-spline curve geometry
     start_pt     IGRpoint              point on the curve from which to
                                        begin generating points
     side_pt      IGRpoint              point to indicate which side of the
                                        curve the text is should be placed on
     preferred_dir IGRint               TRUE if the orientation of the text
                                        is desired to be from left to right
                                        or bottom to top, FALSE for the
                                        reverse orientation
     view_matrix  IGRmatrix             view rotation matrix of view in which
                                        the text is to be "readable"
     *text_string IGRuchar              the chars. to be put along the curve
     *font_info   struct vfont_entry    current text font information
     text_width   IGRdouble             the width of the characters
     text_height  IGRdouble             the height of the characters
     char_spacing IGRdouble             character spacing of the text
     line_spacing IGRdouble             line spacing of the text (used to
                                        offset the text from the curve)
     *text_length IGRshort              number of chars. (bytes) in text string
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                     DESCRIPTION
     ----------   ----------------  ---------------------------------------
     *msg         IGRlong           completion code
                                     - MSSUCC     if successful
                                     - MSINARG    if the curve is normal to
                                                  the view plane
                                     - MSFAIL     if failure
     *text_length IGRshort          number of chars. (bytes) in text string
                                    (string may be truncated if curve is too
                                     short)
     *num_pts     IGRint            number of array entries returned in
                                    origin and orient_matrix
     *origin      IGRpoint          array of points along the specified curve
                                    that are the origins of the text characters
     *orient_matrix IGRmatrix       the orientation matrices that correspond
                                    to the origins above; memory should be
                                    provided by the caller for both the origins
                                    and the matrices - the maximum number of
                                    entries required is the number of
                                    displayable characters in the text string
     *out_flags    IGRint           flags containg information about the
                                    origins and matrices returned - #defines
                                    can be found in gotextdef.h
                                    GRTX_REV_SIDE - if text should be cap
                                         justified instead base justified
                                    GRTX_SINGLE_ELEM - the whole text string
                                         has the same origin and orientation
                                         so it can be placed as a single element

     VALUE (IGRboolean) = TRUE         - if successful
                          FALSE        - if failure
-----
%MD%

     FUNCTIONS INVOKED: 
-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:

        WBC  08/07/91 : Creation date.
        SCW  07/21/92 : Ansi conversion
        WBC  06/01/93 : Initialized members of the just_info struct to take
                        care of UMRs reported by Purify.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include <alloca.h>

#include "exsysdep.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "igrdp.h"
#include "gotextdef.h"
#include "gotext.h"
#include "bserr.h"
#include "grerr.h"
#include "madef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "FS.h"
#include "FSOutl.h"
#include "OMmacros.h"

#define PARM_OFFSET  0.00001   /* used in creating a proximity point */


IGRint GRtext_along_curve(msg, curve, start_pt, side_pt, preferred_dir,
                          view_matrix, text_string, font_info, text_width,
                          text_height, char_spacing, line_spacing, text_length,
                          num_pts, origin, orient_matrix, out_flags)

IGRlong             *msg;         /* completion code */
struct IGRbsp_curve *curve;       /* B-spline curve geometry */
IGRpoint            start_pt;     /* point on the curve from which to
                                     begin generating points */
IGRpoint            side_pt;      /* point to indicate which side of the
                                     curve the text is should be placed on */
IGRint              preferred_dir;/* TRUE if the orientation of the text
                                     is desired to be from left to right
                                     or bottom to top, FALSE for the
                                     reverse orientation */
IGRmatrix           view_matrix;  /* view rotation matrix of view in which
                                     the text is to be "readable" */
IGRuchar            *text_string; /* the chars. to be put along the curve */
struct vfont_entry  *font_info;   /* font information */
IGRdouble           text_width;   /* the width of the characters */
IGRdouble           text_height;  /* the height of the characters */
IGRdouble           char_spacing; /* character spacing of the text */
IGRdouble           line_spacing; /* line spacing of the text (used to
                                     offset the text from the curve) */
IGRshort            *text_length; /* number of chars. (bytes) in text string */
IGRint              *num_pts;     /* number of array entries returned in
                                     origin and orient_matrix (see below) */
IGRpoint            *origin;      /* array of points along the specified curve
                                     that are the origins of the text chars */
IGRmatrix           *orient_matrix;/*the orientation matrices that correspond
                                     to the origins above; memory should be
                                     provided by the caller for both the origins
                                     and the matrices - the maximum number of
                                     entries required is the number of
                                     displayable characters in the text string*/
IGRint              *out_flags;   /* flags containg information about the
                                     origins and matrices returned - #defines
                                     can be found in gotextdef.h
                                     GRTX_REV_SIDE - if text should be cap
                                       justified instead base justified
                                       (on the reverse side of the curve)
                                     GRTX_SINGLE_ELEM - the whole text string
                                       has the same origin and orientation
                                       so it can be placed as a single element*/

{
    extern void BScvarrevt();
    extern IGRdouble BSarclen();
    extern IGRboolean BSptsdlcv(), BSprptoncv(), BScrossp(), MAang2vc(),
                      MAbcrevparm(), MAunitvc(), MAptonvc();

    OutlCharInfo  charinfo;
    IGRint        value, i, j, elem_preferred_dir, begin_parm_index, index_size;
    IGRint        str_index,temp_msg;
    IGRshort      num_chars; 
    IGRlong       bsrc;
    IGRdouble     end_parm, dir_parm, tmp_parm, arc_length, *uparm, distance,
                  start_parm, angle[3], view_origin[3], view_xy_angle[3],
                  char_size_factor, addl_char_spacing, half_char_width;
    IGRpoint      (*vector_pts)[2], proj_pt, start_vectors[2], proximity_pt;
    IGRvector     line_vec, y_axis, z_axis, side_vec;
    IGRboolean    status, on_curve, curve_reversed;
    CharId        charid;
    struct IGRestx      text_attr;          /* text specific attributes      */
    IGRdouble           wk_origin[2];       /* current working origin        */
    IGRdouble           base_line;          /* current base line             */
    IGRshort            prev_font;
    struct just_info    just_info;
    struct extents      unjust_extents;
    struct IGRdisplay   cur_disp_attr;
    IGRint              chars_processed,txt_substr_ptr;
    IGRboolean          mode;               /* skip multiple escape seqs     */
    IGRboolean          leave;              /* flag for leaving loop         */
    IGRint              char_index;
    IGRdouble           *y_displacement;
    struct vfont_entry  fnt_inf;
    IGRdouble           initial_char_height;


    initial_char_height = 0.0;
   

    OM_BLOCK_MOVE( font_info, &fnt_inf, sizeof(struct vfont_entry));

    if ((text_string[0]==27)&(text_string[1]=='J')) 
         OM_BLOCK_MOVE(&text_string[2],&distance,sizeof(IGRdouble));
    else distance=0.0;


    value = TRUE;
    uparm = NULL;
    *num_pts = 0;
    *out_flags = 0;
    curve_reversed = FALSE;
    view_origin[0] = 0.0;
    view_origin[1] = 0.0;
    view_origin[2] = 0.0;
    text_attr.width = text_width;
    text_attr.height = text_height;
    text_attr.char_spac = char_spacing;
    text_attr.line_spac = line_spacing;
    wk_origin[0]=wk_origin[1]=base_line=0.0;

    y_displacement= (IGRdouble *)alloca(*text_length* sizeof(IGRdouble));
    

    MAang2vc(msg, view_matrix, &view_matrix[4], view_xy_angle);

    /* project the side point onto the plane which is parallel to the view's
     * x-y plane and contains the start point; this will be used to create a
     * vector going from the start point in the direction of the side point
     */

    BSproj1(&bsrc, side_pt, &view_matrix[8], start_pt, proj_pt);

    side_vec[0] = proj_pt[0] - start_pt[0];
    side_vec[1] = proj_pt[1] - start_pt[1];
    side_vec[2] = proj_pt[2] - start_pt[2];

    /* find the parameter of the start point on the curve */

    BSprptoncv(&bsrc, curve, start_pt, &start_parm, &on_curve);

    /* get the vector which is tangent to the start point on
     * the curve; it will be used to determine the "preferred" direction
     * of the text and which way the curve is currently going
     */

    BScvarrevt(curve, &start_parm, 1, 1.0, start_vectors, &bsrc);

    if (bsrc == BSSUCC)
    {
        /* move the tangent vector so that its start point is
         * at the origin (0,0,0) - the same as the view vectors
         */

        start_vectors[1][0] -= start_vectors[0][0];
        start_vectors[1][1] -= start_vectors[0][1];
        start_vectors[1][2] -= start_vectors[0][2];

        /* find the angle between the view's x-vector and the projection of
         * the start point's tangent vector onto the view's x-y plane (which
         * is measured counter clockwise in radians); if the angle is less
         * than or equal to PI/2 or between 3/2PI and 2PI (the first and
         * fourth quadrants), the direction of the curve is the "preferred"
         * direction, otherwise the parameterization of the curve should be
         * reversed
         */

        BSproj1(&bsrc, start_vectors[1], &view_matrix[8], view_origin, proj_pt);
        MAang2vc(msg, view_matrix, proj_pt, angle);

        if (*msg == MSSUCC)
        {
            if ((angle[0] > PI/2) && (angle[0] <= 1.5 * PI))
                elem_preferred_dir = FALSE;
            else
                elem_preferred_dir = TRUE;
        }
        else
            elem_preferred_dir = TRUE;

        if ((preferred_dir && ! elem_preferred_dir) ||
            (! preferred_dir && elem_preferred_dir))
        {
            MAbcrevparm(msg, curve, curve);
            curve_reversed = TRUE;

            /* reverse the direction of the tangent vector */

            start_vectors[1][0] = -start_vectors[1][0];
            start_vectors[1][1] = -start_vectors[1][1];
            start_vectors[1][2] = -start_vectors[1][2];
            proj_pt[0] = -proj_pt[0];
            proj_pt[1] = -proj_pt[1];
            proj_pt[2] = -proj_pt[2];

            /* find the parameter of the start point on the curve again
             * since the curve's parameterization has been reversed
             */

            BSprptoncv(&bsrc, curve, start_pt, &start_parm, &on_curve);
        }

        /* determine which side of the curve the text should be placed along;
         * if the angle between the projection of the text's x-axis onto the
         * view's x-y plane and the side vector is less than or equal to PI,
         * the text should be "above" the curve (base justified), else it will
         * be below the curve and needs to be cap justtified
         */

        MAang2vc(msg, proj_pt, side_vec, angle);

        if (*msg == MSSUCC)
        {
            /* we need for the angle to be counter-clockwise relative to the
             * view, so if the angle between the view's x and y axes is
             * PI/2 radians, the angle we have is correct but if the angle
             * between the view's x and y axes is 1.5*PI, we have the complement
             * of the angle we want; comparing against PI to avoid tolerance
             * problems
             */

            if (view_xy_angle[0] > PI)
            {
                angle[0] = 2 * PI - angle[0];  /* get complement of angle */
            }

            if (angle[0] > PI)
                *out_flags |= GRTX_REV_SIDE;
        }
    }
    else
    {
        *msg = MSFAIL;
        goto wrapup;
    }

    if (curve->phy_closed)
    {
        /* since this is a closed curve we can use the entire length
         * of the curve to place the text along
         */

        tmp_parm = 0.0;
        end_parm = 1.0;
        dir_parm = 0.5;
    }
    else
    {
        /* find the length of the open curve from the start point
         * to the end of the curve
         */

        tmp_parm = start_parm;
        end_parm = 1.0;
        dir_parm = (start_parm + 1.0) / 2;
    }

    BSarclen(&bsrc, &status, curve, &tmp_parm,
             &end_parm, &dir_parm, &arc_length);

    /* check to see if there's any room to place text */

    if (distance > arc_length) goto wrapup;

    /* generate points (and their corresponding u-parameters)
     * along the element at a distance equal to the current
     * text width; the first point is the located point
     */

    if (fnt_inf.flags & SIXTEEN_BIT) index_size = 2;
    else index_size = 1;

    uparm = (IGRdouble *) alloca(*text_length* sizeof(IGRdouble));

    /* the math routine BSptsdlcv requires a proximity point to determine
     * the direction in which to generate the new point, so we'll set
     * the proximity point slightly in the positive direction on the curve
     * so the points will be generated from the start point towards the
     * end of the curve
     */

    uparm[0] = start_parm;

    if ((uparm[0] += PARM_OFFSET) > 1.0)
        uparm[0] = 1.0;


    BScveval(curve, uparm[0], 0, proximity_pt, &bsrc);
    begin_parm_index = 0;

    /* allocate space for points along the curve as well as points that
     * are tangent to the points along the curve
     */

    vector_pts = (IGRpoint (*)[2]) alloca(*text_length * sizeof(IGRdouble) * 6);

    /* Now process the text string, calling the esc sequence handler for 
       each sequence until a displayable character is reached.
       Then compute the origins for each string of displayable characters
       unseparated by escape sequences.                              */

    txt_substr_ptr=0;
    chars_processed=0;
    str_index=0;
    num_chars=0; 
    char_index=0;
    mode=1;
    leave=FALSE;

    for (;;)
    {
    /* find and process escape sequences */
    for (;;){
    GRfind_esc_char(&temp_msg,&(text_string[str_index]),
	    (IGRshort)*text_length - str_index,fnt_inf.flags,
	    &num_chars);
    
    if (num_chars) /* reached a displayable character */
    {
       num_chars*=index_size;
       txt_substr_ptr=str_index;
       str_index+=num_chars;
       chars_processed += num_chars;
       if (chars_processed >= *text_length) leave=TRUE;
       char_index+=num_chars;
       break;
    }
    else  /* handle escape sequence */
    {
    /*
     * go process esc sequence, calculating working origin;
     * initializing the structures just_info and unjust extents
     * to take care of UMRs reported by Purify; the values returned
     * are relative to the beginning of the escape sequence that
     * is processed, i.e. the returned values are NOT relative to
     * the beginning of the text string
     */

    just_info.num_lines = 1;
    just_info.just_esc_pos = 0;
    just_info.cur_line_right=0.0;
    just_info.cur_line_left=0.0;
    unjust_extents.right = unjust_extents.left = 0.0;
    unjust_extents.bottom = -(text_attr.height / 
                              (fnt_inf.bodysize - fnt_inf.descent)) *
                               fnt_inf.descent;
    unjust_extents.base = 0.0;
    unjust_extents.top = text_attr.height - unjust_extents.bottom;
    unjust_extents.cap = text_attr.height;

    if (text_string[str_index+1]!='\n') 
        mode=GResc_handler(&temp_msg,text_string,str_index+1,
                  &text_attr,wk_origin,
                  &base_line,&fnt_inf,&prev_font,
		  &cur_disp_attr,&just_info,
		  &unjust_extents,&num_chars); 
    else /* leave, effectively "truncating" the string */
    {
       distance=arc_length+1.0;
       leave=TRUE;
       break;
    }

    if (wk_origin[0]<0.0) wk_origin[0]=0.0;
    str_index+=num_chars+1;
    chars_processed+=num_chars+1;
    distance += (just_info.cur_line_right);
    distance += (just_info.cur_line_left);
    
    if (fnt_inf.flags & SIXTEEN_BIT) index_size = 2;
    else index_size = 1;
    }
    }
    
    if (*num_pts==0) initial_char_height=text_attr.height;

    /* factor to convert char width from FSGetOutlCharInfo to a distance */

    char_size_factor = text_attr.width / (fnt_inf.bodysize - fnt_inf.descent);
    addl_char_spacing = (text_attr.char_spac - 1.0) * text_attr.width;

    for (i = char_index-num_chars; i < char_index; i+=index_size)
    {
        /* save the amount of vertical movement */

        y_displacement[*num_pts]=wk_origin[1];

        /* add a factor so character of different sizes have the same */
        /* baseline when placed on reverse side                       */

        if (*out_flags&GRTX_REV_SIDE) y_displacement[*num_pts]+=text_attr.height-initial_char_height;

        /* want to find the distance from the current position to the
         * middle of the current character
         */

#ifdef BIG_ENDIAN     
        if (fnt_inf.flags & SIXTEEN_BIT) 
        {
           charid =(CharId) text_string[txt_substr_ptr+i-(char_index-num_chars)];
           charid = charid<<8|(CharId) text_string[txt_substr_ptr+i-(char_index-num_chars)+1]; 
        }
        else charid = (CharId) text_string[txt_substr_ptr+i-(char_index-num_chars)];
#else
        if (fnt_inf.flags & SIXTEEN_BIT) swab(&text_string[txt_substr_ptr+i-(char_index-num_chars)],&charid,2);
        else charid = (CharId) text_string[txt_substr_ptr+i-(char_index-num_chars)];
#endif


        if (FSGetOutlCharInfo(fnt_inf.fontid, charid, &charinfo) ==
                                                              FS_NO_ERROR)
        {
            half_char_width = (char_size_factor * charinfo.xMax) / 2;
        }
        else
        {
            half_char_width = text_attr.width / 2;
            charinfo.setWid = fnt_inf.bodysize;
        }

        distance += half_char_width;

        if (distance > arc_length)
        {
            leave=TRUE;
            break;
        }

        BSptsdlcv(&bsrc, curve, &start_parm, proximity_pt, &distance,
                  origin[*num_pts]);
        BSprptoncv(&bsrc, curve, origin[*num_pts], &uparm[*num_pts], &on_curve);

        /* the function BScvarrevt expects the curve parmeters in ascending
         * order; if moving along a closed curve we might go past the end
         * point and the next parmeter would decrease - if this happens,
         * call BScvarrevt to produce the vector points up to the end of
         * the curve, then after this loop exits call BScvarrevt again
         * to get the rest of the vector points (if any)
         */

        if (*num_pts && (uparm[*num_pts] < uparm[*num_pts - 1]))
        {
            BScvarrevt(curve, &uparm[begin_parm_index], 
                       *num_pts-begin_parm_index, 1.0, 
                       vector_pts[begin_parm_index], &bsrc);
            begin_parm_index = *num_pts;
        } 

        /* increment distance past the second half of the character as
         * well as as its white space and any additional character spacing
         */

        distance += (char_size_factor * charinfo.setWid) - half_char_width +
                    addl_char_spacing;
        
        (*num_pts)++;

    }
    if (leave) break;
    } /* end of for(;;) */ 

    if (*num_pts - begin_parm_index)
            BScvarrevt(curve, &uparm[begin_parm_index], 
		       *num_pts-begin_parm_index, 1.0,
                       vector_pts[begin_parm_index], &bsrc);


    /* need to create an orientation matrix for the text; the tangent
     * vector will be the text's x-axis (must first "move" the tangent
     * vector so that it originates from the origin (0,0,0) instead of a
     * point along the curve), the cross product of the view's normal
     * vector and the text's x-axis will be the text's y-axis and the
     * cross product of the text's x and y axes will be the text's z-axis
     */

    for (i = 0; i < *num_pts; i++)
    {
        orient_matrix[i][3] = orient_matrix[i][7] =
        orient_matrix[i][11] = orient_matrix[i][12] =
        orient_matrix[i][13] =
        orient_matrix[i][14] = 0.0;
        orient_matrix[i][15] = 1.0;

        for (j = 0; j < 3; j++)
        {
            orient_matrix[i][j * 4] = vector_pts[i][1][j] -= vector_pts[i][0][j];
        }

        BScrossp(&bsrc, &view_matrix[8], vector_pts[i][1], y_axis);

        orient_matrix[i][1] = y_axis[0];
        orient_matrix[i][5] = y_axis[1];
        orient_matrix[i][9] = y_axis[2];

        /* if the line spacing is not the default (1.0), the origin of the
         * text should be offset from the curve along the text's y-axis the
         * distance indicated by the line spacing - go in the reverse
         * direction of the y-axis if GRTX_REV_SIDE in *out_flags is set;
         * otherwise use the point on the curve
         */

            
        if (text_attr.line_spac != 1.0)
            distance = (text_attr.line_spac - 1.0) * text_attr.height;
        else distance = 0.0;

            if (*out_flags & GRTX_REV_SIDE)
            {
                y_axis[0] = -y_axis[0];
                y_axis[1] = -y_axis[1];
                y_axis[2] = -y_axis[2];
                if (y_displacement[i]!=0.0) distance -= y_displacement[i];
            }
                
            else if (y_displacement[i]!=0.0) distance += y_displacement[i];

            MAptonvc(msg, y_axis, &distance, line_vec);

            origin[i][0] += line_vec[0];
            origin[i][1] += line_vec[1];
            origin[i][2] += line_vec[2];

        BScrossp(&bsrc, vector_pts[i][1], y_axis, z_axis);

        orient_matrix[i][2] = z_axis[0];
        orient_matrix[i][6] = z_axis[1];
        orient_matrix[i][10] = z_axis[2];
    }

wrapup:
 
    if (curve_reversed)
        MAbcrevparm(&bsrc, curve, curve);

    return(value);
}
