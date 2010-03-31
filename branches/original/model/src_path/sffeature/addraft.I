/*
 *  OVERVIEW
 *
 *  The function in this file is API for drafting a solid     
 *
 *  NOTES
 *
 *  HISTORY
 *  Jagan  04/25/96  Creation
 */

class implementation Root;

#include "OMminimum.h"
#include "OMmacros.h"
#include "bsvalues.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
#include "dp.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSasnuc.h"
#include "EMSascmacros.h"
#include "EMSasopts.h"


#include "PWminimum.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWmodel.h"
#include "PWapi/mx.h"
#include "PWapi/msgsend.h"
#include "valinfo.h"



#include "EMSmsgdef.h"
#include "EMSasnuc.h"
#include "REaddrmfea.h"
#include "EMSfeadef.h"
#include "EMSasfeatdef.h"

#include "bsparameters.h"
#include "bserr.h"
#include "bsdotp.h"
#include "bscvtstclsd.h"
#include "bsnorvec.h"

extern OMuword OPP_EMSsolid_class_id;

PWresult pwAddDraft
(
  PWobjid solid,
  PWosnum os,
  PWobjid datum_plane,
  int num_draft_sfs,
  PWobjid *draft_sfs,
  struct PWvalueinfo draft_angle,
  PWboolean draft_into_volume,
  PWobjid *drafted_solid
)
{
  struct                GRid cons_id;
  IGRint                add_draft_type,i;
  IGRboolean            associative_flag;
  struct GRlc_info      *loc_info;
  struct GRvg_construct constrlist;
  struct GRevent        events[2];
  struct GRmd_env       md_env;
  struct IGRdisplay     display;
  IGRlong               nbytes_trans,nbytes_in_buff,sizbuf,nret;
  IGRshort              level;
  IGRint                sts;
  IGRlong               msg_loc,status;
  IGRushort             initopts; 
  PWresult              result;
  PWclassid             classid;
  associative_flag = TRUE;
  add_draft_type = 1;  /* To be found out, what it is ? */

  result = PW_K_Success; 
  /* validate the solid */
  status = om$is_objid_valid ( objid = solid , osnum = os );
  OnErrorState( !status, result, PW_K_InvalidArg, wrap_up);

  classid = omClassidFromObjid ( solid ,os);
  printf(" Classid = %ld \n",classid);

  /*  if ( ! omIsAncestryValid ( classid , OPP_EMSsolid_class_id ))
  {
     OnErrorState( TRUE, result, PW_K_Error, wrap_up);
  }
  */

  /* get constuction list    */
  status = gr$get_module_env(msg = &msg_loc,
                          sizbuf = &sizbuf,
                          buffer = &md_env,
                          nret   = &nret);
  OnErrorState( !(status & 1),result,PW_K_Error,wrap_up);


  nbytes_in_buff = sizeof(struct IGRdisplay);
  sts = gr$get_active_display (msg = &msg_loc,
                               sizbuf = &nbytes_in_buff,
                               buffer = &display,
                               nret = &nbytes_trans);
  if(!(sts & msg_loc & 1))
   {
     goto wrap_up;
   }

  nbytes_in_buff = sizeof(IGRshort);
  sts = gr$get_active_level(msg = &msg_loc,
                            sizbuf = &nbytes_in_buff,
                            buffer = &level,
                            nret = &nbytes_trans);
  if(!(sts & msg_loc & 1))
   {
     goto wrap_up;
   }

  EMinitvgcnstr( &msg_loc, &md_env,&display, 0,&constrlist);
  OnErrorState( !(1&msg_loc), result, PW_K_Error, wrap_up);

  status = EMgetvgcnstr ( NULL, NULL, &md_env, level,
                          &display, 0, 0, &constrlist);
  OnErrorState( !status, result, PW_K_Error, wrap_up);
  events[0].located_object[0].located_obj.objid=NULL_OBJID;
  events[0].event.value = draft_angle.value;
  events[0].subtype = 1;
  events[1].located_object[0].located_obj.objid=NULL_OBJID;
 
  /* flag to decide in or out draft*/
  events[1].event.value = draft_into_volume ;
  events[1].subtype = 1;
  loc_info = ( struct GRlc_info *)malloc((num_draft_sfs + 1)*
                                  sizeof(struct GRlc_info));
 
  loc_info[0].located_obj.objid = datum_plane; 
  loc_info[0].located_obj.osnum = os;
  loc_info[0].module_info = md_env; 
  for(i = 1 ; i < (num_draft_sfs + 1) ; i++)
  {
    loc_info[i].located_obj.objid = draft_sfs[i- 1];
    loc_info[i].located_obj.osnum = os; 
    loc_info[i].module_info = md_env;
  }

  initopts = NULL;

        EFadd_draft(&msg_loc,
                    num_draft_sfs,
                    draft_into_volume,
                    &events[0],       
                    &events[1],      
                    add_draft_type,
                    loc_info,      
                    initopts,       
                    &constrlist,
                    &cons_id,
                    associative_flag ? NULL : EMSasconst_notassociative);
  if(drafted_solid) *drafted_solid = cons_id.objid;

 wrap_up:
  PW_Wrapup(result,"pwAddDraft");
   return(result);
}
end implementation Root;
