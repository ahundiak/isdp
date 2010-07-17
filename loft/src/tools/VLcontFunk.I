class implementation VLabstract;

#include <stdio.h>
#include <math.h>
#include "vlprototype.h"
#include "OMerrordef.h"
#include "macro.h"
#include "OMprimitives.h"
#include "asmacros.h"
#include "AS_status.h"
#include "ndmacros.h"
#include "nddef.h"
#include "bstypes.h"
#include "bserr.h"
#include "grdpbdef.h"
#include "expmacros.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "emsdef.h"
#include "grdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "coparamac.h"
#include "vsplatedef.h"
#include "bsparameters.h"
#include "bsdefs.h"
#include "EMSopt.h"		
#include "grmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "vsmiscmacros.h"
#include "vsedgedef.h"
#include "vldbgmacros.h"
#include "vsedgemacros.h"
#include "bsvalues.h"
#include "bsmdstptcv.h"
#include "bssplitcv2.h"
#include "bsmerge_cv.h"
#include "bsarclen.h"
#include "bscvmidpt.h"
#include "bscvcv_int.h"

#include	"vlmsg.h"
#include	"vlplatejig.h"

from  EMSsurface  import  EMgetedges;
from  EMSedge     import EMget_bcxyz_geom;

extern	struct GRid NULL_GRID;
extern  ASstart_fence();
extern  ASstart_var_fence();
extern  ASget_active_symb();
extern  GRdpb_get();
extern  VLinitCnst();
extern  GRdisplay_object();
extern  MAmulmx();
extern  void BScveval();
extern  IGRboolean  BSnorvec();
extern  BSdotp();
 
#define MAX_PLATES      MACRO_J_VTEMP
#define MAX_EDGES       (5 * MAX_PLATES)
#define ANGLE           (cos(M_PI/18.0))
#define MAX_TOL 	6.0

/*#define DEBUG*/

extern GRclassid OPP_GR3dlineseg_class_id;
extern GRclassid OPP_GRbspline_class_id;
extern GRclassid OPP_GRbcsubbc_class_id;
extern GRclassid OPP_VSimgFeature_class_id;
extern GRclassid OPP_VSplate_class_id;

IGRdouble	EPS,EPS1,DIS_EPS; 
static struct GRobj_env	surf[MAX_PLATES]; /* surfaces supporting plates */

/* *********************** VLdel *********************** */
/*
/*       free memory.
/*
/* */
void VLdel (bsp)
struct IGRbsp_curve  *bsp; /* I: structure to free */
{
  if( bsp->poles ){ om$dealloc( ptr=bsp->poles ); bsp->poles = NULL;}
  if( bsp->knots ){ om$dealloc( ptr=bsp->knots ); bsp->knots = NULL;}
  if( bsp->weights ){ om$dealloc( ptr=bsp->weights ); bsp->weights = NULL;}
  if( bsp->bdrys ){ om$dealloc( ptr=bsp->bdrys ); bsp->bdrys = NULL;}
}

/* *********************** VLdel_mem *********************** */
/*
/*       free memory.
/*
/* */
void VLdel_mem(nb_plates,num,tab) 
int 	nb_plates;                /* I : number of plates */
int 	*num;                     /* I : number of edges of each plate */
struct IGRbsp_curve	***tab;   /* I : structure to free */
{
IGRint	ii;
IGRlong	jj;
  for (ii=0; ii< nb_plates; ii = ii + 1)
  {
    for (jj=0; jj<num[ii]; jj++)
    {
      VLdel(tab[ii][jj]);
      if (tab[ii][jj]) {om$dealloc( ptr=tab[ii][jj]); tab[ii][jj] = NULL;}
    }
    if (tab[ii]) {om$dealloc( ptr=tab[ii]); tab[ii] = NULL;}
  }
}

/* *********************** VLsame_pole *********************** */
/*
/*       is it the same pole ?
/*
/* */
VLsame_pole (pt1,pt2)
IGRdouble *pt1,*pt2; /* I : two points */
{
  if (
      ((pt1[0] - pt2[0] <= EPS) && (pt1[0] - pt2[0] >= -EPS)) &&
      ((pt1[1] - pt2[1] <= EPS) && (pt1[1] - pt2[1] >= -EPS)) &&
      ((pt1[2] - pt2[2] <= EPS) && (pt1[2] - pt2[2] >= -EPS))
     ) {
     /* AVOID PRECISION PROBLEMS */
      pt1[0] = pt2[0];
      pt1[1] = pt2[1];
      pt1[2] = pt2[2];
      return 1;
    }
  else return 0;
}

VLsame_point (pt1, pt2, tol)
IGRdouble *pt1,*pt2, tol; /* I : two points */
{
  if (
      ((pt1[0] - pt2[0] <= tol) && (pt1[0] - pt2[0] >= -tol)) &&
      ((pt1[1] - pt2[1] <= tol) && (pt1[1] - pt2[1] >= -tol)) &&
      ((pt1[2] - pt2[2] <= tol) && (pt1[2] - pt2[2] >= -tol))
     ) {
      return 1;
    }
  else return 0;
}


/* *********************** VLprod *********************** */
/*
/*       test the angle between two edges.
/*
/* */
VLprod (pt1,pt2)
IGRdouble *pt1,*pt2; /* I : two vectors */
{
BSrc	rc;
double pr=0.0;

	BSnorvec ( &rc, pt1); 		if (rc != BSSUCC) return 0;
	BSnorvec ( &rc, pt2);		if (rc != BSSUCC) return 0;
	pr = BSdotp ( &rc, pt1, pt2);	if (rc != BSSUCC) return -1;
	if ( fabs(pr) < ANGLE) {
          return 0;
        }
  	return 1;
}

/* *********************** VLmore_of_mem *********************** */
/*
/*        before merging two curves, this function allocate sufficient memory.
/*
/* */
VLmore_of_mem (cv1,cv2,cvv)
struct IGRbsp_curve *cv1,*cv2, /* I : two curves (which will be merged) */
                    *cvv;      /* O : curve with more of memory */
{
IGRdouble *dbl,*dbl1;
IGRint    jj;

      dbl  = NULL;
      dbl1 = NULL;

      if (cv1->order == cv2->order) {
        dbl = (IGRdouble *) om$malloc(
                  size =((3*(cv1->num_poles+cv2->num_poles-1))*sizeof(double)));
        if (dbl == NULL) return 0;
      }
      if (cv1->order > cv2->order) {
        dbl = (IGRdouble *) om$malloc(
                  size =((3* (cv1->num_poles+cv2->num_poles +
                             ((cv2->num_poles -cv2->order +2)*
                               (cv1->order - cv2->order))))*sizeof(double)));
        if (dbl == NULL) return 0;
      }
      if (cv1->order < cv2->order) {
        dbl = (IGRdouble *) om$malloc(
                  size =((3* (cv1->num_poles+cv2->num_poles +
                             ((cv1->num_poles -cv1->order +2)*
                               (cv2->order - cv1->order))))*sizeof(double)));

       if (dbl == NULL) return 0;
      }
      for (jj=0;jj<3*cvv->num_poles;jj = jj+1) dbl[jj] = cvv->poles[jj];
      om$dealloc(ptr=cvv->poles );
      cvv->poles = dbl; 
      if (cv1->order == cv2->order) {
        dbl1 = (IGRdouble *) om$malloc(
                  size =((3*(cv1->num_knots+cv2->num_knots-1))*sizeof(double)));
        if (dbl1 == NULL) return 0;
      }
      if (cv1->order > cv2->order) {
        dbl1 = (IGRdouble *) om$malloc(
                  size =((3* (cv1->num_knots+cv2->num_knots +
                             ((cv2->num_knots -cv2->order +2)*
                               (cv1->order - cv2->order))))*sizeof(double)));
        if (dbl1 == NULL) return 0;
      }
      if (cv1->order < cv2->order) {
        dbl1 = (IGRdouble *) om$malloc(
                  size =((3* (cv1->num_knots+cv2->num_knots +
                             ((cv1->num_knots -cv1->order +2)*
                               (cv2->order - cv1->order))))*sizeof(double)));
        if (dbl1 == NULL) return 0;
      }
      for (jj=0;jj<3*cvv->num_knots;jj = jj+1) dbl1[jj] = cvv->knots[jj];
      om$dealloc(ptr=cvv->knots );
      cvv->knots = dbl1;
return 1;
}

/* *********************** VLfind_distances *********************** */
/*
/*        find distances of each pole of an edge to the other edge.      
/*
/* */
VLfind_distances(cv1,cv2,disp1cv1,disp2cv1,disp1cv2,disp2cv2,
       parmp1cv1,parmp2cv1,parmp1cv2,parmp2cv2)
struct IGRbsp_curve  *cv1,*cv2; /* I : two curves */
IGRdouble            *disp1cv1,  /* O  : distance of pole1 of cv1 to cv2 */
                     *disp2cv1,  /* O  : distance of pole2 of cv1 to cv2 */
		     *disp1cv2,  /* O  : distance of pole1 of cv2 to cv1 */
                     *disp2cv2;  /* O  : distance of pole2 of cv2 to cv1 */
IGRdouble            *parmp1cv1, /* O  : parameter of pole1 of cv1 on cv2 */
                     *parmp2cv1, /* O  : parameter of pole2 of cv1 on cv2 */
                     *parmp1cv2, /* O  : parameter of pole1 of cv2 on cv1 */
                     *parmp2cv2; /* O  : parameter of pole2 of cv2 on cv1 */
{
BSrc rc;
IGRdouble base[6];


BSmdstptcv(cv1,cv2->poles,parmp1cv2,base,disp1cv2,&rc);
if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		    printf( "Error in BSmdstptcv(1) ...\n");
		    return 0;	}
BSmdstptcv(cv1,&cv2->poles[3*(cv2->num_poles-1)], parmp2cv2,base,disp2cv2,&rc);
if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		    printf( "Error in BSmdstptcv(2) ...\n");
		    return 0;	}
BSmdstptcv(cv2,cv1->poles,parmp1cv1,base,disp1cv1,&rc);
if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		    printf( "Error in BSmdstptcv(3) ...\n");
		    return 0;	}
BSmdstptcv(cv2,&cv1->poles[3*(cv1->num_poles-1)], parmp2cv1,base,disp2cv1,&rc);
if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		    printf( "Error in BSmdstptcv(4) ...\n");
		    return 0;	}
return 1;
}

/* *********************** VLone_in_other *********************** */
/*
/*       if one edge is in the other : edge1 : 1------1, edge2 : !______!,
/*       and they are : 1-----!_-__-__-_-_!-----1
/*
/* */
VLone_in_other(cv1,cv2,disp1cv1,disp2cv1,disp1cv2,disp2cv2,
       parmp1cv1,parmp2cv1,parmp1cv2,parmp2cv2)
struct IGRbsp_curve  *cv1,*cv2; /* IO : two curves */
IGRdouble            disp1cv1,  /* I  : distance of pole1 of cv1 to cv2 */
                     disp2cv1,  /* I  : distance of pole2 of cv1 to cv2 */
		     disp1cv2,  /* I  : distance of pole1 of cv2 to cv1 */
                     disp2cv2;  /* I  : distance of pole2 of cv2 to cv1 */
