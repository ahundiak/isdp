/* $Id: SMMain_fn.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        smstrsf/SMMain_fn.I
 *
 * Description:
 *
 *      This file implements functions useful for the management of the 
 *	main (or structural) surfaces.
 *
 * Dependencies:
 *
 *      Root
 *
 * Revision History:
 *	$Log: SMMain_fn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
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
# Revision 1.3  1996/04/29  09:20:10  pinnacle
# Replaced: smstrsf/imp/SMMain_fn.I for:  by ksundar for vds.240
#
# Revision 1.2  1996/01/23  06:43:52  pinnacle
# Replaced: smstrsf/imp/SMMain_fn.I for:  by rgade for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *      02/01/93        P. Lacroix      Creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;
 
 
#include <stdio.h>
#include "string.h"
#include "math.h"
#include "OMmacros.h"


#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "growner.h"
#include "parametric.h"
#include "exmacros.h"

#include "nddef.h"
#include "ndmacros.h"

#include "bstypes.h"
#include "bserr.h"
#include "bsmdistptsf.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "SMdef.h"
#include "SMmacros.h"

#include "SMStructSf.h"
#include "VDmem.h"


#include "AS_status.h"

/* Prototypes */
#include "bsmdistptsf.h"

#define	SMCalMnSfFlagExpName	":CALMNSFLAG"
#define	SMDspMnSfFlagExpName	":DSPMNSFLAG"

#define SMCALMSTON      1       /* Turn on      */
#define SMCALMSTOF      0       /* Turn off     */
#define SMCALMSTTG      2       /* Switch       */

from	expression	import	modify, create;
from	NDnode		import	NDget_objects, ASreturn_go, NDgive_structure;
from	GRvg		import	GRgenabsg, GRptdis;




 
/*+fi
 -------------------------------------------------------------------------
  Internal Function   SMIsPtOnSf

  Abstract

 	Function that returns if the given point lies on the surface.

	
  Notes/Remarks
 	md_env can be NULL if the surface is a source object because
	The function makes a return_go


  Returns

	1 if success
 	0 if fails.


 -------------------------------------------------------------------------
*/
int SMIsPtOnSf(point,surf,mod_env,tolerance,on_surface)

IGRdouble 	*point; 	/* I : point geometry                       */
struct GRid 	*surf; 		/* I : surf object                          */
struct GRmd_env *mod_env; 	/* I : env of the surface                   */
IGRdouble 	tolerance; 	/* I : min dist to be on surface            */
IGRint 		*on_surface;	/* O : 1 = the point is on surface (else 0) */
/*
-fi*/
{
IGRshort		mat_type;
IGRint			i, status;
IGRlong			msg;
IGRdouble		u,v,dist, base[3];
BSrc			rc;
IGRmatrix		matrix;
struct IGRbsp_surface	*surface;
struct GRid		go;

extern GRclassid OPP_GRowner_class_id;

surface = NULL;


if(surf == NULL || point == NULL || on_surface == NULL){
	printf("Invalid argument in SMIsPtOnSf\n");
	goto wrapup;
}

status = om$send(msg = message NDnode.ASreturn_go(&go,
                                &mat_type,
                                matrix),
			senderid = NULL_OBJID,
                        targetid = surf->objid,
                        targetos = surf->osnum ) ;
if(!(status & 1)) {
	if(mod_env == NULL){ 
		printf("Invalid argument in SMIsPtOnSf\n");
		goto wrapup;
	}
	go = *surf;
	mat_type = mod_env->md_env.matrix_type;
	for(i=0;i<16;i++) matrix[i] =  mod_env->md_env.matrix[i];
}
 
if(! SMIsKindOf(&go, OPP_GRowner_class_id) ){
	 status = om$send(msg = message GRvg.GRgenabsg(&msg,
                                &mat_type,
                                matrix, 
				(char **)&surface),
			senderid = NULL_OBJID,
                        targetid= go.objid,
                        targetos= go.osnum ) ;
 	if(!(status & msg & 1)) {
		printf("ERROR GRvg.GRgenabsg\n"); 
		goto wrapup;
	}
}

if(surface != NULL)
 	BSmdistptsf(&rc, surface, point, &u, &v, base, &dist);
if(surface == NULL || rc != BSSUCC){
	 	status = om$send(msg = message GRvg.GRptdis(&msg,
                                &mat_type,
                                matrix, 
				point, &dist),
			senderid = NULL_OBJID,
                        targetid= go.objid,
                        targetos= go.osnum ) ;
 		if(!(status & msg & 1)) {
			printf("ERROR GRvg.GRptdis\n"); 
			goto wrapup;
		}
}

if(dist <= tolerance) *on_surface = TRUE;
else *on_surface = FALSE;



return 1;

wrapup:
return 0;

}

 
/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMGetSurfPtIsOn

  Abstract

  	Function that returns the main surfaces on which the 
	given point is lying.

	We search all the main surfaces that are the given type 
	(deck, bulkhead ...) and we verify if the point is on one
	of them.

	surfaces is allocated by the function of nb_surf and must 
	be deallocated by the user.


  Returns

	1 if success
 	0 if fails.


 -------------------------------------------------------------------------
