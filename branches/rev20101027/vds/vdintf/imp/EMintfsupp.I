/* $Id: EMintfsupp.I,v 1.2 2001/01/12 19:13:20 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintf/imp / EMintfsupp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: EMintfsupp.I,v $
 *	Revision 1.2  2001/01/12 19:13:20  hans
 *	SP16 import to CVS
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
 *	Initial import to CVS
 *
# Revision 1.2  1999/06/30  13:34:44  pinnacle
# Intersection Fix
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/12/09  19:12:38  pinnacle
# Replaced: vdintf/imp/*.I for:  by impd for vds
#
# Revision 1.3  1997/10/31  18:32:04  pinnacle
# UnInit warnings
#
# Revision 1.2  1997/08/04  16:35:08  pinnacle
# Replaced: vdintf/imp/EMintfsupp.I for:  by jwfrosch for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/05/21  17:43:00  pinnacle
# Replaced: vdintf/imp/EMintfsupp.I for:  by jwfrosch for vds.240
#
# Revision 1.3  1996/03/29  17:54:34  pinnacle
# Replaced: vdintf/imp/EMintfsupp.I for:  by jwfrosch for vds.240
#
# Revision 1.2  1995/07/24  14:39:16  pinnacle
# Replaced: vdintf/imp/EMintfsupp.I for:  by hverstee for vds.240
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
 *	05/21/96	HF		File has been split in two because of
 *					multi-defined symbols when linking an
 *					integrated MODEL_VDS_... executable.
 *					(EMintfsupp.I && VDintfsupp.I)
 *	10/31/97	ah		UnInit warnings
 * -------------------------------------------------------------------*/

/* ###################   APOGEE COMPILED   ################## */
/*
This file contains the support for interference analysis.
*/
class implementation EMSsurface;

#include "EMS.h"

#ifndef DEBUG
#define DEBUG 0
#endif

#if DEBUG
#define ResultBufInc	1
#else
#define ResultBufInc	10
#endif

#define MaxNameDup	10

#include <stdio.h>
#include <string.h>

#ifndef SUNOS5
%safe
#include <math.h>
%endsafe
#endif

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
#include	<vdsmacros.h>

#define	VD_DEBUG
#include	<VDdebug.h>

/* ex$message */
# include "msmacros.h"
#include "EC_M.h"       /* Command strings */
#include "EC_I.h"       /* Status strings */
#include "EC_P.h"       /* Prompt strings */
#include "EC_F.h"       /* Error box strings */
#include "EC_E.h"       /* Error strings */

# include "grmacros.h"	/* */

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vdparmacros.h"   /* vd$.. */
#include "acrepdef.h"	/* AC_2D_REP etc... */

from GRowner		import	GRget_number_components, GRget_components;
from ACncpx		import	ACget_NV_rep;
from ACrg_collect	import	AClist_attribute;

extern GRclassid OPP_GRgrset_class_id;

extern int VD_Interference_Analysis;	/* GLOBAL : TRUE if VDS Interference Analysis is active	*/
					/* 	    FALSE otherwise				*/

extern double	eps_tst();
extern void	VDintf_rep_info();

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

#argsused  // Get rid of warning

void EMintf_getname(id, md_env, elename)
struct GRid	*id;
struct GRmd_env *md_env;
IGRchar		*elename;
{
  IGRboolean	found;
  IGRlong	sts = OM_S_SUCCESS, rc = EMS_S_Success;
  IGRchar	locname[DI_PATH_MAX];
  GRclassid	objclass;

  __enterFunction ( name = "EMintf_getname" );

  om$get_classid (objid = id->objid, osnum = id->osnum, p_classid = &objclass);
  if (om$is_ancestry_valid (superclassid = OPP_GRgrset_class_id,
			    subclassid = objclass) != OM_S_SUCCESS)
  {
    found = FALSE;
    sts = om$send(msg = message GRvg.GRgetname(&rc, locname),
		  senderid = NULL_OBJID, targetid = id->objid,
		  targetos = id->osnum);
    if(1&rc&sts)
    {
      sts = di$cvt_name_for_output(s_path = locname, u_path = elename);
      if(1&sts)
	found = TRUE;
    }

    if (!found)
    {
      if (!IF_NULL_OBJID (id->objid))
	sprintf(elename, "ID-%d/OS-%d", id->objid, id->osnum);
      else
	elename[0] = NULL;
    }
  }
  else
    elename[0] = NULL;

  __exitFunction ( name = "EMintf_getname" );

  return;
}

