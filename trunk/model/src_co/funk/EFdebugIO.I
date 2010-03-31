/* ###################   APOGEE COMPILED   ################## */
class implementation GRbcsubbc;

/*
DESCRIPTION

EFfreadGeom, EFfprintGeom -- read and write geometry

NOTE

Instances of subclasses of GRowner are not written.

HISTORY

 11/03/93   GMK If the geometry has the SKgeometry ancestry, change the SK classname to
 		equivalent GR classname. TR#119222606

6/26/90     DLB added indef IDRAW

25 Sep 1989 rlw Removed kluge of jBk.  Modified write operation to support
                sets, output surface boundaries, and to flush buffer after
                writing.
19 May 1989 jBk Enhanced to use kluge to avoid reparameterization
                of a surface when its data are posted.
                Fixed to free dynamic memory allocated for
                reading curves and surfaces.
01 May 1989 jBk Genesis.

Sudha   06/02/93        modified to include for BSprototype headers
*/

# include "EMS.h"           /* for shared libraries */
# include <stdio.h>         /* FILE */
# include "EMStypedef.h"    /* EMSrc */
# include "EMSlogic.h"      /* EMSokay NULL IS */
# include "EMSmsgdef.h"     /* EMS_E_Fail, etc. */
#include "bswrbssfwhx.h"
#include "bswrbscvwhx.h"
#include "bsrdbssfwhx.h"
#include "bsrdbscvwhx.h"


#ifndef IDRAW
from EMSsubbs import EMget_boundaries;
#endif

EMSrc EFfprintGeom (
    msg,
    fp,
    osnum,
    objid,
    p_env,
    write_hex
)
EMSrc *msg;
FILE *fp;
OMuword osnum;
OM_S_OBJID objid;
struct GRmd_env *p_env;
IGRboolean write_hex;
{
 extern		OMuword OPP_GRbspline_class_id;
 extern		OMuword OPP_SKgeometry_class_id;
#ifndef IDRAW
 extern         OMuword OPP_EMSsubbs_class_id;
#endif
 IGRlong	number_of_objects, i, sts;
 struct		GRlc_info *objects;
 extern		SKgetgrclass();
/*
 * Initialize
 */
 *msg = EMS_S_Success;
 number_of_objects = 0;
 objects = NULL;
/*
 * Break down the input object into a list of objects
 */
 {
  extern		IGRlong EMselective_fence();
  OMuword		classes_we_want[2];
  struct		GRlc_info set_object;
  OM_S_CLASSLIST	yes_classes, no_classes;

#ifndef IDRAW
  yes_classes.w_count = 2;
#else
  yes_classes.w_count = 1;
#endif
  yes_classes.p_classes = classes_we_want;
  classes_we_want[0] = OPP_GRbspline_class_id;
#ifndef IDRAW
  classes_we_want[1] = OPP_EMSsubbs_class_id;
#endif
  no_classes.w_count = 0;
  set_object.located_obj.objid = objid;
  set_object.located_obj.osnum = osnum;
  set_object.module_info = *p_env;
  sts = EMselective_fence(
    &yes_classes,
    &no_classes,
    &set_object,
    TRUE,			/* break_down_composites */
    TRUE,			/* is_operation_readonly */
    NULL_OBJID,			/* my_stupid_id */
    &number_of_objects,
    &objects,
    msg);
   if ((! (1 & sts)) || (number_of_objects == 0)) goto wrapup;
 }
/*
 * Process all of the elements which were found
 */
 for (i = 0; i < number_of_objects; i++)
  {
   OMuword	classid;
   IGRchar	*geometry, classname[OM_K_MAXCLASS_LEN + 1];
   IGRboolean	is_curve;
/*
 * Write the classname of the object into the
 * data file.
 */
   sts = om$get_classid(
     objid = objects[i].located_obj.objid,
     osnum = objects[i].located_obj.osnum,
     p_classid = &classid);
    if (! (1 & sts))
     {
      *msg = EMS_E_OMerror;
      goto wrapup;
     }
  /*
   * check for SKgeometry ancestry. 
   * If the class has SKgeometry ancestry, change the SKclassname to equivalent GRclassname
   * TR # 119222606 - GMK
   */
  if (om$is_ancestry_valid (subclassid = classid, 
       superclassid = OPP_SKgeometry_class_id) == OM_S_SUCCESS)
  {
    sts = SKgetgrclass( classid, NULL, classname );
    if ( ! (1 & sts) )
    {
      *msg = EMS_E_OMerror;
      goto wrapup;
    }
  }
  else
  {
   sts = om$get_classname(
     classid = classid,
     classname = classname);
    if (! (1 & sts))
     {
      *msg = EMS_E_OMerror;
      goto wrapup;
     }
  }
  fprintf(
   fp,
   "%s\n",
   classname);
/*
 * Determine if the given element is a curve
 * or surface
 */
   sts = om$is_ancestry_valid(
     superclassid = OPP_GRbspline_class_id,
     subclassid = classid);
   if (sts == OM_S_SUCCESS)
    is_curve = TRUE;
   else if (sts == OM_I_INVANCESTRY)
    {
#ifndef IDRAW
     sts = om$is_ancestry_valid(
       superclassid = OPP_EMSsubbs_class_id,
       subclassid = classid);
     if (sts == OM_S_SUCCESS)
      is_curve = FALSE;
     else
      {
       *msg = EMS_E_OMerror;
       goto wrapup;
      }
#endif
    } /* else if (sts == OM_I_INVANCESTRY) */
   else
    {
     *msg = EMS_E_OMerror;
     goto wrapup;
    }
/*
 * Get the required geometry and dump it to the
 * file in the correct format.
 */
   {
    struct	GRlc_info *loc_info;
    struct	GRid *id;
    struct	GRmdenv_info *mdenv_info;

    loc_info = &objects[i];
    id = &loc_info->located_obj;
    mdenv_info = &loc_info->module_info.md_env;
    sts = om$send(
      msg = message GRvg.GRgenabsg(
       (IGRlong *)msg,
       &mdenv_info->matrix_type,
       mdenv_info->matrix,
       &geometry),
      senderid = NULL_OBJID,
      targetid = id->objid,
      targetos = id->osnum);
     if ((! (1 & sts)) ||
         (! (1 & *msg)))
      {
       *msg = EMS_E_Fail;
       goto wrapup;
      }
/*
 * Dump the curve.
 */
    if (is_curve)
     {
      struct	IGRbsp_curve *curve;

      curve =  (struct IGRbsp_curve *) geometry;
      BSwrbscvwhx(
       fp,
       "",
       curve,
       FALSE,
       write_hex);
     } /* if (is_curve) */
/*
 * Get the boundaries if the element is a surface and
 * then dump the surface.
 */
#ifndef IDRAW
    else
     {
      struct	IGRbsp_surface *surface;

      surface =  (struct IGRbsp_surface *) geometry;
      sts = om$send(
        msg = message EMSsubbs.EMget_boundaries(
         (IGRlong *)msg,
         &mdenv_info->matrix_type,
         mdenv_info->matrix,
         &surface->on_off, 
         &surface->num_boundaries,
         &surface->bdrys),
        senderid = NULL_OBJID,
        targetid = id->objid,
        targetos = id->osnum);
       if ((! (1 & sts)) ||
           (! (1 & *msg)))
        {
         *msg = EMS_E_Fail;
         goto wrapup;
        }
      BSwrbssfwhx(
       fp,
       "",
       surface,
       FALSE,
       write_hex);
      if (surface->num_boundaries &&
          surface->bdrys)
       {
        IGRlong      j;

        for(j = 0; j < surface->num_boundaries; j++)
         {
          free(surface->bdrys[j].points);
         }
         free(surface->bdrys);
        surface->num_boundaries = 0;
        surface->bdrys = NULL;
       } /* if (surface->num_boundaries && surface->bdrys) */
     } /* ELSE FOR if (is_curve) */
#endif
   } /* Get the required geometry */
  } /* for (i = 0; i < number_of_objects; i++) */
/*
 * Flush the buffer
 */
 fflush(fp);
/*
 * Eof
 */
wrapup:
 if (number_of_objects && objects) free(objects);
 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
} /* end EFfprintGeom */




