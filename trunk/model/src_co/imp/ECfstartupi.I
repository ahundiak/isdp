/* ###################   APOGEE COMPILED   ################## */
class implementation ECfstartup;

%safe
#include <math.h>
%endsafe

# include "EMS.h" /* For shared libraries */
# include <stdio.h>
# include "ems_m_inc.h" /* Includes everything */
# include "alloca.h"
# include "EMSmsgdef.h"

extern IGRint GRget_sorted_nested_files();

extern OMuword OPP_EMShrzcvs_class_id;

from NDnode     import ASreturn_go;
from GRgraphics import GRdelete;
from OMObjSpace import pass;

/*
 * This command object serves as the startup command to initalise
 * EMS structures during the process of creation of a new file with the
 * help of the executive..
 *
 * Currently the same is used for :
 * a) Constructing and waking up EMSdpb object.
 *
 * History
 *   02/09/89 : PP  : Creation.
 *   07/27/93 : WBC : Sending the message NDparent_deleted to any horizon
 *                    curves with broken connections.
 */

method execute(int *response; char *response_data; int pos)
{
 IGRlong EMmsg,
         OMsts;
 IGRint sts,
        index,
        index2,
        num_ref_files;
 IGRuint broken_count,
         previous_count;
 struct GRid dpbid,
             broken_con_obj;
 struct GRmd_env md_env;
 OM_S_MESSAGE mymessage;
 OM_S_CLASSLIST classlist;
 OM_S_TAG_CON_INFO *connect_info;
 GRobjid osobj;
 GRspacenum *ref_osnums,
             cur_mod_osnum;
 OMuword classid;
 extern OMuword OPP_EMShrzcvs_class_id;
 extern int ASsuper_construct();

 struct
 {
   IGRlong  *msg;
 } arglist;

/*
 * This function constructs a dpb object if one is not already present.
 */

 ASsuper_construct();
/*
 * Initialize associative geometry. Other wise they barf all over the
 * place.
 */
 EMget_dpbobjid (&EMmsg, &dpbid.objid, &dpbid.osnum);
 if (!(1&EMmsg)) 
  fprintf (stderr, "Error getting EMSdpb object. \n");

/* if the master file object space contains any horizon curves, need to
 * determine if any of them have broken connections; if they do, the
 * horizon curves should be deleted
 */

 classid = OPP_EMShrzcvs_class_id;
 classlist.w_count = 1;
 classlist.w_flags = 0;
 classlist.p_classes = &classid;

 arglist.msg = &EMmsg;

 OMsts = om$make_message(classname = "EMShrzcvs",
                         methodname = "EMfind_hrzcvs",
                         size = sizeof(arglist),
                         p_arglist = &arglist,
                         p_msg = &mymessage);
 if (! (1 & OMsts))
   goto wrapup;

 ex$get_cur_mod(osnum = &cur_mod_osnum);
 om$osnum_to_oso_objid(osnum = cur_mod_osnum,
                       p_objid = &osobj);
 OMsts = OM_S_SUCCESS;

 OMsts = om$send(msg = message OMObjSpace.pass(&classlist, OM_e_wrt_object,
                                               &mymessage),
                 targetid = osobj,
                 targetos = cur_mod_osnum);

 if ((OMsts == OM_I_STOP_SENDING) &&
     (EMmsg == EMS_I_Found))
 {
  sts = GRget_sorted_nested_files(&EMmsg, &num_ref_files, &ref_osnums,
                                  cur_mod_osnum);
  if (! (1 & sts & EMmsg))
    goto wrapup;

  previous_count = 0;

  /* skip the first osnum since it will be cur_mod_osnum and there shouldn't
   * be any horizon curves with broken connections in cur_mod_osnum since
   * the parents would be in the same object space as the horizon curves and
   * when the parent is deleted, the horizon curves would be notified and
   * would have deleted themselves
   */

  for (index = 1; index < num_ref_files; index++)
  {
    OMsts = om$broken_connects(osnum = cur_mod_osnum,
                               tagged_osnum = ref_osnums[index],
                               p_count = &broken_count);

    if ((1 & OMsts) && broken_count)
    {
      /* allocate more stack space if necessary */

      if (broken_count > previous_count)
      {
        connect_info = NULL;
        connect_info = (OM_S_TAG_CON_INFO *)alloca(broken_count *
                                                  sizeof(OM_S_TAG_CON_INFO));
        if (! connect_info)
          goto wrapup;

        previous_count = broken_count;
      }

      OMsts = om$broken_connects(osnum = cur_mod_osnum,
                                 tagged_osnum = ref_osnums[index],
                                 p_count = &broken_count,
                                 size = broken_count,
                                 p_tag_con_info = connect_info);
      if (1 & OMsts)
      {
        md_env.md_id.objid = NULL_OBJID;

        for (index2 = 0; index2 < broken_count; index2++)
        {
          /* send the message ASreturn_go to get the id of the child object
           * which has had its channel connection broken
           */

          OMsts = om$send(msg = message NDnode.ASreturn_go(&broken_con_obj,
                                                   &md_env.md_env.matrix_type,
                                                   md_env.md_env.matrix),
                          targetid = connect_info[index2].objid,
                          targetos = cur_mod_osnum);
          if (1 & OMsts)
          {
            OMsts = om$get_classid(osnum = broken_con_obj.osnum,
                                   objid = broken_con_obj.objid,
                                   p_classid = &classid);
            if ((1 & OMsts) &&
                (classid == OPP_EMShrzcvs_class_id))
            {
              md_env.md_id.osnum = broken_con_obj.osnum;

              om$send(msg = message GRgraphics.GRdelete(&EMmsg, &md_env),
                      targetid = broken_con_obj.objid,
                      targetos = broken_con_obj.osnum);
            }
          }
         }
       }
     }
   }
 }

wrapup:
 
 *response = TERMINATE;
 return (OM_S_SUCCESS);
 
}
end implementation ECfstartup;

