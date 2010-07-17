/*
/*
        File    VRreports.h
        Date    25-June-1990
        Auteur  AdZ (ISDC Paris)

	I/ROUTE
	"Generation I/ROUTE Report"

	Dependences:
		none	

        History:
	ADZ	25-06-91 Creation date.
	LAW	03-03-97 TR179603615 add ref-file connect.
*/
#ifndef VRreports_include

#define VRreports_include

/* 
 * object definitions
 */
#define _objid			obj_id.objid
#define _osnum			obj_id.osnum

#define BEGIN_TRACE		1
#define START_BRANCH		2
#define BEGIN_BRANCH		3
#define END_BRANCH		4
#define END_TRACE		5
#define LOOP_DETECTED		6
#define CONNECT_DETECTED	7

#define NUMBER_OF_ROWS		66
#define NUMBER_OF_CHARS 	132

/*
 * test constants
 */

#define VR_K_FileIsDirectory	0x01
#define VR_K_FileExist		0x02
#define VR_K_CantCreateFile	0x04

/* report type */
#define	VR_REPORT_LIST_MAX	20

#define VR_REP_NOT_DEF		10

#define VR_REP_STR		11

#define	VR_REP_CONST_1		21

#define VR_REP_FLO_4_1_INCH	31

#define VR_REP_FLO_3_0		41
#define VR_REP_FLO_6_1		42
#define VR_REP_FLO_8_1		43
/*
 * macro definitions
 */
#define TAB			11
#define	INCH_CHAR		'"'

#define F_SPACE(fp,lenght )	fprintf( fp, "%*c", (lenght), ' ' ) ;
#define F_STRING(fp,string )	fprintf( fp, "%s", (string) ) ;
#define F_REPEATCHAR(fp,item,nb) { char *buff = NULL ;\
				   buff = (char *) malloc( ((nb) +1) \
							   *sizeof(char) ) ;\
				   if( buff ) {\
					memset( buff, (item), (nb) ) ;\
					*(buff + (nb) ) = '\0' ;\
					F_STRING( fp, buff ) ;\
					free( buff ) ;\
				   } }

#endif