IGRdouble            parmp1cv1, /* I  : parameter of pole1 of cv1 on cv2 */
                     parmp2cv1, /* I  : parameter of pole2 of cv1 on cv2 */
                     parmp1cv2, /* I  : parameter of pole1 of cv2 on cv1 */
                     parmp2cv2; /* I  : parameter of pole2 of cv2 on cv1 */
{
BSrc rc;
struct IGRbsp_curve  cvv1,cvv2,cvv3,cvv4;
IGRdouble dbl1,dbl2;
IGRdouble base[6];

#ifdef DEBUG
printf("VLone_in_other\n");
printf("cv1: %d\n",cv1->num_poles);
printf("poles1=%lf %lf %lf\n",cv1->poles[0],cv1->poles[1],cv1->poles[2]);
printf("poles2=%lf %lf %lf\n",cv1->poles[3*(cv1->num_poles-1)],cv1->poles[3*(cv1->num_poles-1)+1],cv1->poles[3*(cv1->num_poles-1)+2]);
printf("cv2: %d\n",cv2->num_poles);
printf("poles1=%lf %lf %lf\n",cv2->poles[0],cv2->poles[1],cv2->poles[2]);
printf("poles2=%lf %lf %lf\n",cv2->poles[3*(cv2->num_poles-1)],cv2->poles[3*(cv2->num_poles-1)+1],cv2->poles[3*(cv2->num_poles-1)+2]);
#endif

  cvv1.poles = NULL; cvv1.knots = NULL;
  cvv1.weights = NULL; cvv1.bdrys = NULL;
  cvv2.poles = NULL; cvv2.knots = NULL;
  cvv2.weights = NULL; cvv2.bdrys = NULL;
  cvv3.poles = NULL; cvv3.knots = NULL;
  cvv3.weights = NULL; cvv3.bdrys = NULL;
  cvv4.poles = NULL; cvv4.knots = NULL;
  cvv4.weights = NULL; cvv4.bdrys = NULL;

  if ((disp1cv1 < DIS_EPS && disp1cv1 > -DIS_EPS) &&
      (disp2cv1 < DIS_EPS && disp2cv1 > -DIS_EPS)) {
  						/* if cv1 is "in" cv2 */
    if (
         (parmp1cv1 < EPS1 && parmp1cv1 > -EPS1) || 
                           /* if pole1 of cv1 is projected on pole1 of cv2 */
         ((1-parmp1cv1) < EPS1 && (1-parmp1cv1) > -EPS1)
                           /* if pole1 of cv1 is projected on pole2 of cv2 */
       ) {
      BSsplitcv2(cv2,parmp2cv1,parmp2cv1,&cvv1,&cvv2,&rc);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		          printf( "Error in BSsplitcv2(1) ...\n");
		          return -1;	}
      if (parmp1cv1 < EPS1 && parmp1cv1 > -EPS1) {
        VLdel(cv2);
        *cv2 = cvv2;
        VLdel(&cvv1);
        cv1->num_poles = 0;
      }
      else {
        VLdel(cv2);
        *cv2 = cvv1;
        VLdel(&cvv2);
        cv1->num_poles = 0;
      }
    }
    else {
      if (
        (parmp2cv1 < EPS1 && parmp2cv1 > -EPS1) ||
                           /* if pole2 of cv1 is projected on pole1 of cv2 */
        ((1-parmp2cv1) < EPS1 && (1-parmp2cv1) > -EPS1)
                           /* if pole2 of cv1 is projected on pole2 of cv2 */
       ) {
        BSsplitcv2(cv2,parmp1cv1,parmp1cv1,&cvv1,&cvv2,&rc);
        if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		            printf( "Error in BSsplitcv2(2) ...\n");
		            return -1;	}
        if (parmp2cv1 < EPS1 && parmp2cv1 > -EPS1) {
          VLdel(cv2);
          *cv2 = cvv2;
          VLdel(&cvv1);
          cv1->num_poles = 0;
        }
        else {
          VLdel(cv2);
          *cv2 = cvv1;
          VLdel(&cvv2);
          cv1->num_poles = 0;
        }
      }
      else {
        if (parmp1cv1 < parmp2cv1) {
        BSsplitcv2(cv2,parmp1cv1,parmp1cv1,&cvv1,&cvv2,&rc);
        if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		            printf( "Error in BSsplitcv2(3) ...\n");
		            return -1;	}
        BSmdstptcv(&cvv2,&cv1->poles[3*(cv1->num_poles-1)],&dbl1, base,
                   &dbl2,&rc);
        if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		            printf( "Error in BSmdstptcv(5) ...\n");
		            return -1;	}
        BSsplitcv2(&cvv2,dbl1,dbl1,&cvv3,&cvv4,&rc);
        if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		            printf( "Error in BSsplitcv2(4) ...\n");
		            return -1;	}
        VLdel(cv2);
        VLdel(cv1);
        *cv1 = cvv1;
        *cv2 = cvv4;
        VLdel(&cvv2);
        VLdel(&cvv3);
      }
      else {
        BSsplitcv2(cv2,parmp2cv1,parmp2cv1,&cvv1,&cvv2,&rc);
        if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		            printf( "Error in BSsplitcv2(5) ...\n");
		            return -1;	}
        BSmdstptcv(&cvv2,&cv1->poles[0],&dbl1,base,&dbl2,&rc);
        if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		            printf( "Error in BSmdstptcv(6) ...\n");
		            return -1;	}
        BSsplitcv2(&cvv2,dbl1,dbl1, &cvv3,&cvv4,&rc);
        if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		            printf( "Error in BSsplitcv2(6) ...\n");
		            return -1;	}
        VLdel(cv1);
        VLdel(cv2);
        *cv1 = cvv1;
        *cv2 = cvv4;
        VLdel(&cvv2);
        VLdel(&cvv3);
      }
    }
  }
#ifdef DEBUG
if (cv1->num_poles) {
printf("cv1: %d\n",cv1->num_poles);
printf("poles1=%lf %lf %lf\n",cv1->poles[0],cv1->poles[1],cv1->poles[2]);
printf("poles2=%lf %lf %lf\n",cv1->poles[3*(cv1->num_poles-1)],cv1->poles[3*(cv1->num_poles-1)+1],cv1->poles[3*(cv1->num_poles-1)+2]);
}
if (cv2->num_poles) {
printf("cv2: %d\n",cv2->num_poles);
printf("poles1=%lf %lf %lf\n",cv2->poles[0],cv2->poles[1],cv2->poles[2]);
printf("poles2=%lf %lf %lf\n",cv2->poles[3*(cv2->num_poles-1)],cv2->poles[3*(cv2->num_poles-1)+1],cv2->poles[3*(cv2->num_poles-1)+2]);
}
#endif
    return 1;
  }
  if ((disp1cv2 < DIS_EPS && disp1cv2 > -DIS_EPS) &&
      (disp2cv2 < DIS_EPS && disp2cv2 > -DIS_EPS)) {
  						/* if cv2 is "in" cv1 */
    if (
        (parmp1cv2 < EPS1 && parmp1cv2 > -EPS1) ||
                           /* if pole1 of cv2 is projected on pole1 of cv1 */
        ((1-parmp1cv2) < EPS1 && (1-parmp1cv2) > -EPS1)
                           /* if pole1 of cv2 is projected on pole2 of cv1 */
       ) {
     BSsplitcv2(cv1,parmp2cv2,parmp2cv2,&cvv1,&cvv2,&rc);
     if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		         printf( "Error in BSsplitcv2(7) ...\n");
		         return -1;	}
     if (parmp1cv2 < EPS1 && parmp1cv2 > -EPS1) {
       VLdel(cv1);
       *cv1 = cvv2;
       VLdel(&cvv1);
       cv2->num_poles = 0;
     }
     else {
       VLdel(cv1);
       *cv1 = cvv1;
       VLdel(&cvv2);
       cv2->num_poles = 0;
    }
  }
  else {
    if (
      (parmp2cv2 < EPS1 && parmp2cv2 > -EPS1) ||
                           /* if pole2 of cv2 is projected on pole1 of cv1 */
      ((1-parmp2cv2) < EPS1 && (1-parmp2cv2) > -EPS1)
                           /* if pole2 of cv2 is projected on pole2 of cv1 */
     ) {
      BSsplitcv2(cv1,parmp1cv2,parmp1cv2,&cvv1,&cvv2,&rc);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		        printf( "Error in BSsplitcv2(8) ...\n");
		        return -1;	}
      if (parmp2cv2 < EPS1 && parmp2cv2 > -EPS1) {
        VLdel(cv1);
        *cv1 = cvv2;
        VLdel(&cvv1);
        cv2->num_poles = 0;
      }
      else {
      VLdel(cv1);
      *cv1 = cvv1;
      VLdel(&cvv2);
      cv2->num_poles = 0;
    }
  }
  else {
    if (parmp1cv2 < parmp2cv2) {
      BSsplitcv2(cv1,parmp1cv2,parmp1cv2,&cvv1,&cvv2,&rc);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		          printf( "Error in BSsplitcv2(9) ...\n");
		          return -1;	}
      BSmdstptcv(&cvv2,&cv2->poles[3*(cv2->num_poles-1)],&dbl1, base,&dbl2,&rc);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		          printf( "Error in BSmdstptcv(7) ...\n");
		          return -1;	}
      BSsplitcv2(&cvv2,dbl1,dbl1,&cvv3,&cvv4,&rc);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		          printf( "Error in BSsplitcv2(10) ...\n");
		          return -1;	}
      VLdel(cv1);
      VLdel(cv2);
      *cv1 = cvv1;
      *cv2 = cvv4;
      VLdel(&cvv2);
      VLdel(&cvv3);
    }
    else {
      BSsplitcv2(cv1,parmp2cv2,parmp2cv2,&cvv1,&cvv2,&rc);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		          printf( "Error in BSsplitcv2(11) ...\n");
		          return -1;	}
      BSmdstptcv(&cvv2,cv2->poles,&dbl1,base,&dbl2,&rc);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		          printf( "Error in BSmdstptcv(8) ...\n");
		          return -1;	}
      BSsplitcv2(&cvv2,dbl1,dbl1,&cvv3,&cvv4,&rc);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		          printf( "Error in BSsplitcv2(12) ...\n");
		          return -1;	}
      VLdel(cv1);
      VLdel(cv2);
      *cv1 = cvv1;
      *cv2 = cvv4;
      VLdel(&cvv2);
      VLdel(&cvv3);
    }
  }
 }
#ifdef DEBUG
if (cv1->num_poles) {
printf("cv1: %d\n",cv1->num_poles);
printf("poles1=%lf %lf %lf\n",cv1->poles[0],cv1->poles[1],cv1->poles[2]);
printf("poles2=%lf %lf %lf\n",cv1->poles[3*(cv1->num_poles-1)],cv1->poles[3*(cv1->num_poles-1)+1],cv1->poles[3*(cv1->num_poles-1)+2]);
}
if (cv2->num_poles) {
printf("cv2: %d\n",cv2->num_poles);
printf("poles1=%lf %lf %lf\n",cv2->poles[0],cv2->poles[1],cv2->poles[2]);
printf("poles2=%lf %lf %lf\n",cv2->poles[3*(cv2->num_poles-1)],cv2->poles[3*(cv2->num_poles-1)+1],cv2->poles[3*(cv2->num_poles-1)+2]);
}
#endif
  return 1;
 }
  return 0;
}
  
