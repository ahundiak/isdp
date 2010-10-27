/* $Id: SMfunct.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smutil/func / SMfunct.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMfunct.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  17:54:32  pinnacle
# Fixed warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.3  1996/09/20  20:14:38  pinnacle
# Replaced: smutil/func/SMfunct.I for:  by jwfrosch for vds.241
#
# Revision 1.2  1996/09/20  19:31:36  pinnacle
# Replaced: smutil/func/*.I for:  by jwfrosch for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/17  14:56:34  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
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
 *	10/30/97	ah		Uninitialized ref in SMGetAllDrw
 *					This may actually have been a bug
 * -------------------------------------------------------------------*/

/* 	Usefull Functions 	*/
/*
/*	1.  GetEnvFrObj
/*	2.  GetDefName
/*	3.  SMGetCompFromDrw  (PL Nov 93)
/*	4.  SMGetGraphDrw
/*	5.  SMGetListObj
/*	6.  SMGetAllDrw
/*	7.  SMIsInCompt2D 
/*	8.  SMIsInCompt 
/*	9.  VDGetCsFromEq 
/*	10. SMPtInsideCv
/*	11. SMPtInsideSf
/*	12. SMGetAdjCompart
/*	13. SMGetInAdjCmpt
/* 	14. SMGetConxCmpt
/* 	15. SMGetConxCmpt2D
/*      History
/*      June 93 : Jean -  GetDefName, if name is terminated by a number,
/*	                  increment it.
/* */
class implementation Root;

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <ctype.h>
#include "math.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "grdpb.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "gr.h"
#include "ctype.h"
#include "go.h"
#include "growner.h"
#include "gomacros.h"
#include "msdef.h"
#include "parametric.h"

#include "EMSconstruct.h"
 
#include "exdef.h"
#include "exmacros.h" 
#include "nddef.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "SMdef.h"
#include "SMmacros.h"
#include "asbox.h"
#include "VDmem.h"

#include "AS_status.h"

/* Prototypes */

#include "bstypes.h"
#include "bserr.h"
#include "bsptinbx.h"
#include "bsprptonsf.h"
#include "bspt_in_cv.h"
#include "bsptoldtnw.h"
#include "bscvoton.h"
#include "bscvnormal.h"
#include "bstrans2.h"
#include "bsbxint.h"

/*#define	TIME1	1*/

#define FAIL	10
#define INCR	10


#define ALWAYS_INCREMENT 1 /* If this flag is set, when name is a complete
			      number, name will increment. 
			      Else will add _number                    */


struct VDlist{

	int	nb_cc;
	int	size;
	struct GRid *cc;
};


from 	OMObjSpace	import  pass;
from 	EMSsolid	import  EMpoint_locate;
from 	NDnode		import  NDgive_structure,NDget_objects, ASreturn_go;
from	SMmgr		import	SMGetAttTxt,SMGetAttDbl;
from	NDmacro		import	ACreturn_foot;
from	GRgraphics	import	GRfunction, GRptproject, GRgetrang;
from   	GRvg		import	GRgetsize, GRgetgeom;

extern GRclassid 	OPP_GRlbsys_class_id;
extern GRclassid       	OPP_SMcomp_class_id, OPP_VDdrawing_class_id,
			OPP_EMSplane_class_id,	OPP_AScompcurve_class_id;


/* ------------------------------------------------------------------
 *  Given an associative object, retrieve the graphic and mod_env 
 *  associated with the object 
 *  Return 0 if problem and 1 if OK */

int GetEnvFrObj(as_obj,env, go)

struct GRid 	*as_obj;	/* [I] the associative object */
struct GRmd_env *env;		/* [O] the md_env return     */
struct GRid 	*go;		/* [O] the graphic object */
{
  IGRlong 		status;
  struct GRid		obj;
  struct GRmd_env  	my_env;

  if(as_obj == NULL){
  	printf("ERROR, Invalid Argument\n");
  	return(0);
  }
  if(go) go->objid = NULL_OBJID;	
    
  status = om$send(msg = message NDnode.ASreturn_go(&obj,
						    &my_env.md_env.matrix_type,
						    my_env.md_env.matrix),
		   senderid = NULL_OBJID,
		   targetid = as_obj->objid,
		   targetos = as_obj->osnum);
  
  if(!(status & 1))   return 0;
  if(go != NULL) {
  	go->objid = obj.objid;
  	go->osnum = obj.osnum;
  }
  if(env != NULL){
  	my_env.md_id.osnum = obj.osnum;
  	status =ex$get_modid(mod_osnum = my_env.md_id.osnum,
		       mod_id =    &my_env.md_id.objid);
  	if(status != 1)
   	{
     	printf("Error get mod_id\n");
     	return 0;
   	}
   	*env = my_env;
  }
  
  return 1;
}   


/* Given a base name , gener a default name (adding "_" number if needed)     */
/* This default name is : if base_name is not ending with number, add _number */
/* if base name is ending with a number, replace this number by number + 1    */
/* If the base name is empty, return the base name                            */

void GetDefName(base_name,def_name)
char *base_name; /* [I] */
char *def_name; /* [O]  */
{
  struct GRid tmp_obj;
  char        *pt;     
  IGRlong     status;
  int         i = 0, num_obj = 0;

  if(!base_name || !def_name) return;

  strcpy(def_name,base_name);
  if(base_name[0] == '\0') return ;

  status = di$translate(objname =  def_name,
                        p_objid = &tmp_obj.objid);
  if(status == DIR_S_SUCCESS)
   {
     pt = strrchr(def_name,'_');
     if(pt == NULL || isalpha( *(pt+1) ))
      {
        pt = def_name + strlen(base_name);
	if(isdigit(*(pt -1)))
	 {
	   /* Look for all number in reverse */
	   while((pt !=  def_name) && isdigit(*(pt-1))) pt--;
	   /* pt point now on the first digit char */

	   /* If character is a number, add one to old number, else 0 */
	   if(sscanf(pt,"%d",&num_obj) != 1) num_obj = 0;

#ifndef ALWAYS_INCREMENT
	   if(pt == def_name) /* name is a complete number ,add _ with this opt*/
	    {
	      pt = def_name + strlen(base_name) ;
	      *pt = '_';
	      *pt++;
	      num_obj = 0;
	    }
#endif
	 }
	else
	 {
	   *pt = '_'; /* Non digit, add _1 and generate default with */
	   pt++;
	   num_obj = 0;
	 }
      }
     else 
      {
	pt++;
	if(sscanf(pt,"%d",&num_obj) != 1) num_obj = 0;
      }
    
     num_obj++;

     while(i < 10000) /* To avoid infinite loop */
      {
        sprintf(pt,"%d",num_obj);
        status = di$translate(objname =  def_name,
                              p_objid = &tmp_obj.objid);
        if(status != DIR_S_SUCCESS) break;
	i++;
	num_obj++;
      }
   }
}


/* ============================================================
	
	The function retrieve the compartment object that is
	connected to the given drawing object.
 
	return 1 if ok 
 	else 0.	
*/

