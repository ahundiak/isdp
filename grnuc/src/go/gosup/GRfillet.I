/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRvg
     METHOD NAME: GRfillet

     Abstract: This routine produces a fillet arc between two
	      objects and trims the curves according to a
	      input flag.
-----
%SC%    

     GRfillet(msg,obj1,env1,pt1,parms1,obj2,env2,pt2,parms2,radius,center,
	      trim_flag,tr_pnt1,tr_pnt2,arc,newid1,newid2)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     obj1	  GRid		 first object and space number
     env1	  GRmd_env	 first object environment information
     pt1	  IGRpoint	 approximate tangent point on obj1
     parms1	  GRparms	 geometric parameters for object 1
     obj2	  GRid		 second object and space number
     env2	  GRmd_env	 second object environment information
     pt2	  IGRpoint	 approximate tangent point on obj2
     parms2	  GRparms	 geometric parameters for object 2
     radius	  IGRdouble	 radius of fillet
     center	  IGRline	 line identifying approx center of fillet
     trim_flag	  IGRshort	 flag for trimming
     tr_pnt1	  IGRpoint	 point on part of first object which
				 is to be kept
     tr_pnt2	  IGRpoint	 point on part of second object which
				 is to be kept

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful     
					MSFAIL - an error occured or
				 failure to find fillet
					MASDGENRAST - targets of 
				 fillet were colinear

     arc	  IGRbsp_curve	 fillet arc
     newid1	  GRobjid	 new object id if trim on obj1
     newid2	  GRobjid	 new object id if trim on obj2

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
		BSfillet
		BSfilletatr
		BSfillettr1
		BSfillettr2
     Methods:
		GR2ptpartdel
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:
		The flag, trim_flag is used as follows:

			0 - do not trim either curve
			1 - manual trim first curve only
			2 - manual trim second curve only
			3 - manual trim both curves
			4 - automatically trim both curves
			5 - automatically trim first curve
			6 - automatically trim second curve

	   In addition, if the trim flag has the value 1, 2, or 3,
	   the points tr_pnt1 and tr_pnt2 will be used to determine
	   which portion of the object to keep.

	   If the trim flag indicates automatic trim for either or
	   both elements and one of the elements is closed, the trim
	   will not occurr for the element since this routine does not
	   have enough data to decide how the curve(s) should be 
	   trimmed.

		The storage for the arc must be allocated before
	   calling this routine.

-----
%CH%

     CHANGE HISTORY:
	
	RDH     06/18/86 : Design date.
        dhm     10/26/93 : 119311828 - return MANONPLANAR if BScvcoplan fails.
        dhm     11/10/93 : 119311828 - give BScvcoplan the regular geometry
                           and not the extended geometry. Then project the
                           extended geometry onto the plane defined by the 
                           normal vector and a point on the curve.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine gets the geometries and properties of the two objects
and switches on the value of the trim flag to call the appropriate
BS math routine to find the fillet and trim the input curve if 
nescessary.

----*/
/*EH*/


class implementation GRvg;


#include "grimport.h"
#include "OMmacros.h"
#include "grerr.h"
#include "msdef.h"
#include "bserr.h"
#include "maerr.h"

from GRcurve import GRptextend;

extern    IGRboolean    GRget2objgeom();
extern    IGRboolean    MAdetplane();
extern    IGRboolean    MAlnplproj();
extern    IGRboolean    BSprj_cv_pl();
extern    void          BSxtlntcvbx();

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif

