/* ###################   APOGEE COMPILED   ################## */
class implementation EMShorizon;

#include "OMmacros.h"

/*
History

    10 Jul 90   AIC     Creation Date
    03 Oct 90   AIC     Added support for "best hit" display.
    11 Nov 90   AIC     Removed "best hit" display, added edge-based
                        rule lines.
    26 Nov 90   AIC     Support horizon edge display on/off switch.
    01 May 91   Jack    Modified for 2.0.1 Horizon Loops.
    13 Aug 91   Jack    Added struct GRid *obj parm.  If specified,
                        returns back my_GRid. 
    17 Sep 91   Jack    Added struct GRmdenv_info *mdenv_info parm.
                        Also added code to get z_vector from reference
                        plane.
*/


from EMSdatpln  import EMget_pln_info;

method EMcheck_orientation(double               vector[3];
                           struct GRmdenv_info *mdenv_info;
                           int                 *match;
                           double              *result;
                           struct GRid         *obj)
{
  IGRlong   sts,
            EMmsg;
  double    r;
  OM_S_CHANSELECT father;
  struct GRmd_env md_env;
  IGRdouble z_vector[3];
  struct GRid     ref_pln_id;
      
  md_env.md_id.osnum = 0;
  md_env.md_id.osnum = 0;  
  md_env.md_env.matrix_type = mdenv_info->matrix_type;
  OM_BLOCK_MOVE(mdenv_info->matrix,md_env.md_env.matrix,(16* sizeof(IGRdouble)));
  
  sts = EMmake_chanselect( NDfather_father, &father );
  if(! (1 & sts)) goto wrapup;

  /* Get the GRid of the reference plane.  It will always be the
     first object on the father channel.
   */
  om$get_objid_at_index( object = me,
                         p_chanselect = &father,
                         index = 0,
                         objidaddr = &ref_pln_id.objid,
                         osnumaddr = &ref_pln_id.osnum );



   /* get the z_vector from the reference plane connected to my father channel*/
  sts = om$send(msg = message EMSdatpln.EMget_pln_info
                           (&EMmsg,
                             NULL,
                            &md_env, 
                             NULL,
                             NULL,
                             z_vector,
                             NULL,
                             NULL), 
                senderid = my_id,
                targetid = ref_pln_id.objid,
                targetos = ref_pln_id.osnum );                  
  if(! (1 & sts & EMmsg)) goto wrapup;



  if(*match = EMcompare_vectors(z_vector, vector, &r))
  {
    if(obj)
    {
      obj->objid = my_id;
      obj->osnum = OM_Gw_current_OS;
    }

    if(result) *result = r;

    sts = OM_I_STOP_SENDING;
  }
  else
  {
    if(result) if (r < *result) *result = r;
    sts = OM_S_SUCCESS;
  }

wrapup:
  return sts;
};

end implementation EMShorizon;
