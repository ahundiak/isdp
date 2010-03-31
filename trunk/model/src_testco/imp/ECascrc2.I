/* ###################   APOGEE COMPILED   ################## */
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
              o AFFIN_INV
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
#define dflT5 0
#define dflT7 0
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

IGRdouble	 bf_nr_2(ord,num,anz,knot,u)
IGRint      ord,num,anz;
IGRdouble   *knot,u;
{
	IGRint    i=0, j=0;
	IGRdouble a1=0.0, a2=0.0, b=0.0, *ba, *bn;
	ba = (IGRdouble *) om$malloc (size = (ord+anz) * sizeof ( IGRdouble ) );
        if(!ba)
          goto function_end;
	bn = (IGRdouble *) om$malloc (size = (ord+anz) * sizeof ( IGRdouble ) );
        if(!bn)
          goto function_end;
	for ( i=0 ; i<ord+anz ; i=i+1 )
	 bn[i] = 0;
	for ( i=0 ; i<anz ; i=i+1 )
	{
	 if ( knot[i]-EPS < u 
	      &&        u < knot[i+1]+EPS 
	      &&      EPS < knot[i+1]-knot[i] )
	 {
	  bn[i] = 1;
	  i     = anz;
	 }
	}
	for ( j=2 ; j<ord+1 ; j=j+1 )
	{
	 for ( i=num ; i<num+ord-j+2 ; i=i+1 )
	  ba[i] = bn[i];
    	 for ( i=num ; i<num+ord-j+1 ; i=i+1 )
	 {
	  if ( knot[i+j-1]-knot[i]<EPS && ba[i]<EPS )
	   a1 = 0;
	  else 
	  a1 = ba[i]*(u-knot[i])/(knot[i+j-1]-knot[i]);
	  if ( knot[i+j]-knot[i+1]<EPS && ba[i+1]<EPS )
	   a2 = 0;
	  else
	  a2 = ba[i+1]*(knot[i+j]-u)/(knot[i+j]-knot[i+1]);
	  bn[i] = a1+a2;
	 }
	}
	b = bn[i-1];

      function_end:
       if(ba)
        om$dealloc(ptr=ba);
       if(bn)
        om$dealloc(ptr=bn);
	return(b);
}


void put_msg(Form *p, IGRint l, IGRchar *t)
{
 /***put_msg***/
 /* 
    ABSTRACT  display a message in the message field of a form

    INPUT     
              Form *p        -  pointer to form structure
              IGRint l       -  gadget label of message field
              IGRchar *t     -  message text

    OUTPUT    none
 */
 FIg_set_text(*p, l, t);
}


void set_main_dfpar(struct mainform_par *p, IGRboolean next_ls)
{
 /***set_main_dfpar***/
 /* 
    ABSTRACT  sets default values in certain curve parameters

    INPUT     struct mainform_par *p     -  pointer to parameter structure
                                            
    OUTPUT    none
 */
 IGRint i=0;

 if(!next_ls) {
   p->order = MIN_CV_ORDER + 1;
   p->nspans = 1;
   p->npole = MIN_POLES + 1;
   p->smfac = 0.0;
   p->opt_curv0 = 0;
   p->opt_curv1 = 0;
   for (i=0;i<6;i++)
     p->cv_vector[i] = 0.0;
   p->rad0 = 0.0;
   p->rad1 = 0.0;
   strcpy(p->para_type,CENTRIPEDAL_T);
   strcpy(p->knot_type,UNIFORM_T);
 } else {
   p->opt_curv0 = 0;
   p->opt_curv1 = 0;
   for (i=0;i<6;i++)
     p->cv_vector[i] = 0.0;
   p->rad0 = 0.0;
   p->rad1 = 0.0;
 }
}

void set_gadget_active_inactive(Form *f, 
                                IGRint num,
                                IGRint g1, IGRint s1,
                                IGRint g2, IGRint s2,
                                IGRint g3, IGRint s3,
                                IGRint g4, IGRint s4,
                                IGRint g5, IGRint s5,
                                IGRint g6, IGRint s6,
                                IGRint g7, IGRint s7,
                                IGRint g8, IGRint s8,
                                IGRint g9, IGRint s9,
                                IGRint g10, IGRint s10,
                                IGRint g11, IGRint s11,
                                IGRint g12, IGRint s12,
                                IGRint g13, IGRint s13,
                                IGRint g14, IGRint s14,
                                IGRint g15, IGRint s15,
                                IGRint g16, IGRint s16)
{

 /* 
    ABSTRACT  function to disable or enable gadgets of a form

    INPUT
              Form *f           -  pointer to form structure
              IGRint num        -  number of gadgets to enable and/or disable
              IGRintg1-16       -  the gadget lables
              IGRints1-16       -  code to either enable or disable
                                   the gadget

 */

  IGRint i=0;
  struct gstruct{
    IGRint l;
    IGRint s;
  } g[16];
  g[0].l = g1;
  g[0].s = s1;
  if(num > 1) { g[1].l = g2; g[1].s = s2; }   
  if(num > 2) { g[2].l = g3; g[2].s = s3; }   
  if(num > 3) { g[3].l = g4; g[3].s = s4; }   
  if(num > 4) { g[4].l = g5; g[4].s = s5; }   
  if(num > 5) { g[5].l = g6; g[5].s = s6; }   
  if(num > 6) { g[6].l = g7; g[6].s = s7; }   
  if(num > 7) { g[7].l = g8; g[7].s = s8; }   
  if(num > 8) { g[8].l = g9; g[8].s = s9; }   
  if(num > 9) { g[9].l = g10; g[9].s = s10; }   
  if(num > 10) { g[10].l = g11; g[10].s = s11; }   
  if(num > 11) { g[11].l = g12; g[11].s = s12; }   
  if(num > 12) { g[12].l = g13; g[12].s = s13; }   
  if(num > 13) { g[13].l = g14; g[13].s = s14; }   
  if(num > 14) { g[14].l = g15; g[14].s = s15; }   
  if(num > 15) { g[15].l = g16; g[15].s = s16; }   


  for (i=0;i<num;i++) {
     if(g[i].s == OFF)
       FIg_disable(*f,g[i].l);
     else 
       FIg_enable(*f,g[i].l); 
  }

} 
   
void switch_to_process_state(struct GRevent *accev, IGRchar p) 
{ 
  /***switch_to_process_state***/
 /* 
    ABSTRACT  puts a character into an event structure and puts
              the event into the event queue

    INPUT
              struct GRevent *accev     -  pointer to a event
              IGRchar p                 -  character
 */

    int resp;
    IGRlong n, msg_loc, stat_OM;

    accev->event.keyin[0] = p;
    accev->event.keyin[1] = '\0';
    accev->event.keyin[2] = '\13';
    accev->event.keyin[2] = '\10';
    n = 4;
    resp = EX_CHAR;
    stat_OM = ex$putque(msg = &msg_loc,
                        pos = FRONT,
                        response = &resp,
                        byte = &n,
                        buffer = (IGRchar *) accev->event.keyin);

}

method find_max_angle(IGRlong *msg)
{
 IGRlong stat_OM, msg_loc;
 IGRchar fmessage[MSG_F_L];
 struct  IGRbsp_curve  *bsp_ptr;
 /*IGRchar    m[1],FMT_1[80],FMT_2[80],FMT_3[80],FMT_4[80],FMT_5[80];*/
 IGRint     i,*kl,*kw,klz=0,kwz=0,
            i_wmin=0,i_wmax=0,i_dmin=0,i_dmax=0,pnt_anz=0;
 IGRdouble  wmin=0.0,wmax=0.0,dmin=0.0,dmax=0.0,
            *l,*vx,*vy,*vz,*w, cw=0.0,sw=0.0,*px,*py,*pz;

 stat_OM = msg_loc = OM_S_SUCCESS;

 wmax  	= -9999.0;
 wmin  	=  9999.0;
 dmin  	=  1e10;
 dmax   =  1e-10;

 gr$get_curve_geometry ( msg          = &msg_loc          ,
                         object_id    = &me->ls_info,
                         curve_struct = &bsp_ptr          );
 /*stat_OM = om$send (msg = message GRvg.GRgenabsg(
                          &msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &bsp_ptr),                        
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum);*/
 TEST_ERROR(msg_loc,msg_loc,"get_curve_geometry",function_end);

 pnt_anz    =  bsp_ptr->num_poles;

 px = (IGRdouble *) om$malloc( size = (pnt_anz+1) * sizeof ( IGRdouble));	
 if(!px)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(px)",function_end);
 py = (IGRdouble *) om$malloc( size = (pnt_anz+1) * sizeof ( IGRdouble));	
 if(!py)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(py)",function_end);
 pz = (IGRdouble *) om$malloc( size = (pnt_anz+1) * sizeof ( IGRdouble));	
 if(!pz)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(pz)",function_end);
 vx = (IGRdouble *) om$malloc( size = (pnt_anz+1) * sizeof ( IGRdouble));	
 if(!vx)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(vx)",function_end);
 vy = (IGRdouble *) om$malloc( size = (pnt_anz+1) * sizeof ( IGRdouble));	
 if(!vy)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(vy)",function_end);
 vz = (IGRdouble *) om$malloc( size = (pnt_anz+1) * sizeof ( IGRdouble));
 if(!vz)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(vz)",function_end);
 l  = (IGRdouble *) om$malloc( size = (pnt_anz+1) * sizeof ( IGRdouble));	
 if(!l)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(l)",function_end);
 w  = (IGRdouble *) om$malloc( size = (pnt_anz+1) * sizeof ( IGRdouble));	
 if(!w)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(w)",function_end);
 kl = (IGRint *) om$malloc( size = (pnt_anz+1) * sizeof ( IGRint));	
 if(!kl)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(kl)",function_end);
 kw = (IGRint *) om$malloc( size = (pnt_anz+1) * sizeof ( IGRint));	
 if(!kw)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(kw)",function_end);
 klz	= 1;
 kwz	= 1;
 for     ( i=0 ; i<pnt_anz ; i=i+1 ) {
   kl[i]	= 1;
   kw[i]	= 1;
 }

 for     ( i=0 ; i<pnt_anz ; i++ ) {
  px[i] = *(bsp_ptr->poles+(3*i));
  py[i] = *(bsp_ptr->poles+(3*i+1));
  pz[i] = *(bsp_ptr->poles+(3*i+2));
 }
 l[0] 	= sqrt((px[1]-px[0])*(px[1]-px[0])+
	     (py[1]-py[0])*(py[1]-py[0])+
	     (pz[1]-pz[0])*(pz[1]-pz[0]));

 vx[i]	= px[i+1]-px[i];
 vy[i]	= py[i+1]-py[i];
 vz[i]	= pz[i+1]-pz[i];

 if( l[i]<EPS1 ) {    /*distance between P[0] und P[1] */
	              /*is less than  EPS1. */
   kl[i] 	= 0;	
   klz	= 0;	      /*one of the distances is less */
 }		      /*than EPS1. */

 for ( i=1 ; i<pnt_anz-1 ; i=i+1 ) {
   vx[i] = px[i+1]-px[i];
   vy[i] = py[i+1]-py[i];
   vz[i] = pz[i+1]-pz[i];
   l[i]  = sqrt((px[i+1]-px[i])*(px[i+1]-px[i])+
	      (py[i+1]-py[i])*(py[i+1]-py[i])+
              (pz[i+1]-pz[i])*(pz[i+1]-pz[i]));
   if( l[i]<EPS1 ) {
     kl[i] = 0;	/*kl[i] = 0 : distance  < EPS1 */
     klz = 0;	/*klz   = 0 : one distance < EPS1 */
     goto for_end;
   }
   if( l[i-1]<EPS1 )
     goto for_end;
   w[i] = vx[i]*vx[i-1]+vy[i]*vy[i-1]+vz[i]*vz[i-1];
   w[i] = w[i]/(l[i]*l[i-1]);
   cw   = w[i];          /*Cosine */ 

   if( (fabs(1-fabs(cw)))<EPS2 ) {
     kw[i] = 0;	/*kw[i] = 0 : angle  is 0 or 180. */
     kwz   = 0;	/*kwz   = 0 : one of the angles is 0 or 180 */
     if ( cw > 0 )  
       w[i]	= 0;		/* angle will be set to 0 */

     if ( cw < 0 )	        /* angle will be set to 180 */
       w[i]	= 180;

     goto for_end;	/* no angle computation */
   }  
 
   w[i] = acos(w[i]);	/* compute angle (Bogenmass)*/
   sw   = sin(w[i]);	/* Sine of angle */
   w[i] = w[i]*180.0/PI;	/* compute angle (Gradmass) */

   if( w[i]<wmin ) {
     wmin   = w[i];
     i_wmin = i;
   }
   if( wmax<w[i] ) {
     wmax   = w[i];
     i_wmax = i;
   }
   if(l[i]<dmin) {
     dmin    = l[i];
     i_dmin  = i;
   }
   if(dmax<l[i]) {
     dmax    = l[i];
     i_dmax  = i;
   }

for_end:
  ;
 }

 sprintf(fmessage,"max angle:%f at %d;min dist:%f at %d", wmax, i_wmax,dmin,i_dmin);
 if(me->mainform_requested)
    put_msg(&me->mainform, M_MSG_F, fmessage);
 if(me->edtform_requested)
    put_msg(&me->edtform, E_MSG_F, fmessage);


function_end:
 if(!px)
  om$dealloc(ptr = px);
 if(!py)
  om$dealloc(ptr = py);
 if(!pz)
  om$dealloc(ptr = pz);
 if(!vx)
  om$dealloc(ptr = vx);
 if(!vy)
  om$dealloc(ptr = vy);
 if(!vz)
  om$dealloc(ptr = vz);
 if(!l)
  om$dealloc(ptr = l);
 if(!w)
  om$dealloc(ptr = w);
 if(!kl)
  om$dealloc(ptr = kl);
 if(!kw)
  om$dealloc(ptr = kw);

 *msg = msg_loc;
 return(stat_OM);
}


method draw_knot(IGRlong *msg; IGRboolean dpmode)
{
 /***draw_knot***/
 /* 
    ABSTRACT  draw knots of a curve

    INPUT     IGRboolean dpmode      -   display mode (foreground, background);

 */
 IGRlong msg_loc, stat_OM;
 IGRint i=0, j=0, k=0;
 IGRdouble uv[2];
 IGRpoint pp;
 struct IGRdisplay mdis;
 struct sknot {
   IGRdouble knot;
   IGRint dup;
   IGRint color;
   IGRint weight;
 } *knots;

 stat_OM = msg_loc = OM_S_SUCCESS;
 strcpy(me->errmsg,"ECascrcr.draw_knot");

 knots = (struct sknot *) om$malloc(size = (me->nknot * sizeof(struct sknot)));
 if(!knots) 
   REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(knots)",function_end);

 knots[0].knot = me->knots[0];
 knots[0].dup = 1;
 /* determine all knots which have identical values (duplicates) */
 for(i=1,j=0;i<me->nknot;i++) {
    if(me->knots[i] == me->knots[i-1]) {
      knots[j].dup += 1;
      knots[j].color = me->cv.sknt_fm.ptmc;
      knots[j].weight = me->cv.sknt_fm.ptmw;
    } else {
      j++; 
      knots[j].color = me->cv.sknt_fm.ptsc;
      knots[j].weight = me->cv.sknt_fm.ptsw;
      knots[j].knot = me->knots[i];
      knots[j].dup = 1;
    }
 }
 j++;
 for(i=0;i<j;i++) {
   uv[0] = knots[i].knot;
   uv[1] = 0.0;
   /* determine point-x-y-z  for u-parameter */
   stat_OM = om$send(msg = message GRvg.EMptatpr(
                           &msg_loc,
                           &me->md_env.md_env.matrix_type,
                           me->md_env.md_env.matrix,
                           uv,
                           1,
                           pp),
                     targetid = me->curve_id.objid,
                     targetos = me->curve_id.osnum);
   TEST_ERROR(stat_OM,msg_loc,"EMptatpr",function_end);

   k = 1;
   mdis = me->active_display;
   mdis.color = (short unsigned)knots[i].color;
   mdis.weight = (IGRuchar) knots[i].weight;
   /* display knot positions */
   stat_OM = ECdisplayPointSetByBuffer(
                         &msg_loc,
                         mdis,
                         me->md_env,
                         my_id,
                         k,
                         pp,
                         dpmode);
 }

 function_end:
   if(knots) 
     om$dealloc(ptr=knots);
   *msg = msg_loc;
   return (stat_OM);
}

