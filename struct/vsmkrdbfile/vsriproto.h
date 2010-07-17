/*
	I/STRUCT

	File dependency :	sys/types.h
				FI.h
				vsri.h
*/
#ifndef vsriproto_include
#	define vsriproto_include

extern char
*exefile		(	void ),
*vslogname		(	void ),
*strdup			(	const char	*string ) ;

extern uid_t
getuid			(	void ) ;

extern gid_t
getgid			(	void ) ;

extern int
/* cftime			(	char		*buf,
				const char	*fmt,
				const time_t	*clock ),  */

access			(	const char	*path,
				int		access_mode ) ;

extern char	*sys_errlist[] ;

extern void
stripString		(	char		*string ),
rmDupSpaces		(	char		*string ),
getStrippedFldText	(	const Form	form,
				int		field,
				int		size,
				char		*text ),
getFam			(	void ),
getMat			(	void ),
setTime			(	const Form	form,
				int		field ),
setDate			(	const Form	form,
				int		field ),
setMatList		(	const Form	form,
				int		field ),
msg			(	const char	*text ),
prompt			(	const char	*text ),
fatal			(	const char	*text ),
badFileFormat		(	const char	*file,
				int		line,
				const char	*expected,
				const char	*got ) ;

extern int
findLanguage		(	const char	*EXNUCdir,
				char		*language ),
getChoice		(	int		*choice ),
getTimeFormat		(	void ),
ASCII_fld_format_routine(	const char	*data_in,
				char		**data_out ),
checkDir		(	const char	*directory ),
writeFamDef		(	void ),
writePartDef		(	void ),
writeMatDef		(	void ),
checkFamData		(	void ),
checkMatData		(	void ),
getParNumf		(	void ),
partIsUnique		(	const char	*family,
				const char	*partname ),
getAllMaterials		(	char		materials[MAX_MATERIALS][MAX_MAT_LEN+1],
				int		*count ),
gradeIsUnique		(	const char	*grade ),
doesMatExist		(	const char	*material ) ;

extern enum READRC
readFamDef		(	void ) ;

#endif
