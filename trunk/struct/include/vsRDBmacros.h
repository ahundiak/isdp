/*
	I/STRUCT
	Macros to extract structural information from the Relational Data Base.

	File dependency : vsRDBdef.h
*/

#ifndef vsRDBmacros_include
#	define vsRDBmacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"
#endif
#ifndef gr_include
#	include "gr.h"
#endif

/*+M
Macro vs$extract_materials_from_RDB

Abstract
	Extracts a list of materials from the database.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string (optional).
	OUT	int	*p_count	Count of materials.
	OUT	char	***p_materials	List of materials.
Note
	"*p_materials" is malloc'ed and must be freed with :
			VSfreeList( *p_count, *p_materials ) ;

-M*/
extern long
VSextractMaterialsFromRDB	__((	long		*msg,
					char		*errStr,
					int		*p_count,
					char		***p_materials )) ;

#omdef vs$extract_materials_from_RDB(	msg,
					errStr = NULL,
					p_count,
					p_materials )

	VSextractMaterialsFromRDB( (msg), (errStr), (p_count), (p_materials) )
#endomdef

/*+M
Macro vs$extract_grades_from_RDB

Abstract
	Extracts a list of grades from the database.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string (optional).
	IN	char	*material	Material wanted.
	OUT	int	*p_count	Count of grades.
	OUT	char	***p_grades	List of grades.
Note
	"*p_grades" is malloc'ed and must be freed with :
			VSfreeList( *p_count, *p_grades ) ;

-M*/
extern long
VSextractGradesFromRDB		__((	long		*msg,
					char		*errStr,
					char		*material,
					int		*p_count,
					char		***p_grade )) ;

#omdef	vs$extract_grades_from_RDB(	msg,
					errStr = NULL,
					material,
					p_count,
					p_grades )

	
	VSextractGradesFromRDB(	(msg),
				(errStr),
				(material),
				(p_count),
				(p_grades) )
#endomdef

/*+M
Macro vs$extract_shapes_from_RDB

Abstract
	Extracts a list of cross-section shapes from the database.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string (optional).
	IN	char	*material	Material wanted.
	OUT	int	*p_count	Count of shapes.
	OUT	char	***p_shapes	List of shapes.
Note
	"*p_shapes" is malloc'ed and must be freed with :
			VSfreeList( *p_count, *p_shapes ) ;

-M*/
extern long
VSextractShapesFromRDB		__((	long		*msg,
					char		*errStr,
					char		*material,
					int		*p_count,
					char		***p_shapes )) ;

#omdef	vs$extract_shapes_from_RDB(	msg,
					errStr = NULL,
					material,
					p_count,
					p_shapes )

	
	VSextractShapesFromRDB(	(msg),
				(errStr),
				(material),
				(p_count),
				(p_shapes) )
#endomdef

/*+M
Macro vs$extract_plates_from_RDB

Abstract
	Extracts the list of available plates from the database.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string (optional).
	IN	char	*material	Material wanted.
	OUT	int	*p_count	Count of plates.
	OUT	char	***p_plates	List of plates.
Note
	"*p_plates" is malloc'ed and must be freed with :
			VSfreeList( *p_count, *p_plates ) ;

-M*/
extern long
VSextractPlatesFromRDB		__((	long		*msg,
					char		*errStr,
					char		*material,
					int		*p_count,
					char		***p_plates )) ;

#omdef	vs$extract_plates_from_RDB(	msg,
					errStr = NULL,
					material,
					p_count,
					p_plates )

	
	VSextractPlatesFromRDB(	(msg),
				(errStr),
				(material),
				(p_count),
				(p_plates) )
#endomdef

/*+M
Macro vs$extract_parts_from_RDB

Abstract
	Extracts a list of structural parts from the database.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string (optional).
	IN	char	*material	Material wanted.
	IN	char	*family		Type of wanted parts.
	OUT	int	*p_count	Count of parts.
	OUT	char	***p_parts	List of parts.
Note
	"*p_parts" is malloc'ed and must be freed with :
			VSfreeList( *p_count, *p_parts ) ;

-M*/
extern long
VSextractPartsFromRDB		__((	long		*msg,
					char		*errStr,
					char		*family,
					char		*material,
					int		*p_count,
					char		***p_parts )) ;