method comp_para_vector(IGRlong *msg)  
{
 /* 
    ABSTRACT  compute parameter vector of curve depending on 
              parameter type
 */
  IGRlong rc, msg_loc, stat_OM;
  IGRlong num_ele=0, size=0;
  IGRint i=0, j=0, type=0;
  IGRdouble pav_i=0.0, *ptv, *weight;
  IGRchar x[13];
  struct IGRbsp_curve *crv;

  msg_loc = OM_S_SUCCESS;
  stat_OM = OM_S_SUCCESS; 
  me->XXXXX = 2112;
  /* compute new para vector */
  num_ele = om$dimension_of(varray = me->paras); 
  if (me->npara > num_ele) {
    stat_OM = om$vla_set_dimension(varray = me->paras,
                                   size = me->npara);
    TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",function_end);
  }
  ptv = (IGRdouble *) om$malloc(size = (3*me->nvx) * sizeof(IGRdouble));
  if(!ptv) 
    REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(ptv)",function_end);

  weight = (IGRdouble *) om$malloc(size = (me->nvx) * sizeof(IGRdouble));
  if(!weight) 
    REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(weight)",function_end);
  /* fill point vector */
  for(i=0,j=0;j<me->nvx;j++) {
    ptv[i++] = me->vxt[j].xp;
    ptv[i++] = me->vxt[j].yp;
    ptv[i++] = me->vxt[j].zp;
  }

  /*** find type of parameter to compute 
       if parameter type is free type nothing will be done ***/
  strcpy(x,me->mfp.para_type);
  if(!strncmp(x,EQUIDISTANT_T,strlen(x)))
    type = EQUIDISTANT;
  else if(!strncmp(x,CENTRIPEDAL_T,strlen(x)))
    type = CENTRIPEDAL;
  else if(!strncmp(x,CHORDAL_T,strlen(x))) 
    type = CHORDAL;
  else if(!strncmp(x,PROJECT_T,strlen(x))) 
    type = PROJECT;
  else if(!strncmp(x,AFFIN_INV_T,strlen(x)))
    type = AFFIN_INV;
  else if(!strncmp(x,REF_CURVE_T,strlen(x)))
    type = REF_CURVE;
  else if(!strncmp(x,POWER_T,strlen(x)))
    type = POWER;
  else if(!strncmp(x,NODE_T,strlen(x)))
    type = NODE;

    switch(type) {

    case EQUIDISTANT:

       for(i=0;i<me->nvx;i++)
         me->paras[i] = (IGRdouble) i / (IGRdouble) (me->nvx - 1);
       break;

    case NODE:

      if ( me->nvx==me->mfp.npole )
      {
       IGRdouble tmp; 
       for ( j=0 ; j<me->nvx ; j++ )
       {
        tmp = 0;
        for ( i=j+1 ; i<j+me->mfp.order ; i++ )
         tmp = tmp+me->knots[i];
        me->paras[j] = tmp/(double)(me->mfp.order-1);
       }
      }
      else
      {
       /************************************************************************
       Die Verallgemeinerung ( generalization ) der NODE-Methode fuer
       me->nvx!=me->mfp.npole  muss noch gemacht werden. Das geht aehnlich wie
       die Verallgemeinerung der not a knot Methode.
       Bis diese Verallgemeinerung fertig ist begnuegeb wir mit
       EQUIDISTANT.
       ************************************************************************/
       for(i=0;i<me->nvx;i++)
        me->paras[i] = (IGRdouble) i / (IGRdouble) (me->nvx - 1); 
      }
      break;

    case CENTRIPEDAL:
  
       me->paras[0] = 0.0;
       me->mfp.power = 0.5;
       for(i=1;i<me->nvx;i++) {
         pav_i = sqrt((ptv[3*i]-ptv[3*i-3])*(ptv[3*i]-ptv[3*i-3])+
                      (ptv[3*i+1]-ptv[3*i-2])*(ptv[3*i+1]-ptv[3*i-2])+
                      (ptv[3*i+2]-ptv[3*i-1])*(ptv[3*i+2]-ptv[3*i-1]));
         pav_i = pow(pav_i,me->mfp.power);
         me->paras[i] = me->paras[i-1] + pav_i;
       }

       for(i=0;i<me->nvx;i++) 
         me->paras[i] = me->paras[i] / me->paras[me->nvx-1];

       break;

     case CHORDAL:

       me->paras[0] = 0.0;

       for(i=1;i<me->nvx;i++) {
         pav_i =      (ptv[3*i]-ptv[3*i-3])*(ptv[3*i]-ptv[3*i-3])+
                      (ptv[3*i+1]-ptv[3*i-2])*(ptv[3*i+1]-ptv[3*i-2])+
                      (ptv[3*i+2]-ptv[3*i-1])*(ptv[3*i+2]-ptv[3*i-1]);
         me->paras[i] = me->paras[i-1] + sqrt(pav_i);
       }

       for(i=0;i<me->nvx;i++) 
         me->paras[i] = me->paras[i] / me->paras[me->nvx-1];

       break;

     case POWER:

       me->paras[0] = 0.0;

       for(i=1;i<me->nvx;i++) {
         pav_i = sqrt((ptv[3*i]-ptv[3*i-3])*(ptv[3*i]-ptv[3*i-3])+
                      (ptv[3*i+1]-ptv[3*i-2])*(ptv[3*i+1]-ptv[3*i-2])+
                      (ptv[3*i+2]-ptv[3*i-1])*(ptv[3*i+2]-ptv[3*i-1]));
         pav_i = pow(pav_i,me->mfp.power);
         me->paras[i] = me->paras[i-1] + pav_i;
       }

       for(i=0;i<me->nvx;i++) 
         me->paras[i] = me->paras[i] / me->paras[me->nvx-1];

       break;


       case PROJECT:
       {
          IGRdouble  laenge, laengei, *laen, 
             pnt[3], pnt_lot[3], dist;
          IGRdouble pav_i, *pol, *weight;
          pol = (IGRdouble *) om$malloc(size = (3*me->mfp.npole) * sizeof(IGRdouble));
          if(!pol) 
            REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(pol)",project_end);

          crv = (struct IGRbsp_curve *) stackalloc(sizeof(struct IGRbsp_curve));
          if(!crv) 
            REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(crv)",project_end);


          laen = (IGRdouble *) om$malloc(size = (me->nvx) * sizeof(IGRdouble));
          if(!laen) 
            REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(laen)",project_end);

          weight = (IGRdouble *) om$malloc(size = (me->mfp.npole) * sizeof(IGRdouble));
          if(!weight) 
            REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(weight)",project_end);

          laenge  = 0;
          laen[0] = 0;
          for ( i=1 ; i<me->nvx; i++ )
          {
            laengei = sqrt((me->vxt[i].xp  -me->vxt[i-1].xp)
                         *(me->vxt[i].xp  - me->vxt[i-1].xp)+
                        (me->vxt[i].yp - me->vxt[i-1].yp)
                         *(me->vxt[i].yp-me->vxt[i-1].yp)+
                        (me->vxt[i].zp - me->vxt[i-1].zp)
                         *(me->vxt[i].zp-me->vxt[i-1].zp));
           laenge  = laenge+laengei;
           laen[i] = laen[i-1] + laengei;
          }
	  for ( i=1 ; i<me->nvx; i++)
	   laen[i] = laen[i]/laenge;
 	  for ( i=0 ; i<me->mfp.npole ; i++) {
	     pol[3*i] = (double)(i)/(double)(me->mfp.npole-1);
	     pol[3*i+1] = 0.0;
	     pol[3*i+2] = 0.0;
	  }

          for(i=0;i<me->mfp.npole;i++) 
             weight[i] = 1;

	  crv->order       = me->mfp.order;
          crv->periodic    = 0;
          crv->non_uniform = 1;
          crv->num_poles   = me->mfp.npole;
          crv->poles       = pol;
          crv->num_knots   = (me->mfp.npole + me->mfp.order);
          crv->knots       = me->knots;
          crv->rational    = 1;
          crv->weights     = weight;
          crv->planar      = 0;
          crv->phy_closed  = 0;
          crv->bdrys       = NULL;
	  me->paras[0]     = 0;
	  me->paras[me->nvx-1] = 1;
	  pnt[1] = 0;
	  pnt[2] = 0;
	  for ( i=1 ; i< me->nvx-1 ; i++ ) { 
	   pnt[0] = laen[i];
	   BSmdstptcv(crv,pnt,&pav_i,pnt_lot,&dist,&rc);
           TEST_MATH_ERROR(rc, "BSmdsptcv", project_end);
	   me->paras[i] = pav_i;
	  }
       project_end:
         if(pol) om$dealloc(ptr = pol);
         if(laen) om$dealloc(ptr = laen);
         if(weight) om$dealloc(ptr = weight);
         
	}
	 break;
#if dflT9

     case PROJECT:
       {
          IGRdouble  laenge=0.0, laengei=0.0, *laen,  max_0=0.0, 
                     max_1=0.0, del=0.0,
                     *lae, pnt[3], pnt_lot[3], dist=0.0;
          IGRdouble pav_i=0.0, u=0.0, *ptv, *pol, *weight;


          pol = (IGRdouble *) om$malloc(size = 
                 (3*(me->mfp.npole)) * sizeof(IGRdouble));
          if(!pol) 
            REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(pol)",project_end);

          laen = (IGRdouble *) om$malloc(size = 
                   (me->nvx) * sizeof(IGRdouble));
          if(!laen) 
            REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(laen)",project_end);

          weight = (IGRdouble *) om$malloc(size = 
                    (me->mfp.npole) * sizeof(IGRdouble));
          if(!weight) 
            REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(weight)",project_end);

          crv = (struct IGRbsp_curve *) 
                   stackalloc(sizeof(struct IGRbsp_curve));
          if(!crv) 
            REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"stackalloc(crv)",project_end);

          laenge  = 0;
          laen[0] = 0;
          for ( i=1 ; i<me->nvx; i++ ) {
            laengei = sqrt((me->vxt[i].xp  -me->vxt[i-1].xp)
                         *(me->vxt[i].xp  - me->vxt[i-1].xp)+
                        (me->vxt[i].yp - me->vxt[i-1].yp)
                         *(me->vxt[i].yp-me->vxt[i-1].yp)+
                        (me->vxt[i].zp - me->vxt[i-1].zp)
                         *(me->vxt[i].zp-me->vxt[i-1].zp));
           laenge  = laenge+laengei;
           laen[i] = laen[i-1] + laengei;
          }

	  for ( i=1 ; i<me->nvx; i++)
	   laen[i] = laen[i]/laenge;

          pol[0] = 0.0;
          pol[1] = 0.0;
          pol[2] = 0.0;
          for(i=1; i<me->mfp.npole-1;i++) {
            del = (me->knots[i+me->mfp.order]-me->knots[i])/10.0;
            u = me->knots[i];
            while(1e-6<fabs(del)) {
              do {
                max_0 = bf_nr_2(me->mfp.order, i, me->mfp.npole, &me->knots[0], u);
                u = u + del;
                max_1 = bf_nr_2(me->mfp.order, i, me->mfp.npole, &me->knots[0], u);
              } while(max_0<max_1);
              del = -del/10.0;
            } 
            pol[3*i] = u;
            pol[3*i+1] = 0.0;
            pol[3*i+2] = 0.0;
          }
          pol[3*(me->mfp.npole-1)] = 1.0;
          pol[3*(me->mfp.npole-1)+1] = 0.0;
          pol[3*(me->mfp.npole-1)+2] = 0.0;

          for(i=0;i<me->mfp.npole;i++) 
             weight[i] = 1;

	  crv->order       = me->mfp.order;
          crv->periodic    = 0;
          crv->non_uniform = 1;
          crv->num_poles   = me->mfp.npole;
          crv->poles       = pol;
          crv->num_knots   = (me->mfp.npole + me->mfp.order);
          crv->knots       = me->knots;
          crv->rational    = 1;
          crv->weights     = weight;
          crv->planar      = 0;
          crv->phy_closed  = 0;
          crv->bdrys       = NULL;
	  me->paras[0]     = 0;
	  me->paras[me->nvx-1] = 1;
	  pnt[1] = 0;
	  pnt[2] = 0;
	  for ( i=1 ; i< me->nvx-1 ; i++ ) { 
	   pnt[0] = laen[i];
	   BSmdstptcv(crv ,pnt,&pav_i,pnt_lot,&dist,&rc);
           TEST_MATH_ERROR(rc,"BSmdstptcv",project_end);
	   me->paras[i] = pav_i;
	  }
       project_end:
         *msg = msg_loc;
         if(weight) om$dealloc(ptr = weight);
         if(laen) om$dealloc(ptr = laen);
         if(pol) om$dealloc(ptr = pol);
	}
	 break;

#endif

     case REF_CURVE:
       {
         IGRdouble  laenge=0.0, laengei=0.0, *laen, 
             *lae, pnt[3], pnt_lot[3], dist=0.0;
         IGRdouble *pol;
         if(me->wrong_element) { 
            me->wrong_element = FALSE;
            stat_OM = OM_E_ABORT;
            goto ref_end;
         }
         stat_OM = om$send( msg = message GRvg.GRgetsize(
                                  &msg_loc,
                                  &me->md_env.md_env.matrix_type,
                                  me->md_env.md_env.matrix,
                                  &size ),
                            targetos = me->ref_curve_id.osnum,
                            targetid = me->ref_curve_id.objid );
         TEST_ERROR(stat_OM,msg_loc,"GRgetsize",ref_end);

         crv = (struct IGRbsp_curve *) stackalloc( size );
         if(!crv) 
           REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"stackalloc(crv)",ref_end);
 
         stat_OM = om$send( msg = message GRvg.GRgetgeom(
                                  &msg_loc,
                                  &me->md_env.md_env.matrix_type,
                                  me->md_env.md_env.matrix,
                                  (IGRchar *)crv),
                            targetos = me->ref_curve_id.osnum,
                            targetid = me->ref_curve_id.objid );

#if dflT1
 for(i=0,j=0;j<crv->num_poles;i+=3,j++) 
  printf("pole_no %d  %f %f %f\n", j, *(crv->poles + i + X),
                                      *(crv->poles + i + Y),
                                      *(crv->poles + i + Z));
#endif

        laen = (IGRdouble *) om$malloc(size = (me->nvx) * sizeof(IGRdouble));
        if(!laen) 
          REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(laen)",ref_end);

        lae = (IGRdouble *) om$malloc(size = (crv->num_poles) * sizeof(IGRdouble));
        if(!lae) 
          REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(lae)",ref_end);

        pol = (IGRdouble *) om$malloc(size = (3*crv->num_poles) * sizeof(IGRdouble));
        if(!pol) 
          REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(pol)",ref_end);
/*}break;}
#if dflT12*/

        laenge  = 0;
        laen[0] = 0;
        for ( i=1 ; i<me->nvx; i++ )
        {
         laengei = sqrt((me->vxt[i].xp  -me->vxt[i-1].xp)
                         *(me->vxt[i].xp  - me->vxt[i-1].xp)+
                        (me->vxt[i].yp - me->vxt[i-1].yp)
                         *(me->vxt[i].yp-me->vxt[i-1].yp)+
                        (me->vxt[i].zp - me->vxt[i-1].zp)
                         *(me->vxt[i].zp-me->vxt[i-1].zp));
         laenge  = laenge+laengei;
         laen[i] = laen[i-1] + laengei;
        }
	for ( i=1 ; i<me->nvx; i++)
	 laen[i] = laen[i]/laenge;
	for ( i=0 ; i<3*crv->num_poles ; i=i+1 )
         pol[i] = crv->poles[i];
	laenge  = 0;
        lae[0] = 0;
        for ( i=1 ; i<crv->num_poles; i=i+1 )
        {
         laengei = sqrt((pol[3*i]  - pol[3*i-3])*(pol[3*i]  -pol[3*i-3])+
                        (pol[3*i+1]-pol[3*i-2])*(pol[3*i+1]-pol[3*i-2])+
                        (pol[3*i+2]-pol[3*i-1])*(pol[3*i+2]-pol[3*i-1]));
         laenge = laenge+laengei;
         lae[i] = lae[i-1] + laengei;
        }
	for ( i=0 ; i<crv->num_poles ; i++ )
	{
	 pol[3*i] = lae[i]/laenge;
	 pol[3*i+1] = 0;
	 pol[3*i+2] = 0;
	}
	/*knot_anz = crv->num_knots;
	for ( i=0 ; i<knot_anz ; i=i+1 )
         knot[i] = *( crv->knots+(i));
	crv->order       = ord;
        crv->periodic    = 0;
        crv->non_uniform = 1;
        crv->num_poles   = anz;*/
        crv->poles       = (double *)pol;
        /*crv->num_knots   = (anz+ord);
        crv->knots       = (double *)knot;
        crv->rational    = 1;
        crv->weights     = (double *)weight;
        crv->planar      = 0;
        crv->phy_closed  = 0;
        crv->bdrys       = NULL;*/
        pnt[1] = 0;
        pnt[2] = 0;
	me->paras[0] = 0;
	me->paras[me->nvx-1] = 1;
	i = 0;
	/*fprintf(stderr,"\nlaen[%d] = %8.4f",i,laen[i]);
	fprintf(stderr,"  u_par[%d] = %8.4f",i,u_par[i]);*/
	for ( i=1 ; i< me->nvx-1 ; i++ )
        {
         pnt[0] = laen[i];
         /*fprintf(stderr,"\nlaen[%d] = %8.4f",i,laen[i]);*/
         BSmdstptcv(crv,pnt,&laenge,pnt_lot,&dist,&rc);
         TEST_MATH_ERROR(rc,"BSmdstptcv",ref_end);
         me->paras[i] = laenge;
         /*fprintf(stderr,"  u_par[%d] = %8.4f",i,u_par[i]);*/
        }
        strcpy(me->mfp.para_type,FREE_T);
        FIg_set_text(me->mainform,M_PARA_F,me->mfp.para_type);
        me->reference_curve = FALSE;
     ref_end:
        if(*msg == OM_E_ABORT)
           strcpy(me->mfp.para_type,me->old_para_type);          
        if(laen) om$dealloc(ptr=laen);
        if(lae) om$dealloc(ptr=lae);
        if(pol) om$dealloc(ptr=pol);
       }
         
         break;



     case AFFIN_INV:
     {
      #define   EPS 1e-4
      #define   PI  3.141592654
      IGRint    cod=0, r_p=0, r_l=0, r_e=0, r_r=0, x_l=0, 
                y_l=0, z_l=0, x_p=0, y_p=0, z_p=0;  
      IGRint    x_e=0, y_e=0, z_e=0, x_r=0, y_r=0, z_r=0;  
      IGRdouble xq=0.0, yq=0.0, zq=0.0, s_xx=0.0, 
                s_xy=0.0, s_yy=0.0, s_yz=0.0, s_zz=0.0, s_zx=0.0;
      IGRdouble det=0.0, err=0.0, tmp=0.0, f=0.0, q[6];
      IGRdouble *pbp, *pnp, *d, *dq, *laen, *phi, *h;
      IGRpoint  p_av;
      IGRvector vec_x, vec_y, vec_z, v_dum;
      pbp  = (IGRdouble *) om$malloc(size = 3*me->nvx * sizeof(IGRdouble));
      if(!pbp)
          REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(pbp)",lych_end);
      pnp  = (IGRdouble *) om$malloc(size = 3*me->nvx * sizeof(IGRdouble));
      if(!pnp)
          REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(pnp)",lych_end);
      dq   = (IGRdouble *) om$malloc(size = me->nvx   * sizeof(IGRdouble));
      if(!dq)
          REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(dq)",lych_end);
      laen = (IGRdouble *) om$malloc(size = me->nvx   * sizeof(IGRdouble));
      if(!laen)
          REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(laen)",lych_end);
      phi  = (IGRdouble *) om$malloc(size = me->nvx   * sizeof(IGRdouble));
      if(!phi)
          REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(phi)",lych_end);
      h    = (IGRdouble *) om$malloc(size = me->nvx   * sizeof(IGRdouble));
      if(!h)
          REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(h)",lych_end);
      d    = (IGRdouble *) om$malloc(size = (1+3*me->nvx)*sizeof(IGRdouble));
      if(!d)
          REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(d)",lych_end);

      xq = 0.0;
      yq = 0.0;
      zq = 0.0;
      for ( i=0 ; i<me->nvx ; i=i+1 )
      {
       xq = xq + ptv[3*i];
       yq = yq + ptv[3*i+1];
       zq = zq + ptv[3*i+2];
      }
      xq   = xq/(double)(me->nvx);
      yq   = yq/(double)(me->nvx);
      zq   = zq/(double)(me->nvx);
#if dflT7
      fprintf(stderr,"\nxq = %12.6f",xq);
      fprintf(stderr,"  yq = %12.6f",yq);
      fprintf(stderr,"  zq = %12.6f",zq);
#endif
      s_xx = 0.0;
      s_yy = 0.0;
      s_zz = 0.0;
      s_xy = 0.0;
      s_yz = 0.0;
      s_zx = 0.0;
      for ( i=0 ; i<me->nvx ; i=i+1 )
      {
       s_xx = s_xx + (ptv[3*i]  -xq)*(ptv[3*i]  -xq);
       s_yy = s_yy + (ptv[3*i+1]-yq)*(ptv[3*i+1]-yq);
       s_zz = s_zz + (ptv[3*i+2]-zq)*(ptv[3*i+2]-zq);
       s_xy = s_xy + (ptv[3*i]  -xq)*(ptv[3*i+1]-yq);
       s_yz = s_yz + (ptv[3*i+1]-yq)*(ptv[3*i+2]-zq);
       s_zx = s_zx + (ptv[3*i+2]-zq)*(ptv[3*i]  -xq);
      }
#if dflT7
      fprintf(stderr,"\ns_xx = %12.6f",s_xx);
      fprintf(stderr,"  s_yy = %12.6f",s_yy);
      fprintf(stderr,"  s_zz = %12.6f",s_zz);
      fprintf(stderr,"\ns_xy = %12.6f",s_xy);
      fprintf(stderr,"  s_yz = %12.6f",s_yz);
      fprintf(stderr,"  s_zx = %12.6f",s_zx);
#endif
      s_xx = s_xx/(double)(me->nvx);
      s_yy = s_yy/(double)(me->nvx);
      s_zz = s_zz/(double)(me->nvx);
      s_xy = s_xy/(double)(me->nvx);
      s_yz = s_yz/(double)(me->nvx);
      s_zx = s_zx/(double)(me->nvx);
#if dflT7
      fprintf(stderr,"\ns_xx = %12.6f",s_xx);
      fprintf(stderr,"  s_yy = %12.6f",s_yy);
      fprintf(stderr,"  s_zz = %12.6f",s_zz);
      fprintf(stderr,"\ns_xy = %12.6f",s_xy);
      fprintf(stderr,"  s_yz = %12.6f",s_yz);
      fprintf(stderr,"  s_zx = %12.6f",s_zx);
      fprintf(stderr,"\n*****************************  Glatthei");
      fprintf(stderr,"tstest    *******************************");
      fprintf(stderr,"\nTest im Raum !");
#endif
      BSlsqptlnpl(me->nvx, &ptv[0], NULL, 3, &cod, p_av, vec_z, &err, &rc);
      TEST_MATH_ERROR(rc,"BSlsqptlnpl",lych_end);
      r_p = r_l = r_e = r_r = 0;
      x_p = x_l = x_e = x_r = 0;
      y_p = y_l = y_e = y_r = 0;
      z_p = z_l = z_e = z_r = 0;
      switch ( (int)(cod) )
      {
       case 1:
        r_p = 1;
       break;
       case 2:
        r_l = 1;
       break;
       case 3:
        r_e = 1;
       break;
       case 4:
        r_r = 1;
       break;
       default:
        fprintf(stderr,"\nCase default ist eingetreten !");
        fprintf(stderr,"\nAFFIN_INV - 1 Fehler im Programm !");
       break; 
      }
      for ( i=0 ; i<me->nvx ; i=i+1 )
      {
       pbp[3*i]   = 0.0;
       pbp[3*i+1] = ptv[3*i+1];
       pbp[3*i+2] = ptv[3*i+2];
      }
      BSlsqptlnpl(me->nvx, &pbp[0], NULL, 3, &cod, p_av, v_dum, &err, &rc);
      TEST_MATH_ERROR(rc,"BSlsqptlnpl",lych_end);
      switch ( (int)(cod) )
      {
       case 1:
        x_p = 1;
       break;
       case 2:
        x_l = 1;
       break;
       case 3:
        x_e = 1;
       break;
       case 4:
        x_r = 1;
       break;
       default:
        fprintf(stderr,"\nCase default ist eingetreten !");
        fprintf(stderr,"\nLyche - 2 Fehler im Programm !");
       break; 
      }
      for ( i=0 ; i<me->nvx ; i=i+1 )
      {
       pbp[3*i]   = ptv[3*i];
       pbp[3*i+1] = 0.0;
       pbp[3*i+2] = ptv[3*i+2];
      }
      BSlsqptlnpl(me->nvx, &pbp[0], NULL, 3, &cod, p_av, v_dum, &err, &rc);
      TEST_MATH_ERROR(rc,"BSlsqptlnpl",lych_end);
      switch ( (int)(cod) )
      {
       case 1:
        y_p = 1;
       break;
       case 2:
        y_l = 1;
       break;
       case 3:
        y_e = 1;
       break;
       case 4:
        y_r = 1;
       break;
       default:
        fprintf(stderr,"\nCase default ist eingetreten !");
        fprintf(stderr,"\nLyche - 3 Fehler im Programm !");      
       break;
      }
      for ( i=0 ; i<me->nvx ; i=i+1 )
      {
       pbp[3*i]   = ptv[3*i];
       pbp[3*i+1] = ptv[3*i+1];
       pbp[3*i+2] = 0.0;
      }
      BSlsqptlnpl(me->nvx, &pbp[0], NULL, 3, &cod, p_av, v_dum, &err, &rc);
      TEST_MATH_ERROR(rc,"BSlsqptlnpl",lych_end);
      switch ( (int)(cod) )
      {
       case 1:
        z_p = 1;
       break;
       case 2:
        z_l = 1;
       break;
       case 3:
        z_e = 1;
       break;
       case 4:
        z_r = 1;
       break;
       default:
        fprintf(stderr,"\nCase default ist eingetreten !");
        fprintf(stderr,"\nLyche - 4 Fehler im Programm !");
       break;
      }
#if dflT7
      fprintf(stderr,"\nr_p = %d",r_p); /* Punkt im Raum */
      fprintf(stderr,"  r_l = %d",r_l); /* Linie im Raum */
      fprintf(stderr,"  r_e = %d",r_e); /* Ebene im Raum */
      fprintf(stderr,"  r_r = %d",r_r); /* echter 3-D LS */
      fprintf(stderr,"\nx_p = %d",x_p); /* Punkt in der y-z-Ebene */
      fprintf(stderr,"  x_l = %d",x_l); /* Linie in der y-z-Ebene */
      fprintf(stderr,"  x_e = %d",x_e); /* Ebene in der y-z-Ebene */
      fprintf(stderr,"  x_r = %d",x_r); /* 3-D LS in der y-z-Ebene */
      fprintf(stderr,"\ny_p = %d",y_p); /* Punkt in der z-x-Ebene */
      fprintf(stderr,"  y_l = %d",y_l); /* Linie in der z-x-Ebene */
      fprintf(stderr,"  y_e = %d",y_e); /* Ebene in der z-x-Ebene */
      fprintf(stderr,"  y_r = %d",y_r); /* 3-D LS in der z-x-Ebene */
      fprintf(stderr,"\nz_p = %d",z_p); /* Punkt in der x-y-Ebene */
      fprintf(stderr,"  z_l = %d",z_l); /* Linie in der x-y-Ebene */
      fprintf(stderr,"  z_e = %d",z_e); /* Ebene in der x-y-Ebene */
      fprintf(stderr,"  z_r = %d",z_r); /* 3-D LS in der x-y-Ebene */

      if ( r_p )
       fprintf(stderr,"\nPunkt im Raum !");
      if ( r_l )
       fprintf(stderr,"\nLinie im Raum !");
      if ( r_e )
       fprintf(stderr,"\nEbene im Raum !");
      if ( r_r )
       fprintf(stderr,"\nechter 3-D LS !");
      if ( x_p )
       fprintf(stderr,"\nPunkt in der y-z-Ebene !");
      if ( x_l )
       fprintf(stderr,"\nLinie in der y-z-Ebene !");
      if ( x_e )
       fprintf(stderr,"\nEbene in der y-z-Ebene !");
      if ( x_r )
       fprintf(stderr,"\n3-D LS in der y-z-Ebene !");
      if ( y_p )
       fprintf(stderr,"\nPunkt in der z-x-Ebene !");
      if ( y_l )
       fprintf(stderr,"\nLinie in der z-x-Ebene !");
      if ( y_e )
       fprintf(stderr,"\nEbene in der z-x-Ebene !");
      if ( y_r )
       fprintf(stderr,"\n3-D LS in der z-x-Ebene !");
      if ( z_p )
       fprintf(stderr,"\nPunkt in der x-y-Ebene !");
      if ( z_l )
       fprintf(stderr,"\nLinie in der x-y-Ebene !");
      if ( z_e )
       fprintf(stderr,"\nEbene in der x-y-Ebene !");
      if ( z_r )
       fprintf(stderr,"\n3-D LS in der x-y-Ebene !");
      if ( r_e*(x_e*y_e+y_e*z_e+z_e*x_e) )
      {
       fprintf(stderr,"\nDer Linestring ist eben.\nDiese Ebene liegt ");
       fprintf(stderr," nicht parallel zu einer Koordinatenebene !");
      }
      fprintf(stderr,"\nvec_z = ");
      for ( i=0 ; i<3 ; i=i+1 )
       fprintf(stderr,"%12.6f",vec_z[i]);
      fprintf(stderr,"\n************************   Ende des Glat");
      fprintf(stderr,"theitstest  ****************************\n");
#endif
      if ( r_e*(x_e*y_e+y_e*z_e+z_e*x_e) )
      {
       /* Der Linestring ist eben */
       /* Diese Ebene liegt nicht parallel zu einer Koordinatenebene ! */
#if dflT1
       fprintf(stderr,"\nDer Linestring ist eben !\nDiese Ebene ");
       fprintf(stderr," liegt nicht parallel zu einer Koordinatenebene !");
#endif
       r_e = 0;
       r_r = 0;
       tmp = 0;
       for ( i=0 ; i<3 ; i=i+1 )
        tmp = tmp + vec_z[i]*vec_z[i];
       tmp = sqrt(tmp);
#if dflT7
       fprintf(stderr,"\na - tmp = %12.6f",tmp);
#endif
       for ( i=0 ; i<3 ; i=i+1 )
        vec_z[i] = vec_z[i]/tmp;
       if ( fabs(vec_z[1])<fabs(vec_z[2]) )
       {
        vec_x[0] =  1;
        vec_x[1] = -vec_z[0]/vec_z[1];
        vec_x[2] =  0;
       }
       else
       {
        vec_x[0] = -vec_z[1]/vec_z[0];
        vec_x[1] =  1;
        vec_x[2] =  0;
       }
       tmp = 0;
       for ( i=0 ; i<2 ; i=i+1 )
        tmp = tmp + vec_x[i]*vec_x[i];
       tmp = sqrt(tmp);
#if dflT7
       fprintf(stderr,"\nb - tmp = %12.6f",tmp);
#endif
       for ( i=0 ; i<2 ; i=i+1 )
        vec_x[i] = vec_x[i]/tmp;
       vec_y[0] = vec_z[1]*vec_x[2] - vec_z[2]*vec_x[1];
       vec_y[1] = vec_z[2]*vec_x[0];
       vec_y[2] = vec_z[0]*vec_x[1] - vec_z[1]*vec_x[0];
       tmp = 0;
       for ( i=0 ; i<3 ; i=i+1 )
        tmp = tmp + vec_y[i]*vec_y[i];
       tmp = sqrt(tmp);
       for ( i=0 ; i<3 ; i=i+1 )
        vec_y[i] = vec_y[i]/tmp;
#if dflT7
       for ( i=0 ; i<3 ; i=i+1 )
       {
        fprintf(stderr,"\n");
        fprintf(stderr,"%12.6f",vec_x[i]);
        fprintf(stderr,"%12.6f",vec_y[i]);
        fprintf(stderr,"%12.6f",vec_z[i]);
       }
#endif
       for ( j=0 ; j<me->nvx ; j=j+1 )
       {
        for ( i=0 ; i<6 ; i=i+1 )
         q[i] = 0.0;
        for ( i=0 ; i<3 ; i=i+1 )
        {
         q[0] = q[0] + vec_x[i]*vec_x[i];
         q[1] = q[1] + vec_x[i]*vec_y[i];
         q[2] = q[1];
         q[3] = q[3] + vec_y[i]*vec_y[i];
         q[4] = q[4] + ptv[3*j+i]*vec_x[i];
         q[5] = q[5] + ptv[3*j+i]*vec_y[i];
        }
#if dflT7
        fprintf(stderr,"\nq - j = %2d",j);
        fprintf(stderr,"\n%12.6f",q[0]);
        fprintf(stderr,"  %12.6f",q[1]);
        fprintf(stderr,"  %12.6f",q[4]);
        fprintf(stderr,"\n%12.6f",q[2]);
        fprintf(stderr,"  %12.6f",q[3]);
        fprintf(stderr,"  %12.6f",q[5]);
#endif
       }
       for ( j=0 ; j<me->nvx ; j=j+1 )
       {
        pnp[3*j]   = 0;
        pnp[3*j+1] = 0;
        for ( i=0 ; i<3 ; i=i+1 )
        {
         pnp[3*j]   = pnp[3*j]   + ptv[3*j+i] * vec_x[i];
         pnp[3*j+1] = pnp[3*j+1] + ptv[3*j+i] * vec_y[i];
        }
#if dflT7
        fprintf(stderr,"\npnp[%2d]  %12.6f",j,pnp[3*j]);
        fprintf(stderr,"  %12.6f",pnp[3*j+1]);
#endif
       }
#if dflT7
       fprintf(stderr,"\n");
#endif
       xq = 0.0;
       yq = 0.0;
       for ( i=0 ; i<me->nvx ; i=i+1 )
       {
        xq = xq + ptv[3*i];
        yq = yq + ptv[3*i+1];
       }
       xq   = xq/(double)(me->nvx);
       yq   = yq/(double)(me->nvx);
#if dflT7
       fprintf(stderr,"\nxq = %12.6f",xq);
       fprintf(stderr,"  yq = %12.6f",yq);
#endif
       s_xx = 0.0;
       s_yy = 0.0;
       s_xy = 0.0;
       for ( i=0 ; i<me->nvx ; i=i+1 )
       {
        s_xx = s_xx + (ptv[3*i]  -xq)*(ptv[3*i]  -xq);
        s_yy = s_yy + (ptv[3*i+1]-yq)*(ptv[3*i+1]-yq);
        s_xy = s_xy + (ptv[3*i]  -xq)*(ptv[3*i+1]-yq);
       }
       s_xx = s_xx/(double)(me->nvx);
       s_yy = s_yy/(double)(me->nvx);
       s_xy = s_xy/(double)(me->nvx);
#if dflT7
       fprintf(stderr,"\ns_xx = %12.6f",s_xx);
       fprintf(stderr,"  s_yy = %12.6f",s_yy);
       fprintf(stderr,"\ns_xy = %12.6f",s_xy);
#endif
       det  =  s_xx*s_yy-s_xy*s_xy;
#if dflT7
       fprintf(stderr,"\ndet = %12.8f",det);
#endif
       if ( fabs(det)<1e-6 )
        goto lych_end;
       q[0] =  s_yy/det;
       q[1] = -s_xy/det;
       q[2] =  0.0;
       q[3] =  s_xx/det;
       q[4] =  0.0;
       q[5] =  1.0;
      }
      if ( r_r || r_e )
      {
       if ( r_r )
       {
        /* Raeumlicher 3-dimensionaler Linestring */
#if dflT7
        fprintf(stderr,"\nRaeumlicher 3-dimensionaler Linestring !");
#endif
        r_e = 0;
        det  =  s_xx*(s_yy*s_zz-s_yz*s_yz);
        det  =  det - s_xy*(s_xy*s_zz-s_yz*s_zx);
        det  =  det + s_zx*(s_xy*s_yz-s_yy*s_zx);
#if dflT7
        fprintf(stderr,"\ndet = %12.8f",det);
#endif
        if ( fabs(det)<1e-6 )
         goto lych_end;
        q[0] =  (s_yy*s_zz-s_yz*s_yz)/det;
        q[1] = -(s_xy*s_zz-s_yz*s_zx)/det;
        q[2] =  (s_xy*s_yz-s_yy*s_zx)/det;
        q[3] =  (s_xx*s_zz-s_zx*s_zx)/det;
        q[4] = -(s_xx*s_yz-s_xy*s_zx)/det;
        q[5] =  (s_xx*s_yy-s_xy*s_xy)/det;
       }
       if ( r_e==1 )
       {
        /* Der Linestring ist eben */
        /* Diese Ebene liegt parallel zu einer Koordinatenebene */
#if dflT7
        fprintf(stderr,"\nDer Linestring ist eben !\nDiese Ebene ");
        fprintf(stderr," liegt parallel zu einer Koordinatenebene !");
#endif
        if ( x_e&&y_l&&z_l )
        {
         /* gruen */
#if dflT7
         fprintf(stderr,"\nDie Linestringebene liegt parallel zur");
         fprintf(stderr,"\ny-z-Ebene des Koordinatensystems !");
#endif
         det  =  s_yy*s_zz-s_yz*s_yz;
#if dflT7
         fprintf(stderr,"\ndet = %12.8f",det);
#endif
         if ( fabs(det)<1e-6 )
          goto lych_end;
         q[0] =  1.0;
         q[1] =  0.0;
         q[2] =  0.0;
         q[3] =  s_zz/det;
         q[4] = -s_yz/det;
         q[5] =  s_yy/det;
        }
        if ( x_l&&y_e&&z_l )
        {
         /* rot */
#if dflT7
         fprintf(stderr,"\nDie Linestringebene liegt parallel zur");
         fprintf(stderr,"\nz-x-Ebene des Koordinatensystems !");
#endif
         det  = s_xx*s_zz-s_zx*s_zx;
#if dflT7
         fprintf(stderr,"\ndet = %12.8f",det);
#endif
         if ( fabs(det)<1e-6 )
          goto lych_end;
         q[0] =  s_zz/det;
         q[1] =  0.0;
         q[2] = -s_zx/det;
         q[3] =  1.0;
         q[4] =  0.0;
         q[5] =  s_xx/det;
        }
        if ( x_l&&y_l&&z_e )
        {
         /* gelb */
#if dflT7
         fprintf(stderr,"\nDie Linestringebene liegt parallel zur");
         fprintf(stderr,"\nx-y-Ebene des Koordinatensystems !");
#endif
         det  =  s_xx*s_yy-s_xy*s_xy;
#if dflT7
         fprintf(stderr,"\ndet = %12.8f",det);
#endif
         if ( fabs(det)<1e-6 )
          goto lych_end;
         q[0] =  s_yy/det;
         q[1] = -s_xy/det;
         q[2] =  0.0;
         q[3] =  s_xx/det;
         q[4] =  0.0;
         q[5] =  1.0;
        }
       }
      }
#if dflT7
      fprintf(stderr,"\nBeginn der Parameterberechnung !\n");
      for ( i=0 ; i<3 ; i=i+1 )
       fprintf(stderr,"  q[%d] = %12.6f",i,q[i]);
      fprintf(stderr,"\n                     ");
      for ( i=3 ; i<5 ; i=i+1 )
       fprintf(stderr,"  q[%d] = %12.6f",i,q[i]);
      fprintf(stderr,"\n                      ");
      fprintf(stderr,"                      ");
      fprintf(stderr,"q[5] = %12.6f",q[5]);
#endif
      d[0]  = 0.0;
      dq[0] = 0.0;
#if dflT7
      fprintf(stderr,"\ndq\n");
#endif
      for ( i=1 ; i<me->nvx ; i=i+1 )
      {
       dq[i] =             ( ptv[3*i]   - ptv[3*i-3])
               * ( q[0]  * ( ptv[3*i]   - ptv[3*i-3])
                +  q[1]  * ( ptv[3*i+1] - ptv[3*i-2])
                +  q[2]  * ( ptv[3*i+2] - ptv[3*i-1]) )
                +          ( ptv[3*i+1] - ptv[3*i-2])
               * ( q[1]  * ( ptv[3*i]   - ptv[3*i-3])
                +  q[3]  * ( ptv[3*i+1] - ptv[3*i-2])
                +  q[4]  * ( ptv[3*i+2] - ptv[3*i-1]) )
                +          ( ptv[3*i+2] - ptv[3*i-1])
               * ( q[2]  * ( ptv[3*i]   - ptv[3*i-3])
                +  q[4]  * ( ptv[3*i+1] - ptv[3*i-2])
                +  q[5]  * ( ptv[3*i+2] - ptv[3*i-1]) );
       d[i] = sqrt(dq[i]);
#if dflT7
       if ( i%5==1 )
        fprintf(stderr,"\n%2d",i);
       fprintf(stderr,"%12.8f",d[i]);
#endif
      }
      f = 1.5;
      laen[0] = 0.0;
      d[me->nvx]  = 0.0;
/*
      phi[0]     = PI/2;
      phi[me->nvx-1] = PI/2;
*/
      phi[0]     = 0.0;
      phi[me->nvx-1] = 0.0;
      for ( i=1 ; i<me->nvx-1 ; i=i+1 )
      {
       phi[i] =            ( ptv[3*i+3] - ptv[3*i-3])
               * ( q[0]  * ( ptv[3*i+3] - ptv[3*i-3])
                +  q[1]  * ( ptv[3*i+4] - ptv[3*i-2])
                +  q[2]  * ( ptv[3*i+5] - ptv[3*i-1]) )
                +          ( ptv[3*i+4] - ptv[3*i-2])
               * ( q[1]  * ( ptv[3*i+3] - ptv[3*i-3])
                +  q[3]  * ( ptv[3*i+4] - ptv[3*i-2])
                +  q[4]  * ( ptv[3*i+5] - ptv[3*i-1]) )
                +          ( ptv[3*i+5] - ptv[3*i-1])
               * ( q[2]  * ( ptv[3*i+3] - ptv[3*i-3])
                +  q[4]  * ( ptv[3*i+4] - ptv[3*i-2])
                +  q[5]  * ( ptv[3*i+5] - ptv[3*i-1]) );
       phi[i] = (dq[i] + dq[i+1] - phi[i])/(2*sqrt(dq[i]*dq[i+1]));
       if ( phi[i]<EPS-1 )
       {
#if dflT7
        fprintf(stderr,"\n   phi[%2d]<EPS-1          phi[%2d] = %8.4f",
                                    i,i,phi[i]);
#endif
        phi[i] = 0.0;
        goto phi_14;
       }
       else if ( -1<phi[i] && phi[i]<EPS )
       {
#if dflT7
        fprintf(stderr,"\n-1<phi[%2d] && phi[%d]<EPS phi[%2d] = %8.4f",
                                     i,i,i,phi[i]);
#endif
        phi[i] = PI-acos(phi[i]);
        goto phi_14;
       }
       else if ( 0<phi[i] )
        phi[i] = PI/2;    

phi_14:
       ;
#if dflT7
       fprintf(stderr,"  phi[%2d] = %8.4f",i,phi[i]);
#endif
      }
#if dflT7
      for ( i=0 ; i<me->nvx ; i=i+1 )
      {
       if ( i%3==0 )
        fprintf(stderr,"\n");
       fprintf(stderr,"  phi[%2d] = %12.6f",i,phi[i]);
      }
      fprintf(stderr,"\nh ******************** ");
#endif
      for ( i=1 ; i<me->nvx ; i=i+1 )
      {
#if dflT7
       fprintf(stderr,"\n%2d",i);
#endif
       h[i] = f*phi[i]*d[i+1]/(d[i]+d[i+1]);
#if dflT7
       fprintf(stderr," a %8.4f",h[i]);
#endif
       h[i] = h[i] + f*phi[i-1]*d[i-1]/(d[i-1]+d[i]);
#if dflT7
       fprintf(stderr," b %8.4f",h[i]);
#endif
       h[i] = d[i]*(1+h[i]);
#if dflT7
       fprintf(stderr," c %8.4f",h[i]);
#endif
       laen[i] = laen[i-1] + h[i];
#if dflT7
       fprintf(stderr," d %8.4f",laen[i]);
#endif
      }
      for ( i=0 ; i<me->nvx ; i=i+1 )
       me->paras[i] = laen[i]/laen[me->nvx-1];
lych_end:
      if(pbp) om$dealloc(ptr = pbp);
      if(pnp) om$dealloc(ptr = pnp);
      if(dq) om$dealloc(ptr = dq);
      if(laen) om$dealloc(ptr = laen);
      if(phi) om$dealloc(ptr = phi);
      if(h) om$dealloc(ptr = h);
      if(d) om$dealloc(ptr = d);
     }

         break;


       default:
         break;
     }