/* *********************** VLadjacence *********************** */
/*
/*       if edges are adjacents : edge1 : 1------1, edge2 : !______!,
/*       and they are : 1-----1!_______!
/*
/* */
VLadjacence (cv1,cv2)
struct IGRbsp_curve *cv1,*cv2; /*IO : two curves */ 
{
BSrc rc;
IGRdouble   evl1[10],evl2[10];
int nb_int,rep;
long n_over;
IGRdouble *int_pts,*par1,*par2,*end_pts,*over0,*over1;

#ifdef DEBUG
printf("VLadjacence\n");
printf("cv1: %d\n",cv1->num_poles);
printf("poles1=%lf %lf %lf\n",cv1->poles[0],cv1->poles[1],cv1->poles[2]);
printf("poles2=%lf %lf %lf\n",cv1->poles[3*(cv1->num_poles-1)],cv1->poles[3*(cv1->num_poles-1)+1],cv1->poles[3*(cv1->num_poles-1)+2]);
printf("cv2: %d\n",cv2->num_poles);
printf("poles1=%lf %lf %lf\n",cv2->poles[0],cv2->poles[1],cv2->poles[2]);
printf("poles2=%lf %lf %lf\n",cv2->poles[3*(cv2->num_poles-1)],cv2->poles[3*(cv2->num_poles-1)+1],cv2->poles[3*(cv2->num_poles-1)+2]);
#endif
                                    /* look if they are perpendicular */
  int_pts = par1 = par2 = end_pts = over0 = over1 = NULL;
  BScvcv_int(&rc,cv1,cv2,&nb_int,&int_pts,&par1,&par2,
       &n_over,&end_pts,&over0,&over1);
  if (par1 != NULL && par2 != NULL && int_pts != NULL) {
    BScveval(cv1,par1[0],1,evl2,&rc);
    if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
  		        printf( "Error in BScveval(1) ...\n");
		        return -1;	}
    BScveval(cv2,par2[0],1,evl1,&rc);
    if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		        printf( "Error in BScveval(2) ...\n");
		        return -1;	}
    rep = VLprod(&evl1[3],&evl2[3]);
    if (rep == -1) return -1;
    if (!rep){
#ifdef DEBUG
printf("Perpendicualr\n");
#endif
      return 2;
    }
  }
  else { 
#ifdef DEBUG
printf("DDDDISJOINT\n");
#endif
      return 2;
  }
  if (int_pts) {om$dealloc(ptr= int_pts ); int_pts = NULL;}
  if (par1) {om$dealloc(ptr= par1 ); par1 = NULL;}
  if (par2) {om$dealloc(ptr= par2 ); par2 = NULL;}
  if (end_pts) {om$dealloc(ptr= end_pts ); end_pts = NULL;}
  if (over0) {om$dealloc(ptr= over0 ); over0 = NULL;}
  if (over1) {om$dealloc(ptr= over1 ); over1 = NULL;}
    

  if (VLsame_pole(&cv2->poles[0],&cv1->poles[3*(cv1->num_poles-1)])) {
      if (!VLmore_of_mem(cv1,cv2,cv1)) {
        ex$message(msgnumb = VL_E_PlClFail);
	printf( "Error in VLmore_of_mem(1) ...\n");
        return -1;
      }
      BSmerge_cv(&rc,cv1,cv2,cv1);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		          printf( "Error in BSmerge_cv(1) ...\n");
		          return -1;	}
      cv2->num_poles = 0;
#ifdef DEBUG
printf("CHANGED\n");
printf("cv1: %d\n",cv1->num_poles);
printf("poles1=%lf %lf %lf\n",cv1->poles[0],cv1->poles[1],cv1->poles[2]);
printf("poles2=%lf %lf %lf\n",cv1->poles[3*(cv1->num_poles-1)],cv1->poles[3*(cv1->num_poles-1)+1],cv1->poles[3*(cv1->num_poles-1)+2]);
#endif
    return 1;
  }
  if (VLsame_pole(&cv2->poles[0],&cv1->poles[0])) {
      if (!VLmore_of_mem(cv2,cv1,cv1)) {
        ex$message(msgnumb = VL_E_PlClFail);
	printf( "Error in VLmore_of_mem(2) ...\n");
        return -1;
      }
        
      BSmerge_cv(&rc,cv2,cv1,cv1);
      if (rc != BSSUCC) {
#ifdef DEBUG
printf("C'EST SANS DOUTE A CAUSE DE L'ORDRE DES COURBES\n");
#endif
        ex$message(msgnumb = VL_E_PlClFail);
	printf( "Error in BSmerge_cv(2) ...\n");
        return -1;
      }
      cv2->num_poles = 0;
#ifdef DEBUG
printf("CHANGED\n");
printf("cv1: %d\n",cv1->num_poles);
printf("poles1=%lf %lf %lf\n",cv1->poles[0],cv1->poles[1],cv1->poles[2]);
printf("poles2=%lf %lf %lf\n",cv1->poles[3*(cv1->num_poles-1)],cv1->poles[3*(cv1->num_poles-1)+1],cv1->poles[3*(cv1->num_poles-1)+2]);
#endif
    return 1;
  }
  if (VLsame_pole(&cv1->poles[0],&cv2->poles[3*(cv2->num_poles-1)])) {
      if (!VLmore_of_mem(cv2,cv1,cv1)) {
        ex$message(msgnumb = VL_E_PlClFail);
	printf( "Error in VLmore_of_mem(3) ...\n");
        return -1;
      }
        
      BSmerge_cv(&rc,cv2,cv1,cv1);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		          printf( "Error in BSmerge_cv(3) ...\n");
		          return -1;	}
      cv2->num_poles = 0;
#ifdef DEBUG
printf("CHANGED\n");
printf("cv1: %d\n",cv1->num_poles);
printf("poles1=%lf %lf %lf\n",cv1->poles[0],cv1->poles[1],cv1->poles[2]);
printf("poles2=%lf %lf %lf\n",cv1->poles[3*(cv1->num_poles-1)],cv1->poles[3*(cv1->num_poles-1)+1],cv1->poles[3*(cv1->num_poles-1)+2]);
#endif
    return 1;
  }
  if (VLsame_pole(&cv2->poles[3*(cv2->num_poles-1)],
                &cv1->poles[3*(cv1->num_poles-1)])) {
      if (!VLmore_of_mem(cv2,cv1,cv1)) {
        ex$message(msgnumb = VL_E_PlClFail);
	printf( "Error in VLmore_of_mem(4) ...\n");
        return -1;
      }
        
      BSmerge_cv(&rc,cv2,cv1,cv1);
      if (rc != BSSUCC) {
#ifdef DEBUG
printf("I THINK : C'EST SANS DOUTE A CAUSE DE L'ORDRE DES COURBES\n");
#endif
        ex$message(msgnumb = VL_E_PlClFail);
	printf( "Error in BSmerge_cv(4) ...\n");
        return -1;
      }
      cv2->num_poles = 0;
#ifdef DEBUG
printf("CHANGED\n");
printf("cv1: %d\n",cv1->num_poles);
printf("poles1=%lf %lf %lf\n",cv1->poles[0],cv1->poles[1],cv1->poles[2]);
printf("poles2=%lf %lf %lf\n",cv1->poles[3*(cv1->num_poles-1)],cv1->poles[3*(cv1->num_poles-1)+1],cv1->poles[3*(cv1->num_poles-1)+2]);
#endif
    return 1;
  }
#ifdef DEBUG
printf("Non Adjacence\n");
#endif
  return 0;
}

/* *********************** VLmerged *********************** */
/*
/*       if edges are merged : edge1 : 1------1, edge2 : !______!,
/*       and they are : 1-----!_-_-1_______!
/*
/* */
VLmerged(cv1,cv2,disp1cv1,disp2cv1,disp1cv2,disp2cv2,
               parmp1cv1,parmp2cv1,parmp1cv2,parmp2cv2)
struct IGRbsp_curve  *cv1,*cv2; /* IO : two curves */
IGRdouble            disp1cv1,  /* I  : distance of pole1 of cv1 to cv2 */
                     disp2cv1,  /* I  : distance of pole2 of cv1 to cv2 */
		     disp1cv2,  /* I  : distance of pole1 of cv2 to cv1 */
                     disp2cv2;  /* I  : distance of pole2 of cv2 to cv1 */
IGRdouble            parmp1cv1, /* I  : parameter of pole1 of cv1 on cv2 */
                     parmp2cv1, /* I  : parameter of pole2 of cv1 on cv2 */
                     parmp1cv2, /* I  : parameter of pole1 of cv2 on cv1 */
                     parmp2cv2; /* I  : parameter of pole2 of cv2 on cv1 */
{
struct IGRbsp_curve cvv1,cvv2,cvv3,cvv4;
BSrc   rc;
IGRdouble base[6],dbl1,dbl2;
int       two;

#ifdef DEBUG
printf("VLmerged\n");
printf("cv1: %d\n",cv1->num_poles);
printf("poles1=%lf %lf %lf\n",cv1->poles[0],cv1->poles[1],cv1->poles[2]);
printf("poles2=%lf %lf %lf\n",cv1->poles[3*(cv1->num_poles-1)],cv1->poles[3*(cv1->num_poles-1)+1],cv1->poles[3*(cv1->num_poles-1)+2]);
printf("cv2: %d\n",cv2->num_poles);
printf("poles1=%lf %lf %lf\n",cv2->poles[0],cv2->poles[1],cv2->poles[2]);
printf("poles2=%lf %lf %lf\n",cv2->poles[3*(cv2->num_poles-1)],cv2->poles[3*(cv2->num_poles-1)+1],cv2->poles[3*(cv2->num_poles-1)+2]);
#endif
  cvv1.poles = NULL; cvv1.knots = NULL; 
  cvv1.weights = NULL; cvv1.bdrys = NULL;
  cvv2.poles = NULL; cvv2.knots = NULL; 
  cvv2.weights = NULL; cvv2.bdrys = NULL;
  cvv3.poles = NULL; cvv3.knots = NULL; 
  cvv3.weights = NULL; cvv3.bdrys = NULL;
  cvv4.poles = NULL; cvv4.knots = NULL; 
  cvv4.weights = NULL; cvv4.bdrys = NULL;
  if (disp1cv1<DIS_EPS && disp1cv1>-DIS_EPS) {
                           /* if pole1 of cv1 is projected on pole1 of cv2 */
    BSmdstptcv(cv2,&cv1->poles[3*(cv1->num_poles-1)],&dbl1,
                     base,&dbl2,&rc);
    if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		        printf( "Error in BSmdstptcv(9) ...\n");
		        return -1;	}
    if (VLsame_pole(base,cv2->poles)) two=1;
    else two=0;
    BSsplitcv2(cv2,parmp1cv1,parmp1cv1,&cvv1,&cvv2,&rc);
    if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		        printf( "Error in BSsplitcv2(13) ...\n");
		        return -1;	}
    VLdel(cv2);
    if (two) {*cv2 = cvv2; VLdel(&cvv1);}
    else { *cv2 = cvv1; VLdel(&cvv2);}
    if (two) {
      BSsplitcv2(cv1,parmp1cv2,parmp1cv2,&cvv3,&cvv4,&rc);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		          printf( "Error in BSsplitcv2(14) ...\n");
		          return -1;	}
    }
    else {
      BSsplitcv2(cv1,parmp2cv2,parmp2cv2,&cvv3,&cvv4,&rc);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		          printf( "Error in BSsplitcv2(15) ...\n");
		          return -1;	}
    }
    VLdel(cv1);
    VLdel(&cvv3);
    *cv1 = cvv4;
    return 1;
  }
  if (disp2cv1<DIS_EPS && disp2cv1>-DIS_EPS) {
                           /* if pole2 of cv1 is projected on pole1 of cv2 */
     BSmdstptcv(cv2,&cv1->poles[0],&dbl1,base,&dbl2,&rc);
     if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		         printf( "Error in BSmdstptcv(10) ...\n");
		         return -1;	}
     if (VLsame_pole(base,cv2->poles)) two=1;
     else two=0;
     BSsplitcv2(cv2,parmp2cv1,parmp2cv1,&cvv1,&cvv2,&rc);
     if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		         printf( "Error in BSsplitcv2(16) ...\n");
		         return -1;	}
     VLdel(cv2);
     if (two) {*cv2 = cvv2; VLdel(&cvv1);}
     else { *cv2 = cvv1; VLdel(&cvv2);}
     if (two) {
       BSsplitcv2(cv1,parmp1cv2,parmp1cv2,&cvv3,&cvv4,&rc);
       if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		           printf( "Error in BSsplitcv2(17) ...\n");
		           return -1;	}
     }
     else {
       BSsplitcv2(cv1,parmp2cv2,parmp2cv2,&cvv3,&cvv4,&rc);
       if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		           printf( "Error in BSsplitcv2(18) ...\n");
		           return -1;	}
     }
     VLdel(cv1);
     VLdel(&cvv4);
     *cv1 = cvv3;
     return 1;
   }
  if (disp1cv2<DIS_EPS && disp1cv2>-DIS_EPS) {
                           /* if pole1 of cv2 is projected on pole1 of cv1 */
    BSmdstptcv(cv1,&cv2->poles[3*(cv2->num_poles-1)],&dbl1,
                     base,&dbl2,&rc);
    if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		        printf( "Error in BSmdstptcv(11) ...\n");
		        return -1;	}
    if (VLsame_pole(base,cv1->poles)) two=1;
    else two=0;
    BSsplitcv2(cv1,parmp1cv2,parmp1cv2,&cvv1,&cvv2,&rc);
    if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		        printf( "Error in BSsplitcv2(19) ...\n");
		        return -1;	}
    VLdel(cv1);
    if (two) {*cv1 = cvv2; VLdel(&cvv1);}
    else { *cv1 = cvv1; VLdel(&cvv2);}
    if (two) {
      BSsplitcv2(cv2,parmp1cv1,parmp1cv1,&cvv3,&cvv4,&rc);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		          printf( "Error in BSsplitcv2(20) ...\n");
		          return -1;	}
    }
    else {
      BSsplitcv2(cv2,parmp2cv1,parmp2cv1,&cvv3,&cvv4,&rc);
      if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		          printf( "Error in BSsplitcv2(21) ...\n");
		          return -1;	}
    }
    VLdel(cv2);
    VLdel(&cvv3);
    *cv2 = cvv4;
    return 1;
   }
  if (disp2cv2<DIS_EPS && disp2cv2>-DIS_EPS) {
                           /* if pole2 of cv2 is projected on pole1 of cv1 */
     BSmdstptcv(cv1,&cv2->poles[0],&dbl1,base,&dbl2,&rc);
     if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		         printf( "Error in BSmdstptcv(12) ...\n");
		         return -1;	}
     if (VLsame_pole(base,cv1->poles)) two=1;
     else two=0;
     BSsplitcv2(cv1,parmp2cv2,parmp2cv2,&cvv1,&cvv2,&rc);
     if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		         printf( "Error in BSsplitcv2(22) ...\n");
		         return -1;	}
     VLdel(cv1);
     if (two) {*cv1 = cvv2; VLdel(&cvv1);}
     else { *cv1 = cvv1; VLdel(&cvv2);}
     if (two) {
       BSsplitcv2(cv2,parmp1cv1,parmp1cv1,&cvv3,&cvv4,&rc);
       if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		           printf( "Error in BSsplitcv2(23) ...\n");
		           return -1;	}
     }
     else {
       BSsplitcv2(cv2,parmp2cv1,parmp2cv1,&cvv3,&cvv4,&rc);
       if (rc != BSSUCC) { ex$message(msgnumb = VL_E_PlClFail);
		           printf( "Error in BSsplitcv2(24) ...\n");
		           return -1;	}
     }
     VLdel(cv2);
     VLdel(&cvv4);
     *cv2 = cvv3;
     return 1;
   }
  return 0;
}

