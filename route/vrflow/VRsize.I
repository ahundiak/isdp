/* $Id: VRsize.I,v 1.3 2002/04/10 19:02:39 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrflow / VRsize.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRsize.I,v $
 *	Revision 1.3  2002/04/10 19:02:39  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.2  2001/02/20 01:13:52  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:51  cvs
 *	Initial import to CVS
 *	
# Revision 1.4  1999/12/02  22:51:42  pinnacle
# Replaced: vrflow/VRsize.I for:  by lawaddel for route
#
# Revision 1.3  1999/05/04  13:51:58  pinnacle
# Replaced: vrflow/VRsize.I for:  by sbilla for route
#
# Revision 1.2  1998/07/24  12:30:26  pinnacle
# Replaced: vrflow/VRsize.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/01/14  18:43:52  pinnacle
# Replaced: vrflow/VRsize.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1996/11/07  18:53:00  pinnacle
# Replaced: vrflow/VRsize.I for:  by r241_int for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/04/05  18:07:32  pinnacle
# Replaced: vrflow/VRsize.I for:  by hverstee for route240
#
# Revision 1.4  1996/04/04  23:12:14  pinnacle
# Replaced: vrflow/VRsize.I for:  by hverstee for route240
#
# Revision 1.3  1996/03/13  22:30:34  pinnacle
# Replaced: vrflow/VRsize.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/16  23:55:56  pinnacle
# Replaced: vrflow/VRsize.I for:  by r240_int for route240
#
 *
 * History:
 *	* 24-Jul-98	Reddy	02.05
 *                      - Modified for CR179801165 - Linkage of Equivalent
 *                        Diameter with Air flow rate.
 *	* 12-Jan-98	law	02.05
 *                      - Modified for CR179700399 - Linkage of Equivalent
 *                        Diameter with width/depth.
 *
 *	* 23-Aug-94	Manyam	02.03.01.02
 *			- Added a new function "VRUpdSegLength()" to update
 *		  	  the segments.		  
 *
 *	* 21-Jul-94	Manyam	02.03.01.02
 *			- Modified "VRmodify_body()" to handle Nozzles 
 *		  	  present in the network in a differant way.
 *		  	  Also did some clean up.
 *
 *	* 28-Oct-91	Bruno 	1.4.3.6	
 *			- VRupdate_flow has been renamed VRinject_flow.
 *			- VRupdate_diam function has been added and is called
 *				by the COflow.u command file ( temporarly ).
 *			- In VRmodify_body, do not call solver when only 
 *			one equation with one unknown becaus it fails ???
 *
 *	* 12-MAR-91	Bruno 1.4.5.4
 *			- Implement VREquiDiam function to take in account
 *		  		the working unit.	
 *
 *	* 10-APR-91   Bruno	1.4.5.8
 *			- Recall VREquiDiam function to VREquiDiamFV.
 *			- Implement VREquiDiamWD function to compute
 *		  	the equivalent diameter based on the width and
 *		  	the depth.
 *
 *	01/15/96   tlb	Add VX_FIproto.h, prototypes
 *      05/04/99    Reddy       Doble value comparision corrected
 *      12/03/99    law    tr179900935-sum airflow failed with VRCptIn
 *      04/05/02    law         TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

class implementation ASnode;

#include	<stdio.h>
#include	<time.h>
#include 	<math.h>
#include 	"OMerrordef.h"
#include 	"GMerrordef.h"
#include 	"GM.h"
#include 	"ACattrib.h"
#include 	"ACrg_collect.h"
#include 	"OMmacros.h"
#include	"exmacros.h"
#include 	"grdpbdef.h"
#include 	"grdpb.h"
#include	"grdpbmacros.h"
#include	"VRsize.h"
#include	"VRdef.h"
#include	"VRMath.h"
#include	"VRcompdef.h"
#include	"VRattr_def.h"
#include	"VRparamdef.h"
#include	"madef.h"
#include	"VRdimdef.h"
#include	"HV_param.h"
#include	"GMndg.h"
#include	"nddef.h"
#include	"ndmacros.h"
#include	"alloca.h"
#include	"AS_status.h"
#include	"VRDbStruct.h"
#include	"vrflow_pto.h"
#include	"vrtools_pto.h"
#include	"vrpdu_pto.h"
#include	"asbox.h"      /* May not be needed-tr179900935 **/

#include	"VDmem.h"
#include	"vrdbgmacros.h"

