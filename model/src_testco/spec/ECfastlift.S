/* ###################   APOGEE COMPILED   ################## */
class specification ECfastlift (1:0) of ECbase;

#include "ems_m_inc.h"		/* Every file in the system */

/* History 
   ???? - Creation
   Tapadia  05/17/91 - Added GRevent dist_eve. Changed datum_surface from GRid
			to GRlc_info.
   scw      08/14/94 - Clarified sleep method
*/

struct lift_packet
 {
  struct	GRid top_state_before;
  struct	GRlc_info datum_surface;
  IGRint	number_of_curves;
  struct	GRlc_info *curves;
  IGRdouble	*distances;
 };

instance ECfastlift
 {
/*
 * The module enviroment of the solid
 */
  struct	GRmd_env md_env;
/*
 * The current top local mod state
 */
  struct	GRid top_lm_state;
/*
 * Lift information
 */
  IGRint	number_of_datum_surfaces;
  struct	lift_packet *lift_packet;
  variable  struct GRevent dist_eve[10];
  IGRboolean    is_associative;
 };

override execute, delete, wakeup, super_cmd.sleep;

end specification ECfastlift;

