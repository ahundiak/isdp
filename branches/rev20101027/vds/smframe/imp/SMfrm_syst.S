/* $Id: SMfrm_syst.S,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smframe/imp / SMfrm_syst.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMfrm_syst.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*---------------------------------------------------------------------------
/*
/*  ABSTRACT
/*  This class defined a frame system object
/*---------------------------------------------------------------------------*/
class specification SMfrm_syst (0:1) of ACdiowner, SMmgr ;

#include "ACattrib.h"
#include "vds.h"

struct ACattr
  { int  name; /* its name */
    int  index; /* its index on the owner channel */
  };

override translate;

override ACcreate;
/* 
  ABSTRACT
 Initialize the frame system and add it in the directory tree.

   ARGUMENTS
msg    O : completion code MSSUC or MSFAIL
name   I : name of the frame_system.
*/

override unknown;

override GRgetobjinfo;

override SMGetAttType;

override SMGetAtt;

override SMWhoAreYou;

override ACadd_component_with_name;

override GRget_locate_properties;

override GRcopy;  /* Do nothing */

override GRchgname; /* Verify I am not in my directory */

override dump;    /* ACdiowner don't treat reg_expr */


override SMFillSfFile;	/* Seasafe output print				*/

override SMFillRpFile;	/* Reports output print				*/


/*+me
  Public Message
	DIgive_output

  Abstract
	This message is sent with a "make_message" to the expression

  Arguments
        IN	char		*out_s		The name of the expression
        OUT	char		*out_s		the name of the expression
						concatenated with its syntax

-me*/
message DIgive_output(	char		*out_s );

/*+me
  Public Message
	SMgetObjDef

  Abstract
        Returns the definition of an object: name of templates and feet, etc.
  Arguments
        OUT     long            *msg            Completion code.
        IN      VDobjDef        *objDef         Object definition.
  Note
        The fields of `objDef' point to static buffers and therefore should
        not be freed.
-me*/

message SMgetObjDef(    long            *msg ;
                        VDobjDef        *objDef );

message SMchange_component_name(IGRlong *msg; struct GRid *go_obj;
			     	IGRchar *new_name);
/* 
 ABSTRACT
  Change the name of a component 

   ARGUMENTS
msg       O : completion code MSSUC or MSFAIL
go_obj    I : The objid of the component 
new_name  I : New name of for the component 
*/

message SMremove_component(IGRlong *msg; struct GRid *go_obj);
/*
ABSTRACT
  Disconnect the SMfrm_syst and the go_obj 

   ARGUMENTS
msg       O : completion code MSSUC or MSFAIL
go_obj    I : The objid of the component 
*/


message  SMfind_all_frame(IGRlong *msg;struct GRid **frame;IGRint **fr_number;
			  IGRint *nb_elem;IGRint *lowest;IGRint *highest);
/*
 ABSTRACT	
   Return all the frame objid and frame number in increasing order
   of frame number.
   The frame array and fr_number array are allocated by function
   and must be deallocated by user. 
   Given a null pointer in one of output argument means to ignore output	
 ARGUMENTS
msg       O : completion code MSSUC or MSFAIL 
frame     O : array of frame objid  (or NULL)             
fr_number O : array of frame number (or NULL) (correspond to the objid)  
nb_elem   O : number of frame found 
lowest    O : Number of lowest frame found
highest   O : number of highest frame found
*/


message SMfind_frame_objid(IGRlong *msg;IGRint fr_number;struct GRid *frame);
/*
 ABSTRACT	
  Given the frame number of a frame , return the frame objid 
 ARGUMENTS
msg       O : completion code MSSUC or MSFAIL
fr_number I : frame number to retrieve
frame     O : The objid of the frame 
*/


message SMfind_inter_frame(IGRlong *msg;IGRint *lowest;IGRint *highest;
	                   struct GRid *frame;IGRint *nb_elem);
/*
 ABSTRACT	
  Given two frame numbers, give all the objid of the frame between
  *lowest and *highest 
   The frame array must be allocated to received all frames
  (size = *highest - *lowest + 1)
  The frame in the array are sorted from the lowest number found to the
  highest (i.e. frame[0] = GRid of the *lowest found )
  
 ARGUMENTS
 msg      O : completion code MSSUC or MSFAIL
 lowest  I/O : (I)Number of the lowest frame required
               (O)Number of the lowest frame found which is greater than lowest required 
 highest I/O : (I)number of the highest frame required
                (O)Number of the highest frame frame which is lowest than highest required 
 frame    O : the array (allocated by user) of the intermediate frame
              in increasing order
 nb_elm  O : Number of the elements returned
*/             

message SMfind_frame_near_pt(IGRlong *msg; IGRdouble *point;
	                     IGRint *lowest_fr_num; IGRint *highest_fr_num;
                             IGRdouble *low_delta; IGRdouble *high_delta;
			     IGRshort *matrix_type;IGRmatrix matrix);
/*
   ABSTRACT Given a point in WORLD COORDINATE SYSTEM, calculate coordinate
            of this point relative to frame system cs. Then look at frames
            which are nearest relatively to the frame system axis of this point.
	    If the point is outside the "range" of frame system, low_near_num
            and high_near_num are equal (to lowest frame or highest frame)

  msg             O : completion code MSSUC or MSFAIL
  point           I : Point to look for
  low_near_num    O : Number of nearest frame before point
  high_near_num   O : Number of nearest frame after  point
  low_delta       O : Distance on axis from lowest frame 
  high_delta      O : Distance on axis from highest frame 
  matrix_type     I : matrix type
  matrix          [I]  environment matrix 
*/
            
 
message SMfind_near_frame(IGRlong *msg;IGRdouble dist_in;
		          IGRint *fr_num;IGRdouble *delta);
/*
   ABSTRACT
   Given a distance (on the main axis), convert it to frame_number + delta
   Ex : 23.45 ==> fr_num = 11; delta = 2.45  
   It fail if no positive delta can be found 

 ARGUMENTS
 msg      O : completion code MSSUC or MSFAIL
 dist_in  I : Distance to convert 
 fr_num   O : Number of nearest frame 
 delta    O : Distance of this frame
*/

message SMcvt_frm_to_wld(IGRlong *msg;IGRdouble pos;IGRpoint pt;
	IGRshort *matrix_type; IGRmatrix matrix); 
/* ABSTRACT: 
   Given a position on axis of the frame system ,
   return the corresponding point in the coordinate world system 
   ARGUMENTS:
     msg       [O]  Completion code   MSSUCC or MSFAIL
     pos       [I]  The position on the axis 
     pt        [O]  The coordinate of the corresponding point 
     *mat_type [I]  matrix type
     matrix    [I]  environment matrix 	
*/   

message SMdisplay_all_frame(IGRlong *msg;enum GRdpmode mode;
                            struct GRmd_env *md_env);
/*
   ABSTRACT
   Display all the frame of the frame system 

   ARGUMENTS
   msg      O : completion code MSSUC or MSFAIL
   mode     I : mode to display the frame system
   md_env   I : module env of frame system 
*/

end specification SMfrm_syst;