typedef   char * CHRPTR_TYPE;

/*
#define MY_DEBUG
*/

from	VRGeneric	import	VRGetNumberOfCpts,
				VRGetStatus,
				VRGetNextOnCpt,
				VRGetNeighbors,
				VRGetPlanes,
				VRGetCptProp;

/*A define the global variables	*/
/*** externs needed for dload for tr179900935 ***/
FILE		*DbgFilePtr;	/* Dbg File Ptr to write the nozzle info*/
IGRboolean	bIsNozPresent;	/* Flag to indicate whether a nozzle is
				   present in the network or not	*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            function VRfind_value                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRfind_value(p_spec, p_base, p_data)
  
  struct VRres_info *p_spec;  /* IN     Specifications of the object          */
  struct sim_havcdb *p_base;  /* IN     Pointer to the simulated data base    */
  struct COdatab_hvac *p_data;/* OUT    Pointer to the found data             */

  /*.VRfind_value*/
  {
  /*
  Description : Given the instances of an object, find the object to resize it
                from the data base. If a value is found in the list (p_data),
                returns TRUE else return FALSE.

  Constraint  : The list p_list must be ordered with the equivalent diameter
                less values ---> hight values
  */ 
  double         DE_min;       /* Equivalent Diameter for the flow            */
  double         fabs();       /* Function to get the absolute value          */
  int            find;         /* Flag = TRUE if the element exist            */
  struct COdatab_hvac *p_tempo;/* Temporary pointer to the found data         */
  struct GMlist *p_list;       /* List storing the profile for resizing       */
  int         status = TRUE;   /* Status returned by the function             */

  p_tempo = NULL;

  /*| Load the section data to correct the element */

  switch(p_spec->shape)
    {
    case VR_RECT:
    p_list = &p_base->rect_list;
    break;

    case VR_CORNER:
    case VR_OVAL:
    p_list = &p_base->oval_list;
    break;

    case VR_CIRC:
    p_list = &p_base->circ_list;
    break;

    default:
    status = GM_F_BAD_FUNCT_ARG;
    /*| Load the section data to correct the element */
    gm$status();
  }/* end switch */

  /*"Compute equiv diameter for speed = %lf, flow = %lf\n",p_spec->max_veloc,p_spec->air_flow*/

  VREquiDiamFV( p_spec->air_flow, p_spec->max_veloc, &DE_min );

#ifdef MY_DEBUG
  printf (" vel,flow %f %f equidia = %f\n",p_spec->max_veloc,p_spec->air_flow,
                                           DE_min);
#endif
  /*" equiv diameter = %lf\n",DE_min*/

  /*| ---------------------------- */
  /*| find with depth min criteria */
  /*| ---------------------------- */

  for(GMl_first(p_list),find=FALSE;!GMl_at_end(p_list);GMl_next(p_list))
  {
    p_tempo = (struct COdatab_hvac *)GMl_current(p_list);

    if((p_tempo->equiv_diam >= DE_min))
      {

      IGRdouble Diff , RefDiff;		/* Delta between depths */
      struct COdatab_hvac *p_tempoBis;  /* Temporary pointer to the found data   */

      /*" Found the equiv diameter %lf\n",p_tempo->equiv_diam*/

      /* lets find for this diameter, the bigger depth value smaller to
	 the specified Max_depth */
      /* loop on the set of dimensions corresponding to the same equivalent diameter */

      /*BILLA  Double value comparison problem */
      for(p_tempoBis = p_tempo, RefDiff = p_spec->max_depth - p_tempo->depth;
	  !GMl_at_end(p_list) && (fabs(p_tempoBis->equiv_diam - p_tempo->equiv_diam) < VRGetTol(VR_DIST_TOL));
	  GMl_next(p_list), p_tempoBis = (struct COdatab_hvac *)GMl_current(p_list))
	{

	/* -- compute difference -- */
        Diff = p_spec->max_depth - p_tempoBis->depth;

	if ( Diff >= 0 && ( RefDiff<0 || RefDiff>Diff )  ||
	     Diff <= 0 && ( RefDiff<Diff ) )
	  {
	  /*| This depth is acceptable */
	  RefDiff = Diff;
	  p_tempo = p_tempoBis;
	}
      }/* end loop on depth */
      find = TRUE;
      status = TRUE;
#ifdef MY_DEBUG
      printf (" found, equidia = %f\n",p_tempo->equiv_diam);
#endif
      break;
      }/* end if */
  }/* end for(GMl_first)*/

  if(!find)
  {
    /*| --------------------- */
    /*| find without criteria */
    /*| --------------------- */

    for(GMl_first(p_list),find=FALSE;!GMl_at_end(p_list);GMl_next(p_list))
    {
      p_tempo = (struct COdatab_hvac *)GMl_current(p_list);

      if(p_tempo->equiv_diam>=DE_min)
        {
        /*" Found the equiv diameter %lf\n",p_tempo->equiv_diam*/

        find = TRUE;
        status = FALSE;
        break;
      }/* end if */
    }/* end for(GMl_first)*/
  }/* end f((p_tempo)*/
 
 if(!find)
 {
    /*| (degenerate case) find the best solution */

    GMl_last(p_list);
    p_tempo = (struct COdatab_hvac *)GMl_current(p_list);
    status = FALSE;
 }/* end if(!find)*/

  *p_data = *p_tempo;
exception:
#ifdef MY_DEBUG
  printf ("returned match %f\n", p_tempo->equiv_diam);
#endif
  return(status);
}/* VRfind_value */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        INTERNAL function VRget_fixobj                      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRget_fixobj(p_object, p_info, pl_connect, p_nb_connect)

  struct GRid      *p_object; /* IN     Object to inquire                     */
  struct VRgrinfo  *p_info;   /* IN     Additional information                */
  struct GRid **pl_connect;   /* OUT    List of connected objects             */
  int         *p_nb_connect;  /* OUT    Number of connected objects           */
  /*
  Description : Function that return the fix objects of a graph (I.E. Connection
                objects).
  Constraint  : none
  */ 
  /*.VRget_fixobj*/
  {
  int            status;       /* Status returned by the function             */
  long           msg;          /* Duplication of the status                   */
  int            index0;       /* Index for a loop                            */
  int            index1;       /* Index for a loop                            */
  int            is_anc;       /* Flag = TRUE if is an ancestor               */
  int            nb_anc;       /* Number of ancestors in this list            */
  struct GRid    *l_anc=NULL;  /* Pointer to one of the ancestor              */
  IGRshort       cpt_ind;      /* Index of the connection point               */
  IGRshort       ancind;       /* Ancestor index                              */
  int            nb_cnt;       /* Number of connections for this object       */
  IGRshort       nb_via;       /* Number of Hidden connections                */
  struct GRid    anc_obj;      /* ancestor object                             */
  struct GRid    l_via         /* Kludge list for the outlets                 */
                [VRMAX_CONNEX];
  struct GRid    l_cnt         /* List of connected objects                   */
                [VRMAX_CONNEX];
  static struct GRid p_buff    /* Buffer of the found objects                 */
                [VRMAX_CONNEX];
int not_vrcptin;   /* tr179900935 */

  status = OM_S_SUCCESS;
{ /* This block added for tr179900935 */
   char                 ClassName[64]={""};
   om$get_classname( objid           = p_object->objid,
                          osnum           = p_object->osnum,
                          classname       = ClassName);
   not_vrcptin = 1;
   *p_nb_connect = 0;
   if(!strcmp(ClassName,"VRCptIn"))
   {
   /* printf("Caught a VRCptIn upfront %ld\n",p_object->objid); */
      not_vrcptin = 0;
   }
}

if(pl_connect && not_vrcptin)
{
  if(!(*pl_connect)) *pl_connect = p_buff;

    /*" Get the connections of %d.%d \n",p_object->objid,p_object->osnum*/
 
  status = om$send
               (msg = message VRGeneric.VRGetNumberOfCpts
               (&msg,&nb_cnt,(struct GRmd_env *)p_info->p_md_env),
                senderid = NULL_OBJID,
                targetid = p_object->objid,
                targetos = p_object->osnum);
  gm$status(test = !((status&1)&&(msg&1)));
/*** printf("no cpts for %ld is %d\n",p_object->objid,nb_cnt); ***/

  /*" Get the %d neighbors of %d.%d \n",nb_cnt,p_object->objid,p_object->osnum*/

  status = om$send
               (msg = message VRGeneric.VRGetNeighbors
               (&msg,0,nb_cnt,&nb_cnt,l_cnt,0,(struct GRmd_env *)p_info->p_md_env),
                senderid = NULL_OBJID,
                targetid = p_object->objid,
                targetos = p_object->osnum);
  gm$status(test = !((status&1)&&(msg&1)));

  /*" Get the ancestors of %d.%d \n",p_object->objid,p_object->osnum*/
 
  status = GMget_anc_ingr(p_object, p_info->p_add, &l_anc, p_nb_connect);
  gm$status();

  for(index0=0,nb_anc=0; index0 < *p_nb_connect; index0++)
  {
    /* Added for TR179900935 */
    /*" Get the index of %d.%d\n",l_anc[index0].objid,l_anc[index0].osnum */
    char ClassName[64]={""};
    cpt_ind = 0; /* only to keep compiler happy */

    om$get_classname( objid           = l_anc[index0].objid,
                      osnum           = l_anc[index0].osnum,
                      classname       = ClassName);

    /* if ancestor is not a VRCptIn */
    if(strcmp(ClassName,"VRCptIn")) /* Added for tr179900935 */
    {
      cpt_ind = 0;
      for(is_anc= FALSE,index1 = 0; index1 < nb_cnt; index1++)
      {
        if(!GMgridcmp(&(l_anc[index0]), &(l_cnt[index1]),NULL))
        {
        is_anc = TRUE;
        cpt_ind = index1;
/* printf("Match found on cpt %d of %ld as %ld\n",index1,p_object->objid,l_cnt[index1].objid); ***/
        /*" index[%d.%d] = %d\n",l_anc[index0].objid,l_anc[index0].osnum,cpt_ind*/
        break;
        }/* end if */
      }
           
      if(is_anc)     /* Major modifications for tr179900935 */
      {
         struct GRid CorId;
         IGRint WeHaveCorrection;
         nb_via =0;
        /*** Check if a correction. If so should be the first pick. *****/
        WeHaveCorrection = 0;
        status = ASget_as_owner( p_object, &CorId );

        if( CorId.objid != NULL_OBJID )
        {
        /*** We have owner, get the class make sure it is a VRHCorentity ***/
           om$get_classname( objid           = CorId.objid,
                             osnum           = CorId.osnum,
                             classname       = ClassName);

           /* if the correction is being processed */
           if(!strcmp(ClassName,"VRHCorentity"))
           {
              WeHaveCorrection = 1;
           }
        }
        if(WeHaveCorrection)
        {
         /* It is a correction,l_cnt[cpt_ind] has the next component we need **/
            anc_obj = l_cnt[cpt_ind];
            nb_via = 0;
        }
        else
        {
           status = om$send
                 (msg = message VRGeneric.VRGetNextOnCpt
                 (&msg, cpt_ind, &anc_obj, &ancind,
                  VRMAX_CONNEX,&nb_via,l_via,NULL,(struct GRmd_env *)p_info->p_md_env),
                 senderid = NULL_OBJID,
                 targetid = p_object->objid,
                 targetos = p_object->osnum );
           gm$status(test = !((status&1)&&(msg&1)));
        }
/*******
printf("Processing trace using VRGetNextOnCpt on %ld on cpt %d\n",p_object->objid,cpt_ind);
printf("pl_connect %d loaded as anc_obj %ld\n",nb_anc,anc_obj.objid);
*******/

        (*pl_connect)[nb_anc++] = anc_obj;

        for(index1 = 0; index1 < nb_via; index1++)
        {
/*****
printf("pl_connect %d loaded as l_via-%d as %ld\n",nb_anc,index1,l_via[index1].objid);
****/
          (*pl_connect)[nb_anc++] = l_via[index1];
        }
      }
      else
      {
         return(OM_W_ABORT);
      }
    }
  }/* end for(index0)*/
    *p_nb_connect = nb_anc;
/*^
for(index0=0; index0 < *p_nb_connect; index0++)
printf("anc[%d] =%d.%d\n",index0,(*pl_connect)[index0].objid,(*pl_connect)[index0].osnum);
*/
}/* end if(pl_connect)*/

exception:
  return(status);
}/* end VRget_fixobj */

