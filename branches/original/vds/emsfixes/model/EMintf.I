/*
Abstract
  This messages analyzes interference between EACH element of a set against
  ALL elements of another set.

Arguments
	SetInfo1	input		The set information
	Ele1		input		Set of elements to be checked for
					interference. There will be a structure
					per element. 
	NumEle1		input		Number of elements in above array.
	setnum1		input		The index or number of the set
					that should be included in the report
	SetInfo2	input		The set information
	Ele2  		input		Set of elements against which each 
					element of the first set is to
					be checked.
	NumEle2 	input		Number of elements in above array
	setnum1		input		The index or number of the set
					that should be included in the report
	options		input		See EMSintf.h
	ReportFileName	input		Filename in which the report is to
					be written. If EMinterference_NoReport
					is specified, this will be
					ignored. If report desired and this 
					is NULL, stdout will be used.
	const_list	input		If intersection curves are to be
					constructed.
	result		output		Results of the analysis, optionally
					returned back.
	num_results	output		number of structures in the result
					array.
					All the output memory is always
					allocated by the method. All the
					memory MUST be freed via the function
					EMintf_free().
Return Values

Files
	EMsfintf.I
History
	SM	03-Jun-89	Creation.
	SM	18-Sep-89	Added and supported option EMSintf_Display
				to display the curve and volume elements
				as soon as they are computed.
	SM	11-May-90	If same object is in both sets, prevent
				self intersection.
        SM      08-Apr-92       When processing same GRid but with different
                                envs (as in same file attatched twice in
                                different orientations),  make copies before
                                intersection. This is because
                                the inters list and the uv intobj are linked
                                based on GRid only. If both operands have
				same GRid everything goes haywire wrt tracing
                                fixing etc.
        NP      27-Aug-92	Modified for ANSI compliance.
        ???     22-Mar-93       Who knows?
        scw     25-jun-93       Added buffer_size to ex$message call
*/

class implementation EMSsurface;

#include "EMS.h"

#ifndef DEBUG
#define DEBUG 0
#endif

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
#include "msmacros.h"         /* struct MS_sd_msg for ex$message */
#include "emssfintdef.h"
#include "emsbool.h"
#include "emserr.h"
#include "emsmacros.h"

/* ex$message */
# include "msmacros.h"
#include "EC_M.h"       /* Command strings */
#include "EC_I.h"       /* Status strings */
#include "EC_P.h"       /* Prompt strings */
#include "EC_F.h"       /* Error box strings */
#include "EC_E.h"       /* Error strings */
#include "EMStpmacros.h"
#include "EMSsffmacros.h"

//#include	<v_miscmacros.h>

//#define	VD_DEBUG
//#include	<VDdebug.h>

#if DEBUG
#define ResultBufInc	1
#else
#define ResultBufInc	20
#endif

/* method specific error handling macros. 
*/
#define EMlocerrinit(cond, e1, e2, e3, junk) \
	{\
	 if((cond)) \
	  {\
	   (e1).objid = NULL_OBJID;\
	   (e2).objid = NULL_OBJID;\
	   (e3).objid = NULL_OBJID;\
	   (junk) = FALSE;\
	  }\
	}
	
#define EMlocerrhndlr(cond, code, reccode, ele1, ele2, numf, f, buf, skip)\
	{\
	 if( (cond) ) \
	  {\
	   *(code) = (reccode);\
	   EMintf_recordFailure( (code), (ele1), (ele2), (numf),\
					(f), (buf), EMqualitative);\
	   sts = OM_S_SUCCESS; \
	   if((skip)) continue;\
	  }\
	}
	
extern OMuword OPP_EMSslboolean_class_id, OPP_EMSsolid_class_id, 
	       OPP_EMSsfboolean_class_id, OPP_EMSsurface_class_id;
/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

	
from GRowner import GRget_siblings, GRpass_messg;
from EMSdpr import EMmake_primitive1;

#define MaxInters 20
#define NUM_STATIC_SIBLINGS 20

%safe
static void	EMcleanup(), EMinsideOutside(), EMinit();
%endsafe


IGRlong EManalyzeIntf(EMmsg,
                      SetInfo1, Ele1, NumEle1, setnum1,
		      SetInfo2, Ele2, NumEle2, setnum2,
		      options,
		      ReportFileName, const_list, result, num_result)
