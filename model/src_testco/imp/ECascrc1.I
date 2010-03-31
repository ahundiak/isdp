/*  ###################   APOGEE COMPILED   ################## */
class implementation ECascrcr;
/*
ABSTRACT



        This command object includes the following functionalities

        o  create an associative curve from a linestring
        o  curve parameter editing
           o  order
           o  spans
           o  poles
           o  smoothing factor
           o  iterative improvement
           o  knot vector
              o  uniform 
              o  half uniform
              o  not a knot
              o  from ref curve
              o  free (edit knot values)
              o  interactive (manipulate knots interactively)
           o  parameter vector
              o equidistant
              o centripedal
              o chordal
              o lyche
              o ref curve
              o free
              o project
        o  linestring editing
           o edit/move vertex
           o insert vertex
           o delete vertex
           o undo
           o add/delete fixpoint
           o add/delete tangency in vertex
           o add/delete factors (weight)
           o add/delete curvature in vertex
        o  curve analysis
           o show distance 
           o show curvature
           o show poles
           o show knots
History
           dfl    created  04/94 except analysis 
           uwa       "       "   analysis

 */

#ifndef OM_DEFINE_ERRMSG
#define OM_DEFINE_ERRMSG
#endif

#define dflT1 0
#include "string.h"
#include "memory.h"
#include "EMS.h"
#include "OMerrordef.h"
/* igemacros replacement */

# ifndef grdpbmacros_include
# include "grdpbmacros.h" /* gr$get_active_display */
# endif
/* end of igemacros.h replacement */

/* grutildef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grutildef.h replacement */

/* grvaluedef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grvaluedef.h replacement */
/*#include "grdef.h"*/
#include "igrdef.h"
#include "codef.h"
#include "msdef.h"

#include "griomacros.h" /* co$getevent */
#include "grmacros.h"
#include "grwireframe.h"
#include "comiscmac.h"
#include "bserr.h"
#include "bsicmpcvoff.h"
#include "math.h"
#include "comisc.h"
#include "nddef.h"
#include "ndmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "lcmacros.h"
#include "gotextdef.h"
#include "cotxmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpezmac.h"
#include "coplcmac.h"
#include "dpstruct.h"
#include "OMobjectcomm.h"
#include "exmacros.h"		/* ex$putqueue() */
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"
#include "EC_I.h"
#include "dpdef.h"
#include "dp.h"
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "EMSasmacros.h"
#include "nddef.h"
#include "exdef.h"
#include "ecascrcr.h"


/*vvvvv*/
#if defined ( NT )
#if 0 /* because opp cannot handle it */
#include <windows.h>
#endif
#endif

#ifdef X11
#include <X11/Xlib.h>
#unclude <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0 /* because opp cannot handle it */
#if defined ( X11 )
#include <XFIproto_pub.h>
#elif defined ( ENV5 )
#include <FIproto_pub.h>
#elif defined ( NT )
#include <shampub.h>
#endif
#else
#include <FI.h>
#endif
#else
#include <FI.h>
#endif
/*^^^^^*/
/* structure for dynamic point function */
    struct istruct {
       struct DPele_header point_element;   /* display buffer */
       struct IGRbsp_curve *curve;
       Form *mform;
       IGRdouble *pknot;
       IGRdouble *nknot;
       IGRdouble *knot;
    }; 


extern IGRboolean BSnorvec();
extern IGRboolean BScumdist();
extern IGRdouble 	BSdotp();
extern void BScveval();
extern IGRdouble      fabs(IGRdouble);
IGRint dist_process_form ();
IGRint cvra_process_form ();
IGRint spol_process_form ();
IGRint sknt_process_form ();
IGRint tool, wool;

extern OMuword 			OPP_EMScomposite_class_id;
extern OMuword 			OPP_GR3dlineseg_class_id;
extern OMuword 			OPP_GR3dlinestr_class_id;
extern OMuword 			OPP_GA3dlinestr_class_id;
extern OMuword 			OPP_GRbspline_class_id;
extern OMuword 			OPP_GRcurve_class_id;
extern OMuword 			OPP_EMSdatpln_class_id;
extern OMuword 			OPP_EMSplane_class_id;
extern OMuword 			OPP_EMSsurface_class_id;
extern OMuword 			OPP_EMSsubbs_class_id;
extern OMuword 			OPP_GRbcsubbc_class_id;
extern OMuword                  OPP_GRlinear_class_id;
extern OMuword                  OPP_GAbspline_class_id;


from GRgraphics import 	GRlnproject, GRdisplay, GRgetrang, GRdelete, 
                       	GRgetobjinfo, GRptproject;
from GRvg import 	GRgetattr, GRdetplane, GRgeomprops, GRgetgeom, 
                 	GRgetsize, GRconstruct, GRprojpt, EMptatpr;
from EMSsubbs import EMtoggle_polygon;
from GR3dlinestr import GRgetpolyline, GRputpolyline;
from GRlinear import    GRvtadjseg, GRdelvertex;
from GRcurve import 	EMcvoffset, GRgenabsg, GRmidpoint, GRinsvertex;
from EMSassoc import    EMget_info, EMput_info;
from NDnode   import    NDget_objects;
from ASnode   import    NDchange_connect;

/*      Programmname     : cvra_def.c
*       Letzte Aenderung : 24.  8. 1994
*	Curvature Radius
*/
#include "igrdef.h"
#include "igrtypedef.h"
#include "igr.h"
/* #include "curv_mod.h" */
cvra_def( struct cvra_frm *cvra )
{
 cvra->wlox = 50;   /* window lower x                                       */ 
 cvra->wloy = 50;   /* window lower y                                       */ 
 cvra->exsa  = 0;   /* Exit and Save Button                                 */ 
 cvra->runn  = 0;   /* Run  Button                                          */
 cvra->rest  = 0;   /* Reset   Button                                       */
 cvra->quit  = 0;   /* Quit Button                                          */
 cvra->cura = ON;   /* Toggle Curvature or Radius                           */
 cvra->nogr = ON;   /* Toggle Normals or Graph                              */ 
 cvra->fasl = ON;   /* Normals Display FAst SLow                            */ 
 cvra->mysy = ON;   /* Toggle My Symbology - Active Symbology               */ 
 cvra->cvin = ON;   /* Toggle anz Normals in Interval - along Curve         */
 cvra->par2 = ON;   /* case two Parameters to define the Interval           */
 cvra->defl = OF;   /* case define parameters later                         */
 cvra->par1 = OF;   /* case one Parameter to define the Interval            */
 cvra->scaf = OF;   /* case Scaling All Normals are scaled with fac         */
 cvra->maxl = ON;   /* case Longest Normal defines fac                      */
 cvra->anzn = 201;  /* Number of Normals or vertices of the Graph           */
 cvra->layr = 1015; /* Layer for the Output if my_sym is ON                 */ 
 cvra->colo = 4;    /* Color for the Output if my_sym is ON                 */ 
 cvra->weit = 0;    /* Weightfor the Output if my_sym is ON                 */ 
 cvra->styl = 0;    /* Style for the Output if my_sym is ON                 */ 
 cvra->ustr = 0.0;  /* Start- and    of the Intervall if it is defined      */ 
 cvra->uend = 1.0;  /* Endparameter  in the form   -   par2 is ON           */
 cvra->u_st = 0.25; /* Start- and    default values if the parmeters        */
 cvra->u_en = 0.75; /* Endparameter  if they are defined later - defl is ON */
 cvra->u_p1 = 0.5;  /* One parameter from the form   -   par1 is ON         */
 cvra->u_p2 = 0.75; /* One parameter defined later   -   par1 is ON         */
 cvra->fact = 1.0;  /* Scalingfactor, if scaf is ON                         */ 
 cvra->leth = 10.0; /* Length of the longest normal, if max_cas is ON       */ 
return (OM_S_SUCCESS);
}


/*      Programmname     : dist_def.c
*       Letzte Aenderung : 20. 04. 1994
*	Distance	
*/

dist_def( struct dist_frm *dist )
{
 dist->wlox = 60;  /* window lower x                                        */
 dist->wloy = 0;   /* window lower y                                        */
 dist->exsa = 0;   /* Exit and Save Button                                  */
 dist->runn = 0;   /* Run Button                                            */
 dist->rest = 0;   /* Reset   Button                                        */
 dist->quit = 0;   /* Quit Button                                           */
 dist->grap = OF;  /* Toggle Graph Yes - No                                 */
 dist->alln = ON;  /* Toggle all Normal Yes - No                            */
 dist->loca = ON;  /* Toggle local max Yes - No                             */
 dist->glob = ON;  /* Toggle global max Yes - No                            */
 dist->mysy = ON;  /* Toggle My Symbology - Active Symbology                */
 dist->outp = OF;  /* Toggle Output Yes - No                                */
 dist->wifi = ON;  /* Toggle Output window - file                           */
 dist->apnf = ON;  /* Toggle Append Output - Create new file                */
 dist->numb = ON;  /* Toggle Number of each point Yes - No                  */
 dist->lspo = ON;  /* Toggle Coordinates of the Linestring Vertices Yes - No*/
 dist->prpo = ON;  /* Toggle Coordinates of the Projected points Yes - No   */
 dist->dist = ON;  /* Toggle Distance between both points                   */
 dist->proj = ON;  /* case Project Endpoints                                */
 dist->conn = OF;  /* case Connect Endpoints                                */
 dist->mixe = OF;  /* case Mix between Project and Connect Endpoints        */
 dist->maxl = ON;  /* case Longest Normal defines fact                      */
 dist->scaf = OF;  /* case Scaling All Normals are scaled with fact         */
 dist->grla = 1011;/* Layer for Graph if my_sym is ON                       */
 dist->alla = 1012;/* Layer for the Output of all normals if my_sym is ON   */
 dist->lmla = 1012;/* Layer for local max Normals if my_sym is ON           */
 dist->gmla = 1012;/* Layer for global max Normal if my_sym is ON           */
 dist->grco = 4;   /* Color for Graph if my_sym is ON                       */
 dist->alco = 5;   /* Color for the Output of all normals if my_sym is ON   */
 dist->lmco = 6;   /* Color for local max Normals if my_sym is ON           */
 dist->gmco = 15;  /* Color for global max Normal if my_sym is ON           */
 dist->grwt = 0;   /* Weightfor Graph if my_sym is ON                       */
 dist->alwt = 0;   /* Weightfor the Output of all normals if my_sym is ON   */
 dist->lmwt = 2;   /* Weightfor local max Normals if my_sym is ON           */
 dist->gmwt = 4;   /* Weightfor global max Normal if my_sym is ON           */
 dist->grst = 0;   /* Style for Graph if my_sym is ON                       */
 dist->alst = 0;   /* Style for local max Normals if my_sym is ON           */
 dist->lmst = 0;   /* Style for the Output of all normals if my_sym is ON   */
 dist->gmst = 0;   /* Style for global max Normal if my_sym is ON           */
 dist->inpt = 0;   /* Button to put text into file                          */
 dist->fact = 100; /* Scalingfactor, if sca is ON                           */
 dist->leth = 1;  /* Length of the longest normal, if max is ON            */
 strcpy(dist->flna,"dist.out"); /* default file name                        */
 strcpy(dist->text,"*********  distance  *********"); /* default output     */
return (OM_S_SUCCESS);
}


/*      Programmname     : spol_def.c
*       Letzte Aenderung : 22.  4. 1994
*	Show poles
*/

spol_def( struct spol_frm *spol )
{
 spol->wlox = 80;  /* window lower x                             */
 spol->wloy = 0;   /* window lower y                             */
 spol->exsa = 0;   /* Exit and Save Button                       */
 spol->runn = 0;   /* Run   Button                               */
 spol->rest = 0;   /* Reset   Button                             */
 spol->quit = 0;   /* Quit Button                                */
 spol->topo = ON;  /* Toggle Polygon ON - OFF                    */
 spol->mysy = ON;  /* Toggle My Symbology - Active Symbology     */
 spol->lstr = ON;  /* Toggle Linestring Polygon                  */
 spol->pnts = ON;  /* Toggle Points in the Poles                 */
 spol->lsla = 1020;/* Layer for Linestring                       */
 spol->lsco = 16;  /* Color for Linestring                       */
 spol->lswt = 0;   /* Weightfor Linestring                       */
 spol->lsst = 3;   /* Style for Linestring                       */
 spol->ptla = 1021;/* Layer for the Points in the Poles          */
 spol->ptco = 24;  /* Color for the Points in the Poles          */
 spol->ptwt = 5;   /* Weightfor the Points in the Poles          */
return (OM_S_SUCCESS);
}
/*      Programmname     : sknt_def.c
*       Letzte Aenderung : 20.  4. 1994
*	Show Knots
*/

