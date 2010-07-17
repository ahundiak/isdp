
/* $Id: VRsym_cache.I,v 1.3 2001/02/20 01:18:25 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrtools/VRsym_cache.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRsym_cache.I,v $
 *      Revision 1.3  2001/02/20 01:18:25  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 20:09:43  anand
 *      SP merge
 *
# Revision 1.1  2000/05/24  01:33:46  pinnacle
# Created: route/vrtools/VRsym_cache.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/04/15  22:10:38  pinnacle
# Replaced: vrtools/VRsym_cache.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/05/03  17:56:08  pinnacle
# Replaced: vrtools/VRsym_cache.I for:  by hverstee for route240
#
 *
 * History:
 *
 *************************************************************************/

/*
  VRsym_cache.I
  robert patience
  25-feb-91
*/

class implementation Root;


#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "AS_status.h"
#include "gr.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "macro.h"
#include "acmacros.h"
#include "parametric.h"
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRstructs.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "msdef.h"
#include "exmacros.h"
#include "VDmem.h"
#include <stdio.h>
#include        "vrdbgmacros.h"

#define AS_DEBUG

from ACcpx_defn		import 	ACgive_temp_desc;
from ACcpx_defn		import 	ACgive_feet_desc;
from ACmacro_defn 	import 	ACtake_template;
from nci_macro		import 	user_func;
from NDmacro		import	ACreturn_foot,ACgive_structure;
from ACcpx		import	find_macro;

/* @@@@@   static buffers, redo in dynamic  @@@@@  */
static char			*VRfailed_names[50];
static struct ret_struct	VRfailed_default[50];

/*****************************************************************************/

VRget_cache_attr (my_model,num_pts,attr)

struct 	GRid 		*my_model; 	/* I */
int	num_pts;			/* I */
struct	VRcp_attr 	*attr;		/* I/O assumes that cpt_attr are    */
					/*			 allocated  */
/*.VRget_cache_attr*/
{
int 		i,status;
IGRlong 	msg;
char 		str[16];
struct 	GRid 	foot_GRid;
     
SetProc( Func_VRget_cache_attr ); Begin
/*"ATTR  name of model %d\n", my_model->objid  */

 for(i=0;i<num_pts;i++)
   {
     VRCptEncode (i, str, NULL);

     /*"ATTR  name of cpt [%d] : %s\n", i, str */
    status = om$send(msg = message NDmacro.ACreturn_foot(&msg,
                                        str,&foot_GRid,NULL,NULL),
                senderid = my_model->objid,
                targetid = my_model->objid,targetos = my_model->osnum );
    as$status(  );
    status = om$send(msg = message nci_macro.user_func(
                                        "cpt_attr",NULL,(char *) &(attr[i])),
                senderid = my_model->objid,
                targetid = foot_GRid.objid,targetos = foot_GRid.osnum );
    as$status(  );

   }

End
return OM_S_SUCCESS;
}/* end VRget_cache_attr */

/*****************************************************************************/

VRget_cp_attr (my_model,nCpNum,attr)

struct 	GRid 		*my_model; 	/* I */
IGRshort		nCpNum;		/* I */
struct	VRcp_attr 	*attr;		/* I/O assumes that cpt_attr are    */
					/*			 allocated  */
/*.VRget_cp_attr*/
{
int 		status;
IGRlong 	msg;
char 		str[16];
struct 	GRid 	foot_GRid;
     
SetProc( Func_VRget_cp_attr ); Begin
/*"ATTR  name of model %d\n", my_model->objid  */

     VRCptEncode ((IGRint) nCpNum, str, NULL);

     /*"ATTR  name of cpt [%d] : %s\n", nCpNum, str */
    status = om$send(msg = message NDmacro.ACreturn_foot(&msg,
                                        str,&foot_GRid,NULL,NULL),
                senderid = my_model->objid,
                targetid = my_model->objid,targetos = my_model->osnum );
    as$status( action = RET_STATUS );
    status = om$send(msg = message nci_macro.user_func(
                                        "cpt_attr",NULL,(char *) attr),
                senderid = my_model->objid,
                targetid = foot_GRid.objid,targetos = foot_GRid.osnum );
End
return status;

}/* end VRget_cp_attr */