*/

int SMGetSurfPtIsOn(point,sftype,tolerance, nb_surf ,surf_id)

IGRdouble 	  *point;      /* I : point geometry                  */
IGRchar 	  *sftype;     /* I : type des surfaces               */
IGRdouble 	  tolerance;   /* I : min dist to be on surface       */
IGRint 		  *nb_surf;    /* O : nb of surfaces the point is on  */
struct GRobj_env  **surf_id;   /* O : surfaces object the point is on */
/*
-fi*/
{
int			i, count, onsf, status;
long			msg;
struct ACrg_coll	crit;
struct GRid		tmp_obj;
struct SMObjList	list;

list.list = NULL;
onsf = 0;

if(point == NULL || sftype == NULL || nb_surf == NULL || surf_id == NULL){
	printf("ERROR, Invalid Argument in SMGetSurfPtIsOn\n");
	goto wrapup;
}
*nb_surf = 0;
*surf_id = NULL;

crit.desc.type = AC_ATTRIB_TEXT;
strcpy(crit.desc.value.att_txt,sftype);
strcpy(crit.name,"surftype");

status = SM$CritSel(      options = SM_REF_FILE,
                          msg = &msg,
                          type = SM_SRF,
                          nb_crit = 1,
                          crit = &crit,
                          list = &list);
if(!(status&msg&1)){
	printf("ERROR SM$CritSel\n");
	goto wrapup;
}
if(list.nb_objects == 0) {
	_FREE(list.list);
	return 1;
}
*surf_id = _MALLOC(list.nb_objects, struct GRobj_env );
if(*surf_id == NULL){
	printf("ERROR bad allocation\n");
	goto wrapup;
}
for(i=0;i<list.nb_objects;i++){

 	status = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT ,&tmp_obj, 1 ,NULL, 1, 1,&count),
		   senderid = NULL_OBJID,
                   targetid = list.list[i].obj_id.objid,
		   targetos = list.list[i].obj_id.osnum);
	if(status != OM_S_SUCCESS) {
                printf("ERROR NDnode.NDget_objects\n");
                goto wrapup;
	}

	status = SMIsPtOnSf(point,&tmp_obj, (struct GRmd_env *)NULL,
				tolerance, &onsf);
	if(!(status&1)){
		printf("ERROR SMIsPtOnSf\n");
		goto wrapup;
	}
	if(onsf){
		(*surf_id)[*nb_surf].obj_id.objid = list.list[i].obj_id.objid;
		(*surf_id)[*nb_surf].obj_id.osnum = list.list[i].obj_id.osnum;
		(*surf_id)[*nb_surf].mod_env = list.list[i].mod_env;
		(*nb_surf) ++;
	}
}


_FREE(list.list);
return 1;

wrapup:
_FREE(*surf_id) ;
_FREE(list.list) ;
return 0;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMGetCalMnSfFlg

  Abstract

        This function returns the calculation flag for the main surface 
	It basically retrieves the expression "filename: CALMNSFLAG" and set
	CalFlg depending on its value. If the expression doesn't exists,
	CalFlg is set to FALSE.

  Returns

	1 if success
 	0 if fails.


 -------------------------------------------------------------------------
*/