void EMintf_failureReport(failed, num_failed, ptr)
struct EMSintf_failure	*failed;
IGRint	num_failed;
IGRchar	*ptr;
{
  IGRint		i, junk;
  IGRchar		elename1[DI_PATH_MAX], elename2[DI_PATH_MAX];
  extern IGRint		EFprintcode() ;

  __enterFunction ( name = "EMintf_failureReport" );

  fprintf((FILE *) ptr, "  %s\n", "Failure record --\n");
  for(i=0; i<num_failed; i++)
  {
    if(!IF_NULL_OBJID(failed[i].ele1.objid))
      EMintf_getname(&failed[i].ele1, (struct GRmd_env *)NULL, elename1);

    if(!IF_NULL_OBJID(failed[i].ele2.objid))
      EMintf_getname(&failed[i].ele2, (struct GRmd_env *)NULL, elename2);
    else strcpy(elename2, "Unknown");

    if(!IF_NULL_OBJID(failed[i].ele1.objid))
      fprintf((FILE *) ptr, " Element:           %s\n", elename1);

    if(!IF_NULL_OBJID(failed[i].ele2.objid))
      fprintf((FILE *) ptr, " Analyzing against: %s\n", elename2);

    fprintf((FILE *) ptr, " Error:             ");
    junk = EFprintcode(ptr, failed[i].msgcode);

    if(failed[i].type == EMqualitative)
    {
      if(failed[i].msgcode == EMS_E_BoolFail)
	fprintf((FILE *) ptr, "  - Volume element not created");
      else if(failed[i].msgcode == EMS_E_Intersect)
	fprintf((FILE *) ptr, "  - Interference curves not created");
    }
    else if(failed[i].type == EMxsection)
    {
      if(failed[i].msgcode == EMS_E_Intersect)
	fprintf((FILE *) ptr, "  - Could not generate cross section");
      else if(failed[i].msgcode == EMS_E_NoMoreLoops)
	fprintf((FILE *) ptr, "  - Analysis areas not created");
      else if(failed[i].msgcode == EMS_E_Fail)
	fprintf((FILE *) ptr, "  - Failure in computing min max distances");
    }
    fprintf((FILE *) ptr, "\n");
  }

  __exitFunction ( name = "EMintf_failureReport" );
}


void EMintf_free(inptr, num)
struct EMSintf *inptr;
IGRint	num;
{
  IGRint i, j, m, n;

  __enterFunction ( name = "EMintf_free" );

  for(i=0; i<num; i++)
  {
    if( (inptr[i].intfInfoType == EMqualitative) && inptr[i].info.qualitative)
    {
//     om$dealloc(ptr = inptr[i].info.qualitative);
      _FREE ( inptr[i].info.qualitative );
    }
    else if( (inptr[i].intfInfoType == EMxsection) && inptr[i].info.xsec)
    {
      for(j=0; j<inptr[i].numintf; j++)
	for(m=0; m<NumIntfCases; m++)
	  for(n=0; n<2; n++)
	    if(inptr[i].info.xsec[j].linesegs[m][n])
	    {
//	  om$dealloc(ptr = inptr[i].info.xsec[j].linesegs[m][n]);
	      _FREE ( inptr[i].info.xsec[j].linesegs[m][n] );
	    }
//     om$dealloc(ptr = inptr[i].info.xsec);
      _FREE ( inptr[i].info.xsec );
    }

  }
// if(inptr) om$dealloc(ptr = inptr);
  _FREE ( inptr );

 __exitFunction ( name = "EMintf_free" );
}


