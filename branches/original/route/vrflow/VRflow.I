/* $Id: VRflow.I,v 1.3 2001/05/09 23:46:44 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrflow / VRflow.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRflow.I,v $
 *	Revision 1.3  2001/05/09 23:46:44  louis
 *	TR5100-meaningful error message with incorrect select of component
 *	
 *	Revision 1.2  2001/02/20 01:13:50  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:51  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  1999/12/02  22:51:22  pinnacle
# Replaced: vrflow/VRflow.I for:  by lawaddel for route
#
# Revision 1.2  1999/08/20  08:39:30  pinnacle
# TR179900761 - Sum Air Flow : For reference files not working
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/03/13  22:30:40  pinnacle
# Replaced: vrflow/VRflow.I for:  by hverstee for route240
#
# Revision 1.3  1996/01/16  23:55:44  pinnacle
# Replaced: vrflow/VRflow.I for:  by r240_int for route240
#
 *
 * History:
 *
 *
 *
 *	28-Oct-91	Bruno 	1.4.3.6	
 *				- VRupdate_flow has been renamed VRinject_flow.
 *				- VRupdate_diam function has been added and 
 *					is called by the COflow.u command 
 *					file ( temporarly ).
 *				- Remove VRkludge_flow function.
 *				- Avoid incrementing an index in VRcompute_flow
 *				   because the according array was not updated.
 *
 *	05-NOV-91	Bruno 	1.4.3.7	
 *				- VRcompute_flow did not store the flow in the
 *					terminal component.
 *
 *	23-JUL-92	Bruno	1.4.5.28
 *					- VRupdate_diam has been removed.
 *	26-Aug-94	Manyam	2.3.1.10
 *					Added the function "VRSetCorCmpFlow()"
 *      15-Dec-95     	Shankar	2.4.0.11
 *              			Added the function "VRcheck_database()"
 *	01/16/96	tlb	  Add prototypes
 *	08/20/99	Alwin	TR179900761, For the VRCptIn end component we
 *				 don't need to Set flow value.
 *      09/17/99        law        TR179900935-bad sums & reverse flows
 *      05/09/01	law	TR5100-Picking wrong dangle gives generic error.
 *************************************************************************/

class implementation ASnode;

#include "OMmacros.h"
#include "OMerrordef.h"
#include "GMerrordef.h"
#include "GM.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRsize.h"
#include "VRdef.h"
#include "VRcompdef.h"
#include "VRattr_def.h"
#include "VRparamdef.h"
#include "madef.h"
#include "HV_param.h"
#include "GMndg.h"
#include "exmacros.h"
#include "vrtrace_pto.h"
#include "vrflow_pto.h"
#include "vrtools_pto.h"
#include "vrdbgmacros.h"

/*
#define MY_DEBUG
*/

from	VRGeneric	import	VRGetParams,
				VRGetConnDesc,
				VRGetNumberOfCpts,
				VRGetNextOnCpt,
				VRSetFlow,
				VRGetStatus,
				VRGetCorOnCpt,
                                VRGetNeighbors,
				VRGetFlow;

from	ACdiowner	import	ACmod_attribute;

/*C extern declarations	*/
extern	OM_S_CHANSELECT	AS_to_comp;
extern GRclassid OPP_VRCptIn_class_id;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                    INTERNAL function VRget_diconnect                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRget_diconnect(p_object, p_info, pl_connect, p_nb_connect)

  struct GRid *p_object;      /* IN     Object to inquire                     */
  struct VRgrinfo *p_info;    /* IN     Pointer to the user information       */
  struct GRid **pl_connect;   /* OUT    List of connected objects             */
  int         *p_nb_connect;  /* OUT    Number of connected objects           */
  /*
  Description : Function that return the directed connections of a HVAC
                component. In fact Give an orientation of the connections. This
                function is written to be one of the arguments of the 
                GMget_graph function.
  Constraint  : none
  */ 

{
  int            status;       /* Status returned by the function             */

  /*" Get the connections of %d.%d\n",p_object->objid,p_object->osnum*/

  status = VRget_connect(p_object, p_info->p_md_env, pl_connect, p_nb_connect);

  /*| Orient the connections */
    
  status = GMorient(p_object,p_info->p_add,*pl_connect,p_nb_connect);

  exception:
  return(status);
}/* end VRget_diconnect */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                     INTERNAL function VRcompute_flow                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRcompute_flow(p_object, p_info)

  struct GRid     *p_object;  /* IN     Object to analyse                     */
  struct VRgrinfo *p_info;    /* IN     Additional information                */
  /*
  Description : Compute the flow of an element by adding the flow of its parents
  Constraint  : The graph must be taken before
  */

