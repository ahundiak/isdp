/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method outputs the prompt string and returns the mask
 needed by the getevent function for the following simple commands:

                 Command                      my_type
        ----------------------------------    -------
	Place solid box by two points		1
	Place box by four points		2
	Place solid box by four points		3
	Place cone by axis and radii		4
  	Place solid right trunc. cone		5
	Place cylinder by axis and radius	6
	Place solid right circ. cylinder	7
	Place torus				8
	Place solid torus			9
	Place solid right elliptical cylinder	10
	Place solid trunc. elliptical cone	11
	Place ellipsoid - foci axis len.	12
	Place ellipsoid - ctr. axis rad.	13
	Place solid 4 face 4 vert. polyhedron	14
	Place solid 5 face 5 vert. polyhedron	15
	Place solid 5 face 6 vert. polyhedron	16
	Place solid 6 face 7 vert. polyhedron	17
	Place solid 6 face 8 vert. polyhedron	18
	Place rectangular plane by 3 points	19
	Place parallelogram plane by 3 points	20
	Place solid right angle wedge		21
	Rho conic				22
	Conic by 3 points and 2 tangents	23
	Conic by 4 points and 1 tangent		24
	Conic by 5 points			25
	Place sphere by center and radius	26
	Place solid globe			27
	Place solid ellipsoid - foci axis len.	28
	Place solid ellipsoid - ctr. axis rad.	29
	Place right elliptical cylinder		30
	Place trunc. elliptical cone		31
	Place part of curve			32
	Place parabola tangent to 2 curves	33
	Place blend between 2 curves		34
	Place plane encompassing planar element	35
	Place helix				36
	Place partial surface			37
        Place surface of revolution		38
        Place solid of revolution               39
        Project curve onto surface along norm   40
        Project point along vector onto surf    41
        Project curve along vector onto surf    42
	Place surface by 3 boundaries		43
	Place surface by 4 boundaries		44

	Place offset surface			45
        code for Place offset surface is moved to
        src_testco/imp ECcsoffseti.I

        Blend 2 surfaces - interior		46
	Blend 2 surfaces - exterior		47
	Place fillet surface			48
	Place plane tangent to surface		49
	Place plane tangent to curve		50
						51
        Extract iso curves			52
	Place surface of projection		83
	Place solid of projection		84
	Intersect elements			85
	Place conic by linestring		93
	Place plane normal to curve		94
						--
	Place solid by offsetting surface	109
						--
	Cross hatch				111
        Create wireframe model			112
        Place parting lines as curves		113
						--
        Place fillet surface with auto trim	115
        Place parting lines as features		201
	Display isophotes                       202
	Place angular parting surface		203
	
 History

 10/27/87 : rlw : The beginning
 01/04/88 : rlw : Added some commands
 01/11/88 : rlw : Changed identify prompt for solid of projection
 01/15/88 : rlw : Changed the identify prompt for surface of projection,
                  actually I removed the planar curve restriction as
                  per Attilio's direction.  Did the same for surface of
                  revolution.
 01/17/88 : rlw : Modified solid of projection to allow for identification
                  of planar surfaces.
 02/09/88 : rlw : Changed GRm_STRING to GRm_TEXT_VALUE on Shelley Heard's
                  recommendation.
 02/19/88 : rlw : Modified project curve onto surface along vector to allow
                  for locate of composite surfaces.
 03/22/88 : rlw : Added place conic by linestring command and
                  place plane normal to curve command.
 05/30/88 : rlw : Modified fillet surface to support variable radius.
 06/29/88 : rlw : Added the place blending surface command
 07/04/88 : rlw : Added the place reduced fit curve command
 07/14/88 : rlw : Added Place solid by offsetting surface command
                  Modified the prompts for place plane encompassing command
 07/28/88 : rlw : Added Cross hatch command
 08/01/88 : rlw : Added Create wireframe model command, note that this
                  was originally witten by Sunit on 01/21/88.
                  Added Place parting lines command.
 08/05/88 : rlw : Removed curve data reduction and moved it to modify.
 08/29/88 : rlw : Added additional question for sweep direction of helix.
 09/02/88 : rlw : Added fillet with auto trim
 09/20/88 : rlw : Modified intersect two elements to not allow duplicate
                  locate unless first object is a curve.
 12/01/88 : rlw : Moved the place blending surface (105) command to a
                  separate class due to changes in the command.
 01/16/89 : rlw : Modified to disallow location of rigid childred in fillet
                  surface with trim and per Gupta's request.
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 04/14/89 : rlw : Modified to allow groups of planes for cross hatching.
                  Modified to allow groups of curves for place plane
                  encompassing planar element.
 08/01/89 : pp  : Added command to place isophotes.
 08/16/89 : pp  : Modified the project curve onto surface command to
                  let the user identify an infinite plane and to support
                  sets for curves.
 21-Sep-89: SM  : Added 'Place angular parting surface'
 02-Aug-90:ashok: Added/Modified conditional compilation statements to
		  include commands "conic by ......" (23, 24 and 25) in the
		  MDS(I/DRAW) product.
 Sep 5,90:Inasu : Added/modified conditional compilation statements  to
                  include command 33. 
 1/2/92  :  np  : Mofified the code such that a "surface" cannot be picked for
                  the "place solid of projection"(84)command, in the associative
                  mode. Once the code to associatively place a solid of 
                  projection from a surface is in place, then this change can 
                  be undone. Also look at file "ECprfprmcons.I" at the history
                  dated 1/2/92 for some other changes that may need to be 
                  undone. Also see comments below under "case 84" of "case 84",
                  of "case 0" of the outermost switch.

 Tapadia 03/25/92 Commented case 84 as it's overriden (ECplsolproj.I)
 sam     03/19/93 code for place offset surface (case 45)is moved to
                  src_testco/imp/ECcsoffseti.I.

 */

