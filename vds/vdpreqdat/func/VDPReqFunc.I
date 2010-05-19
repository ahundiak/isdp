/* $Id: VDPReqFunc.I,v 1.1.1.1 2001/01/04 21:09:03 cvs Exp $ */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdpreqdat/func/VDPReqFunc.I
 *
 * Description:
 *      Function :  VDPGetContextTypeCode
 *
 *
 * Dependencies:
 *
 * History:
 *
 *      09/28/95        MSM        Creation
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include "stdio.h"
#include "string.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDPDatFrmDf.h"

IGRlong	VDPGetContextTypeCode( IGRchar *CtxTypeName,
				IGRchar *TypeCode )
{
   SetProc( VDPGetContextTypeCode ); Begin

   if( !(strcmp(CtxTypeName,VDPTSYSTEM)))
	*TypeCode = VDPTSYSTEM_CODE;
   else if ( !(strcmp(CtxTypeName,VDPTCOMPARTMENT)))
	*TypeCode = VDPTCOMPARTMENT_CODE;
   else if ( !(strcmp(CtxTypeName,VDPTZONE)))
	*TypeCode = VDPTZONE_CODE;
   else if ( !(strcmp(CtxTypeName,VDPTUSERDEF)))
	*TypeCode = VDPTUSERDEF_CODE;
   else if ( !(strcmp(CtxTypeName,VDPTBUDGET)))
	*TypeCode = VDPTBUDGET_CODE;
   else
	*TypeCode = '\0';

   End
   return OM_S_SUCCESS;

}

IGRlong	VDPGetContextType( IGRchar  TypeCode,
			   IGRchar *CtxTypeName )
{
   SetProc( VDPGetContextType ); Begin

   switch ( TypeCode )
   {
	case VDPTSYSTEM_CODE :
		strcpy( CtxTypeName,VDPTSYSTEM);
		break;
	case VDPTCOMPARTMENT_CODE :
		strcpy( CtxTypeName,VDPTCOMPARTMENT);
		break;
	case VDPTZONE_CODE :
		strcpy( CtxTypeName,VDPTZONE);
		break;
	case VDPTUSERDEF_CODE :
		strcpy( CtxTypeName,VDPTUSERDEF);
		break;
	case VDPTBUDGET_CODE :
		strcpy( CtxTypeName,VDPTBUDGET);
		break;
	default : 
		CtxTypeName[0] = '\0';
		break;
   }
   End
   return OM_S_SUCCESS;

}


/* given subtype description get the subtype code */

IGRlong	VDPGetContextSubTypeCode ( IGRchar		Type,
				   IGRchar  		*CtxSubTypeDesc,
				   struct VDPPlCtxTST	*CtxTSTList,
				   IGRint		nbList,
				   IGRint   		*CtxSubType )
{
   IGRint	i;

   SetProc( VDPGetContextSubTypeCode ); Begin

   for (i = 0; i< nbList; i++ )
   {
      if(!(strcmp(CtxSubTypeDesc, CtxTSTList[i].SubTypeDesc )) && 
	   (Type == CtxTSTList[i].Type ))
      {
	  *CtxSubType = CtxTSTList[i].SubType;
	  break;
      }
   }

   End
   return OM_S_SUCCESS;
}


/* given  type-subtype get the class name of the context */

IGRlong	VDPGetClassNameGivenTST (  IGRchar		Type,
				   IGRint  		CtxSubType,
				   struct VDPPlCtxTST	*CtxTSTList,
				   IGRint		nbList,
				   IGRchar   		*ClassName )
{
   IGRint	i;
   IGRboolean	found = FALSE;

   SetProc( VDPGetClassNameGivenTST ); Begin
   ClassName[0]='\0';

   for (i = 0; i< nbList; i++ )
   {
      if((CtxSubType == CtxTSTList[i].SubType ) && 
	   (Type == CtxTSTList[i].Type ))
      {
	  strcpy(ClassName, CtxTSTList[i].ClassName );
	  found=TRUE;
	  break;
      }
   }

   if (!found )
      return OM_E_ABORT;

   End
   return OM_S_SUCCESS;
}

end implementation Root;