{
  double         value;       /* Value of the flow in a connection point      */
  double         valuek;      /* Value for the outlets kludges                */
  int            nb_anc;      /* Number of ancestors in this list             */
  IGRshort       direct;      /* Direction of the flow                        */
  struct GRid    *l_anc=NULL; /* Pointer to one of the ancestor               */
  double         comp_flow;   /* Computed flow for the object                 */
  long           status;      /* Status returned by the functions             */
  long           msg;         /* Returned code for a message                  */
  int            index0;      /* Index for a loop                             */
  int            index1;      /* Index for a loop                             */
  int            index2;      /* Index for a loop                             */
  IGRshort       cpt_ind;     /* Index of the connection point                */
  IGRshort       ancind;      /* Ancestor index                               */
  int            nb_cnt;      /* Number of connections for this object        */
  struct GRid    anc_obj;     /* ancestor object                              */
  IGRshort       nb_via;      /* Number of kludgy outlets                     */
  IGRshort       l_cntind     /* List of connected indexes                    */
                [VRMAX_CONNEX];
  struct GRid    l_via        /* Kludge list for the outlets                  */
                [VRMAX_CONNEX];
  IGRboolean	bIsTerminator;/* Kludge to update param box of the terminator */
 
	SetProc( Fn VRcompute_flow ); Begin 

	msg = MSSUCC; //initialized by alwin
  status = VRis_outlet(p_object, p_info->p_md_env, (int *)&msg);
  gm$status();

  __DBGpr_obj( " Compute Flow of ", *p_object );
 
  if(!msg)
  {
    /*" Get the connections of %d.%d \n",p_object->objid,p_object->osnum*/
 
    status = om$send
             (msg = message VRGeneric.VRGetNumberOfCpts
             (&msg,&nb_cnt,(struct GRmd_env *)p_info->p_md_env),
              senderid = NULL_OBJID,
              targetid = p_object->objid,
              targetos = p_object->osnum);
    gm$status(test = !((status&1)&&(msg&1)));

		__DBGpr_int( " Nb. of Connection ", nb_cnt );

    for(index0=0; index0<nb_cnt; index0++)
      l_cntind[index0] = index0;

    /*"\t - %d connections\n",nb_cnt*/

    status = GMget_anc_ingr(p_object, p_info->p_add, &l_anc, &nb_anc);
    gm$status();

    __DBGpr_int( " Nb. of Ancestores ", nb_anc );
 
    bIsTerminator = ( nb_cnt == nb_anc ); /* Kludge bruno */
		__DBGpr_int( " Is it a Terminal component ", bIsTerminator );

    for(index0=0,comp_flow=0; index0<nb_anc; index0++)
    {
      __DBGpr_obj( " Get the flow of ", l_anc[index0] );

      status = om$send
               (msg = message VRGeneric.VRGetConnDesc
               (&msg, &l_anc[index0], &cpt_ind, &ancind,
                (struct GRmd_env *)p_info->p_md_env),
                senderid = NULL_OBJID,
                targetid = p_object->objid,
                targetos = p_object->osnum);

			__DBGpr_int( " Cpt Index of Ancestor ", cpt_ind );
			__DBGpr_int( " Other Anc Index ", ancind );

      if((status&1)&&(msg&1))
      {
				__DBGpr_com( " Calling VRGetFlow ... " );
        status = om$send
                 (msg = message VRGeneric.VRGetFlow
                 (&msg, cpt_ind, &direct, &value, p_info->p_md_env),
                senderid = NULL_OBJID,
                targetid = p_object->objid,
                targetos = p_object->osnum);
        gm$status(test = !((status&1)&&(msg&1)) );

				__DBGpr_dbl( " Flow Value ", value );

        nb_via =0;
        status = om$send
                 (msg = message VRGeneric.VRGetNextOnCpt
                 (&msg, cpt_ind, &anc_obj, &ancind, VRMAX_CONNEX,&nb_via,
                  l_via,NULL,(struct GRmd_env *)p_info->p_md_env),
                 senderid = NULL_OBJID,
                 targetid = p_object->objid,
                 targetos = p_object->osnum);

				__DBGpr_obj( " Another ancestor object ", anc_obj );
				__DBGpr_int( " Nb. of via ", nb_via );

        if(nb_via)
        {
          for(index1 = 0; index1 < nb_via; index1++)
          {
            /*" Add the flow of the kludgy %d.%d for index %d\n",
                    l_via[index1].objid,l_via[index1].osnum,cpt_ind*/

						valuek = 0.0;
						__DBGpr_com( " Get the Flow value from neighbouring comps. " );
            status = om$send
                     (msg      = message VRGeneric.VRGetFlow
                     (&msg, 1, &direct, &valuek, p_info->p_md_env),
                     senderid = NULL_OBJID,
                     targetid = l_via[index1].objid,
                     targetos = l_via[index1].osnum);
            gm$status(test = !((status&1)&&(msg&1)));
            value += valuek;
						__DBGpr_dbl( " Flow value ", valuek );
          }/* end for nb_via */

          /*" add the outlet flows to index %d of %d.%d\n",
                  cpt_ind,p_object->objid,p_object->osnum*/ 

#ifdef MY_DEBUG
          printf ("to store flow %f on %d %d\n",value,p_object->objid,
                                                p_object->osnum);
#endif

/******          direct = VR_FLOW_OUT; DELETED FOR tr179900935 *****/
		__DBGpr_com( " Calling VRstore_flow fn ... " );
/* status = VRstore_flow(p_info->p_md_env,cpt_ind,&direct, tr179900935 **/
          status = VRstore_flow(p_info->p_md_env,cpt_ind,NULL,
                                 &value,p_object);
          gm$status();
        }/* end if nb_via */

        /*" Direction = %d\n",direct*/
        /*" Add the flow %lf of %d.%d\n",
             value,l_anc[index0].objid,l_anc[index0].osnum*/
        comp_flow += value;
      }/* end if GetConDesc */
      else
      {
        /*| It must be this kludgy outlet */
        /* removed by bruno        nb_cnt++; because the array
                                             l_cntind is not updated.     */
      }/* end if*/

      /*" Remove index %d from successor list\n",cpt_ind */

      for(index1 = 0; index1 < nb_cnt; index1++)
      {
        if(cpt_ind == l_cntind[index1])
        {
          nb_cnt--;
          for(index2 = index1; index2 < nb_cnt; index2++)
            l_cntind[index2]=l_cntind[index2+1];
          break;
        }/* end if */
      }/* end for */
    }/* end loop on ancestors */

    /* checking which cpts are not connected-tr179900935 *****/
    if(nb_cnt)
    {
    IGRint lastndx,notfoundit,foundit;
    IGRlong retmsg;
   IGRshort  nStatus;
    IGRint    TmpNbNei;
    struct GRid  TmpNeiId;
    notfoundit = 1;
    foundit = 0;
    lastndx = -1;
       for(index1 = 0;index1 < nb_cnt && notfoundit;index1++)
       {
         TmpNeiId.objid = NULL_OBJID;
         nStatus=
                 om$send ( msg = message VRGeneric.VRGetNeighbors
                    ( &retmsg, l_cntind[index1], l_cntind[index1], &TmpNbNei,
                                        &TmpNeiId, NULL, p_info->p_md_env),
         senderid = NULL_OBJID,
         targetid = p_object->objid,
         targetos = p_object->osnum);
         if ( TmpNeiId.objid != NULL_OBJID )
         {
           notfoundit = 0; 
           foundit = 1;
           lastndx = index1;
         }
       }
       if(foundit )
       {
         /******      direct = VR_FLOW_IN; tr179900935 ***********/
         status = VRstore_flow(p_info->p_md_env, l_cntind[lastndx],
                               NULL, &comp_flow, p_object);
         /*****  &direct, &comp_flow, p_object); tr179900935 *****/
         gm$status();
       }
     }/* end if(nb_cnt)*/
     else
     if ( bIsTerminator )
     {
      /*" Store the flow: %lf in the Terminator %d.%d\n",
                 comp_flow,p_object->objid,p_object->osnum*/

      direct = VR_FLOW_OUT;
/** status = VRstore_flow(p_info->p_md_env, (IGRshort) 0, &direct, tr179900935*/
      status = VRstore_flow(p_info->p_md_env, (IGRshort) 0, NULL,
                                          &comp_flow, p_object);
      gm$status();
     }/* end if(nb_cnt)*/

  }/* end if(!msg) ( if not outlet ) */

  exception:
	End
  return(status);
}/* end VRcompute_flow */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function VRdisplay_elmt                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRdisplay_elmt(p_object, p_info)
  
  struct GRid     *p_object;  /* IN     Object to analyse                     */
  struct VRgrinfo *p_info;    /* IN     Pointer to the user information       */
  /*
  Description : Display a piping object, Function used by the graph manager.
  Constraint  : none
  Note        : p_info contains 2 pointers: a pointer to the module env, and
                a pointer to the display mode.
  */ 

