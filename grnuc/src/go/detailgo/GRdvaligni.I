/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRnotifylis

Description
    This method is used to define a state within the drawing view alignment
    object so that it will notify the drawing view of any needed changes.

Arguments
    *msg           IGRlong           the return message from the
                                     operation on the graphics object
    *OMmsg         IGRlong           the om return code from the
                                     operation on the graphics object
    *mask          IGRlong           the mask indicating what sort
                                     of operation was performed
    *graphics_msg  OM_S_MESSAGE      the message that was sent to
                                     the graphics object

Return Values
    No value should be returned

Notes
    The listener should use the input arguments for reference only
    and should not alter any value.  The return codes are for
    input only, to notify the listener of the status of the
    operation on the graphics object
\*/

class implementation GRdvalign;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "godef.h"
#include "madef.h"
#include "exmacros.h"

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static IGRint GRis_translation __((IGRmatrix matrix));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe



#define MAETA                    1.0e-12     /* Obtain through numerical */
                                             /* testing                  */

#define  TWO_DIM                 0
#define  TWO_DIM_TRANSLATION     1   
#define  IDENTITY                MAIDMX
#define  SCALED_IDENTITY         3
#define  GENERAL                 4
#define  TRANSLATION             5
#define  SCALED_TRANSLATION      6
#define  THREE_DIM               7

from GRgraphics   import GRxform, GRdisplay;
from GRvg         import GRgetgeom;
from GRnotify     import GRntfyconn;
from GRdrawview   import GRget_drawing_attachment_id;
from GRdvattach   import GRget_drawing_view_id;

