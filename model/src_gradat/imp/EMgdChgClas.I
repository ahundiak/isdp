/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS error codes  */
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"      /* EMSmsgReport     */
# endif

# ifndef EMStypedef_include
# include "EMStypedef.h"    /* EMSmsgReport     */
# endif

# ifndef EMScmacros_include
# include "EMScmacros.h"    /* EMSmsgReport     */
# endif

# include "emsdef.h"

# define MAX_NUM_OBJS   2

method EMchangeClass(IGRlong *EMmsg; OMuword new_classid;
                     OM_p_MESSAGE messg; GRobjid *newobjid)
{
  IGRlong   sts;
  GRobjid   surface_id, Ploop_id;
  OMuword   my_classid;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /*
   * Check the class id
   */
  sts = om$is_ancestry_valid(subclassid = new_classid,
                             superclassid = OPP_EMSgradata_class_id);
  if(sts IS OM_I_INVANCESTRY) *EMmsg = EMS_E_InvalidArg;
  if(! (1 & sts)) goto wrapup;

  /*
   * Make shure I am changing class
   */
  sts = om$get_classid(object = me, p_classid = &my_classid);
  if(! (1 & sts)) goto wrapup;
  if(my_classid ISNT new_classid)
  {
    OM_S_CHANSELECT 	 to_requesters;
    OMuword		 dum_os;

    /*
     * Find out who the surface and Ploop are.
     */
    sts = EMmake_chanselect (EMShelper_to_requesters, &to_requesters);
    if(! (1 & sts)) goto wrapup;

    sts = om$get_objid_at_index(object = me, p_chanselect = &to_requesters,
                          index = 0, objidaddr = &surface_id,
			  osnumaddr = &dum_os);
    if (sts == OM_E_INVINDEX) 
    {
	sts = OM_S_SUCCESS;
        surface_id = NULL_OBJID; 
    }
    if(! (1 & sts)) goto wrapup;

    sts = om$get_objid_at_index(object = me, p_chanselect = &to_requesters,
                          index = 1, objidaddr = &Ploop_id,
			  osnumaddr = &dum_os);
    if (sts == OM_E_INVINDEX) 
    {
	sts = OM_S_SUCCESS;
        Ploop_id = NULL_OBJID; 
    }
    if(! (1 & sts)) goto wrapup;


    /*
     * Construct the new class
     */

    sts = om$construct(classid = new_classid, p_objid = newobjid,
                       msg = message EMSgradata.EMinit(EMmsg, surface_id,
                       Ploop_id));
    if(! (1 & *EMmsg & sts)) goto wrapup;

    /*
     * Delete me
     */
    sts = om$send(msg = message Root.delete(1), targetid = my_id);

  } /* my class id isnt new class id */
  else *newobjid = my_id;

  /*
   * Send the input message to the new object
   */
  if((messg->select.DefClassid != OM_GS_NULL_MESSAGE.select.DefClassid) ||
     (messg->select.ReqClassid != OM_GS_NULL_MESSAGE.select.ReqClassid) ||
     (messg->select.FuncIndex != OM_GS_NULL_MESSAGE.select.FuncIndex) ||
     (messg->size != OM_GS_NULL_MESSAGE.size))
  {
    sts = om$send(msg = messg, targetid = *newobjid);
    if(! (1 & sts))
    {
      *EMmsg = EMS_E_Fail;
      sts = om$send(msg = message Root.delete(1), targetid = *newobjid);
      goto wrapup;
    }
  }

wrapup:
  EMSmsgReport(sts, "EMSgradata.EMchangeClass", FALSE);
  if EMSmsgReport(*EMmsg, "EMSgradata.EMchangeClass", FALSE) sts = OM_E_ABORT;
  return(sts);
}

end implementation EMSgradata;
