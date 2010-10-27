/* $Id: VDintfsupp.I,v 1.3 2001/01/12 19:17:38 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintf/imp/VDintfsupp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDintfsupp.I,v $
 *	Revision 1.3  2001/01/12 19:17:38  hans
 *	SP16 import to CVS
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	05/21/96	HF		Creation Date
 *					File has been split in two because of
 *					multi-defined symbols when linking an
 *					integrated MODEL_VDS_... executable.
 *					(EMintfsupp.I && VDintfsupp.I)
 *
 * -------------------------------------------------------------------*/

class implementation EMSsurface;

#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "griodef.h"
#include "msdef.h"

#include "DItypedef.h"
#include "DIdef.h"	/* PATH_MAX */
#include "DIglob.h"	/* DItranslate */
#include "DImacros.h"   /* di$.. */
#include "DIprims.h"
#include "go.h"         /* GRobj_info for obj indentifier */

#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emssfint.h"
#include "EMSintf.h"
#include "griodef.h"
#include "msdef.h"
#include "emssfintdef.h"
#include "emsbool.h"
#include "emserr.h"
#include "DItypedef.h"
#include "DIdef.h"	/* PATH_MAX */
#include "DIglob.h"	/* DItranslate */
#include "DImacros.h"   /* di$.. */
#include "DIprims.h"
#include "go.h"         /* GRobj_info for obj indentifier */
#include "EMSmsgdef.h"

#include	<v_miscmacros.h>

#define	VD_DEBUG
#include	<VDdebug.h>

/* ex$message */
# include "msmacros.h"

# include "grmacros.h"	/* */

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vdparmacros.h"   /* vd$.. */
#include "acrepdef.h"	/* AC_2D_REP etc... */

from GRowner		import	GRget_number_components, GRget_components;
from ACncpx		import	ACget_NV_rep;
from ACrg_collect	import	AClist_attribute;

extern GRclassid OPP_GRgrset_class_id;

#define	EPS_HIGH	(1e-7)
#define POSSIBLE_SYMB ":IGENOD:ACpossible_symb"

