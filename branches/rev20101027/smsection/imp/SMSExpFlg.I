/* $Id: SMSExpFlg.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsection/imp / SMSExpFlg.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSExpFlg.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH  : 16 Oct 92	  creation date.
/*
/* */

class implementation Root;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "parametric.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"
#include "expression.h"
#include "expmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"



#include "AS_status.h"

#define AS_DEBUG


#define SMCalSectFlagExpName  	":CALSECTFLAG"

#define SMCALSCTON	1	/* Turn on	*/
#define SMCALSCTOF	0	/* Turn off	*/
#define SMCALSCTTG	2	/* Switch	*/


from    expression	import	modify, create;
from    NDnode		import	NDgive_structure;
from    GRvg            import  GRputname;

/* 
 *   SMSetCalSctFlg:
 *
 *   Set the calculation section flag.
 *
 */

SMSetCalSctFlg(Type)
IGRshort	Type;	/* Operation type 	(I) */
{
 IGRlong                status/*, loc_msg*/;
 IGRchar                ExpName[81], ExpValue[81];
 struct GRid            module, MyExpId;
 IGRshort		rc;
 extern GRclassid 	OPP_text_exp_class_id;

 /* Look if already existing */
 VDSget_filename(ExpName);
 strcat(ExpName, SMCalSectFlagExpName);

 status = di$translate(objname = ExpName,
              p_objid = &MyExpId.objid,
              p_osnum = &MyExpId.osnum);
 if(!(status&1))
  {
   /* The expression does not exist => create it */

   if(Type == SMCALSCTON || Type == SMCALSCTTG) strcpy(ExpValue, "y");
   else			  			strcpy(ExpValue, "n");

   ex$get_cur_mod(id = &module.objid, osnum = &module.osnum);

   MyExpId.osnum = module.osnum;
   status = om$construct(classid = OPP_text_exp_class_id,
			 osnum   = MyExpId.osnum,
			 p_objid = &MyExpId.objid);
   if(!(status & 1)) return 0;

   status = om$send(msg = message expression.create(ExpName, ExpValue, &rc),
                        senderid = NULL_OBJID,
                        targetid = MyExpId.objid,
                        targetos = MyExpId.osnum);
   if(!(status & rc & 1)) return 0;

   /* status = exp$create(exp_name = ExpName, exp_syntax = ExpValue, 
   /*	     	       osnum    = module.osnum , type_rq    = EXP_TEXT,
   /*		       p_exp_id = MyExpId.objid, p_osnum    = MyExpId.osnum);
   /*
   /* Add a name separately to avoid the pb of changing dir */
   /*status = om$send(msg = message GRvg.GRputname(&loc_msg, ExpName),
   /*                     senderid = NULL_OBJID,
   /*                     targetid = MyExpId.objid,
   /*                     targetos = MyExpId.osnum);
   /*if(!(status & loc_msg & 1)) return 0;
   /* */

   return 1;
  }

 if(Type == SMCALSCTTG)
  {
   IGRboolean CurCalFlg;

   /* Get the current value */
   if(!(SMGetCalSctFlg(&CurCalFlg) & 1)) return 0;

   if(CurCalFlg) ExpValue[0] = 'n';
   else		 ExpValue[0] = 'y';
   ExpValue[1] = '\0';
  }
 else
  {
   if(Type == SMCALSCTON) ExpValue[0] = 'y';
   else			  ExpValue[0] = 'n';
   ExpValue[1] = '\0';
  }

 status = om$send(msg = message expression.modify(ExpName, ExpValue, &rc),
 				senderid = NULL_OBJID,
				targetid = MyExpId.objid,
				targetos = MyExpId.osnum);
 if(!(status & rc & 1)) return 0;
 
 
 return 1;
}



/* 
 *   SMGetCalSctFlg:
 *
 *   Set the calculation section flag.
 *
 */

SMGetCalSctFlg(CalFlg)
IGRboolean	*CalFlg;	/* True => one, FALSE => off	(O) */
{
 IGRlong                status, loc_msg;
 IGRchar                ExpName[81];
 struct GRid            MyExpId;
 struct ret_struct	rt;

 /* Look if already existing */
 VDSget_filename(ExpName);
 strcat(ExpName, SMCalSectFlagExpName);

 status = di$translate(objname = ExpName,
              p_objid = &MyExpId.objid,
              p_osnum = &MyExpId.osnum);
 if(!(status&1))

  {
   *CalFlg = FALSE;
   return 1;
  }

 /* Get the current value */
 status = om$send(msg = message NDnode.NDgive_structure(&loc_msg, &rt, NULL),
 				senderid = NULL_OBJID,
				targetid = MyExpId.objid,
				targetos = MyExpId.osnum);
 if(!(status & loc_msg & 1)) return 0;
 if(rt.type != text_type) *CalFlg = FALSE;

 if(rt.var.text_st.text_string[0] == 'y' ||
    rt.var.text_st.text_string[0] == 'Y') *CalFlg = TRUE;
 else					  *CalFlg = FALSE;

 return 1;
}


end implementation Root;