int SMGetCompFromDrw(
	struct GRid	*obj,		/* (I) input drawing      */
	struct GRid	*compart,	/* (O) returned compart   */
	struct GRmd_env *cmp_env	/* (O) env of the compart */
)
{
int 		i, nb_roots, status;
struct GRid	go, *roots;
struct GRmd_env	md_env;

if(obj == NULL || compart == NULL) goto wrapup;
compart->objid = NULL_OBJID;

status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF, NULL, 0,
					&roots, 0, OM_K_MAXINT, &nb_roots),
		senderid = NULL_OBJID,
        	targetid = obj->objid,
		targetos = obj->osnum);
as$status();
if(!(status&1) ){
	printf("ERROR NDget_objects\n");
	goto wrapup;
}

for(i=0;i<nb_roots;i++){
	status = GetEnvFrObj(&roots[i], &md_env, &go);
	if(!(status & 1)){
        	printf("ERROR GetEnvFrObj\n");
        	goto wrapup;
	}

	if(SMIsKindOf(&go, OPP_SMcomp_class_id)){
		compart->objid = go.objid;
		compart->osnum = go.osnum;
		if(cmp_env) *cmp_env = md_env;
		break;
	}

}


return 1;

wrapup:
return 0;

}

/* ===============================================================

	The function returns the list of all the graphic objects
        defining the drawing that are composite curve or plane 
	(feet of VDgeom) 
 
	graphics is allocated by the function and must be deallocated
	by the user.

	return 1 if ok 
 	else 0.	

*/

int SMGetGraphDrw(
	struct GRid	*obj,		/* (I) input drawing 		*/
	int		*nb_graphic,	/* (O) nb of graphic foot	*/
	struct GRid	**graphics	/* (O) graphic foot 		*/
)
{
int			i, status;
OMuint			count, ssize;
OM_S_OBJECT_LINKAGE	*list;
IGRlong			loc_msg;
struct GRmd_env		md_env;
struct GRid		component, geom;

if(nb_graphic) *nb_graphic = 0;
if(graphics)   *graphics = NULL;
 
list = NULL;
status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"geom",
                                &geom, &md_env.md_env.matrix_type,
				md_env.md_env.matrix),
		   senderid = NULL_OBJID,
		   targetid = obj->objid,
		   targetos = obj->osnum);
if(!(status & loc_msg & 1)) {
	printf("ERROR NDmacro.ACreturn_foot geom\n");
	goto wrapup;
}

status = om$get_channel_count(  objid = geom.objid,
				osnum = geom.osnum,
				p_chanselect = &AS_to_comp,
				count = &ssize );

if (!(status&1)){ 
		printf("ERROR om$get_channel_count\n");
		om$report_error(sts=status); 
		goto wrapup; 
} 
if(ssize == 0 ) goto success;
list=_MALLOC(ssize ,OM_S_OBJECT_LINKAGE);
if(list == NULL)
	{printf("bad alloc of list\n");  goto wrapup; }
status = om$get_channel_objects(
			objid		= geom.objid,
			osnum		= geom.osnum,
			p_chanselect	= &AS_to_comp,
			size		= ssize,
			list		= list ,
			count 		= &count) ;


if(!(status & 1)) {
		printf("ERROR om$get_channel_object\n");
		om$report_error(sts=status); 
		goto wrapup; 
} 
ssize = 0;
if(graphics || nb_graphic){
	if(graphics){
		(*graphics)=
		   _MALLOC(count,struct GRid);
		if( (*graphics) == NULL)
			{printf("bad alloc of graphics\n");
				 goto wrapup; }

	}
	for(i=0;i<count;i++){
		component.objid = list[i].S_objid;
		component.osnum = list[i].osnum;

		if(! SMIsKindOf(&component, OPP_EMSplane_class_id) &&
		   ! SMIsKindOf(&component, OPP_AScompcurve_class_id) ) continue;

		if(graphics) {
			(*graphics)[ssize].objid = component.objid;
			(*graphics)[ssize].osnum = component.osnum;
			ssize ++;
		}
	}
	if (nb_graphic) (*nb_graphic) = ssize;
}

success:
_FREE(list); 
_FREE(*graphics); 

return 1;

wrapup:

_FREE(list); 
return 0;


}

/* ====================== SMGetListObj ============================
 
	The function adds the GRid of the object in the list if
	the object is a VDdrawing of a compart.
 
	info.cc is allocated by the function and must be deallocated 
	by the user

	return 1 if ok 
 	else 0.	
*/

int	SMGetListObj(
	long		*msg,		/* (O) completion code 	*/
	struct GRid	*obj,		/* (O) list of object 	*/
	struct GRfunction_info	*f_info /* (O) info 		*/
)
{
int			size, status;
IGRlong			loc_msg;
struct VDlist		*info=NULL;
struct GRmd_env		md_env;
struct GRid		mac;
struct ret_struct	rst;

if(! SMIsKindOf(obj, OPP_VDdrawing_class_id)) return 1;

status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"macro",
                                &mac, &md_env.md_env.matrix_type,
				md_env.md_env.matrix),
		   senderid = NULL_OBJID,
		   targetid = obj->objid,
		   targetos = obj->osnum);
if(!(status & loc_msg & 1)) return 1;

md_env.md_id.osnum = mac.osnum;
ex$get_modid( 	mod_osnum = md_env.md_id.osnum ,
		mod_id = &md_env.md_id.objid);

status = om$send(msg = message NDnode.NDgive_structure(&loc_msg,&rst,
                                &md_env),
		   senderid = NULL_OBJID,
		   targetid = mac.objid,
		   targetos = mac.osnum);
if(!(status & loc_msg & 1)) return 1;
if(rst.type != text_type) return 1;

if(strcmp(rst.var.text_st.text_string,"SMcomp") ) return 1;

info = (struct VDlist *)f_info->info;
if(info->nb_cc + 1 >= info->size){
	size = info->size + INCR;
	if(info->size == 0){
        	/*"Allocation of: %d Objects\n", size */
        	info->cc = 
		     _MALLOC(size,struct GRid);
	}
     	else{
        	/*"Reallocation of: %d Objects (old size: %d\n", size, info->size */
        	info->cc = 
		   _REALLOC(info->cc, size,struct GRid );
	}
	if(info->cc == NULL){
        	printf("Error in ISvalid_cc, no memory space available\n");
        	info->size  = 0;
        	info->nb_cc = 0;
        	*msg        = FAIL;
        	return 0;
      	}
     	/*"allocated address: %u\n",info->cc */
     	info->size = size;
}

info->cc[info->nb_cc++] = *obj;

*msg  = MSSUCC;
return 1;


}


/* ====================== SMGetAllDrw =============================
 
	the function retrieve all the VDdrawing objects in the 
	design file that are the drawing of a compartment.


	obj is allocated by the function and must be deallocated
	by the user.

	return 1 if ok 
 	else 0.	

*/