{
  long           status;      /* Status returned by the functions             */
  struct GRmd_env	tmp_env;/* KLUDGE : Display needs the current md_id even
				   if object is in another object space */

  tmp_env = *(p_info->p_md_env);
  ex$get_cur_mod ( 	id 	= &tmp_env.md_id.objid,
			osnum 	= &tmp_env.md_id.osnum );

  /*" Display %d.%d\n", p_object->objid, p_object->osnum */

  status = om$send
             (msg = message NDnode.NDdisplay
                   (0,*p_info->p_add,&tmp_env),
              senderid = NULL_OBJID,
  	      targetid = p_object->objid,
	      targetos = p_object->osnum );
  return(GM_S_SUCCESS);
}/* VRdisplay_elmt */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                      INTERNAL function VRinject_flow                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRinject_flow(p_object, p_md_env)

  struct GRid     *p_object;  /* IN     Object to analyse                     */
  struct GRmd_env *p_md_env;  /* IN     Module environment                    */
  /*
  Description : Update the flow for the terminators elements: Get the value in
                the instances and update it for the connection point 0
  Constraint  : none. TO BE REMOVE WHEN USER INTERFACE READY.
  */

{
  IGRshort       direct;      /* Direction of the flow                        */
  long           status;      /* Status returned by the functions             */
  long           msg;         /* Returned code for a message                  */
  struct GRid	 paramid;     /* Identifier of the parameters                 */
  struct ret_struct param;    /* Parameter returned for this value            */
  int    foot_ind = -1;       /* Foot index                                   */

	SetProc( Fn VRinject_flow ); Begin 

  __DBGpr_obj( " Get the flow ", *p_object );

	/* added by alwin for TR179900761 */
	{
		GRclassid Classid;

		status = om$get_classid( objid = p_object->objid,
														 osnum = p_object->osnum,
														 p_classid = &Classid );

		if( Classid == OPP_VRCptIn_class_id ) 
		{
				__DBGpr_com( " Its a Reference Object " );
				End
				return status;
		}
	}
	/* added by alwin for TR179900761 */

  status = om$send
             (msg = message VRGeneric.VRGetParams(&msg,&paramid,NULL, NULL),
              senderid = NULL_OBJID,
              targetid = p_object->objid,
              targetos = p_object->osnum);
  gm$status(test = !((status&1)&&(msg&1)) );

  status = om$send
             (msg      = message NDmacro.ACgive_structure
               ((int *)&msg, &foot_ind, VR_N_FLOW_RATE_DB, &param,p_md_env),
              senderid = NULL_OBJID,
              targetid = paramid.objid,
              targetos = paramid.osnum);
  gm$status(test = !((status&1)&&(msg&1)) );

#ifdef vdsDEBUG
  printf (" Store the flow: %lf in index 0\n",param.var.root_pm_st.value);
  printf (" object %d param %d\n",p_object->objid,paramid.objid);
#endif
  direct = VR_FLOW_IN;
  status = om$send
             (msg      = message VRGeneric.VRSetFlow
              (&msg, 0, NULL, &param.var.root_pm_st.value, p_md_env),
              senderid = NULL_OBJID,
              targetid = p_object->objid,
              targetos = p_object->osnum);

  /***** TR5100 some files had an unconnected dangle at vrcptin ****/
  if(!((status&1)&&(msg&1)))
  {
     long locstatus;
     long locmsg;
     struct GRid l_cnt[VRMAX_CONNEX];         /* List of connected objects                   */
     int nb_nbr;
     int kk,kkk;

     locstatus = om$send
               (msg = message VRGeneric.VRGetNumberOfCpts
               (&locmsg,&nb_nbr,(struct GRmd_env *)p_md_env),
                senderid = NULL_OBJID,
                targetid = p_object->objid,
                targetos = p_object->osnum);
     gm$status(test = !((locstatus&1)&&(locmsg&1)));
     locstatus = om$send
               (msg = message VRGeneric.VRGetNeighbors
               (&locmsg,0,nb_nbr,&nb_nbr,l_cnt,0,(struct GRmd_env *)p_md_env),
                senderid = NULL_OBJID,
                targetid = p_object->objid,
                targetos = p_object->osnum);

      printf("\nError in flow analysis at object %d\n", p_object->objid);
      printf("number of neighbors of objid %d is %d\n",p_object->objid, nb_nbr);
      for(kk=0;kk<nb_nbr;kk++)
      {
         kkk = kk +1;
         printf("objid of neighbor_no. %d is %d\n",kkk, l_cnt[kk].objid);
      }
      printf("If the above info is suspect, please verify correct network chosen\n");
  }
/*  gm$status(test = !((status&1)&&(msg&1)) ); tr5100  */
/* (&msg, 0, &direct, &param.var.root_pm_st.value, p_md_env),tr179900935 */

  exception:
	End
  return(status);
}/* end VRinject_flow */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*+fi
  Internal Function VRSetCorCmpFlow

  Abstract
	Given a component ID, this function gets the flowrate value
	from the correction( only at the Cpts where the flow direction
	is outwards ) and updates the flowrate value in the collections
	of that Correction's components to this value.

  Returns
	OM_S_SUCCESS	- success
	status		- return value of the failed function or
			  method