/*****************************************************************************/


VRget_cache_pnts (my_model,num_pts,cpt_geom,md_env )

struct 	GRid 		*my_model;		/* I */
int			*num_pts;		/* I */
IGRdouble  		*cpt_geom;   	/* I/O your array i fill it */ 
struct 	GRmd_env 	*md_env;	/* I */

/*. VRget_cache_pnts*/
{
int 		i,j,status,suc,m_1;
char 		str[20];
struct ret_struct	r_pnt;

 SetProc( Func_VRget_cache_pnts ); Begin
 for(i=0;i< *num_pts;i++)
   {
     VRCptEncode (i, str, ":graphic");

    /*" name of cpt [%d] : %s\n", i, str */

    m_1=-1;
    status = om$send(msg 	 = message NDmacro.ACgive_structure
		   			(&suc,&m_1,str,&r_pnt,md_env),
                senderid = my_model->objid,
                targetid = my_model->objid,targetos = my_model->osnum );
    as$status(  );
    for(j=0;j<3;j++)
	{
	cpt_geom[i*3+j] = r_pnt.var.point_st.pt[j];
        /*" index of cpt vec  [%d] : %f\n",i*3+j , cpt_geom[i*3+j]*/
	}
   }

End
return OM_S_SUCCESS;
}/* end VRget_cache_pnts */

/*****************************************************************************/


VRnum_cpts(mac_name,num_pts)

char	 		*mac_name;		/* I */
int			*num_pts;		/* O */
{
int 		i,status;
struct 	GRid 	mac_def;
int 		feet_num; 
struct 		myfeet *myfeet;

   SetProc( Func_VRnum_cpts ); Begin
	status =
	ac$find_macro_defn( 	action		= ACfind_load,
		      	       macro_name 	= mac_name,
		      	       p_macro_defn_id 	= &mac_def );
	if ( !(status & 1) )
        {
           End
           return OM_E_ABORT;
        }

	status =
	om$send(msg = message ACcpx_defn.ACgive_feet_desc(&feet_num,&myfeet),
		senderid = mac_def.objid,
		targetid = mac_def.objid,targetos = mac_def.osnum );
	as$status( action = RET_STATUS );

	*num_pts=0;

	for(i=0;i<feet_num;i=i+1)
	{
		if(!strncmp(myfeet[i].name,"VRcpt_",6)) *num_pts +=1;
	}

End
return OM_S_SUCCESS;

}/* end VRnum_cpts */

/*****************************************************************************/

IGRint	VRGetGeom ( pGraphicsId, CpFrom, CpTo, dCpCoors, md_env )
struct GRid	*pGraphicsId;	/* I : macro occurrence Id */
IGRint		CpFrom;
IGRint		CpTo;
IGRdouble	*dCpCoors;
struct GRmd_env	*md_env;

/*. VRGetGeom */
{

	IGRint			status;
	IGRlong			retmsg;
	IGRint			CpNum,Index=-1;
	struct ret_struct	AttrSt;
	IGRchar 		footname[20];

        SetProc( Func_VRGetGeom ); Begin
	if ( CpFrom > CpTo || CpFrom < 0 || CpTo > VR_MAX_CPTS )
        {
          End
          return OM_E_INVARG;
        }

	/* -- Get Cpt coordinates -- */

	for (CpNum = CpFrom; CpNum <= CpTo; CpNum++ )
	{
		VRCptEncode (CpNum, footname, ":graphic");

		status = 
		om$send ( msg = message NDmacro.ACgive_structure 
					( (IGRint *) &retmsg, &Index,
					 footname, &AttrSt, md_env ),
			senderid = NULL_OBJID,
			targetid = pGraphicsId->objid,
			targetos = pGraphicsId->osnum );
		as$status ( action = RET_STATUS );

		dCpCoors[3*CpNum  ] = AttrSt.var.point_st.pt[0];
		dCpCoors[3*CpNum+1] = AttrSt.var.point_st.pt[1];
		dCpCoors[3*CpNum+2] = AttrSt.var.point_st.pt[2];

	}/* end loop on connect points */

End
return OM_S_SUCCESS;

}/* end VRGetGeom */

