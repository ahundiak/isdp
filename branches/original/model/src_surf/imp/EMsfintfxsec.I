/* ###################   APOGEE COMPILED   ################## */
/*
 History
	SM	10-Oct-89	Creation.
	SM	11-May-90	If same object is in both sets, prevent
				self intersection.
        NP      24-Aug-92	Modified for ANSI compliance. Moved static fn.
				declarations to global scope. Also missing 
				typecasts added. 

	Sudha   07/07/93        Modified for BSprototypes ansification
*/

class implementation EMSsurface;

#include "EMS.h"

#ifndef DEBUG
#define DEBUG 0
#endif

#define Max	1
#define Min	0

#define Pt1	0
#define Pt2	1

#define NumPt	2		/* Number of points per distance calculation
				*/
#define NumDist	2		/* Number of distance calculations.
				   Will be min and max, therefore 2.
				*/

#define SampleU	0.5
#define SampleV 0.5

#if DEBUG
#define Buffer		1
#else
#define Buffer		10
#endif

%safe
#include <math.h>		/* fabs */
%endsafe
#include <stdio.h>
#include <string.h>
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
#include "EMSopt.h"
#include "emsimpdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsinterdef.h"
#include "EMSprop.h"
#include "DIdef.h"	/* DI_PATH_MAX */
#include "EMSchatch.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

/* ex$message */
# include "msmacros.h"
#include "EC_M.h"       /* Command strings */
#include "EC_I.h"       /* Status strings */
#include "EC_P.h"       /* Prompt strings */
#include "EC_F.h"       /* Error box strings */
#include "EC_E.h"       /* Error strings */

#include "ma.h"
#include "mazrotmx.h"
#include "bsvcdst2cvs.h"
#include "bssfeval.h"
#include "bssfarrevn.h"
#include "bsplptnorsz.h"
#include "bsplptnorrg.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscrossp.h"
#include "bschgdeppar.h"

/* method specific error handling macros. 
*/
#define EMlocerrhndlr(cond, code, reccode, ele1, ele2, numf, f, buf, proceed, skip)\
	{\
	 if( (cond) ) \
	  {\
	   *(code) = (reccode);\
	   EMintf_recordFailure( (code), (ele1), (ele2), (numf),\
					(f), (buf), EMxsection);\
	   sts = OM_S_SUCCESS; \
	   if((proceed)) continue;\
	   if((skip)) goto next_check;\
	  }\
	}
	

extern OMuword OPP_EMSedge_class_id, OPP_EMSplane_class_id, 
	       OPP_EMSgradata_class_id, OPP_EMSptedge_class_id;

from EMSboundary import EMtree_traverse, EMtpcopy;
from EMSloopset import EMobint, EMcvboolean, EMget_loops, EMtreemod, 
			EMnesting, EMgetrange, EMuv_transform;
from EMSloop import EMget_edges, EMtreemod, EMgivenestinfo, EMloopInterference,
		    EMnesting, EMget_props, EMset_props, EMgetbcgeom, 
		    EMendpts, EMreverse;
from EMSsubbs import EMsftanorm;

from EMSedge import EMgetbcgeom, EMendpts;
from EMSplane import EMplaneDef, EMcross_hatch;

struct EMSintfloc_record
{
 IGRdouble	dist;
 IGRdouble	Keypt[2][2];
 GRobjid	loopids[2];
};

struct EMSintf_lpgm
{
 GRobjid	lpid;
 struct IGRbsp_curve *lpgm;
 IGRboolean islast;
};

extern IGRboolean EMSintfWriteFlag;

%safe
static void		EMsfloops_free(), EMintf_recordInfo(), 
			EMremakeownlist(), EMintf_malloc(), EMintf_dealloc();
static IGRboolean	EMislpinarr(), EMislsped(), EMlpsprocessed(), 
			EMislsed();
static IGRint		EMoutAreaElem();
static IGRlong		EMintf_getlpgm();
%endsafe

#ifdef __STDC__
#argsused
#endif
method EManalyzeIntfAlongXsec(IGRlong *EMmsg;
			      struct GRlc_info *SetInfo1, *Ele1;
			      IGRint NumEle1, setnum1;
			      struct GRlc_info *SetInfo2, *Ele2;
			      IGRint NumEle2, setnum2;
			      IGRushort options;
			      IGRchar *ReportFileName;
			      struct GRvg_construct *const_list;
			      struct IGRplane *plane;
			      struct EMSintf **result;
			      IGRint *num_result)