function_end:
 *msg = msg_loc;
 if(weight) om$dealloc(ptr=weight);
 if(ptv) om$dealloc(ptr=ptv);
/*#endif*/
 return (stat_OM);
}

method comp_knot_vector(IGRlong *msg)
{
 /***comp_knots***/
 /* 
    ABSTRACT  compute knot vector of curve depending on knot type
 */

 IGRlong stat_OM, msg_loc;
 IGRlong size=0;
 IGRint send_message=0, type=0;
 IGRint i=0, j=0;
 IGRchar imsg[MSG_F_L], x[13];
 IGRlong num_ele=0.0;
 IGRdouble tmp=0.0; 
 struct IGRbsp_curve *crv;

    /* look if the curve parameters are correct; otherwise change
       ncon = number of constraints
       npole   = number of poles
       nspans  = number of spans
       order   = curve order
       nfp     = number of fix points
       nta     = number of tangents
       opt_curv0 = determines if curvature in start point is defined 
       opt_curv1 = determines if curvature in end point is defined 
    */
    send_message = 0;
    stat_OM = msg_loc = *msg = OM_S_SUCCESS;

    if (me->ncon > me->mfp.npole) {
       me->mfp.npole = me->ncon;
       me->mfp.nspans  = me->mfp.npole  - me->mfp.order + 1;
       FIg_set_value(me->mainform,M_SPANS_F,(double) me->mfp.nspans);
       FIg_set_value(me->mainform,M_POLES_F,(double) me->mfp.npole);

       if (!strncmp(me->mfp.knot_type,FREE_T,strlen(me->mfp.knot_type))) {
          strcpy(me->mfp.knot_type,UNIFORM_T);
          if(me->mainform_requested)
            FIg_set_text(me->mainform,M_KNOT_F,me->mfp.knot_type);
       }
       strcpy(imsg,POLES_SPANS);
       send_message = 1;
    }

    strcpy(x,me->mfp.knot_type);
    if(!strncmp(x,FREE_T,strlen(x))) 
      return(OM_S_SUCCESS);
    /* compute new knot vector */
      me->nknot = me->mfp.npole + me->mfp.order;
    /*me->nknot = 2 * me->mfp.order + me->mfp.nspans - 1;*/
    num_ele = om$dimension_of(varray = me->knots); 
    if (me->nknot > num_ele) {
      stat_OM = om$vla_set_dimension(varray = me->knots,
                                   size = me->nknot);
      TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",function_end);
      if(!(1&stat_OM)) return (OM_E_ABORT);
    }

    /*** find type ***/
    if(!strncmp(x,UNIFORM_T,strlen(x)))
      type = UNIFORM;
    else if(!strncmp(x,HUBS_T,strlen(x)))
      type = HUBS;
    else if(!strncmp(x,NOT_A_KNOT_T,strlen(x))) 
      type = NOT_A_KNOT;
    else if(!strncmp(x,REF_CURVE_T,strlen(x))) 
      type = REF_CURVE;
    
    switch(type) {

    case UNIFORM:
      for(i=0;i<me->nknot;i++)
        me->knots[i] = 0.0;
      for(i=me->mfp.order;i<me->mfp.npole;i++)
        me->knots[i] = me->knots[i-1] + 1/
                        (IGRdouble) (me->mfp.npole - me->mfp.order + 1); 
      for(i=me->nknot-1;i>=me->nknot - me->mfp.order;i--)
        me->knots[i] = 1.0;
      break;

    case REF_CURVE:
      {
            stat_OM = om$send( msg = message GRvg.GRgetsize(
                                  &msg_loc,
                                  &me->md_env.md_env.matrix_type,
                                  me->md_env.md_env.matrix,
                                  &size ),
                            targetos = me->ref_curve_id.osnum,
                            targetid = me->ref_curve_id.objid );
            TEST_ERROR(stat_OM,msg_loc,"GRgetsize", ref_end);
            crv = (struct IGRbsp_curve *) stackalloc( size );
            if(!crv) 
              REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(crv)", ref_end);
 
            stat_OM = om$send( msg = message GRvg.GRgetgeom(
                                  &msg_loc,
                                  &me->md_env.md_env.matrix_type,
                                  me->md_env.md_env.matrix,
                                  (IGRchar *)crv),
                            targetos = me->ref_curve_id.osnum,
                            targetid = me->ref_curve_id.objid );

          gr$get_curve_geometry(
                 msg = &msg_loc,
                 object_id = me->ref_curve_id,
                 md_env = me->md_env,
                 curve_struct = &crv);
          if(crv->order == me->mfp.order && crv->num_poles == me->mfp.npole) {
            me->nknot = crv->num_knots;
            for(i=0;i<crv->num_knots;i++)
              me->knots[i] = crv->knots[i];
          } else {
            strcpy(me->mfp.knot_type,me->old_knot_type);
            FIg_set_text(me->mainform, M_KNOT_F, me->mfp.knot_type);
            put_msg(&me->mainform, M_MSG_F, WRONG_ORDER);
            ex$message(msgnumb = EMS_I_WRONG_ORDER);
            ex$message( field=PROMPT_FIELD,
                msgnumb = EMS_I_00000);
          }
          strcpy(me->mfp.knot_type,FREE_T);
          FIg_set_text(me->mainform,M_KNOT_F,me->mfp.knot_type);
          me->reference_curve = FALSE;
 ref_end:
    *msg = msg_loc;
   }
          break;

    case NOT_A_KNOT:

     for ( i=0 ; i<me->mfp.order ; i++ )
       me->knots[i] = 0.0;
     if ( me->mfp.npole==me->nvx )
     {
      for ( i=me->mfp.order ; i<me->nknot-me->mfp.order ; i++ ) 
       me->knots[i] = me->paras[2+i-me->mfp.order];
     }
     else
     {
      IGRdouble *x, *y;
      x = (IGRdouble * ) om$malloc( size = (me->nvx-2) * sizeof(IGRdouble));
      if(!x)
        REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(x)",function_end);
      y = (IGRdouble * ) om$malloc( size = (me->nvx-2) * sizeof(IGRdouble));
      if(!y)
        REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(y)",function_end);
      x[0] = 0.0;
      x[me->nvx-3] = (double)(1+me->nknot-2*me->mfp.order); 
      for ( i=1 ; i<me->nvx-3 ; i++ )
       x[i] = x[me->nvx-3]*(double)(i)/(double)(me->nvx-3);
      y[0] = 0.0;
      for ( i=1 ; i<me->nvx-3 ; i++ )
       y[i] = me->paras[i+1]; 
      y[me->nvx-3] = 1.0;  
      for ( j=1 ; j<(int)(x[me->nvx-3]+0.5) ; j++ )
      {
       for ( i=0 ; x[i]<(double)(j) ; i++ );
       i--;
       me->knots[j+me->mfp.order-1] = y[i+1]*((double)(j)-x[i]);
       me->knots[j+me->mfp.order-1] = me->knots[j+me->mfp.order-1] + 
                                                   y[i]*(x[i+1]-(double)(j));
       me->knots[j+me->mfp.order-1] = me->knots[j+me->mfp.order-1] / 
                                                   (x[i+1]-x[i]);
      }    
      if ( x ) om$dealloc(ptr=x);
      if ( y ) om$dealloc(ptr=y); 
     } 
      for ( i=me->nknot-me->mfp.order ; i<me->nknot ; i++ )
        me->knots[i] = 1.0;
      break;

    case HUBS:
    /* de Boor Algorithm */
     if ( me->nvx == me->mfp.npole ) {
      for ( i=0 ; i<me->mfp.order ; i++ )
        me->knots[i] = 0.0;
      for ( j=me->mfp.order ; j<me->nknot-me->mfp.order ; j++ ) { 
        tmp = 0.0;
        for ( i=j-me->mfp.order+1 ; i<j ; i++ ) { 
          tmp = tmp + me->paras[i];
        }
        me->knots[j] = tmp / (IGRdouble)(me->mfp.order-1); 
      }
      for ( i=me->mfp.npole ; i<me->mfp.npole+me->mfp.order ; i++ )
        me->knots[i] = me->knots[i]/me->knots[me->nknot-2];
      for ( i=me->nknot-me->mfp.order ; i<me->nknot ; i++ )
        me->knots[i] = 1.0;
     } else {
      for(i=0;i<me->nknot;i++)
        me->knots[i] = 0.0;
      for(i=me->mfp.order;i<me->mfp.npole;i++)
        me->knots[i] = me->knots[i-1] + 1.0/
                        (IGRdouble) (me->mfp.npole - me->mfp.order + 1);
      for(i=me->nknot-1;i>=me->nknot - me->mfp.order;i--)
        me->knots[i] = 1.0;
     }
    break;


    default:
      break;
    }
               
    if(send_message) {
      strcat(imsg,CHANGED);
      if(me->mainform_requested)
         put_msg(&me->mainform, M_MSG_F, imsg); 
      if(me->edtform_requested)
         put_msg(&me->edtform, E_MSG_F, imsg);
      ex$message( field=PROMPT_FIELD,
             msgnumb = EMS_I_00000);
    } 
function_end:
 if(!(1 & stat_OM & msg_loc))
   strcpy(me->mfp.knot_type,me->old_knot_type);
 
 return (stat_OM);

}
method comp_and_disp_tangent(IGRlong *msg; IGRint row; IGRpoint cveval)
{
 /* ABSTRACT  compute and display a tangent at a certain linestring point

    INPUT     IGRint row          -  row in vertex table respectively
                                    vertex-no
              IGRpoint cveval     -  unnormalized tangent vector
 */
  IGRlong rc, msg_loc, stat_OM;
  IGRint i=0, reverse=0;
  IGRpoint p;
  IGRdouble dotp=0.0;
  IGRvector  vnext_vprior;
  stat_OM = msg_loc = OM_S_SUCCESS;

  /* determine direction of linestring */
  if(row != me->nvx-1 && row != 0) {
    i = row;
    vnext_vprior[X] = me->vxt[i+1].xp - me->vxt[i-1].xp;
    vnext_vprior[Y] = me->vxt[i+1].yp - me->vxt[i-1].yp;
    vnext_vprior[Z] = me->vxt[i+1].zp - me->vxt[i-1].zp;
  } else if(row == 0) {
    vnext_vprior[X] = me->vxt[1].xp - me->vxt[0].xp;
    vnext_vprior[Y] = me->vxt[1].yp - me->vxt[0].yp;
    vnext_vprior[Z] = me->vxt[1].zp - me->vxt[0].zp;
  } else {
    i = me->nvx-1;
    vnext_vprior[X] = me->vxt[i].xp - me->vxt[i-1].xp;
    vnext_vprior[Y] = me->vxt[i].yp - me->vxt[i-1].yp;
    vnext_vprior[Z] = me->vxt[i].zp - me->vxt[i-1].zp;
  }
  BSnorvec(&rc, vnext_vprior);
  TEST_MATH_ERROR(rc,"BSnorvec",function_end);
  me->nta += 1;
  me->ncon +=1;
  if(me->vxt[row].fxp[0] != '*') {
    me->nfp += 1;
    me->ncon += 1;
  }
  me->vxt[row].tav[X] = cveval[X];
  me->vxt[row].tav[Y] = cveval[Y];
  me->vxt[row].tav[Z] = cveval[Z];
  BSnorvec(&rc, me->vxt[row].tav);
  TEST_MATH_ERROR(rc,"BSnorvec",function_end);
  /* adjust tangent to linestring direction */
  dotp = BSdotp(&rc, vnext_vprior, me->vxt[row].tav);
  TEST_MATH_ERROR(rc,"BSdotp",function_end);
  reverse = (dotp > 0 ? FALSE : TRUE);

  if(reverse) {
    me->vxt[row].tav[X] = me->vxt[row].tav[X] * -1;            
    me->vxt[row].tav[Y] = me->vxt[row].tav[Y] * -1;            
    me->vxt[row].tav[Z] = me->vxt[row].tav[Z] * -1; 
  }  
  p[X] = me->vxt[row].xp;     
  p[Y] = me->vxt[row].yp;     
  p[Z] = me->vxt[row].zp;     
  stat_OM = om$send(msg = message ECascrcr.draw_vector(
                          &msg_loc,
                          p,
                          GRbd,
                          FALSE,
                          me->vxt[row].tav),
                    targetid = my_id);
  
  /* mark vertex point with tangent and fixpoint marker */
  FIfld_set_text(me->edtform, E_MCOL_F, row, TAC, "* ",0); 
  FIfld_set_text(me->edtform, E_MCOL_F, row, FXC, "* ",0); 
  strcpy(me->vxt[row].ta,"*"); 
  strcpy(me->vxt[row].fxp,"*"); 

function_end: 
 *msg = msg_loc;
 return(stat_OM);

}