/* *********************** VLdelete_common_edges *********************** */
/*
/*       VLdelete common edges.
/*
/* */
VLdelete_common_edges(num1,bsp1,num2,bsp2,stop)
int 			num1;   /* I : number of edges of first plate */
struct IGRbsp_curve 	**bsp1; /* IO: edges of first plate */
int 			num2;   /* I : number of edges of second plate */
struct IGRbsp_curve     **bsp2; /* IO: edges of second plate */
int			*stop;  /* O : boolean */
{
int 		      jj,kk,rep;
int		      p1p1,p2p2,p1p2,p2p1;
IGRdouble             disp1cv1,disp2cv1,disp1cv2,disp2cv2;
IGRdouble             parmp1cv1,parmp2cv1,parmp1cv2,parmp2cv2;
IGRint		      NP1, NP2;

  *stop = 1;
  for (jj=0; jj<num1; jj++)
  {
    if (bsp1[jj]->num_poles == 0) {
#ifdef DEBUG
printf("CONTINUE1\n");
#endif
      continue;
    }
    for (kk=0; kk<num2; kk++)
    {
      if (bsp2[kk]->num_poles == 0) {
#ifdef DEBUG
printf("continue2\n");
#endif
       continue;
      }
      if (bsp1[jj]->num_poles == 0) {
#ifdef DEBUG
printf("BREAK1\n");
#endif
        break;
      }
#ifdef DEBUG
printf("bsp1[%d]->num_poles: %d\n",jj,bsp1[jj]->num_poles);
printf("poles1=%lf %lf %lf\n",bsp1[jj]->poles[0],bsp1[jj]->poles[1],bsp1[jj]->poles[2]);
printf("poles2=%lf %lf %lf\n",bsp1[jj]->poles[3*(bsp1[jj]->num_poles-1)],bsp1[jj]->poles[3*(bsp1[jj]->num_poles-1)+1],bsp1[jj]->poles[3*(bsp1[jj]->num_poles-1)+2]);
printf("bsp2[%d]->num_poles: %d\n",kk,bsp2[kk]->num_poles);
printf("poles1=%lf %lf %lf\n",bsp2[kk]->poles[0],bsp2[kk]->poles[1],bsp2[kk]->poles[2]);
printf("poles2=%lf %lf %lf\n",bsp2[kk]->poles[3*(bsp2[kk]->num_poles-1)],bsp2[kk]->poles[3*(bsp2[kk]->num_poles-1)+1],bsp2[kk]->poles[3*(bsp2[kk]->num_poles-1)+2]);
#endif
      NP1 = bsp1[jj]->num_poles;
      NP2 = bsp2[kk]->num_poles;
      p1p1 = VLsame_pole ( &bsp1[jj]->poles[0],
			 &bsp2[kk]->poles[0] );
      p2p2 = VLsame_pole ( &bsp1[jj]->poles[3*(NP1-1)],
                         &bsp2[kk]->poles[3*(NP2-1)] );
      p1p2 = VLsame_pole ( &bsp1[jj]->poles[0],
                         &bsp2[kk]->poles[3*(NP2-1)] );
      p2p1 = VLsame_pole ( &bsp1[jj]->poles[3*(NP1-1)],
                         &bsp2[kk]->poles[0] );
      if (((p1p1) && (p2p2)) || ((p1p2) && (p2p1))) {
          *stop = 0;
          bsp1[jj]->num_poles = 0;
          bsp2[kk]->num_poles = 0;
#ifdef DEBUG
printf("THE SAME\n");
#endif
          break;
        } 
     /* find distances of each pole of an edge to the other edge */
      if(!(VLfind_distances(
                     bsp1[jj],bsp2[kk],
                     &disp1cv1,&disp2cv1,&disp1cv2,&disp2cv2,
                     &parmp1cv1,&parmp2cv1,&parmp1cv2,&parmp2cv2
                    ))){return 0;}
      if ((disp1cv1 > DIS_EPS || disp1cv1 < -DIS_EPS) &&
          (disp2cv1 > DIS_EPS || disp2cv1 < -DIS_EPS) &&
          (disp1cv2 > DIS_EPS || disp1cv2 < -DIS_EPS) &&
          (disp2cv2 > DIS_EPS || disp2cv2 < -DIS_EPS)){
#ifdef DEBUG
printf("DISJOINT\n");
#endif
          continue; /*disjoint */
      }
     /* if one edge is in the other one */
      if (
          (rep=(VLone_in_other(
                       bsp1[jj],bsp2[kk],
                       disp1cv1,disp2cv1,disp1cv2,disp2cv2,
                       parmp1cv1,parmp2cv1,parmp1cv2,parmp2cv2
                      )))
         ) { 
            *stop = 0;
            if (rep == 1) continue;
            else { ex$message(msgnumb = VL_E_PlClFail);
		   printf( "Error : rep = %d\n", rep);
		   return 0;	}
           }
     /* if edges are adjacents */
      if ((rep=(VLadjacence(bsp1[jj],bsp2[kk])))) 
         {
            if (rep == 1) { *stop=0; continue;} /* they are perpendicular */
            else {
              if (rep == 2) { continue; }
              else { ex$message(msgnumb = VL_E_PlClFail);
		     printf( "Error : rep = %d\n", rep);
		     return 0;	}
            }
         }
       /* if edges are merged :   1-----!_-_-1_______! */
      if (
          (rep=(VLmerged(
                 bsp1[jj],bsp2[kk],
                 disp1cv1,disp2cv1,disp1cv2,disp2cv2,
                 parmp1cv1,parmp2cv1,parmp1cv2,parmp2cv2
                )
         ))) 
         {
            *stop = 0;
            if (rep == 1) continue;
            else { ex$message(msgnumb = VL_E_PlClFail);
		   printf( "Error : rep = %d\n", rep);
		   return 0;	}
         }
#ifdef DEBUG
printf("Invalid CASE\n");
return 0;
#endif
    }
  }
  return 1;
}

/* *********************** VLFindEdges *********************** */
/*
/*       Find Edges of a plate.
/*
/* */

IGRlong VLFindEdges( SurfObj, bspcv, num, msg )
struct GRobj_env	*SurfObj;	/*I : surface */
struct IGRbsp_curve	***bspcv;       /*O : bspline list of edges   */
int                     *num;           /*O : number of edges */
IGRlong			*msg;		/*O : MSSUCC or MSfail */

{
int		count,jj;
struct GRid     grEdge,*list=NULL;
int             ii;
IGRlong		sts, loc_sts;
struct IGRbsp_curve *cv = NULL;

  *msg = MSFAIL;
  sts = vs$get_surface_edges( msg         = &loc_sts,
                              sfId        = &SurfObj->obj_id,
                              sfEnv       = &SurfObj->mod_env,
                              edgeType    = VS_K_CONTOUR_EDGES,
                              edCount     = &count,
                              edList      = &list ) ;

  if( !( sts & 1 & loc_sts ) ) {
#ifdef DEBUG
    printf( "~~~~~~~~~~ERROR in vs$get_surface_edges\n" ) ;
#endif
    goto quit;
  }
  *num = count;
  *bspcv = (struct IGRbsp_curve **)
                    om$malloc(size = count*sizeof(struct IGRbsp_curve *));
  for (ii=0; ii<count; ii++)
  {
    sts = vs$get_graphic_edge( msg    = &loc_sts,
                               edId   = &list[ii],
                               edEnv  = &SurfObj->mod_env,
                               copy   = FALSE,
                               copyEnv   = NULL,
                               grEdge = &grEdge) ;
  
    if( !( sts & 1 & loc_sts) ) {
#ifdef DEBUG
      printf( "~~~~~~~~~~ERROR in vs$get_graphic_edge\n" ) ;
#endif
      goto quit;
    }
    sts = om$send(msg = message GRvg.GRgenabsg(&loc_sts,
					&SurfObj->mod_env.md_env.matrix_type,
					SurfObj->mod_env.md_env.matrix,
					(IGRchar **)&cv),
 		  senderid = NULL_OBJID,
                  targetid = grEdge.objid,
                  targetos = grEdge.osnum );
    (*bspcv)[ii] = (struct IGRbsp_curve *)
                      om$malloc( size = sizeof(struct IGRbsp_curve));
    (*bspcv)[ii][0] = *cv;
    (*bspcv)[ii]->poles = (double *) 
                           om$malloc( size = 3*cv->num_poles*sizeof(double));
    for (jj=0; jj<3*cv->num_poles;jj++) (*bspcv)[ii]->poles[jj]=cv->poles[jj];
    (*bspcv)[ii]->knots = (double *) 
                           om$malloc( size = cv->num_knots*sizeof(double));
    for (jj=0; jj<cv->num_knots;jj++) (*bspcv)[ii]->knots[jj]=cv->knots[jj];
    if (cv->rational) {
      (*bspcv)[ii]->weights = (double *)
                           om$malloc( size = cv->num_knots*sizeof(double));
      for (jj=0; jj<cv->num_knots;jj++) 
        (*bspcv)[ii]->weights[jj]=cv->weights[jj];
    }
#ifdef DEBUG
  printf("NUM_POLES=%d\n",(*bspcv)[ii]->num_poles);
    printf("poles= %lf %lf %lf\n",(*bspcv)[ii]->poles[0],(*bspcv)[ii]->poles[1], (*bspcv)[ii]->poles[2]);
    printf("poles= %lf %lf %lf\n",(*bspcv)[ii]->poles[3*((*bspcv)[ii]->num_poles-1)],(*bspcv)[ii]->poles[3*((*bspcv)[ii]->num_poles-1)+1], (*bspcv)[ii]->poles[3*((*bspcv)[ii]->num_poles-1)+2]);
fflush(stdout);
#endif
  }

  if(list)  {free(list); list = NULL;}
  *msg = MSSUCC;
  return 1;
quit :
  if(list)  {free(list); list = NULL;}
  return 0;
}