int SMGetAllDrw(
	int		*nb_obj, /* (O) nb object VDdrawing in design */
	struct GRid	**obj    /* (O) the VDdrawing objects         */
)
{
int			status;
IGRlong			msg;
OM_S_CLASSLIST         	clist;
OMuword                	classes;
struct  GRid            mod_id, *cc;
struct	VDlist		sel;
struct GRfunction_info  f_info;



classes         = OPP_VDdrawing_class_id;
clist.w_count   = 1;
clist.w_flags   = OM_CLST_subclass;
clist.p_classes = &classes;

ex$get_cur_mod( id = &mod_id.objid, osnum = &mod_id.osnum );

sel.nb_cc     = 0;
sel.size      = 0;

/* -----------------------------------------
 * 30 Oct 1997, original code was just this
 * sel.cc = cc;
 * cc was never initialized
 * warning was being ignored
 * wrapup frees sel.cc if it is not NULL
 * Set cc to NULL here and let it go for now
 */
cc = NULL;
sel.cc = cc;
  
go$build_user_function_buffer(buffer    = &f_info,
                                 your_info = &sel);


status = om$send( msg = message OMObjSpace.pass(&clist,OM_e_wrt_object,
                         message GRgraphics.GRfunction(&msg, SMGetListObj,
                                                (char *) &f_info)),
                         senderid = NULL_OBJID,
                         targetid = OM_GO_current_OS_objid,
                         targetos = mod_id.osnum);
as$status(action = RET_STATUS);
if(msg == FAIL){
	printf("Problem in SMGetListObj\n");
	return (0);
}
if(sel.nb_cc == 0) goto quit;


*nb_obj = sel.nb_cc;
(*obj) = sel.cc;

return(1);

quit:
if(sel.nb_cc && sel.cc){free(sel.cc);sel.cc = NULL;}
return(1);


}
 
/* ====================== SMIsInCompt2D =================================
 
 	Function that returns in which compartment drawing the element is
	in (cog in the compart drawing range)

	If Compart is pseudo, or hull_compart don't take it if no_pseudo=1
	or no_hull = 1.


	return 1 if ok 
 	else 0.	
	

*/
 
 
int SMIsInCompt2D(obj, obj_env, no_pseudo, no_hull, cmp_id, cmp_name, nb_list, totlist)
struct GRid	  *obj;  	/* [I] : object to test                    */
struct GRmd_env	  *obj_env;  	/* [I] : object env                        */
int		  no_pseudo;    /* [I] : 1 if pseudo not wanted            */
int		  no_hull;      /* [I] : 1 if hull not wanted              */
struct GRid       *cmp_id; 	/* [O] compartment in which is the object  */
IGRchar		  *cmp_name;	/* [O] compart name                        */
IGRint		  *nb_list;	/* [O] nb compart in the list              */
struct GRid       **totlist; 	/* [O] compartment list containing the obj */
{
int			i, k, count, nb_drawing, nb_graphics,
			inside, status;
long			msg, sizbuf, nret;
IGRchar			tpipo[81];
IGRboolean		found, world;
IGRdouble		volume1, volume2, cog[3];
struct GRmd_env		cur_env;
struct GRid		compart, *graphics, *drawing, *x_cmp, dummy_cmp;
GRrange			range;

#ifdef TIME1
	long	t, t1, t2;
	t1=clock();
	printf("t1: %d\n",t1);
#endif


nb_graphics = 0;
nb_drawing = 0;
drawing = NULL;
graphics = NULL;
dummy_cmp.objid = NULL_OBJID;

if(totlist) (*totlist) = NULL;
if(nb_list) *nb_list = 0;

if(cmp_id) x_cmp = cmp_id;
else 	   x_cmp = &dummy_cmp;

if(cmp_name) cmp_name[0] = '\0';

sizbuf = sizeof(struct GRmd_env );
gr$get_module_env(      msg = &msg,
                        sizbuf = &sizbuf,
                        buffer = &cur_env,
                        nret = &nret);



/* compute the cog of the object */

world = TRUE;
status = om$send(msg = message GRgraphics.GRgetrang(&msg,
                                &obj_env->md_env.matrix_type,
                                obj_env->md_env.matrix,
                                &world,
                                range),
                        senderid = NULL_OBJID,
                        targetid = obj->objid,
                        targetos = obj->osnum );
if(!(status & 1)){
        	as$status();
        	printf("ERROR GRgraphics.GRgetrange\n");
        	goto wrapup;
}
for(i=0;i<3;i++) cog[i] = (range[i] + range[i+3])/2;

/* Get the list of all VDdrawing */

status = SMGetAllDrw(&nb_drawing, &drawing);
if(!(status&1) ){
	printf("ERROR SMGetAllDrw\n");
	goto wrapup;
}

if(totlist){
	(*totlist) = _MALLOC(nb_drawing,struct GRid);
	if(!(*totlist)){
		printf("Bad allocation\n");
		goto wrapup; 
	}
}

count = 0;
found = FALSE;

for(i=0;i<nb_drawing;i++){

	if(graphics){_FREE(graphics); graphics = NULL;}
	status = SMGetGraphDrw(&drawing[i], &nb_graphics, &graphics);
	if(!(status&1) ){
		printf("ERROR SMGetGraphDrw\n");
		goto wrapup; 
	}
	inside = 0;
	for(k=0;k<nb_graphics;k++){

		/* look if cog is in one graphics */

		if(SMIsKindOf(&graphics[k], OPP_EMSplane_class_id)){
			status = SMPtInsideSf(cog, NULL, &graphics[k], 
				&cur_env, &inside);
			if(!(status&1) ){
				printf("ERROR SMPtInsideCv\n");
				goto wrapup; 
			}
			if(inside) break;
		}
		else if(SMIsKindOf(&graphics[k], OPP_AScompcurve_class_id)){
			status = SMPtInsideCv(cog, NULL, &graphics[k], 
				&cur_env, &inside);
			if(!(status&1) ){
				printf("ERROR SMPtInsideCv\n");
				goto wrapup; 
			}
			if(inside) break;

		}
	}	
	if(inside ){

		status = SMGetCompFromDrw(&drawing[i], &compart, NULL);
		if(!(status&1) || compart.objid == NULL_OBJID){
			printf("ERROR SMGetCompFromDrw\n");
			goto wrapup;
		}

		/* if compartment is a pseudo, forget it */

		status = om$send(msg = message SMmgr.SMGetAttTxt(&msg,
                                "pseudo", tpipo, NULL),
                        senderid = NULL_OBJID,
                        targetid = compart.objid,
                        targetos = compart.osnum );
		if(!(status & msg & 1)) tpipo[0] = '\0';
		if( no_pseudo && tpipo[0] != 'n') continue;

		/* if compartment is a compartment hull, forget it */

		status = om$send(msg = message SMmgr.SMGetAttTxt(&msg,
                                "comp_type", tpipo, NULL),
                        senderid = NULL_OBJID,
                        targetid = compart.objid,
                        targetos = compart.osnum );
		if(!(status & msg & 1)) tpipo[0] = '\0';
		if( no_hull && tpipo[0] == 'h') continue;

		if(totlist) (*totlist)[count ++] = compart;

		if(!found){
			
			status = om$send(msg = message SMmgr.SMGetAttDbl(&msg,
                                "volume", &volume1, NULL),
                        		senderid = NULL_OBJID,
                        		targetid = compart.objid,
                        		targetos = compart.osnum );
			if(!(status & 1)){
        			as$status();
        			printf("ERROR SMmgr.SMGetAttDbl\n");
        			goto wrapup;
			}
			x_cmp->objid = compart.objid;
			x_cmp->osnum = compart.osnum;

			found = TRUE;
			continue;
		}

		/* keep the compart with the minimun volume */

		status = om$send(msg = message SMmgr.SMGetAttDbl(&msg,
                                "volume", &volume2, NULL),
                        	senderid = NULL_OBJID,
                        	targetid = compart.objid,
                        	targetos = compart.osnum );
		if(!(status & 1)){
        		as$status();
        		printf("ERROR SMmgr.SMGetAttDbl\n");
        		goto wrapup;
		}
		if(volume2 < volume1){
			volume1 = volume2;
			x_cmp->objid = compart.objid;
			x_cmp->osnum = compart.osnum;
		}
	}

}


#ifdef TIME1
	t2=clock();
	t=t2-t1;
	printf("t end : %d\n",t);
#endif

if(nb_list) *nb_list = count;
if(found && cmp_name){

	status = om$send(msg = message SMmgr.SMGetAttTxt(&msg,
                                "name", cmp_name, NULL),
                        senderid = NULL_OBJID,
                        targetid = x_cmp->objid,
                        targetos = x_cmp->osnum );
	if(!(status & 1)){
        		as$status();
        		printf("ERROR SMmgr.SMGetAttTxt\n");
        		goto wrapup;
	}
	
}


return 1;

wrapup:
if(totlist && (*totlist) ){free(*totlist);(*totlist) = NULL;}

return 0;
}
 
