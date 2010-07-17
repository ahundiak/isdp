/*********************************************************************
/*  ABSTRACT
/*  --------
/*
/*  This abstract class is the parent class of all the associative 
/*  plane objects
/*  This class is a dummy class of graphic planes.
/*
/*   HISTORY
/*   -------
/*
/*    DP      11-13-89 : Design date
/*    Lori    11-21-94 : Add method VRVerPlaneTopology
/*    law     05-01-02 : NDchildren_deleted added for tr5415
/*********************************************************************/

class specification VRplane (0:1) of ASnode;

#define VR_FIXED_PLANE 1

instance VRplane
  {
  IGRdouble  origin[3];	            /* Origin point of the plane              */
  IGRdouble  normal[3];	            /* Normal vector to the plane             */
  IGRdouble  loc_origin[3];	    /* Local origin of the plane (JLA's MAGIC)*/
  IGRdouble  loc_normal[3];	    /* local vector of the plane (JLA's MAGIC)*/
  int plane_state;		    /* Is the plane fixed		      */
};

override GRvg;

message VRpostabsg
  (
  long              *p_msg;         /* OUT    Completion code                 */
  struct GRmd_env   *p_md_env;      /* IN     Current module environment      */
  struct ret_struct *p_str          /* IN     Geometry to update              */
  );
 /*
DESCRIPTION: Update the internal instances of the object (because this object
             has not a graphic object).
*/


override
  GRlocate_owner,
  GRdisyourself,
  GRdetplane,
  GRxform,
  GRgetobjinfo,
  GRgetsymb,
  GRkeypoint,
  GRcopy,
  NDplace,
  NDgive_structure,
  NDcompute_node,
  NDattach_to_cs,
  NDdetach_from_cs,
  NDdisplay,
  NDmake_source,
  NDcopy_to_root,
  NDchildren_deleted,
  NDget_objects;

/* Temporary kludges to remove as soon as the code will be redesigned */

override
  ASconstruct_go,
  ASreturn_go,
  ACreturn_foot,
  GRgenabsg,
  GRgetsize,
  GRgetgeom,
  GRpostabsg;

message VRget_plane_state(int *state);

message VRchg_plane_state(int mask, state);

/****************************************************************************
/*           
/* Abstract:  Verify the topology of a plane, write results to reports 
/*
/*	  *msg          O  : return message 
/*  	  *FileData    I/O : file info for reports
/* 	  bVerbose      I  : flag, TRUE if verbose report is to be generated
/* 	  *ErrorCnt    I/O : count of errors found 
/*
/****************************************************************************/

message VRVerPlaneTopology( IGRlong *msg; struct VRvfy_file *FileData;
			  IGRboolean bVerbose; IGRint *ErrorCnt);



end specification VRplane;