/* *********************** VLn_edges_to_4_edges *********************** */
/*
/*       make a four edges structure.
/*
/* */

VLn_edges_to_4_edges(nb_edge,cv_contour)
int nb_edge;                         /* I : number of edges */
struct  IGRbsp_curve	**cv_contour;/* IO: edges */
{
BSrc    rc;
IGRboolean stat;
int     ii,jj,jj1,mm,new_edge;
IGRdouble vect[MAX_EDGES],*dbl;
IGRdouble mid,par1,par2;

  mid = 0.5;
  par1 = 0;
  par2 = 1;
  dbl = NULL;
  /* compute every edge's length */
  for (ii=0; ii< nb_edge; ii = ii +1)
  {
    BSarclen(&rc,&stat,cv_contour[ii],&par1,&par2,&mid,&vect[ii]);
    if (rc != BSSUCC) { return 0;}
  }

  new_edge = nb_edge;
  while (new_edge > 4) {
    mm = 0;
    for (ii=1; ii< nb_edge; ii = ii +1)
      if (vect[ii] < vect[mm]) mm = ii; 
    jj1 = mm;
    if (mm == 0){
      for (jj=mm+1; jj < nb_edge; jj++)
      {
        if (vect[jj] < OM_K_MAXINT) break; 
      }
      if (jj < nb_edge) {
        if (!VLmore_of_mem(cv_contour[mm],cv_contour[jj],cv_contour[mm])) {
         ex$message(msgnumb = VL_E_PlClFail);
	 printf( "Error in VLmore_of_mem(5) ...\n");
         return 0;
        }
        BSmerge_cv(&rc,cv_contour[mm],cv_contour[jj],cv_contour[mm]);
        if (rc != BSSUCC) {return 0;}
        vect[mm] = vect[mm]+vect[jj];
        vect[jj] = OM_K_MAXINT;
        jj1 = jj;
        new_edge = new_edge - 1;
      }
      if (new_edge > 4) {
        for (jj=nb_edge-1; jj > jj1; jj--)
        {
          if (vect[jj] < OM_K_MAXINT) break;
        }
        if (jj > 0) {
          if (!VLmore_of_mem(cv_contour[jj],cv_contour[mm],cv_contour[mm])) {
           ex$message(msgnumb = VL_E_PlClFail);
	   printf( "Error in VLmore_of_mem(6) ...\n");
           return 0;
          }
          BSmerge_cv(&rc,cv_contour[jj],cv_contour[mm],cv_contour[mm]);
          if (rc != BSSUCC) {return 0;}
          vect[mm] = vect[mm]+vect[jj];
          vect[jj] = OM_K_MAXINT;
          new_edge = new_edge - 1;
       }
      }
    }
    else {
      if (mm == (nb_edge-1)) {
        for (jj=mm-1; jj >= 0; jj--)
        {
          if (vect[jj] < OM_K_MAXINT) break;
        }
        if (jj >= 0) {
          if (!VLmore_of_mem(cv_contour[jj],cv_contour[mm],cv_contour[mm])) {
            ex$message(msgnumb = VL_E_PlClFail);
	    printf( "Error in VLmore_of_mem(7) ...\n");
            return 0;
          }
          BSmerge_cv(&rc,cv_contour[jj],cv_contour[mm],cv_contour[mm]);
          vect[mm] = vect[jj]+vect[mm];
          vect[jj] = OM_K_MAXINT;
          jj1 = jj;
          new_edge = new_edge - 1;
        }
        if (new_edge > 4) {
          for (jj=0; jj < jj1; jj++)
          {
            if (vect[jj] < OM_K_MAXINT) break;
          }
          if (jj < mm) {
            if (!VLmore_of_mem(cv_contour[mm],cv_contour[jj],cv_contour[mm])) {
              ex$message(msgnumb = VL_E_PlClFail);
	      printf( "Error in VLmore_of_mem(8) ...\n");
              return 0;
            }
            BSmerge_cv(&rc,cv_contour[mm],cv_contour[jj],cv_contour[mm]);
            vect[mm] = vect[mm]+vect[jj];
            vect[jj] = OM_K_MAXINT;
            new_edge = new_edge - 1;
          }
        }
      }
      else {
          for (jj=mm+1; jj < nb_edge; jj++)
          {
            if (vect[jj] < OM_K_MAXINT) break;
          }
          if (jj < nb_edge) {
            if (!VLmore_of_mem(cv_contour[mm],cv_contour[jj],cv_contour[mm])) {
              ex$message(msgnumb = VL_E_PlClFail);
	      printf( "Error in VLmore_of_mem(9) ...\n");
              return 0;
            }
            BSmerge_cv(&rc,cv_contour[mm],cv_contour[jj],cv_contour[mm]);
            vect[mm] = vect[mm]+vect[jj];
            vect[jj] = OM_K_MAXINT;
            new_edge = new_edge - 1;
          }
          if (new_edge > 4) {
            for (jj=mm-1; jj >= 0; jj--)
            {
              if (vect[jj] < OM_K_MAXINT) break;
            }
            if (jj >= 0) {
              if (!VLmore_of_mem(cv_contour[jj],cv_contour[mm],cv_contour[mm])){
                ex$message(msgnumb = VL_E_PlClFail);
	        printf( "Error in VLmore_of_mem(10) ...\n");
                return 0;
              }
              BSmerge_cv(&rc,cv_contour[jj],cv_contour[mm],cv_contour[mm]);
              vect[mm] = vect[jj] + vect[mm];
              vect[jj] = OM_K_MAXINT;
              new_edge--;
            }
          }
       }
    }
  }
   
  mm = 0;
  for (ii=0; ii< nb_edge; ii = ii +1)
  {
    if (vect[ii] != OM_K_MAXINT) { 
      cv_contour[mm] = cv_contour[ii];
      mm = mm + 1;
    }
  }
  return 1;
}

/* *********************** VLmakeContour *********************** */
/*
/*       compute the contour of several plates.
/*
/* */

IGRlong VLmakeContour (msg,nb_plates,plates,name,nb_edge,contour_id,
                         cv_contour,modenv,four,tab_cv,Num_Edges)
int 			nb_plates;/* I: plate's number */
struct GRobj_env  	*plates;  /* I: plates */
IGRchar			*name;    /* I: plate surface name (Top or Bottom) */
struct GRmd_env         *modenv;  /* I: current module environnement */
int			four;     /* I: 1--> need just four edges in the contour
					  0--> number of edges not limited */

int			*msg;        /*O: completion code */
int			*nb_edge;    /*O: contour edge number */ 
struct GRobj_env	*contour_id; /*O: if four==1 each edge in the contour 
                                         is constructed and this array contains
                                         their GRobjenv */
struct  IGRbsp_curve	**cv_contour;/*O: contains the description of each
					  edge in the contour */      
struct  IGRbsp_curve	***tab_cv;   /*O:tab_cv[i] contains edges descriptions
					 of the iem plate */
IGRint			*Num_Edges;  /*O: Num_Edges[i] is the edge number of the
					  iem plate */ 
{
IGRint			ind,ii,jj,ret;
IGRint			halte,stop,yes,count;
IGRlong			loc_sts;
struct	GRobj_env	base_surf;
IGRlong			sts;
IGRdouble               tmp[3];
struct GRobj_env	cp_obj;
struct  GRvg_construct  cnst;
struct  IGRbsp_curve	*contour[MAX_EDGES];
struct  IGRbsp_curve	**tab_curves[MAX_PLATES];
IGRint			nb_edges[MAX_PLATES];
int			kill = 1;

    *msg = MSFAIL;
    ret = 1;
    if (nb_plates > MAX_PLATES) {
      ex$message(msgnumb = VL_E_PlClFail);
      ret = 0;
      goto quit;
    }
    if (!four) {
      BSxtractpar ( msg, BSTOLCHRDHT, &EPS);
      BSxtractpar ( msg, BSTOLBASIS, &EPS1);
      EPS = 2*EPS;
      EPS1 = 2*EPS1;
      DIS_EPS = sqrt(3*EPS*EPS);
    }

    if (cv_contour == NULL) cv_contour = contour;
    if (tab_cv == NULL) tab_cv = tab_curves;
    if (Num_Edges == NULL) Num_Edges = nb_edges;

    for( ind=0; ind<nb_plates; ind = ind + 1 )
    {
      if(
         (vs$is_ancestry_valid( object   = &plates[ind].obj_id,
			        classid = OPP_VSplate_class_id )
		  == TRUE) ||
         (vs$is_ancestry_valid( object   = &plates[ind].obj_id,
			        classid = OPP_VSimgFeature_class_id )
		  == TRUE)
        ) {
      /*
       * Get bottom side of plate.
       */
        sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                          &loc_sts,
                                          VS_K_plBotSfPath,
                                          &base_surf.obj_id,
                                          &base_surf.mod_env.md_env.matrix_type,
                                          base_surf.mod_env.md_env.matrix),
                         senderid = NULL_OBJID,
                         targetid = plates[ind].obj_id.objid,
                         targetos = plates[ind].obj_id.osnum ) ;
        if( !( loc_sts & 1 & sts ) ) {
           ex$message(msgnumb = VL_E_PlClFail);
	   printf( "Error in NDmacro.ACreturn_foot(%s) ...\n", name);
           ret = 0;
           goto quit;
        }
        base_surf.mod_env.md_id.osnum = base_surf.obj_id.osnum;
/*
        MAmulmx(&loc_sts,&dim,&dim,&dim,plates[ind].mod_env.md_env.matrix,
               base_surf.mod_env.md_env.matrix,base_surf.mod_env.md_env.matrix);
        MAtypemx( &loc_sts, base_surf.mod_env.md_env.matrix,
                                      &base_surf.mod_env.md_env.matrix_type);
*/
      }
      else {
        base_surf = plates[ind];
      }

      if ((vs$is_ancestry_valid( object   = &plates[ind].obj_id,
			        classid = OPP_VSimgFeature_class_id )
		  == TRUE)) {
        sts = om$send(msg = message GRgraphics.GRcopy(
                                                &loc_sts,
                                                &base_surf.mod_env,
                                                modenv,
                                                &cp_obj.obj_id.objid ),
                                senderid = NULL_OBJID,
                                targetid = base_surf.obj_id.objid,
                                targetos = base_surf.obj_id.osnum );
        cp_obj.obj_id.osnum = modenv->md_id.osnum;
        if( ! (sts&loc_sts&1)){
           ex$message(msgnumb = VL_E_PlClFail);
	   printf( "Error in GRgraphics.GRcopy() ...\n");
           ret = 0;
           goto quit;
        }
        cp_obj.mod_env = *modenv;
     }
     else {
       cp_obj = base_surf;
       kill = 0;
     }

     /* if TOP is not the recquired face */
     if ( strcmp(name,VS_K_plTopSfPath) ||
           ((vs$is_ancestry_valid( object   = &plates[ind].obj_id,
			          classid = OPP_VSplate_class_id )
		    == FALSE) &&
           (vs$is_ancestry_valid( object   = &plates[ind].obj_id,
			          classid = OPP_VSimgFeature_class_id )
		    == FALSE))
        ) {
         surf[ind] =base_surf;
      }
      else {
        /* get top side of plate */
        sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                          &loc_sts,
                                          VS_K_plTopSfPath,
                                          &base_surf.obj_id,
                                          NULL,
                                          NULL),
                         senderid = NULL_OBJID,
                         targetid = plates[ind].obj_id.objid,
                         targetos = plates[ind].obj_id.osnum ) ;
        if( !( loc_sts & 1 & sts ) ) {
           ex$message(msgnumb = VL_E_PlClFail);
	   printf( "Error in NDmacro.ACreturn_foot(%s) ...\n", name);
           ret = 0;
           goto quit;
        }
        base_surf.mod_env.md_id.osnum = base_surf.obj_id.osnum;
        surf[ind] = base_surf;
      }
      sts = VLFindEdges( &cp_obj,&tab_cv[ind], &Num_Edges[ind], &loc_sts );
      if (!(sts&loc_sts&1)) {
        ex$message(msgnumb = VL_E_PlClFail);
	printf( "Error in VLFindEdges() ...\n");
        ret = 0;
        goto quit;
      }
      if (surf[ind].obj_id.objid != cp_obj.obj_id.objid &&
          surf[ind].obj_id.osnum != cp_obj.obj_id.osnum &&
          kill) {
        om$send(    msg      = message GRgraphics.GRdelete
                                      ( &loc_sts, modenv ),
                      senderid = NULL_OBJID,
                      targetid = cp_obj.obj_id.objid,
                      targetos = cp_obj.obj_id.osnum );
         
      }
    } /* end for */
    halte = stop = 0; count = -1;
    if (nb_plates >1) {
      while (!halte) {
        halte = 1;
        count++;
        if (count >1600) {
		  printf( "\tPlace Control Line Failed, cccount=%d\n", count);
		  ex$message(msgnumb = VL_E_PlClFail);
                  ret = 0;
		  goto quit;
        }
        for( ind=0; ind<nb_plates; ind++ )
        {
          for (ii=ind+1; ii< nb_plates; ii++)
          {
            if (!(VLdelete_common_edges(Num_Edges[ind],tab_cv[ind],
                                      Num_Edges[ii],tab_cv[ii],&stop)))  {
               ret=0;
               goto quit;
            }
	    if (!stop) halte = 0;
          }
        } /* end for */
      }
    }
