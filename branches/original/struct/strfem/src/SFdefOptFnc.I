class implementation Root;

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"

#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "APdef.h"
#include "vderrmacros.h"
#include  "SFconvDef.h"

from	GRvg		import	GRputname;
from	ACrg_collect	import	ACset_list_attribute;
from	ACrg_collect	import	ACget_named_attribute;

/**************************************************************************
 Doc : SFsetConvOpt

 Desrciption :  This function sets the global conversion options.

 History :

 Date	   Who       Revision	Why
 -----     ---       --------   ---
 08-30-94  raju	     2.3.1	Creation

************************************************************************/
long  SFsetConvOpt (
   long		*msg,		/* O - return status	*/
   char		*PlateSurfOpt,  /* I - which surface of plate to extract    */
   double	*offset,	/* I - offset, needed only if
				       PlateSurfOpt is keyin		    */
   char		*BmExtractOpt,  /* I - meshing or trace curves  */
   int		ElemType,	/* I - LINE2 or LINE3, needed only if
				       BmExtarctOpt is meshing 		    */
   int		NbFemElem,      /* I - No. of FEM elements per beam, needes
				       only if BmExtractOpt is meshing      */
   int		ConvAllEl	/* I - TRUE for converting all elements.
				 *   - FALSE for converting unconverted 
				 *     elements only.
				 */
)
{

long			sts;
char			CollName[81];
struct GRid		CollId,
			module;
struct ACrg_coll	att[6];
IGRint			ind;


    sts = OM_S_SUCCESS;
    *msg = MSSUCC;

    sts = VDSget_filename ( CollName );
    strcat ( CollName, SFconvOptDir  );

    sts =  di$translate(objname = CollName,
			p_objid = &CollId.objid,
			p_osnum = &CollId.osnum);
    if(!(sts&1))
    {
     /* The collection does not exit, create it */

	ex$get_cur_mod(id = &module.objid, osnum = &module.osnum);

	CollId.osnum = module.osnum;
	sts = om$construct(classid = OPP_ACrg_collect_class_id,
			   osnum   = CollId.osnum,
			   p_objid = &CollId.objid );
	if(!(sts & 1)) goto wrapup;

	/* Add a name */
	sts = om$send(msg = message GRvg.GRputname( msg, CollName ),
			senderid = NULL_OBJID,
                        targetid = CollId.objid,
			targetos = CollId.osnum);
	if(!(sts & *msg & 1)) goto wrapup;
    }

    ind = 0;
    if ( PlateSurfOpt )
    {
	strcpy( att[ind].name, SF_TXT_PL_SURF );
	att[ind].desc.type  = AC_ATTRIB_TEXT;
	strcpy( att[ind].desc.value.att_txt, PlateSurfOpt );
	ind++;

        if ( !strcmp( PlateSurfOpt, SF_TXT_KEYIN ) )
	{
	   strcpy( att[ind].name, SF_TXT_OFFSET );
	   att[ind].desc.type = AC_ATTRIB_DOUBLE;
	   if ( offset )
		att[ind].desc.value.att_exp = *offset;
	   else
		att[ind].desc.value.att_exp = 0.0;
	   ind++;
	}
    } /* END if ( PlateSurfOp ) */

    if ( BmExtractOpt )
    {
	strcpy( att[ind].name, SF_TXT_BM_EXTR );
	att[ind].desc.type  = AC_ATTRIB_TEXT;
	strcpy( att[ind].desc.value.att_txt, BmExtractOpt );
	ind ++;

	if ( !strcmp( BmExtractOpt, SF_TXT_MESHING ) )
	{
	   strcpy( att[ind].name, SF_TXT_ELEM_TYPE );
	   att[ind].desc.type = AC_ATTRIB_DOUBLE;
	   att[ind].desc.value.att_exp = (double) ElemType;
	   ind++;

	   strcpy( att[ind].name, SF_TXT_FEM_ELEMS );
	   att[ind].desc.type = AC_ATTRIB_DOUBLE;
	   att[ind].desc.value.att_exp = (double) NbFemElem;
	   ind++;
	}
    } /* END if ( BmExtractOp ) */

    strcpy( att[ind].name, SF_TXT_CONV_ALL );
    att[ind].desc.type = AC_ATTRIB_DOUBLE;
    att[ind].desc.value.att_exp = (double) ConvAllEl;
    ind++;

    sts = om$send(msg = message ACrg_collect.ACset_list_attribute(
						msg, ind, att),
                                senderid = NULL_OBJID,
                                targetid = CollId.objid,
				targetos = CollId.osnum);
    VDS_ERR_HNDLR( "ACrg_collect.ACset_list_attribute", sts, *msg, VD_VERBOSE,
		    wrapup );

wrapup:
    return  sts;
}

