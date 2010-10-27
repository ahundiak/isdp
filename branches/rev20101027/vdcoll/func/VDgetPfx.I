class implementation Root;

/*
File :	VDgetPfx.I

Doc  :	This file contains functions which are used for getting a prefix
	for an object (VDgetPfxFromObjid) and for matching an object and
	prefix defintion ( VDmatchObjAndPfxDef ).
*/
#include <stdio.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "growner.h"

#include "vdpardef.h"
#include "vdparmacros.h"
#include "vdcolldef.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "vderrmacros.h"
#include "vdprdmacros.h"
#include "vdmemmacros.h"


extern  OMuword		OPP_VDdrawing_class_id,
			OPP_ACcpx_class_id;
long	VDmatchObjAndPfxdef();


from	NDmacro	     import   ACgive_structure;
from    ACcpx	     import   find_macro;
from    ACcpx_defn   import   ACgive_name;
from	ACrg_collect import   AClist_attribute;
from	ACrg_collect import   ACget_attribute_at_index;

/*+fe
Function :  VDgetPfxFromObjid

Abstract
  This function gets a prefix for an object. It gets prefix defintions
from prefix collector object and tries to match the object for each of
the definitions. Once the match is found, it returns the prefix defined
for the definition.

Arguments
  IGRlong		*msg		O    return status
  struct GRobj_env	*obj_env	I    object for which prefix
					     needs to be found.
  char			*objdef		O    definition of the object
					     memory provided by caller.
					     usually objdef[ATTR_NAME].
					     for ATTR_NAME see ACrg_collect.h.
  char			*pfx		O    prefix for the object.
					     memory provided by caller.

Notes

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

History
   11-03-1994  Raju   Creation
-fe*/
long  VDgetPfxFromObjid (
 long			*msg,
 struct GRobj_env	*obj_env,  /* I - objid and env */
 char			*objdef,   /* O - object definition */
 char			*pfx	   /* O - prefix  */
)
{
long			sts;
char			str[100], **DefList = NULL, **PfxList = NULL,
			def[80], filename[256], coll_name[15];
FILE			*fp = NULL;
int			nb_attr, ii, indx;
struct GRid		coll_id;
struct ACrg_coll	att;
IGRboolean		match;


 if ( !msg || !obj_env || !pfx || !def )
 {
    *msg = MSINARG;
    sts = OM_E_INVARG;
    goto wrapup;
 }

 sts = OM_S_SUCCESS;
 *msg = MSSUCC;
 strcpy( objdef, "" );
 strcpy( pfx, "" );

 /*
  * get collection id
  */
 strcpy ( coll_name, VD_PFXDEF_DIR_NAME );
 sts = VDgetVdCollId ( msg, coll_name, FALSE, FALSE, &coll_id );
 if ( sts&1 )
 {
     sts = om$send( msg = message ACrg_collect.AClist_attribute(
					msg,
					0,
					NULL,
					&nb_attr ),
			targetid = coll_id.objid,
			targetos = coll_id.osnum,
			senderid = NULL_OBJID );
     VDS_ERR_HNDLR("ACrg_collect.AClist_attribute",sts,*msg,VD_VERBOSE,wrapup);

     vd$malloc_str_list ( str_list = &DefList,
			  num_str  = nb_attr,
			  str_size = ATTR_NAME );

     vd$malloc_str_list ( str_list = &PfxList,
			  num_str  = nb_attr,
			  str_size = ATTR_TXT );

     for(ii=0; ii<nb_attr; ii++)
     {
	sts = om$send(msg = message ACrg_collect.ACget_attribute_at_index(
						msg, ii, &att ),
			targetid = coll_id.objid,
			targetos = coll_id.osnum,
			senderid = NULL_OBJID );
	VDS_ERR_HNDLR( "ACrg_collect.ACget_attribute_at_index", sts, *msg,
			VD_VERBOSE,  wrapup );
	strcpy( DefList[ii], att.name );
	strcpy( PfxList[ii], att.desc.value.att_txt );
     }
 }
 else
 {
   /*
    * collection does not exist
    * try to read from file
    */
    sts = vd$prd_get_product_info( run_name   = VD_PROD_NAME_VDS,
				   conf_path  = filename );

    strcat( filename, "/config/VDPfxDef" );

    if( !(fp = (FILE *) fopen( filename, "r") ) )
    {
	/* printf("Can not open [%s] for reading\n", filename); */
	goto wrapup;
    }

    nb_attr = 0;
    while ( fgets(str, 80, fp) )
    {
	indx = 0;
	while( str[indx] && isspace( str[indx] ) )  indx++;
	if ( str[indx] == '#' || str[indx] == '\0' ) continue;
	nb_attr++ ;
    }
    rewind ( fp );

    vd$malloc_str_list ( str_list = &DefList,
			 num_str  = nb_attr,
			 str_size = ATTR_NAME );

    vd$malloc_str_list ( str_list = &PfxList,
			 num_str  = nb_attr,
			 str_size = ATTR_TXT );

    nb_attr = 0;
    while ( fgets(str, 100, fp) )
    {
	indx = 0;
	while( str[indx] && isspace( str[indx] ) )  indx++;
	if ( str[indx] == '#' || str[indx] == '\0' ) continue;
	sscanf ( str, "%s %s", DefList[nb_attr], PfxList[nb_attr] );
	nb_attr++ ;
    }
 }


 for ( ii=0; ii<nb_attr; ii++)
 {
   strcpy( def, DefList[ii] );
   __DBGpr_int("Processing def no.", ii );
   __DBGpr_str("  Defintion", def );

   sts = VDmatchObjAndPfxdef ( msg, obj_env, def, &match );
   if ( !(sts&*msg&1) ) goto wrapup;
/*
  return status checking after macro writing
*/
   if ( match )
   {
	strcpy( objdef, def );
	strcpy( pfx, PfxList[ii] );
	goto wrapup;
   }

 } /* for ( ii=0; ii<nb_attr; ii++) */

 sts = OM_S_SUCCESS;
 *msg = MSSUCC;

wrapup:
 __DBGpr_str("def", objdef );
 __DBGpr_str("prefix", pfx );
 return sts;

}