#ifdef DEBUG  
    for( ind=0; ind<nb_plates; ind++ )
    {
      for (ii=0;ii<Num_Edges[ind];ii++)
      {
        if (tab_cv[ind][ii]->num_poles) {
        printf("num_poles=%d\n",tab_cv[ind][ii]->num_poles);
        printf("POLE1=%lf %lf %lf\n",tab_cv[ind][ii]->poles[0],tab_cv[ind][ii]->poles[1],tab_cv[ind][ii]->poles[2]);
        printf("POLE2=%lf %lf %lf\n",tab_cv[ind][ii]->poles[3*(tab_cv[ind][ii]->num_poles-1)],tab_cv[ind][ii]->poles[3*(tab_cv[ind][ii]->num_poles-1)+1],tab_cv[ind][ii]->poles[3*(tab_cv[ind][ii]->num_poles-1)+2]);
        }
      }
    }
fflush(stdout);
#endif
   /* put edges in order */
    stop = 0; yes = 0; jj = 0; count = -1;
    while (stop == 0) {
      count++;
      if (count >1600) {
		printf( "\tPlace Control Line Failed, count=%d\n", count);
		ex$message(msgnumb = VL_E_PlClFail);
                ret = 0;
		goto quit;
      }
      stop = 1;
      for (ind=0; ind<nb_plates; ind++ )
      {
        for (ii=0; ii<Num_Edges[ind]; ii++)
        {
          if (jj > MAX_EDGES) {
	    ex$message(msgnumb = VL_E_PlClFail);
            ret = 0;
	    goto quit;
          }
          if(tab_cv[ind][ii]->num_poles > 0 ) {
            stop = 0;
            if (!yes) {
              tmp[0] = tab_cv[ind][ii]->poles[3*(tab_cv[ind][ii]->num_poles-1)];
              tmp[1] = tab_cv[ind][ii]->poles[3*(tab_cv[ind][ii]->num_poles-1)+1];
              tmp[2] = tab_cv[ind][ii]->poles[3*(tab_cv[ind][ii]->num_poles-1)+2];
              cv_contour[jj] = tab_cv[ind][ii];
              jj++;
              yes = 1;
              tab_cv[ind][ii]->num_poles = -tab_cv[ind][ii]->num_poles;
            }
            else {
                if (VLsame_pole(&tab_cv[ind][ii]->poles[0], tmp)) {
                  tmp[0] = tab_cv[ind][ii]->poles[3*(tab_cv[ind][ii]->num_poles-1)];
                  tmp[1] = tab_cv[ind][ii]->poles[3*(tab_cv[ind][ii]->num_poles-1)+1];
                  tmp[2] = tab_cv[ind][ii]->poles[3*(tab_cv[ind][ii]->num_poles-1)+2];
                  cv_contour[jj] = tab_cv[ind][ii];
                  jj++;
                  tab_cv[ind][ii]->num_poles = -tab_cv[ind][ii]->num_poles;
                }
              else {
              if (VLsame_pole(&tab_cv[ind][ii]->poles[3*(tab_cv[ind][ii]->num_poles-1)], tmp)) {
                   tmp[0] = tab_cv[ind][ii]->poles[0];
                   tmp[1] = tab_cv[ind][ii]->poles[1];
                   tmp[2] = tab_cv[ind][ii]->poles[2];
                  cv_contour[jj] = tab_cv[ind][ii];
                  jj++;
                  tab_cv[ind][ii]->num_poles = -tab_cv[ind][ii]->num_poles;
              }
              }
            }
          }
        }
      }
    }
    *nb_edge = jj;
    for (ind=0;ind<*nb_edge; ind++)
    {
      cv_contour[ind]->num_poles = -cv_contour[ind]->num_poles;
    }
#ifdef DEBUG
    for(ind=0;ind < *nb_edge; ind++)
    {
      if (cv_contour[ind]->num_poles) {
      printf("cv_contour[%d]->num_poles=%d\n",ind,cv_contour[ind]->num_poles);
      printf("POLES1=%lf %lf %lf\n",cv_contour[ind]->poles[0],cv_contour[ind]->poles[1],cv_contour[ind]->poles[2]);
      printf("POLES2=%lf %lf %lf\n",cv_contour[ind]->poles[3*(cv_contour[ind]->num_poles-1)],cv_contour[ind]->poles[3*(cv_contour[ind]->num_poles-1)+1],cv_contour[ind]->poles[3*(cv_contour[ind]->num_poles-1)+2]);
      }
    }
#endif
   /* if desired, make a four edges structure */
    if (four && *nb_edge > 4) {
      if(!(VLn_edges_to_4_edges(*nb_edge,cv_contour))) {
        ret = 0;
        ex$message(msgnumb = VL_E_PlClFail);
	printf( "Error in VLn_edges_to_4_edges()\n");
        goto quit;
      }
      *nb_edge = 4;
    }
#ifdef DEBUG
    for(ind=0;ind < *nb_edge; ind++)
    {
      if (cv_contour[ind]->num_poles) {
      printf("cv_contour[%d]->num_poles=%d\n",ind,cv_contour[ind]->num_poles);
      printf("POLES1=%lf %lf %lf\n",cv_contour[ind]->poles[0],cv_contour[ind]->poles[1],cv_contour[ind]->poles[2]);
      printf("POLES2=%lf %lf %lf\n",cv_contour[ind]->poles[3*(cv_contour[ind]->num_poles-1)],cv_contour[ind]->poles[3*(cv_contour[ind]->num_poles-1)+1],cv_contour[ind]->poles[3*(cv_contour[ind]->num_poles-1)+2]);
      }
    }
#endif
   /* if a four edges structure is'nt desired, construct contour edges */
    if (!four) {
      VLinitCnst(&cnst);
      cnst.env_info = modenv;
      if (*nb_edge > MAX_EDGES) {
        ex$message(msgnumb = VL_E_PlClFail);
        ret = 0;
        goto quit;
      }
      for (jj=0;jj < *nb_edge; jj = jj+1)
      {
        contour_id[jj].mod_env = *modenv;
        contour_id[jj].obj_id.objid =  NULL_OBJID;
        contour_id[jj].obj_id.osnum =  modenv->md_id.osnum;
        cnst.geometry = (char*) cv_contour[jj];
        sts = om$construct( classid = OPP_GRbcsubbc_class_id,
                            osnum   = contour_id[jj].obj_id.osnum,
                            p_objid = &contour_id[jj].obj_id.objid );
        if (!(sts&1)) {
          ret = 0;
          ex$message(msgnumb = VL_E_PlClFail);
	  printf( "Error in om$construct(OPP_GRbspline_class_id)\n");
          goto quit;
        }
        sts = om$send( msg = message GRgraphics.GRconstruct(&cnst),
                           senderid = NULL_OBJID,
                           targetid  = contour_id[jj].obj_id.objid,
                           targetos  = contour_id[jj].obj_id.osnum);
        if (!(sts&1)) {
          ret = 0;
          ex$message(msgnumb = VL_E_PlClFail);
	  printf( "Error in GRbspline.GRconstruct()\n");
          goto quit;
        }
      }
    }
  *msg = MSSUCC;
  quit :
  if (!four && ret)
     VLdel_mem(nb_plates,Num_Edges,tab_cv);
     if (ret) return 1;
     else return 0;
}

/* *********************** VLsimpleClLine *********************** */
/*
/*       compute one line joining midpoints of two opposing edges 
/*       from a four-edges structure. 
/*
/* */

IGRlong VLsimpleClLine(msg,contour, ShipAxis, controlLine,nb_surf)
IGRint			*msg;           /* O : completion code */
struct  IGRbsp_curve    **contour;      /* I : four-edges structure */
IGRint			nb_surf;	/* I : number of surfaces */
IGRdouble		*ShipAxis;	/* I : ship axis */
struct BendingLineInfo  *controlLine;	/* O : control line output */
{
  IGRint		i;                   
  IGRdouble             midpar;             
  IGRdouble             midpts[12];  
  BSrc                  bsrc;       
  struct IGRpolyline    geom;	
  IGRvector		vec1;
  IGRdouble		dotp1;		
  IGRvector		vec2;	
  IGRdouble		dotp2;
  struct  GRvg_construct  cst;
  IGRvector		tmp_S_axis;
  IGRpoint		nor_pnt;
  IGRlong		sts,loc_msg;

  *msg = MSFAIL;
  tmp_S_axis[0] = ShipAxis[0];
  tmp_S_axis[1] = ShipAxis[1];
  tmp_S_axis[2] = ShipAxis[2];
  /* Get midpoints */
  BSnorvec( &bsrc, tmp_S_axis );
  if (bsrc != BSSUCC) {goto quit;}
  BScvmidpt(contour[0],&midpar,&midpts[0],&bsrc);
  if (bsrc != BSSUCC) {goto quit;}
  BScvmidpt(contour[2],&midpar,&midpts[3],&bsrc);
  if (bsrc != BSSUCC) {goto quit;}
  BScvmidpt(contour[1],&midpar,&midpts[6],&bsrc);
  if (bsrc != BSSUCC) {goto quit;}
  BScvmidpt(contour[3],&midpar,&midpts[9],&bsrc);
  if (bsrc != BSSUCC) {goto quit;}

	/* got the mid points, now find the line between opposing edges */
  vec1[0] = midpts[3] - midpts[0];
  vec1[1] = midpts[4] - midpts[1];
  vec1[2] = midpts[5] - midpts[2];
  BSnorvec( &bsrc, vec1 );
  if (bsrc != BSSUCC) {goto quit;}
  
  dotp1 = BSdotp( &bsrc, vec1, tmp_S_axis);
  if (bsrc != BSSUCC) {goto quit;}

