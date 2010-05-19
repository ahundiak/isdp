/* $Id: VDdrwSet.S,v 1.1.1.1 2001/01/04 21:09:30 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/set / VDdrwSet.S
 *
 * Description:
 *	This class has been created to support associative sets.
 *	Introduced for supporting unlimited associative parents for
 *	a table row object.
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95         R.Manem         Creation Date
 *      06/22/95         R.Manem         Added VDemptySet message
 * -------------------------------------------------------------------------
 */


class specification VDdrwSet (1:0) of VDSnode;

/*+v
*/
	
instance VDdrwSet
{
	variable IGRchar	setName[0];	/* For future use */
};

/*
-v*/

reject GRgetobjinfo;

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
	NDplace from NDnode

  Abstract
	Do nothing.  No graphical components

  Arguments
	struct GRas	*assoc_list	I	associative information
	struct GRmd_env	*md_env		I	module env
	char		*go_cnst_lis	I	full construction for the
						corresponding graphic object

 ---------------------------------------------------------------------------
-mo*/

override	NDplace;

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        NDcompute_node from NDnode

  Abstract
        Do nothing.  No graphical components

  Arguments
	IGRlong		*msg		O	return code
	IGRint		cn_type		I	reserved
	IGRint		count		I	number of roots
	struct GRid	*list		I	list of roots
        struct GRmd_env *md_env         I       module env

 ---------------------------------------------------------------------------
-mo*/

override        NDcompute_node;


/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        NDmove_to_root from NDnode

  Abstract
	When any of the parents is deleted, this message is received.
	Get the new list of parents. If one or more, put myself in the
	wait_batch, so that the dependent row object will recompute.  Else
	send VDparentSetEmpty message to the row object.

  Arguments
	IGRlong		*msg		O	return code
	struct GRid	*src_grid	O	GRid of the created object
        struct GRmd_env *md_env         I       module env
 ---------------------------------------------------------------------------
-mo*/

override        NDmove_to_root;

/*+me
 -------------------------------------------------------------------------
  Public Message VDinitSet

  Abstract
        This method does initialization : make myself non-locatable

  Arguments
        IGRlong         *msg            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 -------------------------------------------------------------------------
-me*/

message VDinitSet(   IGRlong         *msg );


/*+me
 ---------------------------------------------------------------------------
  Public Message VDgetSetObjects

  Abstract
        This method returns the set objects.

  Arguments
        IGRlong         	*msg      O     Return code
        IGRint          	*nbObjs   O     Number of objects 
	struct GRobj_env	*list	  O	List of obj envs.

  Notes/Remarks
	NULL could be used to suppress output
	Memory for list must be allocated by caller.
	The GRids returned will be of the actual object, not the source object

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDgetSetObjects(IGRlong			*msg;
			IGRint			*nbObjs;
			struct GRobj_env	*list );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDaddObjectsToSet

  Abstract
        This method adds objects, ie, connects the new objects as parents.
	Checks for duplication before adding

  Arguments
        IGRlong         *msg      O     Return code
        IGRint          nbObjs    I     Number of objects to add to set
        struct GRid     *list     I     List of objects to add

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDaddObjectsToSet(	IGRlong		*msg;
				IGRint		nbObjs;
				struct GRid	*list );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDdeleteObjectsFromSet

  Abstract
        This method deletes objects, ie, disconnects them 

  Arguments
        IGRlong         *msg      O     Return code
        IGRint          nbObjs    I     Number of objects to delete from set
        struct GRid     *list     I     List of objects to delete

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDdeleteObjectsFromSet( IGRlong         *msg;
                                IGRint          nbObjs;
                                struct GRid     *list );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDdeleteSet

  Abstract
	This message deletes the set

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDdeleteSet( IGRlong    *msg );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDemptySet

  Abstract
	This message empties the set (without deleting itself)

  Arguments
        IGRlong         *msg      O     Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDemptySet( IGRlong    *msg );

end specification VDdrwSet;