{
 IGRchar		*stackptr;
 IGRchar		str[MS_MAX_MSG_LENGTH+1];
 IGRboolean		*in_set2, *in_set1;
 IGRlong		rc, sts = OM_S_SUCCESS;
 struct EMSintf		*locresult = NULL;
 struct EMSintfloc_record *info[NumIntfCases];
 IGRint			BufSize[NumIntfCases], NumOcc[NumIntfCases], NumEle;
 struct GRlc_info	*Ele;
 struct IGRbsp_curve	*lpcv = NULL;
 struct EMSintf_failure *failed = NULL;
 IGRint			failBufSize = 0, numfail = 0, numresult_lps = 0, 
			buf_size = 0, numedges,
			numpts, ind1, ind2, locnumresult = 0, i, j, 
			numchecked = 0, m, n, num, depth,
			numlslps[2], p, q, total_linesegs = 0, 
			bytes_in, bytes_out;
 IGRuint		count;

 struct GRid		pl, GRid1, GRid2, NULL_GRid, *edges = NULL, 
			*linesegs = NULL, linesegsbuf[Buffer];
 struct GRmdenv_info    *envinfo1, *envinfo2;
 struct GRmd_env	*env1, *env2, *plenv;
 OM_S_CHANSELECT	to_ls, to_assoc, to_sf;
 GRrange		range, temp_range;
 IGRboolean		world_range = TRUE, inrange, 
			display = FALSE, nomsg = FALSE, 
			intpt = FALSE, atleastone = FALSE, 
			isnestedintf = FALSE, isnestedcl = FALSE, 
			isdisjointcl = FALSE, inputxsec = FALSE, 
			vcdstfound = FALSE, *iscoinc = NULL, 
			iscoincbuf[Buffer], crosshatch_init = FALSE;
			
 IGRdouble		udist, vdist, dist, u_knots[4], v_knots[4], 
			lentol, bastol, par1, par2, scale_factor, 
			mindist, maxdist, tmpminpts[4], tmpmaxpts[4], 
			pt1[3], pt2[3], 
			hatch_angle, hatch_spacing;
			
 IGRpoint		plane_poles[4], temppt[2], locplpt, hatch_origin, sfpt;

 extern void 		EMintf_recordFailure(), EMintf_report(), 
			EMintf_failureReport(), EMintf_free(), EMintfDisplay(), 
			EMintf_christen(), EFget_xh_definition();
			
 struct IGRbsp_surface	xsec_plane, *srf = NULL;
 GRobjid 		ls1 = NULL_OBJID, ls2 = NULL_OBJID, 
			lsnest[2], *result_lps = NULL,
			*nestlps = NULL, *lscs[2], *lslps[2], 
			lscsbuf[2][Buffer], 
			thisedge, nextedge, junkls;
			
 struct EMSintf_lpgm	**lpgm[2], *lpgmbuf[2][Buffer], 
			lpgmbufbuf[2][Buffer][Buffer];
 struct EMSpartolbasis	ptol;

 extern IGRboolean      EFplace_line_string(), EFisAncestryValid(), 
			IGEstop(), EMisElementSame();
			
 struct EMSnest_info	nesting;
 OM_S_OBJECT_LINKAGE	ls;
 enum EMSintfType	type;
 extern IGRlong		EFbuild_graphic_group();
 IGRint 	        numRec[2], *entryInx = NULL, entryBuffSize = 0, 
			numEntry = 0;
 IGRboolean 		*ismin = NULL, *ismax = NULL, isminbuf[Buffer], 
			ismaxbuf[Buffer], noxhatch = FALSE;
 struct EMSintfloc_record *rec[2], recbuf[2][Buffer];
 struct EMSownercomp	*sfloopsUnused[2], *sfloopsUsed[2];
 IGRchar		eleidentifier[NumIntfCases][NumDist][DI_PATH_MAX], 
			elename[DI_PATH_MAX], str_array[MS_MAX_MSG_LENGTH+1], 
			material_type[40];
 IGRushort	        resultlpprops;
 IGRvector		uvnormal, edgevec, entryvec, locplnormal, nrml1, nrml2;
 IGRmatrix		transmat, chmat;
 struct IGRplane	locplane;
 struct EMSxh_info	hatch_info;
 IGRdouble		dotp, sample_u, sample_v;
 extern IGRboolean	EFsrf1uv_to_srf2uv();
 extern IGRint		EMgetvggeom();

 *EMmsg = EMS_S_Success;

 stackptr = NULL;

 nomsg = options & EMSintf_NoStatMsg;
 noxhatch = options & EMSintf_NoCrossHatch;

 plenv = const_list->env_info;
 pl.osnum = plenv->md_id.osnum;
 pl.objid = NULL_OBJID;
 const_list->geometry = (IGRchar *) &xsec_plane;
 NULL_GRid.objid = NULL_OBJID;
 NULL_GRid.osnum = pl.osnum;
 if(!result) result = &locresult;
 if(!num_result) num_result = &locnumresult;

 hatch_info.v_sgrp_info = NULL;
 hatch_info.u_sgrp_info = NULL;

 *result = NULL;
 *num_result = 0;
 for(q=0; q<2; q++)
  {
   numRec[q] = 0;
   rec[q] = NULL;
   lscs[q] = NULL;
   sfloopsUnused[q] = NULL;
   sfloopsUsed[q] = NULL;
   lsnest[q] = NULL_OBJID;
   lslps[q] = NULL;
   numlslps[q] = 0;
   lpgm[q] = NULL;
  }

 for(i=0; i<NumIntfCases; i++) 
  {
   info[i] = NULL;
   NumOcc[i] = 0;
   BufSize[i] = 0;
   for(j=0; j<2; j++)
    {
     if(i == Intf) strcpy(eleidentifier[i][j], "Intf");
     else if(i == NestedCl) strcpy(eleidentifier[i][j], "NestedCl");
     else if(i == DisjointCl) strcpy(eleidentifier[i][j], "DisjointCl");
     else if(i == NestedIntf) strcpy(eleidentifier[i][j], "NestedIntf");
     if(j == Min) strcat(eleidentifier[i][j], "Min");
     else if(j == Max) strcat(eleidentifier[i][j], "Max");
    }
  }

 EMmake_chanselect(EMSsubbs_to_loopset, &to_ls);
 EMmake_chanselect(GRnotify_notification, &to_assoc);
 EMmake_chanselect(EMSloopset_to_surface, &to_sf);

 display = options & EMSintf_Display;
 inputxsec = options & EMSintf_InputXsec;

 BSEXTRACTPAR (&rc, BSTOLBASIS, bastol);
 BSEXTRACTPAR (&rc, BSTOLLENVEC, lentol);

 uvnormal[0] = 0.0;
 uvnormal[1] = 0.0;
 uvnormal[2] = 1.0;


 EMerr_hndlr(!Ele1 || !Ele2, *EMmsg, EMS_E_InvalidArg, wrapup);
 EMerr_hndlr( (options & EMSintf_ReportBoth) && !ReportFileName, 
	     *EMmsg, EMS_E_InvalidArg, wrapup);

 /*
  * Prepare lists of Boolean flags for the two sets, indicating the elements
  * that are contained in both sets
  */

 stackptr = (IGRchar *)stackalloc ((NumEle1 + NumEle2) * sizeof (IGRboolean));
 EMerr_hndlr (!stackptr, *EMmsg, EMS_E_NoStackMemory, wrapup);

 in_set2 = (IGRboolean *)stackptr;
 in_set1 = &((IGRboolean *) stackptr)[NumEle1];

 for (i=0; i<NumEle1; i++)
   in_set2[i] = FALSE;
 for (i=0; i<NumEle2; i++)
   in_set1[i] = FALSE;
 for (i=0; i<NumEle1; i++)
   for (j=0; j<NumEle2; j++)
     {
     envinfo1 = &Ele1[i].module_info.md_env;
     envinfo2 = &Ele2[j].module_info.md_env;
     if (!in_set1[j] && 
         EMisElementSame (&Ele1[i].located_obj, &Ele2[j].located_obj,
          envinfo1->matrix_type, envinfo2->matrix_type,
          envinfo1->matrix, envinfo2->matrix))
       {
       in_set2[i] = TRUE;
       in_set1[j] = TRUE;
       }
     }

 if(!(*result))
  *result = (struct EMSintf *) 
	    om$malloc(size = NumEle1 * sizeof(struct EMSintf));
 EMerr_hndlr(!(*result), *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 /* Get the range box encompassing the primary set AND the check set.
    This is so that large enough plane for a cross section can be constructed
    once only.
 */
 for(i=0; i<3; i++)
  {
   range[i] = MAXDOUBLE;
   range[i+3] = MINDOUBLE;
  }

 for(p=0; p<2; p++)
  {
   NumEle = p ? NumEle2 : NumEle1;
   Ele = p ? Ele2 : Ele1;

   for(i=0; i<NumEle; i++)
    {
     sts = om$send(msg = message GRvg.GRgetrang
		(EMmsg, &Ele[i].module_info.md_env.matrix_type, 
		 Ele[i].module_info.md_env.matrix, &world_range, temp_range), 
		targetid = Ele[i].located_obj.objid, 
		targetos = Ele[i].located_obj.osnum);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
     for(j=0; j<3; j++)
      {
       if(temp_range[j] < range[j]) range[j] = temp_range[j];
       if(temp_range[j+3] > range[j+3]) range[j+3] = temp_range[j+3];
      }
    }
  }


 /* Construct a plane encompassing the total range.
 */
 xsec_plane.poles = (IGRdouble *) plane_poles;
 xsec_plane.u_knots = u_knots;
 xsec_plane.v_knots = v_knots;
 scale_factor = 1.1;
 if(!plane)
  {
   locplane.point = locplpt;
   locplane.normal = locplnormal;
   plane = (struct IGRplane *) &locplane;
   sts = om$send(msg = message EMSplane.EMplaneDef(EMmsg, 
	         &Ele[0].module_info.md_env.matrix_type, 
		 Ele[0].module_info.md_env.matrix, plane), 
		targetid = Ele[0].located_obj.objid, 
		targetos = Ele[0].located_obj.osnum);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
  }

 BSplptnorrg(range, &range[3], plane->point, plane->normal, scale_factor, 
	     &inrange, &xsec_plane, &rc);
 if(rc != BSSUCC) {*EMmsg=EMS_E_Fail; goto wrapup;}
 else *EMmsg = EMS_S_Success;

 /* Make the plane square so that we do not have to deal
    with transformations to model space. Because the plane will have linear
    mapping between its parametric and model spaces, all the computations
    can be done in parametric space and then be converted to model space
    at output time.
    For making the plane square, give the center point of the already
    determined plane as the pivot point about which to modify that plane.
 */
 udist = BSdistptpt(&rc, plane_poles[0], plane_poles[1]);
 vdist = BSdistptpt(&rc, plane_poles[0], plane_poles[2]);
 if(fabs(udist - vdist) > lentol)
  {
   IGRpoint		centerpt;
   IGRdouble		*savept;

   BSsfeval(&xsec_plane, 0.5, 0.5, 0, (IGRpoint *)centerpt, &rc);
   if(rc != BSSUCC) {*EMmsg=EMS_E_Fail; goto wrapup;}
   else *EMmsg = EMS_S_Success;
   
   savept = plane->point;   
   plane->point = centerpt;
   dist = udist > vdist ? udist : vdist;
   BSplptnorsz(plane->point, plane->normal, dist, dist, &xsec_plane, &rc);
   plane->point = savept;
   if(rc != BSSUCC) {*EMmsg=EMS_E_Fail; goto wrapup;}
   else *EMmsg = EMS_S_Success;
  }

 /* We now have a square plane which encompasses all the elements we are
    dealing with.
 */
 sts = om$construct(classid = OPP_EMSplane_class_id, osnum = pl.osnum, 
			p_objid = &pl.objid, 
			msg = message GRgraphics.GRconstruct(const_list));
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
 ptol.mattyp = &plenv->md_env.matrix_type;
 ptol.mat = plenv->md_env.matrix;
 sts = EFsspbtol_by_geom(EMmsg, &xsec_plane, &ptol.tol);
 ptol.is_valid = TRUE;
 if(inputxsec)
  {
   sample_u = SampleU;
   sample_v = SampleV;
   BSsfarrevn(&rc, &xsec_plane, 1, &sample_u, 1, &sample_v, sfpt, nrml1);
   if(rc != BSSUCC) {*EMmsg=EMS_E_Fail; goto wrapup;}
   (void) BSnorvec(&rc, nrml1);
  } 

 /* Get cross sections of all the elements involved. Whichever element fails
    to produce a cross section will be skipped during the analysis.
 */
 for(p=0; p<2; p++)
  {
   EMintf_malloc(&lscs[p], lscsbuf[p], Buffer, p ? NumEle2 : NumEle1, 
		 sizeof(GRobjid));
   EMerr_hndlr(!lscs[p], *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   for(i=0; i< (p ? NumEle2 : NumEle1); i++) lscs[p][i] = NULL_OBJID;
   EMintf_malloc(&lpgm[p], lpgmbuf[p], Buffer, p ? NumEle2 : NumEle1, 
		 sizeof(struct EMSintf_lpgm *));
   EMerr_hndlr(!lpgm[p], *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   for(i=0; i< (p ? NumEle2 : NumEle1); i++) lpgm[p][i] = NULL;
  }

 for(p=0; p<2; p++) 
  {
   NumEle = p ? NumEle2 : NumEle1;
   Ele = p ? Ele2 : Ele1;
   atleastone = FALSE;

   for(i=0; i<NumEle; i++)
    {
     if((intpt = IGEstop())) break;	/* user interrupt */

     GRid1 = Ele[i].located_obj;
     env1 = &Ele[i].module_info;

     if(!inputxsec)
      {
       if(!nomsg)
        {
	 int junk1, junk2;
	
	junk1 = p ? setnum2 : setnum1;
	junk2 = i+1;
	ex$message(msgnumb = EMS_I_SetNumEleNum, var = `junk1, junk2`, 
	           type = "%d %d", buff = str);
        ex$message(msgnumb = EMS_I_GenXsec, var = `str`, type = "%s");
        }
       sts = om$send(msg = message EMSsurface.EMcross_section(EMmsg, 
			const_list, NULL, env1, &pl.objid, NULL), 
			targetid = GRid1.objid, targetos = GRid1.osnum);
       EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Intersect, &Ele1[i], 
			NULL, &numfail, &failed, &failBufSize, TRUE, NULL); 
       sts = om$get_channel_objects(objid = pl.objid, osnum = pl.osnum, 
		        p_chanselect = &to_ls, 
			list = &ls, size = 1, count = &count);
       EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Intersect, &Ele1[i], 
			NULL, &numfail, &failed, &failBufSize, TRUE, NULL); 

       if(!count) continue;
       lscs[p][i] = ls.S_objid;
       sts = om$send(msg = message Root.wild_disconnect(to_ls), 
		targetid = pl.objid, targetos = pl.osnum);

       EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Intersect, &Ele1[i], 
			NULL, &numfail, &failed, &failBufSize, TRUE, NULL); 
      }
     else
      {
       /* The input cross section must be a plane.
       */
       EMlocerrhndlr(!EFisAncestryValid(&rc, GRid1.objid, GRid1.osnum, 
	 OPP_EMSplane_class_id, TRUE), EMmsg, EMS_E_Fail, &Ele1[i],
	    &Ele2[j], &numfail, &failed, &failBufSize, FALSE, TRUE);

       ls.S_objid = NULL_OBJID;
       sts = om$send(msg = message EMSsurface.EMputLsIfNotThere
			(EMmsg, &env1->md_env, NULL, &ls.S_objid, NULL, NULL), 
		targetid = GRid1.objid, targetos = GRid1.osnum);
       EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Intersect, &Ele1[i], 
			NULL, &numfail, &failed, &failBufSize, TRUE, NULL); 
       if(IF_NULL_OBJID(ls.S_objid)) continue;

       sts = om$send(msg = message EMSboundary.EMtpcopy
		(EMmsg, env1, GRid1.osnum, pl.osnum, NULL, &junkls), 
			targetid = ls.S_objid, targetos = GRid1.osnum);
       EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i],
		&Ele2[j], &numfail, &failed, &failBufSize, FALSE, TRUE);
		
       if(srf) om$dealloc(ptr = srf);
       srf = NULL;
       sts = EMgetvggeom(EMmsg, &env1->md_env.matrix_type, 
			 env1->md_env.matrix, &GRid1, &srf, NULL);
       EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i],
		&Ele2[j], &numfail, &failed, &failBufSize, FALSE, TRUE);

       /* Map the copied loopset onto the plane contructed here.
       */
       (void) EFsrf1uv_to_srf2uv(srf, &xsec_plane, transmat, EMmsg);
       EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i],
		&Ele2[j], &numfail, &failed, &failBufSize, FALSE, TRUE);

       sts = om$send(msg = message EMSloopset.EMuv_transform
		(EMmsg, transmat, &ptol, EMS_TF_TRANSFORM_NE, NULL, NULL), 
		targetid = junkls, targetos = pl.osnum);
       EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i],
		&Ele2[j], &numfail, &failed, &failBufSize, FALSE, TRUE);
		
       BSsfarrevn(&rc, srf, 1, &sample_u, 1, &sample_v, sfpt, nrml2);
       if(rc != BSSUCC) {*EMmsg=EMS_E_Fail; goto wrapup;}
       (void) BSnorvec(&rc, nrml2);
       dotp = BSdotp(&rc, nrml1, nrml2);
       EMlocerrhndlr(rc!=BSSUCC, EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);
       if(dotp < 0.0)
        {
	 sts = om$send(msg = message EMSboundary.EMtree_traverse(&rc, 
			message EMSloop.EMreverse(EMmsg), MAXINT, 1, 
			&OPP_EMSloop_class_id, TRUE, NULL, NULL, NULL), 
			targetid = junkls, targetos = pl.osnum);
         EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i],
		&Ele2[j], &numfail, &failed, &failBufSize, FALSE, TRUE);

	 sts = om$send(msg = message EMSboundary.EMtree_traverse(&rc, 
			message EMSloop.EMset_props
			(EMmsg, EMLP_PLOOP, EMS_O_TOGGLE), MAXINT, 1, 
			&OPP_EMSloop_class_id, TRUE, NULL, NULL, NULL), 
			targetid = junkls, targetos = pl.osnum);
         EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i],
		&Ele2[j], &numfail, &failed, &failBufSize, FALSE, TRUE);
			
        }
       lscs[p][i] = junkls;
      }

     /* Delete all gradata objects since this loopset has no surface
        any more.
     */
     sts = om$send(msg = message EMSboundary.EMtree_traverse(&rc, 
			message Root.delete(TRUE), 
			MAXINT, 1, &OPP_EMSgradata_class_id, 
			EMStreetrav_down, NULL, NULL, NULL), 
			targetid = ls.S_objid, targetos = pl.osnum);
     EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Intersect, &Ele1[i], 
			NULL, &numfail, &failed, &failBufSize, TRUE, NULL); 
     atleastone = TRUE;
    }

   if(!atleastone) {*EMmsg = EMS_E_Intersect; goto wrapup;}

  }

 /* We now have all the required cross sections. 
 */
 for(i=0; (i<NumEle1) && !intpt; i++)
  {
   struct EMSintf 	*this_result = NULL;
   struct EMSintf_xsec 	**against;

   if((intpt = IGEstop())) break;	/* user interrupt */

   if(IF_NULL_OBJID(lscs[0][i])) continue;

   GRid1 = Ele1[i].located_obj;
   env1 = &Ele1[i].module_info;
   
   this_result = (struct EMSintf *) &(*result)[*num_result];
   this_result->eleminfo = Ele1[i];
   this_result->numintf = 0;
   this_result->intfInfoType = EMxsection;
   this_result->info.xsec = NULL;
   against = (struct EMSintf_xsec **) &this_result->info.xsec;
   *against = (struct EMSintf_xsec *) om$malloc(size = NumEle2 *
					sizeof(struct EMSintf_xsec));
   EMerr_hndlr(!(*against), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   for(n=0; n<NumEle2; n++)
    {
     for(p=0; p<NumAreas; p++)
       (*against)[n].areas[p] = NULL_GRid;
     for(p=0; p<NumIntfCases; p++)
      {
       for(q=0; q<2; q++)
        {
         (*against)[n].NumOcc[p][q] =  0;
         (*against)[n].linesegs[p][q] = NULL;
        }
      }
     }
   numchecked++;

   for(j=0; (j<NumEle2) && !intpt; j++)
    {
     struct EMSintf_xsec *this_against;
          
     if((intpt = IGEstop())) break; 	/* user interrupt */
     if(IF_NULL_OBJID(lscs[1][i])) continue;

     GRid2 = Ele2[j].located_obj;
     env2 = &Ele2[j].module_info;

     if (in_set2[i] && in_set1[j] &&
         (EMisElementSame (&GRid1, &GRid2,
           env1->md_env.matrix_type, env2->md_env.matrix_type,
           env1->md_env.matrix, env2->md_env.matrix) ||
         !EMisFirstDominant (&GRid1, &GRid2, 
           env1->md_env.matrix_type, env2->md_env.matrix_type,
           env1->md_env.matrix, env2->md_env.matrix)))
       continue;

     if(!nomsg)
      {
       if (setnum1 != setnum2)
         sprintf(str_array, "Set #%d - Elem %d : Set #%d - Elem %d",
          setnum1, i+1, setnum2, j+1);
       else
         sprintf(str_array, "Set #%d - Elem %d : Elem %d",
          setnum1, i+1, j+1);

       ex$message(msgnumb = EMS_I_ProcessingSomething, var = `str_array`, 
		  type = "%s");
      }

     num = this_result->numintf;
     this_against = (struct EMSintf_xsec *) &this_result->info.xsec[num];
     this_against->against_eleminfo = Ele2[j];


     if(!IF_NULL_OBJID(ls1))
      {
       sts = om$send(msg = message Root.delete(TRUE), targetid = ls1, 
				targetos = pl.osnum);
       ls1 = NULL_OBJID;
      }
     sts = om$send(msg = message EMSboundary.EMtpcopy
			(EMmsg, plenv, pl.osnum, pl.osnum, NULL, &ls1), 
			targetid = lscs[0][i], targetos = pl.osnum);
     EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i],
		&Ele2[j], &numfail, &failed, &failBufSize, FALSE, TRUE);

     if(!IF_NULL_OBJID(ls2))
      {
       sts = om$send(msg = message Root.delete(TRUE), targetid = ls2, 
				targetos = pl.osnum);
       ls2 = NULL_OBJID;
      }
     sts = om$send(msg = message EMSboundary.EMtpcopy(EMmsg, plenv, pl.osnum, 
			pl.osnum, NULL, &ls2), targetid = lscs[1][j], 
			targetos = pl.osnum);
     EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], 
			&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);

     for(m=0; m<NumIntfCases; m++) 
      {
       if(info[m])
        {
         for(p=0; p<NumOcc[m]; p++)
          {
	   sts = om$send(msg = message Root.delete(TRUE), targetid = 
				info[m][p].loopids[0], targetos = pl.osnum);
	   sts = om$send(msg = message Root.delete(TRUE), targetid = 
				info[m][p].loopids[1], targetos = pl.osnum);
          }
         om$dealloc(ptr = info[m]);
        }
       info[m] = NULL;
       NumOcc[m] = 0;
       BufSize[m] = 0;
      }

     for(q=0; q<2; q++)
      {
       if(lslps[q])
        {
         for(m=0; m<numlslps[q]; m++)
         rc = om$send(msg = message Root.delete(TRUE), targetid = lslps[q][m], 
				targetos = pl.osnum);
         om$dealloc(ptr = lslps[q]);
        }
       lslps[q] = NULL;
       numlslps[q] = 0;
       depth = MAXINT;
       buf_size = 0;
       sts = om$send(msg = message EMSloopset.EMget_loops(EMmsg, EMS_OPT_ALL,
			&depth, &lslps[q], NULL, &buf_size, &numlslps[q]), 
		targetid = q ? ls2 : ls1, targetos = pl.osnum);
       EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], 
			&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);

       /* Associate each loop to all its edges. This is so as to keep
	track of which pieces were contributed by each loopset in the boolean
	intersection result.
       */
       for(m=0; m<numlslps[q]; m++)
        {
         sts = om$send(msg = message Root.wild_disconnect(to_assoc), 
			targetid = lslps[q][m], targetos = pl.osnum);
         EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], 
			&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);
         sts = om$send(msg = message EMSboundary.EMtree_traverse(&rc, 
			message Root.connect(to_assoc, MAXINT, lslps[q][m], 
			pl.osnum, to_assoc, MAXINT), 1, 1, 
			&OPP_EMSedge_class_id, 
			EMStreetrav_down, NULL, NULL, NULL), 
			targetid = lslps[q][m], targetos = pl.osnum);
         EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], 
			&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);
       }

      m = q ? j : i;
      if(!lpgm[q][m])
       {
	if(lpgm[q] == lpgmbuf[q])
         EMintf_malloc(&lpgm[q][m], lpgmbufbuf[q][m], Buffer, numlslps[q], 
			sizeof(struct EMSintf_lpgm));
	else
         lpgm[q][m] = (struct EMSintf_lpgm *) om$malloc(size = numlslps[q] *
				sizeof(struct EMSintf_lpgm));
        EMerr_hndlr(!lpgm[q][m], *EMmsg, EMS_E_NoDynamicMemory, wrapup);
        for(n=0; n<numlslps[q]; n++)
         {
          lpgm[q][m][n].lpid = NULL_OBJID;
          lpgm[q][m][n].lpgm = NULL;
   	  lpgm[q][m][n].islast = n == (numlslps[q] -1) ? TRUE : FALSE;
         }
       }
     } /* for(q=0; q<2; q++) */

				
    /* Perform a boolean intersection between the two loopsets. Also get
       back all the loops in each of them that did not contribute towards
       the result (wholly or partially).
       Pass option to Maintain Associations if new edges are created.
    */
    for(q=0; q<2; q++)
     {
      if(sfloopsUnused[q]) EMsfloops_free(&sfloopsUnused[q], pl.osnum);
      if(sfloopsUsed[q]) EMsfloops_free(&sfloopsUsed[q], pl.osnum);
     }

    sts = om$send(msg = message EMSloopset.EMcvboolean(EMmsg,
		EMSbool_intersect, ls2, NULL, 
		EMImpBnd_MaintainAssoc | EMImpBnd_NoInputDelete, 
		&sfloopsUnused[0], &sfloopsUnused[1], &sfloopsUsed[0], 
		&sfloopsUsed[1], &ptol), 
		targetid = ls1, targetos = pl.osnum);
    EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], 
			&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);

    /* Get all the loops of the result.
    */
    depth = MAXINT;
    buf_size = 0;
    if(result_lps) om$dealloc(ptr = result_lps);
    result_lps = NULL;
    numresult_lps = 0;

    sts = om$send(msg = message EMSloopset.EMget_loops (EMmsg, EMS_OPT_ALL,
			&depth, &result_lps, NULL, &buf_size, &numresult_lps), 
		targetid = ls1, targetos = pl.osnum);
    EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], 
			&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);

    BSchgdeppar (ptol.tol, &rc);

    for(n=0; n<numresult_lps; n++)			
     {
      sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &resultlpprops), 
			targetid = result_lps[n], targetos = pl.osnum);
      EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], 
			&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);
      if(!(resultlpprops & EMLP_PLOOP)) continue;

      buf_size = 0;
      if(edges) om$dealloc(ptr = edges);
      edges = NULL;
      numedges = 0;
      sts = om$send(msg = message EMSloop.EMget_edges(EMmsg, 1, 
			EMS_OPT_ALL, &edges, &buf_size, &numedges), 
			targetid = result_lps[n], targetos = pl.osnum);
      EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);
	 
      /* All the original loops of ls2 were associated to their edges.
         By maintaining associations the information as to which edge came
	 from ls2 has been retained. 
	
	 In order to compute the interference, the entry edge where an area
	 from one enters into the other loopset has to be determined.
	 An entry edge is one which comes from a P loop of one loopset and
	 is flanked by edges coming the other loopset. There can
	 be any number of such edges. The two extremes are chosen.
      */
      if(entryInx) om$dealloc(ptr = entryInx);
      entryInx = NULL;
      entryBuffSize = 0;
      numEntry = 0;

      for(p=0; p<numedges; p++)
       {
        if( (EMislsed(EMmsg, lslps[0], numlslps[0], &edges[p], &to_assoc) &&
	     !EMislsed(EMmsg, lslps[0], numlslps[0], 
		     &edges[(p+1)%numedges], &to_assoc)) ||
	    (EMislsed(EMmsg, lslps[1], numlslps[1], &edges[p], &to_assoc) &&
             !EMislsed(EMmsg, lslps[1], numlslps[1], 
		     &edges[ (p+1) % numedges], &to_assoc)))
	 {
	  if(!entryBuffSize)
	   {
	    if(entryInx)
	     entryInx = (IGRint *) om$realloc(ptr = (IGRchar *)entryInx, 
				size = (numEntry + Buffer) * sizeof(IGRint));
	    else
	     entryInx = (IGRint *) om$malloc(size = Buffer * sizeof(IGRint));
	    EMerr_hndlr(!entryInx, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	    entryBuffSize = Buffer;
	   }
	  entryInx[numEntry++] = p;
	  entryBuffSize--;
	 }
	
       } /* for(p=0; p<numedges; p++) */

      /*
	If this loop is comprised of edges from ls1 or ls2 only then
	ignore it since it does not represent geometrical intersection
      */
      if(!numEntry)
       {
        IGRboolean list_ext, isls2lp = FALSE;

	isls2lp = EMislpinarr(result_lps[n], lslps[1], numlslps[1]);
	
        sts = om$send(msg = message EMSloop.EMtreemod(EMmsg, &nesting, 
				EXTRACT, &ptol), targetid = result_lps[n], 
				targetos = pl.osnum);
        EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);

	EMmkownlist(&rc, isls2lp ? &sfloopsUnused[1] : &sfloopsUnused[0], 
		NULL_OBJID, NULL, result_lps[n], FALSE, &list_ext);
	EMremakeownlist(&rc, isls2lp ? &sfloopsUsed[1] : &sfloopsUsed[0], 
			result_lps[n]);
	result_lps[n] = NULL_OBJID;
        continue;
       }

      EMlocerrhndlr(numEntry<2, EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);

      if(lpcv) BSfreecv(&rc, lpcv);
      lpcv = NULL;
      sts = om$send(msg = message EMSloop.EMgetbcgeom
			(EMmsg, &lpcv, &ptol, NULL), 
			targetid = result_lps[n], targetos = pl.osnum);
      EMlocerrhndlr(!lpcv || !(1&*EMmsg&sts), EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);

      maxdist = MINDOUBLE;
      vcdstfound = FALSE;

      for(p=0; p<numEntry; p++)      
       {
	thisedge = edges[entryInx[p]].objid;
	nextedge = edges[entryInx[ (p+1) % numEntry]].objid;
	
	sts = om$send(msg = message EMSedge.EMendpts(EMmsg, NULL, pt1, NULL, 
				NULL, NULL), 
			targetid = thisedge, targetos = pl.osnum);
        EMlocerrhndlr(!(1&*EMmsg&sts), EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);
		
	sts = om$send(msg = message EMSedge.EMendpts(EMmsg, NULL, pt2, NULL, 
				NULL, NULL), 
			targetid = nextedge, targetos = pl.osnum);
        EMlocerrhndlr(!(1&*EMmsg&sts), EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);
		
	pt1[2] = 0.0;
	pt2[2] = 0.0;
	
	/* Entry vector is a vector normal to the vector joining the endpoints
	   of the two edges under consideration.
	*/
        (void) BSmkvec(&rc, edgevec, pt1, pt2);
        (void) BSnorvec(&rc, edgevec);
        EMlocerrhndlr(rc!=BSSUCC, EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);
		
        (void) BScrossp(&rc, edgevec, uvnormal, entryvec);
        EMlocerrhndlr(rc!=BSSUCC, EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);
	
        BSvcdst2cvs(lpcv, NULL, entryvec, &numpts, &par1, &par2, temppt[Pt1], 
		     temppt[Pt2], &dist, &ind1, &ind2, &rc);
	if(EMSintfWriteFlag && (rc != BSSUCC))
	 {
	  IGRint	junk;
	  extern IGRint prtbspc();
	
	  printf("Problem in BSvcdst2cvs, writing curve out\n");
	  prtbspc(lpcv);
	  printf("Entry Vector is - \n");
	  for(junk=0; junk<3; junk++) printf("%lf\n", entryvec[junk]);
	  printf("Tolerance is %2.13lf\n", ptol.tol);
	 }
        EMlocerrhndlr(rc!=BSSUCC, EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);

	if(dist > maxdist)
	 {
          OM_BLOCK_MOVE(temppt[Pt1], tmpmaxpts, 2 * sizeof(IGRdouble));
          OM_BLOCK_MOVE(temppt[Pt2], &tmpmaxpts[2], 2 * sizeof(IGRdouble));
          maxdist = dist;
	  vcdstfound = TRUE;
	 }
	if(numEntry == 2) break;
	
       } /* for(p=0; p<numEntry; p++) */

      if(vcdstfound)
       {
        EMintf_recordInfo(EMmsg, info, NumOcc, BufSize, Intf, 
		result_lps[n], NULL_OBJID, maxdist, tmpmaxpts);
        if(!(1&*EMmsg)) goto wrapup;
       }

     } /* for(n=0; n<numresult_lps; n++) */

    if(sfloopsUnused[0] || sfloopsUnused[1])
     {
       GRobjid	*lps[3];
       IGRint numlps[3];

      for(m=0; m<2; m++)
       if(!IF_NULL_OBJID(lsnest[m]))
        {
         sts = om$send(msg = message Root.delete(TRUE), targetid = lsnest[m], 
				targetos = pl.osnum);
         lsnest[m] = NULL_OBJID;
        }

       /*
	index 0 -- unused loops from other loopset.
	index 1 -- used loops from other loopset.
	index 2 -- unused loops from loopset under consideration.
       */

      for(m=0; m<2; m++)	/* For each loopset */
       {
	if(!sfloopsUnused[m]) continue;
	
        sts = om$construct(classid = OPP_EMSloopset_class_id, osnum = pl.osnum,
			   p_objid = &lsnest[m]);

	lps[0] = sfloopsUnused[!m] ? sfloopsUnused[!m]->comps : NULL;
	numlps[0] = sfloopsUnused[!m] ? sfloopsUnused[!m]->num_comps : NULL;

	lps[1] = sfloopsUsed[!m] ? sfloopsUsed[!m]->comps : NULL;
	numlps[1] = sfloopsUsed[!m] ? sfloopsUsed[!m]->num_comps : NULL;
	
        lps[2] = sfloopsUnused[m]->comps;
        numlps[2] = sfloopsUnused[m]->num_comps;

	EMintf_dealloc(&iscoinc, iscoincbuf);
	EMintf_malloc(&iscoinc, iscoincbuf, Buffer, numlps[2], 
		      sizeof(IGRboolean));
	EMerr_hndlr(!iscoinc, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	
	for(n=0; n<numlps[2]; n++) iscoinc[n] = FALSE;
	
	/* Nest all the loops (used and unused) from other loopset
	 * and the unused loops from this loopset into lsnest.
	 * Since unused loops from this loopset are being considered, 
	 * no loop intersections should occur.
	*/
        for(n=0; n<3; n++)
         {
	  for(p=0; p<numlps[n]; p++)
	   {
            sts = om$send(msg = message EMSloop.EMtreemod(EMmsg, &nesting, 
		EXTRACT, &ptol), targetid = lps[n][p], 
		targetos = pl.osnum);

	    sts = om$send(msg = message EMSloop.EMset_props
			(EMmsg, EMLP_EXTERNAL, EMS_O_OFF), 
				targetid = lps[n][p], targetos = pl.osnum);
				
	    sts = om$send(msg = message EMSloop.EMset_props
			(EMmsg, EMLP_ACTIVE, EMS_O_ON), 
				targetid = lps[n][p], targetos = pl.osnum);
				
            sts = om$send(msg = message EMSloopset.EMnesting
		(EMmsg, &nesting, &ptol), targetid = lsnest[m], 
		targetos = pl.osnum);
            EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);
		
	    if( (*EMmsg == EMS_I_Ambiguous) && (n==2)) iscoinc[p] = TRUE;
	
	    if(IF_EQ_OBJID(nesting.parent, lsnest[m]))
             sts = om$send(msg = message EMSloopset.EMtreemod(EMmsg, &nesting, 
		ADD_CHILD, &ptol), targetid = lsnest[m], targetos = pl.osnum);
            else
             sts = om$send(msg = message EMSloop.EMtreemod(EMmsg, &nesting, 
		ADD_CHILD, &ptol), targetid = nesting.parent, 
		targetos = pl.osnum);
	   }
	 }

	/* Process all the unused P loops of the loopset under consideration.
	*/
        for(n=0; n<numlps[2]; n++)
         {
          sts = om$send(msg = message EMSloop.EMgivenestinfo
			(EMmsg, &nesting), targetid = lps[2][n], 
			 targetos = pl.osnum);
          EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);

 	  if(!(nesting.lp_props & EMLP_PLOOP)) continue;

	  isnestedcl = FALSE;
	  isnestedintf = FALSE;
	  isdisjointcl = FALSE;
	
	  /* If the loop is nested under the loopset, it is disjoint
	     clearance.
	     Else see if a loop is nested inside a parent from the other
	     loopset.
	  */
	
 	  if(IF_EQ_OBJID(nesting.parent, lsnest[m])) isdisjointcl = TRUE;
	  else if(EMislpinarr(nesting.parent, lps[0], numlps[0]) ||
		  EMislpinarr(nesting.parent, lps[1], numlps[1]))
	   {
	    if(nesting.parent_props & EMLP_PLOOP) isnestedintf = TRUE;
	    else isnestedcl = TRUE;
	   }

 	  if(isdisjointcl)
	   { 
            /* Find all the disjoint clearances of this loop against
              all the external loops from the other loopset.
	    */
            for(p=0; p<2; p++)
	     {
              for(q=0; q<numlps[p]; q++)
	       {
	        IGRushort lpprops;
		struct IGRbsp_curve *lpgm1= NULL, *lpgm2 = NULL;
		
	        sts = om$send(msg = message EMSloop.EMget_props
			(EMmsg, &lpprops), targetid = lps[p][q], 
			targetos = pl.osnum);
			
	        if(!(lpprops & EMLP_EXTERNAL)) continue;
	
	        type = EMdisjoint_cl;
	        mindist = MAXDOUBLE;
	        if(EMlpsprocessed(info, NumOcc, DisjointCl, lps[2][n], 
				  lps[p][q])) continue;

		sts = EMintf_getlpgm(EMmsg, numlslps[m], lslps[m], 
		      lpgm[m][m ? j : i], lps[2][n], pl.osnum, &lpgm1, &ptol);
		
		sts = EMintf_getlpgm(EMmsg, numlslps[!m], lslps[!m], 
		      lpgm[!m][!m ? j : i], lps[p][q], pl.osnum, &lpgm2, 
		      &ptol);

	        sts = om$send(msg = message EMSloop.EMloopInterference
			(EMmsg, lps[2][n], &type, NULL, NULL, lpgm2, lpgm1, 
			 NULL, &mindist, NULL, tmpminpts, &ptol), 
			targetid = lps[p][q], targetos = pl.osnum);
                EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], 
		  &Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);
		
	        EMintf_recordInfo(EMmsg, info, NumOcc, BufSize, DisjointCl, 
			lps[2][n], lps[p][q], mindist, tmpminpts);
		if(!(1&*EMmsg)) goto wrapup;
		
    	       } /* for(q=0; q<numlps[p]; q++) */

             }  /* for(p=0; p<2; p++) */

 	   } /* if(isdisjointcl) */

 	  else if(isnestedcl || isnestedintf)
	   {
	    IGRint 	inx;
	    struct IGRbsp_curve	*lpgm1, *lpgm2;
	
            type = isnestedcl ? EMnested_cl : EMnested_intf;
            inx = isnestedcl ? NestedCl : NestedIntf;

	    if(EMlpsprocessed(info, NumOcc, inx, nesting.loopid,
			      nesting.parent)) continue;
	    if(iscoinc[n])
	     {
	      /* If the loop is known to be coincedent, treat it as a 
		 limiting condition of clear nesting. Hence min and max
		 distances will be 0.
	      */
	      sts = om$send(msg = message EMSloop.EMendpts
				(EMmsg, tmpmaxpts, NULL, NULL, NULL), 
		  targetid = nesting.loopid, targetos = pl.osnum);
	      OM_BLOCK_MOVE(tmpmaxpts, &tmpmaxpts[2], 2 * sizeof(IGRdouble));
	      maxdist = 0.0;
	     }
	    else
	     {
	      sts = EMintf_getlpgm(EMmsg, numlslps[m], lslps[m], 
		      lpgm[m][m ? j : i], nesting.loopid, pl.osnum, &lpgm1, 
		      &ptol);
	      sts = EMintf_getlpgm(EMmsg, numlslps[!m], lslps[!m], 
		      lpgm[!m][!m ? j : i], nesting.parent, pl.osnum, &lpgm2, 
		      &ptol);
	      
	      /* The message needs to be sent to the parent. The math routine
		 expects curve1 to enclose curve2.
	      */
              sts = om$send(msg = message EMSloop.EMloopInterference
		  (EMmsg, nesting.loopid, &type, NULL, NULL, lpgm2, lpgm1, 
		   &maxdist, &mindist, tmpmaxpts, tmpminpts, &ptol), 
		  targetid = nesting.parent, targetos = pl.osnum);
              EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL);
	     }
	
            EMintf_recordInfo(EMmsg, info, NumOcc, BufSize, inx, 
		nesting.loopid, nesting.parent, maxdist, tmpmaxpts);
	    if(!(1&*EMmsg)) goto wrapup;
	
	    if(!iscoinc[n])
	     {
              EMintf_recordInfo(EMmsg, info, NumOcc, BufSize, inx, 
		nesting.loopid, nesting.parent, mindist, tmpminpts);
	      if(!(1&*EMmsg)) goto wrapup;
	     }
	
 	   } /* if(isnestedcl || isnestedintf) */
	
         } /* for(n=0; n<numlps[2]; n++)*/

       } /* for(m=0; m<2; m++) */

     } /* if(sfloopsUnused[0] || sfloopsUnused[1]) */


   /* We now have all the interference distances, all the nested
      clearances/interferences and all the disjoint clearances.
      We need to output the following - 

      Min, Max interferences.
      Min, Max nested clearances.
      Min disjoint clearance.
      Min, Max nested interferences.

      If multiple occurances of a particular distance are found (e.g a max
      interferences occuring in 3 different places), then we need to output
      all of them.
   */
   BSchgdeppar (bastol, &rc);
   for(m=0; m<NumIntfCases; m++)   
    {
     if(!NumOcc[m]) continue;

     EMintf_dealloc(&ismin, isminbuf);
     EMintf_dealloc(&ismax, ismaxbuf);

     EMintf_malloc(&ismin, isminbuf, Buffer, NumOcc[m], sizeof(IGRboolean));
     EMerr_hndlr(!ismin, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

     EMintf_malloc(&ismax, ismaxbuf, Buffer, NumOcc[m], sizeof(IGRboolean));
     EMerr_hndlr(!ismax, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

     mindist = MAXDOUBLE;
     for(n=0; n<NumOcc[m]; n++)
      if(info[m][n].dist < mindist) mindist = info[m][n].dist;

     maxdist = MINDOUBLE;
     for(n=0; n<NumOcc[m]; n++)
      if(info[m][n].dist > maxdist) maxdist = info[m][n].dist;

     numRec[Min] = numRec[Max] = 0;
     for(n=0; n<NumOcc[m]; n++)
      {
       ismax[n] = FALSE;
       ismin[n] = FALSE;

       if( (m!=DisjointCl) && (fabs(info[m][n].dist - maxdist) < lentol))
        {
         ismax[n] = TRUE;
         numRec[Max]++;
        }
       else if(fabs(info[m][n].dist - mindist) < lentol)
        {
         ismin[n] = TRUE;
         numRec[Min]++;
        }
      }

     for(n=0; n<2; n++) EMintf_dealloc(&rec[n], recbuf[n]);

     for(n=0; n<2; n++)
      {
       if(numRec[n])
        {
	 EMintf_malloc(&rec[n], recbuf[n], Buffer, numRec[n], 
		       sizeof(struct EMSintfloc_record));
         EMerr_hndlr(!rec[n], *EMmsg, EMS_E_NoDynamicMemory, wrapup);
         numRec[n] = 0;
	}
      }

     for(n=0; n<NumOcc[m]; n++)
      {
       if(ismax[n]) rec[Max][numRec[Max]++] = info[m][n];
       else if(ismin[n]) rec[Min][numRec[Min]++] = info[m][n];
      }

     /* We now have all the occurances for min and max distances of the
        case being processed (Intf, NestedCl or DisjointCl or NestedIntf).
     */
     for(n=Min; n<=Max; n++)
      {
	struct GRid	junk;
	IGRpoint	xyzpts[2];

       if(!numRec[n]) continue;

       this_against->linesegs[m][n] = (struct GRid *)
		om$malloc(size = numRec[n] * sizeof(struct GRid));
       EMerr_hndlr(!this_against->linesegs[m][n], *EMmsg, 
		   EMS_E_NoDynamicMemory, wrapup);

       for(p=0; p< numRec[n]; p++)
        {
	 IGRchar numname[3];
	
         BSsfeval(&xsec_plane, rec[n][p].Keypt[Pt1][0], 
		  rec[n][p].Keypt[Pt1][1], 0, (IGRpoint *)xyzpts[Pt1], &rc);
         BSsfeval(&xsec_plane, rec[n][p].Keypt[Pt2][0], 
		  rec[n][p].Keypt[Pt2][1], 0, (IGRpoint *)xyzpts[Pt2], &rc);
         EMlocerrhndlr(rc!=BSSUCC, EMmsg, EMS_E_Fail, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, TRUE, NULL); 
		
         if(!p)
	   this_against->dist[m][n] = BSdistptpt(&rc, xyzpts[0], xyzpts[1]);
         this_against->NumOcc[m][n]++;
	
         junk = NULL_GRid;
         sts = EFplace_line_string(my_id, const_list, 2, xyzpts, &junk.objid, 
				 &rc);
         if(display && !IF_NULL_OBJID(junk.objid))
	   EMintfDisplay(plenv, &junk, TRUE);
         this_against->linesegs[m][n][p] = junk;

         sprintf(numname, "%d", p+1);
	 strcpy(elename, eleidentifier[m][n]);
         strcat(elename, numname);
         EMintf_christen(&junk, &GRid1, &GRid2, elename, NULL);

	}/* for(p=0; p< numRec[n]; p++) */
	
      } /* for(n=Min; n<=Max; n++) */

    } /* for(m=0; m<=NumIntfCases; m++)*/

   /* If areas are requested, output the loops contributing to the distances
      being output.
      Potentially there can be three planes output. One representing the 
      intersection between the two loopset,  and the other two consisting of
      all the unused loops from each of the loopsets.
   */
  if(!(options & EMSintf_NoAreaElems))
   {
    struct GRid	xsec;
    IGRboolean already_output = FALSE;

    /* Output the primary cross section only once.
    */
    if(!j && !inputxsec)
     {
      if(sfloopsUnused[0])
       {
        sts = EMoutAreaElem(EMmsg, plenv, &this_against->areas[0], 
		&pl, &to_sf, &to_ls, &to_assoc, sfloopsUnused[0]->num_comps, 
		sfloopsUnused[0]->comps, &ptol, FALSE);
        EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_NoMoreLoops, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, FALSE, FALSE);
       }
      if(sfloopsUsed[0])
       {
        sts = EMoutAreaElem(EMmsg, plenv, &this_against->areas[0], 
		&pl, &to_sf, &to_ls, &to_assoc, sfloopsUsed[0]->num_comps, 
		sfloopsUsed[0]->comps, &ptol, FALSE);
        EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_NoMoreLoops, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, FALSE, FALSE);
       }
      if(!IF_NULL_OBJID(this_against->areas[0].objid))
       {
        strcpy(elename, "CrossSection");
        EMintf_christen(&this_against->areas[0], &GRid1, NULL, elename, NULL);
	if(display) EMintfDisplay(plenv, &this_against->areas[0], TRUE);
       }
     }
    else if(!inputxsec)
      this_against->areas[0] = this_result->info.xsec[0].areas[0];

    /* Check if the cross section for the check element has already been
	output.
    */
    already_output = FALSE;
    xsec = NULL_GRid;

    for(p=0; (p<*num_result) && !already_output && i && !inputxsec; p++)
     for(q=0; (q<(*result)[p].numintf) && !already_output && i; q++)
      if( ((*result)[p].info.xsec[q].against_eleminfo.located_obj.objid ==
            GRid2.objid) &&
	     ((*result)[p].info.xsec[q].against_eleminfo.located_obj.osnum ==
               GRid2.osnum))
       {
	already_output = TRUE;
	xsec = (*result)[p].info.xsec[q].areas[1];
       }

    if(!already_output && !inputxsec)
     {
      if(sfloopsUnused[1])
       {
        sts = EMoutAreaElem(EMmsg, plenv, &this_against->areas[1], &pl, 
		&to_sf, &to_ls, &to_assoc, sfloopsUnused[1]->num_comps, 
		sfloopsUnused[1]->comps, &ptol, FALSE);
        EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_NoMoreLoops, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, FALSE, FALSE);
       }
      if(sfloopsUsed[1])
       {
        sts = EMoutAreaElem(EMmsg, plenv, &this_against->areas[1], &pl, 
		&to_sf, &to_ls, &to_assoc, sfloopsUsed[1]->num_comps, 
		sfloopsUsed[1]->comps, &ptol, FALSE);
        EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_NoMoreLoops, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, FALSE, FALSE);
       }
      if(!IF_NULL_OBJID(this_against->areas[1].objid))
       {
        strcpy(elename, "CrossSection");
        EMintf_christen(&this_against->areas[1], NULL, &GRid2, elename, NULL);
	if(display) EMintfDisplay(plenv, &this_against->areas[1], TRUE);
       }
     }
    else if(!inputxsec)
      this_against->areas[1] = xsec;

    /* Always output the partial interference area represented by the
       result_lps.
    */
    if(result_lps)
     {
      sts = EMoutAreaElem(EMmsg, plenv, &this_against->areas[2], 
		&pl, &to_sf, &to_ls, &to_assoc, numresult_lps, result_lps, 
		&ptol, FALSE);
      EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_NoMoreLoops, &Ele1[i], 
		&Ele2[j], &numfail, &failed, &failBufSize, FALSE, FALSE);

      /* Cross hatch the intf area -
	 View vector normal to the plane. Therefore provide a matrix
	 which aligns the plane normal with the z axis.
      */
      if(noxhatch) goto skip_chatch;

      if(!crosshatch_init && !IF_NULL_OBJID(this_against->areas[2].objid))
       {
	(void) MAzrotmx(&rc, plane->normal, chmat);
	if(!(1&rc)) goto skip_chatch;
	strcpy(material_type, "cast_iron");
	
	bytes_in = sizeof(IGRdouble);
	
	/* Get active angle. If problem use 45 degrees.
	*/
 	gr$get_xhatch_angle(msg = &rc, sizbuf = &bytes_in,
			    buffer = &hatch_angle, nret = &bytes_out);
 	if(!(1&rc)) hatch_angle = (45 * PI)/180.0;

        /* Get active spacing.
	   If problem use plane diagonal/(XHatchMaxRules-1)
	*/
	gr$get_xhatch_spacing(msg = &rc, sizbuf = &bytes_in,
			      buffer = &hatch_spacing, nret = &bytes_out);
	if(!(1&rc) || (hatch_spacing <= 0.0))
	 {
	  dist = BSdistptpt(&rc, plane_poles[1], plane_poles[2]);
	  hatch_spacing = dist/(XHatchMaxRules-1);
	 }
	
	/* Use first pole of the plane as the origin.
	*/
	OM_BLOCK_MOVE(xsec_plane.poles, hatch_origin, sizeof(IGRpoint));
        EFget_xh_definition(&rc, hatch_angle, hatch_origin, hatch_spacing, 
			    hatch_spacing, material_type, &hatch_info);
	if(!(1&rc)) goto skip_chatch;
	crosshatch_init = TRUE;
       }

      if(!IF_NULL_OBJID(this_against->areas[2].objid))
       {
	for(m=0; m<2; m++)
	 {

          /* Note the typecast for "chmat". This makes "chmat", (a pointer to an
           * array of 16 doubles i.e.IGRmatrix), look like it is a pointer to an
           * array of 4 doubles, which is pretty much what "mat" is when 
           * declared as "mat[4][4]" of IGRdouble. The "EMcross_hatch" method
           * expects a 4x4 matrix as input.
           */
          sts = om$send(msg = message EMSplane.EMcross_hatch
		(&rc, plenv, &hatch_info, (IGRdouble (*)[4])chmat), 
		targetid = this_against->areas[2].objid, 
		targetos = this_against->areas[2].osnum);
		
	  /* If we had excessive number of rule lines, use the maximum rule
	     lines allowed and reverse compute the spacing.
	  */
	  if(rc == EMS_I_OutOfBounds)
	   {
            crosshatch_init = FALSE;
	    if(m) goto skip_chatch;

	    dist = BSdistptpt(&rc, plane_poles[1], plane_poles[2]);
	    hatch_spacing = dist/(XHatchMaxRules-1);
  	    if (hatch_info.u_sgrp_info) 
	     om$dealloc (ptr = hatch_info.u_sgrp_info);
  	    if (hatch_info.v_sgrp_info) 
	     om$dealloc (ptr = hatch_info.v_sgrp_info);
	    hatch_info.v_sgrp_info = NULL;
	    hatch_info.u_sgrp_info = NULL;
            EFget_xh_definition(&rc, hatch_angle, hatch_origin, hatch_spacing, 
			    hatch_spacing, material_type, &hatch_info);
	    if(!(1&rc)) goto skip_chatch;
	   }
	  else
           break;

	 }/* for(m=0; m<2; m++) */
	
       } /* if(!IF_NULL_OBJID(this_against->areas[2].objid)) */