method GRnotifylis ( IGRlong *msg;
                     IGRlong *OMmsg;        
                     IGRlong *mask;
                     OM_S_MESSAGE *graphics_msg)
{
    IGRlong           ret_msg;
    IGRint            drawing_view;
    IGRint            i,j;
    struct GRid       dv_id1;
    struct GRid       dv_id2;
    struct GRid       da_id1;
    struct GRid       da_id2;

    switch (*mask) 
    {
    case GR_GEOM_XFORMED:

#if defined(__STDC__) || defined(__cplusplus)
        if (graphics_msg->select.FuncIndex == GRgraphics_OPP_GRxform_method_index)
#else
        if (graphics_msg->select.FuncIndex == GRgraphics$GRxform_method_index)
#endif

        {
            struct GRgraphics_GRxform_Msg *xform_msg;

            /*
             *  Did object one or object two send the message.
             */
            GRget_dv_ids ( OM_Gw_current_OS, 
                           my_id, 
                           &da_id1, 
                           &da_id2, 
                           &dv_id1, 
                           &dv_id2 );

            drawing_view = ((sender_id == da_id1.objid) && (sender_os == da_id1.osnum)) ?
                            drawing_view = DV1_TRANSLATED : DV2_TRANSLATED;
            
            xform_msg = (struct GRgraphics_GRxform_Msg *) graphics_msg->p_arglist;

            if (xform_msg->md_env->md_id.objid != NULL_OBJID) 
            {
                if ((*(xform_msg->matrix_type) != MAIDMX) &&
                      GRis_translation(xform_msg->matrix))
                {
                    me->properties |= drawing_view;
                }
                else if ( (*(xform_msg->matrix_type) != MAIDMX)) 
                {
                    /*
                     *   These types of transformations are not allowed.
                     */
                    om$send ( msg = message GRdvalign.GRdvalign_drop_alignment ( &ret_msg ),  
                              targetid = my_id);
                }
            }
        }
        break;         

    case GR_DISPLAYED:
        if ((me->properties & DV1_TRANSLATED) &&
            (me->properties & DV2_TRANSLATED))
        {
            /*
             *  If both drawing views were translated, the drawing
             *  views should still be aligned.
             */
            me->properties &= (0xffffffff ^ (DV1_TRANSLATED | DV2_TRANSLATED));
        }
        else if ((me->properties & DV1_TRANSLATED) ||
                 (me->properties & DV2_TRANSLATED))
        {
            IGRshort          matrix_type;
            IGRdouble         t;
            IGRpoint          origin1;
            IGRpoint          origin2;
            IGRpoint          point2;
            IGRpoint          prj_point;
            IGRmatrix         matrix;
            struct IGRlbsys   lb;
            struct IGRline    line;
            struct GRid       dv_id;
            struct GRmd_env   mod_env;
            enum GRdpmode     mode;

            GRget_dv_ids ( OM_Gw_current_OS,
                           my_id,
                           &da_id1, 
                           &da_id2, 
                           &dv_id1, 
                           &dv_id2 );

            drawing_view = ((sender_id == da_id1.objid) && (sender_os == da_id1.osnum)) ?
                            DV1_TRANSLATED : DV2_TRANSLATED;

            /*
             *  Only xform the geometry if the display is from the object
             *  that originated the transform.
             */
            if (me->properties & drawing_view) 
            {
                MAidmx (&ret_msg, mod_env.md_env.matrix);
                mod_env.md_env.matrix_type = MAIDMX;
                mod_env.md_id.osnum = OM_Gw_current_OS;
                ex$get_modid ( mod_osnum = OM_Gw_current_OS, 
                               mod_id = &mod_env.md_id.objid );

                /*
                 *  Get the origin of drawing view one.
                 */
                om$send( msg = message GRvg.GRgetgeom( 
                                               &ret_msg, 
                                               &mod_env.md_env.matrix_type, 
                                                mod_env.md_env.matrix, 
                                                (IGRchar *)&lb ),
                         targetid = dv_id1.objid, 
                         targetos = dv_id1.osnum );

                origin1[0] = lb.matrix[3];
                origin1[1] = lb.matrix[7];
                origin1[2] = lb.matrix[11];

                /*
                 *  Get the origin of drawing view two.
                 */
                om$send( msg = message GRvg.GRgetgeom( 
                                              &ret_msg, 
                                              &mod_env.md_env.matrix_type,
                                               mod_env.md_env.matrix,
                                               (IGRchar *)&lb ),
                         targetid = dv_id2.objid, 
                         targetos = dv_id2.osnum );

                origin2[0] = lb.matrix[3];
                origin2[1] = lb.matrix[7];
                origin2[2] = lb.matrix[11];

                if (me->properties & DV1_TRANSLATED) 
                {
                    dv_id = dv_id2;
                    point2[0] = origin1[0] + me->vector[0];
                    point2[1] = origin1[1] + me->vector[1];
                    point2[2] = origin1[2] + me->vector[2];
                    line.point1 = origin1;
                    line.point2 = point2;
                    MAptlnproj (&ret_msg, origin2, &line, prj_point, &t);

                    MAidmx (&ret_msg, matrix);
                    for (i=0, j=3; i < 3; ++i, j += 4) 
                    {
                        if (((prj_point[i] - origin2[i]) > MAETA) ||
                            ((prj_point[i] - origin2[i]) < - MAETA))
                        {
                            matrix[j] = prj_point[i] - origin2[i];
                        }
                    }
                }
                else {
                    dv_id = dv_id1;
                    point2[0] = origin2[0] + me->vector[0];
                    point2[1] = origin2[1] + me->vector[1];
                    point2[2] = origin2[2] + me->vector[2];
                    line.point1 = origin2;
                    line.point2 = point2;
                    MAptlnproj (&ret_msg, origin1, &line, prj_point, &t);
   
                    MAidmx (&ret_msg, matrix);
                    for (i=0,j=3; i < 3; ++i, j +=4) 
                    {
                        if ((prj_point[i] - origin1[i] > MAETA) ||
                            (prj_point[i] - origin1[i] < - MAETA))
                        {
                            matrix[j] = prj_point[i] - origin1[i];
                        }
                    }
                }

                MAtypemx (&ret_msg, matrix, &matrix_type);

                /*
                 *  At this point in the code one knows that a translation
                 *  matrix has been formed.  However, because of a problem
                 *  in the MAtypemx code it will return THREE_DIM type.  If
                 *  a THREE_DIM type was returned then the x and y 
                 *  tranlation was zero.  Check to see if the z translation 
                 *  is greater than a given tolerance if so replace the 
                 *  type with a TRANSLATION and if not replace it with a 
                 *  MAIDMX.  
                 */
                if (matrix_type == THREE_DIM) 
                {
                    matrix_type = ((matrix[11] < MAETA) && (matrix[11] > - MAETA)) ?
                                   MAIDMX : TRANSLATION;
                }

                if (matrix_type != MAIDMX) 
                {
                    me->properties &= (0xffffffff ^ (DV1_TRANSLATED | DV2_TRANSLATED));
                    mode = GRbe;
                    om$send ( msg = message GRgraphics.GRdisplay ( &ret_msg, 
                                                                   &mod_env.md_env.matrix_type, 
                                                                   mod_env.md_env.matrix,
                                                                   &mode,
                                                                   &mod_env.md_id ),
                              targetid = dv_id.objid, 
                              targetos = dv_id.osnum);
   
                    me->properties &= (0xffffffff ^ (DV1_TRANSLATED | DV2_TRANSLATED));
                    om$send ( msg = message GRgraphics.GRxform ( &ret_msg, 
                                                                 &mod_env, 
                                                                 &matrix_type,
                                                                 matrix,
                                                                 &dv_id.objid ),
                              targetid = dv_id.objid, 
                              targetos = dv_id.osnum);

                    me->properties &= (0xffffffff ^ (DV1_TRANSLATED | DV2_TRANSLATED));
                    mode = GRbd;
                    om$send ( msg = message GRgraphics.GRdisplay ( &ret_msg, 
                                                                   &mod_env.md_env.matrix_type, 
                                                                   mod_env.md_env.matrix,
                                                                   &mode, 
                                                                   &mod_env.md_id ),
                              targetid = dv_id.objid, 
                              targetos = dv_id.osnum);
                }

                me->properties &= (0xffffffff ^ (DV1_TRANSLATED | DV2_TRANSLATED));
            }
        }
        break;

    case GR_GEOM_MODIFIED:
    case GR_CLIPPED:
    case GR_DELETED:
        om$send ( msg = message GRdvalign.GRdvalign_drop_alignment ( &ret_msg ),
                  targetid = my_id);
        break;
    }

    return(OM_S_SUCCESS);
}