method comp_and_disp_curvat(IGRlong *msg; IGRint row; IGRpoint cveval;IGRpoint tang)
{
  /* ABSTRACT  compute and display curvature in start or end point of
               linestring

     INPUT     
               IGRint row           -  vertex row no and/or point no
               IGRpoint cveval      -  second derivative in a curve point
               IGRpoint tang        -  first derivative in curve point
 */

  IGRlong rc, msg_loc, stat_OM;
  IGRdouble rho, p[9];
  IGRpoint pnt;
  IGRvector  v, w;

  stat_OM = msg_loc = OM_S_SUCCESS;

  pnt[X] = me->vxt[row].xp;
  pnt[Y] = me->vxt[row].yp;
  pnt[Z] = me->vxt[row].zp;
  p[X] = pnt[X];
  p[Y] = pnt[Y];
  p[Z] = pnt[Z];
  p[X2] = tang[X];
  p[Y2] = tang[Y];
  p[Z2] = tang[Z];
  p[X3] = cveval[X];
  p[Y3] = cveval[Y];
  p[Z3] = cveval[Z];

  v[X] = ((p[Y3]* p[Z2]) - (p[Z3] * p[Y2]));
  v[Y] = ((p[Z3]* p[X2]) - (p[X3] * p[Z2]));
  v[Z] = ((p[X3]* p[Y2]) - (p[Y3] * p[X2]));
 
  w[X] = ((p[Y2] * v[Z]) - (p[Z2] * v[Y]));
  w[Y] = ((p[Z2] * v[X]) - (p[X2] * v[Z]));
  w[Z] = ((p[X2] * v[Y]) - (p[Y2] * v[X]));

  rho = (p[X2] * p[X2] + p[Y2] * p[Y2] + p[Z2] * p[Z2]);
  rho = 1/(rho * rho);
  me->rho = rho;
  v[X] = rho * w[X];
  v[Y] = rho * w[Y];
  v[Z] = rho * w[Z];

  BSnorvec(&rc, w);
  TEST_MATH_ERROR(rc,"BSnorvec",function_end);

  stat_OM = om$send (msg = message ECascrcr.comp_and_disp_tangent(
                            &msg_loc,
                            row,
                            tang),
                     targetid = my_id);
  

  if(row == 0) {
    me->mfp.opt_curv0 = 1;
    me->ncon += 1;
    me->ncuv += 1;
    me->mfp.rad0 = 0.0;
    me->mfp.cv_vector[X] = v[X];
    me->mfp.cv_vector[Y] = v[Y];
    me->mfp.cv_vector[Z] = v[Z];
  } else {
    me->mfp.opt_curv1 = 1;
    me->ncon += 1;
    me->ncuv += 1;
    me->mfp.rad1 = 0.0;
    me->mfp.cv_vector[X2] = v[X];
    me->mfp.cv_vector[Y2] = v[Y];
    me->mfp.cv_vector[Z2] = v[Z];
  } 

  stat_OM = om$send(msg = message ECascrcr.draw_vector(
                                   &msg_loc,
                                   pnt,
                                   GRbd,
                                   FALSE,
                                   w),
                    targetid = my_id);

function_end:
 *msg = msg_loc;
 return(stat_OM);

}

method delete_tangent(IGRlong *msg; IGRint row)
{
 /* ABSTRACT delete tangent vector in vertex point (row)
             of linestring
 */
   me->vxt[row].ta[0] = ' '; 
   me->vxt[row].fxp[0] = ' '; 
   me->vxt[row].tav[X] = 0.0;
   me->vxt[row].tav[Y] = 0.0;
   me->vxt[row].tav[Z] = 0.0;
                         
   me->nta -= 1;
   me->nfp -= 1;
   me->ncon -= 2;

   FIfld_set_text(me->edtform, E_MCOL_F, row, TAC, " ",0); 
   FIfld_set_text(me->edtform, E_MCOL_F, row, FXC, " ",0); 



   return(OM_S_SUCCESS);
}

method delete_curvature(IGRlong *msg; IGRint row)
{
 /* ABSTRACT delete curvature and tangent vectors in start or end point 
             of linestring
 */
   if(row == 0) {
     me->mfp.cv_vector[X] = 0.0;
     me->mfp.cv_vector[Y] = 0.0;
     me->mfp.cv_vector[Z] = 0.0;
     me->mfp.opt_curv0 = 0;
     me->ncon -= 1;
     me->ncuv -= 1;
   } else {
     me->mfp.cv_vector[X2] = 0.0;
     me->mfp.cv_vector[Y2] = 0.0;
     me->mfp.cv_vector[Z2] = 0.0;
     me->mfp.opt_curv1 = 0;
     me->ncon -= 1;
     me->ncuv -= 1;
   }
   me->nta -= 1;
   me->nfp -= 1;
   me->ncon -= 2;

   FIfld_set_text(me->edtform, E_MCOL_F, row, TAC, " ",0); 
   FIfld_set_text(me->edtform, E_MCOL_F, row, FXC, " ",0); 
   me->vxt[row].ta[0] = ' ';
   me->vxt[row].fxp[0] = ' ';

   
   put_msg(&me->edtform, E_MSG_F, CURVATURE_REMOVED);
   ex$message (msgnumb = EMS_I_CURVATURE_REMOVED);
   me->command = PROCESS_CURVATURE;
   ME.super_cmd->state = me->commandstate = PROCESS;

   return(OM_S_SUCCESS);
}


method search_for_curve(IGRlong *msg; IGRchar **pasinfo)
{
 /* ABSTRACT  search for an associated curve to a linestring;
              only curves will be identified, which have a marker
              information in its info block

    OUTPUT
              IGRchar **pasinfo     -  pointer pointing to the 
                                       curve info pointer 
 */
  IGRlong               stat_OM, msg_loc;
  IGRint                i=0, j=0;
  struct GRid           *list = NULL;
  struct GRid           *our_curve_id = NULL;
  OMuword 		class_id;
  OM_S_OBJECT_LINKAGE 	*oblist = NULL;
  IGRint                count=0, vcount=0, bcount=0;
  IGRuint               asinfo_size;
  IGRchar               *info = NULL;
  OM_S_CHANSELECT       chandef;


  stat_OM = *msg = msg_loc = OM_S_SUCCESS;
  /* look if there is still memory allocated for associative info */
  if (info) {
    om$dealloc(ptr = info);
    info = NULL;
  }
  count = vcount = bcount = 0;
  me->XXXXX = 7777;
  /* of what class is the linestring: GR3dlinestr or GA3dlinestr ? */       
  stat_OM = om$get_classid(
             objid = me->ls_info.located_obj.objid,
             osnum = me->ls_info.located_obj.osnum,
             p_classid = &class_id);
  TEST_ERROR(stat_OM,stat_OM,"get_classid(1)", function_end);

 
  if(class_id != OPP_GA3dlinestr_class_id) 
    goto part2;
  
  /* look, if this linestring has children objects */
  stat_OM = om$send(msg = message NDnode.NDget_objects(
                                     ND_CHILDREN,
                                     NULL,
                                     0,
                                     NULL,
                                     0,
                                     1,
                                     &count),
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum);

  if(!(1&stat_OM) || (count == 0)) { 
    me->curve_exists = FALSE;
    stat_OM = INFO;
    goto function_end;
  }

  list = (struct GRid *) om$malloc(
               size = (count)*sizeof(struct GRid));
  if(!list)
    REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(list)",function_end);
  stat_OM = om$send(msg = message NDnode.NDget_objects(
                                     ND_CHILDREN,
                                     list,
                                     count,
                                     NULL,
                                     0,
                                     OM_K_MAXINT,
                                     &vcount),
                         targetid = me->ls_info.located_obj.objid,
                         targetos = me->ls_info.located_obj.osnum);
  TEST_ERROR(stat_OM,msg_loc,"NDget_objects", function_end);
  /* test, if there are bspline curves associated */
  for(i=0;i<count;i++) {
      stat_OM = om$get_classid(
              objid = (list + i)->objid,
              osnum = (list + i)->osnum,
              p_classid = &class_id);
      TEST_ERROR(stat_OM,stat_OM,"get_classid(2)", function_end);
 
      stat_OM = om$is_ancestry_valid(subclassid = class_id, 
                      superclassid = OPP_GAbspline_class_id);

      if(stat_OM == OM_S_SUCCESS) 
              bcount +=1;
   }
   if (bcount > 0) {
     our_curve_id = (struct GRid *) om$malloc(
                        size = (bcount) * sizeof(struct GRid));
     if(!our_curve_id)
        REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(our_curve_id)",function_end);
     for(i=0,j=0;i<count;i++) {
        stat_OM = om$get_classid(
                   objid = (list + i)->objid,
                   osnum = (list + i)->osnum,
                   p_classid = &class_id);
        TEST_ERROR(stat_OM,stat_OM,"get_classid(3)",function_end);
 
        stat_OM = om$is_ancestry_valid(subclassid = class_id, 
                      superclassid = OPP_GAbspline_class_id);

        if(stat_OM == OM_S_SUCCESS) {
              our_curve_id[j] = *(list + i);
        }
      }
      for (i=0;i<bcount;i++) {
      /* test, if this curve was created by this command */           
        stat_OM = om$send(msg = message EMSassoc.EMget_info(
                                       &msg_loc,
                                       NULL,
                                       &me->info_type,
                                       &asinfo_size,
                                       NULL),
                           targetid = our_curve_id[i].objid,
                           targetos = our_curve_id[i].osnum);
        TEST_ERROR(stat_OM,msg_loc,"EMget_info",function_end);

        info = (IGRchar *) om$malloc(size = asinfo_size);
        if(!info) 
           REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(info)",function_end);

        stat_OM = om$send(msg = message EMSassoc.EMget_info(
                                       &msg_loc,
                                       NULL,
                                       &me->info_type,
                                       &asinfo_size,
                                       &info),
                           targetid = our_curve_id[i].objid,
                           targetos = our_curve_id[i].osnum);
        TEST_ERROR(stat_OM,msg_loc,"EMget_info",function_end);
        /* is the infoblock marked correctly ? */ 
        *pasinfo = info + 16;
        if(!strcmp(((struct v_info * )(*pasinfo))->marker,"MARKER")) {                    me->curve_id = our_curve_id[i];
           me->curve_exists = TRUE;
           stat_OM = OM_S_SUCCESS;
           goto function_end; 
        } else {
           om$dealloc(ptr = info);
           info = NULL;
	}
      }
    }
    me->curve_exists = FALSE;
    stat_OM = OM_S_SUCCESS;
    goto function_end;


 part2:
  /* here we investigate if there are ASsource objects which link
     GR type objects to their children */
  /* set up the notification channel */
  stat_OM = om$make_chanselect(channame = "GRnotify.notification",
	    p_chanselect = &chandef);

	    if (! (1 & stat_OM)){
	       goto function_end;
	    }

  /* see if there are any listeners	*/
  stat_OM = om$get_channel_count(
             objid = me->ls_info.located_obj.objid,
             osnum = me->ls_info.located_obj.osnum,
             p_chanselect = &chandef,
             count = (OMuint *) &count);    
  if (count == 0) {
     me->curve_exists= FALSE;
     stat_OM = OM_S_SUCCESS;
     goto function_end;
  }

  oblist  = (OM_S_OBJECT_LINKAGE *) om$malloc(
                   size = (count)*sizeof(OM_S_OBJECT_LINKAGE));
  if(!oblist) 
    REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(oblist)",function_end);
    
  stat_OM = om$get_channel_objects(
               objid = me->ls_info.located_obj.objid,
               osnum = me->ls_info.located_obj.osnum,
               p_chanselect = &chandef,
               list = oblist,
               size = (OMuint) count,
               count = (OMuint *) &vcount);
  bcount = 0;
  for(i=0,j=0;i<count;i++) {
    stat_OM = om$send(msg = message NDnode.NDget_objects(
                                     ND_CHILDREN,
                                     NULL,
                                     0,
                                     NULL,
                                     0,
                                     1,
                                     &vcount),
                      targetid = (oblist + i)->S_objid,
                      targetos = (oblist + i)->osnum);
    TEST_ERROR(stat_OM,msg_loc,"NDget_objects",function_end);


    if(1&stat_OM && vcount > 0) {
       list = (struct GRid *) om$malloc(
                size = (vcount)*sizeof(struct GRid));
       stat_OM = om$send(msg = message NDnode.NDget_objects(
                                     ND_CHILDREN,
                                     list,
                                     vcount,
                                     NULL,
                                     0,
                                     OM_K_MAXINT,
                                     &count),
                         targetid = oblist->S_objid,
                         targetos = oblist->osnum);
       TEST_ERROR(stat_OM,msg_loc,"NDget_objects",function_end);
       /* look for associative dependent bspline curves */
       for(i=0;i<vcount;i++) {
          stat_OM = om$get_classid(
                        objid = (list + i)->objid,
                        osnum = (list + i)->osnum,
                        p_classid = &class_id);
          TEST_ERROR(stat_OM,stat_OM,"get_classid",function_end);
 
          stat_OM = om$is_ancestry_valid(subclassid = class_id, 
                          superclassid = OPP_GAbspline_class_id);

          if(stat_OM == OM_S_SUCCESS) {
             stat_OM = om$send(msg = message EMSassoc.EMget_info(
                                      &msg_loc,
                                      NULL,
                                      NULL,
                                      &asinfo_size,
                                      NULL),
                               targetid = (list + i)->objid,
                               targetos = (list + i)->osnum);
             TEST_ERROR(stat_OM,msg_loc,"EMget_info",function_end);
             info = (IGRchar *) om$malloc(size = asinfo_size);
             if(!info) 
               REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(info)",function_end);

             stat_OM = om$send(msg = message EMSassoc.EMget_info(
                                      &msg_loc,
                                      NULL,
                                      NULL,
                                      &asinfo_size,
                                      &info),
                               targetid = (list + i)->objid,
                               targetos = (list + i)->osnum);
             TEST_ERROR(stat_OM,msg_loc,"EMget_info",function_end);
             /* is the infoblock marked correctly ? */ 
             *pasinfo = info + 16;
             if(!strcmp(((struct v_info * )(*pasinfo))->marker,MARKER)){ 
                    me->curve_id = *(list + i);
                    me->curve_exists = TRUE;
                    stat_OM = *msg = OM_S_SUCCESS;
                    goto function_end;
             } else {
                    om$dealloc(ptr = info);
                    info = NULL;
             }
                
	  }
       }
     }
  }
  me->curve_exists = FALSE;
  stat_OM = *msg = INFO;

  
function_end:
  if(list) om$dealloc (ptr = list);
  if(oblist) om$dealloc (ptr = oblist);
  if(our_curve_id) om$dealloc (ptr = our_curve_id);
  return (stat_OM);
}