/* ====================== SMIsInCompt =====================
 
 	Function that returns in which compart the element is
	(cog of the object in the compart range)

	If Compart is pseudo, or hull_compart don't take it if
	no_pseudo = 1 or no_hull = 1.

	The return compart will be the smallest one (smallest volume) containing
	the element.

	The list of all compartments containing the object can also be
	returned (cmp is allocated by the function and must be free by
	the caller).

	If We have a compart that is a disjoint union of 2 solid,
	we can verify by getting these solids if the element is in one of
	them or not (that case is not treated here, can be done later)

	return 1 if ok 
 	else 0.	
	

*/
 
 
int SMIsInCompt(obj, obj_env,no_pseudo, no_hull, cmp_id, cmp_name, nb_list, totlist)
struct GRid	  *obj;  	/* [I] : object to test                    */
struct GRmd_env	  *obj_env;  	/* [I] : object env                        */
int		  no_pseudo;    /* [I] : 1 if pseudo not wanted            */
int		  no_hull;      /* [I] : 1 if hull not wanted              */
struct GRid       *cmp_id; 	/* [O] compartment in which is the object  */
IGRchar		  *cmp_name;	/* [O] compart name                        */
IGRint		  *nb_list;	/* [O] nb compart in the list              */
struct GRid       **totlist; 	/* [O] compartment list containing the obj */
{
BSrc			rc;
int			i, k, dim,count, status;
long			msg;
IGRchar			tpipo[81];
IGRboolean		found, world;
IGRdouble		volume1, volume2, cog[3];
IGRulong		location;
struct GRmd_env		sol_env;
struct GRid		compart, *x_cmp, dummy_cmp;
struct SMObjList	list;
GRrange			range, cmp_range;
IGRpoint		myrange[2];

#ifdef TIME1
	long	t, t1, t2;
	t1 = clock();
#endif

list.list = NULL;
list.nb_objects = 0;

dummy_cmp.objid = NULL_OBJID;

if(totlist) (*totlist) = NULL;
if(nb_list) *nb_list = 0;

if(cmp_id) x_cmp = cmp_id;
else 	   x_cmp = &dummy_cmp;

if(cmp_name) cmp_name[0] = '\0';

/* compute the cog of the object */

world = TRUE;
status = om$send(msg = message GRgraphics.GRgetrang(&msg,
                                &obj_env->md_env.matrix_type,
                                obj_env->md_env.matrix,
                                &world,
                                range),
                        senderid = NULL_OBJID,
                        targetid = obj->objid,
                        targetos = obj->osnum );
if(!(status & 1)){
        	as$status();
        	printf("ERROR GRgraphics.GRgetrange\n");
        	goto wrapup;
}
for(i=0;i<3;i++) cog[i] = (range[i] + range[i+3])/2;

/* Get the list of all comparts */

status = SM$CritSel(      options = SM_REF_FILE,
                          msg = &msg,
                          type = SM_COMPART,
                          list = &list);
if(!(status&msg&1) ){
	printf("ERROR SM$CritSel\n");
	goto wrapup;
}
if(list.nb_objects == 0) {
	if(list.list){free(list.list);list.list = NULL;}
	return 1;
}
if(totlist){
	(*totlist) = 
	  _MALLOC(list.nb_objects,struct GRid );
	if(!(*totlist)){
		printf("Bad allocation\n");
		goto wrapup; 
	}
}

found = FALSE;

count = 0;

for(i=0;i<list.nb_objects;i++){

	/* if compartment is a pseudo, forget it */

	status = om$send(msg = message SMmgr.SMGetAttTxt(&msg,
                                "pseudo", tpipo, NULL),
                        senderid = NULL_OBJID,
                        targetid = list.list[i].obj_id.objid,
                        targetos = list.list[i].obj_id.osnum );
	if(!(status & msg & 1)) tpipo[0] = '\0';
	if( no_pseudo && tpipo[0] != 'n') continue;

	/* if compartment is a compartment hull, forget it */

	status = om$send(msg = message SMmgr.SMGetAttTxt(&msg,
                                "comp_type", tpipo, NULL),
                        senderid = NULL_OBJID,
                        targetid = list.list[i].obj_id.objid,
                        targetos = list.list[i].obj_id.osnum );
	if(!(status & msg & 1)) tpipo[0] = '\0';
	if( no_hull && tpipo[0] == 'h') continue;

	status = om$send(msg = message NDmacro.ACreturn_foot(&msg,
                                "sol", &compart, 
				&sol_env.md_env.matrix_type,
				sol_env.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = list.list[i].obj_id.objid,
                        targetos = list.list[i].obj_id.osnum );
	if(!(status & msg & 1)){
        	as$status();
        	printf("ERROR NDmacro.ACreturn_foot\n");
        	goto wrapup;
	}	

	/* 

		verify if compart contains cog

 	*/

        world = TRUE;
        status = om$send(msg = message GRgraphics.GRgetrang(&msg,
                                &sol_env.md_env.matrix_type,
                                sol_env.md_env.matrix,
                                &world,
                                cmp_range),
                        senderid = NULL_OBJID,
                        targetid = compart.objid,
                        targetos = compart.osnum );
        if(!(status & 1)){
                as$status();
                printf("ERROR GRgraphics.GRgetrange\n");
                goto wrapup;
        }
        dim = 3;
        if(BSptinbx(&rc, cog, &cmp_range[0], &cmp_range[3], &dim)){


		sol_env.md_id.osnum = compart.osnum;
  		status =ex$get_modid(	mod_osnum = sol_env.md_id.osnum,
		       		mod_id =    &sol_env.md_id.objid);
  		if(status != 1)
   		{
     			printf("Error get mod_id\n");
     			goto wrapup;
   		}
		for(k=0;k<3;k++) myrange[0][k]= cmp_range[k];
		for(k=0;k<3;k++) myrange[1][k]= cmp_range[k+3];
		status = om$send(msg = message EMSsolid.EMpoint_locate(&msg,
                                &sol_env,
                                0,
                                cog,
                                myrange,
				&location),
                        senderid = NULL_OBJID,
                        targetid = compart.objid,
                        targetos = compart.osnum );
		if(!(status & msg & 1)){
        		as$status();
        		printf("ERROR EMSsolid.EMpoint_locate\n");
        		goto wrapup;
		}
		if(location == EMS_S_ONSOLID || location == EMS_S_INSOLID){

			if(totlist) (*totlist)[count ++] = list.list[i].obj_id;

			/* 
			To do later --> get the volumes of the compart and see
		   	if the element is really in one of them 
			*/


			if(!found){
			
				status = om$send(msg = message SMmgr.SMGetAttDbl(&msg,
                                "volume", &volume1, NULL),
                        		senderid = NULL_OBJID,
                        		targetid = list.list[i].obj_id.objid,
                        		targetos = list.list[i].obj_id.osnum );
				if(!(status & 1)){
        				as$status();
        				printf("ERROR SMmgr.SMGetAttDbl\n");
        				goto wrapup;
				}
				x_cmp->objid = list.list[i].obj_id.objid;
				x_cmp->osnum = list.list[i].obj_id.osnum;

				found = TRUE;
				continue;
			}

			/* keep the compart with the minimun volume */

			status = om$send(msg = message SMmgr.SMGetAttDbl(&msg,
                                "volume", &volume2, NULL),
                        	senderid = NULL_OBJID,
                        	targetid = list.list[i].obj_id.objid,
                        	targetos = list.list[i].obj_id.osnum );
			if(!(status & 1)){
        			as$status();
        			printf("ERROR SMmgr.SMGetAttDbl\n");
        			goto wrapup;
			}
			if(volume2 < volume1){
				volume1 = volume2;
				x_cmp->objid = list.list[i].obj_id.objid;
				x_cmp->osnum = list.list[i].obj_id.osnum;
			}
		}

	}
}
#ifdef TIME1
	t2=clock();
	t=(t2-t1);
	printf("time EMpoint_locate: %ld\n", t);
#endif

if(nb_list) *nb_list = count;
if(found && cmp_name){

	status = om$send(msg = message SMmgr.SMGetAttTxt(&msg,
                                "name", cmp_name, NULL),
                        senderid = NULL_OBJID,
                        targetid = x_cmp->objid,
                        targetos = x_cmp->osnum );
	if(!(status & 1)){
        		as$status();
        		printf("ERROR SMmgr.SMGetAttTxt\n");
        		goto wrapup;
	}
	
}

if(list.list){free(list.list);list.list = NULL;}
return 1;

wrapup:
if(totlist && (*totlist) ){free(*totlist);(*totlist) = NULL;}
if(list.list){free(list.list);list.list = NULL;}
return 0;
}


/* ======================================================================== 

	This function return the coordinate system attached to an 
	equipment.

 	info = 0 if there is only one graphic root that is the cs
 	info = 1 if there is more than one graphics roots
 	info = 2 if there is no cs
 
	return 0 if no ref found

 */

int VDGetCsFromEq(equip, ref, info)
struct GRid		*equip;	/* [I] the equipment object 	*/
struct GRid		*ref;	/* [O] the output cs if found 	*/
int			*info;	/* [O] info on the cs 		*/
{
int		i, status, nb_roots;
struct GRid	go, *roots;


ref->objid = NULL_OBJID;
if(info) *info = 0;

/* take the roots after the ACrg */

status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF, NULL, 0,
						&roots, 2, OM_K_MAXINT, &nb_roots),
	senderid = NULL_OBJID,
        targetid = equip->objid,
	targetos = equip->osnum);
