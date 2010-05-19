/* $Id: trans_symb.I,v 1.2 2001/01/18 19:09:15 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / trans_symb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: trans_symb.I,v $
 *	Revision 1.2  2001/01/18 19:09:15  ramarao
 *	Merged Service Pack Files to 262 pload.
 *	
# Revision 1.2  2000/07/17  16:24:56  pinnacle
# Replaced: vds/vdassoc/trans_symb.I for:  by rchennup for Service Pack
#
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
	Fix temporary bug on transfert of symboly when a VDsymb_hold is not
	initialize.
	LLC : 29 june 93
	Jean : 14 July 93 . Modification on the file to not display
	                    error message when putsymb fail. 
	Mallik: 7 June 94 . Even if msg_symb value is GR_I_NODISATTR it is
			    alright to transfer the symbology. GR_I_NODISATTR
			    is informational which says that the owner
			    properties are not set to GR_SYM_DISATTR, and that
			    the symbology returned is that of the first compo-
			    nent.

	Pascale: 10 June 94. If context is a VDsymb_hold, the test on the 
			    symbology to allow to return was not correct, 
			    and a NULL symbology was tranfer to my_go.

	Rama Rao: 14 July 00: Don't transfer the symbolgy for drawing objects.

*/

class implementation NDnodein;


#include "AS_status.h"
#include "OMminimum.h"
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "nddef.h"
#include "macro.h"
#include "godef.h"    
#include "grdpbdef.h"    
#include "grdpbmacros.h"    
#include "igrdp.h"
#include "madef.h"
#include "exmacros.h"
#include "grerr.h"
#define AS_DEBUG

from GRgraphics  import GRchgprops;
from GRgraphics  import GRgetprops;
from GRvg  import GRputsymb, GRgetsymb, GRchgdp, GRgetattr, GRputattr;
from GRgraphics  import GRcopy;
from GRtext import GRgettxattr, GRreplace_text;

extern   OM_S_CHANSELECT AS_to_owner;

ACtrans_symb(context_go,my_go)
struct GRid context_go,my_go;
/*.ACtrans_symb*/
{
int status;
IGRlong 		msg,msg_layer,msg_symb;
struct GRsymbology 	symb;
IGRshort	 	props,my_props,set;
GRclassid		obj_class,obj_class1;
IGRlong			sts_hold;
struct GRid             macro;

   om$get_objid_at_index(  osnum        = context_go.osnum,
                           objid        = context_go.objid,
                           p_chanselect = &AS_to_owner,
                           index        = 0,
                           objidaddr    = &macro.objid,
                           osnumaddr    = &macro.osnum  );

  om$get_classid(objid = macro.objid,osnum = macro.osnum,
                               p_classid = &obj_class);
  if( om$is_ancestry_valid(subclassid = obj_class,
                   superclassname = "VDgeom") == OM_S_SUCCESS ||
      om$is_ancestry_valid(subclassid = obj_class,
                   superclassname = "VDdrwGm") == OM_S_SUCCESS )      
  {
        return 1;
  }

/*"transfer symb from %d %d to %d %d\n",context_go.objid,context_go.osnum,my_go.objid,my_go.osnum */
 

  if(!IF_EQ_OBJID(context_go.objid,NULL_OBJID))
   {
    status = om$send(msg = message GRgraphics.GRgetprops(&msg_layer,&props),
		      senderid = my_go.objid,
                      targetid = context_go.objid,
                      targetos = context_go.osnum);
    as$status(  );

    status = om$send(msg = message GRvg.GRgetsymb(&msg_symb,&symb),
		      senderid = my_go.objid,
                      targetid = context_go.objid,
                      targetos = context_go.osnum);
/*"layer %d color %d\n",symb.level,symb.display_attr.color */ 
    as$status(  );

    // check if context is an uninitialized VDsymb_hold 

    sts_hold=om$get_classid(objid = context_go.objid,osnum = context_go.osnum,
                               p_classid = &obj_class);

    /* PL June 1994: modify the test because it doesn't work well */
    /* 	props & GR_.. instead of props == GR_ 			  */
    /*  level == 0 and color == 0 instead of level == color == 0  */

    if( (sts_hold&1) && om$is_ancestry_valid(subclassid = obj_class,
                           superclassname = "VDsymb_hold") == OM_S_SUCCESS)
	if( (symb.level == 0) && (symb.display_attr.color == 0) &&
	     (symb.display_attr.style == 0) && (symb.display_attr.weight == 0 ) 
	     &&  (props & GR_RIGID_RELATIONSHIP ) )	return 1;

    
    if(status&msg_symb&1)
     { if(msg_layer&1)
         {status = om$send(msg = message GRgraphics.GRgetprops(&msg,&my_props),
		      senderid = my_go.objid,
	              targetid = my_go.objid,
                      targetos = my_go.osnum);
          as$status(  );
          props =(GRIS_LOCATABLE|GRIS_DISPLAYABLE) & props;
          my_props = (~(GRIS_LOCATABLE|GRIS_DISPLAYABLE)) & my_props;
          my_props = props|my_props;
          set = -1;   /*replace */
          status = om$send(msg = message GRgraphics.GRchgprops(&msg,&set,
                                                           &my_props),
		      senderid = my_go.objid,
	              targetid = my_go.objid,
                      targetos = my_go.osnum);
          as$status(  );
         }

       if( msg_symb == MSSUCC || msg_symb == GR_I_NO_LAYER || msg_symb == GR_I_NODISATTR)
         {
          /*| transfer symbology */

          status = om$send(msg = message GRvg.GRputsymb(&msg,&symb),
		      senderid = my_go.objid,
	              targetid = my_go.objid,
                      targetos = my_go.osnum);
	  /* 
	    Jean : 14 July 93 . Does not compile the next line. 
	    The ACtrans_symb is sometimes called for object not in GRvg class
	    (in our equipment it is called for ACpl_hold for example).
	    As it doesn't seem to be fundamental we just ignore the return
	    status.
	    */
#if 0 
	    as$status(  );
#endif
         }
     }
       /* Transfer now specific attributes */
       status=om$get_classid(objid = context_go.objid,osnum = context_go.osnum,
                               p_classid = &obj_class);
       status=om$get_classid(objid = my_go.objid,osnum = my_go.osnum,
                               p_classid = &obj_class1);
       if(  (om$is_ancestry_valid(subclassid = obj_class,
                           superclassname = "GRbcsubbc") == OM_S_SUCCESS
          && om$is_ancestry_valid(subclassid = obj_class1,
                           superclassname = "GRbcsubbc") == OM_S_SUCCESS)

          ||
            (om$is_ancestry_valid(subclassid = obj_class,
                           superclassname = "EMSsubbs") == OM_S_SUCCESS
          && om$is_ancestry_valid(subclassid = obj_class1,
                           superclassname = "EMSsubbs") == OM_S_SUCCESS) )
 
         {char bc_attr[100];
          status = om$send(msg = message GRvg.GRgetattr(&msg,bc_attr),
                      senderid = NULL_OBJID,
                      targetid = context_go.objid,
                      targetos = context_go.osnum);

          if((status&1) && msg == MSSUCC)
           {
            status=om$send(msg = message GRvg.GRputattr(&msg,bc_attr),
                      senderid = my_go.objid,
                      targetid = my_go.objid,
                      targetos = my_go.osnum);
            as$status();
           }

        }
  }
 return 1;
}


end implementation NDnodein;