skip_chatch:
      sts = OM_S_SUCCESS;
      if(!IF_NULL_OBJID(this_against->areas[2].objid))
       {
        strcpy(elename, "IntfArea");
        EMintf_christen(&this_against->areas[2], &GRid1, &GRid2, elename, 
			NULL);
	if(display) EMintfDisplay(plenv, &this_against->areas[2], TRUE);
       }

     } /* if(result_lps) */
	
   } /* if(!(options & EMSintf_NoAreaElems)) */

   /* Group all the linesegments into a graphic group.
   */
   total_linesegs = 0;
   for(m=0; m<NumIntfCases; m++)
    for(n=0; n<2; n++) total_linesegs += this_against->NumOcc[m][n];

   if(total_linesegs > 1)
    {
     GRobjid junk;

     EMintf_dealloc(&linesegs, linesegsbuf);
     EMintf_malloc(&linesegs, linesegsbuf, Buffer, total_linesegs, 
		   sizeof(struct GRid));
     EMerr_hndlr(!linesegs, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

     total_linesegs = 0;
     for(m=0; m<NumIntfCases; m++)
      for(n=0; n<2; n++)
       {
        OM_BLOCK_MOVE(this_against->linesegs[m][n], &linesegs[total_linesegs], 
			this_against->NumOcc[m][n] * sizeof(struct GRid));
	total_linesegs += this_against->NumOcc[m][n];
       }
     
     sts = EFbuild_graphic_group(total_linesegs, NULL, linesegs, 
				const_list, &junk, EMmsg);
    }

next_check:
     (this_result->numintf)++;

    }/* for(j=0; j<NumEle2; j++) */

   (*num_result)++; 

  }/* for(i=0; i<NumEle1; i++) */

