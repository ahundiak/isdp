/* $Id: SMCsPp.S,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smperp/imp / SMCsPp.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCsPp.S,v $
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

/* ------------------------------------------------------------------------
   SMCsPp.S
   Pascale Lacroix
   Jan 1993

   ABSTRACT:
	This class implement a set of perpendiculars (Aft, Fore, and Middle)
       
	Parents of the macro:

		- an ACrg_collection that contains:

		. is_analysis (if it is the perp for the analysis)
		. is_middle ( if the middle perp is needed)
		. is_drawing ( if used for the drawing)
		. AftName (name of the Aft Perp if need to be displayed)
		. MidName (name of the middle Perp if need to be displayed)
		. ForName (name of the Fore Perp if need to be displayed)
		. DrwName = name for the drawing macro 
					(default = SMDrwPrp)
		. axis = coord. axis on which are the perp (default x)

		- Coordinate system (act ship cs or act EMS cs)
		- AftDist = Expression distance from cs to the 
			aft perp (default 0)
		- ForeDist = Expression distance from to the aft 
			perp to the fore perp (LPP)
		

	Feet of the macro:

		- the Aft Perp
		- the Middle Perp (if needed otherwise NULL_OBJID)
		- the Fore Perp


---------------------------------------------------------------------------- */

class specification SMCsPp (0:1) of SMAttMgr, VDSroot;

override ACmplace_from_def;

override GRgetobjinfo; 

override SMWhoAreYou;

override SMFillSfFile;

override ACconstruct_feet; 
 

/*+mo
  Overriden Message
	VDgetObjDef from VDSroot

  Abstract
        Returns the definition of an object: name of templates and feet, etc.
  Arguments
        OUT     long            *msg            Completion code.
        IN      VDobjDef        *objDef         Object definition.
  Note
        The fields of `objDef' point to static buffers and therefore should
        not be freed.
-mo*/

override VDgetObjDef;

message SMcreate(IGRlong *msg; struct GRid *coord; struct GRid *aft_id;
		 struct GRid *fore_id; IGRint nb_att; 
		 struct ACrg_coll *ACrg; IGRchar *MacName);

/* ABSTRACT :
     Fill all the parameters of the macro and place it 

  ARGUMENTS :
		. msg 		(O): completion code
		. coord 	(I): Coordinate system 
		. aft_id 	(I): The expression of aftdist
		. fore_id 	(I): The expression of foredist
		. nb_att 	(I): number of attributes in the ACrg_coll
		. ACrg	 	(I): the attributes 
		. MacName 	(I): name of the macro 
					
*/

message SMModify(IGRlong *msg; struct GRid *coord; struct GRid *aft_id;
		 struct GRid *fore_id; 
		 IGRint nb_att; struct ACrg_coll *ACrg; IGRchar *MacName);


/* ABSTRACT :

     Modify the parameters of and existing macro  

  ARGUMENTS :
		. msg 		(O): completion code
		. coord 	(I): Coordinate system 
		. aft_id 	(I): The expression of aftdist
		. fore_id 	(I): The expression of foredist
		. AftDist 	(I): distance from cs to the aft perp 
		. ForeDist 	(I): distance from to the aft perp to the 
				     fore perp 
		. nb_att 	(I): number of attributes in the ACrg_coll
		. ACrg	 	(I): the attributes 
		. MacName 	(I): name of the macro 

*/

message SMGetParameters(
		 IGRlong *msg; struct GRid *coord; struct GRid *aft_id;
		 struct GRid *fore_id; 
 		 IGRint *nb_att; struct ACrg_coll *ACrg; IGRchar *MacName);

/* 
  ABSTRACT :

     Get all the parameters of and existing macro.
     A null pointer for a parameter means not return this parameter

  ARGUMENTS :
		. msg 		(O): completion code
		. coord 	(O): Coordinate system 
		. aft_id 	(O): The expression of aftdist
		. fore_id 	(O): The expression of foredist
		. nb_att 	(I): number of attributes in the ACrg_coll
		. ACrg	 	(I): the attributes 
		. MacName 	(I): name of the macro 


*/


end specification SMCsPp;