/*D
	Function : VRmodify_body()

	Abstract : Modify the sizing values of a HVAC object.
	This function is written to be one of the arguments of 
	GMbroacast_graph fct.
	
	Limitations : This message is sent to comps which are not
	VR_CORRECTION type.
*/ 

IGRint	VRmodify_body(p_object, p_info)
  
	struct GRid     *p_object;  /* IN     Object to analyse              */
	struct VRgrinfo *p_info;    /* IN     Pointer to the information     */

/*.VRmodify_body*/
{
	long           msg;          /* Status returned by a message                */
	int            status;       /* Status returned by the om                   */
	short          cmp_type;     /* Component type                              */
	int            nb_cnt;       /* Number of connections to the element        */
	int            nb_unkn;      /* Number of unknowns to update                */
	int            maxunkn;      /* Number maximum of unknowns                  */
	short          cpt_ind;      /* Index of the connection point               */
	char           **l_equa=0;   /* List of equations                           */
	int            nb_equa=0;    /* Number of equations                         */
	char equation[VRMAX_FORMULA];/* Equation in a connect point                 */
	int            index;        /* Index for a loop                            */
	struct COdatab_hvac obj_data;/* Information to resize                       */
	struct ACrg_coll attr;       /* Attribute to update                         */
	struct VRres_info res_info;  /* specifications of the object                */
	double          value;        /* Temporary value to store a size             */
	IGRboolean	call_wrt_equa;

	status = 
	om$send( msg = message VRGeneric.VRGetStatus(&msg,&cmp_type),
		senderid = NULL_OBJID,
		targetid = p_object->objid,
		targetos = p_object->osnum);
	gm$status(test = !((status&1)&&(msg&1)) );

	/*" status(%d.%d) = %d\n",p_object->objid,p_object->osnum,cmp_type*/

	if(!(cmp_type & VR_CORRECTION))
	{
	  IGRboolean		bNozzle = FALSE;
	  GRclassid		MyClassId;
	  extern GRclassid	OPP_VRNozzle_class_id;
	  IGRdouble		dNewWidth=0, dNewDepth=0;

	  /*A get the classid	*/
	  status = 
	  om$get_classid(
			objid = p_object->objid,
			osnum = p_object->osnum,
			p_classid = &MyClassId	);
	  as$status();

	  if ( om$is_ancestry_valid( subclassid = MyClassId,
		superclassid = OPP_VRNozzle_class_id) == OM_S_SUCCESS )
		bNozzle = TRUE;

	   if ( !bIsNozPresent && bNozzle)
			bIsNozPresent = TRUE;

	  /*A form the equation for the comp under consideration	*/

	  /*" Get the connections of %d.%d \n",p_object->objid,p_object->osnum*/
 
	  status = 
	  om$send( msg = message VRGeneric.VRGetNumberOfCpts(
			&msg,&nb_cnt,(struct GRmd_env *)p_info->p_md_env),
		senderid = NULL_OBJID,
                targetid = p_object->objid,
                targetos = p_object->osnum);
	  gm$status(test = !((status&1)&&(msg&1)));

	  maxunkn = 2*nb_cnt;

	  l_equa = _MALLOC (maxunkn, CHRPTR_TYPE);
/*
(char **)alloca(maxunkn*sizeof(char *));
*/
	  if(!l_equa){status=OM_E_NODYNMEM;gm$status();}

	  for(cpt_ind=0; cpt_ind < nb_cnt; cpt_ind++)
	  {
	    /* Write the Known equations */

	    status = 
	    VRget_resinfo(p_object, cpt_ind, 
		p_info->p_md_env, &res_info, &call_wrt_equa );
	    gm$status();

	    /*" Find the new values of %d.%d\n",
			p_object->objid,p_object->osnum*/
	    status = 
	    VRfind_value(&res_info, (struct sim_havcdb *)p_info->p_add,
			&obj_data);
	    gm$status();
	
	    /*" Width = %lf\n",obj_data.width*/
      	    /*" Depth = %lf\n",obj_data.depth*/
      	    /*" equiv diam = %lf\n",obj_data.equiv_diam*/

	    /*C Kludge to fix the orientation */

      	    if(((res_info.W_D > 1.001)&&(obj_data.width <obj_data.depth))
        	||((res_info.W_D < 0.999)&&(obj_data.width > obj_data.depth)))
            {
		/*A Swap the width and depth */

		value = obj_data.width;
		obj_data.width = obj_data.depth;
		obj_data.depth = value;
	    }/* end if */

	    if( call_wrt_equa )
      	    {
        	/*A Write the width equation */

		status = 
		VRwrite_equation(cpt_ind,VRFT_WIDTH,
                                  obj_data.width,p_object,equation);
		gm$status();
      	    }
	    else sprintf(equation,"%s=%lf;","width_1", obj_data.width );

      	    /*" width -> %s\n",equation*/
	    l_equa[nb_equa] = _MALLOC (strlen(equation) + 1, char);
            strcpy (l_equa[nb_equa] , equation);
	    nb_equa++;
      
	    if(obj_data.shape != VR_CIRC)
            {
		if( call_wrt_equa )
          	{
		  /*A Write the depth equation */
		  status = 
		  VRwrite_equation(cpt_ind,VRFT_DEPTH,
                                      obj_data.depth,p_object,equation);
		  gm$status();
		}
		else 
		  sprintf(equation,"%s=%lf;","depth_1", obj_data.depth );

		/*" depth -> %s\n",equation*/
	        l_equa[nb_equa] = _MALLOC (strlen(equation) + 1, char);
                strcpy (l_equa[nb_equa] , equation);
	        nb_equa++;
	    }/* end if not circular */

	  }/* end loop on cpts*/

	  if ( nb_equa > 1 )
	  {
	    /*A Resolve the simultaneous equations */
	    status = 
	    VRsolve_equation(maxunkn, nb_equa, l_equa, &nb_unkn);
	    gm$status();

	  } else {

	    /*A Take equation as it is --> No call to solver */
	    nb_unkn=1;
	  }

	  /*A update the cpt properties with new values	*/

	  for(index=0; index < nb_unkn; index++)
      	  {
	    /*A split the equation and get the attribute value	*/
	    status =
	    VRsplit_equation(l_equa[index],attr.name,
			&attr.desc.value.att_exp);
	    attr.desc.type = AC_ATTRIB_DOUBLE;

	    /*A System is not supposed to change the cpt properties of
		the nozzle( either placed independently or an equipment's
		nozzle ). It has to inform the user about the required
		changes.
	    */
	
	    /*A process entities which are nozzles	*/
	    if ( bNozzle )
	    {	
		if ( !strncmp( attr.name, VRFT_WIDTH,5 ) )
			dNewWidth = attr.desc.value.att_exp;
		else if ( !strncmp( attr.name, VRFT_DEPTH,5 ) )
			dNewDepth = attr.desc.value.att_exp;		
		
	    } else {
		/*A process graph entities which are not nozzles	*/
	      	/*" Update %s with %lf\n",l_equa[index],attr.desc.value.att_exp*/
		status = 
		VRChgCmpAttr(&msg, &attr,p_object, 
			(struct GRmd_env *)p_info->p_md_env);
		gm$status();
	    }

	  }/* end for */

	  if ( bNozzle )
	  {
		struct	VRcp_attr	CptAttr;
		IGRint			Index=-1;
		struct ret_struct	AttrSt;

		/*A get the width and depth of the nozzle and we assume
		    that the nozzle is going to have only one Cpt	*/
		status = 
		om$send( msg = message VRGeneric.VRGetCptProp(
				&msg, 0, &CptAttr,
				(struct GRmd_env *)p_info->p_md_env),
			senderid = NULL_OBJID,
			targetid = p_object->objid,
			targetos = p_object->osnum);
		gm$status();
	
		/*C get the component code */
		Index = -1;
		status =
		om$send (msg = message NDmacro.ACgive_structure
			( (IGRint *) &msg, &Index, VR_N_TAG_NUMBER_AN,
			&AttrSt, (struct GRmd_env *)p_info->p_md_env ),
			senderid = NULL_OBJID,
			targetid = p_object->objid,
			targetos = p_object->osnum);
		gm$status();

		/*A write the nozzle info to the debug file	*/
	        if ( DbgFilePtr )
		{
		fprintf( DbgFilePtr,
		"   %-12s    %-8G   %-8G   %-8G   %-6G   %-6G %-6G  %-6G \n",
		AttrSt.var.text_st.text_string,  
		res_info.air_flow , res_info.max_veloc,
		obj_data.equiv_diam, CptAttr.width, CptAttr.depth, 
		dNewWidth, dNewDepth );
		}

	  } else {

		/*" Recompute %d.%d\n",p_object->objid,p_object->osnum*/
	  	
		status = 
		om$send( msg = message NDnode.NDs_compute_node(
				&msg,0,(struct GRmd_env *)p_info->p_md_env),
			senderid = NULL_OBJID,
			targetid = p_object->objid,
			targetos = p_object->osnum);
		gm$status(test = !((status&1)&&(msg&1)));
	  } 
	
	}/* end processing for non-correction components */

exception:

	if(l_equa)
        {
		for(index=0; index < nb_equa; index++) _FREE(l_equa[index]);
                _FREE (l_equa);
        }

	return(status);

}/* end	VRmodify_body */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             function VRadd_batch                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRadd_batch(p_object, p_info)
  
  struct GRid     *p_object;  /* IN     Object to recompute                   */
  struct VRgrinfo *p_info;    /* IN     Pointer to the information            */

  /*.VRadd_batch*/
  {
  /*
  Description : if p_info->padd == 1, Add the parents's planes in the batch
                list (to allow a recompute of the geometry for this element).
                if p_info->padd == 0, add the object in the list.

  Constraint  : none.
  */ 
  long         msg;            /* Status returned by a message                */
  int          status;         /* Status returned by the om                   */
  int          index ;         /* Index for a loop                            */
  int          nb_plane;       /* Number of planes to recompute               */
  int          cn_type=ND_COMP;/* Type of compute requested                   */
  struct GRid  l_plane         /* Plane list to add in the batch              */
               [3*VR_MAX_CPTS];

  status = OM_S_SUCCESS;

  switch((int)p_info->p_add)
    {
    case 0:
    nd$wait_batch
      (type       = GR_GEOM_POSTED,
       l_object   = p_object,
       l_obj_info = &cn_type,
       nb_obj     = 1);
    break;

    case 1:
    status = om$send
               (msg = message VRGeneric.VRGetPlanes
               (&msg,3*VR_MAX_CPTS,l_plane,&nb_plane,(struct GRmd_env *)p_info->p_md_env),
                senderid = NULL_OBJID,
                targetid = p_object->objid,
                targetos = p_object->osnum);
    gm$status(test = !((status&1)&&(msg&1)));

    for(index=0; index<nb_plane; index++)
      {
      nd$wait_batch
        (type       = GR_GEOM_POSTED,
         l_object   = &l_plane[index],
         l_obj_info = &cn_type,
         nb_obj     = 1);
    }/* end for */
    break;
  }/* end switch*/

exception:
  return(status);
}/* VRadd_batch */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*-------------------------------------------------------------------*/
/*	function VREquiDiamFV
/*
/* 
/* Computes the equivalent diameter based on the air flow and
/* the air velocity.
/*
/*-------------------------------------------------------------------*/