/*****************************************************************************/

VRedit_macro(mac_name,num_up,temp_GRid,rep_test,md_env)
char 		*mac_name;	/* I	this is the macro name */
int		num_up;		/* I	 */
struct 	GRid	*temp_GRid;	/* I	 */
int		*rep_test;
struct 	GRmd_env 	*md_env;
/*. VRedit_macro*/
{
struct GRid 		macro_defn;
IGRint			temp_num, status,i,j,m_1,suc,rep_inc;
struct stemp 		*dtemp,*sstemp;
struct sup 		*dup;
struct ret_struct	r_value;

	/*" Edition of macro : %s\n",mac_name */
	status = 
	ac$find_macro_defn( 	action		= ACfind_load,
		      	       macro_name 	= mac_name,
		      	       p_macro_defn_id 	= &macro_defn );
	if (!(status&1) ) return (status);


	/*| locate macro find template definition */
	status = om$send(	msg	 = message ACcpx_defn.ACgive_temp_desc
						( &temp_num, &sstemp ),
		senderid = macro_defn.objid,
		targetid = macro_defn.objid,
		targetos = macro_defn.osnum );
	as$status( action = RET_STATUS );

	rep_inc=0;
        if(!strcmp("~rep",sstemp[0].name)) 
             {
	     /*| Theirs a ~rep in here  */
	     rep_inc=1;
	     }
        *rep_test=rep_inc;

	for(i=0;i<temp_num;i++)
	{
		if(strcmp(sstemp[i].down_scan,".")) return(OM_S_SUCCESS);
	}
 

	if(temp_num) 
	{
		dup 	= (struct sup  *)
		  _MALLOC( (num_up+rep_inc), struct sup );
		dtemp 	= (struct stemp  *)
		  _MALLOC( temp_num, struct stemp );
		if ( !dup || !dtemp )
		{ printf ("MALLOC FAILED \n"); return OM_E_ABORT;}
	}

        if(rep_inc) 
             {
	        sprintf(dup[0].prompt,"~rep");
		strcpy(dup[0].up_scan,".");
		dtemp[0]=sstemp[0];
		dup[0].type=dtemp[0].type;
	     }

	for(i=rep_inc;i<num_up+rep_inc;i++)
	{
		sprintf(dup[i].prompt,"PBOX%d",i);
		strcpy(dup[i].up_scan,".");
		dup[i].type=macro_generic;
	}


	for(i=rep_inc;i<temp_num;i++)
	{
		dtemp[i]=sstemp[i];
		for(j=rep_inc;j<num_up+rep_inc;j++)
		{
			m_1=-1;
			status = om$send(msg 	 = message NDmacro.ACgive_structure
						(&suc,&m_1,dtemp[i].name,&r_value,md_env ),
				senderid = macro_defn.objid,
				targetid = temp_GRid[j-rep_inc].objid,
				targetos = temp_GRid[j-rep_inc].osnum );
			as$status();
			if(suc&1)
			{
				strcpy(dtemp[i].down_scan,dtemp[i].name);
				dtemp[i].back=j;
				goto Lsucc;
			}
		}
		printf("** VRedit failed to find %s in a para box \n",
					dtemp[i].name);
		return OM_E_ABORT;
		Lsucc: j=0;
	}

	status = om$send( msg =message ACmacro_defn.ACtake_template
					(num_up+rep_inc,dup,temp_num,dtemp),
			senderid = macro_defn.objid,
			targetid = macro_defn.objid,
			targetos = macro_defn.osnum  );
	as$status();

	if(temp_num) 
	{
		_FREE(dup); 
		_FREE(dtemp); 
	}

return OM_S_SUCCESS;
}/* end VRedit */