wrapup:
 
 if (stackptr)
   stackfree (stackptr);

 BSchgdeppar (bastol, &rc);
 if(!nomsg) ex$message(msgnumb = EMS_I_ClearStatusField);
 
 for(p=0; p<2; p++)
  {
   if(!lscs[p]) continue;
   for(i=0; i< (p ? NumEle2 : NumEle1) ; i++)
    rc = om$send(msg = message Root.delete(TRUE), targetid = lscs[p][i], 
			targetos = pl.osnum);
   EMintf_dealloc(&lscs[p], lscsbuf[p]);
  }

 if(!IF_NULL_OBJID(ls1))
  rc = om$send(msg = message Root.delete(TRUE), targetid = ls1, 
				targetos = pl.osnum);
 if(!IF_NULL_OBJID(ls2))
  rc = om$send(msg = message Root.delete(TRUE), targetid = ls2, 
				targetos = pl.osnum);
 for(i=0; i<2; i++)
   if(!IF_NULL_OBJID(lsnest[i]))
  rc = om$send(msg = message Root.delete(TRUE), targetid = lsnest[i], 
				targetos = pl.osnum);
 if(!IF_NULL_OBJID(pl.objid))
  rc = om$send(msg = message GRgraphics.GRdelete(&rc, plenv), 
	targetid = pl.objid, targetos = pl.osnum);

 if(!(options & EMSintf_NoReport))
  {
   IGRboolean repboth = FALSE, stdrep = FALSE;
   FILE *fileptr;

   repboth = options & EMSintf_ReportBoth;
   stdrep = repboth || !ReportFileName;
   if(ReportFileName)
    {
     fileptr = (FILE *) fopen(ReportFileName, "a");
     if(!fileptr) {*EMmsg = EMS_E_FileOpen; goto wrapup;}
     if(*num_result)
     EMintf_report(numchecked,
      Ele1, NumEle1, setnum1, SetInfo1,
      Ele2, NumEle2, setnum2, SetInfo2,
      *result, *num_result, options, fileptr);
     if(numfail)EMintf_failureReport(failed, numfail, fileptr);
     fclose(fileptr);
    }

   if(stdrep)
    {
     if(*num_result)
     EMintf_report(numchecked,
      Ele1, NumEle1, setnum1, SetInfo1,
      Ele2, NumEle2, setnum2, SetInfo2,
      *result, *num_result, options, stdout);
     if(numfail)EMintf_failureReport(failed, numfail, stdout);
    }
  }

 if((*result) && (*result == locresult))
  EMintf_free(*result, *num_result);
 if(failed) om$dealloc(ptr = failed);
 if(result_lps) om$dealloc(ptr = result_lps);
 if(nestlps) om$dealloc(ptr = nestlps);
 if(edges) om$dealloc(ptr = edges);

 for(p=0; p<2; p++)
  {
   if(lslps[p])
    {
     for(m=0; m<numlslps[p]; m++)
      rc = om$send(msg = message Root.delete(TRUE), targetid = lslps[p][m], 
				targetos = pl.osnum);
     om$dealloc(ptr = lslps[p]);
    }
   if(lpgm[p])
    {
     for(m=0; m<(p ? NumEle2 : NumEle1); m++)
      {
       if(lpgm[p][m])
        {
	 struct EMSintf_lpgm	*ptr;
	 ptr = lpgm[p][m];
	 while(TRUE)
	  {
	   if(ptr->lpgm) BSfreecv(&rc, ptr->lpgm);
	   if(ptr->islast) break;
	   ptr++;
	  }
	 if(lpgm[p] == lpgmbuf[p])
	  EMintf_dealloc(&lpgm[p][m], lpgmbufbuf[p][m]);
	 else om$dealloc(ptr = lpgm[p][m]);
        }
      }
     EMintf_dealloc(&lpgm[p], lpgmbuf[p]);
    }
  }

 EMintf_dealloc(&ismin, isminbuf);
 EMintf_dealloc(&ismax, ismaxbuf);

 for(n=0; n<2; n++) EMintf_dealloc(&rec[n], recbuf[n]);

 for(m=0; m<NumIntfCases; m++) 
  {
   if(info[m])
    {
     for(p=0; p<NumOcc[m]; p++)
      {
       rc = om$send(msg = message Root.delete(TRUE), targetid = 
				info[m][p].loopids[0], targetos = pl.osnum);
       rc = om$send(msg = message Root.delete(TRUE), targetid = 
				info[m][p].loopids[1], targetos = pl.osnum);
      }
     om$dealloc(ptr = info[m]);
    }
  }

 EMintf_dealloc(&linesegs, linesegsbuf);

 for(q=0; q<2; q++)
  {
   if(sfloopsUnused[q]) EMsfloops_free(&sfloopsUnused[q], pl.osnum);
   if(sfloopsUsed[q]) EMsfloops_free(&sfloopsUsed[q], pl.osnum);
  }
 if(entryInx) om$dealloc(ptr = entryInx);
 if(lpcv) BSfreecv(&rc, lpcv);
 EMintf_dealloc(&iscoinc, iscoincbuf);

 if (hatch_info.u_sgrp_info) 
  om$dealloc (ptr = hatch_info.u_sgrp_info);
 if (hatch_info.v_sgrp_info) 
  om$dealloc (ptr = hatch_info.v_sgrp_info);
 if(srf) om$dealloc(ptr = srf);

 if(intpt) *EMmsg = EMS_I_Interrupt;
 EMWRAPUP(*EMmsg,sts,"In EMSsurface.EManalyzeIntfAlongXsec");
 return(sts);
}