method create_as_curve(IGRlong *msg)
{
  /* ABSTRACT create an associative curve to a linestring 
              if an old curve object exists connect all children of that curve
              to the new created curve and then delete the old curve
              object
  */

  IGRlong i=0,j=0;
  IGRlong stat_OM, msg_loc, sts;


  IGRint                        asinfo_size=0;
  IGRint                        num_parents=0;
  IGRint                        nb_to_change=0;
  IGRchar                       *info = NULL;
  IGRchar                       *parvec_pt = NULL;
  IGRchar                       imsg[MSG_F_L];
  struct GRid                   *buffer;
  IGRdouble                     d=0;
  enum GRdpmode 	        dpmode;
  struct EMSobject_info    	objects[1];
  struct v_info                 *asinfo = NULL; 
  IGRchar 		        *char_info = NULL;
  struct GRvg_construct         const_list;
  OM_S_OBJID                    res_id;
  struct GRid                   mnew_id;
  
  me->XXXXX = 2929;
  *msg = OM_S_SUCCESS;
  stat_OM = OM_S_SUCCESS;
  me->linestring_was_modified = FALSE;
  /* if(!me->is_associative) {
    ex$message(msgnumb = EMS_I_ASSOC_OFF);
    *msg = INFO;
    stat_OM = INFO;
    me->new_curve_created = FALSE;
    goto function_end;
  }
  */

  if(me->assoc_delay_set) {
        me->linestring_was_modified = TRUE;
        nd$mod_batch(request = ND_SET,
                   req_mode = ND_IMMEDIATE);
        GRdelay_button(GR_DELAY_OFF);
        nd$exec_batch(mode = ND_DISP_ROOT | ND_DISP_BODY,
                     defer_flag = ND_UNCONDITIONAL);
        me->assoc_delay_set = FALSE;
  } 

  /* compute new parameter vector */
  stat_OM = om$send(msg = message ECascrcr.comp_para_vector(
                           &msg_loc),
                    targetid = my_id);
  TEST_ERROR(stat_OM,msg_loc,"comp_para_vector",function_end);

  /* compute new knot vector */
  stat_OM = om$send(msg = message ECascrcr.comp_knot_vector(
                           &msg_loc),
                    targetid = my_id);
  TEST_ERROR(stat_OM,msg_loc,"comp_knot_vector",function_end);

  FIg_set_value(me->mainform, M_ORDER_F, (double)me->mfp.order);
  FIg_set_value(me->mainform, M_SPANS_F, (double)me->mfp.nspans);
  FIg_set_value(me->mainform, M_POLES_F, (double)me->mfp.npole);
  FIg_set_value(me->mainform, M_SMOOTH_F,(double)me->mfp.smfac);
  FIg_set_text(me->mainform, M_PARA_F, me->mfp.para_type);
  FIg_set_text(me->mainform, M_KNOT_F, me->mfp.knot_type);
  strcpy(imsg," ");
  /* setup the associative info block */ 
  asinfo_size = sizeof (struct v_info );
  /* 16 bytes for recompute function name */
  if(me->curve_exists)
     asinfo_size += (16 * sizeof(IGRchar));
  asinfo_size += (me->nta * sizeof (IGRlong));
  asinfo_size += (me->nta * sizeof (IGRpoint));

  asinfo_size += (me->nfp * sizeof (IGRlong));
  asinfo_size += (me->nfa * sizeof (IGRlong));
  asinfo_size += (me->nfa * sizeof (IGRdouble));
  me->nknot = 2 * me->mfp.order + me->mfp.nspans - 1;
  asinfo_size += (me->nknot * sizeof (IGRdouble));
  asinfo_size += (me->npara * sizeof (IGRdouble)) + 1;

  asinfo = (struct v_info *) om$malloc(
                  size = (asinfo_size) * sizeof(IGRchar));
  if(!asinfo) 
   REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(asinfo)",function_end);


  asinfo->nvx = me->nvx;
  asinfo->nta = me->nta;
  asinfo->pdim = 3;
  asinfo->order = me->mfp.order;
  asinfo->nspans = me->mfp.nspans;
  asinfo->npole = me->mfp.npole;
  asinfo->nknot = 2 * asinfo->order + asinfo->nspans - 1;
  asinfo->npara = me->npara;
  asinfo->opt_end = 0;
  asinfo->power = me->mfp.power;
  asinfo->rho = me->rho;
  strcpy(asinfo->knot_type,me->mfp.knot_type);
  strcpy(asinfo->para_type,me->mfp.para_type);
  strcpy(asinfo->marker,MARKER);


  me->XXXXX = 6565; 
  /* always set opt_par to 0, so that the bs-routines do not 
     compute the parameter vector */
  if (!strcmp(me->mfp.para_type,EQUIDISTANT_T))  
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,CHORDAL_T)) 
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,CENTRIPEDAL_T))
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,PROJECT_T)) 
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,POWER_T)) 
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,AFFIN_INV_T)) 
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,REF_CURVE_T)) 
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,FREE_T)) 
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,NODE_T)) 
        asinfo->opt_par = 0;

  

  asinfo->opt_curv0 = me->mfp.opt_curv0;
  asinfo->opt_curv1 = me->mfp.opt_curv1;

  asinfo->rad0 = me->mfp.rad0;
  asinfo->rad1 = me->mfp.rad1;
  
  asinfo->smfac = me->mfp.smfac;
  if(asinfo->smfac > 0.0)
   asinfo->opt_sm = 1;
  else
   asinfo->opt_sm = 0;

  asinfo->opt_iter = me->mfp.opt_iter;


  char_info = asinfo->char_data;
  asinfo->nta = 0;
  /* add the tangent vectors to the info block */
  for (i=0;i < asinfo->nvx;i++) {
     if(me->vxt[i].ta[0] == '*') {
       j = i + 1;
#if dflT1
       printf("punkt= %d\n", j);
       printf("tax=%e\n", me->vxt[i].tav[X]);
       printf("tay=%e\n", me->vxt[i].tav[Y]);
       printf("taz=%e\n", me->vxt[i].tav[Z]);
#endif
       OM_BLOCK_MOVE(&j,char_info, sizeof(IGRlong));
       char_info +=  sizeof(IGRlong);
       OM_BLOCK_MOVE(&me->vxt[i].tav[X],char_info,sizeof(IGRdouble));
       char_info +=  sizeof(IGRdouble);
       OM_BLOCK_MOVE(&me->vxt[i].tav[Y],char_info,sizeof(IGRdouble));
       char_info +=  sizeof(IGRdouble);
       OM_BLOCK_MOVE(&me->vxt[i].tav[Z],char_info,sizeof(IGRdouble));
       char_info +=  sizeof(IGRdouble);
       asinfo->nta += 1;
     }
  }
  asinfo->nfp = 0;
  /* add the fix point values to the info block */
  for (i=0; i<asinfo->nvx;i++) {
     if(me->vxt[i].fxp[0] == '*') {
       j = i + 1;
       OM_BLOCK_MOVE(&j,char_info, sizeof(IGRlong));
       char_info += sizeof(IGRlong);
       asinfo->nfp += 1;
     }
  }
  me->XXXXX = 5577;
  /* test if the parameter vector is ok */
  if(!(strncmp(me->mfp.para_type,FREE_T,strlen(me->mfp.para_type)))) {
    if(me->paras[me->npara-1] != 1.0) {
      if(me->mainform_requested)
         put_msg(&me->mainform,M_MSG_F,PAR_VEC_ABORT);
      if(me->edtform_requested)
         put_msg(&me->edtform,E_MSG_F,PAR_VEC_ABORT);
      ex$message (msgnumb = EMS_I_PAR_VEC_ABORT);
      *msg = INFO;
      stat_OM = INFO;
      me->new_curve_created = FALSE;
      goto function_end;
    }
  }

  /* test if the no of knots correspond to the number of poles and spans */
  if(!(strncmp(me->mfp.knot_type,FREE_T,strlen(me->mfp.knot_type)))) {
    if(me->nknot != (2 * me->mfp.order + me->mfp.nspans -1)) {
      if(me->edtform_requested)
         put_msg(&me->edtform,E_MSG_F,KNOT_VEC_ABORT);
      if(me->mainform_requested)
         put_msg(&me->mainform,M_MSG_F,KNOT_VEC_ABORT);
      ex$message (msgnumb = EMS_I_KNOT_VEC_ABORT);
      *msg = INFO;
      stat_OM = INFO;
      me->new_curve_created = FALSE;
      goto function_end;
    }
  }
  asinfo->opt_wg = 0;
  asinfo->nfa = 0;
  /*  add the factors array to the info block */
  for (i=0; i<asinfo->nvx;i++) {
     if(me->vxt[i].fac != 0.0) {
       asinfo->opt_wg = 1;
       j = i + 1;
       OM_BLOCK_MOVE(&j,char_info, sizeof(IGRlong));
       char_info +=  sizeof(IGRlong);
       OM_BLOCK_MOVE(&me->vxt[i].fac , char_info, sizeof(IGRdouble));
       char_info += sizeof(IGRdouble);
       asinfo->nfa += 1;
     }
  }
    me->XXXXX = 2323;
  /* add the knots array to the info block */
  for (i=0; i<asinfo->nknot;i++) {
     d = me->knots[i];
     OM_BLOCK_MOVE(&d, char_info,  sizeof(IGRdouble));
     char_info += sizeof(IGRdouble);
  } 
  /* add the curve parameter array to the info block */
  if(asinfo->opt_par == 0) {   
    parvec_pt = char_info;     
    for (i=0; i<asinfo->npara;i++) {
         d = me->paras[i];
         OM_BLOCK_MOVE(&d,char_info,  sizeof(IGRdouble));
         char_info += sizeof(IGRdouble);
    }
  }
  /* fill the curvature vectors into the info block */
  for(i=0;i<6;i++) {
    asinfo->cv_vector[i] = me->mfp.cv_vector[i];
  }
  num_parents = 1;
 
  /* set up the linestring parent object */
  objects[0].grid = me->ls_info.located_obj;
  objects[0].env = me->ls_info.module_info;

  /* set up construction list */
  const_list.msg = &msg_loc;
  const_list.env_info = &me->md_env;
  const_list.newflag = FALSE;
  const_list.level = ME.ECelement->active_level;
  const_list.properties = GRIS_DISPLAYABLE |
                            GRIS_NEW | 
                            GRIS_LOCATABLE;
  const_list.geometry = NULL;
  const_list.display = &ME.ECelement->active_display;
  const_list.class_attr = NULL;
  const_list.name = NULL;


   if(me->curve_exists) {
     /* determine object id of old curve object */
     stat_OM = om$send(msg = message ECascrcr.search_for_curve(
                              &msg_loc,
                              &info),
                       targetid = my_id);
     TEST_ERROR(stat_OM, msg_loc, "search_for_curve",function_end);
   }

    ex$message (msgnumb = EMS_I_PROCESSING);
    /* place associative function */
    sts       = ems$associative_element_by_function(
                msg = &msg_loc,
                associative = ( me->is_associative ? TRUE : FALSE),
                num_parents = num_parents,
                parents = &objects,
                info_size = asinfo_size,
                info = (IGRchar *) asinfo,
                function_name = "EFascrcr",
                construct_list = &const_list,
                created_id = &res_id);
  if(res_id && (1 & sts & msg_loc)) {
    mnew_id.objid = res_id;
    mnew_id.osnum = const_list.env_info->md_id.osnum;
    if(me->curve_exists) {
      nb_to_change = 0;
      /* get the children object ids of the old curve object */
      stat_OM = om$send(msg = message NDnode.NDget_objects(
                               ND_CHILDREN | ND_IN_BUF,
                               NULL,
                               0,
                               &buffer,
                               0,
                               OM_K_MAXINT,
                               &nb_to_change),
                        targetid = me->curve_id.objid,
                        targetos = const_list.env_info->md_id.osnum);
      TEST_ERROR(stat_OM, msg_loc, "NDget_objects",function_end);

      me->XXXXX = 9090;
      if(nb_to_change) {
       for(i=0; i < nb_to_change; i++) {
         /*obj_to_change[i] = buffer[i];*/
         dpmode = GRbe;
         stat_OM = om$send(msg = message GRgraphics.GRdisplay(
                                  &msg_loc,
                                  &me->md_env.md_env.matrix_type,
                                  me->md_env.md_env.matrix,
                                  &dpmode,
                                  &me->md_env.md_id),
                           targetid = buffer[i].objid,
                           targetos = buffer[i].osnum);
         /* connect the childrens of the old curve object to the new
            curve object */
         stat_OM = om$send(msg =  message ASnode.NDchange_connect(
                               1,
                               &me->curve_id, &mnew_id),
                           targetid = buffer[i].objid,
                           targetos = buffer[i].osnum);

         TEST_ERROR(stat_OM, msg_loc, "NDchange_connect", function_end);
         dpmode = GRbd;
         stat_OM = om$send(msg = message GRgraphics.GRdisplay(
                                  &msg_loc,
                                  &me->md_env.md_env.matrix_type,
                                  me->md_env.md_env.matrix,
                                  &dpmode,
                                  &me->md_env.md_id),
                           targetid = buffer[i].objid,
                           targetos = buffer[i].osnum);
                                  
        }
        /*if(buffer) om$dealloc(ptr=buffer);*/
     }
     dpmode = GRbe;
     stat_OM = om$send(msg = message GRgraphics.GRdisplay(
                                  &msg_loc,
                                  &me->md_env.md_env.matrix_type,
                                  me->md_env.md_env.matrix,
                                  &dpmode,
                                  &me->md_env.md_id),
                           targetid = me->curve_id.objid,
                           targetos = me->curve_id.osnum);
     /* delete the old curve object */
     stat_OM = om$send ( msg = message GRgraphics.GRdelete(
                               &msg_loc,
                               const_list.env_info),
                          targetid = me->curve_id.objid,
                          targetos = me->curve_id.osnum);
    } 

    /* if there exist children and the linestring wasn't modified, give
       the linestring a kick so that the associative engine updates
       all dependents in the graph */
    if(nb_to_change && (!me->linestring_was_modified)) {
      me->assoc_delay_set = TRUE;
      stat_OM = om$send(msg = message ECascrcr.putpolyline(
                              &msg_loc),
                        targetid = my_id);
      me->assoc_delay_set = FALSE;
      
    }
    /* search for object id of new curve objects and place id in instance
       area of command  */
     stat_OM = om$send(msg = message ECascrcr.search_for_curve(
                              &msg_loc,
                              &info),
                       targetid = my_id);
     TEST_ERROR(stat_OM, msg_loc, "search_for_curve",function_end);

     if(!me->is_associative) {
       if(me->curve_id.objid) {
         dpmode = GRbe;
         stat_OM = om$send(msg = message GRgraphics.GRdisplay(
                                  &msg_loc,
                                  &me->md_env.md_env.matrix_type,
                                  me->md_env.md_env.matrix,
                                  &dpmode,
                                  &me->md_env.md_id),
                           targetid = me->curve_id.objid,
                           targetos = me->curve_id.osnum);
         /* delete the old curve object */
         stat_OM = om$send ( msg = message GRgraphics.GRdelete(
                               &msg_loc,
                               const_list.env_info),
                          targetid = me->curve_id.objid,
                          targetos = me->curve_id.osnum);
       }
       me->curve_id.objid = res_id;
       me->curve_id.osnum = const_list.env_info->md_id.osnum;
     }

     dpmode = GRbd;
     sts = om$send (msg = message GRgraphics.GRdisplay(&msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &dpmode,
                          &me->md_env.md_id),
                 targetid = me->curve_id.objid,
                 targetos = me->curve_id.osnum);

      me->curve_exists = TRUE; 
      me->new_curve_created = TRUE;
      /* in case of iterative improvemnt computation the bs-routines
         have modified the curve parameter vector; take this new
         vector */
      if(me->mfp.opt_iter != 0) {
       me->mfp.opt_iter = 0;
       strcpy(me->mfp.para_type,FREE_T);
       if(me->mainform_requested) {
          FIg_set_value(me->mainform,M_ITERA_F,(IGRdouble)me->mfp.opt_iter);
          FIg_set_text(me->mainform,M_PARA_F,me->mfp.para_type);
       }
       for (i=0; i<asinfo->npara;i++) {
          d = me->paras[i];
          OM_BLOCK_MOVE(parvec_pt, &me->paras[i],  sizeof(IGRdouble));
          parvec_pt += sizeof(IGRdouble);
       }
      }
#if dflT1
      printf("curve id = %d   curve os = %d \n", me->curve_id.objid, 
                                                 me->curve_id.osnum);
#endif
      /*if(me->mainform_requested)
         put_msg(&me->mainform, M_MSG_F, CURV_CREAT);
      if(me->edtform_requested)
         put_msg(&me->mainform, E_MSG_F, CURV_CREAT);*/
      ex$message (msgnumb = EMS_I_CURV_CREAT);
      me->from_curve_creation = TRUE;
      goto function_end;
    } else {
      /*if(me->mainform_requested)
         put_msg(&me->mainform, M_MSG_F, CURV_NOT_CREAT);
      if(me->edtform_requested)
         put_msg(&me->mainform, E_MSG_F, CURV_NOT_CREAT);*/
      ex$message (msgnumb = EMS_I_CURV_NOT_CREAT);
      me->new_curve_created = FALSE;
      *msg = INFO;
      stat_OM = INFO;
      goto function_end;
    }

  function_end:
    return(stat_OM);

}

