/* $Id: SMPerpFn.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smperp/imp / SMPerpFn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMPerpFn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
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
 	
      PL       FEV 1993  : Design date
 
 ABSTRACT : 
 
 	Implements Functions used for the SMPerp command

	1. SMSetRgAtt 
	2. SMGetRgAtt 
	3. SMGetExpDist 
	
 */
 
 class implementation Root;
 
 
#include <stdio.h>
#include "string.h"
#include "math.h"

#include "OMerrordef.h"
 
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "expression.h"
#include "expmacros.h"

#include "SMCsPp.h"

#include "AS_status.h"


 


from	NDnode  	import ASreturn_go, NDgive_structure;

 /*1 ====================== SMSetRgAtt =====================
 
 	Function that Fill the ACrg_coll with the given 
 	attributes.
	
	 
 	return 1 if OK
 	else 0.	
 */
 
 
 int	SMSetRgAtt(is_analysis, is_middle, is_drawing, AftName,MidName,
 		   ForName, DrwName, axis, ACrg)

IGRint 			is_analysis;  	/* (I) attr is_analysis */
IGRint 			is_middle;	/* (I) attr is_middle */
IGRint 			is_drawing; 	/* (I) attr is_drawing */
IGRchar 		*AftName; 	/* (I) attr AftName to be displayed*/
IGRchar 		*MidName; 	/* (I) attr MidName to be displayed*/
IGRchar 		*ForName; 	/* (I) attr ForName to be displayed*/
IGRchar 		*DrwName;	/* (I) attr DrwName */
IGRchar 		*axis;	        /* (I) attr axis */
struct ACrg_coll	*ACrg;		/* (O) output filled ACrg_collection */
{
 
 if(ACrg == NULL ){
 	printf("ERROR, Invalid argument\n");
 	return(0);
 }
 
 strcpy(ACrg[0].name,"is_analysis");
 ACrg[0].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[0].desc.value.att_exp= (IGRdouble) is_analysis;

 strcpy(ACrg[1].name,"is_middle");
 ACrg[1].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[1].desc.value.att_exp= (IGRdouble) is_middle;

 strcpy(ACrg[2].name,"is_drawing");
 ACrg[2].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[2].desc.value.att_exp= (IGRdouble) is_drawing;
 
 strcpy(ACrg[3].name,"AftName");
 ACrg[3].desc.type = AC_ATTRIB_TEXT;
 strncpy(ACrg[3].desc.value.att_txt, AftName,ATTR_TXT)[ATTR_TXT -1] = '\0';

 strcpy(ACrg[4].name,"MidName");
 ACrg[4].desc.type = AC_ATTRIB_TEXT;
 strncpy(ACrg[4].desc.value.att_txt, MidName,ATTR_TXT)[ATTR_TXT -1] = '\0';

 strcpy(ACrg[5].name,"ForName");
 ACrg[5].desc.type = AC_ATTRIB_TEXT;
 strncpy(ACrg[5].desc.value.att_txt, ForName,ATTR_TXT)[ATTR_TXT -1] = '\0';

 strcpy(ACrg[6].name,"DrwName");
 ACrg[6].desc.type = AC_ATTRIB_TEXT;
 strncpy(ACrg[6].desc.value.att_txt,DrwName,ATTR_TXT)[ATTR_TXT -1] = '\0';

 strcpy(ACrg[7].name,"axis");
 ACrg[7].desc.type = AC_ATTRIB_TEXT;
 strncpy(ACrg[7].desc.value.att_txt,axis,ATTR_TXT)[ATTR_TXT -1] = '\0';

return(1);
}

 /*2 ====================== SMGetRgAtt =====================
 
 	Function that Get the info in the ACrg_coll and fills 
 	the attributes.
	
	return 1 if ok 
 	else 0.	
	

 */
 
 
 int	SMGetRgAtt(ACrg, nb_att, is_analysis, is_middle, is_drawing, AftName, 
		   MidName, ForName, DrwName, axis)

struct ACrg_coll 	*ACrg;	      /* (I) where the info are taken */
IGRint			nb_att;	      /* (I) nb attributes in ACrg */
IGRint 			*is_analysis; /* (O) attr is_analysis */
IGRint 			*is_middle;   /* (O) attr is_middle */
IGRint 			*is_drawing;  /* (O) attr is_drawing */
IGRchar 		*AftName;     /* (O) attr AftName to be displayed*/
IGRchar 		*MidName;     /* (O) attr MidName to be displayed*/
IGRchar 		*ForName;     /* (O) attr ForName to be displayed*/
IGRchar 		*DrwName;     /* (O) attr DrwName */
IGRchar 		*axis;	      /* (O) attr axis */
{
long			status;
char			name[ATTR_TXT], text[ATTR_NAME];
IGRdouble		value;
 

/* Get the is_analysis */

if(is_analysis){
 	strcpy(name,"is_analysis");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, &value, NULL, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute is_analysis\n");
 		return(0);
 	}
 	*is_analysis = (IGRint) value;
}

