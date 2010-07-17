class implementation GRvg ;

#include <stdio.h>
#include <math.h>
#include "vlprototype.h"
#include "madef.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "godef.h"
#include "grgsdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "comiscmac.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "ACattrib.h"
#include "parametric.h"
#include "bserr.h"
#include "vlglinedef.h"
#include "vsplatedef.h"
#include "vsstrngproto.h"
#include "vsmiscmacros.h"
#include "VDobj.h"
#include "bsbasisvect.h"
#include "bsbx2.h"
#include "bscveval.h"
#include "bsdotp.h"
#include "bsmdistptcv.h"
#include "bsnorvec.h"

#include "maidmx.h"
#include "mainvmx.h"
#include "mamulmx.h"
#include "VDmem.h"

from	ACcpx		import	find_macro;
from	ACcpx_defn	import	ACgive_name;
from	NDmacro		import	ACgive_structure;
from	GRreffile	import	GRgetenvironment;
from	EMSgenbs	import	EMplace_skinning_surface;
from	NDmacro		import	ACreturn_foot;

from    VSfeature       import  VSgetSupportedElements;
from    VSfeature       import  VSforwardToOriginal;

extern	GRclassid	OPP_GRgraphics_class_id;
extern	GRclassid	OPP_ACncpx_class_id;
extern	GRclassid	OPP_GRreffile_class_id;
extern	GRclassid	OPP_EMSgenbs_class_id;
extern	GRclassid	OPP_GR3dcircle_class_id;
extern	GRclassid	OPP_VSbeam_class_id;

extern	IGRdouble	fabs();

/* *********************** FCT VLswapObjEnv() ************************	*/

void VLswapObjEnv(list, fromA, toA)

struct	GRobj_env	list[];
int			fromA, toA;

{
struct	GRobj_env	tmp;

	tmp		= list[toA];			
	list[toA]	= list[fromA];
	list[fromA]	= tmp;
}

/* ***************** FCT VLfilterClass() ***********************	*/
/* Select objects of the given classid and its ancestry 
/*
/* */

void VLfilterClass (
int 			length,		/* I  : length of the input list */
struct	GRobj_env	list[],		/* IO : list of objects		 */
int			*count,		/* O  : new legth of the list	 */
GRclassid		cid		/* I  : classid to check	 */
)

{
int		i;
GRclassid	mcid;

	for( i=0, *count=0; i<length; i++ ){

		om$get_classid(	osnum	  = list[i].obj_id.osnum, 
				objid	  = list[i].obj_id.objid, 
				p_classid = &mcid );

		 if( om$is_ancestry_valid(
				subclassid	= mcid,
				superclassid	= cid ) == OM_S_SUCCESS ){

			VLswapObjEnv(list,i,(*count)++);
		}
	}
}

/* **************** FCT VLfilterLevel() ************************	*/
/* Select objects with the given level 
/*
/* */

void VLfilterLevel(

int 			length,		/* I  : length of the input list */
struct	GRobj_env	list[],		/* IO : list of objects		 */
int			*count,		/* O  : new legth of the list	 */
short			level		/* I  : Level to check		 */
)

{
int			i;
long			sts, msg;
struct	GRsymbology	symb;

	for( i=0, *count=0; i<length; i++ ){

		sts = om$send ( msg	 = message GRvg.GRgetsymb
							( &msg, &symb ),
				targetid = list[i].obj_id.objid,
				targetos = list[i].obj_id.osnum,
				senderid = NULL_OBJID );
		if( ! (sts&1))	continue;

		if( symb.level == level ){
			VLswapObjEnv(list,i,(*count)++);
		}
	}
}

/* **************** FCT VLfilterProps() ************************	*/
/* Select objects according to the given mask 
/*
/* */

void VLfilterProps(
int 			length,		/* I  : length of the input list */
struct	GRobj_env	list[],		/* IO : list of objects		 */
int			*count,		/* O  : new legth of the list	 */
short			mask		/* I  : mask of properties	 */
)