#if dflT9
method create_as_curve(IGRlong *msg)
{
  IGRlong i=0,j=0,k=0;
  IGRlong stat_OM, msg_loc, sts;
  IGRboolean create_paras;


  IGRint                        asinfo_size=0;
  IGRuint                       info_size=0;
  IGRuint                       type=0;
  IGRushort                     options;
  IGRshort                      dd=0;
  IGRlong                       num_ele=0;
  IGRint                        num_parents=0;
  IGRint                        ncon=0;
  IGRint                        send_message=0;
  IGRint                        nb_to_change=0;
  IGRint                        cn_type=0;
  IGRchar                       *info = NULL;
  IGRchar                       *parvec_pt = NULL;
  IGRchar                       imsg[MSG_F_L];
  struct GRid                   *obj_to_change, *buffer;
  struct GRid                   curve_id;
  IGRdouble                     d=0.0, d2=0.0;
  enum GRdpmode 	        dpmode;
  struct EMSobject_info    	objects[1];
  struct v_info                 *asinfo = NULL; 
  IGRchar 		        *char_info = NULL;
  IGRchar                       *infoblock = NULL;
  struct GRvg_construct         const_list;
  OM_S_OBJID                    res_id;
  struct GRid                   mnew_id;
  OM_S_OBJECT_LINKAGE 	        *oblist = NULL;
  OM_S_CHANSELECT               children;
  
  me->XXXXX = 2929;

  /* compute new para vector */
  stat_OM = om$send(msg = message ECascrcr.comp_para_vector(
                           &msg_loc),
                    targetid = my_id);

  /* compute new knot vector */
  stat_OM = om$send(msg = message ECascrcr.comp_knot_vector(
                           &msg_loc),
                    targetid = my_id);

  FIg_set_value(me->mainform, M_ORDER_F, (double)me->mfp.order);
  FIg_set_value(me->mainform, M_SPANS_F, (double)me->mfp.nspans);
  FIg_set_value(me->mainform, M_POLES_F, (double)me->mfp.npole);
  FIg_set_value(me->mainform, M_SMOOTH_F,(double)me->mfp.smfac);
  FIg_set_text(me->mainform, M_PARA_F, me->mfp.para_type);
  FIg_set_text(me->mainform, M_KNOT_F, me->mfp.knot_type);
  strcpy(imsg," "); 
  asinfo_size = sizeof (struct v_info );
  /* 16 bytes for recompute function name */
  if(me->curve_exists)
     asinfo_size += (16 * sizeof(IGRchar));
  asinfo_size += (me->nta * sizeof (IGRlong));
  asinfo_size += (me->nta * sizeof (IGRpoint));

  asinfo_size += (me->nfp * sizeof (IGRlong));
  asinfo_size += (me->nfa * sizeof (IGRlong));
  asinfo_size += (me->nfa * sizeof (IGRdouble));
  me->nknot = 2 * me->mfp.order + me->mfp.nspans - 1;
  asinfo_size += (me->nknot * sizeof (IGRdouble));
  asinfo_size += (me->npara * sizeof (IGRdouble)) + 1;

  asinfo = (struct v_info *) om$malloc(
                  size = (asinfo_size) * sizeof(IGRchar));
  if(!asinfo) 
    REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(asinfo)",function_end);


  asinfo->nvx = me->nvx;
  asinfo->nta = me->nta;
  asinfo->pdim = 3;
  asinfo->order = me->mfp.order;
  asinfo->nspans = me->mfp.nspans;
  asinfo->npole = me->mfp.npole;
  asinfo->nknot = 2 * asinfo->order + asinfo->nspans - 1;
  asinfo->npara = me->npara;
  asinfo->opt_end = 0;
  asinfo->power = me->mfp.power;
  asinfo->rho = me->rho;
  strcpy(asinfo->knot_type,me->mfp.knot_type);
  strcpy(asinfo->para_type,me->mfp.para_type);
  strcpy(asinfo->marker,MARKER);


  me->XXXXX = 6565; 
  if (!strcmp(me->mfp.para_type,EQUIDISTANT_T))  
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,CHORDAL_T)) 
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,CENTRIPEDAL_T))
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,PROJECT_T)) 
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,POWER_T)) 
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,AFFIN_INV_T)) 
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,FREE_T)) 
        asinfo->opt_par = 0;
  else if(!strcmp(me->mfp.para_type,NODE_T)) 
        asinfo->opt_par = 0;

  

  asinfo->opt_curv0 = me->mfp.opt_curv0;
  asinfo->opt_curv1 = me->mfp.opt_curv1;

  asinfo->rad0 = me->mfp.rad0;
  asinfo->rad1 = me->mfp.rad1;
  
  asinfo->smfac = me->mfp.smfac;
  if(asinfo->smfac > 0.0)
   asinfo->opt_sm = 1;
  else
   asinfo->opt_sm = 0;

  asinfo->opt_iter = me->mfp.opt_iter;


  char_info = asinfo->char_data;
  asinfo->nta = 0;
  for (i=0;i < asinfo->nvx;i++) {
     if(me->vxt[i].ta[0] == '*') {
       j = i + 1;
#if dflT1
       printf("punkt= %d\n", j);
       printf("tax=%e\n", me->vxt[i].tav[X]);
       printf("tay=%e\n", me->vxt[i].tav[Y]);
       printf("taz=%e\n", me->vxt[i].tav[Z]);
#endif
       OM_BLOCK_MOVE(&j,char_info, sizeof(IGRlong));
       char_info +=  sizeof(IGRlong);
       OM_BLOCK_MOVE(&me->vxt[i].tav[X],char_info, sizeof(IGRdouble));
       char_info +=  sizeof(IGRdouble);
       OM_BLOCK_MOVE(&me->vxt[i].tav[Y],char_info, sizeof(IGRdouble));
       char_info +=  sizeof(IGRdouble);
       OM_BLOCK_MOVE(&me->vxt[i].tav[Z],char_info, sizeof(IGRdouble));
       char_info +=  sizeof(IGRdouble);
       asinfo->nta += 1;
     }
  }
  asinfo->nfp = 0;
  for (i=0; i<asinfo->nvx;i++) {
     if(me->vxt[i].fxp[0] == '*') {
       j = i + 1;
       OM_BLOCK_MOVE(&j, char_info, sizeof(IGRlong));
       char_info += sizeof(IGRlong);
       asinfo->nfp += 1;
     }
  }

  if(!(strncmp(me->mfp.para_type,FREE_T,strlen(me->mfp.para_type)))) {
    if(me->paras[me->npara-1] != 1.0) {
      if(me->mainform_requested)
         put_msg(&me->mainform,M_MSG_F,PAR_VEC_ABORT);
      if(me->edtform_requested)
         put_msg(&me->edtform,E_MSG_F,PAR_VEC_ABORT);
      ex$message (msgnumb = EMS_I_PAR_VEC_ABORT);
      *msg = OM_E_ABORT;
      return(OM_E_ABORT);
    }
  }

  if(!(strncmp(me->mfp.knot_type,FREE_T,strlen(me->mfp.knot_type)))) {
    if(me->nknot != (2 * me->mfp.order + me->mfp.nspans -1)) {
      if(me->edtform_requested)
         put_msg(&me->edtform,E_MSG_F,KNOT_VEC_ABORT);
      if(me->mainform_requested)
         put_msg(&me->mainform,M_MSG_F,KNOT_VEC_ABORT);
      ex$message (msgnumb = EMS_I_KNOT_VEC_ABORT);
      *msg = OM_E_ABORT;
      return(OM_E_ABORT);
    }
  }
  asinfo->opt_wg = 0;
  asinfo->nfa = 0;
  for (i=0; i<asinfo->nvx;i++) {
     if(me->vxt[i].fac != 0.0) {
       asinfo->opt_wg = 1;
       j = i + 1;
       OM_BLOCK_MOVE(&j, char_info, sizeof(IGRlong));
       char_info +=  sizeof(IGRlong);
       OM_BLOCK_MOVE(&me->vxt[i].fac , char_info, sizeof(IGRdouble));
       char_info += sizeof(IGRdouble);
       asinfo->nfa += 1;
     }
  }
    me->XXXXX = 2323;
  for (i=0; i<asinfo->nknot;i++) {
     d = me->knots[i];
     OM_BLOCK_MOVE(&d, char_info,  sizeof(IGRdouble));
     char_info += sizeof(IGRdouble);
  } 
  if(asinfo->opt_par == 0) {   
    parvec_pt = char_info;     
    for (i=0; i<asinfo->npara;i++) {
         d = me->paras[i];
         OM_BLOCK_MOVE(&d, char_info,  sizeof(IGRdouble));
         char_info += sizeof(IGRdouble);
    }
  }

  for(i=0;i<6;i++) {
    asinfo->cv_vector[i] = me->mfp.cv_vector[i];
  }
  num_parents = 1;

  /* curve object */
  objects[0].grid = me->ls_info.located_obj;
  objects[0].env = me->ls_info.module_info;

  /* set up construction list */
  const_list.msg = &msg_loc;
  const_list.env_info = &me->md_env;
  const_list.newflag = FALSE;
  const_list.level = ME.ECelement->active_level;
  const_list.properties = GRIS_DISPLAYABLE |
                            GRIS_NEW | 
                            GRIS_LOCATABLE;
  const_list.geometry = NULL;
  const_list.display = &ME.ECelement->active_display;
  const_list.class_attr = NULL;
  const_list.name = NULL;


   if(me->curve_exists) {
     stat_OM = om$send (msg = message ECascrcr.search_for_curve(
                              &msg_loc,
                              &info),
                        targetid = my_id);
     curve_id = me->curve_id;
     memmove(info,asinfo,asinfo_size);
     /*asinfo_size += 16;*/
     info -= 16;
     stat_OM = om$send (msg = message EMSassoc.EMput_info(
                              &msg_loc,
                              options,
                              type,
                              asinfo_size,
                              info),
                        targetid = me->curve_id.objid,
                        targetos = me->curve_id.osnum);
     if(me->assoc_delay_set) {
        nd$mod_batch(request = ND_SET,
                   req_mode = ND_IMMEDIATE);
        GRdelay_button(GR_DELAY_OFF);
        nd$exec_batch(defer_flag = ND_UNCONDITIONAL);
         me->assoc_delay_set = FALSE; 
     } else {
        stat_OM = om$send (msg = message ECascrcr.process_edit(
                                 &msg_loc),
                           targetid = my_id);     
        nd$mod_batch(request = ND_SET,
                   req_mode = ND_IMMEDIATE);
        GRdelay_button(GR_DELAY_OFF);
        nd$exec_batch(defer_flag = ND_UNCONDITIONAL);
        me->assoc_delay_set = FALSE;
     }
     stat_OM = om$send (msg = message ECascrcr.search_for_curve(
                              &msg_loc,
                              &info),
                        targetid = my_id);
     if(curve_id.objid == me->curve_id.objid) {
        if(me->mainform_requested)
           put_msg(&me->mainform, M_MSG_F, CURV_NOT_CREAT);
        if(me->edtform_requested)
           put_msg(&me->mainform, E_MSG_F, CURV_NOT_CREAT);
        ex$message (msgnumb = EMS_I_CURV_NOT_CREAT);
        me->curve_exists = TRUE;
        me->new_curve_created = FALSE;
        return(OM_E_ABORT);
     } else {
        me->new_curve_created = TRUE;
        me->curve_exists = TRUE;
        if(me->mainform_requested)
           put_msg(&me->mainform, M_MSG_F, CURV_CREAT);
        if(me->edtform_requested)
           put_msg(&me->mainform, E_MSG_F, CURV_CREAT);
        ex$message (msgnumb = EMS_I_CURV_CREAT);
     }
   } else {
      if(me->assoc_delay_set) {
        nd$mod_batch(request = ND_SET,
                   req_mode = ND_IMMEDIATE);
        GRdelay_button(GR_DELAY_OFF);
        nd$exec_batch(defer_flag = ND_UNCONDITIONAL);
        me->assoc_delay_set = FALSE;
      }
      /* place associative function */
      sts  = ems$associative_element_by_function(
                msg = &msg_loc,
                associative = ( me->is_associative ? TRUE : FALSE),
                num_parents = num_parents,
                parents = &objects,
                info_size = asinfo_size,
                info = (IGRchar *) asinfo,
                function_name = "EFascrcr",
                construct_list = &const_list,
                created_id = &res_id);
      if(res_id) {
        me->XXXXX = 2122;
        me->new_curve_created = TRUE;
        me->curve_exists = TRUE;
        me->curve_id.objid = res_id;
        me->curve_id.osnum = me->md_env.md_id.osnum;
        /* display the offset curve */
        dpmode = GRbd;
        sts = om$send (msg = message GRgraphics.GRdisplay(&msg_loc,
                             &me->md_env.md_env.matrix_type,
                             me->md_env.md_env.matrix,
                             &dpmode,
                          &me->md_env.md_id),
                       targetid = me->curve_id.objid,
                       targetos = me->curve_id.osnum);
        if(me->mainform_requested)
           put_msg(&me->mainform, M_MSG_F, CURV_CREAT);
        if(me->edtform_requested)
           put_msg(&me->mainform, E_MSG_F, CURV_CREAT);
        ex$message (msgnumb = EMS_I_CURV_CREAT);
      } else {
        if(me->mainform_requested)
           put_msg(&me->mainform, M_MSG_F, CURV_NOT_CREAT);
        if(me->edtform_requested)
           put_msg(&me->mainform, E_MSG_F, CURV_NOT_CREAT);
        ex$message (msgnumb = EMS_I_CURV_NOT_CREAT);
        me->new_curve_created = FALSE;
        return(OM_E_ABORT);
      }
   }
   if(me->curve_exists) {
      
        if(me->mfp.opt_iter != 0) {
         me->mfp.opt_iter = 0;
         strcpy(me->mfp.para_type,FREE_T);
         if(me->mainform_requested) {
            FIg_set_value(me->mainform,M_ITERA_F,(IGRdouble)me->mfp.opt_iter);
            FIg_set_text(me->mainform,M_PARA_F,me->mfp.para_type);
         }

         stat_OM = om$send(msg = message ECascrcr.fill_tables(
                                &msg_loc,
                                (struct v_info *) info),
                         targetid = my_id);
         for (i=0; i<asinfo->npara;i++) {
          d = me->paras[i];
          OM_BLOCK_MOVE(parvec_pt, &me->paras[i],  sizeof(IGRdouble));
          parvec_pt += sizeof(IGRdouble);
         }
       }
      }
#if dflT1
      printf("curve id = %d   curve os = %d \n", me->curve_id.objid, me->curve_id.osnum);
#endif

}
#endif

method determine_dist_length(IGRlong *msg; IGRdouble *d)
{
 IGRlong                stat_OM, msg_loc, ret_stat;
 IGRint 		point_size=0;
 IGRdouble 		vwvolume[6];
 IGRdouble		r[6];
 struct var_list 	var_list_of[2];
 
 stat_OM = msg_loc = OM_S_SUCCESS;

           /* determine range box */

            var_list_of[0].var = VW_VOLUME;
            var_list_of[0].var_ptr =  (IGRchar *) vwvolume;
            var_list_of[0].num_bytes = sizeof (IGRdouble) * 6;
            var_list_of[0].bytes_returned = (IGRlong *) &ret_stat;
            var_list_of[1].var = END_PARAM;

            /* get view volume  */
            stat_OM = dp$inq_set_gragad (msg = &msg_loc,
                                 gragad_objid = me->locate_stack.window.objid,
                                 osnum = me->locate_stack.window.osnum,
                                 which_error = &ret_stat,
                                 var_list = var_list_of);
            TEST_ERROR(stat_OM,msg_loc,"inq_set_gragad", function_end);

	    point_size = sizeof(IGRpoint);

            OM_BLOCK_MOVE(&vwvolume[X], &r[X], point_size);
            OM_BLOCK_MOVE(&vwvolume[X2], &r[X2], point_size);
        
	    /* compute range */
            /* the arrow length should be 1/10 of the window diagonal
            function EFdraw_vector_on_screen already takes 1/4 of 
            diagonal, so multiply upper corner by RANGE_DIV */

            /*r[X2] = r[X] + ((r[X2] - r[X]) * RANGE_DIV); 
            r[Y2] = r[Y] + ((r[Y2] - r[Y]) * RANGE_DIV);
            r[Z] = r[Z2] = 0.0; 
            r[Z2] = r[Z] + ((r[Z2] - r[Z]) * RANGE_DIV); */

            *d = sqrt(((r[X2]-r[X])*(r[X2]-r[X]))+((r[Y2]-r[Y])*(r[Y2]-r[Y])));
            *d /= 10;
            *d = (IGRdouble)(IGRint)(*d + 0.5);

     
function_end:
 *msg = msg_loc;
 return (stat_OM);

}

method draw_vector(IGRlong *msg; IGRpoint p;  enum GRdpmode dpmode;IGRboolean dir; IGRvector v)
{
 /* ABSTRACT draw a temporary vector on screen from a tangent information

    INPUT    
             IGRpoint p           -  the point where to draw the vector
             enum GRdpmode dpmode -  display mode
             IGRboolean dir       -  vector direction
             IGRvector v          -  the vector to draw
 */
 /***draw_vector***/
 IGRlong msg_loc, ret_stat, sts;
 IGRint 		point_size=0;
 IGRdouble 		vwvolume[6];
 IGRdouble		range[6];
 struct var_list 	var_list_of[2];
           /* determine range box */

            var_list_of[0].var = VW_VOLUME;
            var_list_of[0].var_ptr =  (IGRchar *) vwvolume;
            var_list_of[0].num_bytes = sizeof (IGRdouble) * 6;
            var_list_of[0].bytes_returned = (IGRlong *) &ret_stat;
            var_list_of[1].var = END_PARAM;

            /* get view volume  */
            sts = dp$inq_set_gragad (msg = &msg_loc,
                                 gragad_objid = me->locate_stack.window.objid,
                                 osnum = me->locate_stack.window.osnum,
                                 which_error = &ret_stat,
                                 var_list = var_list_of);

	    point_size = sizeof(IGRpoint);

            OM_BLOCK_MOVE(&vwvolume[0], &range[0], point_size);
            OM_BLOCK_MOVE(&vwvolume[3], &range[3], point_size);
        
	    /* compute range */
            /* the arrow length should be 1/10 of the window diagonal
            function EFdraw_vector_on_screen already takes 1/4 of 
            diagonal, so multiply upper corner by RANGE_DIV */

            range[3] = range[0] + ((range[3] - range[0]) * RANGE_DIV); 
            range[4] = range[1] + ((range[4] - range[1]) * RANGE_DIV);
            range[2] = range[5] = 0.0; 
            range[5] = range[2] + ((range[5] - range[2]) * RANGE_DIV); 

            EFdraw_vector_on_screen(my_id, 
                                &me->active_display, 
                                &me->md_env,
                                dpmode, 
                                dir,
                                p, 
                                v,
                                range, 
                                &msg_loc);

 return(OM_S_SUCCESS);

}

method putpolyline(IGRlong *msg) 
{
 IGRlong msg_loc, stat_OM;
 IGRint i=0, j=0;
 enum GRdpmode 	dpmode;
 struct GRpost_info info;
 struct GRid tobj;
 struct IGRpolyline polyline;
 IGRdouble *polypts;

 stat_OM = msg_loc = OM_S_SUCCESS;
 dpmode = GRbe;
 stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay (
                          &msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &dpmode, 
                          &me->md_env.md_id),
                    senderid = my_id,
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum);

 polypts = (IGRdouble *) om$malloc(
                  size = (me->nvx * 3) * sizeof(IGRdouble));
 if(!polypts) 
     REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(polypts)",function_end);

 /* get the points */
 for(i=0,j=0;i<me->nvx;i++,j+=3) {
     polypts[j] = me->vxt[i].xp;
     polypts[j+1] = me->vxt[i].yp;
     polypts[j+2] = me->vxt[i].zp;
 }
 polyline.num_points = me->nvx;
 polyline.points = polypts;

 if(!me->assoc_delay_set) {

      nd$mod_batch(request = ND_SET,
                   req_mode = ND_DEFER);
      GRdelay_button(GR_DELAY_ON);
      me->assoc_delay_set = TRUE;
 }
 stat_OM = om$send(mode = OM_e_wrt_object,
              	   msg = message GR3dlinestr.GRputpolyline(
                              &msg_loc,
                              &me->md_env,
                              &info,
                              &polyline,
                              &tobj.objid),
                         senderid = my_id,
                         targetid = me->ls_info.located_obj.objid,
                         targetos = me->ls_info.located_obj.osnum);
 TEST_ERROR(stat_OM,msg_loc,"GRputpolyline",function_end);
 dpmode = GRbd;
 stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay (
                          &msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &dpmode, 
                          &me->md_env.md_id),
                   senderid = my_id,
                   targetid = ME.ECelement->elem.located_obj.objid,
                   targetos = ME.ECelement->elem.located_obj.osnum);