/* ========================================================================= */

IGRint	VRtest_macro(mac_name,num_up,temp_GRid,failed_num,failed_names,failed_default,md_env)

char			*mac_name;		/* I	this is the macro name */
int			num_up;			/* I	 */
struct	GRid		*temp_GRid;		/* I	 */
int			*failed_num;		/* O	 */
char			***failed_names;	/* I/O	Static buf max 10.Missing names */
struct 	ret_struct	**failed_default;	/* I/O	Static buf max 10.Default objids*/
struct 	GRmd_env 	*md_env;

/*. VRtest_macro*/
{

struct GRid 		macro_defn,def_GRid;
IGRint			temp_num, status,i,j,m_1,suc,rep_inc;
struct stemp 		*sstemp;
struct ret_struct	r_value;
char 			full_name[DI_PATH_MAX];

	/* Reset number of missing templates */
	if (failed_num) *failed_num=0;

	/*" Test macro : %s\n",mac_name */
	status = 
	ac$find_macro_defn( 	action		= ACfind_load,
		      	       macro_name 	= mac_name,
		      	       p_macro_defn_id 	= &macro_defn );

	if( !status&1 )	return status;

	/*| Get templates' names */
	status = om$send(	msg	 = message ACcpx_defn.ACgive_temp_desc
						( &temp_num, &sstemp ),
		senderid = macro_defn.objid,
		targetid = macro_defn.objid,
		targetos = macro_defn.osnum );
	as$status( action = RET_STATUS );

	rep_inc=0;
        if(!strcmp("~rep",sstemp[0].name)) 
        {
		/*| Theirs a ~rep in here  */
		rep_inc=1;
	}

	/* -- Get Default Parameters Collection Id -- */

	status = di$untranslate(objid = macro_defn.objid,
				osnum = macro_defn.osnum,
				objname = full_name);
	def_GRid.objid=NULL_OBJID;
	if((status&1))
	{ 
		strcat(full_name,"$def");
		status = 
		di$translate(	objname = full_name,
				p_objid = &def_GRid.objid,
				p_osnum = &def_GRid.osnum);
		if((status&1)) 
		{
			/*"def_id was %d %d\n",def_GRid.objid,def_GRid.osnum */
		}
	}
 

	/* -- Scan for Templates' existence int he specified template objects -- */

	for(i=rep_inc;i<temp_num;i++)
	{
		/* -- Try to find the template name in one of the specified objects -- */
		for(j=0;j<num_up;j++)
		{
			m_1=-1;
			/*"temp name  %s\n", sstemp[i].name */
			status = om$send(msg 	 = message NDmacro.ACgive_structure
						(&suc,&m_1,sstemp[i].name,&r_value,md_env ),
				senderid = macro_defn.objid,
				targetid = temp_GRid[j].objid,
				targetos = temp_GRid[j].osnum );
			as$status();

			if(suc&1)
			{
				goto Lsucc;
			}
		}/* end loop on template objects */

		/*"-------> template %s is missing <-------\n",sstemp[i].name */
		if ( failed_num && (failed_names || failed_default) )
		{
			/*| Save template name and default */
			VRfailed_names[*failed_num]=sstemp[i].name;

			status = om$send(msg 	 = message NDmacro.ACgive_structure
						(&suc,&m_1,sstemp[i].name,
						&VRfailed_default[*failed_num],md_env ),
				senderid = macro_defn.objid,
				targetid=def_GRid.objid,
				targetos=def_GRid.osnum);
			as$status();

			*failed_num +=1;

		}/* end save missing parameter name */


		Lsucc: j=0;
	}

	/* -- If there are unknown templates, return them with their default values -- */

	if(failed_num && *failed_num)
	{
		if(failed_names) 	*failed_names=VRfailed_names;
		if(failed_default) 	*failed_default=VRfailed_default;
	}


return OM_S_SUCCESS;

}/* end VRtest */