#ifdef __STDC__
#argsused
#endif
static IGRint EMoutAreaElem(EMmsg, plenv, areaelem, pl, to_sf, to_ls, to_assoc,
			     numlps, lps, ptol, display)
IGRlong			*EMmsg;
struct GRmd_env		*plenv;
struct GRid		*areaelem;
struct GRid		*pl;
OM_S_CHANSELECT		*to_sf, *to_ls, *to_assoc;
IGRint			numlps;
GRobjid			*lps;
struct EMSpartolbasis   *ptol;
IGRboolean		display;
{
 IGRlong	sts = OM_S_SUCCESS;
 GRobjid	junk;
 IGRint		i, j;
 struct EMSnest_info nesting;
 IGRboolean	atleastone = FALSE, duplicate = FALSE;
 extern void    EMintfDisplay();

 *EMmsg = EMS_S_Success;

 for(i=0; i<numlps; i++)
   if(!IF_NULL_OBJID(lps[i]))
    {
     atleastone = TRUE;
     break;
    }

 if(!atleastone) {*EMmsg = EMS_I_Useless; goto wrapup;}

 if(IF_NULL_OBJID(areaelem->objid))
  {
   sts = om$send(msg = message GRvg.GRcopy
		(EMmsg, plenv, plenv,&areaelem->objid),
			targetid = pl->objid, targetos = pl->osnum, 
			senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
   areaelem->osnum = pl->osnum;
   sts = om$construct(classid = OPP_EMSloopset_class_id, 
		 osnum = pl->osnum, p_objid = &junk, 
		 msg = message Root.connect(*to_sf, 0, areaelem->objid, 
					    pl->osnum, *to_ls, 0));
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else
  {
   OM_S_OBJECT_LINKAGE		ls;
   IGRuint			count;

   sts = om$get_channel_objects(objid = areaelem->objid, 
		osnum = areaelem->osnum, p_chanselect = to_ls, list=&ls, 
		size = 1, count = &count);
   if(!(1&*EMmsg&sts)) goto wrapup;		
   junk = ls.S_objid;
  }

 for(i=0; i<numlps; i++)
  {
   duplicate = FALSE;

   if(IF_NULL_OBJID(lps[i])) continue;

   /* Ignore loops already added to the plane.
   */
   for(j=0; j<i; j++)
     if(IF_EQ_OBJID(lps[j], lps[i])) {duplicate = TRUE; break;}

   if(duplicate) continue;

   sts = om$send(msg = message EMSloop.EMtreemod(EMmsg, &nesting, 
				EXTRACT, ptol), targetid = lps[i], 
				targetos = pl->osnum, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) continue;

   sts = om$send(msg = message Root.wild_disconnect(*to_assoc), 
			targetid = lps[i], targetos = pl->osnum, 
			senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) continue;

   sts = om$send(msg = message EMSloop.EMset_props
			(EMmsg, EMLP_EXTERNAL, EMS_O_OFF), 
 	 targetid = lps[i], targetos = pl->osnum, senderid = NULL_OBJID);
				
   sts = om$send(msg = message EMSloop.EMset_props
			(EMmsg, EMLP_ACTIVE, EMS_O_ON), 
	 targetid = lps[i], targetos = pl->osnum, senderid= NULL_OBJID);
				
   sts = om$send(msg = message EMSloopset.EMnesting(EMmsg, &nesting, ptol), 
			targetid = junk, targetos = pl->osnum, 
			senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) continue;

   if(IF_EQ_OBJID(nesting.parent, junk))			
     sts = om$send(msg = message EMSloopset.EMtreemod(EMmsg, &nesting, 
				ADD_CHILD, ptol), targetid = junk, 
				targetos = pl->osnum, senderid = NULL_OBJID);
   else
     sts = om$send(msg = message EMSloop.EMtreemod(EMmsg, &nesting, 
				ADD_CHILD, ptol), targetid = nesting.parent, 
				targetos = pl->osnum, senderid = NULL_OBJID);
  }

 if(display && !IF_NULL_OBJID(areaelem->objid))
   EMintfDisplay(plenv, areaelem, TRUE);

wrapup:
return(sts);

}



#ifdef __STDC__
#argsused
#endif

static IGRboolean EMislpinarr(lpid, lslps, numlslps)
GRobjid lpid, *lslps;
IGRint  numlslps;
{
 IGRint i;

 for(i=0; i<numlslps; i++)
   if(IF_EQ_OBJID(lpid, lslps[i])) return(TRUE);
 return(FALSE);
}


#ifdef __STDC__
#argsused
#endif
static IGRboolean EMislsped (EMmsg, lslps, numlslps, edgeid, to_assoc)
IGRlong *EMmsg;
GRobjid *lslps;
IGRint numlslps;
struct GRid *edgeid;
OM_S_CHANSELECT *to_assoc;
{
 IGRint	i, sts;
 IGRboolean islsped = FALSE;

 for(i=0; i<numlslps && !islsped; i++)
  {
   sts = om$is_objid_on_channel(objid_c = lslps[i], 
			p_chanselect = to_assoc, osnum_c = edgeid->osnum, 
			objid = edgeid->objid, osnum2 = edgeid->osnum);
   if(sts == OM_S_SUCCESS)
    {
     IGRushort lpprops;
	
     sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &lpprops), 
			targetid = lslps[i], targetos = edgeid->osnum, 
			senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(lpprops & EMLP_PLOOP)
      islsped = TRUE;
    }
  }

wrapup:

return(islsped);
}

#ifdef __STDC__
#argsused
#endif
static IGRboolean EMislsed (EMmsg, lslps, numlslps, edgeid, to_assoc)
IGRlong *EMmsg;
GRobjid *lslps;
IGRint numlslps;
struct GRid *edgeid;
OM_S_CHANSELECT *to_assoc;
{
 IGRint	i, sts;
 IGRboolean islsed = FALSE;

 for(i=0; i<numlslps && !islsed; i++)
  {
   sts = om$is_objid_on_channel(objid_c = lslps[i], 
			p_chanselect = to_assoc, osnum_c = edgeid->osnum, 
			objid = edgeid->objid, osnum2 = edgeid->osnum);
   if(sts == OM_S_SUCCESS)
    islsed = TRUE;
  }
return(islsed);
}


#ifdef __STDC__
#argsused
#endif
static void EMsfloops_free(sfloops, plos)
struct EMSownercomp **sfloops;
GRspacenum plos;
{
 IGRint i, sts;
 extern void EMownercomp_free();

 if(*sfloops)
  {
   for(i=0; i<(*sfloops)->num_comps; i++)
    sts = om$send(msg = message Root.delete(TRUE), 
		targetid = (*sfloops)->comps[i], targetos = plos, 
		senderid = NULL_OBJID);
   EMownercomp_free(*sfloops, NULL);
   *sfloops = NULL;
  }
}



#ifdef __STDC__
#argsused
#endif
static void EMintf_recordInfo(EMmsg, info, NumOcc, BufSize, inx, lp1, lp2, 
			      dist, pts)
IGRlong *EMmsg;
struct EMSintfloc_record *info[];
IGRint NumOcc[], BufSize[], inx;
GRobjid lp1, lp2;
IGRdouble dist, *pts;
{
 IGRint	junk = sizeof(struct EMSintfloc_record);

 *EMmsg = EMS_S_Success;

 if(!BufSize[inx])
  {
   if(info[inx])
    info[inx] = (struct EMSintfloc_record *) om$realloc(size =
		(NumOcc[inx] + Buffer) * junk, ptr = (IGRchar *)(info[inx]));
   else
    info[inx] = (struct EMSintfloc_record *) om$malloc(size = Buffer * junk);
   EMerr_hndlr(!info[inx],*EMmsg, EMS_E_NoDynamicMemory, wrapup);
   BufSize[inx] = Buffer;
  }

 info[inx][NumOcc[inx]].dist = dist;
 OM_BLOCK_MOVE(pts, info[inx][NumOcc[inx]].Keypt, 4 * sizeof(IGRdouble));
 info[inx][NumOcc[inx]].loopids[0] = NULL_OBJID;
 info[inx][NumOcc[inx]].loopids[1] = NULL_OBJID;
 info[inx][NumOcc[inx]].loopids[0] = lp1;
 info[inx][NumOcc[inx]].loopids[1] = lp2;
 NumOcc[inx]++;
 BufSize[inx]--;

wrapup:
;
}




#ifdef __STDC__
#argsused
#endif
static void EMremakeownlist(EMmsg, sfloops, lpid)
IGRlong	*EMmsg;
struct EMSownercomp **sfloops;
GRobjid	lpid;
{
 extern void EMownercomp_free();
 struct EMSownercomp	*loc_sfloops = NULL;
 IGRint			i, to_remove = 0;
 IGRboolean		list_ext;

 if(!(*sfloops)) goto wrapup;

 for(i=0; i<(*sfloops)->num_comps; i++)
  if(IF_EQ_OBJID(lpid, (*sfloops)->comps[i]))
    {to_remove++; break;}
 if(!to_remove) goto wrapup;

 for(i=0; i<(*sfloops)->num_comps; i++)
  if(!IF_EQ_OBJID(lpid, (*sfloops)->comps[i]))
   {
    EMmkownlist(EMmsg, &loc_sfloops, NULL_OBJID, NULL, (*sfloops)->comps[i], 
		 FALSE, &list_ext);
    if(!(1&*EMmsg)) goto wrapup;
   }

 if(*sfloops)
  EMownercomp_free(*sfloops, NULL);

 *sfloops = loc_sfloops;

wrapup:
;
}




#ifdef __STDC__
#argsused
#endif
static IGRboolean EMlpsprocessed(info, NumOcc, inx, lp1, lp2)
struct EMSintfloc_record *info[];
IGRint NumOcc[], inx;
GRobjid lp1, lp2;
{
 IGRint		i;
 IGRboolean	processed = FALSE;
 GRobjid	clp1, clp2;

 for(i=0; i<NumOcc[inx]; i++)
  {
   clp1 = info[inx][i].loopids[0];
   clp2 = info[inx][i].loopids[1];
   if( (IF_EQ_OBJID(lp1, clp1) && IF_EQ_OBJID(lp2, clp2)) ||
       (IF_EQ_OBJID(lp1, clp2) && IF_EQ_OBJID(lp2, clp1)))
    {
     processed = TRUE;
     break;
    }
  }
return(processed);
}



#ifdef __STDC__
#argsused
#endif
static IGRlong EMintf_getlpgm(EMmsg, numlps, lps, gm, lpid, lpos, lpgm, ptol)
IGRlong		*EMmsg;
IGRint		numlps;
GRobjid		*lps;
struct EMSintf_lpgm *gm;
GRobjid		lpid;
GRspacenum	lpos;
struct IGRbsp_curve **lpgm;
struct EMSpartolbasis *ptol;
{
 IGRint		i, lpinx = 0;
 IGRboolean	found = FALSE;
 IGRlong	sts = OM_S_SUCCESS, rc;

 *EMmsg = EMS_S_Success;
 *lpgm = NULL;
 
 /* Get the loop index in the array.
 */
 for(i=0; i<numlps; i++)
  if(IF_EQ_OBJID(lpid, lps[i]))
   {
    found = TRUE;
    lpinx = i;
    break;
   }

 if(!found) goto wrapup;

 /* If the geometry array has a valid objid, the geometry has been already
    obtained. Else obtain it and put it in the array.
 */
 if(!IF_NULL_OBJID(gm[lpinx].lpid))
   *lpgm = gm[lpinx].lpgm;
 else
  {
   sts = om$send(msg = message EMSloop.EMgetbcgeom(EMmsg, lpgm, ptol, NULL), 
		targetid = lpid, targetos = lpos, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
   gm[lpinx].lpid = lpid;
   gm[lpinx].lpgm = *lpgm;
  }

wrapup:
if(!(1&sts) && *lpgm)
 {
  BSfreecv(&rc, *lpgm);
  *lpgm = NULL;
 }

return(sts);
}




#ifdef __STDC__
#argsused
#endif
static void EMintf_dealloc(charptr, buf)
IGRchar **charptr, *buf;
{
 if(*charptr && (*charptr != buf))
  om$dealloc(ptr = *charptr);
 *charptr = NULL;
}

#ifdef __STDC__
#argsused
#endif
static void EMintf_malloc(charptr, buf, bufsize, num, datsize)
IGRchar **charptr, *buf;
IGRint bufsize, num, datsize;
{
 *charptr = NULL;
 if(num > bufsize)
  *charptr = om$malloc(size = num * datsize);
 else *charptr = buf;
}
end implementation EMSsurface;