#omdef	vs$extract_parts_from_RDB(	msg,
					errStr = NULL,
					family,
					material,
					p_count,
					p_parts )

	VSextractPartsFromRDB(	(msg),
				(errStr),
				(family),
				(material),
				(p_count),
				(p_parts) )
#endomdef

/*+M
Macro vs$extract_parms_from_RDB

Abstract
	Extracts the parameter names and values of a part.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string (optional).
	IN	char	*material	Material wanted.
	IN	char	*family		Type of wanted parts.
	IN	char	*part		Name of part.
	OUT	int	*p_count	Count of parts.
	OUT	char	***p_names	List of parameter values.
	OUT	double	**p_values	List of parameter values.
Note
	"*p_names" is malloc'ed and must be freed with :
			VSfreeList( *p_count, *p_names ) ;

	"*p_values" is malloc'ed and must be freed with :
			if( *p_values ) free( *p_values ) ;

-M*/
extern long
VSextractParmsFromRDB		__((	long		*msg,
					char		*errStr,
					char		*family,
					char		*material,
					char		*part,
					int		*p_count,
					char		***p_names,
					double		**p_values )) ;

#omdef	vs$extract_parms_from_RDB(	msg,
					errStr = NULL,
					material,
					family,
					part,
					p_count,
					p_names,
					p_values )

	VSextractParmsFromRDB(	(msg),
				(errStr),
				(family),
				(material),
				(part),
				(p_count),
				(p_names),
				(p_values) )
#endomdef

/*+M
Macro vs$load_part_from_RDB

Abstract
	Loads a part from the relational data base into a cache object. If the
	cache object already exists, returns its id.
Arguments
	OUT	long		*msg		Completion code.
	OUT	char		*errStr		Error string (optional).
	IN	char		*material	Material wanted.
	IN	char		*family		Type of wanted parts.
	IN	char		*part		Name of wanted part.
	IN	OMuword		osnum		Object space where cache must
						be looked for or created.
	OUT	struct GRid	*object		Id of cache object.
-M*/
extern long
VSloadPartFromRDB		__((	long		*msg,
					char		*errStr,
					char		*family,
					char		*material,
					char		*part,
					OMuword		osnum,
					struct GRid	*partGRid )) ;

#omdef	vs$load_part_from_RDB(	msg,
				errStr = NULL,
				material,
				family,
				part,
				osnum,
				object )

		VSloadPartFromRDB(	(msg),
					(errStr),
					(family),
					(material),
					(part),
					(osnum),
					(object) )
#endomdef

/*+M
Macro vs$find_thickness_in_RDB

Abstract
	Given a value, finds the closed thickness to that value in the RDB which
	is superior or equal to that value. If the value is greater that all
	the RDB values then the greatest RDB value is returned.
Arguments
	OUT	long	*msg		Completion code
	OUT	char	*errStr		Error string (optional).
	IN	char	*material	Material wanted
	IN	char	*family		Type of wanted parts
	IN	double	value		Value to look for
	OUT	char	**p_thkname	Name of closed thickness found
	OUT	double	*p_thickness	Value of closest thickness found
	OUT	int	*p_index	Index of closest thickness found ( may
					be NULL if not wanted )
Note
	"*p_thkname" is malloc'd and must be freed by the caller with :

		if( *p_thkname ) free( *p_thkname ) ;

-M*/
extern long
VSfindThicknessInRDB		__((	long		*msg,
					char		*errStr,
					char		*material,
					char		*family,
					double		value,
					char		**p_thkname,
					double		*p_thickness,
					int		*p_index )) ;

#omdef	vs$find_thickness_in_RDB(	msg,
					errStr = NULL,
					material,
					family,
					value,
					p_thkname,
					p_thickness,
					p_index = NULL )

		VSfindThicknessInRDB(	(msg),
					(errStr),
					(material),
					(family),
					(value),
					(p_thkname),
					(p_thickness),
					(p_index) )
#endomdef

