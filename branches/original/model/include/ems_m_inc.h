/*
 Description

  This file represents the include files needed by the simple
  construction command object support functions.

 History

  10/15/87 : rlw : The beginning
  09/20/88 : rlw : Added filed to locate structure to specify whether
                   or not objects already located are eligible to be
                   relocated.
 */
/*
 * System includes
 */
#ifdef DEBUG
#include <stdio.h>		/* Needed for prints */
#endif

#include <string.h>		/* Needed for strcpy() */
/*
 * Basic includes
 */
#include "bs.h"			/* Has all the igr junk */
#include "bsparameters.h"	/* For tolerance stuff */
#include "igetypedef.h"		/* Has GRobjid */
#include "godef.h"		/* Needed by go.h */
#include "gr.h"			/* Has GRmd_env */
/*
 * Display includes
 */
#include "dp.h"			/* Has enum GRdpmode */
#include "dpmacros.h"		/* Has dp$erase_hilite, etc. */
#include "igrdp.h"		/* Has struct IGRdisplay */
/*
 * Graphic object includes
 */
#include "go.h"			/* Has GRvg_construct */
/*
 * Input/output includes
 */
#include "exdef.h"		/* Has EX_masks */
#include "ex.h"			/* Has EX_button */
#ifndef BASE_EMS
#include "exmacros.h"		/* Has ex$putque */
#endif
#include "griodef.h"		/* Needed by grio.h */
#include "grio.h"		/* Has GRlc_info and GRevent structs */
#include "griomacros.h"		/* Has co$getevent macro */
/*
 * Dpb stuff
 */
#include "grdpbdef.h"		/* Needed by grdpb.h */
#include "grdpb.h"		/* Has structures for dpb */
#include "grdpbmacros.h"	/* Has macros to get active level, etc. */
/*
 * Message subsystem
 */
#include "msdef.h"		/* MSSUCC, MSFAIL and for ms.h */
#include "msmacros.h"		/* Has ex$message() */
/*
 * Error definitions
 */
#include "maerr.h"		/* MANOMEMORY, etc. */
/*
 * Locate include files
 */
#include "lcdef.h"		/* Locate bit definition masks */
#include "lc.h"			/* Has locate data structures */
#include "lcmacros.h"		/* Has the locate macro */

#include "EMSellpsd.h"         /*  Has ellipsoid structures */
#include "OMmacros.h"          /* OM block move */
/*
 * Define the maximum string size
 * for value type strings used by
 * co$getevent.
 */
#define MAX_VALUE_STRING 20
/*
 * Define the maximum number of events
 * required by the simple construction
 * commands
 */
#define MAX_STATIC_EVENTS 8
/*
 * Types of values needed by co$getevent
 */
#define NONE 0
#define DISTANCE 1
#define SCALAR 2
#define ANGLE 3
/*
 * Directory stuff and nucleus associativity
 */
#include "DIdef.h"
#include "DItypedef.h"
#include "parametric.h"
/*
 * Dimensioning types. Added for EMS 2.0
 */
#include "dimdef.h"
#include "dim.h"
#include "dimsrc.h"
#include "dimplan.h"
#include "diminfo.h"
/*
 * EMS Associativity types. Added for EMS 2.0
 */
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasdef.h"
#include "EMSas.h"
#include "REgenbs.h"

/* end 2.0 */

/*
 * Error check macros
 */
#define ERROR_ABORT if (! (1 & me->msg)) return(OM_E_ABORT);
#define ON_ERROR if (! (1 & sts))
#define CMD_KILL \
 { \
  ex$message(msgnumb = EMS_F_0002) \
  *response = TERMINATE; \
  return(OM_S_SUCCESS); \
 }
#ifndef rlw_include
#define rlw_include
/*
 * Locate communication structure
 */
 enum RLW_event_type
  {
   dummy,	/* Used to locate/accept and position is unimportant */
   good_data,	/* Used to locate/accept and position is important */
   chained	/* Used to locate/accept and will be used to locate another */
  };
 enum RLW_operation
  {
   entity_read_only,
   info_read_only,
   display_modification,
   geometry_modification
  };
 struct RLW_locate_info
  {
   enum			RLW_event_type identify_event_type;
   enum			RLW_event_type accept_event_type;
   enum			RLW_operation operation_type;
   IGRboolean		are_groups_allowed;
   IGRboolean		allow_duplicate_objects;
   unsigned		long planar_flag;
   IGRlong		acc_key;
   IGRlong		relocate_key;
   OM_S_CLASSLIST	rtree_classes;
   OM_S_CLASSLIST	eligible_classes;
   OMuword		r_classes[20];
   OMuword		e_classes[20];
  };
#endif
/*
 * eof
 */
