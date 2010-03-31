/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmacro;

#include "EMS.h"
# include "msdef.h" /* MS message codes */
#include "msmacros.h"
#include "emsclasses.h"
#include "ECmsg.h"

/*
Uses class name and appends operation type to it. Uses the resulting string
as the message name to search the message file.
*/
method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 IGRchar myclassname[OM_K_MAXCLASS_LEN];
 IGRlong sts = OM_S_SUCCESS;
 OM_S_CHANSELECT to_comps;
 IGRint count ,options;
 IGRuint type;
 IGRchar loc_buff[MS_MAX_MSG_LENGTH];

 *msg = MSSUCC;

 sts = EMmake_chanselect(GRcmpowner_to_components, &to_comps);
 if(!(1 & sts)) goto ret_end;

 sts = om$send ( msg = message GRgraphics.GRgetobjinfo( msg,
						       info),
		p_chanselect = &to_comps,
		senderid    = my_id,
		from = 0,
		to = 0);
 if(!(1 & sts)) goto ret_end;
      

 sts = om$send( msg = message EMSassoc.EMget_info(msg,
						  options,
						  &type,
						  NULL,
						  NULL),
		  targetid = my_id);
 if(!(1 & sts)) goto ret_end;

 if( type == EMS_ASpattern_macro)
   {
     /* Append "Pattern" at the end */
     ex$message( msgnumb = EMS_I_Pattern, buff = loc_buff);
     sprintf(info->type,"%s %s",info->type, loc_buff);
   }
                     
ret_end:
 return(sts);
}

end implementation EMSsfmacro;