function_end:
 if(polypts) 
   om$dealloc(ptr = polypts);
 *msg = msg_loc;
 return (stat_OM);

}
method process_edit(IGRlong *msg)
{
 /* ABSTRACT o modify polyline information of linestring due to
               vertices changes; 
             o update forms and vertex table
             o update undo table
  
 */
 /***process_edit***/
 IGRlong msg_loc, stat_OM;
 IGRint i=0, j=0;
 IGRint sel=0,pos=0;
 IGRchar fxp[3];
 IGRpoint p;
 
 stat_OM = msg_loc = OM_S_SUCCESS;

 for(i=0,j=0;i<me->nvx;i++) {
   me->XXXXX = 5555;
   if(me->vxt[i].edt_flag == 'x') {
     me->utbl[j] = me->vxt[i];
     j++;
     FIfld_get_value(me->edtform, E_MCOL_F, i, XC, &p[X],&sel,&pos);
     FIfld_get_value(me->edtform, E_MCOL_F, i, YC, &p[Y],&sel,&pos);
     FIfld_get_value(me->edtform, E_MCOL_F, i, ZC, &p[Z],&sel,&pos);
     me->vxt[i].xp = p[X];
     me->vxt[i].yp = p[Y];
     me->vxt[i].zp = p[Z];
     FIfld_get_text(me->edtform, E_MCOL_F, i, FXC, 2,fxp,&sel, &pos); 
     if(fxp[0] == '\0') {
      fxp[0] = ' ';
      fxp[1] = '\0';
     }
     if(me->vxt[i].fxp[0] != fxp[0]) {
       if(fxp[0] == '*') {
         me->nfp += 1;
         me->ncon += 1;
       } else {
         me->nfp -= 1;
         me->ncon -= 1;
       }
     }
     FIfld_get_text(me->edtform, E_MCOL_F, i, TAC, 2,me->vxt[i].ta,&sel, &pos); 
     FIfld_get_value(me->edtform, E_MCOL_F, i, FAC, &me->vxt[i].fac,&sel,&pos);
     me->vxt[i].edt_flag = ' ';
   }
 }
 me->XXXXX = 4001;
 me->undo_num = j;
 me->undo_type = UNDO_TYPE_MODIFY;


 stat_OM = om$send(msg = message ECascrcr.putpolyline(
                         &msg_loc),
                   targetid = my_id);
 TEST_ERROR(stat_OM,msg_loc,"putpolyline",function_end);

function_end:
 *msg = msg_loc;
 return (stat_OM);
}

method process_delete(IGRlong *msg; IGRint *row; IGRint *pos)
{
 /* ABSTRACT  delete a vertex from linestring
              o update vertex table and form
              o update undo table
              o call delete_vertex method
 */
 IGRlong msg_loc, stat_OM;
 IGRint i=0;
 IGRchar fmessage[MSG_F_L];
 stat_OM = msg_loc = OM_S_SUCCESS;

           if(me->delete_row) {
             if(me->delete_row_no == *row) {
#if dflT1     
               printf("start the delete method here\n");
               printf("vertex delete\n");
#endif         
               me->undo_type = UNDO_TYPE_DELETE;
               me->undo_num = 1;
               me->utbl[0] = me->vxt[*row];

               FIfld_delete_rows(me->edtform, E_MCOL_F, *row, 1);
               FIfld_delete_rows(me->edtform, E_VERTEX_F, *row, 1);

               me->nvx -= 1;
               me->npara -= 1;
               /*FIfld_set_num_rows(me->edtform, E_MCOL_F, me->nvx);
               FIfld_set_num_rows(me->edtform, E_VERTEX_F, me->nvx);*/
               if(me->vxt[*row].fxp[0] == '*') {
                  me->nfp -= 1;
                  me->ncon -= 1;
	       }
               if(me->vxt[*row].ta[0] == '*') {
                  me->nta -= 1;
                  me->ncon -= 1;
	       }
               for(i= *row;i<me->nvx;i++) {
                  FIfld_set_value(me->edtform, E_VERTEX_F, i, VNC,(double)i,FALSE);
                 me->vxt[i] = me->vxt[i+1];
                 me->vxt[i].nvno = i;

	       }
               FIfld_set_active_row(me->edtform, E_MCOL_F, *row, 0); 
               FIfld_set_active_row(me->edtform, E_VERTEX_F, *row, 0); 
               /*FIfld_set_value(me->edtform, E_VERTEX_F, me->nvx, VNC,(double)i,FALSE);
               FIfld_insert_blank_row(me->edtform, E_MCOL_F,me->nvx);
               FIfld_insert_blank_row(me->edtform, E_VERTEX_F,me->nvx);
               FIfld_set_active_row(me->edtform, E_VERTEX_F, *row, *pos);*/
               stat_OM = om$send(msg = message ECascrcr.delete_vertex(
                                        &msg_loc),
                                 targetid = my_id);
               TEST_ERROR(stat_OM,msg_loc,"delete_vertex",function_end);                      put_msg(&me->edtform, E_MSG_F, ROW_DELETED);
               ex$message (msgnumb = EMS_I_ROW_DELETED);
#if dflT5
        for(i=0;i<me->nvx;i++) 
          printf("i= %d nvno= %d  vxt[i]x= %f  vxt[i]y= %f  vxt[i]z %f\n",
                 i, me->vxt[i].nvno,me->vxt[i].xp, me->vxt[i].yp, me->vxt[i].zp);
        for(i=0;i<me->nvx;i++) {
          FIfld_get_value(me->edtform,E_VERTEX_F,i,0,&fvalue,&sel,&pos);
          FIfld_get_value(me->edtform,E_MCOL_F,i,XC,&xp,&sel,&pos);
          FIfld_get_value(me->edtform,E_MCOL_F,i,YC,&yp,&sel,&pos);
          FIfld_get_value(me->edtform,E_MCOL_F,i,ZC,&zp,&sel,&pos);
          printf("i= %d nvno= %d  edtx= %f  edty= %f  edtz %f\n",
                 i, (int)fvalue,xp, yp, zp); 
        }
#endif         
             } 
             put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
             ex$message (msgnumb = EMS_I_00000);
             FIg_set_state_off(me->edtform, E_DEL_B);
             set_gadget_active_inactive(&me->edtform, 15,
                 E_MCOL_F, OFF, E_EDT_B, ON, E_INS_B, ON, 
                 E_UNDO_B, ON, E_TA1_B, ON, E_AFIX_B, ON,
                 E_CURV_B, ON, E_SHFIX_B, ON, E_MOV_B, ON,
                 E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
                 E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0); 
             me->delete_row = FALSE;
             me->command = PROCESS_SELECT;
  
           } else {
             me->delete_row = TRUE;
             me->delete_row_no = *row;
             sprintf(fmessage,"Vertex No %d selected; select again to delete", *row);
             put_msg(&me->edtform, E_MSG_F, fmessage);
               ex$message (msgnumb = EMS_I_00000);
           }
function_end:
  *msg = msg_loc;
  return (stat_OM);
}

method select_cv_point(IGRlong *msg; IGRpoint p; IGRdouble *knotpu; IGRpoint mvp; IGRint *vix)
{
 /***select_cv_point***/
 /* ABSTRACT select a curve point corresponding to a knot value

    INPUT
             IGRpoint p         -  nearest point
             IGRdouble *knotpu  -  knot value when point is selected via
                                   knot table
    OUTPUT   IGRpoint mvp       -  point at parameter
             IGRdouble *knotpu  -  knot value at point for knot insertion
             IGRint  vix        -  index in knot table for knot
 */

 IGRlong stat_OM, msg_loc;
 IGRint i=0, j=0;
 IGRdouble t=0.0, uv[2], diff0=0.0, diff=0.0;
 IGRpoint ppp, pnt1, pnt2;
 struct GRparms proparms;
 struct IGRline 	boreline;
 IGRchar fmessage[MSG_F_L];
 IGRchar *info = NULL;

 if(!me->form_event_handling) {
   /* selection took place via mouse or point value */
   boreline.point1 = pnt1;  /* allocates storage for */
   boreline.point2 = pnt2;  /* the boreline          */
#if dflT1
   printf("from select_cv_point: id = %d  os = %d\n", me->curve_id.objid,
                                                      me->curve_id.osnum);
#endif
   EFboreline(&msg_loc, my_id, &me->accev, &boreline);
   /*stat_OM = CObrln(&msg_loc, &my_id, me->accev, &boreline);*/
   /* determine object id of old curve object */
   stat_OM = om$send(msg = message ECascrcr.search_for_curve(
                           &msg_loc,
                           &info),
                     targetid = my_id);
   stat_OM = om$send(msg = message GRgraphics.GRlnproject(&msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &boreline,
                          pnt1, 
                          ppp, 
                          &t, 
                          &proparms),
                    senderid = my_id,
                    targetid = me->curve_id.objid,
                    targetos = me->curve_id.osnum);
   

  } else {
  /* selection took place via knot table */
  proparms.u = *knotpu;
}
 if(me->command == PROCESS_INS_KNOT) {
   /* here we do not select a point on an existing knot value but
      at a curve parameter value closest to the boreline first point */
   mvp[X] = ppp[X];
   mvp[Y] = ppp[Y];
   mvp[Z] = ppp[Z];
   *knotpu = proparms.u;
   
 } else {
   /* in all other cases we determine an existing knot value closest
      to the parameter value of the the boreline projection */
   /*if(proparms.u < me->knots[i])
      diff0 = me->knots[0] - proparms.u;
   else
      diff0 = proparms.u - me->knots[0];*/
   diff0 = proparms.u - me->knots[0];
   j = 0;
   for(i=1;i<me->nknot;i++) {
    if(proparms.u < me->knots[i])
      diff = me->knots[i] - proparms.u;
    else
      diff = proparms.u - me->knots[i];
    if (diff < diff0) {
      diff0 = diff;
      j = i;
    }
   }

   uv[0] = me->knots[j];
   uv[1] = 0.0; 
   *vix = j;
   /* determine the point for the existing knot value */
   stat_OM = om$send(msg = message GRvg.EMptatpr(
                         &msg_loc,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                         uv,
                         1,
                         mvp),
                   targetid = me->curve_id.objid,
                   targetos = me->curve_id.osnum);
   FIfld_set_active_row(me->mainform, M_FREE_MCF, j, 0);
   sprintf(fmessage,"Knot No %d selected", j);
   FIg_set_text(me->mainform, M_MSG_F, fmessage); 
   stat_OM = om$send(msg = message ECascrcr.highl_point(
                            &msg_loc,
                            mvp),
                     targetid = my_id);
 }
 
 return(OM_S_SUCCESS);
}

method select_ls_point(IGRlong *msg; IGRpoint p; IGRint *row; IGRint *pos)
{
   /***select_ls_point***/
   IGRlong stat_OM, msg_loc;
   IGRint j=0;
   IGRpoint pp;
   IGRchar fmessage[MSG_F_L];

   
   stat_OM = om$send(msg = message ECascrcr.project_point(
                            &msg_loc,
                            p,
                            pp),
                     targetid = my_id);
   stat_OM = om$send(msg = message ECascrcr.highl_point(
                            &msg_loc,
                            pp),
                     targetid = my_id);

   for(j=0;j < me->nvx; j++) {
      if(me->vxt[j].xp ==  pp[X] 
       && me->vxt[j].yp == pp[Y]
       && me->vxt[j].zp == pp[Z]) {
          *row = j;
       if(me->first_point) {
         me->first_point = FALSE;
         break;
       }
      }
   }
   if (me->edtform_requested) {
      sprintf(fmessage,"Vertex No %d selected", *row);
      FIfld_set_active_row(me->edtform, E_MCOL_F,  *row, *pos);
      FIfld_set_active_row(me->edtform, E_VERTEX_F,  *row, *pos);
      FIg_set_text(me->edtform, E_MSG_F, fmessage); 
   } else if(me->mainform_requested) {
      FIfld_set_active_row(me->mainform, M_FREE_MCF,  *row, *pos);
      sprintf(fmessage,"Parameter No %d selected", *row);
      FIg_set_text(me->mainform, M_MSG_F, fmessage); 
   }              
   return (OM_S_SUCCESS);

}

method project_point(IGRlong *msg; IGRpoint p; IGRpoint pp)
{
 /***project_point***/
 IGRlong msg_loc, stat_OM;
 IGRdouble t=0.0;
 IGRpoint ppp, pnt1, pnt2;
 struct GRparms Segment1, Segment2, proparms;
 struct IGRline 	boreline;

 if(!me->form_event_handling)
 {
   boreline.point1 = pnt1;  /* allocates storage for */
   boreline.point2 = pnt2;  /* the boreline          */

   EFboreline(&msg_loc, my_id, &me->accev, &boreline);

   stat_OM = om$send(msg = message GRgraphics.GRlnproject(&msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &boreline,
                          p, 
                          ppp, 
                          &t, 
                          &proparms),
                    senderid = my_id,
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum);

  } else {
    stat_OM = om$send(mode = OM_e_wrt_object,
                    msg = message GRgraphics.GRptproject(&msg_loc,       
                           &me->md_env.md_env.matrix_type,
                           me->md_env.md_env.matrix,
			   p,ppp,
			   &proparms),
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum );
  }
  if(proparms.u < 0.5)
    me->first_point = TRUE;
  else
    me->first_point = FALSE;
  stat_OM = om$send(
               msg = message GRlinear.GRvtadjseg(
                      &msg_loc,
                      &me->md_env.md_env.matrix_type,
                      me->md_env.md_env.matrix,
                      &proparms,
                      ppp,
                      pp,
                      &Segment1,
                      &Segment2 ),
               targetid = me->ls_info.located_obj.objid,
               targetos = me->ls_info.located_obj.osnum );

  stat_OM = om$send(mode = OM_e_wrt_object,
                    msg = message GRgraphics.GRptproject(&msg_loc,       
                           &me->md_env.md_env.matrix_type,
                           me->md_env.md_env.matrix,
			   pp,ppp,
			   &me->vxparms),
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum );

#if dflT9
 printf("segment1 u= %e  inx= %d\n", Segment1.u, Segment1.polygon_inx);
 printf("segment2 u= %e  inx= %d\n", Segment2.u, Segment2.polygon_inx);
 printf("vxparms u= %e  inx= %d\n", me->vxparms.u, me->vxparms.polygon_inx);
 printf("point ppx= %e ppy= %e ppz= %e\n", pp[X], pp[Y], pp[Z]);
 printf("point pppx= %e pppy= %e pppz= %e\n", ppp[X], ppp[Y], ppp[Z]);
#endif
 return (OM_S_SUCCESS);
}

method det_neighbours(IGRlong *msg; IGRpoint p; struct IGRline *boreline; IGRint *no_pts; IGRpoint pnts)
{
 IGRboolean found;
 IGRlong msg_loc, stat_OM;
 IGRint j=0;
 IGRdouble t=0.0;
 IGRpoint pp, ppp;
 struct GRparms segparm, Segment1, Segment2, ppparm;
 
 *msg = OM_S_SUCCESS;
 stat_OM = om$send(msg = message GRgraphics.GRlnproject(&msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          boreline,
                          p, 
                          ppp, 
                          &t, 
                          &segparm),
                    senderid = my_id,
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum);

  stat_OM = om$send(
               msg = message GRlinear.GRvtadjseg(
                      &msg_loc,
                      &me->md_env.md_env.matrix_type,
                      me->md_env.md_env.matrix,
                      &segparm,
                      ppp,
                      pp,
                      &Segment1,
                      &Segment2 ),
               targetid = me->ls_info.located_obj.objid,
               targetos = me->ls_info.located_obj.osnum );
 
 found = FALSE;
 for(j=0;j < me->nvx; j++) {
   if(pp[X] == me->vxt[j].xp) {
     if(pp[Y] == me->vxt[j].yp) {
       if(pp[Z] == me->vxt[j].zp) {
          ppparm.u = (IGRdouble) j/(IGRdouble)(me->nvx-1);
          found = TRUE;
       }
     }
   }
   if(found) 
     break;
 }


 if(j == 0 && ppparm.u == segparm.u) {
     *no_pts = 1;
     pnts[X] = me->vxt[0].xp;
     pnts[Y] = me->vxt[0].yp;
     pnts[Z] = me->vxt[0].zp;
     return (OM_S_SUCCESS);
 }
 if(j == me->nvx-1 && ppparm.u == segparm.u) {
     *no_pts = 1;
     pnts[X] = me->vxt[me->nvx-1].xp;
     pnts[Y] = me->vxt[me->nvx-1].yp;
     pnts[Z] = me->vxt[me->nvx-1].zp;
     return (OM_S_SUCCESS);
 }

 *no_pts = 2;
 pnts[X] = me->vxt[j].xp;
 pnts[Y] = me->vxt[j].yp;
 pnts[Z] = me->vxt[j].zp;
 if (ppparm.u > segparm.u) {
   pnts[6] = me->vxt[j-1].xp;
   pnts[7] = me->vxt[j-1].yp;
   pnts[8] = me->vxt[j-1].zp;
 } else {
   pnts[6] = me->vxt[j+1].xp;
   pnts[7] = me->vxt[j+1].yp;
   pnts[8] = me->vxt[j+1].zp;
 } 

 return(OM_S_SUCCESS);
     
}

method det_neighb2(IGRlong *msg; IGRlong row;  IGRint *no_pts; IGRpoint pnts)
{
 *msg = OM_S_SUCCESS;



  if(row == 0) {
     *no_pts = 1;
     pnts[X] = me->vxt[1].xp;
     pnts[Y] = me->vxt[1].yp;
     pnts[Z] = me->vxt[1].zp;
     return (OM_S_SUCCESS);
 }
 if(row == me->nvx-1) {
     *no_pts = 1;
     if(PROCESS_EDIT_VERTEX) {
        pnts[X] = me->vxt[me->nvx-2].xp;
        pnts[Y] = me->vxt[me->nvx-2].yp;
        pnts[Z] = me->vxt[me->nvx-2].zp;
     } else {
        pnts[X] = me->vxt[me->nvx-1].xp;
        pnts[Y] = me->vxt[me->nvx-1].yp;
        pnts[Z] = me->vxt[me->nvx-1].zp;
     }
     return (OM_S_SUCCESS);
 }

 *no_pts = 2;
 pnts[X] = me->vxt[row-1].xp;
 pnts[Y] = me->vxt[row-1].yp;
 pnts[Z] = me->vxt[row-1].zp;
 pnts[6] = me->vxt[row+1].xp;
 pnts[7] = me->vxt[row+1].yp;
 pnts[8] = me->vxt[row+1].zp;


 return(OM_S_SUCCESS);
     
}


method insert_vertex(IGRlong *msg; IGRpoint p; IGRint ptno;struct IGRline *boreline;IGRint *p1seg)
{
 /***insert_vertex***/
 IGRlong msg_loc, stat_OM;
 GRobjid dummyobj;
 enum GRdpmode 	dpmode;
 IGRpoint ppp, pt1, pt2;
 struct IGRline bline;
 struct GRparms segparm, ptparm;
 
 dpmode = GRbe;
 stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay (
                          &msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &dpmode, 
                          &me->md_env.md_id),
                   senderid = my_id,
                   targetid = me->ls_info.located_obj.objid,
                   targetos = me->ls_info.located_obj.osnum);
   pt1[X] = me->vxt[ptno].xp;
   pt1[Y] = me->vxt[ptno].yp;
   pt1[Z] = me->vxt[ptno].zp;
   
   me->XXXXX = 8111;
   if(!me->form_event_handling) {
     if(me->no_pts == 1)
       stat_OM = om$send(mode = OM_e_wrt_object,
                    msg = message GRgraphics.GRptproject(&msg_loc,       
                           &me->md_env.md_env.matrix_type,
                           me->md_env.md_env.matrix,
			   pt1,ppp,
			   &segparm),
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum );
     else {
       me->accev.event.button.x = me->sel_pt[X];
       me->accev.event.button.y = me->sel_pt[Y];
       me->accev.event.button.z = me->sel_pt[Z];
       bline.point1 = pt1;
       bline.point2 = pt2;
       EFboreline(&msg_loc,my_id, &me->accev, &bline);
       stat_OM = om$send(mode = OM_e_wrt_object,
                    msg = message GRgraphics.GRptproject(&msg_loc,       
                           &me->md_env.md_env.matrix_type,
                           me->md_env.md_env.matrix,
			   pt1,ppp,
			   &segparm),
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum );
     }
   } else {
       stat_OM = om$send(mode = OM_e_wrt_object,
                    msg = message GRgraphics.GRptproject(&msg_loc,       
                           &me->md_env.md_env.matrix_type,
                           me->md_env.md_env.matrix,
			   p,ppp,
			   &segparm),
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum );
   }

   ptparm.u =  ((1.0/((double) me->nvx - 1.0)) * (double)ptno);

   if((segparm.u > ptparm.u) || ((segparm.u == 1.0) && (ptparm.u == 1.0)))
     *p1seg = 1;  
   else 
     *p1seg = 0;

   if(!me->assoc_delay_set) {
      /* set associative delay */
      nd$mod_batch(request = ND_SET,
                   req_mode = ND_DEFER);
      GRdelay_button(GR_DELAY_ON);
      me->assoc_delay_set = TRUE;
   }
 
   stat_OM = om$send (msg = message GRcurve.GRinsvertex(
                           &msg_loc,
                           &me->md_env,
                           &segparm,
                           boreline,
                           &dummyobj),
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum);
   dpmode = GRbd;
   stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay (
                          &msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &dpmode, 
                          &me->md_env.md_id),
                   senderid = my_id,
                   targetid = me->ls_info.located_obj.objid,
                   targetos = me->ls_info.located_obj.osnum);
   return (OM_S_SUCCESS);

}