void EMintf_recordFailure(EMmsg, Ele1, Ele2, num_sofar, failed,
				    bufSize, type)
IGRlong			*EMmsg;
struct GRlc_info	*Ele1, *Ele2;
IGRint			*num_sofar;
struct EMSintf_failure	**failed;
IGRint			*bufSize;
enum EMSintfInfoType	type;
{

  __enterFunction ( name = "EMintf_recordFailure", argfmt = "*num_sofar = %d, *bufSize = %d, *failed = %#x", args = `*num_sofar, *bufSize, *failed` );

  if( ! *bufSize )
  {
    if( ! *failed )
    {
//   *failed = (struct EMSintf_failure *) om$malloc(size = ResultBufInc *	sizeof(struct EMSintf_failure));
      *failed = _MALLOC ( ResultBufInc,	struct EMSintf_failure );
      *bufSize = ResultBufInc;
    }
    else
    {
//   *failed = (struct EMSintf_failure *) om$realloc(ptr = (char *) *failed, size = ResultBufInc * sizeof(struct EMSintf_failure));
      *failed = _REALLOC ( *failed, *num_sofar + ResultBufInc, struct EMSintf_failure );
      *bufSize = ResultBufInc;
    }
  }

  if(*failed && *bufSize)
  {
    (*failed)[*num_sofar].type = type;
    if(Ele1)(*failed)[*num_sofar].ele1 = Ele1->located_obj;
    else (*failed)[*num_sofar].ele1.objid = NULL_OBJID;

    if(Ele2)(*failed)[*num_sofar].ele2 = Ele2->located_obj;
    else (*failed)[*num_sofar].ele2.objid = NULL_OBJID;

    if(EMmsg)(*failed)[*num_sofar].msgcode = *EMmsg;
    if(EMmsg)*EMmsg = EMS_S_Success;
    (*num_sofar)++;
    (*bufSize)--;
  }
  else *EMmsg = EMS_E_NoDynamicMemory;

  __exitFunction ( name = "EMintf_recordFailure" );

}



void EMintfDisplay(disenv, obj, hilite)
struct GRmd_env *disenv;
struct GRid	*obj;
IGRboolean	hilite;
{
  IGRlong	sts, EMmsg;
  IGRshort	*mxtyp;
  IGRdouble	*mx;
  struct GRid	md;
  enum GRdpmode	Display_Mode;
  IGRint		m;

  __enterFunction ( name = "EMintfDisplay" );

  mxtyp = &disenv->md_env.matrix_type;
  mx = disenv->md_env.matrix;
  md = disenv->md_id;

  for(m=0; m< (hilite ? 2 : 1); m++)
  {
    Display_Mode = m ? GRhd : GRbd;
    sts = om$send(msg = message GRgraphics.GRdisplay(
						     &EMmsg, mxtyp, mx, &Display_Mode, &md),
		  targetid = obj->objid, senderid = NULL_OBJID,
		  targetos = obj->osnum);
  }

  __exitFunction ( name = "EMintfDisplay" );
}



void EMintf_getident(id,str)
struct GRid *id;
IGRchar *str;
{
  IGRlong	sts = OM_S_SUCCESS, msg = EMS_S_Success;
  struct GRobj_info info;

  __enterFunction ( name = "EMintf_getident" );

  sts = om$send(msg = message GRgraphics.GRgetobjinfo(&msg, &info),
		senderid = NULL_OBJID,
		targetid = id->objid,
		targetos = id->osnum);

  if (sts & msg & 1)
  {
    strcpy(str,info.type);
  }
  else
    strcpy(str,"unknown");

  __exitFunction ( name = "EMintf_getident" );

}