IGRlong *EMmsg;
struct GRlc_info *SetInfo1, *Ele1;
IGRint NumEle1, setnum1;
struct GRlc_info *SetInfo2, *Ele2;
IGRint NumEle2, setnum2;
IGRushort options;
IGRchar *ReportFileName;
struct GRvg_construct *const_list;
struct EMSintf **result;
IGRint *num_result;
{
 IGRchar		*stackptr;
 IGRboolean		*in_set2, *in_set1, sameobj = FALSE;
 IGRlong		rc, sts = OM_S_SUCCESS;
 IGRint			i, j, k, bufSize = 0, numchecked = 0, num_siblings;
 struct EMSintf		*locresult = NULL, *locptr = NULL;
 struct GRid		intersobj, volelem, op1, op2;
 struct GRid		sibling_store[NUM_STATIC_SIBLINGS], *siblings;
 IGRint			locnumresult = 0, num_inters = 0;
 void			EMintf_free();
 IGRboolean		nocurves = FALSE, nomsg = FALSE, intpt = FALSE, 
			novol = FALSE, outp;
 IGRchar 		str_array[MS_MAX_MSG_LENGTH+1];
// IGRchar		sts_array[MS_MAX_MSG_LENGTH+1];
 IGRchar		*sts_array = NULL;

 extern void	        EMintf_report(), EMintf_failureReport(), 
			EMintf_recordFailure(), EMintfDisplay();

 struct EMSintf_failure *failed = NULL;
 IGRint			failBufSize = 0, numfail = 0, RbufSize = 0;
 extern IGRboolean	IGEstop(), EMisElementSame(), EMisFirstDominant();
 struct EMSinters	*inters[2];
 struct EMSsftracedata  trace[2];
 struct GRmdenv_info    *envinfo1, *envinfo2;
/* extern IGRlong	EMintersect_surfaces();*/
 extern IGRlong         EMboolean_with_intersection(); 
 /*extern IGRlong	EMsfint_topology_validate();*/
 /*extern IGRlong	EMdupinters();*/
 struct EMSsfintloopsdata sfintloopsdata[2], *loopdata[2];

 IGRboolean save_pathway_trim, save_pathway_orient;

// __enterFunction ( name = "EManalyzeIntf" );

 *EMmsg = EMS_S_Success;
 str_array[0] = '\0';

 stackptr = NULL;
 siblings = NULL;

 nocurves = options & EMSintf_NoCurves;
 nomsg = options & EMSintf_NoStatMsg;
 novol = options & EMSintf_NoVolElems ? TRUE : FALSE;
 if (nocurves && novol)
   outp = FALSE;
  else
   outp = TRUE;

 EMinit(trace, inters, sfintloopsdata, loopdata, FALSE);
 if(!result) result = &locresult;
 if(!num_result) num_result = &locnumresult;
 *result = NULL;
 *num_result = 0;

 EMerr_hndlr(!Ele1 || !Ele2, *EMmsg, EMS_E_InvalidArg, wrapup);
 EMerr_hndlr( (options & EMSintf_ReportBoth) && !ReportFileName, 
	     *EMmsg, EMS_E_InvalidArg, wrapup);

 /*
  * Prepare lists of Boolean flags for the two sets, indicating the elements
  * that are contained in both sets
  */

 stackptr = (IGRchar *)stackalloc ((NumEle1 + NumEle2) * sizeof (IGRboolean));
 EMerr_hndlr (!stackptr, *EMmsg, EMS_E_NoStackMemory, wrapup);

// __printf ( ">>>>> stackalloc() : size = %d, stackptr = %#x", `(NumEle1 + NumEle2) * sizeof (IGRboolean), stackptr` );

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

 /*
  * Begin interference checking.
  */

 volelem.osnum = const_list->env_info->md_id.osnum;
 for(i=0; (i<NumEle1) && !intpt; i++)
  {
   IGRboolean atleastone = FALSE;
   struct EMSintf_qualitative **against;
   struct EMSintf *this_result;

   op1.objid = NULL_OBJID;
   op2.objid = NULL_OBJID;
   volelem.objid = NULL_OBJID;

   if((intpt = IGEstop())) break;	/* user interrupt */

//   __printf ( ">>>>> i =  %d", `i` );

   if(RbufSize)
    {
     this_result = (struct EMSintf *) &(*result)[*num_result];
     this_result->numintf = 0;
     this_result->intfInfoType = EMqualitative;
     this_result->info.qualitative = NULL;
     against = (struct EMSintf_qualitative **) &this_result->info.qualitative;
    }

   numchecked++;
   for(j=0; (j<NumEle2) && !intpt; j++)
    {
     IGRboolean		found;
//     IGRchar		sts_array[MS_MAX_MSG_LENGTH+1];
     IGRushort	outworld_opt, outparam_opt, trim_opt, inters_opt;
     struct EMSdataselect other;
     struct GRid	GRid1, GRid2;
     struct GRmd_env	*env1, *env2, *openv;
     IGRboolean		sol1, sol2;
     IGRboolean		sf1, sf2;
     OMuword		cid;

//   __printf ( ">>>>>>>>>> i =  %d, j = %d", `i, j` );

     if((intpt = IGEstop())) break; 	/* user interrupt */
     GRid1 = Ele1[i].located_obj;
     GRid2 = Ele2[j].located_obj;
     env1 = &Ele1[i].module_info;
     env2 = &Ele2[j].module_info;
     openv = const_list->env_info;
     other.datatype = EMSdata_object;
     other.data.object = &GRid2;

     op1.objid = NULL_OBJID;
     op2.objid = NULL_OBJID;
     volelem.objid = NULL_OBJID;
//     sts_array[0] = '\0';

     if(IF_EQ_GRID(GRid1, GRid2)) sameobj = TRUE;
     else sameobj = FALSE;

     if (in_set2[i] && in_set1[j] &&
         (EMisElementSame (&GRid1, &GRid2,
           env1->md_env.matrix_type, env2->md_env.matrix_type,
           env1->md_env.matrix, env2->md_env.matrix) ||
         !EMisFirstDominant (&GRid1, &GRid2, 
           env1->md_env.matrix_type, env2->md_env.matrix_type,
           env1->md_env.matrix, env2->md_env.matrix)))
       continue;

     /*
      * Check if GRid2 is a "sibling" of GRid1 (if GRid1 is a GRowner).
      * If so, then this check is skipped.
      */

     om$get_classid (objid = GRid1.objid, osnum = GRid1.osnum,
      p_classid = &cid);
     if (om$is_ancestry_valid (subclassid = cid, 
          superclassid = OPP_GRowner_class_id) == OM_S_SUCCESS)
       {

//   __printf ( ">>>>>>>>>> 1 GRowner.GRget_siblings() i =  %d, j = %d", `i, j` );

       sts = om$send (msg = message GRowner.GRget_siblings (EMmsg, NULL,
              &num_siblings, &siblings, NUM_STATIC_SIBLINGS, sibling_store),
              targetid = GRid1.objid, targetos = GRid1.osnum,
              senderid = NULL_OBJID);
       EMerr_hndlr (EMSerror (sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

       found = FALSE;
       for (k=0; k<num_siblings; k++)
         if (GRid2.objid == siblings[k].objid &&
             GRid2.osnum == siblings[k].osnum)
           {
           found = TRUE;
           break;
           }
       if (siblings && siblings != sibling_store)
       {
//         _FREE ( siblings );
         om$dealloc (ptr = siblings);
       }

//   __printf ( "<<<<<<<<<< 1 GRowner.GRget_siblings() i =  %d, j = %d, found = %d", `i, j, found` );

       if (found)
         continue;
       }

     /*
      * Check if GRid1 is a "sibling" of GRid2 (if GRid2 is a GRowner).
      * If so, then this check is skipped.
      */

     om$get_classid (objid = GRid2.objid, osnum = GRid2.osnum,
      p_classid = &cid);
     if (om$is_ancestry_valid (subclassid = cid, 
          superclassid = OPP_GRowner_class_id) == OM_S_SUCCESS)
       {

//   __printf ( ">>>>>>>>>> 2 GRowner.GRget_siblings() i =  %d, j = %d", `i, j` );

       sts = om$send (msg = message GRowner.GRget_siblings (EMmsg, NULL,
              &num_siblings, &siblings, NUM_STATIC_SIBLINGS, sibling_store),
              targetid = GRid2.objid, targetos = GRid2.osnum,
              senderid = NULL_OBJID);
       EMerr_hndlr (EMSerror (sts & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

       found = FALSE;
       for (k=0; k<num_siblings; k++)
         if (GRid1.objid == siblings[k].objid &&
             GRid1.osnum == siblings[k].osnum)
           {
           found = TRUE;
           break;
           }
       if (siblings && siblings != sibling_store)
       {
//         _FREE ( siblings );
         om$dealloc (ptr = siblings);
       }

//   __printf ( "<<<<<<<<<< 2 GRowner.GRget_siblings() i =  %d, j = %d, found = %d", `i, j, found` );

       if (found)
         continue;
       }

     if (!nomsg)
       {
       if (setnum1 != setnum2)
         sprintf(str_array, "Set #%d - Elem %d : Set #%d - Elem %d",
          setnum1, i+1, setnum2, j+1);
       else
         sprintf(str_array, "Set #%d - Elem %d : Elem %d",
          setnum1, i+1, j+1);
/*
       ex$message(msgnumb = EMS_I_ProcessingSomething, var = `str_array`, 
		  type = "%s");
       ex$message(msgnumb = EMS_I_ProcessingSomething, var = `str_array`, 
                  type = "%s", buff = sts_array, 
                  buffer_size = (sizeof(sts_array)));

       UI_status ( str_array );
       memcpy (sts_array, str_array, MS_MAX_MSG_LENGTH+1 );
*/
       }

     intersobj.osnum = volelem.osnum;
     intersobj.objid = NULL_OBJID;

     num_inters = 0;
     outworld_opt = EMSINT_OUTPUT_WORLD;

     outparam_opt = EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT |
                     EMSINT_ORIENT_OUTPUT | EMSINT_ORIENT_RIGHT;

     trim_opt = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA |
                EMSINT_TRIM_COPLANAR | EMSINT_TRIM_MOREPRECISE | 
	        EMSINT_TRIM_PROCOVERLAP | EMSINT_TRIM_ONLYCUTTING;

     inters_opt = EMS_SFINT_DOUBLECHECK | EMS_SFINT_HANDLESTOP |
                  (!outp ? EMS_SFINT_YESORNO : NULL);

     EMinit(trace, inters, sfintloopsdata, loopdata, TRUE);

     sol1 = sol2 = sf1 = sf2 = TRUE;
     om$get_classid (objid = GRid1.objid, osnum = GRid1.osnum, 
      p_classid = &cid);
     if (om$is_ancestry_valid (superclassid = OPP_EMSsolid_class_id, 
          subclassid = cid) != OM_S_SUCCESS)
       sol1 = FALSE;
     if (om$is_ancestry_valid (superclassid = OPP_EMSsurface_class_id, 
          subclassid = cid) != OM_S_SUCCESS)
       sf1 = FALSE;

     om$get_classid (objid = GRid2.objid, osnum = GRid2.osnum, 
      p_classid = &cid);
     if (om$is_ancestry_valid (superclassid = OPP_EMSsolid_class_id, 
          subclassid = cid) != OM_S_SUCCESS)
       sol2 = FALSE;
     if (om$is_ancestry_valid (superclassid = OPP_EMSsurface_class_id, 
          subclassid = cid) != OM_S_SUCCESS)
       sf2 = FALSE;

     if (!sf1 || !sf2)
       {
       IGRint inx1, inx2;
       IGRlong msg_loc, msg_rc, pass_rc;
       struct GRmdenv_info *this_mdenv_info, *other_mdenv_info;
       struct GRid this_grid, other_grid;
       OM_S_CLASSLIST sfclass_list;

       sfclass_list.p_classes = &OPP_EMSsurface_class_id;
       sfclass_list.w_count = 1;
       sfclass_list.w_flags = OM_CLST_subclass;

       if (!sf1)
         {
         inx1 = 0;
         inx2 = 1;

         this_grid = GRid1;
         other_grid = GRid2;

         this_mdenv_info = &env1->md_env;
         other_mdenv_info = &env2->md_env;
         }
       else
         {
         inx1 = 1;
         inx2 = 0;

         this_grid = GRid2;
         other_grid = GRid1;

         this_mdenv_info = &env2->md_env;
         other_mdenv_info = &env1->md_env;
         }

//   __printf ( ">>>>>>>>>> 1 GRowner.GRpass_messg->EMSsurface.EMowner_sfsfint() i =  %d, j = %d", `i, j` );


       sts = om$send (msg = message GRowner.GRpass_messg (&pass_rc, NULL,
              OM_e_wrt_object, message EMSsurface.EMowner_sfsfint (&msg_rc,
              this_mdenv_info, &other_grid, other_mdenv_info, 
              inters_opt, outworld_opt, outparam_opt, trim_opt, const_list,
              &num_inters, &inters[inx1], &inters[inx2],
              nocurves ? NULL : &intersobj.objid, NULL, sts_array),
              this_mdenv_info,
              &sfclass_list, NULL, NULL, NULL, MAXINT), 
              targetid = this_grid.objid, targetos = this_grid.osnum,
              senderid = NULL_OBJID);

//   __printf ( "<<<<<<<<<< 1 GRowner.GRpass_messg->EMSsurface.EMowner_sfsfint() i =  %d, j = %d", `i, j` );

       }
     else
       {
	if(sameobj)
	 {
 	  struct EMSdataselect locother;
/****************************************************************************	
          sts = EMdupinters(EMmsg, NULL, NULL, FALSE, TRUE, 
		&Ele1[i].located_obj, &op1, TRUE, env1, const_list, NULL, NULL,
		0, NULL, NULL, 0);
****************************************************************************/

//   __printf ( ">>>>>>>>>> 1 ems$dupinters() i =  %d, j = %d", `i, j` );

          sts = ems$dupinters(msg = EMmsg,
                              copyintobjs = FALSE,
                              delorigintobjs = TRUE,
                              origsfid = &Ele1[i].located_obj,
                              copysfid = &op1,
                              origsfenv = env1,
                              construction_args = const_list);  
          if(!(1&*EMmsg&sts)) EMcleanup(&op1, &op2, &volelem, openv);
          EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Intersect, &Ele1[i], 
          &Ele2[j], &numfail, &failed, &failBufSize, TRUE); 

//   __printf ( "<<<<<<<<<< 1 ems$dupinters() i =  %d, j = %d", `i, j` );

/***************************************************************************
          sts = EMdupinters(EMmsg, NULL, NULL, FALSE, TRUE, 
		&Ele2[j].located_obj, &op2, TRUE, env2, const_list, NULL, NULL,
		0, NULL, NULL, 0);
          if(!(1&*EMmsg&sts)) EMcleanup(&op1, &op2, &volelem, openv);
***************************************************************************/

//   __printf ( ">>>>>>>>>> 2 ems$dupinters() i =  %d, j = %d", `i, j` );

          sts = ems$dupinters(msg = EMmsg,
                              copyintobjs = FALSE,
                              delorigintobjs = TRUE,
                              origsfid = &Ele2[j].located_obj,
                              copysfid = &op2,
                              origsfenv = env2,
                              construction_args = const_list);
          EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Intersect, &Ele1[i], 
          &Ele2[j], &numfail, &failed, &failBufSize, TRUE); 

//   __printf ( "<<<<<<<<<< 2 ems$dupinters() i =  %d, j = %d", `i, j` );
	
	  locother.datatype = EMSdata_object;
	  locother.data.object = &op2;
/***************************************************************************
          sts = EMintersect_surfaces(EMmsg, &op1, &openv->md_env, 1, 
                &locother, &openv->md_env, inters_opt, outworld_opt, 
                outparam_opt, trim_opt, const_list, &num_inters, &inters[0], 
                &inters[1], &trace[0], &trace[1], 
                nocurves ? NULL : &intersobj.objid, NULL, sts_array);
          EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Intersect, &Ele1[i], 
          &Ele2[j], &numfail, &failed, &failBufSize, TRUE); 
***************************************************************************/

          save_pathway_trim = _pathway_trim;
          save_pathway_orient = _pathway_orient;
          _pathway_trim = 0;
          _pathway_orient = 0;

//   __printf ( ">>>>>>>>>> 1 ems$intersect_surfaces() i =  %d, j = %d", `i, j` );

          sts = ems$intersect_surfaces(
                              msg = EMmsg,
                            surface1 = &op1,
                            surface1env = &openv->md_env,
                             numsurfaces2 = 1,
                              surfaces2 = &locother,
                              surfaces2env = &openv->md_env,
                              inters_opts = inters_opt,
                                world_opts = outworld_opt,
                              param_opts = outparam_opt,
                              trim_opts = trim_opt,
                              construction_args = const_list,
                              num_inters = &num_inters,
                              surface1_inters = &inters[0],
                              surfaces2_inters = &inters[1],
                              surface1_tracedata = &trace[0],
                              surfaces2_tracedata = &trace[1],
                       inters_outputobj = nocurves ? NULL : &intersobj.objid, 
                              status_str = sts_array);
                               
          _pathway_trim = save_pathway_trim;
          _pathway_orient = save_pathway_orient;

//   __printf ( "<<<<<<<<<< 1 ems$intersect_surfaces() i =  %d, j = %d", `i, j` );

	 }
	else
	 {
/****************************************************************************
          sts = EMintersect_surfaces(EMmsg, &GRid1, &env1->md_env, 1, &other, 
                &env2->md_env, inters_opt, outworld_opt, outparam_opt, 
                trim_opt, const_list, &num_inters, &inters[0], &inters[1],
                &trace[0], &trace[1], nocurves ? NULL : &intersobj.objid, NULL,
                sts_array);
****************************************************************************/

          save_pathway_trim = _pathway_trim;
          save_pathway_orient = _pathway_orient;
          _pathway_trim = 0;
          _pathway_orient = 0;

//   __printf ( ">>>>>>>>>> 2 ems$intersect_surfaces() i =  %d, j = %d", `i, j` );

          sts = ems$intersect_surfaces(
                                 msg = EMmsg,
                              surface1 = &GRid1,
                              surface1env = &env1->md_env,
                              numsurfaces2 = 1,
                               surfaces2 = &other,
                               surfaces2env = &env2->md_env,
                               inters_opts = inters_opt,
                               world_opts = outworld_opt,
                              param_opts = outparam_opt,
                               trim_opts = trim_opt,
                            construction_args = const_list,
                               num_inters = &num_inters,
                               surface1_inters = &inters[0],
                               surfaces2_inters = &inters[1],
                               surface1_tracedata = &trace[0],
                               surfaces2_tracedata = &trace[1],
                         inters_outputobj = nocurves ? NULL : &intersobj.objid,
                                status_str = sts_array);

	  _pathway_trim = save_pathway_trim;
 	  _pathway_orient = save_pathway_orient;

//   __printf ( "<<<<<<<<<< 2 ems$intersect_surfaces() i =  %d, j = %d", `i, j` );

          EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_Intersect, &Ele1[i], 
          &Ele2[j], &numfail, &failed, &failBufSize, TRUE); 
         }

       }

     if((intpt = (*EMmsg == EMS_I_Interrupt ? TRUE : FALSE))) break;

     /*
      * All we need is for num_inters to behave like a switch. 
      */

     if (!inters[0] || !inters[1])
       num_inters = FALSE;
     else
       num_inters = TRUE;


     /* The following return codes are possible if there is no intersection
	(based on the cutting option) or if they were non orientable. We
	ignore non orientable intersections, typically resulting out of 
	tangencies, for interference.
     */
     if( (*EMmsg == EMS_I_NotFound) || (*EMmsg == EMS_I_IntersectOrient))
       num_inters = 0;

     /* If volume elements are desired and there is some intersection between
	the two elements, perform boolean intersection. The two elements
        must be surfaces and not just GRowners.
     */
     if(!novol && num_inters && sf1 && sf2)
      {
       IGRushort booloptions = EMSsfbool_opt_HandleStop;
       IGRboolean coolscene = TRUE, validated = FALSE;


       if((intpt = IGEstop())) break; 	/* user interrupt */

       /* In case of any error after this point atleast output the
          curves, if asked for and the fact that there was interference
       */
       sts = om$construct(classid = sol1 && sol2 ? OPP_EMSslboolean_class_id
						 : OPP_EMSsfboolean_class_id, 
                         p_objid = &volelem.objid, osnum = openv->md_id.osnum);
       if(!(1&sts)) EMcleanup(&op1, &op2, &volelem, openv);
       EMlocerrinit(!(1&sts), volelem, op1, op2, coolscene);
       EMlocerrhndlr(!(1&sts), EMmsg, EMS_E_BoolFail, &Ele1[i], 
			&Ele2[j], &numfail, &failed, &failBufSize, FALSE); 

       if(!sameobj)
        {
         if(coolscene)
	  {
/****************************************************************************
	   sts = EMdupinters(EMmsg, &inters[0], NULL, FALSE, TRUE, 
		&Ele1[i].located_obj, &op1, TRUE, env1, const_list, NULL, NULL,
		0, NULL, NULL, 0);
****************************************************************************/

//   __printf ( ">>>>>>>>>> 3 ems$dupinters() i =  %d, j = %d", `i, j` );

           sts = ems$dupinters(msg = EMmsg,
                               origsf_inters = &inters[0],
                               copyintobjs = FALSE,
                               delorigintobjs = TRUE,
                               origsfid = &Ele1[i].located_obj,
                               copysfid = &op1,
                               origsfenv = env1,
                               construction_args = const_list);
	   if(!(1&*EMmsg&sts)) EMcleanup(&op1, &op2, &volelem, openv);
	   EMlocerrinit(!(1&sts&*EMmsg), volelem, op1, op2, coolscene);
	   EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_BoolFail, &Ele1[i], 
			&Ele2[j], &numfail, &failed, &failBufSize, FALSE); 

//   __printf ( "<<<<<<<<<< 3 ems$dupinters() i =  %d, j = %d", `i, j` );

	  }

         if((intpt = IGEstop())) break; 	/* user interrupt */

         if(coolscene)
	  {
/*****************************************************************************
	   sts = EMdupinters(EMmsg, &inters[1], NULL, FALSE, TRUE, 
		&Ele2[j].located_obj, &op2, TRUE, env2, const_list, NULL, NULL,
		0, NULL, NULL, 0);
*****************************************************************************/

//   __printf ( ">>>>>>>>>> 4 ems$dupinters() i =  %d, j = %d", `i, j` );

           sts = ems$dupinters(msg = EMmsg,
                               origsf_inters = &inters[1],
                               copyintobjs = FALSE,
                               delorigintobjs = TRUE, 
                               origsfid = &Ele2[j].located_obj,
                               copysfid = &op2,
                               origsfenv = env2,
                               construction_args = const_list);
	   if(!(1&*EMmsg&sts)) EMcleanup(&op1, &op2, &volelem, openv);
	   EMlocerrinit(!(1&sts&*EMmsg), volelem, op1, op2, coolscene);
	   EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_BoolFail, &Ele1[i], 
			&Ele2[j], &numfail, &failed, &failBufSize, FALSE); 

//   __printf ( "<<<<<<<<<< 4 ems$dupinters() i =  %d, j = %d", `i, j` );

	  }
        }

       if(coolscene)
       {
	 
//   __printf ( ">>>>>>>>>> EMboolean_surfaces_w_intersection() i =  %d, j = %d", `i, j` );

	 sts = EMboolean_surfaces_w_intersection(EMmsg, &volelem, 
		 EMSbool_intersect, openv, op1.objid, 1, &op2.objid, inters[0],
		 inters[1], &trace[0], &trace[1], NULL, NULL, 
		 booloptions, NULL, NULL, sts_array);
	 
//   __printf ( "<<<<<<<<<< EMboolean_surfaces_w_intersection() i =  %d, j = %d", `i, j` );
       }
       
       if((intpt = (*EMmsg == EMS_I_Interrupt ? TRUE : FALSE)))
        {
	 EMcleanup(&op1, &op2, &volelem, openv);
	 break;
        }

       if(!(1&*EMmsg&sts) || !coolscene)
        {
	 coolscene = FALSE;
	 EMcleanup(&op1, &op2, &volelem, openv);
         EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_BoolFail, &Ele1[i], 
			&Ele2[j], &numfail, &failed, &failBufSize, FALSE);
        }
	
       if(coolscene)
        {
	 
//   __printf ( ">>>>>>>>>> EMSdpr.EMmake_primitive1() i =  %d, j = %d", `i, j` );

	 sts = om$send(msg = message EMSdpr.EMmake_primitive1
		(EMmsg, openv, &volelem), 
		targetid = volelem.objid, targetos = volelem.osnum,
                senderid = NULL_OBJID);
	 if( (sts == OM_W_UNKNOWN_MSG) || (*EMmsg == EMS_E_InvalidSend))
	   {*EMmsg = EMS_S_Success; sts = OM_S_SUCCESS;}
		
         if(!(1&*EMmsg&sts))
	  {
	   coolscene = FALSE;
	   EMcleanup(&op1, &op2, &volelem, openv);	  
           EMlocerrhndlr(!(1&sts&*EMmsg), EMmsg, EMS_E_BoolFail, &Ele1[i], 
			&Ele2[j], &numfail, &failed, &failBufSize, FALSE); 
          }
	 
//   __printf ( "<<<<<<<<<< EMSdpr.EMmake_primitive1() i =  %d, j = %d", `i, j` );

        }

      }/* if(!(options & EMSintf_NoVolElems) && num_inters) */
	
     /* If there is no intersection check for the an element completely
        enclosing the other element.
        in such a case we do not output interference curves even if
	asked for. However we output the common volume (which will be the
	entire solid inside) if the volume elements are asked for.
     */
     else if(!num_inters && sol1 && sol2)
       EMinsideOutside(EMmsg, &Ele1[i], &Ele2[j], novol ? NULL : &volelem, 
		 const_list, &num_inters);

     if(!num_inters || novol || !sf1 || !sf2)
      EMcleanup(&op1, &op2, &volelem, openv);	  
	      
     EMinit(trace, inters, sfintloopsdata, loopdata, TRUE);
     if(num_inters)
      {
       struct EMSintf_qualitative *junk;
       IGRint	num;

       if(!RbufSize)
        {
         if(!(*result))
         {
//          *result = _MALLOC ( ResultBufInc, struct EMSintf );
          *result = (struct EMSintf *) om$malloc(size = ResultBufInc *
					sizeof(struct EMSintf));
	 }
	 else
         {
//          *result = _REALLOC ( *result, ResultBufInc + *num_result, struct EMSintf );
          *result = (struct EMSintf *) om$realloc(ptr = (IGRchar *)(*result), 
			size = (ResultBufInc + *num_result) *
					sizeof(struct EMSintf));
	 }
         EMlocerrhndlr(!(*result), EMmsg, EMS_E_NoDynamicMemory, &Ele1[i], 
			NULL, &numfail, &failed, &failBufSize, TRUE); 
         RbufSize = ResultBufInc;

         this_result = (struct EMSintf *) &(*result)[*num_result];
         this_result->numintf = 0;
	 this_result->intfInfoType = EMqualitative;
	 this_result->info.qualitative = NULL;
         against = (struct EMSintf_qualitative **) 
		    &this_result->info.qualitative;
        }
       
       num = this_result->numintf;
       if(!bufSize)
        {
         if(!(*against))
         {
//          *against = _MALLOC ( ResultBufInc, struct EMSintf_qualitative );
          *against = (struct EMSintf_qualitative *) 
		     om$malloc(size = ResultBufInc *
					sizeof(struct EMSintf_qualitative));
	 }
	 else
	 {
//          *against = _REALLOC ( *against, ResultBufInc + num, struct EMSintf_qualitative );
          *against = (struct EMSintf_qualitative *) om$realloc(
                        ptr  = (IGRchar *)(*against), 
			size = (ResultBufInc + num) *
					sizeof(struct EMSintf_qualitative));
	 }
         EMlocerrhndlr(!(*against), EMmsg, EMS_E_NoDynamicMemory, &Ele1[i], 
			NULL, &numfail, &failed, &failBufSize, TRUE); 
         bufSize = ResultBufInc;
        }

       junk = (struct EMSintf_qualitative *) 
	       &this_result->info.qualitative[num];

       this_result->eleminfo = Ele1[i];
       junk->against_eleminfo = Ele2[j];


       if(nocurves)
        junk->inters.objid = NULL_OBJID;
       else junk->inters = intersobj;

       if(novol)
        junk->volelem.objid = NULL_OBJID;
       else junk->volelem = volelem;
       
       if(options & EMSintf_Display)
        {
         if(!IF_NULL_OBJID(junk->inters.objid))
	   EMintfDisplay(const_list->env_info, &junk->inters, TRUE);
         if(!IF_NULL_OBJID(junk->volelem.objid))
	   EMintfDisplay(const_list->env_info, &junk->volelem, TRUE);	
        }

       (this_result->numintf)++;
       bufSize--;
       atleastone = TRUE;

      }/* if(num_inters) */
     num_inters = 0;

//   __printf ( "<<<<<<<<<< i =  %d, j = %d", `i, j` );

    }/* for(j=0; j<NumEle2; j++) */

   if(atleastone) 
    {
     (*num_result)++; 
     bufSize = 0;
     RbufSize--;
    }