/* Get the is_middle */

if(is_middle){
 	strcpy(name,"is_middle");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, &value, NULL, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute is_middle\n");
 		return(0);
 	}
 	*is_middle = (IGRint) value;
}

/* Get the is_drawing */

if(is_drawing){
 	strcpy(name,"is_drawing");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, &value, NULL, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute is_drawing\n");
 		return(0);
 	}
 	*is_drawing = (IGRint) value;
}


/* Get the AftName */

if(AftName){
 	strcpy(name,"AftName");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, NULL,text, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute AftName\n");
 		return(0);
 	}
 	strcpy(AftName, text);
}
/* Get the MidName */

if(MidName){
 	strcpy(name,"MidName");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, NULL,text, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute MidName\n");
 		return(0);
 	}
 	strcpy(MidName, text);
}

/* Get the ForName */

if(ForName){
 	strcpy(name,"ForName");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, NULL,text, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute ForName\n");
 		return(0);
 	}
 	strcpy(ForName, text);
}


/* Get the macro_name */

if(DrwName){
 	strcpy(name,"DrwName");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, NULL,text, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute DrwName\n");
 		return(0);
 	}
 	strcpy(DrwName , text);
 	
}

/* Get the axis */

if(axis){
 	strcpy(name,"axis");
	status = SMGetAttr(name, ACrg, NULL, nb_att, NULL, NULL,text, NULL);
 	if(!(status & 1)) {
 		printf("Fails to get the attribute axis\n");
 		return(0);
 	}
 	strcpy(axis, text);
 	
} 

return(1);
}



/*3 ====================== SMGetExpDist =====================
 
 	Function that Get the expressions of the AftDist and 
 	the ForeDist
	
	return 1 if ok 
 	else 0.	
	

*/

int	SMGetExpDist(obj1, obj2, AftDist, ForeDist, name1, name2)

struct GRid		*obj1;	  /* (I) the expression for AftDist */
struct GRid		*obj2;	  /* (I) the expression for ForeDist */
IGRdouble		*AftDist; /* (O) output AftDist */
IGRdouble		*ForeDist;/* (O) output ForeDist */
IGRchar			*name1;   /* (O) name of the exp for AftDist */
IGRchar			*name2;   /* (O) name of the exp for ForeDist */
{
IGRmatrix		matrix;
IGRshort		mat_type;
long			status, msg, loc_msg;
struct ret_struct	str;
struct GRmd_env		md_env;
struct GRid		go;

msg = OM_S_SUCCESS;

if( (AftDist != NULL && obj1 == NULL) || 
    (ForeDist != NULL && obj2 == NULL) ){
 	printf("ERROR, Invalid argument\n");
 	return(0);
}

if(AftDist && obj1 ){
	status = GetEnvFrObj(obj1, &md_env,NULL);
 	if(!(status & 1)) { msg = OM_E_ABORT; goto TEST2;}
 	status = om$send(msg = message NDnode.NDgive_structure(&loc_msg, &str, 
							&md_env),
			senderid = NULL_OBJID,
                        targetid = obj1->objid,
                        targetos = obj1->osnum);
        as$status();
 	if(!(status & loc_msg & 1)) return(0) ;

 	*AftDist = str.var.root_pm_st.value ;
}
if(name1 && obj1 ){
	status = om$send(msg = message NDnode.ASreturn_go(
                                          &go, &mat_type, matrix ),
				senderid = NULL_OBJID,
                                targetid = obj1->objid,
                                targetos = obj1->osnum );
	as$status();
	status = EXP_rec_untranslate(go.objid, go.osnum, name1);
 	if( (status != DIR_S_SUCCESS)&&(status != DIR_W_NAME_NOT_FOUND))
		 { di$report_error(sts = status) ; name1[0] = '\0';}

}
TEST2: 
if(ForeDist && obj2 ){

	status = GetEnvFrObj(obj2, &md_env,NULL);
 	if(!(status & 1)) return(0);
 	status = om$send(msg = message NDnode.NDgive_structure(&loc_msg, &str, 
							&md_env),
			senderid = NULL_OBJID,
                        targetid = obj2->objid,
                        targetos = obj2->osnum);
        as$status();
 	if(!(status & loc_msg & 1)) return(0) ;

 	*ForeDist = str.var.root_pm_st.value ;
}
if(name2 && obj2 ){
	status = om$send(msg = message NDnode.ASreturn_go(
                                          &go, &mat_type, matrix ),
				senderid = NULL_OBJID,
                                targetid = obj2->objid,
                                targetos = obj2->osnum );
	as$status();

	status = EXP_rec_untranslate(go.objid, go.osnum, name2);
 	if( (status != DIR_S_SUCCESS)&&(status != DIR_W_NAME_NOT_FOUND))
		 { di$report_error(sts = status) ; name2[0] = '\0';}

} 
if(msg == OM_E_ABORT) return(0);
return(1);

}

end implementation Root;