sknt_def( struct sknt_frm *sknt )
{
 sknt->wlox = 60;   /* window lower x                              */
 sknt->wloy =  0;   /* window lower y                              */
 sknt->exsa =  0;   /* Exit and Save Button                        */
 sknt->runn =  0;   /* Run Button                                  */
 sknt->rest =  0;   /* Reset   Button                              */
 sknt->quit =  0;   /* Quit Button                                 */
 sknt->lstr = OF;   /* Toggle Linestring connecting knots          */
 sknt->pnts = ON;   /* Toggle Points in single knots               */
 sknt->pntm = ON;   /* Toggle Points in multiple knots             */
 sknt->mysy = ON;   /* Toggle My Symbology - Active Symbology      */
 sknt->lsla = 1018; /* Layer for Linestring                        */
 sknt->lsco = 10;   /* Color for Linestring                        */
 sknt->lswt = 0;    /* Weightfor Linestring                        */
 sknt->lsst = 6;    /* Style for Linestring                        */
 sknt->ptsl = 1019; /* Layer for the Points in the single Knots    */
 sknt->ptsc = 11;   /* Color for the Points in the single Knots    */
 sknt->ptsw = 5;    /* Weight for the Points in the single Knots   */
 sknt->ptml = 1019; /* Layer for the Points in the multiple Knots  */
 sknt->ptmc = 12;   /* Color for the Points in the multiple Knots  */
 sknt->ptmw = 8;    /* Weight for the Points in the multiple Knots */
return (OM_S_SUCCESS);
}