as$status(action = RET_STATUS)

nb_roots = nb_roots-2;

for(i=0;i<nb_roots;i++){
  	status = om$send( msg = message NDnode.ASreturn_go( &go, NULL,NULL),
		senderid = NULL_OBJID,
	   	targetid = roots[i].objid,
	   	targetos = roots[i].osnum);
  	as$status();
	if(SMIsKindOf(&go, OPP_GRlbsys_class_id)){
		ref->objid = go.objid;
		ref->osnum = go.osnum;
	}
}
if(info){
	if(ref->objid == NULL_OBJID) *info = 2;
	else if(nb_roots > 1) *info = 1;
}

if(ref->objid == NULL_OBJID) return 0;

return 1;
}

/* ======================================================================== 

 	This function determine if the given point is inside the closed
 	planar curve or not .

	algorithm: transform the curve into the plan xy and call BSpt_in_cv.
 
 	ind = 0 ---> outside
	ind = 1 ---> inside
	ind = 2 ---> on
	
	return 1 if ok 
 	else 0.	
*/


int SMPtInsideCv(
	IGRpoint		pt,	/* (I) input point                  */
	struct IGRbsp_curve	*curve, /* (I) geom of the curve            */
	struct GRid		*cv_id, /* (I) curve object (NULL if curve) */
	struct GRmd_env 	*ModEnv,/* (I) current env  (NULL if curve) */
	IGRint			*ind	/* (O) position of the point        */
)
{

int			status;
IGRlong			msg, size;
IGRpoint		newpt;
IGRdouble		TMat[3][3], TVec[3], NewZ[3], scale;
IGRboolean		OrientKnow, Orient;
BSrc			rc;
struct IGRbsp_curve	*bsp_cv, *cvgeom;

cvgeom = NULL;

if(ind == NULL){
	printf("Invalid arguments\n");
	goto wrapup;
}

/* get the geom of the curve */

if(curve)	bsp_cv = curve;
else if(cv_id && ModEnv) {
   status = om$send(msg = message GRvg.GRgetsize(&msg, 
   					         &ModEnv->md_env.matrix_type, 
					         ModEnv->md_env.matrix,
						 &size),
                   	senderid = NULL_OBJID,
                   	targetid = cv_id->objid,
                   	targetos = cv_id->osnum);
   if(!(status & msg & 1)) goto wrapup;

   if(size <= 0) goto wrapup;
   cvgeom  = (struct IGRbsp_curve *) _MALLOC(size, char);
   if(cvgeom == NULL )
	{ printf ("Not enough memory\n");
		 goto wrapup;  }

   GRabsg_del_all();
   status = om$send(msg = message GRvg.GRgetgeom(&msg, 
   					         &ModEnv->md_env.matrix_type, 
					         ModEnv->md_env.matrix,
                                                 (IGRchar *) cvgeom),
                     senderid = NULL_OBJID,
                     targetid = cv_id->objid,
                     targetos = cv_id->osnum);
   if(!(status & msg & 1)) {
 	if(cvgeom){free(cvgeom);cvgeom = NULL;}
	goto wrapup;
   }
   bsp_cv = cvgeom;
}
else{
	printf("Invalid arguments\n");
	goto wrapup;
}

/* NewZ is the unit normal vector to the planar curve */

BScvnormal(&rc, bsp_cv, NewZ) ;
if(rc != BSSUCC) goto wrapup;

   /* TMat will be the rotation matrix to transform to a new cs with z axis
	is given by NewZ
   */

BStrans2(NewZ, TRUE, TMat, &rc);
if(rc != BSSUCC) goto wrapup;

TVec[0] = 0; TVec[1] = 0; TVec[2] = 0;
scale = 1;

/* transform the curve in the new cs (TVec,TMat,scale), now the curve
	is on xy plane */

BScvoton(&rc, TVec, TMat, &scale, bsp_cv, bsp_cv);
if(rc != BSSUCC) goto wrapup;

/* project the point onto xy plane */

BSptoldtnw(&rc, TVec, TMat, &scale, pt, newpt);
if(rc != BSSUCC) goto wrapup;

/* determine the position of the point */

OrientKnow = FALSE;
BSpt_in_cv(bsp_cv, newpt, OrientKnow, &Orient, ind, &rc);
if(rc != BSSUCC) goto wrapup;

if(cvgeom){free(cvgeom);cvgeom = NULL;}
return 1;

wrapup:
if(cvgeom){free(cvgeom);cvgeom = NULL;}
return 0;

}