//   __printf ( "<<<<< i =  %d", `i` );

  }/* for(i=0; i<NumEle1; i++) */

wrapup:
/*
 if(!nomsg) ex$message(msgnumb = EMS_I_ClearStatusField);
*/
 if (stackptr)
 {
//   __printf ( "<<<<< stackfree() : stackptr = %#x", `stackptr` );

   stackfree (stackptr);
 }
 if (siblings && siblings != sibling_store)
 {
//   _FREE ( siblings );
   om$dealloc (ptr = siblings);
 }

 if( (1&*EMmsg&sts) && !(options & EMSintf_NoReport))
  {
   IGRboolean repboth = FALSE, stdrep = FALSE;
   FILE *fileptr;

   repboth = options & EMSintf_ReportBoth;
   stdrep = repboth || !ReportFileName;
   if(ReportFileName)
    {
     fileptr = fopen(ReportFileName, "a");
     if(!fileptr) {*EMmsg = EMS_E_FileOpen; goto wrapup;}
     EMintf_report(numchecked,
      Ele1, NumEle1, setnum1, SetInfo1,
      Ele2, NumEle2, setnum2, SetInfo2,
      *result,  *num_result, options, fileptr);
     if(numfail)EMintf_failureReport(failed, numfail, fileptr);
     fclose(fileptr);
    }

   if(stdrep)
    {
     EMintf_report(numchecked,
      Ele1, NumEle1, setnum1, SetInfo1,
      Ele2, NumEle2, setnum2, SetInfo2,
      *result, *num_result, options, stdout);
     if(numfail)EMintf_failureReport(failed, numfail, stdout);
    }
  }

 if((*result) && (*result == locresult))
  EMintf_free(*result, *num_result);
