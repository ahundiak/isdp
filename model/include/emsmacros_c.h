#ifndef emsmacros_c_include
#define emsmacros_c_include 1

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

/*
   This macro determines if two min-max boxes intersect by checking
   if the max point of the first box is less than the min point of the
   second box or the max point of the second box is less than the min
   point of the first box. All the points concerned are 2D. The check is
   made within the specified tolerance.

   Note: It is suggested that EM2dbxinc be used on atleast one of the
   input boxes, to widen the box a little bit, to avoid any floating point
   tolerancing errors. 
*/


#define EM2dbxbxint(bx1, bx2) \
         ((((bx1)[2] <= (bx2)[0]) || ((bx2)[2] <= (bx1)[0]) || \
           ((bx1)[3] <= (bx2)[1]) || ((bx2)[3] <= (bx1)[1])) ? FALSE : TRUE)


/* The following macro determines whether bx1 is nested inside bx2. Both
   the boxes are 2D. To avoid tolerancing problems, the bx2 should be
   increased by tol or the bx1 should be decreased by tol.
*/

#define EM2dbxbxnest(bx1,bx2) \
         ((((bx1)[0] >= (bx2)[0]) && ((bx1)[1] >= (bx2)[1]) && \
           ((bx1)[2] <= (bx2)[2]) && ((bx1)[3] <= (bx2)[3])) ? TRUE : FALSE)

/*
  This macro increases the size of a given box by "tol" on all sides
  of the box, widening the box in width and height by an amount 2 * "tol".
*/

#define EM2dbxinc(bx, tol) \
  { \
  (bx)[0] -= (tol); \
  (bx)[1] -= (tol); \
  (bx)[2] += (tol); \
  (bx)[3] += (tol); \
  }

/*
  This macro increases the size of a given 3D box by "tol" on all sides
  of the box, widening the 3D box in length, breadth and height by an 
  amount 2 * "tol".
*/

#define EM3dbxinc(bx, tol) \
  { \
  (bx)[0] -= (tol); \
  (bx)[1] -= (tol); \
  (bx)[2] -= (tol); \
  (bx)[3] += (tol); \
  (bx)[4] += (tol); \
  (bx)[5] += (tol); \
  }


/*
  This macro decreases the size of a given 3D box by "tol" on all sides
  of the box, thining the 3D box in length, breadth and height by an 
  amount 2 * "tol".
*/

#define EM3dbxdec(bx, tol) \
  { \
  (bx)[0] += (tol); \
  (bx)[1] += (tol); \
  (bx)[2] += (tol); \
  (bx)[3] -= (tol); \
  (bx)[4] -= (tol); \
  (bx)[5] -= (tol); \
  }

#define EM2dbxdec(bx, tol) \
  { \
  (bx)[0] += (tol); \
  (bx)[1] += (tol); \
  (bx)[2] -= (tol); \
  (bx)[3] -= (tol); \
  }

/*
  The only reason this macro is written is because of the need to
  have a 2D-version of the BS-math function -> BSdistptpts. This macro
  cannot possibly have a return code other than success.
*/

#define EM2ddistptpts(pt1, pt2) \
          ((pt1)[0]-(pt2)[0])*((pt1)[0]-(pt2)[0]) + \
          ((pt1)[1]-(pt2)[1])*((pt1)[1]-(pt2)[1])

#define EM2ddistptpt(pt1, pt2) \
	sqrt(EM2ddistptpts(pt1, pt2))
	
#define IF_EQ_CHANNUM(chan1,chan2) \
         ( ((chan1).classid==(chan2).classid)&& \
         ( (chan1).number==(chan2).number)) ? TRUE : FALSE 

#define IF_EQ_GRID(grid1,grid2) \
         ( ((grid1).objid==(grid2).objid)&& \
         ( (grid1).osnum==(grid2).osnum)) ? TRUE : FALSE 

#define EM2dptinbx(box,pt) \
        ( ((pt)[0]>=(box)[0])&&((pt)[1]>=(box)[1])&&((pt)[0]<=(box)[2])&& \
          ((pt)[1]<=(box)[3])) ? TRUE : FALSE

/*
 * Store the partedge information
 */

#define EMput_partinfo(mypartinfo) \
      { \
       mypartinfo.edprops = ME.EMSedge->ed_props; \
       mypartinfo.edtype = ME.EMSedge->curve_type; \
       OM_BLOCK_MOVE (ME.EMSpartedge->boundary, mypartinfo.edbdry, 2 *  \
           sizeof (struct EMSedgebound)); \
       mypartinfo.edid = my_id; \
      }


/* Follwoing macro initializes the general information fields of the
   structure EMSedgeinfo (include/EMSbnd.h). The macro argument must be
   a pointer to the structure to be initialized.
   SM		23-Mar-89	Creation.
*/
#define EMPutGenEdInfo(edinfo) \
  { \
   (edinfo)->edgetype = EMSunknown; \
   (edinfo)->edgeid.objid = my_id; \
   (edinfo)->edgeid.osnum = OM_Gw_current_OS; \
   (edinfo)->edprops = ME.EMSedge->ed_props; \
   (edinfo)->curve_type = ME.EMSedge->curve_type; \
  }

/*
 * Assign the P_loop bit to out_props as the toggle of in_props.
 */
#define EMS_TOGGLE(in_props,out_props) \
        out_props = (in_props & EMIS_PLOOP) ? \
                   out_props & (~EMIS_PLOOP) : \
                   out_props | EMIS_PLOOP;

#endif