/* ========================================================================= */
/* 	Translate the expression return structures to ACrg_coll structures
/* */

IGRint	VRExtractExpStr ( msg, NbObjs, ObjNames, ObjStr, NbExps,  ExpStr )

IGRlong			*msg;		/* O	completion code */
IGRint			NbObjs;		/* I	Number of object to process */
IGRchar			**ObjNames;	/* I	List of objects' names */
struct ret_struct	*ObjStr;	/* I	List of objects */
IGRint			*NbExps;	/* O	Number of found expressions */
struct ACrg_coll	*ExpStr;	/* O	List of expression's structures */

/*.VRExtractExprStr*/
{
register IGRint		i;

*msg = MSSUCC;

/* initialise argument */
if ( NbExps )	*NbExps = 0;
else		return OM_E_INVARG;

for (i=0; i<NbObjs; i++ )
{
	if ( ObjStr[i].type & parameter_generic )
	{
		if (ExpStr)
		{
			strcpy (ExpStr[*NbExps].name, ObjNames[i]);

			/* check on text or double type */
			if ( ObjStr[i].type == double_type )
			{/*" Create exp %f\n",ObjStr[i].var.root_pm_st.value */
				ExpStr[*NbExps].desc.type 	= AC_ATTRIB_DOUBLE;
				ExpStr[*NbExps].desc.value.att_exp =
					ObjStr[i].var.root_pm_st.value;
			}
			else if ( ObjStr[i].type == text_type )
			{/*" Create text %s\n",ObjStr[i].var.text_st.text_string */
					ExpStr[*NbExps].desc.type 	= AC_ATTRIB_TEXT;
				strcpy (ExpStr[*NbExps].desc.value.att_txt ,
					ObjStr[i].var.text_st.text_string) ;
			}
			else 
			{
				printf ("parameters %s has a bad type\n",ObjNames[i]);
				continue;
			}
		}/* end Fill ACrg_coll structure */

		*NbExps +=1;

	} /* end expression treatment */
		
}/* end scanning */

return OM_S_SUCCESS;

};

/*	----------------------------------------------------------------------	*/
/*	This function must be called first with NULL as TempNames to get back the 
/*	number of templates (NbTemp) and allocate a big enough array of TempNames */
/*	----------------------------------------------------------------------	*/

IGRint	VRGetTempNames(mac_name,NbTemp,TempNames)

char			*mac_name;		/* I	this is the macro name */
int			*NbTemp;		/* O	*/
IGRchar			*TempNames[];		/* O	*/

/*.VRGetTempNames*/
{

struct GRid 		macro_defn;
IGRint			status;
struct stemp		*sstemp;

	/*" Macro name : %s\n",mac_name */
	status = 
	ac$find_macro_defn( 	action		= ACfind_load,
		      	       macro_name 	= mac_name,
		      	       p_macro_defn_id 	= &macro_defn );
	as$status( action = RET_STATUS );

	/*| Get templates' names */
	status = om$send(	msg	 = message ACcpx_defn.ACgive_temp_desc
						( NbTemp, &sstemp ),
		senderid = macro_defn.objid,
		targetid = macro_defn.objid,
		targetos = macro_defn.osnum );
	as$status( action = RET_STATUS );

	/*" %d templates\n", *NbTemp */

	/* -- If TempNames array is specified, fill it with the names -- */

	if ( TempNames )
	{
		register IGRint	i;

		/*| Return the template names */

		for ( i=0; i<*NbTemp; i++ )
		{
		 	TempNames[i] = sstemp[i].name;
		}

	}/* end return TempNames */

return OM_S_SUCCESS;

}/* end VRGetTempNames */

IGRint  VRCptEncode (IGRint      nCP,
                     IGRchar    *szStr,
                     IGRchar    *szAdd)
{
  if (szStr)
  {
    sprintf (szStr,"VRcpt_%02d",nCP);
    if (szAdd)
      strcat (szStr,szAdd);
  }

  return (OM_S_SUCCESS);
}

end implementation Root;

