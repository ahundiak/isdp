
#ifndef EMSdpb_include
#define EMSdpb_include 1

/* *************************************************************************

   This include file contains the declarations pertaining to the
   ems default parameter block.

   History
          PP  : 10/19/87                 Creation
          PP  : 04/28/87                 Added a bit for locating/not locating
                                         edges.
          RC  : 11/30/88                 Added definitions related to 
                                         cross section.
          SS  : 03/20/90                 Added bit for associative placement
   ************************************************************************* */



/**
   Following is an explanation of bit mask stored in the properties field of
   the instance data in EMSdpb.S
 **/ 

#define EMDPB_POLYGON_DISPLAY_ON  0x01
#define EMDPB_U_PERIODIC          0x02
#define EMDPB_V_PERIODIC          0x04
#define EMDPB_IGNORE_BOUNDARIES   0x08 
#define EMDPB_LOCATE_EDGES        0x10
#define EMDPB_UPDATE_XSECTION     0x20
#define EMDPB_REF_LOCK_ON         0x40

/**
  Declarations for accessing the parameters stored in the default
  parameter block
 **/

#define EMSdpb_u_order 0          /* Default U order                      */
#define EMSdpb_v_order 1          /* Default V order                      */
#define EMSdpb_u_rules 2          /* Default No of U rule lines           */
#define EMSdpb_v_rules 3          /* Default No of V rule lines           */
#define EMSdpb_props   4          /* Default bit mask for the following
                                     properties.
                                     EMDPB_POLYGON_DISPLAY_ON
                                     EMDPB_U_PERIODIC
                                     EMDPB_V_PERIODIC
                                     EMDPB_IGNORE_BOUNDARIES
                                     EMDPB_IGNORE_EDGES       
                                     EMDPB_UPDATE_XSECTION
                                   */
struct EMdpbinfo
 {
  unsigned char       u_order; /* U order of a surface. */  
  unsigned char       v_order; /* V order of a surface. */
  unsigned char       u_rules; /* No of rule lines in U direction */
  unsigned char       v_rules; /* No of rule lines in V direction */
  unsigned char       props;   /* A props mask explained below */

/* *************************************************

 Explanation of props bit mask
 ------------------------------

Bit           Meaning                            
---           -------
0             Polygon display on/off.
1             Consider boundaries on/off.            
2             is u_periodic
3             is v_periodic
4             edges are locatable
5             update cross section automatically
6             Associative placement turned on
7	      Future expansion
  ************************************************** */
 };

#endif