#include "VRDbStruct.h"

IGRint VREquiDiamFV ( dAirFlow, dVelocity, dEquiDiam )
IGRdouble dAirFlow;
IGRdouble dVelocity;
IGRdouble *dEquiDiam;
/*.VREquiDiamFV */
{

  SetProc( Fn VREquiDiamFV ); Begin 

  __DBGpr_dbl(" Air Flow ", dAirFlow );
  __DBGpr_dbl(" Velocity ", dVelocity );

  if ( dVelocity < .0001 )
  {
	*dEquiDiam = 0.0;
	__DBGpr_com(" Equivalent Diameter is 'zero' " );
	End
	return OM_S_SUCCESS;
  }

  /* Get project units */
  switch (VRenq_proj_units())
  {
	case VR_METRIC_UNITS :
	case VR_MIXED_UNITS :
	  /* convert m3/mn and m/s into mm3/mn and mm/mn to get mm */

	  // LINE BELOW IS COMMENTED FOR THE SAKE OF CR179801165

	  //  *dEquiDiam = sqrt((183*dAirFlow*25.4*25.4)/(dVelocity*60.0));

	  /* Redefined equivalent diameter equation for CR179700399 */
	  /* 
	    *dEquiDiam =sqrt((4.*dAirFlow*1000000.)/(VR_PI_RAD*dVelocity*60.));
	   */

	  /* Redefined equivalent diameter equation for CR179801165 */
	  // Air flow (user input) is changed from m3/mn to lt/s  

	  *dEquiDiam = 25.4*sqrt((183*dAirFlow*0.00508)/(dVelocity*0.4719));

	  break;

	case VR_IMPERIAL_UNITS :
	  /*  Redefined equivalent diameter equation for CR179700399 */
	  /*  *dEquiDiam = sqrt((4.*dAirFlow*144)/(VR_PI_RAD*dVelocity*60)); */

	  /* convert f3/mn and f/s into i3/mn and i/mn to get inches */
          *dEquiDiam = sqrt((183.0 * dAirFlow)/(dVelocity*60.));
	  break;

	default :
#ifdef MY_DEBUG
	  printf ( "Unknown units : %d\n", VRenq_proj_units() );
#endif
	  *dEquiDiam = 0.0;

  }/* end switch on unit */

  __DBGpr_dbl(" Equivalent Diameter ", *dEquiDiam );

End
return OM_S_SUCCESS;
}/* end VREquiDIamFV */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/* Below added for CR179700399 - Link equivalent diameter and width/depth */
/*-------------------------------------------------------------------*/
/*	function VREquiDiamFF
/*
/* 
/* Computes the equivalent diameter based on the air flow and
/* the air velocity.
/*
/*-------------------------------------------------------------------*/