IGRboolean GRfillet(msg,obj1,env1,pt1,parms1,obj2,env2,pt2,parms2,radius,
		    center,trim_flag,tr_pnt1,tr_pnt2,arc,newid1,newid2)

	   long                *msg;	/* return code			     */
	   struct GRid         *obj1;	/* first object and space number     */
	   struct GRmd_env     *env1;   /* first object environment info     */
	   IGRpoint	 	pt1;	/* approximate tangent point on obj1 */
	   struct GRparms      *parms1; /* first object geometrical paras    */
	   struct GRid         *obj2;	/* second object and space info      */
	   struct GRmd_env     *env2;   /* second object environment info    */
	   IGRpoint		pt2;	/* approximate tangent point on obj2 */
	   struct GRparms      *parms2; /* second object geometrical parms   */
	   IGRdouble   	       *radius;	/* radius of desired fillet	     */
	   struct IGRline      *center;	/* approximate center of fillet      */
	   short   	       *trim_flag; /* flag for trimming		     */
	   IGRpoint		tr_pnt1;/* point on portion of obj1 to keep  */
	   IGRpoint		tr_pnt2;/* point on portion of obj2 to keep  */
	   struct IGRbsp_curve *arc;	/* the fillet arc		     */
	   GRobjid	       *newid1; /* new object id if trimming obj1    */
	   GRobjid	       *newid2; /* new object id if trimming obj2    */