// if(failed) _FREE ( failed );
 om$dealloc(ptr = failed);
 EMinit(trace, inters, sfintloopsdata, loopdata, TRUE);

// __exitFunction ( name = "EManalyzeIntf" );

 if(intpt) *EMmsg = EMS_I_Interrupt;
 EMWRAPUP(*EMmsg,sts,"In EMSsurface.EManalyzeIntf");
 return(sts);
}


static void EMcleanup(op1, op2, vol, env)
struct GRid *op1, *op2, *vol;
struct GRmd_env *env;
{
 IGRlong	locsts, rc;
	
 if(!IF_NULL_OBJID(op1->objid))
 locsts = om$send(msg = message GRgraphics.GRdelete (&rc, env), 
	senderid = NULL_OBJID, targetid = op1->objid, targetos = op1->osnum);
		
 if(!IF_NULL_OBJID(op2->objid))		
 locsts = om$send(msg = message GRgraphics.GRdelete (&rc, env), 
        senderid = NULL_OBJID,  targetid = op2->objid, targetos = op2->osnum);
		
 if(!IF_NULL_OBJID(vol->objid))				
 locsts = om$send(msg = message GRgraphics.GRdelete (&rc, env), 
	senderid = NULL_OBJID, targetid = vol->objid, targetos = vol->osnum);
		
