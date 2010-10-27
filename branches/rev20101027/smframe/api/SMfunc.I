/* $Id: SMfunc.I,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smframe/api/SMfunc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMfunc.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/18  18:56:48  pinnacle
# SurfaceFrame
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/09/26  06:28:40  pinnacle
# Created: smframe/api/SMfunc.I by rgade for vds.241
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *
 *  09/25/96  Sundar  Creation.
 *  12/18/97  ah      India made some changes, not sure what
 * -------------------------------------------------------------------*/

class implementation Root;

#include <stdio.h>
#include "OMmacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "godef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "v_dbgmacros.h"

from SMframe 	import SMfind_frame_num;
from SMfrm_syst import SMfind_all_frame;

IGRint SMvalidate_reinforce(valid, inforce)
IGRint          *valid;
IGRchar		*inforce;
{
 IGRint 	*reinf_array=NULL, nb_elem ;
 IGRchar 	syn_error[20] ;

	*valid=SMFrmAnalyseExp(inforce,&reinf_array,&nb_elem,syn_error);

	if ( reinf_array != NULL) free(reinf_array);

	return 1;
}

IGRlong SMvalidate_frame(check,frame,inforce)
IGRlong         *check;
struct GRid     frame;
IGRchar         *inforce;
{
 IGRlong	status, s_msg;
 IGRint		fr_num, *reinf_array=NULL, nb_elem, i, valid;
 IGRchar	syn_error[20] ;

	status = OM_S_SUCCESS;
	s_msg = MSSUCC;

	status =  om$send(msg = message SMframe.SMfind_frame_num(&s_msg,
								&fr_num),
					senderid = NULL_OBJID,
					targetid = frame.objid,
					targetos = frame.osnum);
	__CheckRC( status, s_msg, "SMframe.SMfind_frame_num", wrapup );

	valid=SMFrmAnalyseExp(inforce,&reinf_array,&nb_elem,syn_error);

	for (i=0; i < nb_elem; i++)
		if ( reinf_array[i] == fr_num ){
			*check=1;
			if ( reinf_array != NULL) free(reinf_array);
			goto wrapup;
		}

	*check=0;
	if ( reinf_array != NULL) free(reinf_array);

wrapup :
	return status;
}

IGRlong SMget_frs_from_frsys(num_elm,fr_obj,inforce,frames)
IGRint         *num_elm;
struct GRid     fr_obj;
IGRchar         *inforce;
struct GRid     **frames;
{
 IGRint 		low_num, hinum, nb_frame, *fr_number;
 IGRint 		*reinf_array=NULL, valid, i, i0, j, nb_elem;
 IGRchar 		syn_error[20] ;
 struct GRid 		*frame = NULL;
 IGRlong 		msg, status;

        status = OM_S_SUCCESS;
        msg = MSSUCC;
	
	status = om$send(msg = message SMfrm_syst.SMfind_all_frame
		(&msg,&frame,&fr_number,&nb_frame,&low_num,&hinum),
		senderid = NULL_OBJID,
		targetid = fr_obj.objid,
		targetos = fr_obj.osnum);

	__CheckRC( status, msg, "SMfrm_syst.SMfind_all_frame", wrapup );

	*frames=(struct GRid *)malloc( (hinum-low_num+1)*sizeof(struct GRid)) ;
	if ( inforce[0] == '\0' ){
		*num_elm=hinum-low_num+1;
		for(j=0; j <= *num_elm; j++){
			(*frames)[j].objid=frame[j].objid;
                        (*frames)[j].osnum=frame[j].osnum;
		}	
		goto wrapup;
	}
		
	valid=SMFrmAnalyseExp(inforce,&reinf_array,&nb_elem,syn_error);

	i0=0;
	for (i=low_num; i <= hinum; i++){
		for(j=0; j < nb_elem; j++)
			if ( i == reinf_array[j] ){
				(*frames)[i0].objid=frame[i-low_num].objid;
				(*frames)[i0].osnum=frame[i-low_num].osnum;
				i0++;
			}
	}
	*num_elm=i0;


wrapup :
	if ( reinf_array != NULL ) free(reinf_array);
	if ( frame != NULL ) free(frame);
	return status;
}

end implementation Root;