{
int			i;
long			sts, msg;
short			mprop;

	for( i=0, *count=0; i<length; i++ ){

		sts = om$send ( msg	 = message GRvg.GRgetprops
							( &msg, &mprop ),
				targetid = list[i].obj_id.objid,
				targetos = list[i].obj_id.osnum,
				senderid = NULL_OBJID );
		if( ! (sts&1))	continue;

		if( mprop & mask ){
			VLswapObjEnv(list,i,(*count)++);
		}
	}
}

/* **************** FCT VLfilterDef() ********************************	*/
/* Select objects according to the given macro definition name.
/* This function support regular expression in the definition of the name
/*
/* */

void VLfilterDef(length, list, count, defName)

int 			length;		/* I  : length of the input list */
struct	GRobj_env	list[];		/* IO : list of objects		 */
int			*count;		/* O  : new legth of the list	 */
char*			defName;	/* I  : Macro definition	 */

{
int			i;
struct	GRid		def;
char			*name;
long			sts;

	for( i=0, *count=0; i<length; i++ ){
		def.objid = NULL_OBJID;
		sts = om$send(	msg	 = message ACcpx.find_macro( &def ),
				targetid = list[i].obj_id.objid,
				targetos = list[i].obj_id.osnum,
				senderid = NULL_OBJID );
		if( ! (sts&1) || def.objid == NULL_OBJID )	continue;

		sts = om$send(	msg	 = message ACcpx_defn.ACgive_name
						( &name ),
				targetid = def.objid,
				targetos = def.osnum,
				senderid = NULL_OBJID );
		if( ! (sts&1))	continue;

		if( VSmatchRE(defName, name) ){
			VLswapObjEnv(list,i,(*count)++);
		}
	}
}

/* **************** FCT VLfilterName() ***********************		*/
/* Select objects according to the given name.
/* This function support regular expression in the definition of the name
/*
/* */

void VLfilterName(length, list, count, name)

int 			length;		/* I  : length of the input list */
struct	GRobj_env	list[];		/* IO : list of objects		 */
int			*count;		/* O  : new legth of the list	 */
char*			name;		/* I  : Object name 		 */

{
int			i;
GRname			objName;
long			sts, msg;

	for( i=0, *count=0; i<length; i++ ){

		sts = om$send(	msg	 = message GRgraphics.GRgetname
					( &msg, objName ),
				targetid = list[i].obj_id.objid,
				targetos = list[i].obj_id.osnum,
				senderid = NULL_OBJID );
		if( ! (sts&msg&1))	continue;

		if( VSmatchRE(name, objName) ){
			VLswapObjEnv(list,i,(*count)++);
		}
	}
}

/* **************** FCT VLfilterAttr() *******************************	*/
/* Select objects wich match with attribut definition.
/*	attribute definition is a couple (name, value)
/* */

void VLfilterAttr(length, list, count, attr)

int 			length;		/* I  : length of the input list */
struct	GRobj_env	list[];		/* IO : list of objects		 */
int			*count;		/* O  : new legth of the list	 */
struct	ACrg_coll	*attr;		/* I  : attribut definition	 */

{
int			i;
long			sts;
int			msg;
struct	ret_struct	str;

	for( i=0, *count=0; i<length; i++ ){

		sts = om$send(	msg	 = message NDmacro.ACgive_structure(
						&msg,
						NULL,
						attr->name,
						&str,
						NULL ),
				targetid = list[i].obj_id.objid,
				targetos = list[i].obj_id.osnum,
				senderid = NULL_OBJID );
		if( ! (sts&msg&1))	continue;

		if( ! (str.type & parameter_generic))	continue;

		if( (str.type == double_type) && 
					(attr->desc.type == AC_ATTRIB_DOUBLE)){
			if( fabs(str.var.root_pm_st.value - 
					attr->desc.value.att_exp) < 0.001 ){
				VLswapObjEnv(list,i,(*count)++);
			}
			continue;
		}

		if( (str.type == text_type) && 
					(attr->desc.type == AC_ATTRIB_TEXT)){
			if( ! strcmp(str.var.text_st.text_string,
					attr->desc.value.att_txt )){
				VLswapObjEnv(list,i,(*count)++);
			}
			continue;
		}
	}
}