class implementation ECconstruct;

%safe
#include <math.h>
%endsafe

#include "EMS.h"		/* Shared library stuff */
#include "ems_m_inc.h"		/* Includes everything */
#include "EC_P.h"		/* Message keys for prompt strings */
#include "EC_I.h"		/* Message keys for status strings */
#include <stdio.h>

#define BIG_CURVE 0
#define LITTLE_CURVE 1
#define LITTLE_SURFACE 2
#define LITTLE_ELEMENT 3
#define ANY_ELEMENT 4
#define BIG_SURFACE 5

#ifndef IDRAW
extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSplane_class_id;
extern OMuword OPP_EMScompsurf_class_id;
#endif
extern OMuword OPP_GRcurve_class_id;
extern OMuword OPP_GRbspline_class_id;

method next_event_processing(
 IGRchar	*prompt_string;
 IGRlong	*prompt_index;
 IGRlong	*event_mask;
 IGRlong	*type_of_value_needed;
 IGRboolean	*locate_desired;
 struct		RLW_locate_info *loc_info)

{
 extern		void EFget_locate_information();
 IGRlong	key, integer_to_encode, *my_msg, my_type, 
		save_num_events = 0;
 IGRboolean     prompt_string_set = FALSE;
		
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
 my_type = me->mytype;
 save_num_events = me->number_of_events_input;