/*
 * HISTORY:

    ?? : who knows when. There were a few cobwebs, so must have been
         a while ago                                            : Original.

   Janaka : 05/05/93 : This function is supposed to read only those ASCII files
                       writen by debug out.  It was core dumping on reading EMS
                       files.  Changed the input reading function from fscanf 
                       to fgets (thus specifying the number of bytes to be read
                       so that the buffer 'string' would not be over written).
                       Also made some other checks in case of invalid file
                       input.
 */


EMSrc EFfreadGeom (
    fp,
    osnum,
    p_objid,
    p_list,
    p_mode,
    use_classname,
    tryhex
)
FILE *fp;
OMuword osnum;
OM_S_OBJID *p_objid;
struct GRvg_construct *p_list;
enum GRdpmode *p_mode;
IGRboolean use_classname;
IGRboolean tryhex;
{
    IGRchar twostrings[2][BUFSIZ];
    IGRchar *classname = twostrings[0], *string = twostrings[1];
    IGRboolean found = FALSE, is_curve = FALSE;
    IGRint num_lines_read;
    OMuword classid;
    extern OMuword OPP_GRbcsubbc_class_id;
#ifndef IDRAW
    extern OMuword OPP_EMSgenbs_class_id;
    struct IGRbsp_surface surface;
#endif
    EMSrc omrc = OM_S_SUCCESS;
    struct IGRbsp_curve curve;

    *p_list->msg = EMS_S_Success;
    *p_objid = NULL_OBJID;

    classname[0] = '\0';


    /* In the following, the data format expected is:
     *    . If a class name is present, then it MUST be on the first line.
     *      The next line MUST be either BScurve or BSsurface.  Note that
     *      the class name is optional, where as the geometry indicator is not.
     */

    for( num_lines_read = 0; EMSokay( *p_list->msg) && ( NOT (feof (fp) OR 
                 found) ); )
    {
        if( fgets( string, BUFSIZ, fp ) )
        {
            num_lines_read++;

            /* fgets() includes the end of line */
 
            if (strcmp (string, "BScurve\n"))
            {
                if (strcmp (string, "BSsurface\n"))
                {
                    char *temp;

                    /* The following avoids reading a large file, that is not
                     * complient with the expected data format, until its end
                     * is reached.
                     */

/*
 * Commented the following as this assumes that the first line of the debug
 * out file is going to be a classname. This is not true for Dieter.
 * pp 08/19/93
                       if( num_lines_read != 1 )
                       {
                         *p_list->msg = EMS_E_Fail;
                         break;
                       }
*/

                    temp = classname;
                    classname = string;
                    string = temp;
                }
                else
                {
#ifndef IDRAW
                    found = TRUE;
#else
                    found = FALSE;
#endif        
                }
            }
            else
            {
                found = TRUE;
                is_curve = TRUE;
            }
        }
    }

    if (EMSokay (*p_list->msg) AND found)
    {
        /* determine class and read element */

        IGRboolean read = FALSE;

        if (use_classname)
        {

/*
 * Since classname includes \n, we have to strip the same before we
 * do the following.
 * pp 08/18/93
 */
            EMSrc gcomrc;
            int len;
            len = strlen(classname);

            classname[len-1]='\0';

            gcomrc = om$get_classid (
                classname = classname,
                p_classid = &classid
            );

            if (EMSerror (gcomrc))
            {
                if (is_curve)
                    classid = OPP_GRbcsubbc_class_id;
#ifndef IDRAW
                else
                    classid = OPP_EMSgenbs_class_id;
#endif
            }
        }
        else /* NOT use_classname */
        {
            if (is_curve)
                classid = OPP_GRbcsubbc_class_id;
#ifndef IDRAW
            else
                classid = OPP_EMSgenbs_class_id;
#endif
        }

        if (is_curve)
        {

            curve.poles = NULL;
            curve.knots = NULL;
            curve.weights = NULL;
            curve.bdrys = NULL;
            read = BSrdbscvwhx (fp, &curve, tryhex);
            p_list->geometry = (IGRchar *) &curve;
        }
#ifndef IDRAW
        else /* is surface */
        {

            surface.poles = NULL;
            surface.u_knots = NULL;
            surface.v_knots = NULL;
            surface.weights = NULL;
            surface.bdrys = NULL;
            read = BSrdbssfwhx (fp, &surface, tryhex);
            p_list->geometry = (IGRchar *) &surface;

        }
#endif

        if (NOT read) *p_list->msg = EMS_E_Fail;

    } /* determine class and read element */

    if (EMSokay (omrc) AND EMSokay (*p_list->msg) AND found)
    {
        /* construct */

        omrc = om$construct (
            classid = classid,
            p_objid = p_objid,
            osnum = osnum,
            msg = message GRgraphics.GRconstruct (p_list)
        );

        if (is_curve) /* free memory allocated for curve data */
        {
            if (curve.poles) om$dealloc (ptr = curve.poles);
            if (curve.knots) om$dealloc (ptr = curve.knots);
            if (curve.weights) om$dealloc (ptr = curve.weights);
            if (curve.bdrys) om$dealloc (ptr = curve.bdrys);
        }
#ifndef IDRAW
        else /* free memory allocated for surface data */
        {
            if (surface.poles) om$dealloc (ptr = surface.poles);
            if (surface.u_knots) om$dealloc (ptr = surface.u_knots);
            if (surface.v_knots) om$dealloc (ptr = surface.v_knots);
            if (surface.weights) om$dealloc (ptr = surface.weights);

            if (surface.bdrys) 
            {
                IGRlong ii;

                for (ii = 0; ii < surface.num_boundaries; ii++)
                {
                    if (surface.bdrys[ii].points)
                    {
                        om$dealloc (ptr = surface.bdrys[ii].points);
                    }
                }

                om$dealloc (ptr = surface.bdrys);
            }

        } /* else free memory allocated for surface data */
#endif

    } /* fi construct */

    if (EMSokay (omrc) AND EMSokay (*p_list->msg) AND found AND p_mode)
    {
        omrc = om$send (
            msg = message GRgraphics.GRdisplay (
                p_list->msg,
                &p_list->env_info->md_env.matrix_type,
                p_list->env_info->md_env.matrix,
                p_mode,
                &p_list->env_info->md_id
            ),
            senderid = NULL_OBJID,
            targetid = *p_objid,
            targetos = osnum
        );
    }

    if (EMSerror (omrc) OR EMSerror (*p_list->msg))
    {
        if (EMSokay (omrc)) omrc = OM_E_ABORT;
        if (EMSokay (*p_list->msg)) *p_list->msg = EMS_E_Fail;
    }

    return omrc;

} /* EFfreadGeom */

end implementation GRbcsubbc;