  if ( dotp1 < 0.0 ) dotp1 = -1.0 * dotp1 ;

  vec2[0] = midpts[9] - midpts[6];
  vec2[1] = midpts[10] - midpts[7];
  vec2[2] = midpts[11] - midpts[8];
  BSnorvec( &bsrc, vec2 );
  if (bsrc != BSSUCC) {goto quit;}

  dotp2 = BSdotp( &bsrc, vec2, tmp_S_axis);
  if (bsrc != BSSUCC) {goto quit;}

  if ( dotp2 < 0.0 ) dotp2 = -1.0 * dotp2 ;

  geom.num_points = 2;
  if (dotp2<dotp1) {	/* 1st line has better alignment */
	geom.points = &midpts[0];
  }
  else {
	geom.points = &midpts[6];
  }
		/* only need closest (aligned) to axis */
  cst.geometry = (char *)&geom;
  for (i=0; i< 3; i = i + 1 ) {
	controlLine->point1[i] =   geom.points[i];
	controlLine->point2[i] = geom.points[i+3];
  }
  /* compute average normal on all surfaces */
  sts = VLevalAvNor ( surf, nb_surf, nor_pnt, controlLine->normal, &loc_msg);
  if (!(sts&loc_msg&1)){
    ex$message(msgnumb = VL_E_PlClFail);
    printf( "Error in VLevalAvNor()\n");
    goto quit;
  }
  *msg = MSSUCC;
  return 1;
  quit :
    return 0;
} /*c end simple controline */

/* *********************** VLfindClLine *********************** */
/*
/*       compute one control line on several plates
/*
/* */

IGRlong VLfindClLine (msg,nb_plates,plates,name, mod_env,ShipAxis,
                         normal,controlLine,ControlObj)
IGRint			*msg;           /*O return message */
IGRint			nb_plates;      /*I number of plates */
struct GRobj_env  	*plates;        /*I list of plates */
IGRchar			*name;		/*I which face, Top or Bottom ? */
struct GRmd_env		*mod_env;       /*I current environnement */
IGRdouble		*ShipAxis;	/*I ship axis */
IGRdouble		*normal;	/*I average normal on plate surfaces*/
struct BendingLineInfo  *controlLine;	/*O control line output */
struct GRobj_env	*ControlObj;	/*O the control line curve */
{
IGRint 			loc_msg;                  
IGRlong			sts, loc_sts;
IGRint			nb_edge,i,nb_seg=0;
struct GRobj_env	contour_id[MAX_EDGES];
struct  IGRbsp_curve	*contour[MAX_EDGES];
struct  IGRbsp_curve	**tab_cv[MAX_PLATES];
IGRint			Num_Edges[MAX_PLATES];
struct  GRvg_construct  cst;
struct GRid		plane;
struct GRobj_env	inter[MAX_PLATES],res[MAX_PLATES],tmp[MAX_PLATES];
struct GRobj_env	Icv[MAX_PLATES],cp_obj;
IGRboolean              adj,clo;
struct GRlc_info	entries[MAX_PLATES];
IGRshort		inv[MAX_PLATES],inv1[MAX_PLATES],*inv2;
IGRvector       	pln_vec;
IGRvector       	tmp_S_axis,vec;
struct IGRbsp_curve	*cv;
IGRdouble		dotp,DIS_EPS1,EPS2;
IGRint			ret;
IGRdouble 		axis[3];

  *msg = MSFAIL;
  ret = 1;
  if (nb_plates > MAX_PLATES) {
    ex$message(msgnumb = VL_E_PlClFail);
    ret = 0;
    goto quit;
  }
  VLinitCnst(&cst);
  cst.env_info =  mod_env;
  BSxtractpar ( msg, BSTOLCHRDHT, &EPS);
  BSxtractpar ( msg, BSTOLBASIS, &EPS1);
  DIS_EPS1 = 5*EPS;
  EPS2 = EPS1;

  EPS = 2*EPS;
  EPS1 = 2*EPS1;
  DIS_EPS = sqrt(3*EPS*EPS);

    /* find plates's contour */
  sts = VLmakeContour(&loc_msg,nb_plates,plates,name,&nb_edge,
                        contour_id,contour,mod_env,1,tab_cv,Num_Edges);
  if (!(sts&loc_msg&1)) {
    printf( "Error in VLmakeContour()\n");
    ret = 0;
    goto quit;
  }

   /* compute control line on this contour */
  sts = VLsimpleClLine(&loc_msg,contour,ShipAxis, controlLine,nb_plates);
  if (!(sts&loc_msg&1)) {
    printf( "Error in VLsimpleClLine()\n");
    ret = 0;
    goto quit;
  }

  if (normal == NULL) normal = controlLine->normal;

   /* construct a plane cutting surfaces */
  axis[0] = controlLine->point1[0] - controlLine->point2[0];
  axis[1] = controlLine->point1[1] - controlLine->point2[1];
  axis[2] = controlLine->point1[2] - controlLine->point2[2];
  BScrossp(&loc_msg,axis,normal,pln_vec);
  if (loc_msg != BSSUCC) {
    ex$message(msgnumb = VL_E_PlClFail);
    printf( "Error in BScrossp()\n");
    ret = 0;
    goto quit;
  }
  VLcreatePlane(controlLine->point1,pln_vec,mod_env,&cst,&plane,&loc_sts);
  if (!(loc_sts&1)) {
    ex$message(msgnumb = VL_E_PlClFail);
    printf( "Error in VLcreatePlane()\n");
    ret = 0;
    goto quit;
  }

  /* project control line on the surfaces */
  for (nb_seg=0,i=0;i<nb_plates; i++)
  {
    inter[i].obj_id.objid = NULL_OBJID;
    inter[i].obj_id.osnum = mod_env->md_id.osnum;
    inter[i].mod_env = *mod_env;
    if ((vs$is_ancestry_valid( object   = &plates[i].obj_id,
                                classid = OPP_VSimgFeature_class_id )
                  == TRUE)) {
        sts = om$send(msg = message GRgraphics.GRcopy(
                                                &loc_sts,
                                                &surf[i].mod_env,
                                                mod_env,
                                                &cp_obj.obj_id.objid ),
                                senderid = NULL_OBJID,
                                targetid = surf[i].obj_id.objid,
                                targetos = surf[i].obj_id.osnum );
        cp_obj.obj_id.osnum = mod_env->md_id.osnum;
        if( ! (sts&loc_sts&1)){
           ex$message(msgnumb = VL_E_PlClFail);
           printf( "Error in GRgraphics.GRcopy() ...\n");
           ret = 0;
           goto quit;
        }
        cp_obj.mod_env = *mod_env;
        VLcreateInter(&loc_sts,&cp_obj.obj_id,&cp_obj.mod_env,1,
                        &plane,mod_env,0,&inter[i].obj_id,mod_env);
        if (loc_sts & 1) {
          Icv[nb_seg] = inter[i];
          nb_seg++;
        }
        om$send(    msg      = message GRgraphics.GRdelete
                                      ( &loc_sts, mod_env ),
                      senderid = NULL_OBJID,
                      targetid = cp_obj.obj_id.objid,
                      targetos = cp_obj.obj_id.osnum );
     }
     else {
       VLcreateInter(&loc_sts,&surf[i].obj_id,&surf[i].mod_env,1,
                       &plane,mod_env,0,&inter[i].obj_id,mod_env);
       if (loc_sts & 1) {
         Icv[nb_seg] = inter[i];
         nb_seg++;
       }
     }
  }
  /* Order obtained curves */
  OrderCrv(Icv,nb_seg,DIS_EPS1,EPS2,res,inv,&adj,&clo,&loc_msg);
  if (loc_msg != BSSUCC) {
    ex$message(msgnumb = VL_E_PlClFail);
    printf( "Error in OrderCrv()\n");
    ret = 0;
    goto quit;
  }
  sts = om$send(msg = message GRvg.GRgenabsg(&loc_sts,
					&Icv[0].mod_env.md_env.matrix_type,
					Icv[0].mod_env.md_env.matrix,
					(IGRchar **)&cv),
 		  senderid = NULL_OBJID,
                  targetid = Icv[0].obj_id.objid,
                  targetos = Icv[0].obj_id.osnum );
  if (!(sts&loc_sts&1)) {
    ex$message(msgnumb = VL_E_PlClFail);
    printf( "Error in GRvg.GRgenabsg()\n");
    ret = 0;
    goto quit;
  }
  vec[0] = inv[0]*(cv->poles[3*(cv->num_poles-1)] - cv->poles[0]);
  vec[1] = inv[0]*(cv->poles[3*(cv->num_poles-1)+1] - cv->poles[1]);
  vec[2] = inv[0]*(cv->poles[3*(cv->num_poles-1)+2] - cv->poles[2]);
  tmp_S_axis[0] = ShipAxis[0];
  tmp_S_axis[1] = ShipAxis[1];
  tmp_S_axis[2] = ShipAxis[2];
  BSnorvec( &loc_msg, vec );
  BSnorvec( &loc_msg, tmp_S_axis );
  if (loc_msg != BSSUCC) {ret=0;goto quit;}
  dotp = BSdotp( &loc_msg, vec, tmp_S_axis);
  if (dotp >= 0) {
    for ( i=0; i<nb_seg; i++) {
      tmp[i].mod_env = res[i].mod_env;
      tmp[i].obj_id  = res[i].obj_id;
    }
    inv2 = inv;
  }
  else {
    for ( i=0; i<nb_seg; i++) {
      tmp[i].mod_env = res[nb_seg-i-1].mod_env;
      tmp[i].obj_id  = res[nb_seg-i-1].obj_id;
      inv1[i] = inv[nb_seg-i-1]*-1;
    }
    inv2 = inv1;
  }
  ControlObj->obj_id.osnum =  cst.env_info->md_id.osnum;
  ControlObj->obj_id.objid =   NULL_OBJID;
  ControlObj->mod_env      = *(cst.env_info);

  /* Build the final curve */
  BuildCrv ( 1, tmp, nb_seg, inv2, adj, clo, entries, &cst,
             &ControlObj->obj_id,&loc_msg);
  if (loc_msg != BSSUCC) {
    ex$message(msgnumb = VL_E_PlClFail);
    printf( "Error in BuildCrv()\n");
    ret = 0;
    goto quit;
  }
  *msg = MSSUCC;
quit:
   if (ret)
     VLdel_mem(nb_plates,Num_Edges,tab_cv);
   om$send(    msg      = message GRgraphics.GRdelete
                                      ( &sts, mod_env ),
                      senderid = NULL_OBJID,
                      targetid = plane.objid,
                      targetos = plane.osnum );
  for (i=0;i<nb_seg;i++)
  {
    om$send(    msg      = message GRgraphics.GRdelete
                                      ( &sts, mod_env ),
                      senderid = NULL_OBJID,
                      targetid = Icv[i].obj_id.objid,
                      targetos = Icv[i].obj_id.osnum );
  }
  if (ret) return 1;
  else return 0;
}

IGRlong VLget_ext_contour( IGRlong          		*msg,
			   IGRint           		nb_surf,
			   struct GRobj_env 		*surf_list,
			   struct GRvg_construct 	*cst,
			   struct GRid      		*ext_contour )
{
   IGRint      		i, j, edbufsize=0, nb_edges=0, nb_nodes=0, ext_edges=0,
			*Sindex=NULL, *Eindex=NULL;
   IGRboolean           *Exterior=NULL;
   IGRlong     		sts=OM_S_SUCCESS;
   IGRpoint		*node_list=NULL;
   struct GRid 		*edge_list=NULL;
   struct IGRbsp_curve 	edgeom;
   struct GRobj_env     *Iedges=NULL, *Oedges=NULL;
   struct GRlc_info     *entries=NULL;
   IGRshort        	*inv=NULL;
   IGRboolean      	adj, clo;
   IGRdouble            base_tol;