{
  struct GRid id;      /* object id used in trimming       */
  struct GRid *objid;      /* object pointer used in trimming   */
  struct IGRbsp_curve *bc1,*bc2;  /* abstract geom pointers       */
  struct IGRbsp_curve *prj_crv1, *prj_crv2;  /* projected extended curves */
  struct IGRbsp_curve bc_ln1,bc_ln2;  /* B-spline lines         */
  struct IGRbsp_curve fillet;    /* the fillet arc         */
  struct GRprops props1,props2;    /* geometric properties               */
  struct IGRplane pl;      /* approx plane of fillet       */
  struct IGRbsp_curve ptcv;             /* tan pts and approx center for     */
  /* extension routine                 */
  struct IGRbsp_curve *curves[3];
  struct IGRline line;
  struct IGRpolyline py;

  IGRvector normal;      /* normal to pl           */

  IGRpoint pl_pt;      /* point for pl           */
  IGRpoint pl_pt1, pl_pt2;  /* points for plane */
  IGRpoint origin;      /* origin of fillet arc         */
  IGRpoint app_center;      /* approx center of fillet       */
  IGRpoint ext_pt,end_pt,newend;  /* extend point data         */
  IGRpoint line_pt;      /* project point of center onto pl   */

  double    buf1[200],buf2[200];  /* default geometry buffers       */
  double    poles1[6],knots1[4];  /* storage for ex_ln1         */
  double    poles2[6],knots2[4];  /* storage for ex_ln2         */
  double    pt_poles[9],pt_knots[5];    /* storage for ptcv                  */
  double    fil_poles[21];
  double    fil_knots[10];
  double    fil_wts[7];
  double    fpars[2];      /* parameters of tangent points      */
  double    h;        /* homogeneous factor         */
  double    u,u1,u2;
  double    t;        /* t parameter of line_pt       */

  long    s1;        /* size of default buffers       */
  long    mess;        /* return code           */
  long    mess1;
  long    segnum;
  long    OMmsg,OMmsg1,OMmsg2;    /* OM return code         */
  long    num_curves;

  short    tr_flag;      /* trim flag           */
  short    option;      /* evaluation option         */

  char    *ptr1,*ptr2;      /* abstract geom pointers       */

  IGRboolean cpx1,cpx2;      /* extended/composite curve flag     */
  IGRboolean ex1,ex2;      /* extended geometry flags       */
  IGRboolean done;      /* done processing         */
  IGRboolean pdel_1,pdel_2;    /* flag that trimming is desired     */
  IGRboolean trim1,trim2;
  IGRboolean start;

  *msg = MSSUCC;
  OMmsg1 = OM_S_SUCCESS;
  OMmsg2 = OM_S_SUCCESS;

  prj_crv1 = prj_crv2 = NULL;

  cpx1 = cpx2 = FALSE;      /* set flags for no complex elements */

  ex1 = ex2 = FALSE;

  trim1 = trim2 = TRUE;

  s1 = 200 * sizeof( double    );

  if( GRget2objgeom(msg,obj1,&env1->md_env,&ex1,obj2,&env2->md_env,&ex2,buf1,
      buf2,&s1,&s1,&ptr1,&ptr2,&props1,&props2) )
  {
    bc1 = (struct IGRbsp_curve *)ptr1;
    bc2 = (struct IGRbsp_curve *)ptr2;

    /*
     * 119311828 - dhm 11/10/93
     * Determine if the original curves are co-planar. If so, then get a point
     * on each curve to define the normal plane to the curves.
     */

    if( !BScvcoplan(&mess,bc1,bc2,normal) )
    {
      *msg = MANONPLANAR;
      goto wrapup;
    }

    if( bc1->rational )
    {
      pl_pt1[0] = bc1->poles[0]/bc1->weights[0];
      pl_pt1[1] = bc1->poles[1]/bc1->weights[0];
      pl_pt1[2] = bc1->poles[2]/bc1->weights[0];
    }
    else
    {
      pl_pt1[0] = bc1->poles[0];
      pl_pt1[1] = bc1->poles[1];
      pl_pt1[2] = bc1->poles[2];
    }

    if( bc2->rational )
    {
      pl_pt2[0] = bc2->poles[0]/bc2->weights[0];
      pl_pt2[1] = bc2->poles[1]/bc2->weights[0];
      pl_pt2[2] = bc2->poles[2]/bc2->weights[0];
    }
    else
    {
      pl_pt2[0] = bc2->poles[0];
      pl_pt2[1] = bc2->poles[1];
      pl_pt2[2] = bc2->poles[2];
    }

    /*
     * 119311828 - dhm 11/10/93
     * Project the extended geometry onto the plane defined by the normal
     * vector.  This will ensure that curves that are within the tolerance
     * allowed will process okay.
     */

    ex1 = ex2 = TRUE;

    if(!GRget2objgeom(msg,obj1,&env1->md_env,&ex1,obj2,&env2->md_env,&ex2,buf1,
      buf2,&s1,&s1,&ptr1,&ptr2,&props1,&props2) )
    {
      *msg = MSFAIL;
      goto wrapup;
    }

    bc1 = (struct IGRbsp_curve *)ptr1;
    bc2 = (struct IGRbsp_curve *)ptr2;

    BSalloccv(bc1->order, bc1->num_poles, bc1->rational, bc1->num_boundaries,
              &prj_crv1, &mess);

    BSalloccv(bc2->order, bc2->num_poles, bc2->rational, bc2->num_boundaries,
              &prj_crv2, &mess);

    if ( !BSprj_cv_pl(&mess, bc1, pl_pt1, normal, normal, prj_crv1) )
    {
      *msg = MSFAIL;
      goto wrapup;
    }

    bc1 = prj_crv1;

    if ( !BSprj_cv_pl(&mess, bc2, pl_pt2, normal, normal, prj_crv2) )
    {
      *msg = MSFAIL;
      goto wrapup;
    }

    bc2 = prj_crv2;

/***************  end modification for TR 119311828 *************************/

    if( props1.subtype == GRLN  ||  props2.subtype == GRLN )
    {
      py.num_points = 3;
      py.points = pt_poles;

      ptcv.poles = pt_poles;
      ptcv.knots = pt_knots;

      pt_poles[0] = pt1[0];
      pt_poles[1] = pt1[1];
      pt_poles[2] = pt1[2];

      pt_poles[3] = pt2[0];
      pt_poles[4] = pt2[1];
      pt_poles[5] = pt2[2];

      pt_poles[6] = center->point1[0];
      pt_poles[7] = center->point1[1];
      pt_poles[8] = center->point1[2];

      MApytobc(msg,&py,&ptcv);

      num_curves = 3;
      curves[0] = bc1;
      curves[1] = bc2;
      curves[2] = &ptcv;
    }

    if( props1.subtype == GRLN )
    {
      bc_ln1.poles = poles1;
      bc_ln1.knots = knots1;

      MAutoparms(msg,bc1,&parms1->u,&segnum,&t);

      line.point1 = &bc1->poles[(segnum - 1) * 3];
      line.point2 = &bc1->poles[segnum * 3];

      BSxtlntcvbx(&line,num_curves,curves,&bc_ln1,&mess);

      if( mess != BSSUCC )
      {
        *msg = MSFAIL;
        goto wrapup;
      }

      if( bc1->num_poles != 2 )
      {
        trim1 = FALSE;
      }

      bc1 = &bc_ln1;
    }

    if( props2.subtype == GRLN )
    {
      bc_ln2.poles = poles2;
      bc_ln2.knots = knots2;

      MAutoparms(msg,bc2,&parms2->u,&segnum,&t);

      line.point1 = &bc2->poles[(segnum - 1) * 3];
      line.point2 = &bc2->poles[segnum * 3];

      BSxtlntcvbx(&line,num_curves,curves,&bc_ln2,&mess);

      if( mess != BSSUCC )
      {
        *msg = MSFAIL;
        goto wrapup;
      }

      if( bc2->num_poles != 2 )
      {
        trim2 = FALSE;
      }

      bc2 = &bc_ln2;
    }

    if( bc1->rational )
    {
      pl_pt[0] = bc1->poles[0]/bc1->weights[0];
      pl_pt[1] = bc1->poles[1]/bc1->weights[0];
      pl_pt[2] = bc1->poles[2]/bc1->weights[0];
    }
    else
    {
      pl_pt[0] = bc1->poles[0];
      pl_pt[1] = bc1->poles[1];
      pl_pt[2] = bc1->poles[2];
    }

    pl.point = pl_pt;
    pl.normal = normal;

    MAlnplproj(msg,center,&pl,line_pt,app_center,&t);

    done = FALSE;

    pdel_1 = FALSE;
    pdel_2 = FALSE;

    if( IF_EQ_OBJID(obj1->objid,obj2->objid) )
    {
      tr_flag = 0;
    }
    else
    {
      tr_flag = *trim_flag;
    }

    objid = &id;

    if( tr_flag == 4 )
    {
      if( props1.closed  &&  props2.closed )
      {
        tr_flag = 0;
      }
      else
      {
        if( props1.closed )
        {
          tr_flag = 6;
        }
        else
        {
          if( props2.closed )
          {
            tr_flag = 5;
          }
        }
      }
    }
    else
    {
      if( tr_flag == 5  &&  props1.closed )
      {
        tr_flag = 0;
      }
      else
      {
        if( tr_flag == 6  &&  props2.closed )
        {
          tr_flag = 0;
        }
      }
    }

    if( props1.subtype == GRCN  &&  !props1.closed )
    {
      bc1->phy_closed = FALSE;
    }

    if( props2.subtype == GRCN  &&  !props2.closed )
    {
      bc2->phy_closed = FALSE;
    }

    bc1->num_boundaries = 0;
    bc1->bdrys = 0;
    bc2->num_boundaries = 0;
    bc2->bdrys = 0;

    fillet.poles = fil_poles;
    fillet.knots = fil_knots;
    fillet.weights = fil_wts;


    while( !done & *msg & OMmsg1 & OMmsg2 )
    {
      switch ( tr_flag )
      {
      case 0:
        {
          BSfillet(&mess,bc1,bc2,pt1,pt2,app_center,radius,&fillet,
              origin,fpars);

          break;
        }

      case 1:
        {
          pdel_1 = TRUE;

          BSfillettr1(&mess,bc1,bc2,pt1,pt2,app_center,radius,
              tr_pnt1,&fillet,origin);

          break;
        }

      case 2:
        {
          pdel_2 = TRUE;

          BSfillettr1(&mess,bc2,bc1,pt2,pt1,app_center,radius,
              tr_pnt2,&fillet,origin);

          if( mess == 0 )
          {
            MAbcrevparm(&mess1,&fillet,&fillet);
          }

          break;
        }

      case 3:
        {
          pdel_1 = TRUE;
          pdel_2 = TRUE;

          BSfillettr2(&mess,bc1,bc2,pt1,pt2,app_center,radius,
              tr_pnt1,tr_pnt2,&fillet,origin);

          break;
        }

      case 4:
        {
          pdel_1 = TRUE;
          pdel_2 = TRUE;

          BSfilletatr(&mess,bc1,bc2,pt1,pt2,app_center,radius,
              &fillet,origin);

          break;
        }

      case 5:
        {
          pdel_1 = TRUE;

          BSfilletatr(&mess,bc1,bc2,pt1,pt2,app_center,radius,
              &fillet,origin);

          break;
        }

      case 6:
        {
          pdel_2 = TRUE;

          BSfilletatr(&mess,bc1,bc2,pt1,pt2,app_center,radius,
              &fillet,origin);

          break;
        }

      case 7:
        {
          pdel_1 = TRUE;

          BSfillet(&mess,bc1,bc2,pt1,pt2,app_center,radius,&fillet,
              origin,fpars);

          if( mess == BSSUCC )
          {
            bc1->num_boundaries = 1;

            bc1->bdrys = fpars;
          }

          break;
        }

      default:
        {
          *msg = GRILLDEFINITION;
          goto wrapup;
        }
      }

      if (mess == BSSUCC)
      {
        MAbccopy(&mess,&fillet,arc);

        done = TRUE;
        option = 0;

        if( pdel_1  &&  trim1 )
        {
          if( bc1->num_boundaries == 1 )
          {
            u1 = bc1->bdrys[0];
            u2 = bc1->bdrys[1];

            if( u1 == bc1->knots[bc1->order - 1] )
            {
              u = u2;
              start = TRUE;
            }
            else
            {
              u = u1;
              start = FALSE;
            }

            MAbcueval(&mess,bc1,&option,&u,ext_pt,&h);

            OMmsg = om$send(msg = message GRvg.GRgetgeom(msg,
                &env1->md_env.matrix_type,env1->md_env.matrix,
                ptr1),
                senderid = obj1->objid,
                targetid = obj1->objid,
                targetos = obj1->osnum);

            if( 1 & OMmsg & *msg )
            {
              bc1 = (struct IGRbsp_curve *)ptr1;

              if( start )
              {
                u = bc1->knots[bc1->order - 1];
              }
              else
              {
                u = bc1->knots[bc1->num_poles];
              }

              MAbcueval(&mess,bc1,&option,&u,end_pt,&h);

              OMmsg1 = om$send(msg = message GRcurve.GRptextend(
                  msg,env1,end_pt,ext_pt,newend),
                  senderid = obj1->objid,
                  targetid = obj1->objid,
                  targetos = obj1->osnum);
            }
          }
        }

        if( pdel_2  &&  trim2  &&  (1 & OMmsg1 & *msg) )
        {
          if( bc2->num_boundaries == 1 )
          {
            u1 = bc2->bdrys[0];
            u2 = bc2->bdrys[1];

            if( u1 == bc2->knots[bc2->order - 1] )
            {
              u = u2;
              start = TRUE;
            }
            else
            {
              u = u1;
              start = FALSE;
            }

            MAbcueval(&mess,bc2,&option,&u,ext_pt,&h);

            OMmsg = om$send(msg = message GRvg.GRgetgeom(msg,
                &env2->md_env.matrix_type,env2->md_env.matrix,
                ptr2),
                senderid = obj2->objid,
                targetid = obj2->objid,
                targetos = obj2->osnum);

            if( 1 & OMmsg & *msg )
            {
              bc2 = (struct IGRbsp_curve *)ptr2;

              if( start )
              {
                u = bc2->knots[bc2->order - 1];
              }
              else
              {
                u = bc2->knots[bc2->num_poles];
              }

              MAbcueval(&mess,bc2,&option,&u,end_pt,&h);

              OMmsg1 = om$send(msg = message GRcurve.GRptextend(
                  msg,env2,end_pt,ext_pt,newend),
                  senderid = obj2->objid,
                  targetid = obj2->objid,
                  targetos = obj2->osnum);
            }
          }
        }
      }
      else
      {
        if( cpx1  ||  cpx2 )
        {
          /* get next component geometry */
        }
        else
        {
          *msg = MSFAIL;
        }
      }
    }
  }

wrapup:

  if( ptr2  &&  ptr2 != (char *)buf2 )      /* dealloc allocated storage */
  {
    om$dealloc(ptr = ptr2 );
  }
  if( ptr1  &&  ptr1 != (char *)buf1 )
  {
    om$dealloc(ptr = ptr1 );
  }

  if (prj_crv1) BSfreecv(&mess, prj_crv1);
  if (prj_crv2) BSfreecv(&mess, prj_crv2);

  return *msg == MSSUCC;
}

end implementation GRvg;

