/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD

     CLASS  NAME:  EMSgenbs
     METHOD NAME:  EMbs4cvs   

     Abstract: 
-----
%SC%    

     message EMbs4cvs (&msg;
                       &located_curve_1;
                       &curve1;
                       &located_curve_2;
                       &curve2;
                       &located_curve_3;
                       &curve3;
                       &located_curve_4;
                       &curve4;
                       orientation_point;
                       &construct_list)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
    
 *located_curve_1 struct GRlc_info locate information of the first
                                   curve
 *curve1          struct IGRbsp_curve curve buffer
 *located_curve_2 struct GRlc_info locate information of the second
                                   curve
 *curve2          struct IGRbsp_curve curve buffer
 *located_curve_3 struct GRlc_info locate information of the third
                                   curve
 *curve3          struct IGRbsp_curve curve buffer
 *located_curve_4 struct GRlc_info locate information of the fourth
                                   curve
 *curve4          struct IGRbsp_curve curve buffer
 orientation_pointIGRpoint         The surface orientation is flagged
                                   based on this point

 *construct_list                 structure containing the
                                 construction arguments for the surface
                struct           object that is being constructed from
                GRvg_construct   the three input curves. All fields
                                 except class_attr, geometry and 
                                 newflag are initialised in the command
                                 object.
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
       *msg       IGRlong        completion code
                             
                                 MSINARG - if one the input curves is
                                           not joined with others
                                 MSSUCC  - if successful in determining
                                           a surface
                                 MSFAIL  - if unsuccessful in determining
                                           a surface because of memory
                                           allocation problems or whatever
                                           reason. If there is a problem in
                                           allocating memory status of
                                           OM_E_ABORT is returned.
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  
     
     BSfreesf          -         For freeing memory associated with
                                 the surface structure.
     BSsf3o4cvs        -         This routine constructs a surface
                                 given three or four curves as 
                                 boundaries. 
     OM_stack_alloc    -         For allocating stack memory for the
                                 boundary or curve structures.
     OM_stack_dealloc  -         For freeing stack memory   
     
                          

     Methods:  
     
     GRconstruct       -         For updating the instance data of the
                                 surface object.           
                                 

-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

-----
%CH%

     CHANGE HISTORY:

    rlw : 03/25/88  : Memory was not freed correctly in the
                      wrapup logic.
    PP  : 01/19/88  : Modified this method to handle the three curves
                      case too.
    AIC : 15-Jul-87 : Do not generate element specific attributes.
    PP  : 02/06/87  : Modified the argument list to support input
                      of either curve geometry or curve id.
                      Also added the functionality so that the
                      surface orientation bit is flagged based on the
                      nat_side coming in
    PP  : 10/11/86  : Design date
    
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method forms a surface when given four  boundaries or curves
as input.  If any of the input curves are rational, the math
routine BSsf3o4cvs approximates it into nonrational cubic curves.
The command object initially creates an object of class EMSgenbs
and sends it the message corresponding to this method.  The
surface structure is then created and the instance data
of the surface object is thereafter updated.

Algorithm:

1) Get the abstract geometries for the four  curves by
   sending GRgetsize and GRgetgeom messages to the
   four  curve objects.
2) Call the math routine to create the surface structure when
   given four  curves as input. Since the method has no
   prior knowledge of the amount of memory needed for the
   surface structure the math routine allocates memory for
   the surface.
3) Assign the geometry and newflag fields of construct_list
   structure.
4) Send a message to GRconstruct to update the instance
   data of the surface object.
5) Deallocate memory.

----*/
/*EH*/


class implementation EMSgenbs;

#include "EMS.h"
# include "msdef.h" /* MS message codes */
# include "maerr.h"
# include <stdio.h>
# include "OMerrordef.h"
# include "OMstackalloc.h"
# include "msmacros.h"
# include "emsmacros.h"
# include "bserr.h"
# include "emsgetgeom.h"

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef NULL
#define NULL 0
#endif

method EMbs4cvs (IGRlong *msg;
                 struct GRlc_info *located_curve_1;
                 struct IGRbsp_curve *curve1;
                 struct GRlc_info *located_curve_2;
                 struct IGRbsp_curve *curve2;
                 struct GRlc_info *located_curve_3;
                 struct IGRbsp_curve *curve3;
                 struct GRlc_info *located_curve_4;
                 struct IGRbsp_curve *curve4;
                 IGRboolean nat_side;
                 struct GRvg_construct *construct_list)