/*+M
Macro vs$extract_density_from_RDB

Abstract
	Given a material and its grade, retrieves its density in the 
	Relational Data Base.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string (optional).
	IN	char	*material	Material wanted.
	IN	char	*grade		Grade of above material.
	OUT	double	*density	Density of material.
-M*/
extern long
VSextractDensityFromRDB		__((	long		*msg,
					char		*errStr,
					char		*material,
					char		*grade,
					double		*density )) ;

#omdef vs$extract_density_from_RDB(	msg,
					errStr = NULL,
					material,
					grade,
					density )

	VSextractDensityFromRDB(	(msg),
					(errStr),
					(material),
					(grade),
					(density) )
#endomdef

/*+M
Macro vs$get_member_classes_from_RDB

Abstract
	Returns a list of integer codes for the member classes as those
	defined in the Relational Data Base, as well as a list of messages
	numbers corresponding to an ASCII string in the message sub-system
	describing the class codes.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string (optional).
	OUT	int	clsList[VS_rdb_MAXCLASSES]	Class code list.
	OUT	long	keyList[VS_rdb_MAXCLASSES]	List of message numbers.
-M*/
extern long
VSgetMbrClassesFromRDB		__((	long		*msg,
					char		*errStr,
					int		clsList[],
					long		leyList[] )) ;

#omdef vs$get_member_classes_from_RDB( msg, errStr = NULL, clsList, keyList )
	VSgetMbrClassesFromRDB( (msg), (errStr), (clsList), (keyList) )
#endomdef

/*+M
Macro vs$get_mb_plate_types_from_RDB

Abstract
	Returns a list of integer codes for the member plate types as those
	defined in the Relational Data Base, as well as a list of messages
	numbers corresponding to an ASCII string in the message sub-system
	describing the type codes.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string (optional).
	OUT	int	typeList[VS_rdb_MAXPLTYPES]	Type code list.
	OUT	long	keyList [VS_rdb_MAXPLTYPES]	List of message numbers.
-M*/
extern long
VSgetMbrPlateTypesFromRDBB	__((	long		*msg,
					char		*errStr,
					int		typeList[],
					long		leyList[] )) ;

#omdef vs$get_mb_plate_types_from_RDB( msg, errStr = NULL, typeList, keyList )
	VSgetMbrPlateTypesFromRDB( (msg), (errStr), (typeList), (keyList) )
#endomdef


/*+M
Macro vs$get_mb_beam_types_from_RDB

Abstract
	Returns a list of integer codes for the member beam types as those
	defined in the Relational Data Base, as well as a list of messages
	numbers corresponding to an ASCII string in the message sub-system
	describing the type codes.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string (optional).
	OUT	int	typeList[VS_rdb_MAXBMTYPES]	Type code list.
	OUT	long	keyList [VS_rdb_MAXBMTYPES]	List of message numbers.
-M*/
extern long
VSgetMbrBeamTypesFromRDB	__((	long		*msg,
					char		*errStr,
					int		typeList[],
					long		leyList[] )) ;

#omdef vs$get_mb_beam_types_from_RDB( msg, errStr = NULL, typeList, keyList )
	VSgetMbrBeamTypesFromRDB( (msg), (errStr), (typeList), (keyList) )
#endomdef

/*+M
Macro vs$extractParameters

Abstract
	Extracts the parameter names and values of a part. Internal.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string (optional).
	IN	char	*family		Family of part.
	IN	char	*material	Material of part.
	IN	char	*part		Part name.
	IN	int	size		Of arrays of parameter names and values.
	OUT	int	*p_count	Of parameters.
	OUT	char	*pmNames[]	List of parameter names( optional).
	OUT	char	pmValues	List of parameter values
Note
	The `pmNames[i]' point to static memory and will be overwritten by the
	system.
	`*msg' is odd if success and even if error, it is also a message number
	which may be explicited via the Message Subsystem.
-M*/
extern long
VSextractParameters		__((	long		*msg,
					char		*errStr,
					char		*family,
					char		*material,
					char		*part,
					int		size,
					int		*p_count,
					char		*pmNames[],
					double		pmValues[] )) ;

#omdef vs$extractParameters(	msg,
				errStr	= NULL,
				family,
				material,
				part,
				size,
				p_count,
				pmNames	= NULL,
				pmValues )

	VSextractParameters(	(msg),
				(errStr),
				(family),
				(material),
				(part),
				(size),
				(p_count),
				(pmNames),
				(pmValues) )