#include "VRDbStruct.h"

IGRint VREquiDiamFF ( dAirFlow, dFriction, dEquiDiam )
IGRdouble dAirFlow;
IGRdouble dFriction;
IGRdouble *dEquiDiam;
/*.VREquiDiamFF */
{
IGRdouble dTempval;
IGRdouble dAirFlowMod;

  SetProc( Fn VREquiDiamFF ); Begin 

  __DBGpr_dbl(" Air Flow ", dAirFlow );
  __DBGpr_dbl(" Friction ", dFriction );

  /* Get project units */
  switch (VRenq_proj_units())
  {
	case VR_METRIC_UNITS :
	case VR_MIXED_UNITS :
          /* Convert cubic feet/min to cubic meters/min */
	  /*  CR179801165 - User input is changed from m^3/min to litre/sec */

	  dAirFlowMod = dAirFlow/0.4719;
	  dTempval = 0.123*(8.176/dFriction)* pow(dAirFlowMod,1.82);
	  *dEquiDiam = 25.4*(pow(dTempval,0.206186));

	  break;

	case VR_IMPERIAL_UNITS :
	// Line below is commented as the following eqn. is giving error values

        //*dEquiDiam = 0.2322 * (pow(dAirFlow,0.4))/(pow(dFriction,0.2));

        // Equation to calculate equivalent diameter as sent by Jeff. -- Reddy  

	  dTempval = 0.123*pow(dAirFlow,1.82)/dFriction ;
	  *dEquiDiam = pow(dTempval,0.206186);

	  break;

	default :
#ifdef MY_DEBUG
	  printf ( "Unknown units : %d\n", VRenq_proj_units() );
#endif
	  *dEquiDiam = 0.0;

  }/* end switch on unit */

  __DBGpr_dbl(" Equivalent Diameter ", *dEquiDiam );

End
return OM_S_SUCCESS;
}/* end VREquiDIamFF */