/* ======================================================================== 
 
	This function determine if the given point is on the surface
 
	ind = 0 ---> outside
	ind = 1 ---> on

	return 1 if ok 
 	else 0.	
	
*/


int SMPtInsideSf(
	IGRpoint		pt,	/* (I) input point                   */
	struct IGRbsp_surface	*surf,  /* (I) geom of the surface           */
	struct GRid		*sf_id, /* (I) surface object (NULL if surf) */
	struct GRmd_env 	*ModEnv,/* (I) current env  (NULL if surf)   */
	IGRint			*ind	/* (O) position of the point         */
)
{

int			status;
IGRlong			msg, size;
IGRdouble		param[2];
IGRboolean		onsf;
BSrc			rc;
struct IGRbsp_surface	*bsp_sf, *sfgeom;

sfgeom = NULL;

if(ind == NULL){
	printf("Invalid arguments\n");
	goto wrapup;
}

*ind = 0;

/* get the geom of the surface */

if(surf)	bsp_sf = surf;
else if(sf_id && ModEnv) {
   status = om$send(msg = message GRvg.GRgetsize(&msg, 
   					         &ModEnv->md_env.matrix_type, 
					         ModEnv->md_env.matrix,
						 &size),
                   	senderid = NULL_OBJID,
                   	targetid = sf_id->objid,
                   	targetos = sf_id->osnum);
   if(!(status & msg & 1)) goto wrapup;

   if(size <= 0) goto wrapup;
   sfgeom  = (struct IGRbsp_surface *) _MALLOC(size, char);
   if(sfgeom == NULL ){
	printf ("Not enough memory\n");
	goto wrapup;  }

   GRabsg_del_all();
   status = om$send(msg = message GRvg.GRgetgeom(&msg, 
   					         &ModEnv->md_env.matrix_type, 
					         ModEnv->md_env.matrix,
                                                 (IGRchar *) sfgeom),
                     senderid = NULL_OBJID,
                     targetid = sf_id->objid,
                     targetos = sf_id->osnum);
   if(!(status & msg & 1)) {
 	if(sfgeom){free(sfgeom);sfgeom = NULL;}
	goto wrapup;
   }
   bsp_sf = sfgeom;
}
else{
	printf("Invalid arguments\n");
	goto wrapup;
}



/* determine the position of the point */

BSprptonsf(&rc, bsp_sf, pt, &param[0], &param[1], &onsf);
if(rc != BSSUCC) goto wrapup;

if(onsf == TRUE) *ind = 1;

if(sfgeom){_FREE(sfgeom);sfgeom = NULL;}
return 1;

wrapup:
if(sfgeom){_FREE(sfgeom);sfgeom = NULL;}
return 0;

}

/* ======================================================================== 
 
	SMGetAdjCompart: This function returns the compartments that are 
	adjacents to the given one. (it performs the intersection of the 
	compart ranges)

	totlist is allocated by the function and must be deallocated
	by the user.

	return 1 if ok 
 	else 0.	
 

*/