/* **************** FCT VLfilterDefAttrName() ************************	*/
/* Select objects witch macro definition define the attribute.
/*
/* */

void VLfilterDefAttrName(length, list, count, attrName)

int 			length;		/* I  : length of the input list */
struct	GRobj_env	list[];		/* IO : list of objects		 */
int			*count;		/* O  : new legth of the list	 */
char			*attrName;	/* I  : attribut definition	 */

{
int		i;
char		footName[DI_PATH_MAX];

	for( i=0, *count=0; i<length; i++ ){

		if( VLgetOperName("",&list[i].obj_id,attrName,footName) & 1){

			VLswapObjEnv(list,i,(*count)++);
		}
	}
}

/* **************** FCT VLfilterDefAttrValue() ************************	*/
/* Select objects which macro definition define the attribute.
/*
/* */

void VLfilterDefAttrValue(length, list, count, attrName, attrVal )

int 			length;		/* I  : length of the input list */
struct	GRobj_env	list[];		/* IO : list of objects		 */
int			*count;		/* O  : new legth of the list	 */
char			*attrName;	/* I  : attribut definition	 */
char			*attrVal;	/* I  : attribut Value		 */

{
int		i;
GRname		footName;

	for( i=0, *count=0; i<length; i++ )
		if( VLgetOperName("",&list[i].obj_id,attrName,footName) & 1)
			if( ! strcmp( footName, attrVal ))
				VLswapObjEnv(list,i,(*count)++);

}

/* ************************ FCT VLfilterGeometry() *******************	*/

void VLfilterGeometry(

int			length,
struct	GRobj_env	*list,
int			*count,
long			(*fctCheck)(),
char			*p_args )

{
int	i;
long	sts;

	for( i=0, *count=0; i<length; i++ ){

		sts = (long)fctCheck(&list[i],p_args);

		if( sts & 1 )	VLswapObjEnv(list,i,(*count)++);
	}
}
/* ========================================================================== */

/* ======================== FCT VLfilterFootName() ========================== */

void    VLfilterFootName (              IGRint          length,
                                struct  GRobj_env       list[],
                                        IGRint          *count,
                                        IGRchar         *footname       )
{
                IGRint  i, sts;
                IGRlong msg;
        struct  GRid    foot_id;

        for ( i=0, *count=0; i<length; i++) {

                sts = om$send ( msg = message NDmacro.ACreturn_foot
                                ( &msg, footname, &foot_id, NULL, NULL ),
                                senderid = NULL_OBJID,
                                targetid = list[i].obj_id.objid,
                                targetos = list[i].obj_id.osnum );
                if (sts & 0x00000001 & msg)
                        VLswapObjEnv ( list, i, (*count)++);
        }
}
// The intention is to filter all the plate objects
void VLfilterStiff (
int 			length,		/* I  : length of the input list */
struct	GRobj_env	list[],		/* IO : list of objects		 */
int			*count		/* O  : new legth of the list	 */
)

{
int		i;
struct GRid 	parent;

   for( i=0, *count=0; i<length; i++ ){
	parent.objid = NULL_OBJID; 
	// input is a list of markings - get the second parent and see if its a plate
  	vdobj$GetParent(objOE = &list[i], idx = 2, parentID = &parent );
  	if (parent.objid == NULL_OBJID) {
    	     UI_status("Can't find marking parent\n");
    	     goto wrapup;
  	}

	if( vs$is_ancestry_valid( object  = &parent,
				  classid = OPP_VSbeam_class_id )) {
		VLswapObjEnv(list,i,(*count)++);
		}
	}

wrapup:
return;
}
/* ========================================================================== */

/* **************** FCT VLfilterCloser() **********************	*/

/* **************** FCT VLfilterMinDist() *********************	*/

end implementation GRvg ;