/*\
Name
    GRdvalign_init

Description
    This method initialize the connections between the two drawing
    views.

Arguments
    *msg        IGRlong        return code
    *dv_id1     struct GRid    drawing view one
    *dv_id2     struct GRid    drawing view two
    vector      IGRpoint       vector defining the alignment of the two
                              drawing views.

Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure
\*/
method GRdvalign_init ( IGRlong *msg; 
                        struct GRid *dv_id1; 
                        struct GRid *dv_id2; 
                        IGRpoint vector)
{
    IGRlong           om_msg;
    IGRint            i;
    IGRint            index;
    OMuint            count;
    OMuint            count1;
    IGRint            connect_flag;
    IGRchar           *buffer;
    IGRboolean        make_tagged;
    OM_S_CHANSELECT   chansel;
    OM_S_CHANSELECT   chansel1;
    struct GRid       my_GRid;
    struct GRid       da_id1;
    struct GRid       da_id2;
    OM_S_OBJECT_LINKAGE  list[2];
    OM_S_OBJECT_LINKAGE  *p_list;

    *msg = MSSUCC;
    connect_flag = TRUE;
    buffer = (IGRchar *)NULL;
    make_tagged = FALSE;
    index = OM_K_MAXINT;
    my_GRid.osnum = OM_Gw_current_OS;
    my_GRid.objid = my_id;
    chansel.type = OM_e_name;
    chansel.u_sel.name = "GRdvalign.to_notify";
    chansel1.type = OM_e_name;
    chansel1.u_sel.name = "GRnotify.notification";

    om$send ( msg = message GRdrawview.GRget_drawing_attachment_id ( msg,
                                                                     &da_id1), 
              targetid = dv_id1->objid, 
              targetos = dv_id1->osnum );

    om$send ( msg = message GRdrawview.GRget_drawing_attachment_id ( msg,
                                                                     &da_id2 ), 
              targetid = dv_id2->objid, 
              targetos = dv_id2->osnum );

    om_msg = om$get_channel_count ( objid = da_id1.objid, 
                                    osnum = da_id1.osnum, 
                                    p_chanselect = &chansel1,
                                    count = &count );

    if ((om_msg & 1) && count) 
    {
        if (buffer = om$malloc (size = sizeof(OM_S_OBJECT_LINKAGE) * count)) 
        {
            om$get_channel_objects ( objid = da_id1.objid, 
                                     osnum = da_id1.osnum,
                                     p_chanselect = &chansel1,
                                     list = (OM_S_OBJECT_LINKAGE *)buffer, 
                                     size = count, 
                                     count = &count );
        }
        else om_msg = OM_E_ABORT;

        if (om_msg & 1) 
        {
            p_list = (OM_S_OBJECT_LINKAGE *)buffer;
            for (i=0; (i < count) && connect_flag; ++i, p_list++) 
            {
                om$get_channel_objects ( objid = p_list->S_objid,
                                         osnum = p_list->osnum, 
                                         p_chanselect = &chansel,
                                         list = list, 
                                         size = 2, 
                                         count = &count1 );

                if ((((list[0].S_objid == da_id1.objid) &&
                      (list[0].osnum == da_id1.osnum)) ||
                     ((list[0].S_objid == da_id2.objid) &&
                      (list[0].osnum == da_id2.osnum))) &&
                    (((list[1].S_objid == da_id1.objid) &&
                      (list[1].osnum == da_id1.osnum)) ||
                     ((list[1].S_objid == da_id2.objid) &&
                      (list[1].osnum == da_id2.osnum))))
                {
                    connect_flag = FALSE;
                }
            }
        }
    }

    if ((om_msg & 1) && connect_flag) 
    {
        me->properties = 0;
        for (i=0; i < 3; ++i) me->vector[i] = vector[i];

        om$send ( msg = message GRnotify.GRntfyconn ( msg, 
                                                      &my_GRid, 
                                                      &chansel, 
                                                      &index, 
                                                      &make_tagged, 
                                                      NULL ), 
                  targetid = da_id1.objid, 
                  targetos = da_id1.osnum);

        om$send ( msg = message GRnotify.GRntfyconn ( msg, 
                                                      &my_GRid, 
                                                      &chansel,
                                                      &index,
                                                      &make_tagged,
                                                      NULL ),
                  targetid = da_id2.objid, 
                  targetos = da_id2.osnum );
    }
    else 
    {
        om$send ( msg = message GRdvalign.GRdvalign_drop_alignment (msg),
                  targetid = my_id );

        *msg = MSFAIL;
    }
   
    if (buffer) om$dealloc (ptr = buffer);

    return (om_msg);
}