*/

IGRint	VRSetCorCmpFlow(
	struct GRid	*p_object,	/* I : CmpId	*/
	struct VRgrinfo	*p_info		/* I : Cmp's information	*/
	)
/* start VRSetCorCmpFlow*/
{
	long			retmsg;
	int			status;
	int			NbCpts, i, j;
	double			dFlowRate;	
	short			nDirect;
	struct	GRid		CorId, CorCmpId;
	int			NbCorCmps;
	struct	ACrg_coll	Attr;
	GRclassid		ObjClass;
	extern	GRclassid	OPP_VRGeneric_class_id;

	/* "VRSetCorCmpFlow : the object %d.%d\n",
		p_object->objid,p_object->osnum */

	/*A get the type of component( correction or non-correction )	*/
	{
		short		nStatus;

		status =
		om$send( msg	= message VRGeneric.VRGetStatus(
			&retmsg,&nStatus),
			senderid = NULL_OBJID,
			targetid = p_object->objid,
			targetos = p_object->osnum);
		gm$status(test = !((status&1)&&(retmsg&1)) );

		/*" status(%d.%d) = %d\n",
			p_object->objid,p_object->osnum, nStatus */
		

		/*A no processing needed for correction components directly
		Note : processing needs to be done from Non-Correction 
		Components						*/

		if( nStatus & VR_CORRECTION )
			return OM_S_SUCCESS;
	}

	/*A get the num of Cpts	*/
	status = 
	om$send( msg = message VRGeneric.VRGetNumberOfCpts(
			&retmsg, &NbCpts,
			(struct GRmd_env *)p_info->p_md_env),
	                senderid = NULL_OBJID,
        	        targetid = p_object->objid,
                	targetos = p_object->osnum);
	gm$status(test = !((status&1)&&(retmsg&1)));

	/*A process the cmp at each Cpt	*/
	for ( i=0; i<NbCpts; i++ )
	{
		/*A get the flow rate and flow direction for each Cpt	*/
		status = 
		om$send( msg	= message VRGeneric.VRGetFlow(
			&retmsg, (IGRshort)i, &nDirect, &dFlowRate,
			(struct GRmd_env *)p_info->p_md_env ),
	              senderid = NULL_OBJID,
        	      targetid = p_object->objid,
	              targetos = p_object->osnum);
		gm$status(test = !((status&1)&&(retmsg&1)) );

		/*A proceed further only if the flow-direction is out. 
		This is to avoid redundancy ( processing of correction 
		more than once )					*/

		if ( nDirect == VR_FLOW_IN )
			continue;

		/*A get the correction on Cpt	*/
		status = 
		om$send( msg	= message VRGeneric.VRGetCorOnCpt(
			&retmsg, (IGRshort)i, &CorId,
			(struct GRmd_env *)p_info->p_md_env ),
	              senderid = NULL_OBJID,
        	      targetid = p_object->objid,
	              targetos = p_object->osnum);
		gm$status(test = !((status&1)&&(retmsg&1)) );

		if ( CorId.objid == NULL_OBJID )
			continue;

		/*A get the num of correction components	*/
		status = 
		om$get_channel_count( objid	= CorId.objid,
				osnum		= CorId.osnum,
				p_chanselect	= &AS_to_comp,
				count		= (unsigned int *)&NbCorCmps );
		gm$status();

		for ( j=0; j< NbCorCmps; j++ )
		{
			/*A get the correction's components	*/
	        	status = 
	        	om$get_objid_at_index ( objid	= CorId.objid,
					osnum		= CorId.osnum,
					p_chanselect	= &AS_to_comp,
	                                index	     	= j,
        	                        objidaddr	= &CorCmpId.objid,
		                        osnumaddr	= &CorCmpId.osnum  );
 			gm$status();
		
			if ( CorCmpId.objid == NULL_OBJID )
				continue;

			/*A Flow arrow also sits on the same channel along
			with other correction components. We need to avoid
			the Arrow from being processed			*/
			
			/*A get the classid of the correction cmp	*/
			status = 
			om$get_classid( osnum	= CorCmpId.osnum, 
				objid     	= CorCmpId.objid, 
				p_classid 	= &ObjClass );
			gm$status( );

			/*A proceed only if it is component	*/
			if ( om$is_ancestry_valid( 
				subclassid   = ObjClass,
                                superclassid = OPP_VRGeneric_class_id 
				) != OM_S_SUCCESS )
					continue;

			/*" Store the value %lf\n", dFlowRate */

			/*A set the new flow value in the collections 
			of each correction component			*/
			strcpy(Attr.name,VR_N_FLOW_RATE_DB);
			Attr.desc.type = AC_ATTRIB_DOUBLE;
			Attr.desc.value.att_exp = dFlowRate;
			status = 
			VRChgCmpAttr(&retmsg, &Attr, &CorCmpId,
				(struct GRmd_env *)p_info->p_md_env );
			gm$status();

		}/*end processing of CorCmp	*/

	} /* end processing of each Cpt	*/

	return	OM_S_SUCCESS;

exception:

	return(status);

}/* end VRSetCorCmpFlow */
/*
-----------------------------------------------------------------------------
                  INTERNAL FUNCTION
-----------------------------------------------------------------------------
*/