{
 IGRlong        sts;                /* return code */
 IGRlong        rc;                 /* completion message */
 IGRlong        status;             /* OM return code */
 IGRlong        num_bytes;          /* variable storing the no of bytes that
                                       need to be allocated */
 struct         IGRbsp_curve *crv1; /* pointer to abstract geometry of
                                       crv1_GRid */
 struct         IGRbsp_curve *crv2; /* pointer to abstract geometry of
                                       crv2_GRid */
 struct         IGRbsp_curve *crv3; /* pointer to abstract geometry of
                                       crv3_GRid */   
 struct         IGRbsp_curve *crv4; /* pointer to abstract geometry of
                                       crv4_GRid */

 struct         IGRbsp_surface *surf;
                                    /* pointer to surface structure */
 
                                    /* function declarations */
  extern  void           BSsf3o4cvs();
  extern  IGRboolean     BSfreecv ();
  extern  IGRboolean     BSfreesf ();

/* Initialisation of om return code and method completion code */

 status = OM_S_SUCCESS;
 *msg = MSSUCC;
 crv1 = NULL;
 crv2 = NULL;
 crv3 = NULL;
 crv4 = NULL;
 surf = NULL;

/* Get the abstract geometry for the first curve object */

 if (curve1)
  crv1 = curve1;
 else if (located_curve_1)
  {
   EMS_GET_GEOMETRY(status, msg, located_curve_1, TRUE, crv1)
   if (! (1 & status & *msg)) goto wrapup;
  }
 else
  {
   *msg = MSINARG;
   goto wrapup;
  }
  

/* Get the abstract geometry for the second curve object */

 if (curve2)
  crv2 = curve2;
 else if (located_curve_2)
  {
   EMS_GET_GEOMETRY(status, msg, located_curve_2, TRUE, crv2)
   if (! (1 & status & *msg)) goto wrapup;
  }
 else
  {
   *msg = MSINARG;
   goto wrapup;
  }


/* Get the abstract geometry for the third  curve object */

 if (curve3)
  crv3 = curve3;
 else if (located_curve_3)
  {
   EMS_GET_GEOMETRY(status, msg, located_curve_3, TRUE, crv3)
   if (! (1 & status & *msg)) goto wrapup;
  }
 else
  {
   *msg = MSINARG;
   goto wrapup;
  }

/* Get the abstract geometry for the fourth curve object */

 if (curve4)
  crv4 = curve4;
 else if (located_curve_4)
  {
   EMS_GET_GEOMETRY(status, msg, located_curve_4, TRUE, crv4)
   if (! (1 & status & *msg)) goto wrapup;
  }
 else
  crv4 = NULL;
   

/* Call the math routine for determining the surface when given four
   curves as input */

 (void) BSsf3o4cvs( crv1, crv2, crv3, crv4, &surf, &rc);

 if (rc == BSSUCC) /* if successful in determining surface */
  {

/* Initialisation of the class attributes of class_attr field of the
   construct list
*/


    if (nat_side)
     surf->pos_orient = 1;
    else
     surf->pos_orient = 0;
      

/* Assign the geometry and newflag fields of construct_list */

   construct_list->newflag = FALSE;
   construct_list->geometry = (IGRchar *)surf;

/* Send GRconstruct message to surface object */

   status = om$send(mode = OM_e_wrt_object,
                    msg = message EMSgenbs.GRconstruct(construct_list),
                    senderid = my_id,
                    targetid = my_id);

   EMomerr_hndlr(status, wrapup, "EMbs4cvs: Error GRconstruct");

   *msg = MSSUCC;
  }
 else /* if not successful in determining surface */
  {
    *msg = MSFAIL;
    if (rc == BSNOMEMORY || rc == BSNOSTKMEMORY)
     {
       status = OM_E_ABORT;
     }
    else 
     if (rc == BSFAIL) *msg = MSINARG;
  }

/* deallocate memory allocated in this method */

wrapup:
   if ((*msg != MSSUCC) || (!status))
    {
      status = om$send(mode = OM_e_wrt_object,
                       msg = message Root.delete(1),
                       senderid = my_id,
                       targetid = my_id);
      if (!status) status = OM_E_ABORT;
    }
  if (crv1 && !curve1) om$dealloc (ptr = (IGRchar *) crv1);
  if (crv2 && !curve2) om$dealloc (ptr = (IGRchar *) crv2);
/*
  if (crv1 && !curve3) om$dealloc (ptr = (IGRchar *) crv3);
  if (crv1 && !curve4) om$dealloc (ptr = (IGRchar *) crv4);
 */
  if (crv3 && !curve3) om$dealloc (ptr = (IGRchar *) crv3);
  if (crv4 && !curve4) om$dealloc (ptr = (IGRchar *) crv4);
  if (surf) sts = BSfreesf (&rc, surf);
  
  return(status);

}
end implementation EMSgenbs;