#endomdef

/*+M
Macro vs$getPpartData

Abstract
	Retrieves the parameter names and values of a part and the macro
	library it may be constructed from.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string (optional).
	IN	char	*family		Part family.
	IN	char	*material	Material of part.
	IN	char	*part		Part name.
	IN	int	size		Of arrays of parameter names and values.
	OUT	int	*p_count	Of parameters.
	OUT	char	*pmNames[]	List of parameter names( optional).
	OUT	char	pmValues	List of parameter values
	OUT	char	*file		Name of object space of macro library
					- the co_filename in PDM parlance -,
					optional.
Note
	The `pmNames[i]' point to static memory and will be overwritten by the
	system.
	`*msg' is odd if success and even if error, it is also a message number
	which may be explicited via the Message Subsystem.
-M*/
extern long
VSgetPpartData			__((	long		*msg,
					char		*errStr,
					char		*family,
					char		*material,
					char		*part,
					char		*file,
					int		size,
					int		*p_count,
					char		*pmNames[],
					double		pmValues[] )) ;

#omdef vs$getPpartData(	msg,
			errStr	= NULL,
			family,
			material,
			part,
			size,
			p_count,
			pmNames	= NULL,
			pmValues,
			file	= NULL )

	VSgetPpartData(	(msg),
			(errStr),
			(family),
			(material),
			(part),
			(file),
			(size),
			(p_count),
			(pmNames),
			(pmValues) )

#endomdef

/*+M
Macro vs$getTemplateNames

Abstract
	Given a macro definition living in a macro library, returns the list
	of its template names.
Arguments
	OUT	long	*msg		Completion code.
	OUT	char	*errStr		Error string (optional).
	IN	char	*macLib		Name of the macro library.
	IN	char	*macDefName	Name of the macro definition.
	IN	int	size		Of arrays of template names.
	OUT	int	*p_count	Of template names.
	OUT	char	*templates[]	List of parameter names.
Note
	The `template[i]' point to static memory and will be overwritten by the
	system.
-M*/
extern long
VSgetTemplateNames		__((	long		*msg,
					char		*errStr,
					char		*macLib,
					char		*macDefName,
					int		size,
					int		*p_count,
					char		*templates[] )) ;

#omdef vs$getTemplateNames(	msg,
				errStr = NULL,
				macLib,
				macDefName,
				size,
				p_count,
				templates )

	VSgetTemplateNames(	(msg),
				(errStr),
				(macLib),
				(macDefName),
				(size),
				(p_count),
				(templates) )
#endomdef

/*+M
Macro vs$loadParametricPart

Abstract
	Fetches data of a parametric part in the Relational Data Base and
	places the part in the design file: it will be a macro occurrence
	placed invisible (non-locatable, non-displayable, out of the R-tree),
	which will be used as a cache.
Arguments
	OUT	long		*msg		Completion code.
	OUT	char		*errStr		Error string (optional).
	IN	char		*catalog	Catalog name of part (must be
						referenced in the "pdm_loc"
						catalog containing all the
						user catalogs.
	IN	char		*partNum	Part number (in fact an ASCII
						identifier) corresponding to
						the PDM attribute "part_num"
						in the catalog.
	IN	char		*revision	Revision of part (corresponds
						to the material type). The pair
						(part_num,revision) defines a
						unique row in the catalog.
	IN	char		*pathname	Full pathname of part to be
						placed (the intermediate
						directories will be created if
						they do not already exist).
	OUT	struct GRid	*partGRid	Id of placed part.
-M*/
extern long
VSloadParametricPart		__((	long		*msg,
					char		*errStr,
					char		*family,
					char		*part,
					char		*material,
					char		*dir_name,
					struct GRid	*partGRid )) ;

#omdef vs$loadParametricPart(	msg,
				errStr	= NULL,
				catalog,
				partNum,
				revision,
				pathname,
				partGRid )

	VSloadParametricPart(	(msg),
				(errStr),
				(catalog),
				(partNum),
				(revision),
				(pathname),
				(partGRid) )
#endomdef

#endif