 op1->objid = NULL_OBJID;
 op2->objid = NULL_OBJID;
 vol->objid = NULL_OBJID;
}



/* The following function assumes non intersecting operands.
*/
#include "EMSconstruct.h"   /* EMS_S_INSOLID etc. */

static void EMinsideOutside(EMmsg, ele1, ele2, volelem, const_list, num_inters)
IGRlong			*EMmsg;
struct GRlc_info	*ele1, *ele2;
struct GRid		*volelem;
struct GRvg_construct	*const_list;
IGRint			*num_inters;
{
 IGRlong		sts = OM_S_SUCCESS;
 extern EMSrc		EFsolidRelationship();
 /*extern IGRlong		EMdupinters();*/
 IGRulong	location;
 struct GRlc_info	*inelem = NULL;
 OMuword		cid;
 struct GRid		obj1, obj2;
 IGRboolean		sol1 = TRUE, sol2 = TRUE;

// __enterFunction ( name = "EMinsideOutside" );

 *EMmsg = EMS_S_Success;
 if(volelem) volelem->objid = NULL_OBJID;
 *num_inters = 0;
 obj1 = ele1->located_obj;
 obj2 = ele2->located_obj;

 sts = om$get_classid(objid = obj1.objid, osnum = obj1.osnum, 
		      p_classid = &cid);
		
 if( (cid != OPP_EMSsolid_class_id) &&
     ((sts = om$is_ancestry_valid(superclassid = OPP_EMSsolid_class_id, 
		subclassid = cid)) != OM_S_SUCCESS)) sol1 = FALSE;

 if(sol1)
  {
   sts = om$get_classid(objid = obj2.objid, osnum = obj2.osnum, 
		      p_classid = &cid);
		
   if( (cid != OPP_EMSsolid_class_id) &&
       ((sts = om$is_ancestry_valid(superclassid = OPP_EMSsolid_class_id, 
		subclassid = cid)) != OM_S_SUCCESS)) sol2 = FALSE;
  }

 if(sol1 && sol2)
  {
   /* Is ele2 inside ele1 ?
   */
   sts = EFsolidRelationship(EMmsg, obj1.objid, obj1.objid, obj2.objid, 
		obj1.osnum, obj2.osnum, &ele1->module_info, &ele2->module_info,
		NULL, &location);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if(location == EMS_S_INSOLID) inelem = ele2;
   else if(location == EMS_S_OUTSOLID)
    {
     /* Do a reverse check to find whether ele1 is inside ele2.
     */
     sts = EFsolidRelationship(EMmsg, obj2.objid, obj2.objid, obj1.objid, 
		obj2.osnum, obj1.osnum, &ele2->module_info, &ele1->module_info,
		NULL, &location);
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(location == EMS_S_INSOLID) inelem = ele1;  
    }

  } /* if(sol1 && sol2) */

 else *EMmsg = EMS_I_Useless;

 if(inelem)
  {
   *num_inters = 1;
   if(volelem)
/****************************************************************************
    sts = EMdupinters(EMmsg, NULL, NULL, FALSE, TRUE, &inelem->located_obj, 
		   volelem, TRUE, &inelem->module_info, const_list, NULL, NULL,
		   0, NULL, NULL, 0);
****************************************************************************/
    sts = ems$dupinters(msg = EMmsg,
                        copyintobjs = FALSE,
                        delorigintobjs = TRUE,
                        origsfid = &inelem->located_obj,
                        copysfid = volelem,
                        origsfenv = &inelem->module_info,
                        construction_args = const_list);    
  }

wrapup:
if(!(1&*EMmsg&sts) && volelem && !IF_NULL_OBJID(volelem->objid))
 {
  IGRlong rc;
  sts = om$send(msg = message GRgraphics.GRdelete(&rc, const_list->env_info), 
			targetid = volelem->objid, targetos = volelem->osnum, 
			 senderid = volelem->objid);
  volelem->objid = NULL_OBJID;
 }

// __exitFunction ( name = "EMinsideOutside" );

}


