/*
	I/STRUCT
*/
class specification VSqryRdbCmd(0:0) of Root ;

#include "vsqryrdbdef.h"

instance VSqryRdbCmd {

	/*
	 * Type of queries which will be done :
	 * VS_K_BEAM_QY	: queries for beams or stiffeners.
	 * VS_K_PLATE_QY: queries for plates.
	 * #defined in "vsqryrdbdef.h"
	 */
	int	queryType ;

	/*
	 * Mask indicating what has already been loaded from the RDB.
	 */
#define VS_m_mat_from_RDB	0x01
#define VS_m_grd_from_RDB	0x02
#define VS_m_fam_from_RDB	0x04
#define VS_m_prt_from_RDB	0x08
#define VS_m_par_from_RDB	0x10

	int	loadedMask ;

	/*
	 * Index of current MATterial, GRaDe, FAMily, PaRT.
	 */
	int	matIndex,
		grdIndex,
		famIndex,
		prtIndex,
		savMatIx,
		savGrdIx,
		savFamIx,
		savPrtIx,

	/*
	 * Count of materials, grades, families, parts, profile parameters 
	 * (beams) or thickness values (plates).
	 */
		matCount,
		grdCount,
		famCount,
		prtCount,
		parCount ;

	char	**matList,	/* List of materials			*/
		**grdList,	/* List of grades			*/
		**famList,	/* List of families			*/
		**prtList,	/* List of parts			*/
		**parList,	/* List of parameter names (beams)	*/
		**namValList,	/* List of parameter names and values :
				   namValList[i]="parList[i]=parVal[i]" */

		actMat[VS_K_MAXDBNAME],		/* Active material	*/
		actGrd[VS_K_MAXDBNAME],		/* Active grade		*/
		actFam[VS_K_MAXDBNAME],		/* Active family	*/
		actPrt[VS_K_MAXDBNAME],		/* Active part		*/
		savMat[VS_K_MAXDBNAME],		/* Saved material	*/
		savGrd[VS_K_MAXDBNAME],		/* Saved grade		*/
		savFam[VS_K_MAXDBNAME],		/* Saved family		*/
		savPrt[VS_K_MAXDBNAME] ;	/* Saved part		*/

	/*
	 * List of parameter values of active beam profile part or list of
	 * thicknesses for one plate family.
	 */
	double	*parVal,

	/*
	 * Value of thickness of active plate part.
	 */
		actPar,
		savPar ;

} ;

/*+d
Message setQueryType

Abstract
	Set the type of the queries which will be done :
		- VS_K_BEAM_QY	: queries for beams or stiffeners.
		- VS_K_PLATE_QY	: queries for plates.
		Both #defined in "vscmddef.h"
Arguments
	OUT	long	*msg		Completion code :
					MSFAIL : if invalid query type input.
	IN	int	qyType		Query type.
Note
	This message must be sent at init time.
-d*/
message setQueryType( long *msg ; int qyType ) ;

/*+d
Message initRDBdata

Abstract
	Initializes all instance data which will receive data fetched from
	the RDB.
Note
	This message must be sent at init time.
-d*/
message initRDBdata() ;

/*+d
Message freeRDBdata

Abstract
	Free the memory allocated in instance data to contain data fetched from
	the RDB.
Note
	This message must be sent at delete time.
-d*/
message freeRDBdata() ;

/*+d
Message verifyLogin

Abstract
	Checks that user has logged into Relational Data Base.
Argument
	OUT	long	*msg		Completion code :
					MSSUCC : user has logged in.
					MSFAIL : user has not logged in.
-d*/
message verifyLogin( long *msg ) ;


/*+d
Message setActiveItems

Abstract
	Sets the active material, grade, family, part, that is those proposed
	to the user. If one item does not exist in the RDB, then the first
	one found will be set as active by the
			`load[Materials|Grades|Families|Parts]'
	methods.
Arguments
	IN	char	*mat	Active material to set (may be NULL).
	IN	char	*grd	Active grade    to set (may be NULL).
	IN	char	*fam	Active family   to set (may be NULL).
	IN	char	*prt	Active part     to set (may be NULL).
Note
	If one argument is NULL the corresponding active item will be left
	unchanged.
-d*/
message setActiveItems( char *mat, *grd, *fam, *prt ) ;

/*+d
Message saveActiveItems

Abstract
	Saves the active items. Useful before a query to roll back the active
	items, should the query fail.
Arguments
	None.
-d*/
message saveActiveItems() ;

/*+d
Message restoreActiveItems

Abstract
	Restores the active items previously saved with message
			`saveActiveItems'
Arguments
	None.
-d*/
message restoreActiveItems() ;

/*+d
Message loadMaterials

Abstract
	Gets the list of materials from the RDB.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string in case of failure
					(length MS_MAX_MSG_LENGTH).
-d*/
message loadMaterials( long *msg ; char *errStr ) ;

/*+d
Message loadGrades

Abstract
	Gets the list of material grades from the RDB.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string in case of failure
					(length MS_MAX_MSG_LENGTH).
Note
	 Materials must have been loaded prior to sending this message.
-d*/
message loadGrades( long *msg ; char *errStr ) ;

/*+d
Message loadFamilies

Abstract
	Gets the list of part families from the RDB.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string in case of failure
					(length MS_MAX_MSG_LENGTH).
Note
	 Materials must have been loaded prior to sending this message.
-d*/
message loadFamilies( long *msg ; char *errStr ) ;

/*+d
Message loadParts

Abstract
	Gets the list of parts from the RDB.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string in case of failure
					(length MS_MAX_MSG_LENGTH).
Note
	 Materials and families must have been loaded prior to sending this
	 message.
-d*/
message loadParts( long *msg ; char *errStr ) ;


/*+d
Message loadParms

Abstract
	For query about beams, loads the parameters of the active part
	(profile).
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string in case of failure
					(length MS_MAX_MSG_LENGTH).
Note
	 Materials, families and parts must have been loaded prior to sending
	 this message.
-d*/
message loadParms( long *msg ; char *errStr ) ;

/*+d
Message loadThkVals

Abstract
	For query about plates, loads the values of te thicknesses of the of
	all the parts (plates) in the active family.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string in case of failure
					(length MS_MAX_MSG_LENGTH).
Note
	 Materials, families and parts must have been loaded prior to sending
	 this message.
-d*/
message loadThkVals( long *msg ; char *errStr ) ;

/*+d
Message loadAny

Abstract
	The main interface to the Relational Data Base. Rolls back former values
	should any query fail. Will not load an already loaded item except if
	the force-load bit is set in `action'
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string in case of failure
					(length MS_MAX_MSG_LENGTH).
	IN	int	action		Action to perform.
	OUT	int	*executed	Action really executed.
Note
	`action' may be an ORing of the following:
	VS_m_mat	: load materials
	VS_m_grd	: load grades
	VS_m_fam	: load families
	VS_m_prt	: load parts
	VS_m_par	: load profile parameters (beam) or thicknesses (plates)
	VS_m_tot	: load all of the above (total)
	VS_m_force	: reload item even if already loaded.

	#defined in "vsqryrdbdef".
-d*/
message loadAny(	long	*msg ;
			char 	*errStr ;
			int	action,
				*executed ) ;

end specification VSqryRdbCmd ;