/*-------------------------------------------------------------------*/
/*	function VREquiDiamWD
/*
/* 
/* Computes the equivalent diameter based on the width and
/* the depth.
/*
/*-------------------------------------------------------------------*/

IGRint VREquiDiamWD ( dWidth, dDepth, dEquiDiam )
IGRdouble dWidth;
IGRdouble dDepth;
IGRdouble *dEquiDiam;
/*.VREquiDiamWD */
{
	IGRdouble	pow();		/* Function to get the power of a real    */

	/*" Width : %f\n", dWidth */
	/*" Depth : %f\n", dDepth */

	/* Get project units */

	if ( dWidth+dDepth )
	*dEquiDiam = 1.3 * pow((dWidth*dDepth), .625)/ pow((dWidth+dDepth), .25);
	else
	*dEquiDiam = 0.0;

	/*" ---> Equivalent Diameter : %f\n", *dEquiDiam */

return OM_S_SUCCESS;

}/* end VREquiDiamWD */

IGRint	VRUpdSegLength(p_object, p_info)
  
  struct GRid     *p_object;  /* IN     Object to recompute                   */
  struct VRgrinfo *p_info;    /* IN     Pointer to the information            */

/*.VRUpdSegLength*/
{
/*
Description : 

Constraint  : none.
*/ 
	long         retmsg;         /* Status returned by a message	*/
	int          status;         /* Status returned by the om	*/

	/* "VRUpdateSegLength: objid = %d, osnum = %d \n",
		p_object->objid, p_object->osnum */

	status =
	VRUpdateConstruction( &retmsg, 1, p_object, 
		(struct GRmd_env *)p_info->p_md_env );

exception:
	return(status);

}/* VRUpdSegLength */

end implementation ASnode;