/*+fe
Function :  VDmatchObjAndPfxdef

Abstract
  This function sees if an object and prefix defintion match. Returns TRUE
if matches else FALSE.

Arguments
  IGRlong		*msg		O    return status
  struct GRobj_env	*obj_env	I    object for which prefix
					     needs to be found.
  char			*def		I    definition of the object
  IGRboolean		*match		O    = TRUE if matching,
					     = FALSE if not.
Notes

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

History
   11-03-1994  Raju   Creation
-fe*/
long VDmatchObjAndPfxdef (
  long			*msg,
  struct  GRobj_env	*obj_env,
  char			*def,
  IGRboolean		*match
)
{
long			sts;
OMuword			obj_classid;
char			*ObjMacNm, DefMacNm[20],
			oprnt1[20], oprnt2[20];
int			indx, tmpIndx = -1, jj, oper;
struct ret_struct	rs;
struct GRid		macro_def;



 if ( !msg || !obj_env || !def || !match )
 {
    *msg = MSINARG;
    sts = OM_E_INVARG;
    goto wrapup;
 }

 sts = OM_S_SUCCESS;
 *msg = MSSUCC;
 *match = FALSE;

 /*
  * get macro name of object
  */
 sts = om$get_classid ( objid	  = obj_env->obj_id.objid,
			osnum	  = obj_env->obj_id.osnum,
			p_classid = &obj_classid );
 
 if(
	(om$is_ancestry_valid( subclassid = obj_classid,
			superclassid = OPP_VDdrawing_class_id )==OM_S_SUCCESS )
 )
 {
    sts = om$send( msg = message NDmacro.ACgive_structure(
					(int *)msg, &tmpIndx, "macro", &rs,
					&(obj_env->mod_env)  ),
		   targetid = obj_env->obj_id.objid,
		   targetos = obj_env->obj_id.osnum,
		   senderid = NULL_OBJID );
    VDS_ERR_HNDLR( "NDmacro.ACgive_structure", sts, *msg, VD_VERBOSE, wrapup);	
    strcpy( ObjMacNm, rs.var.macro_st.name );
 }
 else if ( om$is_ancestry_valid( subclassid = obj_classid,
			  superclassid = OPP_ACcpx_class_id ) == OM_S_SUCCESS )
 {
    sts = om$send(msg = message ACcpx.find_macro(&macro_def),
		  targetid = obj_env->obj_id.objid,
		  targetos = obj_env->obj_id.osnum,
		  senderid = NULL_OBJID );
    if(!(sts&1)) return OM_S_SUCCESS;

    sts = om$send(msg = message ACcpx_defn.ACgive_name( &ObjMacNm ),
		  targetid = macro_def.objid,
		  targetos = macro_def.osnum,
		  senderid = NULL_OBJID );
    if(!(sts&1)) return OM_S_SUCCESS;

 }
 else
 {
    /* not a macro */
    *msg = MSINARG;
    sts = OM_E_INVARG;
    goto wrapup;
 }
 __DBGpr_str("Macro name of object", ObjMacNm );

 /* get macro name from definition*/
 indx = 0;
 while ( def[indx] && !isspace(def[indx]) && (def[indx] != ':') )
 {
     DefMacNm[indx] = def[indx];
     indx++;
 }
 DefMacNm[indx] = '\0';

 __DBGpr_str("macro name from definition", DefMacNm);

 if ( !ASmatchRE(DefMacNm, ObjMacNm) ) goto wrapup;

 while ( def[indx] && isspace(def[indx]) ) indx++; /* skip space char */
 if ( !def[indx] )
 {
     *match = TRUE;
     goto wrapup;
 }

 if ( def[indx] == ':' )
 {
     indx++;
     while ( def[indx] && isspace(def[indx]) ) indx++; /* skip space char */
     if ( !def[indx] )
     {  *msg = MSINARG; sts = OM_E_INVARG; goto wrapup;
     }
 }

 /* process for the attributes */
 while ( 1 )
 {
     /* get operant1 */
     jj=0;
     while ( def[indx] && !isspace(def[indx]) &&
	     def[indx] != '=' && def[indx] != '!' &&
	     def[indx] != '<' && def[indx] != '>'    )
     {
	oprnt1[jj] = def[indx];
	indx++;
	jj++;
     }
     oprnt1[jj] = '\0';
     __DBGpr_str("oprnt1", oprnt1);

     while ( def[indx] && isspace(def[indx]) ) indx++; /* skip space char */
     if ( !def[indx] )
     {  *msg = MSINARG; sts = OM_E_INVARG; goto wrapup;
     }

     oper = VD_cnt_qry_EQUAL;
     switch( def[indx] )
     {
	case '=' :
	   oper = VD_cnt_qry_EQUAL;
	   break;

	case '!' :
	   oper = VD_cnt_qry_N_EQUAL;
	   indx++;
	   break;

	case '>' :
	   if ( def[indx+1] == '=' )
	   {
	     oper = VD_cnt_qry_G_EQUAL;
	     indx++;
	   }
	   else
	     oper = VD_cnt_qry_G_THAN;
	   break;
     
	case '<' :
	   if ( def[indx+1] == '=' )
	   {
	     oper = VD_cnt_qry_L_EQUAL;
	     indx++;
	   }
	   else
	     oper = VD_cnt_qry_L_THAN;
	   break;
     }
     __DBGpr_int("oper", oper);

     indx++;
     while ( def[indx] && isspace(def[indx]) ) indx++; /* skip space char */
     if ( !def[indx] )
     {  *msg = MSINARG; sts = OM_E_INVARG; goto wrapup;
     }

     /* get operant2 */
     jj=0;
     while ( def[indx] && !isspace(def[indx]) && def[indx] != ',' )
     {
	oprnt2[jj] = def[indx];
	indx++;
	jj++;
     }
     oprnt2[jj] = '\0';
     __DBGpr_str("oprnt2", oprnt2);

     sts = vd$query_on_attr( msg	= msg,
			     object	= obj_env,
			     operant1	= oprnt1,
			     operator	= oper,
			     operant2	= oprnt2  );

     if ( sts != OM_S_SUCCESS ) 
     {
	sts = OM_S_SUCCESS,
	*msg = MSSUCC;
	goto wrapup;
     }

     while ( def[indx] && isspace(def[indx]) ) indx++; /* skip space char */
     if ( !def[indx] )
     {
       *match = TRUE;
       goto wrapup;
     }

     if ( def[indx] == ',' )
     {
       indx++;
       while ( def[indx] && isspace(def[indx]) ) indx++; /* skip space char */
       if ( !def[indx] )
       {  *msg = MSINARG; sts = OM_E_INVARG; goto wrapup;
       }
     }
 } /* while (1) */

wrapup:
 return sts;

}


end implementation Root;