/*\
Name
    GRdvalign_pass_msg

Description
    This method passes a message to a drawing view.  The method passes
    the message to the drawing view that did not send the original
    pass message.

Arguments
    *msg        IGRlong        return code
    pass_msg    OM_p_MESSAGE   pass message

Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure
\*/
method GRdvalign_pass_msg (IGRlong *msg; OM_p_MESSAGE pass_msg)
{
    IGRlong           om_msg;
    IGRint            drawing_view1;
    struct GRid       dv_id1;
    struct GRid       dv_id2;
    struct GRid       da_id1;
    struct GRid       da_id2;
    struct GRid       send_id;
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;
    om_msg = OM_S_SUCCESS;

    chansel.type = OM_e_name;
    chansel.u_sel.name = "GRnotify.notification";

    GRget_dv_ids ( OM_Gw_current_OS, 
                   my_id, 
                   &da_id1, 
                   &da_id2, 
                   &dv_id1, 
                   &dv_id2 );

    /*
     *  Did object one or object two send the message.
     */
    drawing_view1 = ((sender_id == da_id1.objid) && (sender_os == da_id1.osnum)) ?
                     TRUE : FALSE;

    if (drawing_view1) 
    {
        if (!(me->properties & DV2_PASSED)) 
        {
            if (!(me->properties & DV1_PASSED)) 
            {
                me->properties |= DV1_PASSED;
                send_id.osnum = sender_os;
                send_id.objid = sender_id;
                om$send ( msg = message GRdvalign.GRdvalign_mark ( msg, 
                                                                   &send_id ), 
                          senderid = sender_id, 
                          targetos = sender_os,
                          p_chanselect = &chansel );
            }

            om_msg = om$send ( msg = pass_msg, 
                               senderid = sender_id,
                               targetos = dv_id2.osnum, 
                               targetid = dv_id2.objid );

            me->properties &= (0xffffffff ^ (DV1_PASSED | DV2_PASSED));
        }
        else if ((me->properties & (DV1_PASSED | DV2_PASSED)) == 
                 (DV1_PASSED | DV2_PASSED))
        {
            me->properties &= (0xffffffff ^ (DV1_PASSED | DV2_PASSED));
        }
        else me->properties |= DV1_PASSED;
    }
    else 
    {
        if (!(me->properties & DV1_PASSED)) 
        {
            if (!(me->properties & DV2_PASSED)) 
            {
                me->properties |= DV2_PASSED;
                send_id.osnum = sender_os;
                send_id.objid = sender_id;
                om$send ( msg = message GRdvalign.GRdvalign_mark ( msg, 
                                                                   &send_id ), 
                          senderid = sender_id, 
                          targetos = sender_os,
                          p_chanselect = &chansel);
            }

            om_msg = om$send ( msg = pass_msg, 
                               senderid = sender_id,
                               targetos = dv_id1.osnum, 
                               targetid = dv_id1.objid );

            me->properties &= (0xffffffff ^ (DV1_PASSED | DV2_PASSED));
        }
        else if ((me->properties & (DV1_PASSED | DV2_PASSED)) == 
                 (DV1_PASSED | DV2_PASSED))
        {
            me->properties &= (0xffffffff ^ (DV1_PASSED | DV2_PASSED));
        }
        else me->properties |= DV2_PASSED;
    } 

    return(om_msg);
}