IGRlong EMintf_getrange(id,disenv,rng)
struct GRid     *id;
struct GRmd_env *disenv;
GRrange         rng;
{
  IGRboolean    world;
  IGRlong sts = OM_S_SUCCESS, msg = EMS_S_Success;

  __enterFunction ( name = "EMintf_getrange" );

  world=TRUE;
  sts = om$send( msg = message GRgraphics.GRgetrang(&msg,
						    &disenv->md_env.matrix_type,disenv->md_env.matrix,&world,rng),
		 senderid = NULL_OBJID,
		 targetid = id->objid,
		 targetos = id->osnum);


  if (! (sts & msg & 1))
    msg=EMS_E_Fail;

  __exitFunction ( name = "EMintf_getrange" );

  return(msg);
}

IGRlong EMintf_keypoint(id,disenv,keypoint)
struct GRid     *id;
struct GRmd_env *disenv;
IGRpoint        keypoint;
{
  struct GRparms key_parm;
  struct IGRline dummyline;
  IGRpoint pt1, pt2;
  IGRlong sts = OM_S_SUCCESS, msg = EMS_S_Success;
  IGRlong RetErr;

  __enterFunction ( name = "EMintf_keypoint" );

  pt1[0]=0;
  pt1[1]=0;
  pt1[2]=0;
  pt2[0]=0;
  pt2[1]=0;
  pt2[2]=1;

  dummyline.point1=pt1;
  dummyline.point2=pt2;

  sts = om$send (msg = message GRvg.GRkeypoint
		 (&msg, &disenv->md_env.matrix_type,
		  disenv->md_env.matrix, &dummyline,
		  keypoint, &key_parm),
		 senderid = NULL_OBJID,
		 targetid = id->objid,
		 targetos = id->osnum);


  RetErr=msg;

  __exitFunction ( name = "EMintf_keypoint" );

  return(RetErr);
}


void EMintf_christen(toid, refid1, refid2, str, elename)
struct GRid	*toid, *refid1, *refid2;
IGRchar		*str, *elename;
{
  IGRlong	sts = OM_S_SUCCESS, rc = EMS_S_Success;
  IGRchar	locname[DI_PATH_MAX], junk[2][DI_PATH_MAX], loccopy[DI_PATH_MAX],
    num[10];
  IGRint		i;

  __enterFunction ( name = "EMintf_christen" );

  if(refid1)
    sprintf(junk[0], "%d.%d", refid1->osnum, refid1->objid);
  if(refid2)
  {
    if(refid1)
      sprintf(junk[1], ".%d.%d", refid2->osnum, refid2->objid);
    else
      sprintf(junk[1], "%d.%d", refid2->osnum, refid2->objid);
  }

  if(refid1)
    strcpy(locname, junk[0]);

  if(refid2)
  {
    if(refid1) strcat(locname, junk[1]);
    else strcpy(locname, junk[1]);
  }

  for(i=0; i<MaxNameDup; i++)
  {
    strcpy(loccopy, locname);
    sprintf(num, ".%d", i+1);
    strcat(loccopy, num);

    if(str)
    {
      strcat(loccopy, ".");
      strcat(loccopy, str);
    }

    sts = om$send(msg = message GRvg.GRputname(&rc, loccopy),
		  senderid = NULL_OBJID, targetid = toid->objid,
		  targetos = toid->osnum);
    if(1&rc&sts)
    {
      if(elename) strcpy(elename, loccopy);
      break;
    }
  }

  __exitFunction ( name = "EMintf_christen" );
}

#include <sys/types.h>
#include <time.h>
char * EMgettime()
{

  time_t ret,timinsec;
  time_t *timeptr;

  timinsec=0;
  timeptr=(&timinsec);

  ret=time(timeptr);

  if ( ret != -1 )
  {
    return(ctime(timeptr));
  }
  else
    return(0);
}

end implementation EMSsurface;