static void EMinit(trace, inters, sfintloopsdata, loopdata, dealloc)
struct EMSsftracedata *trace;
struct EMSinters **inters;
struct EMSsfintloopsdata *sfintloopsdata, **loopdata;
IGRboolean dealloc;
{
 IGRint		i, msg_loc;
/* extern void    EMinters_free(), EMinters_data_free();*/ 
  extern void  	EMsfintedpar_free();
	
// __enterFunction ( name = "EMinit", argfmt = "dealloc = %d", args = dealloc );
	
 if(dealloc)
  {
   for (i=0; i<2; i++)
    {
     if(inters[i])
      {
/*****************************************************************************
      EMinters_data_free (&msg_loc, inters[i], MAXINT, NULL,EMsfintedpar_free);
      EMinters_free (inters[i], MAXINT);
*****************************************************************************/
      ems$inters_data_free (
                      msg = (IGRlong *)&msg_loc,
                      inters_list = inters[i],
                         num_nodes = MAXINT,
                  userdfnd_func_to_free_intobj_moreinfo = EMsfintedpar_free);
      ems$inters_free (
                inters_list = inters[i],
                  num_nodes = MAXINT);    
      }
/**************************************************************************
     EMsfinttrace_free ((IGRlong *)&msg_loc, trace[i].num_grps,
      trace[i].num_subgrps_grp, trace[i].num_elems_subgrp,
      (IGRchar ***)trace[i].elems, trace[i].subgrp_rev, trace[i].elem_rev,
      trace[i].grp_closed, trace[i].subgrp_closed);
**************************************************************************/
     ems$sfinttrace_free (
               msg = (IGRlong *)&msg_loc,
             num_grps = trace[i].num_grps,
             num_subgrps_grp = trace[i].num_subgrps_grp,
             num_elems_subgrp = trace[i].num_elems_subgrp,
                        elems = (IGRchar ***)trace[i].elems,
                       subgrp_rev = trace[i].subgrp_rev,
                         elem_rev = trace[i].elem_rev,
                          grp_closed = trace[i].grp_closed,
                          subgrp_closed = trace[i].subgrp_closed);    
     if (sfintloopsdata[i].sfintloops_alloced)
       EMsfintloops_free (sfintloopsdata[i].loop_sf, 
			  sfintloopsdata[i].endedges, 
			  sfintloopsdata[i].intedpars,
       			  sfintloopsdata[i].sfpartolb);
     }
  }

  for (i=0; i<2; i++)
    {
    inters[i] = NULL;
    trace[i].num_grps = 0;
    trace[i].num_subgrps_grp = NULL;
    trace[i].num_elems_subgrp = NULL;
    trace[i].elems = NULL;
    trace[i].subgrp_rev = NULL;
    trace[i].elem_rev = NULL;
    trace[i].grp_closed = NULL;
    trace[i].subgrp_closed = NULL;

    sfintloopsdata[i].loop_sf = NULL;
    sfintloopsdata[i].endedges = NULL;
    sfintloopsdata[i].intedpars = NULL;
    sfintloopsdata[i].sfpartolb = NULL;
    sfintloopsdata[i].sfintloops_alloced = FALSE;
    sfintloopsdata[i].numedsplit = 0;     
    sfintloopsdata[i].commed_k_exists = TRUE;
    sfintloopsdata[i].nocommed_k_exists = FALSE;
    loopdata[i] = &sfintloopsdata[i];

    }

//  __exitFunction ( name = "EMinit" );
}
end implementation EMSsurface;
