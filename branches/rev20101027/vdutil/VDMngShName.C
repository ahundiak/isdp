/* $Id: VDMngShName.C,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDMngShName.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDMngShName.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1995/11/29  13:55:54  pinnacle
 * Replaced: ./vdutil/VDMngShName.C for:  by ksundar for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#include        <stdio.h>
#include	<string.h>

#include        "exmacros.h"
#include        "OMerrordef.h"

#include        "ms.h"
#include        "msdef.h"
#include        "msmacros.h"

#include        "VDDbDef.h"
#include        "vdbmacros.h"
#include        "VDSutil.h"
#include        "VDmsg.h"
#include 	"grdpbdef.h"
#include 	"VDSeqpfidef.h"
#include	"vdsfimacros.h"

static	int	OldProduct = -1, OldAttType = -1;
static  int	NbShortName;
static  char	**ShortNameList = NULL;


VDMngShortNameList(
IGRlong		*msg,		/* O : Complection code 		*/
IGRchar		*FormPtr,	/* I : Form pointer			*/
IGRint		Label,		/* I : Gadget id			*/
IGRint		MsgLabel,	/* I : Gadget id			*/
IGRint		Mode,		/* I : Selection mode, see VDSeqpfidef.h */
IGRint		Product,	/* I : product type, see VDmacdef.h	*/
IGRint		AttribType,	/* I : Attribute to be handled		*/
				/*     see VDSeqpfidef.h		*/
IGRchar		*ShortName	/* I/O : Old attribute			*/
)
{
 IGRint         row = 0, col = 0, sel_flag = 0;
 IGRint		list_num , ii;
 IGRint		status;
 IGRchar	AttribTxt[129], *ptr;


  switch ( AttribType )
  {
   case  VD_SYS_NAME :
	list_num = 125;
	break;

   default :
     FIg_set_text( FormPtr, MsgLabel, "Unknown attribute type" );
     goto wrap_up;
  }

  if ( Product != OldProduct || AttribType != OldAttType )
  {  if ( ShortNameList )
     {  vdb$RisFreeBuffer( buffer = ShortNameList,
			size   = NbShortName * 2);
     }
     for(row=0;row<NbShortName;row++)
     	VDfld_set_list_text(FormPtr, Label, row, col, "", sel_flag );
     NbShortName = 0;

     status = vd$get_codelist_sname( msg = msg,
				     product = Product,
				     list_num = list_num,
				     name_list = &ShortNameList,
				     list_size   = &NbShortName );

     if ( !(status & *msg & 1) )
     {  FIg_set_text ( FormPtr, MsgLabel, "Error getting the list" );
	goto wrap_up;
     }
     OldProduct = Product;
     OldAttType = AttribType;

     row = 0;
     for(ii=0;ii<NbShortName;ii++)
     {
	if ( ShortNameList[ii*2][0] == '\0' ) continue;
	sprintf( AttribTxt, "%s:%s", ShortNameList[ii*2], ShortNameList[ii*2+1]);
 	VDfld_set_list_text(FormPtr, Label, row, col, AttribTxt, sel_flag );
	row++;
     }
  }


  if(Mode == VDShortNameLstInit)
  {
    /* set list size */
     row = 0;
     for(ii=0;ii<NbShortName;ii++)
     {
	if ( ShortNameList[ii*2][0] == '\0' ) continue;
	sprintf( AttribTxt, "%s:%s", ShortNameList[ii*2], ShortNameList[ii*2+1]);
 	VDfld_set_list_text(FormPtr, Label, row, col, AttribTxt, sel_flag );
	row++;
     }
  }


  if(Mode == VDShortNameVerif)
  {
    FIg_get_text(FormPtr, Label, AttribTxt);
    /* do nothing if AttribTxt is NULL */
    if ( AttribTxt[0] == '\0' )
    { ShortName[0] = '\0';
      FIg_set_text(FormPtr, MsgLabel," ");
      goto wrap_up;
    }

    ptr = (char *)strchr( AttribTxt, ':' );
    if ( ptr ) *ptr = '\0';

    for( ii=0; ii<NbShortName; ii++ )
    { if( !strcmp(AttribTxt, ShortNameList[ii*2]) )
      {  strcpy( ShortName, AttribTxt );
	 FIg_set_text(FormPtr, Label, AttribTxt );
	 FIg_set_text(FormPtr, MsgLabel," ");
	 goto wrap_up;
      }
    }

    FIg_set_text( FormPtr, MsgLabel, "Invalid input" );
    FIg_set_text( FormPtr, Label, ShortName );
  }

wrap_up:
    *msg = MSSUCC;
    return OM_S_SUCCESS;

}