/**************************************************************************
 Doc : SFgetConvOpt

 Desrciption :  This function gets the global conversion options.

 Notes : Any of the options may be specified NULL, if not interested in the
	 option.

 History :
 Date	   Who       Revision	Why
 -----     ---       --------   ---
 08-30-94  raju	     2.3.1	Creation

************************************************************************/
long  SFgetConvOpt (
   long		*msg,		/* O - return status	*/
   char		*PlateSurfOpt,  /* O - which surface of plate to extract    */
   double	*offset,	/* O - offset, contains value only if
				       PlateSurfOpt is keyin		    */
   char		*BmExtractOpt,  /* O - meshing or trace curves  */
   int		*ElemType,	/* O - LINE2 or LINE3, contains value only if
				       BmExtarctOpt is meshing 		    */
   int		*NbFemElem,	/* O - No. of FEM elements per beam,
				       only if BmExtractOpt is meshing      */
   int		*ConvAllEl	/* O - TRUE for converting all elements.
				 *   - FALSE for converting unconverted 
				 *     elements only.
				 */
)
{
long			sts;
char			CollName[81];
struct GRid		CollId;
struct ACrg_coll	att;
char			PlSurfLoc[ATTR_TXT],
			BmExtractLoc[ATTR_TXT];
double			offset_loc;
int			ElemTypeLoc,
			NbFemElemLoc,
			ConvAllElLoc;


    *msg = MSSUCC;

    /*
     *  set the defaults
     */
    strcpy ( PlSurfLoc, SF_TXT_TOP_SURF );
    offset_loc = 0.0;
    strcpy ( BmExtractLoc, SF_TXT_MESHING );
    ElemTypeLoc = LINE2;
    NbFemElemLoc = SF_DEFAULT_MESH_SIZE;
    ConvAllElLoc = FALSE;

    sts = VDSget_filename ( CollName );
    strcat ( CollName, SFconvOptDir  );

    sts =  di$translate(objname = CollName,
			p_objid = &CollId.objid,
			p_osnum = &CollId.osnum);
    if(!(sts&1))
    {
	/*
	 * The collection does not exit, return defualt options
	 */
	goto wrapup;
    }

    /*
     *  get option for "place plate at"
     */
    strcpy( att.name, SF_TXT_PL_SURF );
    sts = om$send(msg = message ACrg_collect.ACget_named_attribute
					( msg, &att ),
				senderid = NULL_OBJID,
				targetid = CollId.objid,
				targetos = CollId.osnum);

    if( (sts & *msg & 1) && (att.desc.type == AC_ATTRIB_TEXT) )
      strcpy ( PlSurfLoc, att.desc.value.att_txt);
    else
    {
      /* something wrong. set default */
      printf("SFgetConvOpt : ACrg_collect.ACget_named_attribute failed\n");
    }

    /*
     * get the offset value, if the surface option is "keyin".
     */
    if ( !strcmp(PlSurfLoc, SF_TXT_KEYIN) )
    {
	strcpy( att.name, SF_TXT_OFFSET );
	sts = om$send(msg = message ACrg_collect.ACget_named_attribute
					( msg, &att ),
 				senderid = NULL_OBJID,
				targetid = CollId.objid,
				targetos = CollId.osnum);
	if( (sts & *msg & 1) && (att.desc.type == AC_ATTRIB_DOUBLE) )
	  offset_loc = att.desc.value.att_exp;
	else
	{
	  /* something wrong. set default */
	  printf("SFgetConvOpt : ACrg_collect.ACget_named_attribute failed\n");
	}
    }

    /*
     *  get option for "beam extraction"
     */
    strcpy( att.name, SF_TXT_BM_EXTR );
    sts = om$send(msg = message ACrg_collect.ACget_named_attribute
					( msg, &att ),
				senderid = NULL_OBJID,
				targetid = CollId.objid,
				targetos = CollId.osnum);
    if( (sts & *msg & 1) && (att.desc.type == AC_ATTRIB_TEXT) )
    {
      strcpy ( BmExtractLoc, att.desc.value.att_txt );
 
      if ( !strcmp( BmExtractLoc, SF_TXT_MESHING ) )
      {
	strcpy( att.name, SF_TXT_ELEM_TYPE );
	sts = om$send(msg = message ACrg_collect.ACget_named_attribute
					( msg, &att ),
				senderid = NULL_OBJID,
				targetid = CollId.objid,
				targetos = CollId.osnum);
	if( (sts & *msg & 1) && (att.desc.type == AC_ATTRIB_DOUBLE) )
	    ElemTypeLoc = (int) att.desc.value.att_exp;
	else
	{
	  /* something wrong. set default */
	  printf("SFgetConvOpt : ACrg_collect.ACget_named_attribute failed\n");
	}

	strcpy( att.name, SF_TXT_FEM_ELEMS );
	sts = om$send(msg = message ACrg_collect.ACget_named_attribute
					( msg, &att ),
				senderid = NULL_OBJID,
				targetid = CollId.objid,
				targetos = CollId.osnum);
	if( (sts & *msg & 1) && (att.desc.type == AC_ATTRIB_DOUBLE) )
	    NbFemElemLoc = (int) att.desc.value.att_exp;
	else
	{
	  /* something wrong. set default */
	  printf("SFgetConvOpt : ACrg_collect.ACget_named_attribute failed\n");
	}
      }  /* if ( !strcmp( BmExtractLoc, SF_TXT_MESHING ) ) */
    }
    else
    {
      /* something wrong. set default */
      printf("SFgetConvOpt : ACrg_collect.ACget_named_attribute failed\n");
    }

    /*
     *  get option for "convert all elements"
     */
    strcpy( att.name, SF_TXT_CONV_ALL );
    sts = om$send(msg = message ACrg_collect.ACget_named_attribute
					( msg, &att ),
				senderid = NULL_OBJID,
				targetid = CollId.objid,
				targetos = CollId.osnum);
    if( (sts & *msg & 1) && (att.desc.type == AC_ATTRIB_DOUBLE) )
	ConvAllElLoc = (int) att.desc.value.att_exp;
    else
    {
	/* something wrong. set default */
	printf("SFgetConvOpt : ACrg_collect.ACget_named_attribute failed\n");
    }

wrapup:
    if ( PlateSurfOpt ) strcpy ( PlateSurfOpt, PlSurfLoc );
    if ( !strcmp ( PlSurfLoc, SF_TXT_KEYIN ) )
	if ( offset ) *offset = offset_loc;
    if ( BmExtractOpt ) strcpy ( BmExtractOpt, BmExtractLoc  );
    if ( !strcmp( BmExtractLoc, SF_TXT_MESHING ) )
    {
	if ( ElemType ) *ElemType = ElemTypeLoc;
	if ( NbFemElem ) *NbFemElem = NbFemElemLoc;
    }
    if ( ConvAllEl ) *ConvAllEl = ConvAllElLoc;

    return OM_S_SUCCESS;

}

end implementation Root;