int	VD_Interference_Analysis;	/* GLOBAL : TRUE if VDS Interference Analysis is active	*/
					/* 	    FALSE otherwise				*/

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDintf_get_possible_rep_col
(
  OMuword      osnum,           /* Input        */
  struct GRid *coll             /* Output       */
)
{
  IGRint        sts;
  IGRchar       path_name[DI_PATH_MAX];

    coll->objid = NULL_OBJID;
    path_name[0]= '\0';

    sts = di$give_pathname (    osnum           = osnum,
                                pathname        = path_name );
    if ( sts == DIR_S_SUCCESS )
    {
      strcat( path_name, POSSIBLE_SYMB );

      sts = di$translate (      objname         = path_name,
                                osnum           = osnum,
                                p_objid         = &coll->objid,
                                p_osnum         = &coll->osnum );
      if( ! ( sts & 1 ) )
      {
        coll->objid = NULL_OBJID;
      }
    }

  return 1;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

double eps_tst
(
    double eps,
    double x
)
{
    double dmy = x;

    if ( dmy < 0 ) dmy = -dmy;
    if ( eps < 0 ) eps = -eps;
    if ( eps > EPS_HIGH )
    {
	/* Do Nothing : 'eps' is too large ==> 'dmy = x' */
    }
    else
    {
	dmy = 0.0;
    }
    return (dmy);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDintf_cat_name_to_ident
(
    struct GRid *id,		/* Input	  */
    IGRchar	*str		/* Input / Output */
)
{
    char	obj_name[DI_PATH_MAX];
    char	*ptr = NULL;
    IGRlong	sts  = 0;

  __enterFunction ( name = "VDintf_cat_name_to_ident" );

    /* add object name to 'str', if it exists */
    sts = di$untranslate (	objname = obj_name,
				objid   = id->objid,
				osnum   = id->osnum);
    if (sts == DIR_S_SUCCESS)
    {
	/* Remove PATH from obj_name */
	strcpy(obj_name, ptr = (strrchr(obj_name,':')) + 1);
	if ( (strlen(str) + strlen(obj_name) + 3) < DI_PATH_MAX )
	{
	    if (strlen(str) > 0) strcat(str," - ");
	    strcat(str,obj_name);
	}
    }

  __exitFunction ( name = "VDintf_cat_name_to_ident" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDintf_rep_info
(
  char			*obj_identifier,
  struct GRlc_info	*eleinfo
)
{
# define	LIST_SIZE	(8)

  IGRlong		msg;
  IGRint		k0, sts = 0;
  int			n_prms = 2, data_size = 0, found_rep = FALSE;
  struct GRid		collct;
  struct ACrg_coll	rg_coll[2];
  struct ACrg_coll	rg_list[LIST_SIZE];
  unsigned char		ac_rpr;

  struct GRsymbology	symbology;

  __enterFunction ( name = "VDintf_rep_info" );

  strcpy(rg_coll[0].name , "n_itemno");
  strcpy(rg_coll[1].name , "n_itemname");

  VDintf_cat_name_to_ident (&eleinfo->located_obj, obj_identifier);

  sts = gr$get_symbology( object_id = &eleinfo->located_obj, symb = &symbology );

  if ( sts & 1 )
  {
    sprintf(obj_identifier,"%s - layer %d",obj_identifier, symbology.level);
  }

  rg_coll[0].desc.value.att_txt[0] = '\0';
  rg_coll[1].desc.value.att_txt[0] = '\0';

  sts = vd$review_parameters (	pMsg		= &msg,
				pComponent	= &eleinfo->located_obj,
				NbParams	=  n_prms,
				pList		=  rg_coll,
				pMdEnv		= &eleinfo->module_info);

  if ( sts == 1 && msg == MSSUCC &&
       rg_coll[1].desc.type == 1 && strlen (rg_coll[1].desc.value.att_txt) > 0 )
  {
    sprintf(obj_identifier,"%s - %s",obj_identifier, rg_coll[1].desc.value.att_txt);
  }

  sts = om$send (	msg	 = message ACncpx.ACget_NV_rep ( &ac_rpr ),
			targetid = eleinfo->located_obj.objid,
			targetos = eleinfo->located_obj.osnum,
			senderid = NULL_OBJID);
  if ( sts & 1 )
  {
    VDintf_get_possible_rep_col ( eleinfo->located_obj.osnum, &collct );

    data_size = 0;
    sts = om$send (	msg	 = message ACrg_collect.AClist_attribute(
							&msg,
							 LIST_SIZE,
							 rg_list,
							&data_size ),
			targetid = collct.objid,
			targetos = collct.osnum,
			senderid = NULL_OBJID);

    if ( (sts & msg & 1) && data_size )
    {
      found_rep = FALSE;
      for ( k0=0; k0 < data_size; k0++ )
      {
	if ( rg_list[k0].desc.type == 2 && ac_rpr == (unsigned char) rg_list[k0].desc.value.att_exp )
	{
	  sprintf(obj_identifier,"%s - Repr:%s",obj_identifier, rg_list[k0].name);

	  found_rep = TRUE;

	  break;
	}
      }
      if ( ! found_rep )
      {
        sprintf(obj_identifier,"%s - Repr:UNKNOWN",obj_identifier );
      }
    }
  }

  __exitFunction ( name = "VDintf_rep_info" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDintf_rep_info_2
(
  unsigned char	 ac_rpr,
  OMuword	 osnm,
  char		*obj_rep
)
{
# define	LIST_SIZE	(8)

  IGRlong		msg;
  IGRint		k0, sts = 0;
  int			data_size = 0, found_rep = FALSE;
  struct GRid		collct;
  struct ACrg_coll	rg_list[LIST_SIZE];

  __enterFunction ( name = "VDintf_rep_info_2" );

  VDintf_get_possible_rep_col ( osnm, &collct );

  data_size = 0;
  sts = om$send (	msg	 = message ACrg_collect.AClist_attribute(
							&msg,
							 LIST_SIZE,
							 rg_list,
							&data_size ),
			targetid = collct.objid,
			targetos = collct.osnum,
			senderid = NULL_OBJID);

  if ( (sts & msg & 1) && data_size )
  {
    found_rep = FALSE;
    for ( k0=0; k0 < data_size; k0++ )
    {
      if ( rg_list[k0].desc.type == 2 && ac_rpr == (unsigned char) rg_list[k0].desc.value.att_exp )
      {
	strcpy ( obj_rep, rg_list[k0].name);

	found_rep = TRUE;

	break;
      }
    }
    if ( ! found_rep )
    {
      strcpy ( obj_rep,"Unknown" );
    }
  }

  __exitFunction ( name = "VDintf_rep_info_2" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

#include "DItypedef.h"
#include "DIdef.h"	/* DI_PATH_MAX */
#include "DIglob.h"	/* DItranslate */
#include "DImacros.h"   /* di$.. */
#include "DIprims.h"
#include "OMlimits.h"
#include "OMprimitives.h"

#argsused // Lots of warnings

void VD_EMintf_report (	numcked,
			ele1, num_ele1, setnum1, setinfo1,
			ele2, num_ele2, setnum2, setinfo2,
			result, num_result, options, ptr, start_time)
IGRint		  numcked;
struct GRlc_info *ele1, *setinfo1;
IGRint		  num_ele1, setnum1;
struct GRlc_info *ele2, *setinfo2;
IGRint		  num_ele2, setnum2;
struct EMSintf   *result;
IGRint		  num_result;
IGRushort	  options;
IGRchar		 *ptr;
IGRchar		 *start_time;
{
  IGRint i, j, totintf;

//IGRint status; // No longer used

  struct EMSintf		*this_result;
  struct EMSintf_qualitative *ptr1;
  struct EMSintf_xsec	*ptr2;
  IGRchar		elename0[DI_PATH_MAX];
  IGRchar		elename1[DI_PATH_MAX], elename2[DI_PATH_MAX];
  IGRboolean		quali = FALSE, xsec = FALSE, osfound = FALSE;
  extern void		MSget_master_string();
  IGRdouble		factor;
  IGRchar		master_units[80];
  GRspacenum		objos,tosnum;
  IGRint 		m, n, p;
  IGRlong 		msg;
  extern char            *EMgettime();
  IGRchar                obj_identifier[DI_PATH_MAX];
//IGRchar                obj_informat  [DI_PATH_MAX];   // Not used
  char                   obj_filenm[OM_K_MAXOSNAME_LEN];
  struct GRlc_info	*eleinfo;

/*
 * For printing, move down in function if ever need again
 */
  GRrange                rng;
  IGRpoint               keypt;

  __enterFunction ( name = "VD_EMintf_report" );

  objos = 0; // Get rid of warning

  fprintf ((FILE *)ptr, "\n");
  fprintf ((FILE *)ptr, "  INTERFERENCE ANALYSIS REPORT           Finished: %s",  EMgettime());
  fprintf ((FILE *)ptr, "                                         Started : %s\n",start_time);

  EMintf_getname (&setinfo1->located_obj, &setinfo1->module_info, elename1);
  if (setnum1 == setnum2)
    fprintf ((FILE *)ptr, "\tSet #%d (%s)\n\n", setnum1, elename1);
  else
  {
    EMintf_getname (&setinfo2->located_obj, &setinfo2->module_info, elename2);
    fprintf ((FILE *)ptr, "\tSet #%d (%s) - Set #%d (%s)\n\n", setnum1, elename1, setnum2, elename2);
  }

  if(num_result)
  {
    if(result[0].intfInfoType == EMqualitative)
      quali = TRUE;
    else if(result[0].intfInfoType == EMxsection)
      xsec = TRUE;

    fprintf ((FILE *)   ptr, "\tSUMMARY:\n");
    fprintf ((FILE *)   ptr, "\tNumber of elements in Set #%d = %d\n", setnum1, num_ele1);
    if (setnum1 != setnum2)
      fprintf ((FILE *) ptr, "\tNumber of elements in Set #%d = %d\n", setnum2, num_ele2);

    if (quali)
    {
      totintf = 0;
      for (i=0; i<num_result; i++)
	for (j=0; j<result[i].numintf; j++)
	  totintf++;

      fprintf ((FILE *)  ptr, "\tNumber of unique pairs of interfering elements = %d\n", totintf);
      if (setnum1 != setnum2)
	fprintf ((FILE *)ptr, "\tNumber of interfering elements in Set #%d = %d\n", setnum1, num_result);
      else
	fprintf ((FILE *)ptr, "\tNumber of elements describing the interferences = %d\n", num_result);
    }
    fprintf ((FILE *)ptr, "\n");

    if(xsec && result)
    {
      for(i=0; (i<num_result) && !osfound; i++)
	for(j=0; (j<result[i].numintf) && !osfound; j++)
	  for(m=0; (m<NumIntfCases) && !osfound; m++)
	    for(n=0; (n<2) && !osfound; n++)
	    {
	      if(!result[i].info.xsec[j].NumOcc[m][n]) continue;
	      objos = result[i].info.xsec[j].linesegs[m][n][0].osnum;
	      osfound = TRUE;
	    }
      if(osfound)
      {
	MSget_master_string(&msg, objos, master_units, &factor);
	if(!(1&msg)) osfound = FALSE;
	fprintf((FILE *)ptr, "\tAll distances in %s\n", master_units);
      }
    }

    fprintf ((FILE *)ptr, "\tDETAILS:\n");
    for(i=0; i<num_result; i++)
    {
      this_result = &result[i];

      if(quali)
      {
	sprintf(elename0, "ID-%d/OS-%d", this_result->eleminfo.located_obj.objid, this_result->eleminfo.located_obj.osnum);
	fprintf((FILE *)ptr, "\t%2d) Element - %s - interferes with %d element(s)\n", i+1, elename0, this_result->numintf);

	eleinfo = &this_result->eleminfo;

	EMintf_getident (&eleinfo->located_obj, obj_identifier);

	if ( VD_Interference_Analysis == TRUE )
	{
	  VDintf_rep_info ( obj_identifier, eleinfo );
	}

	fprintf((FILE *)ptr, "\t    identifier : %s\n", obj_identifier);

	tosnum= eleinfo->located_obj.osnum;
	om$os_number_to_name (osnum=tosnum, osname=obj_filenm);

	fprintf((FILE *)ptr, "\t    filename   : %s\n", obj_filenm);

/*
  DO NOT Print range & keypt
*/
	if ((EMintf_getrange (&eleinfo->located_obj, &eleinfo->module_info, rng)) == EMS_E_Fail)
	  fprintf((FILE *)ptr, "\t    range      : unknown\n");
	else
	{
	  fprintf((FILE *)ptr, "\t    range (min): %g %g %g\n", rng[0], rng[1], rng[2]);
	  fprintf((FILE *)ptr, "\t    range (max): %g %g %g\n", rng[3], rng[4], rng[5]);
	}

	if ((EMintf_keypoint (&eleinfo->located_obj, &eleinfo->module_info, keypt)) == EMS_E_Fail)
	  fprintf((FILE *)ptr, "\t    keypoint   : unknown\n");
	else
	  fprintf((FILE *)ptr, "\t    keypoint   : %g %g %g\n", keypt[0], keypt[1], keypt[2] = eps_tst ( 1e-10, keypt[2] ));
/**/
	for(j=0; j<this_result->numintf; j++)
        {
	  ptr1 = &this_result->info.qualitative[j];

	  sprintf(elename0, "ID-%d/OS-%d", ptr1->against_eleminfo.located_obj.objid, ptr1->against_eleminfo.located_obj.osnum);
	  fprintf((FILE *)ptr, "\t\t%2d) %s\n", j+1, elename0);

	  EMintf_getident(&ptr1->against_eleminfo.located_obj, obj_identifier);

	  if ( VD_Interference_Analysis == TRUE )
	  {
	    VDintf_rep_info ( obj_identifier, &ptr1->against_eleminfo );
	  }

	  fprintf((FILE *)ptr, "\t\t    identifier : %s\n", obj_identifier);

	  tosnum=(&ptr1->against_eleminfo.located_obj)->osnum;
	  om$os_number_to_name(osnum=tosnum,osname=obj_filenm);

	  fprintf((FILE *)ptr, "\t\t    filename   : %s\n", obj_filenm);

/*
  DO NOT Print range & keypt
*/
	  if ((EMintf_getrange(&ptr1->against_eleminfo.located_obj,
			       &ptr1->against_eleminfo.module_info,rng)) == EMS_E_Fail)
	    fprintf((FILE *)ptr, "\t\t    range      : unknown\n");
	  else
          {
	    fprintf((FILE *)ptr, "\t\t    range (min): %g %g %g\n", rng[0], rng[1], rng[2]);
	    fprintf((FILE *)ptr, "\t\t    range (max): %g %g %g\n", rng[3], rng[4], rng[5]);
          }
	  if ((EMintf_keypoint(&ptr1->against_eleminfo.located_obj,
			       &ptr1->against_eleminfo.module_info,keypt)) == EMS_E_Fail)
	    fprintf((FILE *)ptr, "\t\t    keypoint   : unknown\n");
	  else
	    fprintf((FILE *)ptr, "\t\t    keypoint   : %g %g %g\n", keypt[0], keypt[1], keypt[2] = eps_tst ( 1e-10, keypt[2] ));
/**/
        }
      }
      else
      {
	fprintf((FILE *)ptr, "Primary element- %s\n", elename0);
	fprintf((FILE *)ptr, "---------------\n");

	ptr2 = &this_result->info.xsec[0];

	if(!IF_NULL_OBJID(ptr2->areas[0].objid))
        {
	  EMintf_getname(&ptr2->areas[0], (struct GRmd_env *)NULL, elename0);
	  fprintf((FILE *)ptr, "Cross section - %s\n", elename0);
        }

	for(j=0; j<this_result->numintf; j++)
        {
	  ptr2 = &this_result->info.xsec[j];
	  EMintf_getname(&ptr2->against_eleminfo.located_obj,
			 &ptr2->against_eleminfo.module_info, elename0);
	  fprintf((FILE *)ptr, "%d) Check element - %s\n", j+1, elename0);
	  fprintf((FILE *)ptr, "   -------------\n");

	  if(!IF_NULL_OBJID(ptr2->areas[1].objid))
          {
	    EMintf_getname(&ptr2->areas[1], (struct GRmd_env *)NULL, elename0);
	    fprintf((FILE *)ptr, "Cross section -     %s\n", elename0);
          }

	  if(!IF_NULL_OBJID(ptr2->areas[2].objid))
          {
	    EMintf_getname(&ptr2->areas[2], (struct GRmd_env *)NULL, elename0);
	    fprintf((FILE *)ptr, "Interference area - %s\n", elename0);
          }

	  fprintf((FILE *)ptr, "Type                         Dist                  Segments\n");
	  fprintf((FILE *)ptr, "----                         ----                  --------\n");

	  for(m=0; m<NumIntfCases; m++)
          {
	    for(n=0; n<2; n++)
  	    {
	      if(!ptr2->NumOcc[m][n]) continue;

	      if( (m==Intf) && (n==0))
		fprintf((FILE *)ptr, "Min interference          ");
	      else if( (m==Intf) && (n==1))
		fprintf((FILE *)ptr, "Max interference          ");

	      if( (m==NestedIntf) && (n==0))
		fprintf((FILE *)ptr, "Min nested interference   ");
	      else if( (m==NestedIntf) && (n==1))
		fprintf((FILE *)ptr, "Max nested interference   ");

	      else if( (m==NestedCl) && (n==0))
		fprintf((FILE *)ptr, "Min nested clearance      ");
	      else if( (m==NestedCl) && (n==1))
		fprintf((FILE *)ptr, "Max nested clearance      ");

	      else if( (m==DisjointCl) && (n==0))
		fprintf((FILE *)ptr, "Min disjoint clearance    ");
	      else if( (m==DisjointCl) && (n==1))
		fprintf((FILE *)ptr, "Max disjoint clearance    ");

	      if(osfound)
		fprintf((FILE *)ptr, "%3.13lf", (ptr2->dist[m][n])/factor);
	      else
		fprintf((FILE *)ptr, "%3.13lf", ptr2->dist[m][n]);

	      for(p=0; p<ptr2->NumOcc[m][n]; p++)
	      {
		EMintf_getname(&ptr2->linesegs[m][n][p], (struct GRmd_env *)NULL, elename0);
		if(!p)
		  fprintf((FILE *)ptr, "    %s\n", elename0);
		else
		  fprintf((FILE *)ptr, "                                             %s\n", elename0);
  	      }
	    }
          }
	  fprintf((FILE *)ptr, "\n");
        }
      }
    }
  }
  else
  {
    fprintf ((FILE *)ptr, "\tNo interference found\n");
    goto wrapup;
  }

wrapup:;

  __exitFunction ( name = "VD_EMintf_report" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation EMSsurface;