   for( i=0; i<nb_surf; ++i )
   {
      sts = om$send(msg = message EMSsurface.EMgetedges( msg, EMS_OPT_ALL,
                                 &edge_list, &edbufsize, &nb_edges, 
				 NULL, NULL, NULL,NULL), 
		senderid = NULL_OBJID,
	       	targetid = surf_list[i]._objid,
		targetos = surf_list[i]._osnum  );
      __CheckRC( sts, *msg, "Getting edges from surf", wrapup ) ;
   }

   node_list = _MALLOC( (nb_edges*2), IGRpoint );
   Sindex    = _MALLOC( nb_edges, IGRint );
   Eindex    = _MALLOC( nb_edges, IGRint );
   Exterior  = _MALLOC( nb_edges, IGRboolean );

   for( i=0; i<nb_edges; ++i )
   {
      edgeom.poles = NULL;
      edgeom.knots = NULL;
      edgeom.weights = NULL;
      edgeom.bdrys = NULL;

      sts = om$send ( msg = message EMSedge.EMget_bcxyz_geom (
                             msg, &surf_list[0].mod_env.md_env, NULL, NULL, 0,
                             MAXINT, FALSE, NULL, &edgeom ),
		senderid = NULL_OBJID,
           	targetid = edge_list[i].objid,
		targetos = edge_list[i].osnum  );
      __CheckRC( sts, *msg, "Getting edge geometry", wrapup ) ;

      if( nb_nodes )
      {
	 IGRboolean s_def = FALSE, e_def = FALSE;

	 for( j=0; j<nb_nodes; ++j )
	 {
	    if( !s_def && VLsame_point ( &node_list[j][0], 
			&edgeom.poles[0], MAX_TOL ) )
	    {
	       Sindex[i] = j;
	       s_def     = TRUE;
            }
	    else if( !e_def && VLsame_point ( &node_list[j][0], 
			&edgeom.poles[3*(edgeom.num_poles-1)], MAX_TOL ) )
            {
	       Eindex[i] = j;
	       e_def     = TRUE;
	    }
	 }

	 if( !s_def )
	 {
	    node_list[nb_nodes][0] = edgeom.poles[0];
	    node_list[nb_nodes][1] = edgeom.poles[1];
	    node_list[nb_nodes][2] = edgeom.poles[2];
	    Sindex[i] = nb_nodes;
	    ++nb_nodes;
	 }

	 if( !e_def )
	 {
	    node_list[nb_nodes][0] = edgeom.poles[3*(edgeom.num_poles-1)];
	    node_list[nb_nodes][1] = edgeom.poles[3*(edgeom.num_poles-1)+1];
	    node_list[nb_nodes][2] = edgeom.poles[3*(edgeom.num_poles-1)+2];
	    Eindex[i] = nb_nodes;
	    ++nb_nodes;
	 }
      }
      else
      {
         node_list[nb_nodes][0] = edgeom.poles[0];
         node_list[nb_nodes][1] = edgeom.poles[1];
         node_list[nb_nodes][2] = edgeom.poles[2];
	 Sindex[i] = 0;
         ++nb_nodes;

         node_list[nb_nodes][0] = edgeom.poles[3*(edgeom.num_poles-1)];
         node_list[nb_nodes][1] = edgeom.poles[3*(edgeom.num_poles-1)+1];
         node_list[nb_nodes][2] = edgeom.poles[3*(edgeom.num_poles-1)+2];
	 Eindex[i] = 1;
         ++nb_nodes;
      }
      Exterior[i] = TRUE;
   }

   for( i=0; i<nb_edges; ++i )
   {
      for( j=i+1; j<nb_edges; ++j )
      {
	 if( ( (Sindex[i] == Sindex[j]) && (Eindex[i] == Eindex[j]) ) ||
	     ( (Sindex[i] == Eindex[j]) && (Sindex[j] == Eindex[i]) )    )
         {
	    Exterior[i] = FALSE;
	    Exterior[j] = FALSE;
	    break;
         }
      }
   }

   for( i=0; i<nb_edges; ++i )
   {
      if( Exterior[i] )	   
      {
	 edge_list[ext_edges++] = edge_list[i];
      }
   }

   if( !ext_edges ) goto wrapup;

   __DBGpr_objlist( "Extrnal Edges", ext_edges, edge_list );

   Iedges  = _MALLOC( ext_edges, struct GRobj_env );
   Oedges  = _MALLOC( ext_edges, struct GRobj_env );
   entries = _MALLOC( ext_edges, struct GRlc_info );
   inv     = _MALLOC( ext_edges, IGRshort );

   for( i=0; i<ext_edges; ++i )
   {
      /*c Build the edges of contour */
      Iedges[i]._osnum = cst->env_info->md_id.osnum;

      edgeom.poles = NULL;
      edgeom.knots = NULL;
      edgeom.weights = NULL;
      edgeom.bdrys = NULL;

      sts = om$send ( msg = message EMSedge.EMget_bcxyz_geom (
                             msg, &surf_list[0].mod_env.md_env, NULL, NULL, 0,
                             MAXINT, FALSE, NULL, &edgeom ),
		senderid = NULL_OBJID,
           	targetid = edge_list[i].objid,
		targetos = edge_list[i].osnum  );
      __CheckRC( sts, *msg, "Getting edge geometry", wrapup ) ;

      cst->geometry = (char *)&edgeom;

      sts    = om$construct( classid = OPP_GRbcsubbc_class_id,
                             osnum   = Iedges[i]._osnum,
                             p_objid = &Iedges[i]._objid,
			     msg     = message GRgraphics.GRconstruct(cst) );
      __CheckRC( sts, 1, "Constructing b-spline", wrapup ) ;

      Iedges[i].mod_env = surf_list[0].mod_env;
      cst->geometry = NULL;
   }

   BSxtractpar ( msg, BSTOLBASIS,  &base_tol);
   if (*msg != BSSUCC) { printf( "Error in BSxtractpar() : %d\n", *msg);
                              *msg = MSFAIL; goto wrapup; }

   /*c Order the edges of contour */
   OrderCrv ( Iedges, ext_edges, MAX_TOL, base_tol, Oedges, inv, &adj, &clo, msg);
   if (*msg != BSSUCC) { printf( "Error in OrderCrv() : %d\n", *msg);
                              *msg = MSFAIL; goto wrapup; }

   /*c Build the edges of contour */
   for ( i=0; i<ext_edges; ++i) 
   { 
      entries[i].module_info = Oedges[i].mod_env;
      entries[i].located_obj = Oedges[i].obj_id;
   }

   BuildCrv ( 3, Oedges, ext_edges, inv, adj, clo, entries, cst, ext_contour, msg);
   if (*msg != BSSUCC) { printf( "Error in BuildCrv() : %d\n", *msg);
                              *msg = MSFAIL; goto wrapup; }
   else *msg = MSSUCC;

wrapup:

   if( inv       )  { om$dealloc ( ptr = inv       );  inv       = NULL; }
   if( Iedges    )  { om$dealloc ( ptr = Iedges    );  Iedges    = NULL; }
   if( Oedges    )  { om$dealloc ( ptr = Oedges    );  Oedges    = NULL; }
   if( entries   )  { om$dealloc ( ptr = entries   );  entries   = NULL; }
   if( Sindex    )  { om$dealloc ( ptr = Sindex    );  Sindex    = NULL; }
   if( Eindex    )  { om$dealloc ( ptr = Eindex    );  Eindex    = NULL; }
   if( Exterior  )  { om$dealloc ( ptr = Exterior  );  Exterior  = NULL; }
   if( node_list )  { om$dealloc ( ptr = node_list );  node_list = NULL; }
   if( edge_list )  { om$dealloc ( ptr = edge_list );  edge_list = NULL; }

   return sts;
}

IGRlong VLgetContour (msg,nb_plates,plates,name, contour_id, cnst_list )
int 			nb_plates;  /* I: plate's number */
struct GRobj_env  	*plates;    /* I: plates */
IGRchar			*name;      /* I: plate surface name (Top or Bottom) */
struct GRvg_construct   *cnst_list; /* I: Construction List */
int			*msg;       /* O: completion code */
struct GRid		*contour_id;/* O: External Contour ID */
{
IGRint			ind, ret;
IGRlong			sts, loc_sts;
struct	GRobj_env	base_surf,
			surf[MAX_PLATES]; /* surfaces supporting plates */

    *msg = MSSUCC;
    ret = 1;

    if (nb_plates > MAX_PLATES) {
      ex$message(msgnumb = VL_E_PlClFail);
      ret = 0;
      goto quit;
    }

    for( ind=0; ind<nb_plates; ind = ind + 1 )
    {
      if(
         (vs$is_ancestry_valid( object   = &plates[ind].obj_id,
			        classid = OPP_VSplate_class_id )
		  == TRUE) ||
         (vs$is_ancestry_valid( object   = &plates[ind].obj_id,
			        classid = OPP_VSimgFeature_class_id )
		  == TRUE)
        ) {
      /*
       * Get bottom side of plate.
       */
        sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                          &loc_sts,
                                          VS_K_plBotSfPath,
                                          &base_surf.obj_id,
                                          &base_surf.mod_env.md_env.matrix_type,
                                          base_surf.mod_env.md_env.matrix),
                         senderid = NULL_OBJID,
                         targetid = plates[ind].obj_id.objid,
                         targetos = plates[ind].obj_id.osnum ) ;
        if( !( loc_sts & 1 & sts ) ) {
           ex$message(msgnumb = VL_E_PlClFail);
	   printf( "Error in NDmacro.ACreturn_foot(%s) ...\n", name);
	   ret = 0;
           goto quit;
        }
        base_surf.mod_env.md_id.osnum = base_surf.obj_id.osnum;
      }
      else {
        base_surf = plates[ind];
      }

     /* if TOP is not the recquired face */
     if ( !strcmp(name,VS_K_plTopSfPath) ||
           !((vs$is_ancestry_valid( object   = &plates[ind].obj_id,
			          classid = OPP_VSplate_class_id )
		    == FALSE) &&
           (vs$is_ancestry_valid( object   = &plates[ind].obj_id,
			          classid = OPP_VSimgFeature_class_id )
		    == FALSE))
        ) {
        /* get top side of plate */
        sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                          &loc_sts,
                                          VS_K_plTopSfPath,
                                          &base_surf.obj_id,
                                          NULL,
                                          NULL),
                         senderid = NULL_OBJID,
                         targetid = plates[ind].obj_id.objid,
                         targetos = plates[ind].obj_id.osnum ) ;
        if( !( loc_sts & 1 & sts ) ) {
           ex$message(msgnumb = VL_E_PlClFail);
	   printf( "Error in NDmacro.ACreturn_foot(%s) ...\n", name);
	   ret = 0;
           goto quit;
        }
        base_surf.mod_env.md_id.osnum = base_surf.obj_id.osnum;
      }

      /* Copy the base surfaces into surf() array */
      sts = om$send(msg = message GRgraphics.GRcopy(
                                                &loc_sts,
                                                &base_surf.mod_env,
                                                cnst_list->env_info,
                                                &surf[ind]._objid ),
                                senderid = NULL_OBJID,
                                targetid = base_surf.obj_id.objid,
                                targetos = base_surf.obj_id.osnum );

        if( ! (sts&loc_sts&1)){
           ex$message(msgnumb = VL_E_PlClFail);
	   printf( "Error in GRgraphics.GRcopy() ...\n");
	   ret = 0;
           goto quit;
        }
        surf[ind].mod_env = *cnst_list->env_info;
        surf[ind]._osnum  = cnst_list->env_info->md_id.osnum;
    } /* end for */

    sts = VLget_ext_contour( &loc_sts, nb_plates, surf, cnst_list, contour_id ); 
    if( !(sts&loc_sts&1)) {
           ex$message(msgnumb = VL_E_PlClFail);
           printf( "Error in VLget_ext_contour() ...\n");
           ret = 0;
           goto quit;
     }
    ret = 1;

quit:
     return ret;
}

end implementation VLabstract;