SMGetCalMnSfFlg(CalFlg)
IGRboolean	*CalFlg;	/* True => one, FALSE => off	(O) */
/*
-fi*/
{
 IGRlong                status, loc_msg;
 IGRchar                ExpName[81];
 struct GRid            MyExpId;
 struct ret_struct	rt;

 /* Look if already existing */
 VDSget_filename(ExpName);
 strcat(ExpName, SMCalMnSfFlagExpName);

 status = di$translate(objname = ExpName,
              p_objid = &MyExpId.objid,
              p_osnum = &MyExpId.osnum);
 if(!(status&1))

  {
   *CalFlg = FALSE;
   return CALFLAG_NOTCREATED;
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

/*+fi
 -------------------------------------------------------------------------
  Internal Function   SMSetCalMnSfFlg

  Abstract

        This function sets the calculation flag for the main surface 
	depending on the given Type. 
	It basically creates or modify the expression
	"filename: CALMNSFLAG" and set the value 'y' or 'n'.

  Returns

	1 if success
 	0 if fails.


 -------------------------------------------------------------------------
*/
 

SMSetCalMnSfFlg(Type)
IGRshort	Type;	/* Operation type 	(I) */
/*
-fi*/
{
 IGRlong                status/*, loc_msg*/;
 IGRchar                ExpName[81], ExpValue[81];
 struct GRid            module, MyExpId;
 IGRshort		rc;
 extern GRclassid 	OPP_text_exp_class_id;

 /* Look if already existing */
 VDSget_filename(ExpName);
 strcat(ExpName, SMCalMnSfFlagExpName);

 status = di$translate(objname = ExpName,
              p_objid = &MyExpId.objid,
              p_osnum = &MyExpId.osnum);
 if(!(status&1))
  {
   /* The expression does not exist => create it */

   if(Type == SMCALMSTON || Type == SMCALMSTTG) strcpy(ExpValue, "y");
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

   return 1;
  }

 if(Type == SMCALMSTTG)
  {
   IGRboolean CurCalFlg;

   /* Get the current value */
   if(!(SMGetCalMnSfFlg(&CurCalFlg))) return 0;

   if(CurCalFlg) ExpValue[0] = 'n';
   else		 ExpValue[0] = 'y';
   ExpValue[1] = '\0';
  }
 else
  {
   if(Type == SMCALMSTON) ExpValue[0] = 'y';
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

/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMGetDspMnSfFlg

  Abstract

        This function returns the Display flag for the main surface 
	It basically retrieves the expression "filename: DSPMNSFLAG" and set
	DspFlg depending on its value. If the expression doesn't exists,
	DspFlg is set to FALSE.

  Returns

	1 if success
 	0 if fails.


 -------------------------------------------------------------------------
*/
 
SMGetDspMnSfFlg(DspFlg)
IGRboolean	*DspFlg;	/* True => one, FALSE => off	(O) */
/*
-fi*/
{
 IGRlong                status, loc_msg;
 IGRchar                ExpName[81];
 struct GRid            MyExpId;
 struct ret_struct	rt;

 /* Look if already existing */
 VDSget_filename(ExpName);
 strcat(ExpName, SMDspMnSfFlagExpName);

 status = di$translate(objname = ExpName,
              p_objid = &MyExpId.objid,
              p_osnum = &MyExpId.osnum);
 if(!(status&1))

  {
   *DspFlg = FALSE;
   return 1;
  }

 /* Get the current value */
 status = om$send(msg = message NDnode.NDgive_structure(&loc_msg, &rt, NULL),
 				senderid = NULL_OBJID,
				targetid = MyExpId.objid,
				targetos = MyExpId.osnum);
 if(!(status & loc_msg & 1)) return 0;
 if(rt.type != text_type) *DspFlg = FALSE;

 if(rt.var.text_st.text_string[0] == 'y' ||
    rt.var.text_st.text_string[0] == 'Y') *DspFlg = TRUE;
 else					  *DspFlg = FALSE;

 return 1;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMSetDspMnSfFlg

  Abstract

        This function sets the Display flag for the main surface 
	depending on the given Type. 
	It basically creates or modify the expression
	"filename: DSPMNSFLAG" and set the value 'y' or 'n'.

  Returns

	1 if success
 	0 if fails.


 -------------------------------------------------------------------------
*/

SMSetDspMnSfFlg(Type)
IGRshort	Type;	/* Operation type 	(I) */
/*
-fi*/
{
 IGRlong                status/*, loc_msg*/;
 IGRchar                ExpName[81], ExpValue[81];
 struct GRid            module, MyExpId;
 IGRshort		rc;
 extern GRclassid 	OPP_text_exp_class_id;

 /* Look if already existing */
 VDSget_filename(ExpName);
 strcat(ExpName, SMDspMnSfFlagExpName);

 status = di$translate(objname = ExpName,
              p_objid = &MyExpId.objid,
              p_osnum = &MyExpId.osnum);
 if(!(status&1))
  {
   /* The expression does not exist => create it */

   if(Type == SMCALMSTON || Type == SMCALMSTTG) strcpy(ExpValue, "y");
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

   return 1;
  }

 if(Type == SMCALMSTTG)
  {
   IGRboolean CurDspFlg;

   /* Get the current value */
   if(!(SMGetDspMnSfFlg(&CurDspFlg) & 1)) return 0;

   if(CurDspFlg) ExpValue[0] = 'n';
   else		 ExpValue[0] = 'y';
   ExpValue[1] = '\0';
  }
 else
  {
   if(Type == SMCALMSTON) ExpValue[0] = 'y';
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

end implementation Root;

