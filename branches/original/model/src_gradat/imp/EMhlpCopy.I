/* ###################   APOGEE COMPILED   ################## */
class implementation EMShelper;

#include "EMS.h"
# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"         /* EMS error codes  */
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"          /* EMSmsgReport     */
# endif

# ifndef EMStypedef_include
# include "EMStypedef.h"        /* EMSmsgReport     */
# endif

# ifndef EMScmacros_include
# include "EMScmacros.h"        /* EMSmsgReport     */
# endif

# include "emsdef.h"

extern OMuword  OPP_EMSsubbs_class_id;
extern OMuword  OPP_EMSloop_class_id;

method EMhelperCopy(IGRlong *EMmsg; struct GRid *sender_copy;
                    struct EMcp_info *copy_info)
{
  IGRlong           sts = OM_S_SUCCESS;
  IGRboolean        copy_exists;
  GRobjid           copy;

  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;
  copy = NULL_OBJID;

  /*
   * Make shure I am copied
   */
  EMcpsearch(EMmsg, my_id, &copy, copy_info, 0, &copy_exists);

  if(! copy_exists)
  {
    /*
     * Copy me
     */
    sts = om$construct_and_copy(object = me, osnum = sender_copy->osnum,
                                p_objid = &copy);
    if(! (1 & sts)) goto wrapup;

    /*
     * Put me and my copy in the copy info
     */
    EMcpsearch(EMmsg, my_id, &copy, copy_info, 3, &copy_exists);

    copy_exists = TRUE;
  }

  /*
   * Connect my copy and the sender's copy on the same indices.
   */
  {
    OMuint          connect_index;
    OM_S_CHANSELECT to_requesters;

    sts = EMmake_chanselect (EMShelper_to_requesters, &to_requesters);
    if(! (1 & sts)) goto wrapup;

    sts = om$get_index(object_c = me, p_chanselect = &to_requesters,
                       objid = sender_id, indexaddr = &connect_index);
    if(! (1 & sts)) goto wrapup;

    sts = om$send(msg = message EMShelper.EMhelperConnect(EMmsg,
                  sender_copy->objid, connect_index),
                  targetid = copy, targetos = sender_copy->osnum);
    if(! (1 & *EMmsg & sts)) goto wrapup;
  }

wrapup:
  /*
   * On failure, delete the copy.
   */
  if(! (1 & *EMmsg & sts))
  {
    if(copy ISNT NULL_OBJID)
    {
      om$send(msg = message Root.delete(0),
              targetid = copy, targetos = sender_copy->osnum);
    }
  }
  EMSmsgReport(sts, "EMShelper.EMgdcopy", FALSE);
  if EMSmsgReport(*EMmsg, "EMShelper.EMgdcopy", FALSE) sts = OM_E_ABORT;
  return(sts);
}

end implementation EMShelper;