 /* For type 203 I am interested in only events 0, 1, 2, and 3. After that
    the pattern for events 2 and 3 repeats.
 */
 if( (my_type == 203) && (save_num_events > 3))
  {
   if(save_num_events % 2) me->number_of_events_input = 3;
   else me->number_of_events_input = 2;
  }

/*
 * Initialize
 */
 *my_msg = MSSUCC;
 integer_to_encode = 0;
/*
 * Branch based on the command state
 */
 switch (me->number_of_events_input)
  {
/*
 * Event 1 prompt
 */
   case 0:
    switch (my_type)
     {
      case  1:
      case 14:
      case 15:
      case 16:
      case 17:
      case 18:
      case 22:
      case 23:
      case 24:
      case 25:
       key = EMS_P_00013;
       integer_to_encode = 1;
       break;
#ifndef IDRAW
      case  2:
      case  3:
       key = EMS_P_00016;
       break;
      case 4:
      case 5:
      case 6:
      case 7:
      case 10:
      case 11:
      case 30:
      case 31:
       key = EMS_P_00004;
       break;
      case  8:
      case  9:
      case 36:
       key = EMS_P_00014;
       break;
      case 12:
      case 28:
       key = EMS_P_00009;
       break;
      case 13:
      case 29:
      case 26:
      case 27:
       key = EMS_P_00005;
       break;
      case 19:
      case 20:
      case 42:
       key = EMS_P_00015;
       break;
      case 21:
       key = EMS_P_00006;
       break;
#endif
      case 32:
      case 35:
      case 38:
      case 39:
      case 40:
      case 43:
      case 44:
      case 83:
/*
      case 84:
*/
      case 93:
      case 111:
       *locate_desired = TRUE;
       EFget_locate_information(BIG_CURVE, loc_info);
       switch (my_type)
        {
#ifndef IDRAW
         case 32:
          key = EMS_P_00030;
          loc_info->acc_key = EMS_P_00039;
          break;
         case 35:
          key = EMS_P_00067;
          loc_info->are_groups_allowed = TRUE;
          loc_info->acc_key = EMS_P_00149;
          loc_info->planar_flag = LC_PLANAR_ONLY;
          break;
         case 38:
          key = EMS_P_00030;
/*  Comment out planar curve only logic           */
/*        key = EMS_P_00036;                      */
/*        loc_info->planar_flag = LC_PLANAR_ONLY; */
          loc_info->acc_key = EMS_P_00042;
          break;
         case 39:
          key = EMS_P_00036;
          loc_info->planar_flag = LC_PLANAR_ONLY;
          loc_info->acc_key = EMS_P_00042;
          break;
         case 40:
          key = EMS_P_00030;
          loc_info->accept_event_type = chained;
          loc_info->acc_key = EMS_P_00043;
          break;
         case 43:
         case 44:
          key = EMS_P_00035;
          integer_to_encode = 1;
          loc_info->accept_event_type = chained;
          loc_info->acc_key = EMS_P_00045;
          break;
         case 83:
          key = EMS_P_00030;
/*  Comment out planar curve only logic           */
/*        key = EMS_P_00036;                      */
/*        loc_info->planar_flag = LC_PLANAR_ONLY; */
          loc_info->acc_key = EMS_P_00044;
          break;
/*
         case 84:
*/
         case 111:
          key = EMS_P_00106;
          loc_info->rtree_classes.w_count = 2;
          loc_info->operation_type = info_read_only; /* I am lying for 111 */
          loc_info->relocate_key = EMS_I_00013;
          loc_info->r_classes[0] = OPP_GRbspline_class_id;
          loc_info->e_classes[0] = OPP_GRcurve_class_id;
          loc_info->planar_flag = LC_PLANAR_ONLY;
          if (my_type == 84)
           {
            /* since code for solid of projection from surfaces is not yet made
             * associative, we disable the user from picking up surfaces to 
             * project, since the "EMsweep_surface_with_lift_face" code was 
             * wrongly notifying the batch list and causing the solid of 
             * projection to vanish. When the assoc. code is in, then the 
             * "if-else" statement below should be replaced by the "else" part
             * of the statement.
             */
	      if (me->associative)
	      {
                loc_info->eligible_classes.w_count = 1;
                loc_info->rtree_classes.w_count    = 1;
                loc_info->acc_key = EMS_P_00044;
		key = EMS_P_00034; /*pick ONLY closed curves prompt*/
      	      }
	      else
              {
                loc_info->eligible_classes.w_count = 2;
                loc_info->r_classes[1] = OPP_EMSsubbs_class_id;
                loc_info->e_classes[1] = OPP_EMSsubbs_class_id;
                loc_info->acc_key = EMS_P_00044;
	      }
           }
          else
           {
            loc_info->eligible_classes.w_count = 3;
            loc_info->r_classes[1] = OPP_EMSplane_class_id;
            loc_info->e_classes[1] = OPP_EMSplane_class_id;
            loc_info->e_classes[2] = OPP_EMScompsurf_class_id;
            loc_info->acc_key = EMS_P_00149;
           }
          break;
#endif
         case 93:
          key = EMS_P_00087;
          loc_info->accept_event_type = dummy;
          loc_info->planar_flag = LC_PLANAR_ONLY;
          break;
        } /* switch (my_type) */
       break;
/* The follwing case was moved and modified from below for MDS -Inasu */
case 33:
       *locate_desired = TRUE;
       EFget_locate_information(LITTLE_CURVE, loc_info);
       key = EMS_P_00035;
       integer_to_encode = 1;
        loc_info->acc_key = EMS_P_00040;
       break;
#ifndef IDRAW
      case 34:
       *locate_desired = TRUE;
       EFget_locate_information(LITTLE_CURVE, loc_info);
       key = EMS_P_00035;
       integer_to_encode = 1;
       if (my_type == 33)
        loc_info->acc_key = EMS_P_00040;
       else
        loc_info->acc_key = EMS_P_00041;
       break;
      case 37:
      case 41:
      case 46:
      case 47:
      case 48:
      case 52:
      case 109:
      case 115:
      case 203:
       *locate_desired = TRUE;
       EFget_locate_information(LITTLE_SURFACE, loc_info);
       switch (my_type)
        {
         case 37:
          key = EMS_P_00031;
          loc_info->acc_key = EMS_P_00039;
          break;
         case 41:
          key = EMS_P_00031;
          loc_info->acc_key = EMS_P_00044;
          break;
         case 45:        /* code is moved to src_testco/imp/ECcsoffseti.I 
			    for case 45.*/
         case 109:
          key = EMS_P_00031;
          loc_info->accept_event_type = dummy;
          break;
         case 46:
          key = EMS_P_00062;
          integer_to_encode = 1;
          loc_info->accept_event_type = chained;
          loc_info->acc_key = EMS_P_00046;
          break;
         case 47:
          key = EMS_P_00062;
          integer_to_encode = 1;
          loc_info->acc_key = EMS_P_00047;
          break;
         case 115:
          loc_info->operation_type = geometry_modification;
         case 48:     /* Note that 115 falls into this case */
          key = EMS_P_00062;
          integer_to_encode = 1;
          loc_info->accept_event_type = dummy;
          ex$message(msgnumb=EMS_I_InvkStatusFrm);/* SM - TR11926238*/
          GRstatus_display_button(1);
          break;
         case 52:
          key = EMS_P_00031;
          loc_info->acc_key = EMS_P_00048;
          break;
	 case 203:
	  key = EMS_P_00031;
          loc_info->acc_key = EMS_P_AccWPtOnSd;
	  break;
        } /* switch (my_type) */
       break;
      case 45:        /* code is moved to src_testco/imp/ECcsoffseti.I 
			    for case 45.*/
      case 112:
      case 113:
      case 201:
      case 202:
       *locate_desired = TRUE;
       EFget_locate_information(BIG_SURFACE, loc_info);
       switch(my_type)
        {
         case 112:
          key = EMS_P_00134;
          loc_info->accept_event_type = dummy;
          loc_info->operation_type = info_read_only;
          loc_info->are_groups_allowed = TRUE;
          break;
         case 45:        /* code is moved to src_testco/imp/ECcsoffseti.I 
			    for case 45.*/
          key = EMS_P_00031;
          loc_info->accept_event_type = dummy;
          break;
         case 113:
         case 201:
	 case 202:
          key = EMS_P_00134;
          loc_info->acc_key = EMS_P_00149;
          loc_info->operation_type = info_read_only;
          loc_info->are_groups_allowed = TRUE;
          break;
        } /* switch (my_type) */
       break;
      case 49:
      case 50:
      case 94:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00072;
       break;
#endif
      case 85:
       *locate_desired = TRUE;
       EFget_locate_information(ANY_ELEMENT, loc_info);
       key = EMS_P_00102;
       integer_to_encode = 1;
       loc_info->accept_event_type = chained;
       loc_info->acc_key = EMS_P_00101;
       break;
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 2 prompt
 */
   case 1:
    switch (my_type)
     {
#ifndef IDRAW
      case  1:
      case 14:
      case 15:
      case 16:
      case 17:
      case 18:
#endif /* added -ashok 2/aug/90 */
      case 23:
      case 24:
      case 25:
       key = EMS_P_00013;
       integer_to_encode = 2;
       break;
#ifndef IDRAW /* added -ashok 02/aug/90 */
      case  2:
      case  3:
       key = EMS_P_00019;
       break;
      case 4:
      case 5:
      case 6:
      case 7:
      case 10:
      case 11:
      case 30:
      case 31:
       key = EMS_P_00011;
       break;
      case  8:
      case  9:
      case 36:
       key = EMS_P_00017;
       break;
      case 12:
      case 28:
       key = EMS_P_00010;
       break;
      case 13:
      case 29:
       key = EMS_P_00012;
       break;
      case 19:
      case 20:
      case 42:
       key = EMS_P_00018;
       break;
      case 21:
       key = EMS_P_00027;
       break;
#endif
      case 22:
       key = EMS_P_00025;
       break;
      case 33:
       key = EMS_P_00052;
       break;
#ifndef IDRAW
      case 26:
      case 27:
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00003;
       break;
      case 32:
      case 37:
       key = EMS_P_00049;
       break;
      case 34:
       key = EMS_P_00053;
       break;
      case 35:
      case 111:
       key = EMS_P_00148;
       break;
      case 38:
      case 39:
       key = EMS_P_00014;
       break;
      case 40:
       *locate_desired = TRUE;
       EFget_locate_information(LITTLE_SURFACE, loc_info);
       switch (my_type)
        {
         case 40:
          key = EMS_P_00031;
          loc_info->accept_event_type = dummy;
          break;
        } /* switch (my_type) */
       break;
      case 41:
      case 83:
/*
      case 84:
*/
       key = EMS_P_00057;
       break;
      case 43:
      case 44:
      case 46:
       *locate_desired = TRUE;
       EFget_locate_information(BIG_CURVE, loc_info);
       switch (my_type)
        {
         case 43:
         case 44:
          key = EMS_P_00035;
          integer_to_encode = 2;
          loc_info->accept_event_type = chained;
          loc_info->acc_key = EMS_P_00045;
          break;
         case 46:
          key = EMS_P_00035;
          integer_to_encode = 1;
          loc_info->accept_event_type = dummy;
          break;
        } /* switch (my_type) */
       break;
      case 45:        /* code is moved to src_testco/imp/ECcsoffseti.I 
			    for case 45.*/
      case 48:
      case 109:
      case 115:
       *event_mask |= GRm_RJT_MOVEON;
       key = EMS_P_00061;
       break;
      case 47:
       key = EMS_P_00064;
       break;
      case 49:
      case 50:
      case 94:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00073;
       break;
      case  52:
       key = EMS_P_00074;
       break;
#endif
      case 85:
       *locate_desired = TRUE;
       EFget_locate_information(ANY_ELEMENT, loc_info);
       key = EMS_P_00102;
       integer_to_encode = 2;
       loc_info->accept_event_type = dummy;
       if (me->events[0].located_object[0].geom_parms.polygon_inx)
        loc_info->allow_duplicate_objects = TRUE;
       break;
#ifndef IDRAW
      case 113:
      case 201:
      case 202:
       key = EMS_P_00148;
       break;

      case 203:
       *locate_desired = FALSE;
       key = EMS_P_InPtOnSd;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 3 prompt
 */
   case 2:
    switch (my_type)
     {
#ifndef IDRAW
      case  2:
      case  3:
      case 19:
      case 20:
      case 21:
      case 42:
       key = EMS_P_00011;
       break;
      case 4:
      case 5:
       *type_of_value_needed = DISTANCE;
/*     key = EMS_P_00002; */
/* start KLUDGE ********/
       strcpy (prompt_string, "Enter height diameter");
       prompt_string_set = TRUE;
/* end KLUDGE **********/
       break;
      case 6:
      case 7:
       *type_of_value_needed = DISTANCE;
/*     key = EMS_P_00003; */
/* start KLUDGE ********/
       strcpy (prompt_string, "Enter diameter");
       prompt_string_set = TRUE;
/* end KLUDGE **********/

       break;
      case  8:
      case  9:
       key = EMS_P_00005;
       break;
      case 10:
      case 11:
      case 30:
      case 31:
       key = EMS_P_00022;
       break;
      case 12:
      case 28:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00028;
       break;
      case 13:
      case 29:
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00021;
       break;
      case 14:
      case 15:
      case 16:
      case 17:
      case 18:
#endif
      case 23:
      case 24:
      case 25:
       key = EMS_P_00013;
       integer_to_encode = 3;
       break;
/* #endif */
      case 22:
       key = EMS_P_00013;
       integer_to_encode = 2;
       break;
/* The follwing case was moved and modified from below for MDS -Inasu */
      case 33:
       *locate_desired = TRUE;
       EFget_locate_information(LITTLE_CURVE, loc_info);
       key = EMS_P_00035;
       integer_to_encode = 2;
       loc_info->acc_key = EMS_P_00040;
       break;
#ifndef IDRAW
      case 32:
      case 37:
       key = EMS_P_00050;
       break;
      case 50:
      case 94:
       *locate_desired = TRUE;
       EFget_locate_information(LITTLE_CURVE, loc_info);
       key = EMS_P_00030;
       loc_info->acc_key = EMS_P_00070;
       break;
      case 34:
       key = EMS_P_00054;
       break;
      case 35:
      case 111:
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       key = EMS_P_00147;
       break;
      case 36:
       key = EMS_P_00077;
       break;
      case 38:
      case 39:
       key = EMS_P_00017;
       break;
      case 41:
       key = EMS_P_00058;
       break;
      case 43:
      case 44:
       *locate_desired = TRUE;
       EFget_locate_information(BIG_CURVE, loc_info);
       switch (my_type)
        {
         case 43:
          key = EMS_P_00035;
          integer_to_encode = 3;
          loc_info->accept_event_type = dummy;
          break;
         case 44:
          key = EMS_P_00035;
          integer_to_encode = 3;
          loc_info->accept_event_type = chained;
          loc_info->acc_key = EMS_P_00045;
          break;
        } /* switch (my_type) */
       break;
      case 45:        /* code is moved to src_testco/imp/ECcsoffseti.I 
			    for case 45.*/
      case 109:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00060;
       break;
      case 46:
      case 47:
      case 52:
       *event_mask |= GRm_RJT_MOVEON;
       key = EMS_P_00061;
       break;
      case 48:
      case 49:
      case 115:
       *locate_desired = TRUE;
       EFget_locate_information(LITTLE_SURFACE, loc_info);
       switch (my_type)
        {
         case 115:
          loc_info->operation_type = geometry_modification;
         case 48:			/* Note 115 falls into this case */
          key = EMS_P_00062;
          integer_to_encode = 2;
          loc_info->accept_event_type = dummy;
          break;
         case 49:
          key = EMS_P_00031;
          loc_info->acc_key = EMS_P_00068;
          break;
        } /* switch (my_type) */
       break;
      case 83:
/*
      case 84:
*/
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       key = EMS_P_00104;
       break;
      case 202:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = ANGLE;
       key = EMS_P_00164;
/*
 * Maybe there is a better place to give  this information.
 */
       ex$message(msgnumb = EMS_I_00103)/* Parting line is a 
                                           90degree isophote */
      break;
      case 203:
        *locate_desired = TRUE;
        integer_to_encode = (save_num_events - 2)/2 + 1;
        EFget_locate_information(BIG_CURVE, loc_info);
        key = integer_to_encode > 1 ? EMS_P_IdNPrtLnMvOn : EMS_P_IdNPrtLn;
        loc_info->acc_key = EMS_P_AccWAngPrtLn;
	loc_info->accept_event_type = chained;
	loc_info->allow_duplicate_objects = TRUE;
        if(integer_to_encode > 1) *event_mask |= GRm_RJT_MOVEON;
      break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 4 prompt
 */
   case 3:
    switch (my_type)
     {
#ifndef IDRAW
      case  2:
      case  3:
      case 19:
      case 20:
      case 21:
       key = EMS_P_00007;
       break;
      case  4:
      case  5:
       *type_of_value_needed = DISTANCE;
/*     key = EMS_P_00001; */
/* start KLUDGE ********/
       strcpy (prompt_string, "Enter base diameter");
       prompt_string_set = TRUE;
/* end KLUDGE **********/
       break;
      case  8:
      case  9:
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00003;
       break;
      case 10:
      case 11:
      case 30:
      case 31:
       key = EMS_P_00024;
       break;
      case 14:
      case 15:
      case 16:
      case 17:
      case 18:
#endif
      case 24:
      case 25:
       key = EMS_P_00013;
       integer_to_encode = 4;
       break;
/* #endif */
      case 22:
       key = EMS_P_00008;
       break;
/* #ifndef IDRAW  moved this line down 2/aug/90 to bring in new commands to MDS */
      case 23:
       key = EMS_P_00025;
       break;
      case 33:
       key = EMS_P_00052;
       break;
#ifndef IDRAW
      case 32:
      case 37:
       key = EMS_P_00051;
       break;
      case 34:
       *locate_desired = TRUE;
       EFget_locate_information(LITTLE_CURVE, loc_info);
       key = EMS_P_00035;
       integer_to_encode = 2;
       loc_info->acc_key = EMS_P_00041;
       break;
      case 35:
      case 111:
       *event_mask |= GRm_RJT_MOVEON;
       key = EMS_P_00038;
       break;
      case 36:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00078;
       break;
      case 38:
      case 39:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = ANGLE;
       key = EMS_P_00055;
       break;
      case 41:
       key = EMS_P_00059;
       break;
      case 42:
       *locate_desired = TRUE;
       EFget_locate_information(BIG_SURFACE,loc_info);
       switch(my_type)
       {
        case 42:
          key = EMS_P_00158;
          loc_info->acc_key = EMS_P_00044;
        break;
       }
       break;
      case 44:
       *locate_desired = TRUE;
       EFget_locate_information(BIG_CURVE, loc_info);
       switch (my_type)
        {
         case 44:
          key = EMS_P_00035;
          integer_to_encode = 4;
          loc_info->accept_event_type = dummy;
          break;
        } /* switch (my_type) */
       break;
      case 46:
      case 47:
       key = EMS_P_00054;
       break;
      case 48:
      case 115:
       *event_mask |= GRm_RJT_MOVEON;
       key = EMS_P_00061;
       break;
      case 49:
       key = EMS_P_00069;
       break;
      case 50:
      case 94:
       key = EMS_P_00071;
       break;
      case 52:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = SCALAR;
       key = EMS_P_00075;
       break;
      case 83:
/*
      case 84:
*/
       {
        IGRboolean	have_plane, is_ortho;

        have_plane = me->events[0].located_object[0].geom_parms.polygon_inx;
        is_ortho = me->events[2].located_object[0].geom_parms.polygon_inx;
        if (have_plane &&
            is_ortho)
         {
          *type_of_value_needed = DISTANCE;
          key = EMS_P_00105;
         }
        else
         key = EMS_P_00058;
       }
       break;
       case 202:
        *event_mask &= ~GRm_DATA;
        *event_mask |= GRm_RJT_MOVEON;
        *type_of_value_needed = ANGLE;
        key = EMS_P_00156;
        break;
       case 203:
        *locate_desired = TRUE;
        EFget_locate_information(BIG_CURVE, loc_info);
        key = EMS_P_IdAngPrtLn;
        loc_info->acc_key = EMS_P_00038;
	loc_info->accept_event_type = dummy;
        integer_to_encode = (save_num_events - 2)/2 + 1;
        break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 5 prompt
 */
   case 4:
    switch (my_type)
     {
#ifndef IDRAW
      case 11:
      case 31:
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00023;
       break;
      case 15:
      case 16:
      case 17:
      case 18:
#endif  /* 02/aug/90  Moved this line from below */
      case 25:
       key = EMS_P_00013;
       integer_to_encode = 5;
       break;
/* #endif  02/aug/90 commented */
      case 22:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = SCALAR;
       key = EMS_P_00029;
       break;
/* #ifndef IDRAW 02/aug/90 commented */
      case 23:
       key = EMS_P_00008;
       break;
      case 24:
       key = EMS_P_00025;
       break;
#ifndef IDRAW    /* 02/aug/90 Moved this from above */
      case 34:
       key = EMS_P_00053;
       break;
      case 36:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00079;
       break;
      case 38:
      case 39:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = ANGLE;
       key = EMS_P_00056;
       break;
      case 42:
       key = EMS_P_00057;
       break;
      case 46:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = SCALAR;
       key = EMS_P_00063;
       break;
      case 47:
       *locate_desired = TRUE;
       EFget_locate_information(LITTLE_SURFACE, loc_info);
       key = EMS_P_00062;
       integer_to_encode = 2;
       loc_info->acc_key = EMS_P_00047;
       break;
      case 48:
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_VALUE;
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00078;
       break;
      case 115:
       key = EMS_P_00077;
       break;
      case 52:
       key = EMS_P_00076;
       break;

      case 202:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = SCALAR;
       key = EMS_P_00157;
      break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 6 prompt
 */
   case 5:
    switch (my_type)
     {
#ifndef IDRAW
      case 16:
      case 17:
      case 18:
       key = EMS_P_00013;
       integer_to_encode = 6;
       break;
      case 34:
       key = EMS_P_00054;
       break;
      case 36:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00081;
       break;
      case 42:
       key = EMS_P_00058;
       break;
      case 46:
       *locate_desired = TRUE;
       EFget_locate_information(LITTLE_SURFACE, loc_info);
       switch (my_type)
        {
         case 46:
          key = EMS_P_00062;
          integer_to_encode = 2;
          loc_info->accept_event_type = chained;
          loc_info->acc_key = EMS_P_00046;
          break;
        } /* switch (my_type) */
       break;
      case 47:
       key = EMS_P_00064;
       break;
      case 48:
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_VALUE;
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00079;
       break;
      case 115:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00078;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 7 prompt
 */
   case 6:
    switch (my_type)
     {
#ifndef IDRAW
      case 17:
      case 18:
       key = EMS_P_00013;
       integer_to_encode = 7;
       break;
      case 36:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = SCALAR;
       key = EMS_P_00080;
       break;
      case 42:
       *locate_desired = TRUE;
       EFget_locate_information(BIG_CURVE, loc_info);
       key = EMS_P_00159;
       loc_info->operation_type = info_read_only;
       loc_info->are_groups_allowed = TRUE;
       loc_info->accept_event_type = dummy;
       break;
      case 46:
       *locate_desired = TRUE;
       EFget_locate_information(BIG_CURVE, loc_info);
       switch (my_type)
        {
         case 46:
          integer_to_encode = 2;
          key = EMS_P_00035;
          loc_info->accept_event_type = dummy;
          break;
        } /* switch (my_type) */       
       break;
      case 47:
       *event_mask |= GRm_RJT_MOVEON;
       key = EMS_P_00061;
       break;
      case 48:
       key =EMS_P_00077;
       break;
      case 115:
       *event_mask |= GRm_RJT_MOVEON;
       key = EMS_P_00138;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 8 prompt
 */
   case 7:
    switch (my_type)
     {
#ifndef IDRAW
      case 18:
       key = EMS_P_00013;
       integer_to_encode = 8;
       break;
      case 36:
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       key = EMS_P_00153;
       break;
      case 46:
       *event_mask |= GRm_RJT_MOVEON;
       key = EMS_P_00061;
       break;
      case 47:
       key = EMS_P_00054;
       break;
      case 48:
       key = EMS_P_00165;
       break;
      case 115:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = DISTANCE;
       key = EMS_P_00079;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 9 prompt
 */
   case 8:
    switch (my_type)
     {
#ifndef IDRAW
      case 46:
       key = EMS_P_00054;
       break;
      case 48:
      case 115:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = SCALAR;
       key = EMS_P_00065;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 10 prompt
 */
   case 9:
    switch (my_type)
     {
#ifndef IDRAW
      case 46:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = SCALAR;
       key = EMS_P_00063;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Error 
 */
   default:
    *my_msg = MSFAIL;
    goto wrapup;
  } /* switch (me->number_of_events_input) */
/*
 * Fix the event mask
 */
 if (*type_of_value_needed)
  *event_mask |= GRm_VALUE;
/*
 * Get the prompt string if not already done.
 */
 if (prompt_string_set != TRUE)
 {
     if (integer_to_encode)
      {
       ex$message(
        msgnumb = key,
        type = "%d",
        var = `integer_to_encode`,
        buff = prompt_string);
      }
     else
      {
       ex$message(
        msgnumb = key,
        buff = prompt_string);
      } 
 }

/*
 * eof
 */
wrapup:
 if( (my_type == 203) && (save_num_events > 3))
  me->number_of_events_input = save_num_events;

 if (1 & *my_msg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation ECconstruct;