IGRint cvra_process_form ( form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label; 
IGRdouble value;   
Form   form_ptr; 
{
 IGRint     stat_func, stat_OM;
 IGRlong    msg_loc;
 GRobjid    cmdobj;
 GRspacenum cmdos;
 #if dflT1
  printf("\nStart : cvra_process_form"); 
 #endif
 stat_OM = OM_S_SUCCESS;
 stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
 if (stat_func)
  return (OM_E_ABORT);
 stat_OM = om$send (msg = message ECascrcr.cvra_do_form 
                          (&msg_loc, form_label, gadget_label, value),
               senderid = NULL_OBJID, 
               targetid = cmdobj, 
               targetos = cmdos);
 #if dflT1
  printf("\nEnde  : cvra_process_form");
 #endif
 if(! (stat_OM & 1))
  return (OM_E_ABORT); 
 return (stat_OM); 
}
IGRint dist_process_form ( form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;     
Form   form_ptr;
{
 IGRint     stat_func, stat_OM;
 IGRlong    msg_loc;
 GRobjid    cmdobj;
 GRspacenum cmdos;
 #if dflT1
  printf("\nStart : dist_process_form");
 #endif
 stat_OM   = OM_S_SUCCESS;
 stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
 if (stat_func)
  return (OM_E_ABORT);
 stat_OM = om$send (msg = message ECascrcr.dist_do_form
                          (&msg_loc, form_label, gadget_label, value),
               senderid = NULL_OBJID,
               targetid = cmdobj,
               targetos = cmdos);
 #if dflT1
  printf("\nEnde  : dist_process_form");
 #endif
 if( !(stat_OM & 1) )
  return (OM_E_ABORT); 
 return (stat_OM);
}
IGRint spol_process_form ( form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
Form form_ptr;
{
 IGRint     stat_func, stat_OM;
 IGRlong    msg_loc;
 GRobjid    cmdobj;
 GRspacenum cmdos;
 #if dflT1
  printf("\nStart : spol_process_form");
 #endif
 stat_OM = OM_S_SUCCESS;
 stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
 if (stat_func)
  return (OM_E_ABORT);
 stat_OM = om$send (msg = message ECascrcr.spol_do_form
                          (&msg_loc, form_label, gadget_label, value),
               senderid = NULL_OBJID,
               targetid = cmdobj,
               targetos = cmdos);
 #if dflT1
  printf("\nEnde  : spol_process_form");
 #endif
 if( !(stat_OM & 1) )
  return (OM_E_ABORT);
 return (stat_OM);
}
IGRint sknt_process_form ( form_label, gadget_label, value, form_ptr)
IGRint form_label, gadget_label;
IGRdouble value;
Form form_ptr;
{
 IGRint     stat_func, stat_OM;
 IGRlong    msg_loc;
 GRobjid    cmdobj;
 GRspacenum cmdos;
 #if dflT1
  printf("\nStart : sknt_process_form");
 #endif
 stat_OM = OM_S_SUCCESS;
 stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
 if (stat_func)
  return (OM_E_ABORT);
 stat_OM = om$send (msg = message ECascrcr.sknt_do_form
                          (&msg_loc, form_label, gadget_label, value),
               senderid = NULL_OBJID,
               targetid = cmdobj,
               targetos = cmdos);
 #if dflT1
  printf("\nEnde  : sknt_process_form");
 #endif
 if( !(stat_OM & 1) )
  return (OM_E_ABORT); return (stat_OM);
}

method erase_analysis_tools ( IGRlong *msg )
{
 /* 
    ABSTRACT  erase analysis objects 
 */

 IGRlong msg1;
 struct GRsymbology symb;

#if dflT1
  fprintf(stderr,"\nStart : method erase_tools");
#endif
 if ( me->cvra_gr_on )
 {
  gr$get_symbology ( object_id = &me->cvra_gr,
                     symb      = &symb      ); 
  /*symb.level               = 1023;*/
  symb.display_attr.color  = 0;
  symb.display_attr.weight = 31;
  symb.display_attr.style  = 0;
  gr$put_symbology ( object_id = &me->cvra_gr,
                     symb      = &symb      );
  gr$display_object ( object_id = &me->cvra_gr,
                      md_env    = NULL        ,
                      mode      = GRbd       );
  gr$delete_object ( msg = &msg1       ,
            md_env       = NULL        ,
            object_id    = &me->cvra_gr,
            display_flag = 1          );
  me->cvra_gr_on = FALSE;
 }
 if ( me->dist_ls_on )
 {
  gr$get_symbology ( object_id = &me->dist_ls,
                     symb      = &symb      );
  /*symb.level               = 1023;*/
  symb.display_attr.color  = 0;
  /*symb.display_attr.weight = 31;*/
  symb.display_attr.style  = 0;
  gr$put_symbology ( object_id = &me->dist_ls,
                     symb      = &symb      );
  gr$display_object ( object_id = &me->dist_ls,
                      md_env    = NULL        ,
                      mode      = GRbd       );
  gr$delete_object ( msg = &msg1       ,
            md_env       = NULL        ,
            object_id    = &me->dist_ls,
            display_flag = 1          );
  me->dist_ls_on = FALSE;
 }
 if ( me->dist_gr_on )
 {
  gr$get_symbology ( object_id = &me->dist_gr,
                     symb      = &symb      );
  /*symb.level               = 1023;*/
  symb.display_attr.color  = 0;
  symb.display_attr.weight = 31;
  symb.display_attr.style  = 0;
  gr$put_symbology ( object_id = &me->dist_gr,
                     symb      = &symb      );
  gr$display_object ( object_id = &me->dist_ls,
                      md_env    = NULL        ,
                      mode      = GRbd       );
  gr$delete_object ( msg = &msg1   ,
            md_env       = NULL    ,
            object_id    = &me->dist_gr,
            display_flag = 1          );
  me->dist_gr_on = FALSE;
 } 
 if ( me->spol_ls_on )
 {
  gr$get_symbology ( object_id = &me->spol_ls,
                     symb      = &symb      );
  /*symb.level               = 1023;*/ 
  symb.display_attr.color  = 0;
  symb.display_attr.weight = 31;
  /*symb.display_attr.style  = 0;*/
  gr$put_symbology ( object_id = &me->spol_ls,
                     symb      = &symb      );
  gr$display_object ( object_id = &me->spol_ls,
                      md_env    = NULL    ,
                      mode      = GRbd   );
  gr$delete_object ( msg = &msg1   ,
            md_env       = NULL    ,
            object_id    = &me->spol_ls,
            display_flag = 1      );
  me->spol_ls_on = FALSE;
 }
 if ( me->spol_gr_on )
 {
  gr$delete_object ( msg = &msg1       ,
            md_env       = NULL        ,
            object_id    = &me->spol_gr,
            display_flag = 1          );
  me->spol_gr_on = FALSE;
 }
 if ( me->sknt_ls_on )
 {
  gr$get_symbology ( object_id = &me->sknt_ls,
                     symb      = &symb      );
  /*symb.level               = 1023;*/
  symb.display_attr.color  = 0;
  /*symb.display_attr.weight = 31;*/
  symb.display_attr.style  = 0;
  gr$put_symbology ( object_id = &me->sknt_ls,
                     symb      = &symb      );
  gr$display_object ( object_id = &me->sknt_ls,
                      md_env    = NULL        ,
                      mode      = GRbd       );
  gr$delete_object ( msg = &msg1       ,
            md_env       = NULL        ,
            object_id    = &me->sknt_ls,
            display_flag = 1          );
  me->sknt_ls_on = FALSE;
 }
 if ( me->sknt_gr_on )
 {
  gr$delete_object ( msg = &msg1       ,
            md_env       = NULL        ,
            object_id    = &me->sknt_gr,
            display_flag = 1          );
  me->sknt_gr_on = FALSE;
 }

#if dflT1
  fprintf(stderr,"\nEnde  : erase_tools");
#endif

 *msg = OM_S_SUCCESS;

 return (OM_S_SUCCESS);
}

method set_defaults ( IGRlong *msg )
{
 /* REMARKS   set default values for analysis parameters
 */
 #if dflT1
  fprintf(stderr,"\nStart : method set_defaults");
 #endif
 #if dflT1
  fprintf(stderr,"\nStart : method set_defaults");
 #endif
 me->cvra_gr_on = FALSE;
 me->dist_ls_on = FALSE;
 me->dist_gr_on = FALSE;
 me->spol_ls_on = FALSE;
 me->spol_gr_on = FALSE;
 me->sknt_ls_on = FALSE;
 me->sknt_gr_on = FALSE;
 cvra_def(&me->cv.cvra_fm);
 dist_def(&me->cv.dist_fm);
 spol_def(&me->cv.spol_fm);
 sknt_def(&me->cv.sknt_fm);
 *msg     = OM_S_SUCCESS;
 #if dflT1
  fprintf(stderr,"\nEnde  : method set_defaults"); 
 #endif
 return OM_S_SUCCESS;
}

method cvra_disp()
{
 IGRlong ret, status, EMmsg;
 IGRint  cvra_disp();
 #if dflT1
  fprintf(stderr,"\nStart : cvra_disp"); 
 #endif
 status = OM_S_SUCCESS;
 EMmsg = 1;
 if(me->cvraform_requested)
   return(status);
 ret = FIf_new (CVRAFORM,"EMAsCrvCr40",cvra_process_form,&me->cvraform); 
 if ( ret )
 {
  status = FALSE;
  goto wrapup;
 }
 ret = FIf_set_cmd_oid_os(me->cvraform,my_id,OM_Gw_current_OS); 
 if ( ret ) 
 {
  status = FALSE;
  goto wrapup;
 }


  ret = FIf_set_location (me->cvraform, cvra_WLOX, cvra_WLOY);
  if ( ret ) 
  {
   status = FALSE;
   goto wrapup;
  }
  FIg_set_state(me->cvraform,CVRA_CURA_T,me->cv.cvra_fm.cura);
  FIg_set_state(me->cvraform,CVRA_NOGR_T,me->cv.cvra_fm.nogr);
  FIg_set_state(me->cvraform,CVRA_FASL_T,me->cv.cvra_fm.fasl);
  FIg_set_state(me->cvraform,CVRA_DEFL_B,me->cv.cvra_fm.defl);
  FIg_set_state(me->cvraform,CVRA_PAR1_B,me->cv.cvra_fm.par1);
  FIg_set_value(me->cvraform,CVRA_USTR_F,me->cv.cvra_fm.ustr);
  FIg_set_value(me->cvraform,CVRA_UEND_F,me->cv.cvra_fm.uend);
  FIg_set_value(me->cvraform,CVRA_U_P1_F,me->cv.cvra_fm.u_p1);
  FIg_set_state(me->cvraform,CVRA_MAXL_B,me->cv.cvra_fm.maxl);
  FIg_set_state(me->cvraform,CVRA_SCAF_B,me->cv.cvra_fm.scaf);
  FIg_set_value(me->cvraform,CVRA_LETH_F,me->cv.cvra_fm.leth);
  FIg_set_value(me->cvraform,CVRA_FACT_F,me->cv.cvra_fm.fact);
  FIg_set_state(me->cvraform,CVRA_MYSY_T,me->cv.cvra_fm.mysy);
  FIg_set_value(me->cvraform,CVRA_LAYR_F,(double)(me->cv.cvra_fm.layr));
  FIg_set_value(me->cvraform,CVRA_COLO_F,(double)(me->cv.cvra_fm.colo));
  FIg_set_value(me->cvraform,CVRA_WEIT_F,(double)(me->cv.cvra_fm.weit));
  FIg_set_value(me->cvraform,CVRA_STYL_F,(double)(me->cv.cvra_fm.styl));
  FIg_set_state(me->cvraform,CVRA_CVIN_T,me->cv.cvra_fm.cvin);
  FIg_set_value(me->cvraform,CVRA_ANZN_F,(double)(me->cv.cvra_fm.anzn));
  ret = FIf_display ( me->cvraform );
  if ( ret ) 
  {
   status = FALSE;
   goto wrapup;
  }
  me->cvraform_requested = TRUE;

 wrapup:
 if ( !(1&status&EMmsg) )
   return (OM_E_ABORT);
 #if dflT1
  fprintf(stderr,"\nEnde  : cvra_disp"); 
 #endif
 return (status); 
}


method dist_disp()
{
 IGRlong status, EMmsg;
 IGRint  ret, dist_disp();
 #if dflT1
  fprintf(stderr,"\nStart : method dist_disp");
 #endif
 status = OM_S_SUCCESS;
 EMmsg  = 1;
 if(me->distform_requested)
  return(status);
 ret = FIf_new (DISTFORM,"EMAsCrvCr50",dist_process_form,&me->distform);
 if ( ret )
 {
  status = FALSE;
  goto wrapup;
 }
 ret = FIf_set_cmd_oid_os(me->distform,my_id,OM_Gw_current_OS);
 if ( ret )
 {
  status = FALSE;
  goto wrapup;
 }

  ret = FIf_set_location (me->distform,dist_WLOX, dist_WLOY);
  if ( ret )
  {
   status = FALSE;
   goto wrapup;
  }
  FIg_set_state(me->distform,DIST_PROJ_B,me->cv.dist_fm.proj);
  FIg_set_state(me->distform,DIST_CONN_B,me->cv.dist_fm.conn);
  FIg_set_state(me->distform,DIST_MIXE_B,me->cv.dist_fm.mixe);
  FIg_set_state(me->distform,DIST_MAXL_B,me->cv.dist_fm.maxl);
  FIg_set_state(me->distform,DIST_SCAF_B,me->cv.dist_fm.scaf);
  FIg_set_value(me->distform,DIST_LETH_F,me->cv.dist_fm.leth);
  FIg_set_value(me->distform,DIST_FACT_F,me->cv.dist_fm.fact);
  FIg_set_state(me->distform,DIST_GRAP_T,me->cv.dist_fm.grap);
  FIg_set_state(me->distform,DIST_ALLN_T,me->cv.dist_fm.alln);
  FIg_set_state(me->distform,DIST_LOCA_T,me->cv.dist_fm.loca);
  FIg_set_state(me->distform,DIST_GLOB_T,me->cv.dist_fm.glob);
  FIg_set_value(me->distform,DIST_GRLA_F,(double)(me->cv.dist_fm.grla));
  FIg_set_value(me->distform,DIST_ALLA_F,(double)(me->cv.dist_fm.alla));
  FIg_set_value(me->distform,DIST_LMLA_F,(double)(me->cv.dist_fm.lmla));
  FIg_set_value(me->distform,DIST_GMLA_F,(double)(me->cv.dist_fm.gmla));
  FIg_set_value(me->distform,DIST_GRCO_F,(double)(me->cv.dist_fm.grco));
  FIg_set_value(me->distform,DIST_ALCO_F,(double)(me->cv.dist_fm.alco));
  FIg_set_value(me->distform,DIST_LMCO_F,(double)(me->cv.dist_fm.lmco));
  FIg_set_value(me->distform,DIST_GMCO_F,(double)(me->cv.dist_fm.gmco));
  FIg_set_value(me->distform,DIST_GRWT_F,(double)(me->cv.dist_fm.grwt));
  FIg_set_value(me->distform,DIST_ALWT_F,(double)(me->cv.dist_fm.alwt));
  FIg_set_value(me->distform,DIST_LMWT_F,(double)(me->cv.dist_fm.lmwt));
  FIg_set_value(me->distform,DIST_GMWT_F,(double)(me->cv.dist_fm.gmwt));
  FIg_set_value(me->distform,DIST_GRST_F,(double)(me->cv.dist_fm.grst));
  FIg_set_value(me->distform,DIST_ALST_F,(double)(me->cv.dist_fm.alst));
  FIg_set_value(me->distform,DIST_LMST_F,(double)(me->cv.dist_fm.lmst));
  FIg_set_value(me->distform,DIST_GMST_F,(double)(me->cv.dist_fm.gmst));
  FIg_set_state(me->distform,DIST_OUTP_T,me->cv.dist_fm.outp);
  FIg_set_state(me->distform,DIST_WIFI_T,me->cv.dist_fm.wifi);
  FIg_set_state(me->distform,DIST_APNF_T,me->cv.dist_fm.apnf);
  FIg_set_state(me->distform,DIST_NUMB_T,me->cv.dist_fm.numb);
  FIg_set_state(me->distform,DIST_LSPO_T,me->cv.dist_fm.lspo);
  FIg_set_state(me->distform,DIST_PRPO_T,me->cv.dist_fm.prpo);
  FIg_set_state(me->distform,DIST_DIST_T,me->cv.dist_fm.dist);
  FIg_set_state(me->distform,DIST_INPT_B,me->cv.dist_fm.inpt);  
  ret = FIf_display(me->distform);
  if ( ret )
  {
   status = FALSE;
   goto wrapup;
  }
  me->distform_requested = TRUE;

 wrapup:
 if ( !(1&status&EMmsg) )
   return (OM_E_ABORT);
 #if dflT1
  fprintf(stderr,"\nEnde  : method dist_disp");
 #endif
 return ( status );
}


method spol_disp()
{
 IGRlong status, EMmsg;
 IGRint  ret, spol_disp();
 #if dflT1
  fprintf(stderr,"\nStart : method spol_disp");
 #endif
 status = OM_S_SUCCESS;
 EMmsg = 1;
 if(me->spolform_requested)
  return(status);
 ret = FIf_new (SPOLFORM,"EMAsCrvCr70",spol_process_form,&me->spolform);
 if ( ret )
 {
  status = FALSE;
  goto wrapup;
 }
 ret = FIf_set_cmd_oid_os(me->spolform,my_id,OM_Gw_current_OS);
 if ( ret )
 {
  status = FALSE;
  goto wrapup;
 }

  ret = FIf_set_location (me->spolform, spol_WLOX, spol_WLOY);
  if ( ret )
  {
   status = FALSE;
   goto wrapup;
  }
  FIg_set_state(me->spolform,SPOL_TOPO_T,me->cv.spol_fm.topo);
  FIg_set_state(me->spolform,SPOL_LSTR_T,me->cv.spol_fm.lstr);
  FIg_set_state(me->spolform,SPOL_PNTS_T,me->cv.spol_fm.pnts);
  FIg_set_state(me->spolform,SPOL_MYSY_T,me->cv.spol_fm.mysy);
  FIg_set_value(me->spolform,SPOL_LSLA_F,(double)(me->cv.spol_fm.lsla));
  FIg_set_value(me->spolform,SPOL_PTLA_F,(double)(me->cv.spol_fm.ptla));
  FIg_set_value(me->spolform,SPOL_LSCO_F,(double)(me->cv.spol_fm.lsco));
  FIg_set_value(me->spolform,SPOL_PTCO_F,(double)(me->cv.spol_fm.ptco));
  FIg_set_value(me->spolform,SPOL_LSWT_F,(double)(me->cv.spol_fm.lswt));
  FIg_set_value(me->spolform,SPOL_PTWT_F,(double)(me->cv.spol_fm.ptwt));
  FIg_set_value(me->spolform,SPOL_LSST_F,(double)(me->cv.spol_fm.lsst));
  ret = FIf_display(me->spolform);
  if ( ret )
  {
   status = FALSE;
   goto wrapup;
  }
  me->spolform_requested = TRUE;

 wrapup:
 if ( !(1&status&EMmsg) )
   return (OM_E_ABORT);
 #if dflT1
  fprintf(stderr,"\nEnde  : method spol_disp");
 #endif
 return ( status );
}


method sknt_disp()
{
 IGRlong status, EMmsg;
 IGRint  ret, spol_disp();
 #if dflT1
  fprintf(stderr,"\nStart : method sknt_disp");
 #endif
 status = OM_S_SUCCESS;
 EMmsg  = 1;
 if(me->skntform_requested)
   return(status);
 ret = FIf_new (SKNTFORM,"EMAsCrvCr60",sknt_process_form,&me->skntform);
 if ( ret )
 {
  status = FALSE;
  goto wrapup;
 }
 ret = FIf_set_cmd_oid_os(me->skntform,my_id,OM_Gw_current_OS);
 if ( ret )
 {
  status = FALSE;
  goto wrapup;
 }

  ret = FIf_set_location (me->skntform, sknt_WLOX, sknt_WLOY);
  if ( ret )
  {
   status = FALSE;
   goto wrapup;
  }
  FIg_set_state(me->skntform,SKNT_LSTR_T,me->cv.sknt_fm.lstr);
  FIg_set_state(me->skntform,SKNT_PNTS_T,me->cv.sknt_fm.pnts);
  FIg_set_state(me->skntform,SKNT_PNTM_T,me->cv.sknt_fm.pntm);
  FIg_set_state(me->skntform,SKNT_MYSY_T,me->cv.sknt_fm.mysy);
  FIg_set_value(me->skntform,SKNT_LSLA_F,(double)(me->cv.sknt_fm.lsla));
  FIg_set_value(me->skntform,SKNT_PTSL_F,(double)(me->cv.sknt_fm.ptsl));
  FIg_set_value(me->skntform,SKNT_PTML_F,(double)(me->cv.sknt_fm.ptml));
  FIg_set_value(me->skntform,SKNT_LSCO_F,(double)(me->cv.sknt_fm.lsco));
  FIg_set_value(me->skntform,SKNT_PTSC_F,(double)(me->cv.sknt_fm.ptsc));
  FIg_set_value(me->skntform,SKNT_PTMC_F,(double)(me->cv.sknt_fm.ptmc));
  FIg_set_value(me->skntform,SKNT_LSWT_F,(double)(me->cv.sknt_fm.lswt));
  FIg_set_value(me->skntform,SKNT_PTSW_F,(double)(me->cv.sknt_fm.ptsw));
  FIg_set_value(me->skntform,SKNT_PTMW_F,(double)(me->cv.sknt_fm.ptmw));
  FIg_set_value(me->skntform,SKNT_LSST_F,(double)(me->cv.sknt_fm.lsst));
  ret = FIf_display(me->skntform);
  if ( ret )
  {
   status = FALSE;
   goto wrapup;
  }
  me->skntform_requested = TRUE;

 wrapup:
 if ( !(1&status&EMmsg) )
   return (OM_E_ABORT);
 #if dflT1
  fprintf(stderr,"\nEnde  : method sknt_disp");
 #endif
 return ( status );
}

method cvra_do_form  (IGRlong   *msg;
                      IGRint    form_label  ;
                      IGRint    gadget_label; 
                      IGRdouble value       )
{
 IGRlong sts, msg_loc, stat_OM;
 IGRint  ret;
 IGRdouble zz;
 #if dflT1
  fprintf(stderr,"\nStart : cvra_do_form");
 #endif
 sts = OM_S_SUCCESS;
 if ( form_label==CVRAFORM )
 {
  switch ( gadget_label )
  {
   case CVRA_EXSA_B:
    #if dflT1
     fprintf(stderr,"\ncase CVRA_EXSA_B");
    #endif
    /*me->form_requested = 0;*/
    me->error_flag = FALSE;
    me->cvraform_requested = FALSE;
    ret = FIf_erase(me->cvraform);
   break;

   case CVRA_QUIT_B:
    #if dflT1
     fprintf(stderr,"\ncase CVRA_QUIT_B");
    #endif

    FIg_get_value(me->cvraform,CVRA_ANZN_F,&zz);
    me->cv.cvra_fm.anzn = (int)(zz);

    FIg_get_value(me->cvraform,CVRA_LAYR_F,&zz);
    me->cv.cvra_fm.layr = (int)(zz);

    FIg_get_value(me->cvraform,CVRA_COLO_F,&zz);
    me->cv.cvra_fm.colo = (int)(zz);  

    FIg_get_value(me->cvraform,CVRA_WEIT_F,&zz);
    me->cv.cvra_fm.weit = (int)(zz);

    FIg_get_value(me->cvraform,CVRA_STYL_F,&zz);
    me->cv.cvra_fm.styl = (int)(zz);

    FIg_get_value(me->cvraform,CVRA_USTR_F,&me->cv.cvra_fm.ustr);

    FIg_get_value(me->cvraform,CVRA_UEND_F,&me->cv.cvra_fm.uend);

    FIg_get_value(me->cvraform,CVRA_U_P1_F,&me->cv.cvra_fm.u_p1);

    FIg_get_value(me->cvraform,CVRA_FACT_F,&me->cv.cvra_fm.fact);

    FIg_get_value(me->cvraform,CVRA_LETH_F,&me->cv.cvra_fm.leth);

    FIg_get_state(me->cvraform,CVRA_CURA_T,&me->cv.cvra_fm.cura);

    FIg_get_state(me->cvraform,CVRA_NOGR_T,&me->cv.cvra_fm.nogr);

    FIg_get_state(me->cvraform,CVRA_FASL_T,&me->cv.cvra_fm.fasl);

    FIg_get_state(me->cvraform,CVRA_MYSY_T,&me->cv.cvra_fm.mysy);

    FIg_get_state(me->cvraform,CVRA_CVIN_T,&me->cv.cvra_fm.cvin);

    FIg_get_state(me->cvraform,CVRA_MAXL_B,&me->cv.cvra_fm.maxl);

    FIg_get_state(me->cvraform,CVRA_SCAF_B,&me->cv.cvra_fm.scaf);

    me->error_flag = FALSE;
    me->cvraform_requested = FALSE;
    ret = FIf_erase(me->cvraform);
    break;

   case CVRA_SCAF_B:
    FIg_set_state(me->cvraform,CVRA_MAXL_B,OF);
    me->cv.cvra_fm.maxl = 0;
    break;

   case CVRA_MAXL_B: 
    FIg_set_state(me->cvraform,CVRA_SCAF_B,OF);
    me->cv.cvra_fm.scaf = 0;
    break;

   case CVRA_REST_B:
    #if dflT1
     fprintf(stderr,"\ncase REST_B von cvra_do_form");
    #endif
    cvra_def(&me->cv.cvra_fm);

    /*stat_OM = om$send (msg = message ECascrcr.set_defaults(&msg_loc),
                  targetid = my_id);*/
    /*me->form_requested = 0;*/
    me->error_flag = FALSE;
    me->cvraform_requested = FALSE;
    ret = FIf_erase(me->cvraform);
   break;

   default:
    /*ret = FIf_erase(me->cvraform);*/
   break;
  }
 }
 #if dflT1
  fprintf(stderr,"\nEnde  : cvra_do_form");
 #endif
 return ( OM_S_SUCCESS ); 


}

method dist_do_form  (IGRlong   *msg;
                      IGRint    form_label  ;
                      IGRint    gadget_label;
                      IGRdouble value       )
{
 IGRlong ret, sts, msg_loc, stat_OM;
 IGRdouble zz;
 FILE *fp;
 #if dflT1
  fprintf(stderr,"\nStart : method dist_do_form");
 #endif
 sts = OM_S_SUCCESS;
 if ( form_label==DISTFORM )
 {
  switch ( gadget_label )
  {
   case DIST_EXSA_B:
    #if dflT1
     fprintf(stderr,"\ncase DIST_EXSA_B");
    #endif
    /*me->form_requested = 0;*/
    me->error_flag = FALSE;
    me->distform_requested = FALSE;
    ret = FIf_erase(me->distform);
   break;

   case DIST_QUIT_B:
    #if dflT1
     fprintf(stderr,"\ncase DIST_QUIT_B");
    #endif
    FIg_get_state(me->distform,DIST_PROJ_B,&me->cv.dist_fm.proj);
    FIg_get_state(me->distform,DIST_CONN_B,&me->cv.dist_fm.conn);
    FIg_get_state(me->distform,DIST_MIXE_B,&me->cv.dist_fm.mixe);
    FIg_get_state(me->distform,DIST_MAXL_B,&me->cv.dist_fm.maxl);
    FIg_get_state(me->distform,DIST_SCAF_B,&me->cv.dist_fm.scaf);
    FIg_get_value(me->distform,DIST_LETH_F,&me->cv.dist_fm.leth);
    FIg_get_value(me->distform,DIST_FACT_F,&me->cv.dist_fm.fact);
    FIg_get_value(me->distform,DIST_GRLA_F,&zz);
    me->cv.dist_fm.grla = (int)(zz);
    FIg_get_value(me->distform,DIST_ALLA_F,&zz);
    me->cv.dist_fm.alla = (int)(zz);
    FIg_get_value(me->distform,DIST_LMLA_F,&zz);
    me->cv.dist_fm.lmla = (int)(zz);
    FIg_get_value(me->distform,DIST_GMLA_F,&zz);
    me->cv.dist_fm.gmla = (int)(zz);
    FIg_get_value(me->distform,DIST_GRCO_F,&zz);
    me->cv.dist_fm.grco = (int)(zz);
    FIg_get_value(me->distform,DIST_ALCO_F,&zz);
    me->cv.dist_fm.alco = (int)(zz);
    FIg_get_value(me->distform,DIST_LMCO_F,&zz);
    me->cv.dist_fm.lmco = (int)(zz);
    FIg_get_value(me->distform,DIST_GMCO_F,&zz);
    me->cv.dist_fm.gmco = (int)(zz);
    FIg_get_value(me->distform,DIST_GRWT_F,&zz);
    me->cv.dist_fm.grwt = (int)(zz);
    FIg_get_value(me->distform,DIST_ALWT_F,&zz);
    me->cv.dist_fm.alwt = (int)(zz);
    FIg_get_value(me->distform,DIST_LMWT_F,&zz);
    me->cv.dist_fm.lmwt = (int)(zz);
    FIg_get_value(me->distform,DIST_GMWT_F,&zz);
    me->cv.dist_fm.gmwt = (int)(zz);
    FIg_get_value(me->distform,DIST_GRST_F,&zz);
    me->cv.dist_fm.grst = (int)(zz);
    FIg_get_value(me->distform,DIST_ALST_F,&zz);
    me->cv.dist_fm.alst = (int)(zz); 
    FIg_get_value(me->distform,DIST_LMST_F,&zz);
    me->cv.dist_fm.lmst = (int)(zz);
    FIg_get_value(me->distform,DIST_GMST_F,&zz);
    me->cv.dist_fm.gmst = (int)(zz);
    FIg_get_state(me->distform,DIST_GRAP_T,&me->cv.dist_fm.grap);
    FIg_get_state(me->distform,DIST_ALLN_T,&me->cv.dist_fm.alln);
    FIg_get_state(me->distform,DIST_LOCA_T,&me->cv.dist_fm.loca);
    FIg_get_state(me->distform,DIST_GLOB_T,&me->cv.dist_fm.glob);
    FIg_get_state(me->distform,DIST_MYSY_T,&me->cv.dist_fm.mysy);
    FIg_get_state(me->distform,DIST_OUTP_T,&me->cv.dist_fm.outp);
    FIg_get_state(me->distform,DIST_WIFI_T,&me->cv.dist_fm.wifi);
    FIg_get_state(me->distform,DIST_APNF_T,&me->cv.dist_fm.apnf);
    FIg_get_state(me->distform,DIST_NUMB_T,&me->cv.dist_fm.numb);
    FIg_get_state(me->distform,DIST_LSPO_T,&me->cv.dist_fm.lspo);
    FIg_get_state(me->distform,DIST_PRPO_T,&me->cv.dist_fm.prpo);
    FIg_get_state(me->distform,DIST_DIST_T,&me->cv.dist_fm.dist);
    me->error_flag = FALSE;
    me->distform_requested = FALSE;
    ret = FIf_erase(me->distform);
    break;

   case DIST_FLNA_F:
    FIg_get_text(me->distform, DIST_FLNA_F, me->cv.dist_fm.flna);
    break;

   case DIST_INPT_B:
    #if dflT1
     fprintf(stderr,"\nStart DIST_INPT_B");
    #endif
    FIg_get_text(me->distform, DIST_FLNA_F, me->cv.dist_fm.flna);
    if ( 14<strlen(me->cv.dist_fm.flna) )
    {
     fprintf(stderr,"\nFilename too long !");
     break;
    }
    FIg_get_text(me->distform, DIST_TEXT_F, me->cv.dist_fm.text);
    if ( 80<strlen(me->cv.dist_fm.text) )
    {
     fprintf(stderr,"\nTextstring too long !");
     break;
    }
    FIg_get_state(me->distform, DIST_OUTP_T, &me->cv.dist_fm.outp);
    FIg_get_state(me->distform, DIST_WIFI_T, &me->cv.dist_fm.wifi);
    FIg_get_state(me->distform, DIST_APNF_T, &me->cv.dist_fm.apnf);
    if ( me->cv.dist_fm.outp&&!me->cv.dist_fm.wifi&&me->cv.dist_fm.apnf )
    {
     if ( fp=fopen(me->cv.dist_fm.flna,"r") )
     {
      fprintf(stderr,"\nfile %s exists already !",me->cv.dist_fm.flna);
      fprintf(stderr,"\nNothing will be written !");
      break;
     }
     else
     {
      if ( fp=fopen(me->cv.dist_fm.flna,"w") )
        fprintf(fp,"\n%s",me->cv.dist_fm.text);
      fclose(fp);
     }
    }
    if ( me->cv.dist_fm.outp&&!me->cv.dist_fm.wifi&&!me->cv.dist_fm.apnf )
    {
     if ( fp=fopen(me->cv.dist_fm.flna,"a") )
     {
      fprintf(fp,"\n%s",me->cv.dist_fm.text);
      fclose(fp);
     }
     else
     {
      fprintf(stderr,"\nFile couldnt be opened  ");
      fprintf(stderr,"for append !");
      fprintf(stderr,"Filename %s",me->cv.dist_fm.flna );
      break;
     }
    }
    /*if ( me->cv.dist_fm.outp&&me->cv.dist_fm.wifi )
    { 
     fprintf(stderr,"\nFolgender Text in EMS-window !");
     fprintf(stderr,"\n %s ",me->cv.dist_fm.text);
    }*/
   break;

   case DIST_REST_B:
    #if dflT1
     fprintf(stderr,"\ncase DIST_REST_B");
    #endif
    dist_def(&me->cv.dist_fm);
    /*stat_OM = om$send (msg = message ECascrcr.set_defaults(&msg_loc),
                  targetid = my_id);*/
    /*me->form_requested = 0;*/

    me->error_flag = FALSE;
    me->distform_requested = FALSE;
    ret = FIf_erase(me->distform);
   break;

   case DIST_PROJ_B:
    FIg_get_state(me->distform,DIST_PROJ_B,&me->cv.dist_fm.proj);
    FIg_set_state(me->distform,DIST_CONN_B,OF);
    me->cv.dist_fm.conn = 0;
    FIg_set_state(me->distform,DIST_MIXE_B,OF);
    me->cv.dist_fm.mixe = 0;
    break;
   case DIST_CONN_B:
    FIg_get_state(me->distform,DIST_CONN_B,&me->cv.dist_fm.conn);
    FIg_set_state(me->distform,DIST_PROJ_B,OF);
    me->cv.dist_fm.proj = 0;
    FIg_set_state(me->distform,DIST_MIXE_B,OF);
    me->cv.dist_fm.mixe = 0;
    break;
   case DIST_MIXE_B:
    FIg_get_state(me->distform,DIST_MIXE_B,&me->cv.dist_fm.mixe);
    FIg_set_state(me->distform,DIST_PROJ_B,OF);
    me->cv.dist_fm.proj = 0;
    FIg_set_state(me->distform,DIST_CONN_B,OF);
    me->cv.dist_fm.conn = 0;
    break;
   case DIST_MAXL_B:
    FIg_get_state(me->distform,DIST_MAXL_B,&me->cv.dist_fm.maxl);
    FIg_set_state(me->distform,DIST_SCAF_B,OF);
    me->cv.dist_fm.scaf = 0;
    break;
   case DIST_SCAF_B:
    FIg_get_state(me->distform,DIST_SCAF_B,&me->cv.dist_fm.scaf);
    FIg_set_state(me->distform,DIST_MAXL_B,OF);
    me->cv.dist_fm.maxl = 0;
    break;


   default:   
   break;
  }
 }
 #if dflT1
  fprintf(stderr,"\nEnde  : dist_do_form");
 #endif
 return ( OM_S_SUCCESS );
}


method spol_do_form ( IGRlong   *msg        ;
                      IGRint    form_label  ;
                      IGRint    gadget_label;
                      IGRdouble value       )
{
 IGRlong   sts, msg_loc, stat_OM;
 IGRint    ret;
 IGRdouble zz=0.0;   
 #if dflT1
  fprintf(stderr,"\nStart : spol_do_form");
 #endif
 sts = OM_S_SUCCESS;
 if ( form_label==SPOLFORM )
 {
  switch ( gadget_label )
  {
   case SPOL_EXSA_B:
    #if dflT1
     fprintf(stderr,"\ncase SPOL_EXSA_B");
     fprintf(stderr,"\ne - me->cv.spol_fm.lsla = %d",me->cv.spol_fm.lsla); 
    #endif
    /*me->form_requested = 0;*/
    me->error_flag = FALSE;
    me->spolform_requested = FALSE;
    ret = FIf_erase(me->spolform);  
   break;

   case SPOL_QUIT_B:
    #if dflT1
     fprintf(stderr,"\ncase SPOL_QUIT_B");
    #endif
    FIg_get_value(me->spolform,SPOL_LSLA_F,&zz);
    me->cv.spol_fm.lsla = (int)(zz);
    FIg_get_value(me->spolform,SPOL_PTLA_F,&zz);
    me->cv.spol_fm.ptla = (int)(zz);
    FIg_get_value(me->spolform,SPOL_LSCO_F,&zz);
    me->cv.spol_fm.lsco = (int)(zz);
    FIg_get_value(me->spolform,SPOL_PTCO_F,&zz);
    me->cv.spol_fm.ptco = (int)(zz);
    FIg_get_value(me->spolform,SPOL_LSWT_F,&zz);
    me->cv.spol_fm.lswt = (int)(zz);
    FIg_get_value(me->spolform,SPOL_PTWT_F,&zz);
    me->cv.spol_fm.ptwt = (int)(zz);
    FIg_get_value(me->spolform,SPOL_LSST_F,&zz);
    me->cv.spol_fm.lsst = (int)(zz);
    FIg_get_state(me->spolform,SPOL_TOPO_T,&me->cv.spol_fm.topo);
    FIg_get_state(me->spolform,SPOL_PNTS_T,&me->cv.spol_fm.pnts);
    FIg_get_state(me->spolform,SPOL_LSTR_T,&me->cv.spol_fm.lstr);
    FIg_get_state(me->spolform,SPOL_MYSY_T,&me->cv.spol_fm.mysy); 
    me->error_flag = FALSE;
    me->spolform_requested = FALSE;
    ret = FIf_erase(me->spolform);  
   break;

   case SPOL_REST_B:
    #if dflT1
     fprintf(stderr,"\ncase SPOL_REST_B");
    #endif
    spol_def(&me->cv.spol_fm);
    /*stat_OM = om$send (msg = message ECascrcr.set_defaults(&msg_loc),
                  targetid = my_id);*/
    /*me->form_requested = 0;*/
    me->error_flag = FALSE;
    me->spolform_requested = FALSE;
    ret = FIf_erase(me->spolform);
   break;


   default:
   break;
  }
 }
 #if dflT1
  fprintf(stderr,"\nEnde  : spol_do_form");
 #endif
 return ( OM_S_SUCCESS );
}


method sknt_do_form ( IGRlong   *msg        ;
                      IGRint    form_label  ;
                      IGRint    gadget_label;
                      IGRdouble value       )
{
 IGRlong   sts, msg_loc, stat_OM;
 IGRint    ret;
 IGRdouble zz=0.0;
 #if dflT1
  fprintf(stderr,"\nStart : method sknt_do_form");
 #endif
 sts = OM_S_SUCCESS;
 if ( form_label==SKNTFORM )
 {
  switch ( gadget_label )
  {
   case SKNT_EXSA_B:
    #if dflT1
     fprintf(stderr,"\ncase SKNT_EXSA_B");
    #endif

    /*me->form_requested = 0;*/
    me->error_flag = FALSE;
    me->skntform_requested = FALSE;
    ret = FIf_erase(me->skntform);
   break;

   case SKNT_QUIT_B:
    #if dflT1
     fprintf(stderr,"\ncase SKNT_QUIT_B");
    #endif
    FIg_get_value(me->skntform,SKNT_LSLA_F,&zz);
    me->cv.sknt_fm.lsla = (int)(zz);
    FIg_get_value(me->skntform,SKNT_PTSL_F,&zz);
    me->cv.sknt_fm.ptsl = (int)(zz);
    FIg_get_value(me->skntform,SKNT_PTML_F,&zz);
    me->cv.sknt_fm.ptml = (int)(zz);
    FIg_get_value(me->skntform,SKNT_LSCO_F,&zz);
    me->cv.sknt_fm.lsco = (int)(zz);
    FIg_get_value(me->skntform,SKNT_PTSC_F,&zz);
    me->cv.sknt_fm.ptsc = (int)(zz);
    FIg_get_value(me->skntform,SKNT_PTMC_F,&zz);
    me->cv.sknt_fm.ptmc = (int)(zz);
    FIg_get_value(me->skntform,SKNT_LSWT_F,&zz);
    me->cv.sknt_fm.lswt = (int)(zz);
    FIg_get_value(me->skntform,SKNT_PTSW_F,&zz);
    me->cv.sknt_fm.ptsw = (int)(zz);
    FIg_get_value(me->skntform,SKNT_PTMW_F,&zz);
    me->cv.sknt_fm.ptmw = (int)(zz);
    FIg_get_value(me->skntform,SKNT_LSST_F,&zz);
    me->cv.sknt_fm.lsst = (int)(zz);
    FIg_get_state(me->skntform,SKNT_LSTR_T,&me->cv.sknt_fm.lstr);
    FIg_get_state(me->skntform,SKNT_PNTS_T,&me->cv.sknt_fm.pnts);
    FIg_get_state(me->skntform,SKNT_PNTM_T,&me->cv.sknt_fm.pntm);
    FIg_get_state(me->skntform,SKNT_MYSY_T,&me->cv.sknt_fm.mysy);
    me->error_flag = FALSE;
    me->skntform_requested = FALSE;
    ret = FIf_erase(me->skntform);
   break;

   case SKNT_REST_B:
    #if dflT1
     fprintf(stderr,"\ncase SKNT_REST_B");
    #endif
    sknt_def(&me->cv.sknt_fm);
    /*stat_OM = om$send (msg = message ECascrcr.set_defaults(&msg_loc),
                  targetid = my_id);*/
    /*me->form_requested = 0;*/
    me->error_flag = FALSE;
    me->skntform_requested = FALSE;
    ret = FIf_erase(me->skntform);
   break;


   default:
   break;
  }
 }
 #if dflT1
  fprintf(stderr,"\nEnde : method sknt_do_form");
 #endif
 return ( OM_S_SUCCESS );
}

method cvra_exec ( IGRlong *msg )
{ 
 #include "bsparameters.h"
 IGRlong  stat_OM, msg1;
 struct   IGRbsp_curve *crv = NULL;
 struct   GRsymbology  symb;
 BSrc     rc;
 IGRboolean ev_bound, bound;
 IGRint     j=0, ND=0, siz=0, nuno=0;
 IGRdouble  udel=0.0, *nx, *ny, *nz, *rho, *p_x, *p_y, *p_z, *pnt, 
            fakt=0.0, u_str=0.0, 
            u_end=0.0, d_l[9], d_r[9], max=0.0, mx=0.0, my=0.0, 
            mz=0.0, tmp_a=0.0, tmp_b=0.0, *ppt, bs_tol=0.0; 
 struct GRid *l_o;
 ND = 2;
 bs_tol = 1e-5;
 #if dflT1
  fprintf(stderr,"\nStart : method cvra_exec");
 #endif

 gr$get_curve_geometry ( msg          = &msg1          ,
                         object_id    = &me->curve_id,
                         curve_struct = &crv          );
 TEST_ERROR(msg1,msg1,"get_curve_geometry",cvra_end);
 if ( me->cv.cvra_fm.par1 && 1<me->cv.cvra_fm.anzn )
  u_end = me->cv.cvra_fm.u_p1;
 /*
 if ( me->cv.cvra_fm.par2 )
 */
 {
  if ( me->cv.cvra_fm.uend < me->cv.cvra_fm.ustr )
  {
   u_str = me->cv.cvra_fm.uend;
   u_end = me->cv.cvra_fm.ustr;
  }
  else
  {
   u_str = me->cv.cvra_fm.ustr;
   u_end = me->cv.cvra_fm.uend;
  }
 }
 /* Number of points is greater than 1 */
 nuno = me->cv.cvra_fm.anzn;
 if ( 1<nuno )
 {
  if ( me->cv.cvra_fm.cvin )
  {
   /* anzn points are wanted along the whole curve */
   nuno = 1 + (int)((double)(nuno-1)*(u_end - u_str)+0.5);
   if ( nuno<2 )
    nuno = 2;
  }
  udel = (u_end - u_str)/(double)(nuno-1);
 }
 siz = nuno * sizeof( IGRdouble );
 nx  = (IGRdouble *) om$malloc ( size = siz );
 if(!nx)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(nx)",cvra_end);
 ny  = (IGRdouble *) om$malloc ( size = siz );
 if(!ny)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(ny )",cvra_end);
 nz  = (IGRdouble *) om$malloc ( size = siz );
 if(!nz)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(nz)",cvra_end);
 rho = (IGRdouble *) om$malloc ( size = siz );
 if(!rho)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(rho)",cvra_end);
 p_x = (IGRdouble *) om$malloc ( size = siz );
 if(!p_x)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(p_x)",cvra_end);
 p_y = (IGRdouble *) om$malloc ( size = siz );
 if(!p_y)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(p_y)",cvra_end);
 p_z = (IGRdouble *) om$malloc ( size = siz );
 if(!p_z)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(p_z)",cvra_end);
 ppt = (IGRdouble *) om$malloc ( size = 6*siz );
 if(!ppt)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(ppt)",cvra_end);
 siz = 3 * nuno * sizeof ( IGRdouble );
 pnt = (IGRdouble *) om$malloc ( size = siz );
 if(!pnt)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(pnt)",cvra_end);
 siz = nuno * sizeof ( struct GRid );
 l_o = (struct GRid *) om$malloc ( size = siz );
 if(!l_o)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(l_o)",cvra_end);
 max = 0;
 if ( udel<bs_tol )
  nuno = 1;
 if ( nuno==1 && me->cv.cvra_fm.par1 )
  u_str = me->cv.cvra_fm.u_p1;
 if ( me->cv.cvra_fm.weit<3 )
  symb.display_attr.weight = 20;
 /* fprintf(stderr,"\nnuno = %d",nuno); */
 switch ( me->cv.cvra_fm.cura )
 {
  case 0:
   /* Radius is active */
   for ( j=0 ; j<nuno ; j++ )
   {
    tmp_a = u_str + (double)(j)*udel;
    BScveval_b(&rc,crv,&tmp_a,&ND,&ev_bound,&bound,&d_l[0],&d_r[0]);
    TEST_MATH_ERROR(rc,"BScveval",cvra_end);
    mx = d_l[3]*d_l[3]+d_l[4]*d_l[4]+d_l[5]*d_l[5];
    my = d_l[6]*d_l[6]+d_l[7]*d_l[7]+d_l[8]*d_l[8];
    mz = d_l[3]*d_l[6]+d_l[4]*d_l[7]+d_l[5]*d_l[8]; 
    tmp_a = mx*mx*mx;
    tmp_b = mx*my - mz*mz;
    if ( 1<tmp_a && tmp_b<1e-6 )
    {
     fprintf(stderr,"\nMessage from the cvra_exec method !");
     fprintf(stderr,"\nThe greatest radius is greater than 1e-6 !");
     fprintf(stderr,"  No radius profile is displayed !");
     ME.super_cmd->state = GET_ACCPT;
     goto cvra_end;
    }
    rho[j] = sqrt( tmp_a/tmp_b );
    if ( max < rho[j] )
     max = rho[j];
    mx = d_l[4]*d_l[8]-d_l[5]*d_l[7];
    my = d_l[5]*d_l[6]-d_l[3]*d_l[8];
    mz = d_l[3]*d_l[7]-d_l[4]*d_l[6];
    nx[j] = my*d_l[5]-mz*d_l[4];
    ny[j] = mz*d_l[3]-mx*d_l[5];
    nz[j] = mx*d_l[4]-my*d_l[3];
    p_x[j] = d_l[0];
    p_y[j] = d_l[1];
    p_z[j] = d_l[2];
   }
  break;
  case 1:
   /* Curvature active */
   for ( j=0 ; j<nuno ; j++ )
   {
    tmp_a = u_str + (double)(j)*udel;
    BScveval_b(&rc,crv,&tmp_a,&ND,&ev_bound,&bound,&d_l[0],&d_r[0]);
    TEST_MATH_ERROR(rc,"BScveval(2)",cvra_end);
    mx = d_l[3]*d_l[3]+d_l[4]*d_l[4]+d_l[5]*d_l[5];
    my = d_l[6]*d_l[6]+d_l[7]*d_l[7]+d_l[8]*d_l[8];
    mz = d_l[3]*d_l[6]+d_l[4]*d_l[7]+d_l[5]*d_l[8];
    if ( mx<1e-6 )
    {
     fprintf(stderr,"\nMessage from the cvra_exec method !");
     fprintf(stderr,"\nThe curve is not regular parametrisized !");
    }
    rho[j] = sqrt(fabs( mx*my - mz*mz ) / ( mx*mx*mx ));
    if ( max < rho[j] )
     max = rho[j];
    mx = d_l[4]*d_l[8]-d_l[5]*d_l[7];
    my = d_l[5]*d_l[6]-d_l[3]*d_l[8];
    mz = d_l[3]*d_l[7]-d_l[4]*d_l[6];
    nx[j] = my*d_l[5]-mz*d_l[4];
    ny[j] = mz*d_l[3]-mx*d_l[5];
    nz[j] = mx*d_l[4]-my*d_l[3];
    p_x[j] = d_l[0];
    p_y[j] = d_l[1];
    p_z[j] = d_l[2];
   }
  break;
 }
 if ( max<1e-5 || 1e6<max )
 {
  fprintf(stderr,"\nMessage from the cvra_exec method !"); 
  fprintf(stderr,"\nThe longest normal is %12.8f !",max);
  fprintf(stderr,"  No curvature profile is displayed !");
  ME.super_cmd->state = GET_ACCPT;
  goto cvra_end;
 }
 if ( me->cv.cvra_fm.maxl )
   fakt = me->cv.cvra_fm.leth/max;
 if ( me->cv.cvra_fm.scaf )
   fakt = me->cv.cvra_fm.fact;
 switch ( me->cv.cvra_fm.nogr )
 {
  case 0:
   /* Graph is active */ 
   for ( j=0 ; j < nuno ; j++ )
   {
    tmp_a = sqrt(nx[j]*nx[j]+ny[j]*ny[j]+nz[j]*nz[j]);
    pnt[3*j]   = p_x[j] + fakt*rho[j]*nx[j]/tmp_a;
    pnt[3*j+1] = p_y[j] + fakt*rho[j]*ny[j]/tmp_a;
    pnt[3*j+2] = p_z[j] + fakt*rho[j]*nz[j]/tmp_a;
   }
   switch ( me->cv.cvra_fm.mysy )
   {
    case 0:
     /* Active Symbology */
     gr$place_linear_object ( msg = &msg1       ,
                     md_env       = NULL        ,
                     num_points   = nuno        ,
                     points       = pnt         ,
                     object_id    = &me->cvra_gr,
                     display_flag = 1          ); 
     TEST_ERROR(msg1,msg1,"place_linear_object",cvra_end);
     me->cvra_gr_on = TRUE;
    break;
    case 1:
     /* My Symbology */
     gr$place_linear_object ( msg = &msg1       ,
                     md_env       = NULL        ,
                     num_points   = nuno        ,
                     points       = pnt         ,
                     object_id    = &me->cvra_gr,
                     display_flag = 0          ); 
     TEST_ERROR(msg1,msg1,"place_linear_object",cvra_end);
     gr$get_symbology ( object_id = &me->cvra_gr,
                        symb      = &symb      );
     symb.level               = me->cv.cvra_fm.layr;
     symb.display_attr.color  = me->cv.cvra_fm.colo;
     symb.display_attr.weight = me->cv.cvra_fm.weit;
     if ( nuno==1 && me->cv.cvra_fm.weit<3 )
      symb.display_attr.weight = 20;
     symb.display_attr.style  = me->cv.cvra_fm.styl;
     gr$put_symbology ( object_id = &me->cvra_gr,
                        symb      = &symb      );
     gr$display_object ( object_id = &me->cvra_gr,
                         md_env    = NULL    ,
                         mode      = GRbd   );
     me->cvra_gr_on = TRUE;  
    break; 
   } 
  break;
  case 1:
   /* Normals is active */
   for ( j=0 ; j < nuno ; j++ )
   {
    tmp_a = sqrt(nx[j]*nx[j]+ny[j]*ny[j]+nz[j]*nz[j]);
    ppt[6*j]   = p_x[j];
    ppt[6*j+1] = p_y[j];
    ppt[6*j+2] = p_z[j];
    ppt[6*j+3] = ppt[6*j]   + fakt*rho[j]*nx[j]/tmp_a;
    ppt[6*j+4] = ppt[6*j+1] + fakt*rho[j]*ny[j]/tmp_a;
    ppt[6*j+5] = ppt[6*j+2] + fakt*rho[j]*nz[j]/tmp_a;
   }
   switch ( me->cv.cvra_fm.fasl )
   {
    case 0:
     /* Normals are wanted in SLow modus */
     switch ( me->cv.cvra_fm.mysy )
     {
      case 0:
       /* Active symbology */ 
       for ( j=0 ; j < nuno ; j++ )
       {
        gr$place_linear_object( msg = &msg1    ,
                       num_points   = 2        ,
                       points       = &ppt[6*j],
                       object_id    = &l_o[j]  ,
                       display_flag = 1       );
       }
       gr$create_graphic_group ( msg = &msg1,
                        object_ids   = l_o  , 
                        num_objects  = nuno ,
                        gg_id        = &me->cvra_gr);
       me->cvra_gr_on = TRUE;   
      break;
      case 1:
       /* My symbology */
       for ( j=0 ; j < nuno ; j++ )
       { 
        gr$place_linear_object( msg = &msg1    ,
                       md_env       = NULL     ,
                       num_points   = 2        ,
                       points       = &ppt[6*j],
                       object_id    = &l_o[j]  ,
                       display_flag = 0       );
       }
       gr$create_graphic_group ( msg = &msg1,
                        object_ids   = l_o  ,
                        num_objects  = nuno ,
                        gg_id        = &me->cvra_gr);
       gr$get_symbology ( object_id = &me->cvra_gr,
                          symb      = &symb      );
       symb.level               = me->cv.cvra_fm.layr;
       symb.display_attr.color  = me->cv.cvra_fm.colo;
       symb.display_attr.weight = me->cv.cvra_fm.weit;
       symb.display_attr.style  = me->cv.cvra_fm.styl;
       gr$put_symbology ( object_id = &me->cvra_gr,
                          symb      = &symb      );
       gr$display_object ( object_id = &me->cvra_gr,
                           md_env    = NULL    ,
                           mode      = GRbd   );
       me->cvra_gr_on = TRUE;
      break;
     }
    break;
    case 1:
     /* Normals are wanted in FAst modus */
     switch ( me->cv.cvra_fm.mysy )
     {
      case 0:   
       gr$place_linear_object( msg = &msg1       ,
                      md_env       = NULL        ,
                      num_points   = 2 * nuno    ,
                      points       = &ppt[0]     ,
                      object_id    = &me->cvra_gr,
                      display_flag = 1          );
       TEST_ERROR(msg1,msg1,"place_linear_object",cvra_end);
       me->cvra_gr_on = TRUE;
      break;
      case 1:
       gr$place_linear_object( msg = &msg1       ,
                      md_env       = NULL        ,
                      num_points   = 2 * nuno    ,
                      points       = &ppt[0]     ,
                      object_id    = &me->cvra_gr,
                      display_flag = 0          );
       TEST_ERROR(msg1,msg1,"place_linear_object",cvra_end);
       gr$get_symbology ( object_id = &me->cvra_gr,
                          symb      = &symb      );
       symb.level               = me->cv.cvra_fm.layr;
       symb.display_attr.color  = me->cv.cvra_fm.colo;
       symb.display_attr.weight = me->cv.cvra_fm.weit;
       symb.display_attr.style  = me->cv.cvra_fm.styl;
       gr$put_symbology ( object_id = &me->cvra_gr,
                          symb      = &symb      );
       gr$display_object ( object_id = &me->cvra_gr,
                           md_env    = NULL    ,
                           mode      = GRbd   );  
       me->cvra_gr_on = TRUE;
      break; 
     }
    break;
   } 
   if ( me->cv.cvra_fm.mysy )
   {
    gr$get_symbology ( object_id = &l_o[j],
                       symb      = &symb);
    symb.level               = me->cv.cvra_fm.layr;
    symb.display_attr.color  = me->cv.cvra_fm.colo;
    symb.display_attr.weight = me->cv.cvra_fm.weit;
    symb.display_attr.style  = me->cv.cvra_fm.styl;
    gr$put_symbology ( object_id = &l_o[0],
                       symb      = &symb);
    gr$display_object ( object_id = &l_o[0],
                        md_env    = NULL   ,
                        mode      = GRbd  );
   }
  break;
 }
 cvra_end:
 gr$free_curve(curve_struct = crv);
 if(l_o) om$dealloc(ptr = l_o);
 if(pnt) om$dealloc(ptr = pnt);
 if(ppt) om$dealloc(ptr = ppt);
 if(p_z) om$dealloc(ptr = p_z);
 if(p_y) om$dealloc(ptr = p_y);
 if(p_x) om$dealloc(ptr = p_x);
 if(rho) om$dealloc(ptr = rho);
 if(nz) om$dealloc(ptr = nz);
 if(ny) om$dealloc(ptr = ny);
 if(nx) om$dealloc(ptr = nx);
 #if dflT1
  fprintf(stderr,"\nEnde  : method cvra_exec");
 #endif
 return(0);
}
method dist_exec ( IGRlong *msg )
{
 #include   "bsparameters.h"
 struct     GRid  *l_o;
 struct     IGRbsp_curve *crv = NULL;
 struct     GRsymbology  symb;
 BSrc       rc;
 FILE       *fp;
 IGRboolean alloncv;
 IGRlong    stat_OM, msg1, msg_loc;
 IGRchar    imsg[MSG_F_L];
 IGRint     i=0, j=0, max_i=0, *l_m, n_str=0, n_end=0, n_anz=0, siz=0;
 IGRint     max_t=0;
 IGRdouble  tol_bas=0.0, max=0.0,tmp=0.0,*dist,*u_par,*pnt,*lot,pt[6],
            *nx,*ny,*nz,*pts,fakt=0.0;
 #if dflT1 
  fprintf(stderr,"\nStart : method dist_exec");
 #endif
 tol_bas = 1e-5;
 gr$get_curve_geometry ( msg          = &msg1 ,
                         object_id    = &me->curve_id,
                         curve_struct = &crv );
 TEST_ERROR(msg1,msg1,"get_curve_geometry",dist_end);

 stat_OM = dp$erase_hilite(msg = &msg_loc);
 
 ME.ECelement->elem_hilit = FALSE;
 siz   = me->nvx * sizeof ( IGRdouble ); 
 nx    = (IGRdouble *) om$malloc ( size = siz );
 if(!nx)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(nx)",dist_end);
 ny    = (IGRdouble *) om$malloc ( size = siz );
 if(!ny)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(ny)",dist_end);
 nz    = (IGRdouble *) om$malloc ( size = siz );
 if(!nz)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(nz)",dist_end);
 u_par = (IGRdouble *) om$malloc ( size = siz );
 if(!u_par)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(u_par)",dist_end);
 dist  = (IGRdouble *) om$malloc ( size = siz );
 if(!dist)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(dist)",dist_end);
 siz   = 3 * me->nvx * sizeof ( IGRdouble );
 pts   = (IGRdouble *) om$malloc ( size = siz );
 if(!pts)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(pts)",dist_end);
 lot   = (IGRdouble *) om$malloc ( size = siz );
 if(!lot)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(lot)",dist_end);
 pnt   = (IGRdouble *) om$malloc ( size = siz );
 if(!pnt)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(pnt)",dist_end);
 l_m   = (IGRint    *) om$malloc ( size =  me->nvx * sizeof ( IGRint ) );;
 if(!l_m)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(l_m)",dist_end);
 l_o   = (struct GRid *) om$malloc ( size = (1+me->nvx)*sizeof( struct GRid ) );
 
 for ( j=0,i=0 ; j<me->nvx ; j++ )
 {
  pts[i++] = me->vxt[j].xp;
  pts[i++] = me->vxt[j].yp;
  pts[i++] = me->vxt[j].zp;
 }
 alloncv = TRUE;
 me->XXXXX = 4680;
 BSmdstptscv(me->nvx,pts,crv,u_par,lot,dist,&alloncv, &rc);
 TEST_MATH_ERROR(rc,"BSmdstptscv",dist_end);
 n_str = 0;
 n_end = me->nvx;
 if ( me->cv.dist_fm.conn )
 { 
  IGRint nu_po;
  nu_po = crv->num_poles;
  /* connect is on */
  for ( i=0 ; i<3 ; i++ )
  { 
   lot[i] = *(crv->poles+(i));
   lot[3*n_end-3+i] = *(crv->poles+(3*nu_po-3+i));
  }
  dist[0] = sqrt ( (lot[0]-pts[0]) * (lot[0]-pts[0]) +
                   (lot[1]-pts[1]) * (lot[1]-pts[1]) +
                   (lot[2]-pts[2]) * (lot[2]-pts[2]) );
  dist[n_end-1] = sqrt ( (lot[3*n_end-3]  -pts[3*n_end-3])   * 
                               (lot[3*n_end-3]  -pts[3*n_end-3])  +
                         (lot[3*n_end-3+1]-pts[3*n_end-3+1]) * 
                               (lot[3*n_end-3+1]-pts[3*n_end-3+1])+
                         (lot[3*n_end-3+2]-pts[3*n_end-3+2]) *
                               (lot[3*n_end-3+2]-pts[3*n_end-3+2]) );
 }
 if ( me->cv.dist_fm.proj )  
 {
  /* project is on */
  while ( u_par[n_str]==0 )
   n_str++;
  while ( u_par[n_end-1]==1 )
   n_end--;
 }
 n_anz = n_end - n_str;
 max = -1;
 for ( i=n_str ; i<n_end ; i++ )
 {
  if ( max<dist[i] )
  {
   max   = dist[i];
   max_i = i;
  }
  nx[i] = pts[3*i]   - lot[3*i];
  ny[i] = pts[3*i+1] - lot[3*i+1];
  nz[i] = pts[3*i+2] - lot[3*i+2];
 }
 if ( me->cv.dist_fm.loca )
 {
  /* Find out: Where is a local maximium */
  l_m[n_str] = 1; 
  for ( i=n_str+1 ; i<n_end ; i++ )
  {
   tmp = nx[i-1]*nx[i] + ny[i-1]*ny[i] + nz[i-1]*nz[i]; 
   if ( tmp<-tol_bas )
    l_m[i] = 1;              /* 90 degrees < angle */
   else
    l_m[i] = 0;              /* angle < 90 degrees */
   if ( dist[i-1]<dist[i] && l_m[i]==0 )
   {
    l_m[i-1] = 0;
    l_m[i]   = 1;
   }
  }
  /* l_m[i] = 1 means: pts[i] has a local max */
 }
 if ( me->cv.dist_fm.maxl )
  fakt = me->cv.dist_fm.leth/max; 
 else
  fakt = me->cv.dist_fm.fact;
 for ( i=n_str ; i<n_end ; i++ )
 { 
  if ( tol_bas<dist[i] )
  {
   tmp        = sqrt(nx[i]*nx[i]+ny[i]*ny[i]+nz[i]*nz[i]);
   pnt[3*i]   = lot[3*i]   + fakt*dist[i]*nx[i]/tmp;
   pnt[3*i+1] = lot[3*i+1] + fakt*dist[i]*ny[i]/tmp;
   pnt[3*i+2] = lot[3*i+2] + fakt*dist[i]*nz[i]/tmp;
  }
  else
  {
   pnt[3*i]   = lot[3*i];
   pnt[3*i+1] = lot[3*i+1];
   pnt[3*i+2] = lot[3*i+2];
  }
 }
 if ( me->cv.dist_fm.grap )
 {
  /* Graph is wanted */
  IGRdouble *pgr;
  pgr = (IGRdouble *) om$malloc ( size = 3 * n_anz * sizeof ( IGRdouble ) );
  for ( i=0 ; i<3*n_anz+2 ; i++ )
   pgr[i] = pnt[3*n_str+i];
  switch ( me->cv.dist_fm.mysy )
  {
   case 0:
    gr$place_linear_object ( msg          = &msg1       ,
                             num_points   = n_anz       ,
                             points       = pgr         ,
                             object_id    = &me->dist_ls,
                             display_flag = 1          );
    TEST_ERROR(msg1,msg1,"place_linear_object",dist_end);

    me->dist_ls_on = TRUE; 
   break;
   case 1:
    gr$place_linear_object ( msg          = &msg1       ,
                             num_points   = n_anz       ,
                             points       = pgr         ,
                             object_id    = &me->dist_ls,
                             display_flag = 0          );
    TEST_ERROR(msg1,msg1,"place_linear_object",dist_end);
    gr$get_symbology ( object_id = &me->dist_ls,
                       symb      = &symb      );
    symb.level               =  me->cv.dist_fm.grla;
    symb.display_attr.color  =  me->cv.dist_fm.grco;
    symb.display_attr.weight =  me->cv.dist_fm.grwt;
    symb.display_attr.style  =  me->cv.dist_fm.grst;
    gr$put_symbology( object_id = &me->dist_ls,
                      symb      = &symb      );
    gr$display_object ( object_id = &me->dist_ls,
                        md_env    = NULL        ,
                        mode      = GRbd       );
    me->dist_ls_on = TRUE;
   break;
  }
 }
 if ( me->cv.dist_fm.alln==0 && me->cv.dist_fm.loca==0 && me->cv.dist_fm.glob )
 {
  /* Only the normal at global max is wanted ! */ 
  pt[0] = lot[3*max_i];
  pt[1] = lot[3*max_i+1];
  pt[2] = lot[3*max_i+2];
  pt[3] = pnt[3*max_i];
  pt[4] = pnt[3*max_i+1];
  pt[5] = pnt[3*max_i+2];
  gr$place_linear_object ( msg         = &msg1       ,
                          num_points   = 2           ,
                          points       = pt          ,
                          object_id    = &me->dist_gr,
                          display_flag = 0          );
  TEST_ERROR(msg1,msg1,"get_curve_geometry",dist_end);
  sprintf(imsg,"Max global distance = %e", dist[max_i]);
  if(me->mainform_requested)
      put_msg(&me->mainform,M_MSG_F,imsg);
  if(me->edtform_requested)
      put_msg(&me->edtform,E_MSG_F,imsg);
  gr$get_symbology ( object_id = &me->dist_gr,
                     symb      = &symb      );
  if ( me->cv.dist_fm.mysy )
  {
   symb.level               =  me->cv.dist_fm.gmla;
   symb.display_attr.color  =  me->cv.dist_fm.gmco;
   symb.display_attr.weight =  me->cv.dist_fm.gmwt;
   symb.display_attr.style  =  me->cv.dist_fm.gmst;
   gr$put_symbology ( object_id = &me->dist_gr,
                      symb      = &symb      );
  } 
  gr$display_object ( object_id = &me->dist_gr,
                      md_env    = NULL        ,
                      mode      = GRbd       );
  me->dist_gr_on = TRUE;
 }
 if ( me->cv.dist_fm.alln ) 
 {
  /* All normals are wanted */
  for ( i=n_str ; i<n_end ; i++ )
  {
   pt[0] = lot[3*i];
   pt[1] = lot[3*i+1];
   pt[2] = lot[3*i+2];
   pt[3] = pnt[3*i];
   pt[4] = pnt[3*i+1];
   pt[5] = pnt[3*i+2];
   gr$place_linear_object ( msg         = &msg1        ,
                           num_points   = 2            ,
                           points       = pt           ,
                           object_id    = &l_o[i-n_str],
                           display_flag = 0           );
   TEST_ERROR(msg1,msg1,"place_linear_object",dist_end);
   gr$get_symbology ( object_id = &l_o[i-n_str],
                      symb      = &symb       );
   if ( me->cv.dist_fm.mysy )
   {
    symb.level               =  me->cv.dist_fm.alla;
    symb.display_attr.color  =  me->cv.dist_fm.alco;
    symb.display_attr.weight =  me->cv.dist_fm.alwt;
    symb.display_attr.style  =  me->cv.dist_fm.alst;
   }
   gr$put_symbology ( object_id = &l_o[i-n_str],
                      symb      = &symb       );
   gr$display_object ( object_id = &l_o[i-n_str],
                       md_env    = NULL         ,
                       mode      = GRbd        );
  }
  if ( me->cv.dist_fm.loca && me->cv.dist_fm.mysy )
  {
   symb.level               =  me->cv.dist_fm.lmla;
   symb.display_attr.color  =  me->cv.dist_fm.lmco;
   symb.display_attr.weight =  me->cv.dist_fm.lmwt;
   symb.display_attr.style  =  me->cv.dist_fm.lmst;
   for ( i=n_str  ; i<n_end ; i++ ) 
   {
    if ( l_m[i] )
    {
     gr$put_symbology ( object_id = &l_o[i-n_str],
                        symb      = &symb       );
     gr$display_object ( object_id = &l_o[i-n_str],
                         md_env    = NULL         ,
                         mode      = GRbd        );
    }
   }
  }
  if ( me->cv.dist_fm.glob && me->cv.dist_fm.mysy )
  {
   symb.level               =  me->cv.dist_fm.gmla;
   symb.display_attr.color  =  me->cv.dist_fm.gmco;
   symb.display_attr.weight =  me->cv.dist_fm.gmwt;
   symb.display_attr.style  =  me->cv.dist_fm.gmst;
   gr$put_symbology ( object_id = &l_o[max_i-n_str],
                      symb      = &symb           );
   gr$display_object ( object_id = &l_o[max_i-n_str],
                       md_env    = NULL             ,
                       mode      = GRbd            );
   sprintf(imsg,"Max global distance = %e", dist[max_i]);
   if(me->mainform_requested)
      put_msg(&me->mainform,M_MSG_F,imsg);
   if(me->edtform_requested)
      put_msg(&me->edtform,E_MSG_F,imsg);
  }
  gr$create_graphic_group ( msg = &msg1        ,
                    object_ids  = l_o          ,
                    num_objects = n_anz        ,
                    gg_id       = &me->dist_gr); 
  TEST_ERROR(msg1,msg1,"create_graphic_group",dist_end);
  me->dist_gr_on = TRUE;
 } 
 if ( me->cv.dist_fm.alln==0 && me->cv.dist_fm.loca )
 {
  j = -1;
  for ( i=n_str ; i<n_anz ; i++ )
  {
   if ( l_m[i] )
   {
    j++;
    if ( max_i==i )
     max_t = j;
    pt[0] = lot[3*i];
    pt[1] = lot[3*i+1];
    pt[2] = lot[3*i+2];
    pt[3] = pnt[3*i];
    pt[4] = pnt[3*i+1];
    pt[5] = pnt[3*i+2];
    gr$place_linear_object ( msg         = &msg1  ,
                            num_points   = 2      ,
                            points       = pt     ,
                            object_id    = &l_o[j],
                            display_flag = 0     );
    TEST_ERROR(msg1,msg1,"place_linear_object",dist_end);
    gr$get_symbology ( object_id = &l_o[j],
                        symb     = &symb );
    if ( me->cv.dist_fm.mysy )
    {
     symb.level               =  me->cv.dist_fm.lmla;
     symb.display_attr.color  =  me->cv.dist_fm.lmco;
     symb.display_attr.weight =  me->cv.dist_fm.lmwt;
     symb.display_attr.style  =  me->cv.dist_fm.lmst;
    } 
    gr$put_symbology ( object_id = &l_o[j],
                       symb      = &symb );
    gr$display_object ( object_id = &l_o[j],
                        md_env    = NULL   ,
                        mode      = GRbd  );
   }
  }
  if ( me->cv.dist_fm.glob && me->cv.dist_fm.mysy )
  {
   symb.level               =  me->cv.dist_fm.gmla;
   symb.display_attr.color  =  me->cv.dist_fm.gmco;
   symb.display_attr.weight =  me->cv.dist_fm.gmwt;
   symb.display_attr.style  =  me->cv.dist_fm.gmst;
   gr$put_symbology ( object_id = &l_o[max_t],
                      symb      = &symb     );
   gr$display_object ( object_id = &l_o[max_t],
                       md_env    = NULL      ,
                       mode      = GRbd     );
  }
  gr$create_graphic_group ( msg = &msg1        ,
                    object_ids  = l_o          ,
                    num_objects = j+1          ,
                    gg_id       = &me->dist_gr);
  TEST_ERROR(msg1,msg1,"create_graphic_group",dist_end);
  me->dist_gr_on = TRUE;
 }
 sprintf(imsg,"Max global distance = %e", dist[max_i]);
 if(me->mainform_requested)
  put_msg(&me->mainform,M_MSG_F,imsg);
 if(me->edtform_requested)
  put_msg(&me->edtform,E_MSG_F,imsg);
 if ( me->cv.dist_fm.outp &&  0 < me->cv.dist_fm.numb +
                                  me->cv.dist_fm.lspo +
                                  me->cv.dist_fm.prpo + 
                                  me->cv.dist_fm.dist )
 {
  switch ( me->cv.dist_fm.wifi )
  {
   case 0:
   {
    /* Output into file */
    IGRint print;
    print = 0; 
    switch ( me->cv.dist_fm.apnf )
    {
     case 0:
      /* Append output to file */
      if ( (fp=fopen(me->cv.dist_fm.flna,"a"))==NULL )
      {
       fprintf(stderr,"\nThe file %s",me->cv.dist_fm.flna);
       fprintf(stderr," can not be opened for APPEND !\n");
      }
      else
      {
       print = 1; 
      }
     break;
     case 1:
      /* New file for output */ 
      if ( fp=fopen(me->cv.dist_fm.flna,"r") )
      {
       fprintf(stderr,"\nThe file %s exists !",me->cv.dist_fm.flna);
       fprintf(stderr,"  Nothing written into file !\n");
       fclose(fp);
      }
      else
      {
       if ( (fp=fopen(me->cv.dist_fm.flna,"w"))==NULL )
       {
        fprintf(stderr,"\nThe file %s",me->cv.dist_fm.flna);
        fprintf(stderr," can not be opened for WRITE !");
       }
       else
       {
        print = 1;
       }
      }
     break;
    }
    if ( print )
    {
     /* Print into file */
     fprintf(fp,"\n");
     if ( me->cv.dist_fm.numb )
       fprintf(fp,"     ");
     if ( me->cv.dist_fm.lspo )
     {
      fprintf(fp,"    ");
      fprintf(fp,"Point on Linestring      ");
      if ( me->cv.dist_fm.prpo )
      {
       fprintf(fp,"     ");
       fprintf(fp,"Projected Point on Curve");
      }
     }
     else
     {
      if ( me->cv.dist_fm.prpo )
      {
       fprintf(fp,"    Projected Point on Curve");
      }
     }
     fprintf(fp,"\n");
     if ( me->cv.dist_fm.numb )
      fprintf(fp,"   No",j);
     if ( me->cv.dist_fm.lspo )
     {
      fprintf(fp,"     x");
      fprintf(fp,"         y");
      fprintf(fp,"         z    ");
     }
     if ( me->cv.dist_fm.prpo )
     {
      fprintf(fp,"     x");
      fprintf(fp,"         y");
      fprintf(fp,"         z    ");
     }
     if ( me->cv.dist_fm.dist )
      fprintf(fp,"  distance\n");    
     for ( j=0 ; j<me->nvx ; j++ )
     {
      fprintf(fp,"\n");
      if ( me->cv.dist_fm.numb )
       fprintf(fp,"%5d",j);
      if ( me->cv.dist_fm.lspo )
       for ( i=0 ; i<3 ; i++ )
        fprintf(fp,"%10.4f",pts[3*j+i]);
      if ( me->cv.dist_fm.prpo )
      for ( i=0 ; i<3 ; i++ )
       fprintf(fp,"%10.4f",lot[3*j+i]);
      if ( me->cv.dist_fm.dist )
      {
       fprintf(fp,"%10.4f",dist[j]);
       if ( j==max_i )
        fprintf(fp," max");
      }
     }
     fclose (fp);
    }
   }
   break;
   case 1:
    /* Output into window */
    fprintf(stderr,"\n");
    if ( me->cv.dist_fm.numb )
      fprintf(stderr,"     "); 
    if ( me->cv.dist_fm.lspo )
    {
     fprintf(stderr,"    ");
     fprintf(stderr,"Point on Linestring      ");
     if ( me->cv.dist_fm.prpo )
     {
      fprintf(stderr,"     ");
      fprintf(stderr,"Projected Point on Curve");
     } 
    }
    else
    {
     if ( me->cv.dist_fm.prpo )
     {
      fprintf(stderr,"    Projected Point on Curve");
     }  
    }
    fprintf(stderr,"\n");  
    if ( me->cv.dist_fm.numb )
      fprintf(stderr,"   No",j);
    if ( me->cv.dist_fm.lspo )
    {
     fprintf(stderr,"     x");
     fprintf(stderr,"         y");
     fprintf(stderr,"         z    ");
    }
    if ( me->cv.dist_fm.prpo )
    {
      fprintf(stderr,"     x");
      fprintf(stderr,"         y");
      fprintf(stderr,"         z    ");
    }
    if ( me->cv.dist_fm.dist )
     fprintf(stderr,"  distance\n");
    for ( j=0 ; j<me->nvx ; j++ )
    {
     fprintf(stderr,"\n"); 
     if ( me->cv.dist_fm.numb )
      fprintf(stderr,"%5d",j);
     if ( me->cv.dist_fm.lspo )
      for ( i=0 ; i<3 ; i++ )   
       fprintf(stderr,"%10.4f",pts[3*j+i]);
     if ( me->cv.dist_fm.prpo )
      for ( i=0 ; i<3 ; i++ )
       fprintf(stderr,"%10.4f",lot[3*j+i]);
     if ( me->cv.dist_fm.dist )
     {
      fprintf(stderr,"%10.4f",dist[j]);
      if ( j==max_i )
       fprintf(stderr," max"); 
     }
    }
    fprintf(stderr,"\n"); 
   break;
   default:
   break;
  }
 }
 dist_end:
 gr$free_curve(curve_struct = crv);
 if(l_o) om$dealloc(ptr = l_o);
 if(l_m) om$dealloc(ptr = l_m);
 if(pnt) om$dealloc(ptr = pnt);
 if(lot) om$dealloc(ptr = lot);
 if(pts) om$dealloc(ptr = pts);
 if(dist) om$dealloc(ptr = dist);
 if(u_par) om$dealloc(ptr = u_par);
 if(nz) om$dealloc(ptr = nz);
 if(ny) om$dealloc(ptr = ny);
 if(nx) om$dealloc(ptr = nx);
 #if dflT1
  fprintf(stderr,"\nEnde  : method - dist_exec");
 #endif
 return(0);
}

method spol_exec ( IGRlong *msg )
{

 struct    IGRbsp_curve *crv = NULL;
 struct    GRsymbology  symb;
 struct    GRid         crvid;
 IGRlong   stat_OM, msg1;
 IGRint    i=0, j=0, anz=0;
 IGRdouble tmp=0.0; 
 #if dflT1
  fprintf(stderr,"\nStart : method - spol_exec");
 #endif
 me->XXXXX = 4449;
 gr$get_curve_geometry ( msg          = &msg1          ,
                         object_id    = &me->curve_id,
                         md_env       = &me->md_env    ,
                         curve_struct = &crv          );
 TEST_ERROR(msg1,msg1,"get_curve_geometry",spol_end);
 crvid.objid = me->curve_id.objid;
 crvid.osnum = me->curve_id.osnum;

 anz = crv->num_poles;

 if ( me->cv.spol_fm.lstr )
 {
  IGRint j;
  IGRdouble *pt, tmp;
  pt = ( IGRdouble * ) om$malloc ( size = 3 * anz * sizeof ( IGRdouble ) );
  if(!pt)
    REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(pt)",spol_end);
  for ( i=0 ; i<3*anz ; i++ )
   pt[i] = *(crv->poles+(i));
  if ( crv->rational )
  {
   for ( j=0 ; j<anz ; j++ )
   {
    tmp =  *(crv->weights+(j));
    for ( i=0 ; i<3 ; i++ )
     pt[3*j+i] = pt[3*j+i]/tmp;
   }
  }
  gr$place_linear_object( msg          = &msg1       ,
                          num_points   = anz         ,
                          points       = pt          ,
                          object_id    = &me->spol_ls,
                          display_flag = 0          );
  TEST_ERROR(msg1,msg1,"place_linear_object",spol_end);
  gr$get_symbology ( object_id = &me->spol_ls,
                     symb      = &symb      );
  if ( me->cv.spol_fm.mysy )
  {
   symb.level               = me->cv.spol_fm.lsla; 
   symb.display_attr.color  = me->cv.spol_fm.lsco;
   symb.display_attr.weight = me->cv.spol_fm.lswt;
   symb.display_attr.style  = me->cv.spol_fm.lsst;
  }
  gr$put_symbology ( object_id = &me->spol_ls,
                     symb      = &symb      );
  gr$display_object ( object_id = &me->spol_ls,
                      md_env    = NULL        ,
                      mode      = GRbd       );
  me->spol_ls_on = TRUE;
  if(pt)
    om$dealloc(ptr = pt);
 }
 if ( me->cv.spol_fm.pnts )
 {
  struct GRid *p;
  IGRdouble pt[3];
  p = ( struct GRid * ) om$malloc ( size = anz * sizeof ( struct GRid ) );
  if(!p)
    REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(p)",spol_end);
    
  for ( j=0 ; j<anz ; j++ )
  {
   pt[0] = *(crv->poles+(3*j));
   pt[1] = *(crv->poles+(3*j+1));
   pt[2] = *(crv->poles+(3*j+2));
   if ( crv->rational )
   {
    tmp =  *(crv->weights+(j));
    for ( i=0 ; i<3 ; i++ )
     pt[i] = pt[i]/tmp;
   }
   gr$place_linear_object( msg          = &msg1,
                           num_points   = 1    ,
                           points       = pt   ,
                           object_id    = &p[j],
                           display_flag = 0   ); 
   TEST_ERROR(msg1,msg1,"place_linear_object",spol_end);
   gr$get_symbology ( object_id = &p[j] ,
                      symb      = &symb); 
   if ( me->cv.spol_fm.mysy )
   {
    symb.level               =  me->cv.spol_fm.ptla;
    symb.display_attr.color  =  me->cv.spol_fm.ptco;
    symb.display_attr.weight =  me->cv.spol_fm.ptwt;
   }
   gr$put_symbology ( object_id = &p[j]  ,
                      symb      = &symb );
   gr$display_object ( object_id = &p[j],
                       md_env    = NULL ,
                       mode      = GRbd);   
  }
  gr$create_graphic_group ( msg         = &msg1        ,
                            object_ids  = p            ,
                            num_objects = anz          ,
                            gg_id       = &me->spol_gr);     
  TEST_ERROR(msg1,msg1,"create_graphic_group",spol_end);
  me->spol_gr_on = 1;
  if(p)
    om$dealloc(ptr = p);
 }
 if ( me->cv.spol_fm.topo )
 {
  /* Toggle Polygon */
  /*stat_OM = om$send (msg = message EMSsubbs.EMtoggle_polygon(
                            &msg1,
                            &crvid,
                            NULL),
                targetid = my_id);
  TEST_ERROR(stat_OM,msg1,"EMtoggle_polygon",spol_end);*/
  gr$display_object ( object_id = &crvid.objid,
                      md_env    = NULL ,
                      mode      = GRbd);
 }
 spol_end:
 gr$free_curve(curve_struct = crv);

 #if dflT1
  fprintf(stderr,"\nEnde  : method - spol_exec");
 #endif
 return(stat_OM);
}
method sknt_exec ( IGRlong *msg )
{
 struct     GRid  *p;
 struct     IGRbsp_curve *crv = NULL;
 struct     GRsymbology  symb;
 BSrc       rc;
 IGRlong    stat_OM, msg1, msg_loc;
 IGRint     i=0, j=0, ord=0, knot_anz=0, anz=0, pole_anz=0;
 IGRdouble  pt[3], *pnt, *knot;
 #if dflT1
  fprintf(stderr,"\nStart : method - sknt_exec");
 #endif
 gr$get_curve_geometry ( msg          = &msg1        ,
                         object_id    = &me->curve_id,
                         curve_struct = &crv        );
 TEST_ERROR(msg1,msg1,"get_curve_geometry",sknt_end);

 stat_OM = dp$erase_hilite(msg = &msg_loc);

 ME.ECelement->elem_hilit = FALSE;
 ord      = crv->order;
 knot_anz = crv->num_knots;
 pole_anz = crv->num_poles;
 knot = ( IGRdouble * ) om$malloc ( size = knot_anz * sizeof ( IGRdouble ) );
 if(!knot)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(knot)",sknt_end);
 p = ( struct GRid * ) om$malloc ( size = knot_anz * sizeof(struct GRid ));;
 if(!p)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(p)",sknt_end);
 for ( i=0 ; i<knot_anz ; i++ )
  knot[i] = *(crv->knots+(i));
 if ( me->cv.sknt_fm.lstr )
 {
  anz  = knot_anz-2*ord+2;
  pnt  = ( IGRdouble * ) om$malloc ( size =  3 * anz * sizeof ( IGRdouble ) );
  if(!pnt)
   REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(pnt)",sknt_end);
  for ( j=0 ; j<anz ; j++ )
  {
   BScveval(crv,knot[j+ord-1],0,pt,&rc);
   TEST_MATH_ERROR(rc,"BScveval",sknt_end);
   for ( i=0 ; i<3 ; i++ )
    pnt[3*j+i] = pt[i];
  }
  gr$place_linear_object ( msg          = &msg1       ,
                           num_points   = anz         ,
                           points       = pnt         ,
                           object_id    = &me->sknt_ls,
                           display_flag = 0          );
  TEST_ERROR(msg1,msg1,"place_linear_object",sknt_end);
  gr$get_symbology ( object_id = &me->sknt_ls,
                     symb      = &symb      );
  if ( me->cv.sknt_fm.mysy )
  {
   symb.level               =  me->cv.sknt_fm.lsla;
   symb.display_attr.color  =  me->cv.sknt_fm.lsco;
   symb.display_attr.weight =  me->cv.sknt_fm.lswt;
   symb.display_attr.style  =  me->cv.sknt_fm.lsst;
  }
  gr$put_symbology ( object_id = &me->sknt_ls,
                     symb      = &symb      );
  gr$display_object ( object_id = &me->sknt_ls,
                      md_env    = NULL        ,
                      mode      = GRbd       );
  me->sknt_ls_on = TRUE;
  free(pnt);
 }
 if ( me->cv.sknt_fm.pnts )
 {
  anz = knot_anz - 2*ord + 4;
  for ( j=ord-2,i=0 ; j<knot_anz-ord+2 ; j++,i++ )
  {
   BScveval(crv,knot[j],0,pt,&rc);
   TEST_MATH_ERROR(rc,"BScveval",sknt_end);
   gr$place_linear_object( msg          = &msg1,
                           num_points   = 1    ,
                           points       = pt   ,
                           object_id    = &p[i],
                           display_flag = 0   );
   TEST_ERROR(msg1,msg1,"place_linear_object",sknt_end);
   gr$get_symbology ( object_id = &p[i] ,
                      symb      = &symb);
   if ( me->cv.sknt_fm.mysy )
   {
    symb.level               =  me->cv.sknt_fm.ptsl;
    symb.display_attr.color  =  me->cv.sknt_fm.ptsc;
    symb.display_attr.weight =  me->cv.sknt_fm.ptsw;
   }
   gr$put_symbology ( object_id = &p[i]  ,
                      symb      = &symb );
   gr$display_object ( object_id = &p[i],
                       md_env    = NULL   ,
                       mode      = GRbd  );
  }
  if ( me->cv.sknt_fm.pntm && me->cv.sknt_fm.mysy )
  { 
   for ( j=ord-1 ; j<knot_anz-ord+2 ; j++ )
   {
    if ( knot[j]-knot[j-1]<1e-5 )
    {
     for ( i=j-ord+1 ; i<j-ord+3 ; i++ )
     {
      gr$get_symbology ( object_id = &p[i] ,
                         symb      = &symb);
      symb.level               =  me->cv.sknt_fm.ptml;
      symb.display_attr.color  =  me->cv.sknt_fm.ptmc;
      symb.display_attr.weight =  me->cv.sknt_fm.ptmw;
      gr$put_symbology ( object_id = &p[i]  ,
                         symb      = &symb );
      gr$display_object ( object_id = &p[i],
                         md_env    = NULL   ,
                         mode      = GRbd  );
     } 
    }
   }
  }
  gr$create_graphic_group ( msg         = &msg1        ,
                            object_ids  = p            ,
                            num_objects = anz          ,
                            gg_id       = &me->sknt_gr);
  TEST_ERROR(msg1,msg1,"create_graphic_group",sknt_end);
  me->sknt_gr_on = TRUE;
 }
 if ( me->cv.sknt_fm.pnts==0 && me->cv.sknt_fm.pntm )
 {
  i=0;
  for ( j=ord-2 ; j<knot_anz-ord+2 ; j++ )
  {
   if ( knot[j]-knot[j-1]<1e-5 )
   {
    BScveval(crv,knot[j],0,pt,&rc);
    TEST_MATH_ERROR(rc,"BScveval",sknt_end);
    gr$place_linear_object ( msg          = &msg1,
                             num_points   = 1    ,
                             points       = pt   ,  
                             object_id    = &p[i],
                             display_flag = 0   );
    TEST_ERROR(msg1,msg1,"place_linear_object",sknt_end);
    gr$get_symbology ( object_id = &p[i] ,
                       symb      = &symb);
    if ( me->cv.sknt_fm.mysy )
    {
     symb.level               =  me->cv.sknt_fm.ptml;
     symb.display_attr.color  =  me->cv.sknt_fm.ptmc;
     symb.display_attr.weight =  me->cv.sknt_fm.ptmw;
     gr$put_symbology ( object_id = &p[i] ,
                        symb      = &symb);
    }
    gr$display_object ( object_id = &p[i],
                        md_env    = NULL ,
                        mode      = GRbd);
   i++; 
   }
  }
  if ( 0<i )
  {
   gr$create_graphic_group ( msg         = &msg1        ,
                             object_ids  = p            ,
                             num_objects = i            ,
                             gg_id       = &me->sknt_gr);
   TEST_ERROR(msg1,msg1,"create_graphic_group",sknt_end);
   me->sknt_gr_on = TRUE;
  } 
 }
 sknt_end:
 gr$free_curve(curve_struct = crv);
 free(p);
 free(knot);
 #if dflT1
  fprintf(stderr,"\nEnde  : method - sknt_exec");
 #endif
 return(0);
}
end implementation ECascrcr;