method delete_vertex(IGRlong *msg)
{
 /***delete_vertex***/
 IGRlong msg_loc, stat_OM;
 GRobjid dummyobj;
 enum GRdpmode 	dpmode;
 
 dpmode = GRbe;
 stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay (
                          &msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &dpmode, 
                          &me->md_env.md_id),
                   senderid = my_id,
                   targetid = me->ls_info.located_obj.objid,
                   targetos = me->ls_info.located_obj.osnum);
 if(!me->assoc_delay_set) {

      nd$mod_batch(request = ND_SET,
                   req_mode = ND_DEFER);
      GRdelay_button(GR_DELAY_ON);
      me->assoc_delay_set = TRUE;
 }

      stat_OM = om$send(msg = message ECascrcr.putpolyline(
                              &msg_loc),
                        targetid = my_id);
/* stat_OM = om$send (msg = message GRlinear.GRdelvertex(
                           &msg_loc,
                           &me->md_env,
                           &me->vxparms,
                           &dummyobj),
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum);*/
 dpmode = GRbd;
 stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay (
                          &msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &dpmode, 
                          &me->md_env.md_id),
                   senderid = my_id,
                   targetid = me->ls_info.located_obj.objid,
                   targetos = me->ls_info.located_obj.osnum);
 return (OM_S_SUCCESS);

}

method undo_last_edit(IGRlong *msg)
{
 IGRlong stat_OM, msg_loc;
 IGRint row=0, i=0, j=0, dum1=0;
 IGRpoint pnt1, pnt2;
 struct IGRline boreline;
 enum GRdpmode 	dpmode;
 struct GRpost_info info;
 struct GRid tobj;
 struct IGRpolyline polyline;
 IGRdouble *polypts;

 *msg = OM_S_SUCCESS;
 me->XXXXX = 4000;
 switch(me->undo_type)
   {
     case UNDO_TYPE_DELETE:
       me->nvx += 1;
       me->npara += 1;
       row = me->utbl[0].nvno;

       FIfld_insert_blank_row(me->edtform, E_VERTEX_F, row);
       for(i=row;i<me->nvx;i++)
          FIfld_set_value(me->edtform, E_VERTEX_F, i, VNC , (double)i,0); 

       for(i=me->nvx;i > row; i--) {
          me->vxt[i] = me->vxt[i-1];
          me->vxt[i].nvno = i;
       }
       me->XXXXX = 9012;
       me->vxt[row] = me->utbl[0];
       if(me->vxt[row].ta[0] == '*') { 
           me->nta += 1;
           me->ncon += 1;
       }
       if(me->vxt[row].fxp[0] == '*') { 
           me->nfp += 1;
           me->ncon += 1;
       }
       FIfld_insert_blank_row(me->edtform, E_MCOL_F, row);
      
       FIfld_set_value(me->edtform, E_VERTEX_F, row, VNC , (IGRdouble) row,0); 
       FIfld_set_value(me->edtform, E_MCOL_F, row, XC, me->utbl[0].xp,0); 
       FIfld_set_value(me->edtform, E_MCOL_F, row, YC, me->utbl[0].yp,0); 
       FIfld_set_value(me->edtform, E_MCOL_F, row, ZC, me->utbl[0].zp,0);
       FIfld_set_text(me->edtform, E_MCOL_F, row, FXC, me->utbl[0].fxp,0); 
       FIfld_set_value(me->edtform, E_MCOL_F, row, FAC, me->utbl[0].fac,0); 
       FIfld_set_text(me->edtform, E_MCOL_F, row, TAC,  me->utbl[0].ta,0); 
       FIfld_set_value(me->edtform, E_MCOL_F, row, TAX, me->utbl[0].tav[X],0); 
       FIfld_set_value(me->edtform, E_MCOL_F, row, TAY, me->utbl[0].tav[Y],0); 
       FIfld_set_value(me->edtform, E_MCOL_F, row, TAZ, me->utbl[0].tav[Z],0); 
       boreline.point1 = pnt1;  /* allocates storage for */
       boreline.point2 = pnt2;  /* the boreline          */
       pnt1[X] = me->utbl[0].xp;      
       pnt1[Y] = me->utbl[0].yp;      
       pnt1[Z] = me->utbl[0].zp;      

       EFboreline(&msg_loc,my_id, &me->ls_info, &boreline);

       stat_OM = om$send(msg = message ECascrcr.insert_vertex(
                                       &msg_loc,
                                       pnt1,
                                       row,
                                       &boreline,
                                       &dum1),
                         targetid = my_id);
              
       put_msg(&me->edtform, E_MSG_F, VDEL_UNDONE);
       ex$message (msgnumb = EMS_I_VDEL_UNDONE);

       break;

     case UNDO_TYPE_MODIFY:

       for(i=0;i<me->undo_num;i++) {

          row = me->utbl[i].nvno;

          if(me->vxt[row].fxp[0] != me->utbl[i].fxp[0]) {
            if(me->utbl[i].fxp[0] == '*') {
              me->nfp += 1;
              me->ncon += 1;
            } else {
              me->nfp -= 1;
              me->ncon -= 1;
            }
	  }
          if(me->vxt[row].ta[0] != me->utbl[i].ta[0]) {
            if(me->utbl[i].ta[0] == '*') { 
              me->nta += 1;
              me->ncon += 1;
            } else {
              me->nta -= 1;
              me->ncon -= 1;
            }
	  }

          me->vxt[row] = me->utbl[i];
          FIfld_set_value(me->edtform, E_MCOL_F, row, XC, me->utbl[i].xp,0); 
          FIfld_set_value(me->edtform, E_MCOL_F, row, YC, me->utbl[i].yp,0); 
          FIfld_set_value(me->edtform, E_MCOL_F, row, ZC, me->utbl[i].zp,0);
          FIfld_set_text(me->edtform, E_MCOL_F, row, FXC, me->utbl[i].fxp,0); 
          FIfld_set_value(me->edtform, E_MCOL_F, row, FAC,me->utbl[i].fac,0); 
          FIfld_set_text(me->edtform, E_MCOL_F, row, TAC, me->utbl[i].ta,0); 
          FIfld_set_value(me->edtform, E_MCOL_F, row, TAX,me->utbl[i].tav[X],0); 
          FIfld_set_value(me->edtform, E_MCOL_F, row, TAY,me->utbl[i].tav[Y],0); 
          FIfld_set_value(me->edtform, E_MCOL_F, row, TAZ,me->utbl[i].tav[Z],0);
       } 

       dpmode = GRbe;
       stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay (
                          &msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &dpmode, 
                          &me->md_env.md_id),
                    senderid = my_id,
                    targetid = me->ls_info.located_obj.objid,
                    targetos = me->ls_info.located_obj.osnum);

       polypts = (IGRdouble *) om$malloc(
                  size = (me->nvx * 3) * sizeof(IGRdouble));
       if(!polypts) 
         REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(polypts)",function_end);

       /* get the points */
       for(i=0,j=0;i<me->nvx;i++,j+=3) {
         polypts[j] = me->vxt[i].xp;
         polypts[j+1] = me->vxt[i].yp;
         polypts[j+2] = me->vxt[i].zp;
       }
       polyline.num_points = me->nvx;
       polyline.points = polypts;

       if(!me->assoc_delay_set) {
         /* set associative delay */
         nd$mod_batch(request = ND_SET,
                   req_mode = ND_DEFER);
         GRdelay_button(GR_DELAY_ON);
         me->assoc_delay_set = TRUE;
       }
       stat_OM = om$send(mode = OM_e_wrt_object,
              	   msg = message GR3dlinestr.GRputpolyline(
                              &msg_loc,
                              &me->md_env,
                              &info,
                              &polyline,
                              &tobj.objid),
                         senderid = my_id,
                         targetid = me->ls_info.located_obj.objid,
                         targetos = me->ls_info.located_obj.osnum);

       dpmode = GRbd;
       stat_OM = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay (
                          &msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &dpmode, 
                          &me->md_env.md_id),
                   senderid = my_id,
                   targetid = ME.ECelement->elem.located_obj.objid,
                   targetos = ME.ECelement->elem.located_obj.osnum);

       if(polypts) om$dealloc(ptr = polypts);

          
       put_msg(&me->edtform, E_MSG_F, VMOD_UNDONE);
       ex$message (msgnumb = EMS_I_VMOD_UNDONE);

       break;

     default:
       break;
   }
   me->undo_type = UNDO_COMPLETED;

function_end:
   return(stat_OM);
}

method highl_point(IGRlong *msg; IGRpoint p)
{
 /***highl_point***/

 IGRlong msg_loc;
 struct GRsymbology s;

 *msg = OM_S_SUCCESS;
 if(!(me->highl_pt.objid == 0)) {
   gr$delete_object(msg = &msg_loc,
                    md_env = NULL,
                    object_id = &me->highl_pt);
 }

 gr$place_linear_object(msg = &msg_loc,
                        md_env = NULL,
                        num_points = 1,
                        points = p,
                        object_id = &me->highl_pt,
                        name = NULL,
                        display_flag = 0);
 gr$get_symbology (object_id = &me->highl_pt,
                   symb = &s);
 s.display_attr.color = me->sptco;
 s.display_attr.weight = me->sptwt;
 gr$put_symbology (object_id = &me->highl_pt,
                   symb = &s);
 gr$display_object (object_id = &me->highl_pt,
                    md_env = NULL,
                    mode = GRbd);

 return (OM_S_SUCCESS);

}


method get_poly_instances(IGRlong *msg)
{
 /***get_poly_instance***/
  IGRint i=0, action=0;
  IGRint num_doubles=0, num_ele=0;
  IGRlong msg_loc, stat_OM;
  struct IGRpolyline polyline;
  IGRdouble *polypts = NULL;
  
 stat_OM = msg_loc = OM_S_SUCCESS;
 action = 0;
 stat_OM = om$send (msg = message GR3dlinestr.GRgetpolyline(
                           msg,
                           &me->md_env.md_env.matrix_type,
                           me->md_env.md_env.matrix,
                           &action,
                           &polyline),
                    targetid = ME.ECelement->elem.located_obj.objid,
                    targetos = ME.ECelement->elem.located_obj.osnum);
 TEST_ERROR(stat_OM,msg_loc,"GRgetpolyline1",function_end);
                           
 polypts = (IGRdouble *) om$malloc(
                  size = (polyline.num_points * 3) * sizeof(IGRdouble));
 if(!polypts) 
   REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(polypts)",function_end);

 polyline.points = polypts;
 action = 1; /* get polyline itself */
 stat_OM = om$send (msg = message GR3dlinestr.GRgetpolyline(
                           &msg_loc,
                           &me->md_env.md_env.matrix_type,
                           me->md_env.md_env.matrix,
                           &action,
                           &polyline),
                    targetid = ME.ECelement->elem.located_obj.objid,
                    targetos = ME.ECelement->elem.located_obj.osnum);
 TEST_ERROR(stat_OM,msg_loc,"GRgetpolyline2",function_end);

 num_doubles = polyline.num_points * 3;
 num_ele = om$dimension_of(varray = me->opts); 
 if (num_doubles > num_ele) {
    stat_OM = om$vla_set_dimension(varray = me->opts,
                                   size = num_doubles + 30);
    TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",function_end);
 }  
 num_ele = om$dimension_of(varray = me->vxt); 
 if (polyline.num_points > num_ele) {
    stat_OM = om$vla_set_dimension(varray = me->vxt,
                                   size = polyline.num_points + 10);
    TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",function_end);
 }  
 for(i=0;i<polyline.num_points;i++) {
      me->vxt[i].fac = 0.0;
      me->vxt[i].fxp[0] = ' ';
      me->vxt[i].ta[0] = ' ';
 }

 for(i=0;i<num_doubles;i++) {
   me->opts[i] = polyline.points[i];
 }
 me->opl.num_points = polyline.num_points;
 me->nvx = me->opl.num_points;
 me->opl.points = me->opts;
 me->XXXXX = 9631;

function_end:
 *msg = msg_loc;
 if(polypts) 
   om$dealloc(ptr = polypts);

 return (stat_OM);
}  
 
method fill_tables(IGRlong *msg; struct v_info *asinfo)
{
  /***fill_tables***/
  IGRint n=0, i=0, j=0, k=0, l=0, m=0;
  IGRint num_ele=0;
  IGRlong msg_loc, stat_OM;
  IGRchar 		        *char_info = NULL;
  
  stat_OM = msg_loc = OM_S_SUCCESS;

  /* allocate memory for different tables */
  me->XXXXX = 4321;
  if(me->curve_exists) {
    num_ele = om$dimension_of(varray = me->tat);
    if(asinfo->nta > num_ele) {
      stat_OM = om$vla_set_dimension(varray = me->tat,
                                   size = asinfo->nta + DFT_EMP);
      TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",function_end);
    }
    num_ele = om$dimension_of(varray = me->fxt);
    if(asinfo->nfp > num_ele) {
      stat_OM = om$vla_set_dimension(varray = me->fxt,
                                   size = asinfo->nfp + DFT_EMP);
      TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",function_end);
    }
    num_ele = om$dimension_of(varray = me->fat);
    if(asinfo->nfa > num_ele) {
      stat_OM = om$vla_set_dimension(varray = me->fat,
                                   size = asinfo->nfa + DFT_EMP);
      TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",function_end);
    }
    num_ele = om$dimension_of(varray = me->knots);
    if(asinfo->nknot > num_ele) {
      stat_OM = om$vla_set_dimension(varray = me->knots,
                                   size = asinfo->nknot + DFT_EMP);
      TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",function_end);
    }
    num_ele = om$dimension_of(varray = me->paras);
    if(asinfo->npara > num_ele) {
      stat_OM = om$vla_set_dimension(varray = me->paras,
                                   size = asinfo->npara + DFT_EMP);
      TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",function_end);
    }

   char_info = asinfo->char_data; 
   /* get tangents information */ 
   me->nta = asinfo->nta;
   me->ncon = me->nta;
   for(i=0,j=0;i<asinfo->nta;i++) {
     OM_BLOCK_MOVE(char_info, &me->tat[i].nvno,sizeof(IGRlong));
     me->tat[i].nvno -= 1;
     char_info = char_info + sizeof(IGRlong);
     OM_BLOCK_MOVE(char_info, &me->tat[i].tav[X],sizeof(IGRdouble));
     char_info = char_info + (sizeof(IGRdouble));
     OM_BLOCK_MOVE(char_info, &me->tat[i].tav[Y],sizeof(IGRdouble));
     char_info = char_info + (sizeof(IGRdouble));
     OM_BLOCK_MOVE(char_info, &me->tat[i].tav[Z],sizeof(IGRdouble));
     char_info = char_info + (sizeof(IGRdouble));
   }
   /* get fix point information */ 
   me->nfp = asinfo->nfp;
   me->ncon += me->nfp;
   for(i=0;i<asinfo->nfp;i++) {
     OM_BLOCK_MOVE(char_info, &me->fxt[i].nvno,sizeof(IGRlong));
     me->fxt[i].nvno -= 1;
     char_info = char_info + sizeof(IGRlong);
   }

   /* get factor information */
   me->nfa = asinfo->nfa; 
   for(i=0;i<asinfo->nfa;i++) {
     OM_BLOCK_MOVE(char_info, &me->fat[i].nvno,sizeof(IGRlong));
     me->fat[i].nvno -= 1;
     char_info = char_info + sizeof(IGRlong);
     OM_BLOCK_MOVE(char_info, &me->fat[i].fac,sizeof(IGRdouble));
     char_info = char_info + sizeof(IGRdouble);
   }

   /* get knot vector information */ 
   me->nknot = asinfo->nknot;
   for(i=0;i<asinfo->nknot;i++) {
     OM_BLOCK_MOVE(char_info, &me->knots[i],sizeof(IGRdouble));
     char_info = char_info + sizeof(IGRdouble);
   }
   /* get para vector information */ 
   me->npara = asinfo->npara;
   for(i=0;i<asinfo->npara;i++) {
     OM_BLOCK_MOVE(char_info, &me->paras[i],sizeof(IGRdouble));
     char_info = char_info + sizeof(IGRdouble);
   }

   /* get curvature vector information */ 
   for(i=0;i<6;i++) {
     me->mfp.cv_vector[i] = asinfo->cv_vector[i];
   }
   me->mfp.order = asinfo->order;
   me->mfp.nspans = asinfo->nspans;
   me->mfp.npole = asinfo->npole;
   me->mfp.smfac = asinfo->smfac;
   me->mfp.opt_curv0 = asinfo->opt_curv0;
   me->mfp.opt_curv1 = asinfo->opt_curv1;
   me->mfp.rad0 = asinfo->rad0;
   me->mfp.rad1 = asinfo->rad1;
   me->mfp.opt_iter = 0;
   me->mfp.power = asinfo->power;
   me->rho = asinfo->rho;
   strcpy(me->mfp.para_type,asinfo->para_type);
   strcpy(me->old_para_type,asinfo->para_type);
   strcpy(me->mfp.knot_type,asinfo->knot_type);
   strcpy(me->old_knot_type,asinfo->knot_type);
  } else {
    me->nta = 0;
    me->nfp = 0;
    me->nfa = 0;
    if(me->to_next_linestring) {
      if(!strncmp(me->mfp.knot_type,FREE_T,strlen(FREE_T))) {
        strcpy(me->mfp.knot_type,UNIFORM_T);
        FIg_set_text(me->mainform,M_KNOT_F,UNIFORM_T);
      } 
      if(!strncmp(me->mfp.para_type,FREE_T,strlen(FREE_T))) {
        strcpy(me->mfp.para_type,CENTRIPEDAL_T);
        FIg_set_text(me->mainform,M_PARA_F,CENTRIPEDAL_T);
      } 
    }

    set_main_dfpar(&me->mfp,me->to_next_linestring);

    strcpy(me->old_knot_type,me->mfp.knot_type);
    strcpy(me->old_para_type,me->mfp.para_type);
    me->npara = me->nvx;
    me->vxt[0].fxp[0] = '*';
    me->vxt[me->nvx-1].fxp[0] = '*';
    me->nfp = 2;
    me->ncon = 2;
  }
 
  /*n = me->opl.num_points * 3 */;
  /* look if vertex table in instance is big enough to hold the data */
  num_ele = om$dimension_of(varray = me->vxt); 
  if (me->nvx > num_ele) {
    stat_OM = om$vla_set_dimension(varray = me->vxt,
                                   size = n + DFT_EMP);

    TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",function_end);
  }
  
  for(i=j=k=l=m=0; j<me->nvx; j++) {
     if(me->fxt[k].nvno == j && me->nfp > 0) {
       strcpy(me->vxt[j].fxp,"*  ");
       k++;
     }

     if(me->tat[m].nvno == j && me->nta > 0) {
       me->vxt[j].tav[X] = me->tat[m].tav[X];
       me->vxt[j].tav[Y] = me->tat[m].tav[Y];
       me->vxt[j].tav[Z] = me->tat[m].tav[Z];
       strcpy(me->vxt[j].ta,"* ");
       m++;
     }

     if(me->fat[l].nvno == j && me->nfa > 0) {
      me->vxt[j].fac = me->fat[l].fac;
      l++;
     }

    me->vxt[j].nvno = j;
    me->vxt[j].xp = me->opts[i++];
    me->vxt[j].yp = me->opts[i++];
    me->vxt[j].zp = me->opts[i++]; 
   }
   if(!me->curve_exists) {
      /* compute new para vector */
    stat_OM = om$send(msg = message ECascrcr.comp_para_vector(
                           &msg_loc),
                    targetid = my_id);
  

    /* compute new knot vector */
    stat_OM = om$send(msg = message ECascrcr.comp_knot_vector(
                           &msg_loc),
                    targetid = my_id);
   }


function_end:
  *msg = msg_loc;
  return(stat_OM);
} 

method fill_form_tbl(IGRlong *msg)
{
  /***fill_form_table***/
  IGRint n=0, j=0, k=0, l=0, m=0;
  IGRlong msg_loc, stat_OM;
  
  stat_OM = msg_loc = OM_S_SUCCESS;
 
  FIfld_set_max_num_rows(me->edtform,E_MCOL_F, 0);
  FIfld_set_max_num_rows(me->edtform,E_VERTEX_F, 0);
  /*FIfld_set_num_rows(me->edtform,E_MCOL_F, me->nvx);
  FIfld_set_num_rows(me->edtform,E_VERTEX_F, me->nvx);*/
  
  n = me->nvx * 3;

  for(j=k=l=m=0; j<me->nvx; j++) {
     if(me->vxt[j].fxp[0] == '*') 
        FIfld_set_text(me->edtform, E_MCOL_F, j, FXC, "*  ", 0);

     if(me->vxt[j].ta[0] == '*') 
       FIfld_set_text(me->edtform, E_MCOL_F, j, TAC, "* ", 0);

     if(me->vxt[j].fac > 0) 
      FIfld_set_value(me->edtform, E_MCOL_F, j, FAC, me->vxt[j].fac, 0);

    FIfld_set_value(me->edtform, E_VERTEX_F, j, VNC, (double) j, 0);
    FIfld_set_value(me->edtform, E_MCOL_F, j, XC, me->vxt[j].xp,0);
    FIfld_set_value(me->edtform, E_MCOL_F, j, YC, me->vxt[j].yp,0);
    FIfld_set_value(me->edtform, E_MCOL_F, j, ZC, me->vxt[j].zp,0);
  }

function_end:

  *msg = msg_loc;  
  return(stat_OM);
} 

end implementation ECascrcr;