int SMGetAdjCompart(
struct GRid	  *obj,  	/* [I] : compart to test      */
IGRint		  *nb_list,	/* [O] nb compart in the list */
struct GRid       **totlist	/* [O] adjacent compartments  */
)
{
BSrc			rc;
int			i, count, status;
long			msg;
IGRboolean		found, world;
struct GRmd_env		sol_env;
struct GRobj_env	go_obj;
struct GRid		compart;
struct SMObjList	list;
GRrange			range, cmp_range;

#ifdef TIME1
	long	t, t1, t2;
	t1 = clock();
#endif


list.list = NULL;
list.nb_objects = 0;


if(totlist) (*totlist) = NULL;
if(nb_list) *nb_list = 0;

status = GetEnvFrObj(obj, &go_obj.mod_env, &go_obj.obj_id);
if(!(status & 1)){
        as$status();
        printf("ERROR GetEnvFrObj\n");
        goto wrapup;
}
world = TRUE;
status = om$send(msg = message GRgraphics.GRgetrang(&msg,
                                &go_obj.mod_env.md_env.matrix_type,
                                go_obj.mod_env.md_env.matrix,
                                &world,
                                range),
                        senderid = NULL_OBJID,
                        targetid = go_obj.obj_id.objid,
                        targetos = go_obj.obj_id.osnum );
if(!(status & 1)){
        	as$status();
        	printf("ERROR GRgraphics.GRgetrange\n");
        	goto wrapup;
}

/* Get the list of all comparts */

status = SM$CritSel(      options = SM_REF_FILE,
                          msg = &msg,
                          type = SM_COMPART,
                          list = &list);
if(!(status&msg&1) ){
	printf("ERROR SM$CritSel\n");
	goto wrapup;
}
if(list.nb_objects == 0) {
	if(list.list){free(list.list);list.list = NULL;}
	return 1;
}
if(totlist){
	(*totlist) = _MALLOC(list.nb_objects,struct GRid );
	if(!(*totlist)){
		printf("Bad allocation\n");
		goto wrapup; 
	}
}


count = 0;
for(i=0;i<list.nb_objects;i++){
	found = FALSE;

	status = om$send(msg = message NDmacro.ACreturn_foot(&msg,
                                "sol", &compart, 
				&sol_env.md_env.matrix_type,
				sol_env.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = list.list[i].obj_id.objid,
                        targetos = list.list[i].obj_id.osnum );
	if(!(status & msg & 1)){
        	as$status();
        	printf("ERROR NDmacro.ACreturn_foot\n");
        	goto wrapup;
	}	

        world = TRUE;
        status = om$send(msg = message GRgraphics.GRgetrang(&msg,
                                &sol_env.md_env.matrix_type,
                                sol_env.md_env.matrix,
                                &world,
                                cmp_range),
                        senderid = NULL_OBJID,
                        targetid = compart.objid,
                        targetos = compart.osnum );
        if(!(status & 1)){
                as$status();
                printf("ERROR GRgraphics.GRgetrange\n");
                goto wrapup;
        }
	found = BSbxint(&rc, &range[0], &range[3], &cmp_range[0], &cmp_range[3]);
	if(found)
		if(totlist) (*totlist)[count ++] = list.list[i].obj_id;
	
}

#ifdef TIME1
	t2=clock();
	t=(t2-t1);
	printf("time EMpoint_locate: %ld\n", t);
#endif

if(nb_list) *nb_list = count;

if(list.list){free(list.list);list.list = NULL;}
return 1;

wrapup:
if(totlist && (*totlist) ){free(*totlist);(*totlist) = NULL;}
if(list.list){free(list.list);list.list = NULL;}
return 0;

}


 
/* ====================== SMGetInAdjCmpt =====================
 
 	Function that returns in which compart the element is
	in (cog in the compart range)and all the adjacent compartments
	to that one.

	If Compart is pseudo, or hull_compart don't take it if
	no_pseudo = 1 or no_hull = 1.

	totlist is allocated by the function and must be deallocated
	by the user.

	return 1 if ok 
 	else 0.	
	

*/
 
 
int SMGetInAdjCmpt(obj, obj_env, no_pseudo, no_hull,cmp_id, cmp_name, nb_list, totlist)
struct GRid	  *obj;  	/* [I] : object to test 		   */
struct GRmd_env	  *obj_env;  	/* [I] : object env 			   */
int		  no_pseudo;    /* [I] : 1 if pseudo not wanted 	   */
int		  no_hull;      /* [I] : 1 if hull not wanted 		   */
struct GRid       *cmp_id; 	/* [O] compartment in which is the object  */
IGRchar		  *cmp_name;	/* [O] compart name 			   */
IGRint		  *nb_list;	/* [O] nb compart in the list 		   */
struct GRid       **totlist; 	/* [O] compartment list containing the obj */
{
int	status;

status = SMIsInCompt(obj, obj_env, no_pseudo, no_hull, cmp_id, cmp_name, 
			(IGRint *)NULL, 
			(struct GRid **)NULL);

if(!(status & 1)){
        printf("ERROR SMIsInCompt\n");
        goto wrapup;
}

status = SMGetAdjCompart(cmp_id, nb_list, totlist);

if(!(status & 1)){
        printf("ERROR SMGetAdjCompart\n");
        goto wrapup;
}

return 1;

wrapup:
if(totlist && (*totlist) ){free(*totlist);(*totlist) = NULL;}
return 0;

}

/* ====================== SMGetConxCmpt =====================
 
 	Function that returns the comparts that are adjacent to
	the given pt. (create a range of fact*cht around the pt and intersect
	that range with the compart ranges)

	A verification is added because the range is not accurate: 
	if the 2 points defining the range of the pt are outside
	the solid, don't take the corresponding compartment 


	If Compart is pseudo, or hull_compart don't take it if
	no_pseudo = 1 or no_hull = 1.

	if fact is NULL, fact = 100

	totlist is allocated by the function and must be deallocated
	by the user.

	return 1 if ok 
 	else 0.	
	

*/
 
 
int SMGetConxCmpt(pt, fact, no_pseudo, no_hull,nb_list, totlist)
IGRpoint	  pt;		/* [I] : point to test 			  */
IGRdouble	  *fact;	/* [I] : fact for cht to construct range  */
int		  no_pseudo;    /* [I] : 1 if pseudo not wanted 	  */
int		  no_hull;      /* [I] : 1 if hull not wanted 		  */
IGRint		  *nb_list;	/* [O] nb compart in the list 		  */
struct GRid       **totlist; 	/* [O] compartment list containing the obj*/
{
BSrc			rc;
int			i, k, dim, count, status;
IGRlong			msg, sizebuf, nret;
IGRchar			tpipo[81];
IGRdouble		coef, cht_tol;
IGRboolean		found, world;
IGRulong		location;
GRrange			pt_range, cmp_range;
struct GRmd_env		sol_env;
struct GRid		compart;
struct SMObjList	list;
IGRpoint		point, myrange[2];

list.list = NULL;
list.nb_objects = 0;

if(totlist) (*totlist) = NULL;
if(nb_list) *nb_list = 0;

if(fact && *fact > 0 ) coef = *fact;
else coef = 100;

/* create the range for the point */


sizebuf = sizeof(IGRdouble) ;
gr$get_chord_height_tolerance(  msg     = &msg,
                        	sizbuf  = &sizebuf,
                        	buffer  = &cht_tol,
                        	nret    = &nret);
if (! (msg & 1)) {
   	printf("ERROR gr$get_chord_height_tolerance\n");
	goto wrapup;
}

for(i=0;i<3;i++) pt_range[i]   = pt[i] - coef*cht_tol;
for(i=0;i<3;i++) pt_range[i+3] = pt[i] + coef*cht_tol;



/* Get the list of all comparts */

status = SM$CritSel(      options = SM_REF_FILE,
                          msg = &msg,
                          type = SM_COMPART,
                          list = &list);
if(!(status&msg&1) ){
	printf("ERROR SM$CritSel\n");
	goto wrapup;
}
if(list.nb_objects == 0) {
	if(list.list){free(list.list);list.list = NULL;}
	return 1;
}
if(totlist){
	(*totlist) = 
	    _MALLOC(list.nb_objects,struct GRid);
	if(!(*totlist)){
		printf("Bad allocation\n");
		goto wrapup; 
	}
}


count = 0;
for(i=0;i<list.nb_objects;i++){

	status = om$send(msg = message SMmgr.SMGetAttTxt(&msg,
                                "pseudo", tpipo, NULL),
                        senderid = NULL_OBJID,
                        targetid = list.list[i].obj_id.objid,
                        targetos = list.list[i].obj_id.osnum );
	if(!(status & msg & 1)) tpipo[0] = '\0';
	if( no_pseudo && tpipo[0] != 'n') continue;

	/* if compartment is a compartment hull, forget it */

	status = om$send(msg = message SMmgr.SMGetAttTxt(&msg,
                                "comp_type", tpipo, NULL),
                        senderid = NULL_OBJID,
                        targetid = list.list[i].obj_id.objid,
                        targetos = list.list[i].obj_id.osnum );
	if(!(status & msg & 1)) tpipo[0] = '\0';
	if( no_hull && tpipo[0] == 'h') continue;

	status = om$send(msg = message NDmacro.ACreturn_foot(&msg,
                                "sol", &compart, 
				&sol_env.md_env.matrix_type,
				sol_env.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = list.list[i].obj_id.objid,
                        targetos = list.list[i].obj_id.osnum );
	if(!(status & msg & 1)){
        	as$status();
        	printf("ERROR NDmacro.ACreturn_foot\n");
        	goto wrapup;
	}	

        world = TRUE;
        status = om$send(msg = message GRgraphics.GRgetrang(&msg,
                                &sol_env.md_env.matrix_type,
                                sol_env.md_env.matrix,
                                &world,
                                cmp_range),
                        senderid = NULL_OBJID,
                        targetid = compart.objid,
                        targetos = compart.osnum );
        if(!(status & 1)){
                as$status();
                printf("ERROR GRgraphics.GRgetrange\n");
                goto wrapup;
        }
	found = FALSE;
	dim = 3;
	found = BSbxint(&rc, &pt_range[0], &pt_range[3], &cmp_range[0], &cmp_range[3]);
	if(!found) 
		found = BSptinbx(&rc, pt, &cmp_range[0], &cmp_range[3], &dim);
	if(found){


		/* add a verification because the range is not accurate, 
		   if the 2 points defining the range of the pt are outside
		   the solid, don't take the corresponding compartment */

		for(k=0;k<3;k++) myrange[0][k]= cmp_range[k];
		for(k=0;k<3;k++) myrange[1][k]= cmp_range[k+3];
		for(k=0;k<3;k++) point[k] = pt_range[k];

		status = om$send(msg = message EMSsolid.EMpoint_locate(&msg,
                                &sol_env,
                                0,
                                point,
                                myrange,
				&location),
                        senderid = NULL_OBJID,
                        targetid = compart.objid,
                        targetos = compart.osnum );
		if(!(status & msg & 1)){
        		as$status();
        		printf("ERROR EMSsolid.EMpoint_locate\n");
        		goto wrapup;
		}
		if(location == EMS_S_ONSOLID || location == EMS_S_INSOLID){
			if(totlist) (*totlist)[count ++] = list.list[i].obj_id;
		}
		else{
			for(k=0;k<3;k++) point[k] = pt_range[k+3];

			status = om$send(msg = message EMSsolid.EMpoint_locate(&msg,
                                &sol_env,
                                0,
                                point,
                                myrange,
				&location),
                        	senderid = NULL_OBJID,
                        	targetid = compart.objid,
                        	targetos = compart.osnum );
			if(!(status & msg & 1)){
        			as$status();
        			printf("ERROR EMSsolid.EMpoint_locate\n");
        			goto wrapup;
			}
			if(location == EMS_S_ONSOLID || location == EMS_S_INSOLID)
				if(totlist) (*totlist)[count ++] = list.list[i].obj_id;
		}
	}
	
}

if(nb_list) *nb_list = count;



if(list.list){free(list.list);list.list = NULL;}
return 1;

wrapup:
if(list.list){free(list.list);list.list = NULL;}
if(totlist && (*totlist) ){free(*totlist);(*totlist) = NULL;}
return 0;

}

/* ====================== SMGetConxCmpt2D =====================
 
 	Function that returns the comparts drawing that are adjacent to
	the given pt. (create a range of fact*cht around the pt and intersect
	that range with the compart ranges)


	If Compart is pseudo, or hull_compart don't take it if
	no_pseudo = 1 or no_hull = 1.

	if fact is NULL, fact = 500

	totlist is allocated by the function and must be deallocated
	by the user.

	return 1 if ok 
 	else 0.	
	

*/
 
 
int SMGetConxCmpt2D(pt, fact, no_pseudo, no_hull,nb_list, totlist)
IGRpoint	  pt;		/* [I] : point to test 			  */
IGRdouble	  *fact;	/* [I] : fact for cht to construct range  */
int		  no_pseudo;    /* [I] : 1 if pseudo not wanted 	  */
int		  no_hull;      /* [I] : 1 if hull not wanted 		  */
IGRint		  *nb_list;	/* [O] nb compart in the list 		  */
struct GRid       **totlist; 	/* [O] compartment list containing the obj*/
{
BSrc			rc;
int			i, k, count, dim, nb_drawing, nb_graphics,
			inside, status;
long			msg, sizebuf, nret;
IGRchar			tpipo[81];
IGRboolean		found, world;
IGRdouble		coef, cht_tol;
struct GRmd_env		cur_env;
struct GRid		compart, *graphics, *drawing;
GRrange			pt_range, cmp_range;



nb_graphics = 0;
nb_drawing = 0;
drawing = NULL;
graphics = NULL;


if(totlist) (*totlist) = NULL;
if(nb_list) *nb_list = 0;

if(fact && *fact > 0 ) coef = *fact;
else coef = 100;

/* create the range for the point */


sizebuf = sizeof(IGRdouble) ;
gr$get_chord_height_tolerance(  msg     = &msg,
                        	sizbuf  = &sizebuf,
                        	buffer  = &cht_tol,
                        	nret    = &nret);
if (! (msg & 1)) {
   	printf("ERROR gr$get_chord_height_tolerance\n");
	goto wrapup;
}

for(i=0;i<3;i++) pt_range[i]   = pt[i] - coef*cht_tol;
for(i=0;i<3;i++) pt_range[i+3] = pt[i] + coef*cht_tol;

sizebuf = sizeof(struct GRmd_env );
gr$get_module_env(      msg = &msg,
                        sizbuf = &sizebuf,
                        buffer = &cur_env,
                        nret = &nret);


/* Get the list of all VDdrawing */

status = SMGetAllDrw(&nb_drawing, &drawing);
if(!(status&1) ){
	printf("ERROR SMGetAllDrw\n");
	goto wrapup;
}

if(totlist){
	(*totlist) = 
		_MALLOC(nb_drawing,struct GRid );
	if(!(*totlist)){
		printf("Bad allocation\n");
		goto wrapup; 
	}
}

count = 0;
found = FALSE;

for(i=0;i<nb_drawing;i++){

	if(graphics){_FREE(graphics); graphics = NULL;}
	status = SMGetGraphDrw(&drawing[i], &nb_graphics, &graphics);
	if(!(status&1) ){
		printf("ERROR SMGetGraphDrw\n");
		goto wrapup;
	}
	inside = 0;
	for(k=0;k<nb_graphics;k++){

		/* look if pt range intersect one graphic range */

		/* will not work in ref file */

        	world = TRUE;
        	status = om$send(msg = message GRgraphics.GRgetrang(&msg,
                                &cur_env.md_env.matrix_type,
                                cur_env.md_env.matrix,
                                &world,
                                cmp_range),
                        senderid = NULL_OBJID,
                        targetid = graphics[k].objid,
                        targetos = graphics[k].osnum );
        	if(!(status & 1)){
                	as$status();
                	printf("ERROR GRgraphics.GRgetrange\n");
                	goto wrapup;
        	}
		found = FALSE;
		dim = 3;
		found = BSbxint(&rc, &pt_range[0], &pt_range[3], &cmp_range[0], &cmp_range[3]);
		if(!found) 
		found = BSptinbx(&rc, pt, &cmp_range[0], &cmp_range[3], &dim);
		if(found) break;


	}	
	if(found ){

		status = SMGetCompFromDrw(&drawing[i], &compart, NULL);
		if(!(status&1) || compart.objid == NULL_OBJID){
			printf("ERROR SMGetCompFromDrw\n");
			goto wrapup;
		}

		/* if compartment is a pseudo, forget it */

		status = om$send(msg = message SMmgr.SMGetAttTxt(&msg,
                                "pseudo", tpipo, NULL),
                        senderid = NULL_OBJID,
                        targetid = compart.objid,
                        targetos = compart.osnum );
		if(!(status & msg & 1)) tpipo[0] = '\0';
		if( no_pseudo && tpipo[0] != 'n') continue;

		/* if compartment is a compartment hull, forget it */

		status = om$send(msg = message SMmgr.SMGetAttTxt(&msg,
                                "comp_type", tpipo, NULL),
                        senderid = NULL_OBJID,
                        targetid = compart.objid,
                        targetos = compart.osnum );
		if(!(status & msg & 1)) tpipo[0] = '\0';
		if( no_hull && tpipo[0] == 'h') continue;

		if(totlist) (*totlist)[count ++] = compart;

	}

}




if(nb_list) *nb_list = count;


return 1;

wrapup:
if(totlist && (*totlist) ){free(*totlist);(*totlist) = NULL;}

return 0;
}


end implementation Root;