/*\
Name
    GRdvalign_mark

Description
    This method marks a drawing view alignment object so that only
    messages from the given drawing view will be passed.

Arguments
    *msg        IGRlong        o   return code
    *da_id      struct GRid    i   drawing attachment id

Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure
\*/
method GRdvalign_mark (IGRlong *msg; struct GRid *da_id)
{
    IGRlong           om_msg;
    struct GRid       da_id1;
    struct GRid       da_id2;

    *msg = MSSUCC;
    om_msg = OM_S_SUCCESS;
    GRget_dv_ids(OM_Gw_current_OS, my_id, &da_id1, &da_id2, NULL, NULL);

    /*
     *  Did object one or object two send the message.
     */
    if ((da_id->objid == da_id1.objid) && (da_id->osnum == da_id1.osnum)) 
    {
        if (!(me->properties & DV2_PASSED)) me->properties |= DV1_PASSED;
    }
    else if ((da_id->objid == da_id2.objid) && 
             (da_id->osnum == da_id2.osnum))
    {
        if (!(me->properties & DV1_PASSED)) me->properties |= DV2_PASSED;
    }

    return(om_msg);
}

/*\
Name
    GRdvalign_drop_alignment
 
Description
    This method drops the drawing view alignment.

Arguments
    *msg        IGRlong        return code

Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure
\*/
method GRdvalign_drop_alignment (IGRlong *msg)
{
    IGRlong  om_msg;

    *msg = MSSUCC;
    om_msg = om$send ( msg = message Root.delete (FALSE),
                       targetid = my_id);
    return(om_msg);
}

/*\
Name
    GRis_translation

Description
    This function determines whether this matrix is a translaton matrix
    or not.

    matrix      IGRmatrix         Matrix to check

Return Values
    0  - is not a translation
    1  - is a translation
\*/
static IGRint GRis_translation (matrix)
    IGRmatrix   matrix;
{
    IGRint   value;

    value = FALSE;
 
    if ( (matrix[0]   == 1.0) &&
         (matrix[5]   == 1.0) &&
         (matrix[10]  == 1.0) &&
         (matrix[15]  == 1.0) &&
         (matrix[1]   == 0.0) &&
         (matrix[2]   == 0.0) &&
         (matrix[4]   == 0.0) &&
         (matrix[6]   == 0.0) &&
         (matrix[8]   == 0.0) &&
         (matrix[9]   == 0.0) &&
         (matrix[12]  == 0.0) &&
         (matrix[13]  == 0.0) &&
         (matrix[14]  == 0.0))
    {
        if ((matrix[3] != 0.0) ||
            (matrix[7] != 0.0) ||
            (matrix[11] != 0.0))
        {
            value = TRUE;
        }
    }

    return (value);
}

IGRint  GRget_dv_ids (osnum, objid, da_id1, da_id2, dv_id1, dv_id2)
    GRspacenum        osnum;
    GRobjid           objid;
    struct GRid       *da_id1;
    struct GRid       *da_id2;
    struct GRid       *dv_id1;
    struct GRid       *dv_id2;
{
    IGRlong           ret_msg;
    OM_S_CHANSELECT   chansel;

    chansel.type = OM_e_name;
    chansel.u_sel.name = "GRdvalign.to_notify";

    /*
     *  Get the object at index 0.
     */
    om$get_objid_at_index ( objid = objid, 
                            osnum = osnum,
                            p_chanselect = &chansel, 
                            index = 0, 
                            objidaddr = &da_id1->objid,
                            osnumaddr = &da_id1->osnum );

    if (dv_id1) 
    {
        om$send ( msg = message GRdvattach.GRget_drawing_view_id ( &ret_msg,
                                                                   dv_id1), 
                  senderid = NULL_OBJID,
                  targetid = da_id1->objid, 
                  targetos = da_id1->osnum);
    }

    /*
     *  Get the object at index 1.
     */
    om$get_objid_at_index ( objid = objid, 
                            osnum = osnum, 
                            p_chanselect = &chansel, 
                            index = 1, 
                            objidaddr = &da_id2->objid,
                            osnumaddr = &da_id2->osnum );

    if (dv_id2) 
    {
        om$send ( msg = message GRdvattach.GRget_drawing_view_id ( &ret_msg,
                                                                   dv_id2), 
                  senderid = NULL_OBJID,
                  targetid = da_id2->objid, 
                  targetos = da_id2->osnum );
    }

    return(1);
}

end implementation GRdvalign;