IGRint	VRcheck_database(p_object, p_info)
  
struct GRid     *p_object;  /* IN     Object to analyse              */
struct VRgrinfo *p_info;    /* IN     Pointer to the information     */

/*.VRcheck_database*/
{
  long           msg;          /* Status returned by a message                */
  int            status;       /* Status returned by the om                   */
  short          cmp_type;     /* Component type                              */
  int            nb_cnt;       /* Number of connections to the element        */
  short          cpt_ind;      /* Index of the connection point               */
  struct COdatab_hvac obj_data;/* Information to resize                       */
  struct VRres_info res_info;  /* specifications of the object                */
  IGRboolean	call_wrt_equa;

#ifdef MY_DEBUG
  printf ("check_database for %d %d\n",p_object->objid,p_object->osnum);
#endif

	status = 
	om$send( msg = message VRGeneric.VRGetStatus(&msg,&cmp_type),
		senderid = NULL_OBJID,
		targetid = p_object->objid,
		targetos = p_object->osnum);
	gm$status(test = !((status&1)&&(msg&1)) );

	/*" status(%d.%d) = %d\n",p_object->objid,p_object->osnum,cmp_type*/

	if(!(cmp_type & VR_CORRECTION))
	{

	  /*" Get the connections of %d.%d \n",p_object->objid,p_object->osnum*/
 
	  status = 
	  om$send( msg = message VRGeneric.VRGetNumberOfCpts(
			&msg,&nb_cnt,(struct GRmd_env *)p_info->p_md_env),
		senderid = NULL_OBJID,
                targetid = p_object->objid,
                targetos = p_object->osnum);
	  gm$status(test = !((status&1)&&(msg&1)));

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

	    if( !status )
		break;
	
	  }/* end loop on cpts*/

	  if( cpt_ind != nb_cnt )
		return FALSE;

	}/* end processing for non-correction components */
    return TRUE;

exception:

	return(status);
}/* end	VRcheck_database */

end implementation ASnode;




