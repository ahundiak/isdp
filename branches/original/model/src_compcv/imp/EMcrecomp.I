class implementation GRcompcurve;

/*

Name
  EMcreate_composite_curve

Abstract
  This routine accepts a group of points and constructs a composite
  curve object containing line segments going from point to point in
  the order they are input.  Real world connect-the_dots.  See the 
  Notes about the close_it option.

Synopsis
  So I'm sitting here wondering why I have to do so much stuff
  just to construct a composite curve from some points.  I 
  thought for sure someone would have written a nice little
  function to do such a thing, but alas, that has not happened...
  until now.

Description
  

Return Value
       EMmsg   --  EMS_E_Success => No problem
               --  EMS_E_Fail    => Something went wrong

Notes
   IGRboolean  close_it 
        TRUE:  I will create a line segment from the last point 
               to the first point and the resulting composite
               curve will be closed.
        FALSE: I will not create a line segment from the last
               point to the first and the resulting composite
               curve will be open.      


Index

Keywords
  composite,construct,create,curve,function

History
  07/16/93 : Jack : created

 */


#include "OMtypes.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "emserr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "alloca.h"

extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GRcompcurve_class_id;

#argsused
IGRlong EMcreate_composite_curve( EMmsg,
                                  mdenv,
                                  num_points,
                                  points,
                                  close_it,
                                  osnum,
                                  comp_cv_obj )

IGRlong     *EMmsg;       /* O - Return code */
struct GRmd_env *mdenv;   /* I - module environment */
IGRint       num_points;  /* I - number of points in the composite */
IGRpoint    *points;      /* I - array of points to make each segment */
IGRboolean   close_it;    /* I - TRUE: create a closed composite curve,
                                 FALSE: leave the composite curve open */
GRspacenum   osnum;       /* I - object space where the composite curve
                                 will get constructed */
struct GRid *comp_cv_obj; /* O - resulting composite curve */



{
IGRlong               status  = MSSUCC, rc;
IGRboolean            bool_st = TRUE;
struct IGRbsp_curve  *work_cv=NULL;
IGRint                ii=0;
GRobjid               line_id = NULL_OBJID;
struct GRvg_construct const_list;
struct IGResbc        esbc;
IGRlong               bytes_in = 0,
                      bytes_out = 0;
struct IGRdisplay     act_display;
struct GRlc_info     *loc_info = NULL;
IGRlong               rotten_one = 0;

extern void BSalloccv();
extern IGRboolean MA2pttobc();

/*
 * initialize
 */
*EMmsg = EMS_S_Success;
comp_cv_obj->objid = NULL_OBJID;
comp_cv_obj->osnum = osnum;

/*
 * allocate a list of object ids for the line segments
 */
if(close_it)
   loc_info  = (struct GRlc_info *) alloca(num_points * sizeof(struct GRlc_info));
else
   loc_info  = (struct GRlc_info *) alloca((num_points - 1) * sizeof(struct GRlc_info));



/*
 * determine the linesegments
 */
BSalloccv(2,     /* order */
          2,     /* num_poles */
          FALSE, /* rational */
          0,     /* num_boundaries */
         &work_cv, 
         &status);
if(status != 0)
 {
  *EMmsg = EMS_E_Fail;
  goto wrapup;
 }


/*
 * fill out construct list
 */

bytes_in = sizeof(IGRshort);
gr$get_active_layer(msg = EMmsg,
                    sizbuf = &bytes_in,
                    buffer = &const_list.level,
                    nret = &bytes_out);
if(!(*EMmsg & 1))
 {
  status = MSFAIL;
  goto wrapup;   
 }


bytes_in = sizeof(struct IGRdisplay);
gr$get_active_display(msg = EMmsg,
                    sizbuf = &bytes_in,
                    buffer = &act_display,
                    nret = &bytes_out);
if(!(*EMmsg & 1))
 {
  status = MSFAIL;
  goto wrapup;   
 }

const_list.display = &act_display;

const_list.geometry = (IGRchar *) work_cv;
const_list.msg = EMmsg;
const_list.env_info = mdenv;
const_list.newflag = FALSE;
const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
esbc.is_polydis = FALSE;
esbc.is_curvedis = TRUE;
const_list.class_attr = (IGRchar *) &esbc;
const_list.name = NULL;


            
for ( ii=0; ii < (num_points - 1); ii++)
 {
  bool_st = MA2pttobc(EMmsg,
                      points[ii],
                      points[ii+1],
                      work_cv);
  if(!bool_st)
   {
    *EMmsg = EMS_E_Fail;
     goto wrapup;
   }


  status = om$construct (classid = OPP_GR3dlineseg_class_id,
             msg = message GRgraphics.GRconstruct (&const_list), 
             osnum = osnum, p_objid = &line_id);
  if(!(status & 1))
   {
    *EMmsg = EMS_E_Fail;
     goto wrapup;
   }

  loc_info[ii].module_info = *mdenv;
  loc_info[ii].located_obj.osnum = osnum;
  loc_info[ii].located_obj.objid = line_id;
    
 }


/*
 * if close_it is TRUE, construct a segment from the last point
 * to the first and close the composite.
 */
if(close_it)
 {
  bool_st = MA2pttobc(EMmsg,
                      points[num_points-1],
                      points[0],
                      work_cv);
  if(!bool_st)
   {
    *EMmsg = EMS_E_Fail;
     goto wrapup;
   }

  status = om$construct (classid = OPP_GR3dlineseg_class_id,
               msg = message GRgraphics.GRconstruct (&const_list), 
               osnum = osnum, p_objid = &line_id);
  if(!(status & 1))
   {
    *EMmsg = EMS_E_Fail;
     goto wrapup;
   }

  loc_info[num_points - 1].module_info = *mdenv;
  loc_info[num_points - 1].located_obj.osnum = osnum;
  loc_info[num_points - 1].located_obj.objid = line_id;

 }

                    
/*
 * create a composite curve from the list of linesegments
 */

const_list.geometry = NULL; /* the geometry will get filled out by EMmakecomp */

status = om$construct (classid = OPP_GRcompcurve_class_id,
               msg = message GRgraphics.GRconstruct (&const_list), 
               osnum = osnum, p_objid = &(comp_cv_obj->objid));
if(!(status & 1))
  {
   *EMmsg = EMS_E_Fail;
    goto wrapup;
  }


status = om$send ( msg = message GRcompcurve.EMmakecomp( 
                                     EMmsg,
                                     mdenv,
                                     (close_it) ? num_points : (num_points - 1),
                                     loc_info,
                                    &rotten_one),
          senderid = NULL_OBJID,
          targetos = comp_cv_obj->osnum , 
          targetid = comp_cv_obj->objid );
if(!(status & *EMmsg & 1))
  goto wrapup;

    
wrapup:

 if ( work_cv ) {
   BSfreecv(&rc, work_cv);
   work_cv = NULL;
 }

 return( status );
}
end implementation GRcompcurve;
