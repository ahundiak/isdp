/*
** Functions and messages used by the CI super_object to manage lists of loaded
** CI objects.
**
** NOTES
**   File names are stored in the DataBase with their absolute paths, without
** suffix.
**  The presence of the super ci object is tested before each request. It is
** constructed if necessary.
**
** Dominique GARDELLA. ISDC, Paris.
*/
class implementation super_ci;

/*
HYPOTHESES:
 1/ Le modele est tjs le 1er elt satisfaisant de la liste (pb d'init).

A FAIRE:
 1/ Implementer qcq chose de plus dynamique que des tableaux a dimension fixe
    (malloc + realloc).
 3/ Ajouter un argument de sortie a SCIload indiquant si le fichier a ete loade
    ou clone (1/ & 4/ peuvent etre realises par le meme parametre).
 4/ Rationnaliser f_execute() & exec_fun().
 5/ Editer des stats sur le H-code ...
*/

#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "OMminimum.h"
#include "OMobjectcomm.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "ciexecmacros.h"
#include "citypedef.h"
#include "cierrordef.h"
#include "cierrmacros.h"
#include "cidef.h"
#include "cisetup.h"
#include "ciprivmacros.h"


#ifdef DEBUG
#	define SCI_DEBUG(txt)	fprintf(stderr, "FILE %s, LINE %d:\t%s\n", \
					__FILE__, __LINE__, txt); \
				fflush( stderr ) ;
#else
#	define SCI_DEBUG(txt)	;
#endif

#ifdef DEBUG
#	define CI_SYS_ERR(fun,arg)	fprintf(stderr,			\
		"FILE %s, LINE %d:\t%s() failed on %s, %s\n", __FILE__,	\
		__LINE__, fun, arg, sys_errlist[errno]);
#else
#	define CI_SYS_ERR(fun,arg)	;
#endif
#define SCI_FREE(ptr)							\
	if ( ptr != NULL )						\
	{								\
		free(ptr);						\
		ptr = NULL;						\
	}								\
	else								\
		SCI_DEBUG("free() tentative with a NULL pointer")

#ifdef DEBUG
#	define SCI_OM_ERROR(stat,txt)					\
	if ( (stat & 1) != 1 )						\
	{								\
		fprintf(stderr, "FILE %s, LINE %d:\t%s\n",		\
			__FILE__, __LINE__, txt);			\
		om$report_error(sts = stat);				\
	}
#else
#	define SCI_OM_ERROR(stat,txt)
#endif

#define NUM_HASH	100		/* # of elements in SCIhash_table[] */
#define SCI_MX_FILE	100		/* Max number of executing files */
#define SCI_MX_OBJ	200		/* Max number of running CI objects */
					/* (limit is 65535) */
#define END_OF_LIST	65535		/* list index are unsigned short */

typedef struct {
	char	       *name;		/* absolute name without suffix */
	unsigned short	p_object,	/* pointer to the list of CI objects */
			next;		/* Forward pointer */
} SCI_S_FILE;

typedef struct {
	GRobjid		objid;		/* self explanatory */
	unsigned short	next;		/* Forward pointer */
	time_t		mtime;		/* Last modification time of the '.e' file */
} SCI_S_OBJECT;


SCI_S_FILE	SCIfiles[SCI_MX_FILE];	/* Array of CI files */
SCI_S_OBJECT	SCIobjects[SCI_MX_OBJ];	/* Array of running CI object */
unsigned short	SCIfree_file;		/* index of the first unused element
						in SCIfiles */
unsigned short	SCIfree_object;		/* index of the first unused element
						in SCIobjects */
unsigned short	SCIhash_table[NUM_HASH]; /* array of index to SCIfiles[] */
extern char	*sys_errlist[];
char		*malloc();
void		SCIinit();

%safe
static char	SCI_wk_activ = 1;	/* wake_up: 1=activ, 0=desactivated */
static int	SCI_ex_flag  = EX_REAL_SLEEP ;
static int	SCI_init = FALSE ;
%endsafe
/* -- Class id of "ci" and "COci" ( Initialized in this file ).
   -- */
GRclassid CI_ci_classid, CI_COci_classid ;

from ci import terminate;
ci$opp$import ;

/*-METHODS--------------------------------------------------------------------*/

method super_construct()
{
SCI_DEBUG( "super_ci.super_construct: ENTER" )
#ifdef DEBUG
  printf( "super_ci.super_construct: SCI_wk_activ = %d\n", SCI_wk_activ ) ;
  fflush( stdout ) ;
#endif
    SCI_wk_activ = 1;
    SCIinit();
SCI_DEBUG( "super_ci.super_construct: EXIT" )
    return OM_S_SUCCESS;
}

method wake_up()
/*
 *   Initialization of some globals.
 */
{
    CIpushlist	warning_arg	;
    int		warn_val	;

SCI_DEBUG( "super_ci.wake_up ENTER" )
#ifdef DEBUG
  printf( "super_ci.wake_up: SCI_wk_activ = %d, SCI_ex_flag = %d\n",
  		SCI_wk_activ, SCI_ex_flag ) ;
  fflush( stdout ) ;
#endif
    om$get_classid(	classname = "ci",
    			p_classid = &CI_ci_classid ) ;
    om$get_classid(	classname = "COci",
    			p_classid = &CI_COci_classid ) ;

    if ( SCI_wk_activ )
	SCIinit();
    SCI_wk_activ = 1;

/* -- After design was closed: a new one is going to be opened, and has a
	super_ci: warn loaded PPL files of opening.
   -- */
    if( !ex$is_temp_wakeup() /* SCI_ex_flag == EX_REAL_SLEEP */ ) {
    	warn_val = CI_W_OPENING_DGN		;
  	warning_arg.addr = &warn_val		;
  	warning_arg.size = sizeof warn_val	;
 	SCIbroadcast( "warning", 1, &warning_arg ) ;
    }
/* -- Initialize CI options upon the first invocation.
   -- */
    if( *CIcci_path == '\0' ) CIiniopt() ;
#ifdef DEBUG
  printf( "super_ci.wake_up: EXIT\n" ) ; fflush( stdout ) ;
#endif

    return OM_S_SUCCESS;
}


method global_class.sleep(int pos)
/*
 *   If pos == 1: The design file is going to be saved and closed.
 * The super object deallocates the memory. If ever the loaded CI objects are
 * to receive the "sleep" message, it can be sent from here.
 *   If pos == 0: The design file is going to be saved only, and the super
 * object will soon receive a "wake_up" message which is  "desactivated"
 * from here.
 */
{
    CIpushlist	warning_arg	;
    int		warn_val	;
    int		OMsts		;

SCI_DEBUG( "super_ci.sleep ENTER" )

/*
/*    if ( ! pos )
/*    {
/*        for (i=0; i<SCI_MX_FILE; i++)
/*    	    if ( SCIfiles[i].name != NULL )
/*    	        free( SCIfiles[i].name );
/*	SCI_wk_activ = 1;
/*    }
/*    else
/*	SCI_wk_activ = 0;
/* */
  SCI_wk_activ = 0  ;
  SCI_ex_flag = pos ;

#ifdef DEBUG
  printf( "super_cii.sleep: pos = %d\n", pos ) ;
  fflush( stdout ) ;
#endif
  switch( pos ) {
	case EX_TEMP_SLEEP : warn_val = CI_W_WRITING_DGN ; break ;
	case EX_REAL_SLEEP : warn_val = CI_W_CLOSING_DGN ; break ;
	default		   :
		fprintf( stderr, "super_ci.sleep: Unknown code %d\n", pos ) ;
		fflush( stdout ) ;
		return OM_S_SUCCESS ;
  }
  warning_arg.addr = &warn_val		;
  warning_arg.size = sizeof warn_val	;

#ifdef DEBUG
  printf( "super_cii.sleep: warn_val = %d, %d\n", warn_val,
	*(int *) warning_arg.addr ) ;
  fflush( stdout ) ;
#endif
  SCIbroadcast( "warning", 1, &warning_arg ) ;

  if( pos == EX_REAL_SLEEP ) {
/* --	Delete self so as not to be stored in the design file. Should a new
	design file be brought up, the command object "COcidgnop" will create
	a new super_ci for that design.
   -- */
#ifdef DEBUG
  printf( "super_cii.sleep: EX_REAL_SLEEP\n" ) ; fflush( stdout ) ;
#endif
/* -- USELESS
	OMsts = ex$remove_name_from_NOD(	NODname	= "IGENOD",
						objname	= "super_ci",
						mod_osnum = OM_Gw_current_OS ) ;

	if( OMsts != OM_S_SUCCESS ) {
		ci$om_failed(	sts	= OMsts,
				text	= "super_ci.sleep -> ex$remove_name_from_NOD" ) ;
	}
   -- */
	OMsts = om$send(	msg	= message Root.delete( 0 ),
				targetid= my_id	) ;
	if( OMsts != OM_S_SUCCESS ) {
		ci$om_failed(	sts	= OMsts,
				text	= "super_ci.sleep -> Root.delete" ) ;
	}
  }
    return OM_S_SUCCESS;
}

/*-PRIVATE FUNCTIONS----------------------------------------------------------*/

void SCIinit()
/*
 *   Initialization of some globals.
 */
{
    unsigned short i;			/* loop index */

#ifdef DEBUG
  printf( "SCIinit: ENTER\n" ) ; fflush( stdout ) ;
#endif
    if( !SCI_init ) {
    	for (i=0; i<NUM_HASH; i++)
    		SCIhash_table[i] = END_OF_LIST;

    	for (i=0; i<SCI_MX_FILE; i++)
    		SCIfiles[i].name = NULL;

    	SCIfree_file = SCIfree_object = 0;

    	for (i=1; i<SCI_MX_FILE; i++)
		SCIfiles[i-1].next = i;
    	SCIfiles[SCI_MX_FILE - 1].next = END_OF_LIST;

    	for (i=1; i<SCI_MX_OBJ; i++)
		SCIobjects[i-1].next = i;
    	SCIobjects[SCI_MX_OBJ - 1].next = END_OF_LIST;

	SCI_init = TRUE ;
   }
#ifdef DEBUG
  printf( "SCIinit: EXIT\n" ) ; fflush( stdout ) ;
#endif
}


void	SCIdelete_object(objid)
/*
 *   Physically deletes the CI object.
 */
GRobjid		objid;		/* IN: CI object to be deleted */
{
    int	rc, CIsts ;			/* return code */

#ifdef DEBUG
  printf( "SCIdelete_object: ENTER objid = %d\n", objid ) ; fflush( stdout ) ;
#endif
    /* Terminate the CI object */
    rc = om$send(	mode = OM_e_wrt_object,
			msg = message ci.terminate( &CIsts ),
			targetid = objid,
		        targetos = OM_Gw_TransOSnum_0,
			senderid = NULL_OBJID );
    SCI_OM_ERROR(rc, "SCIdelete_object -> ci.terminate");

    /* Delete the CI object */
    if ( objid != NULL_OBJID )
    {
        rc = om$send(	mode	 = OM_e_wrt_message,
			msg	 = message Root.delete(0),
			targetid = objid,
			targetos = OM_Gw_TransOSnum_0,
			senderid = NULL_OBJID );
        SCI_OM_ERROR(rc, "SCIdelete_object -> Root.delete")
    }
#ifdef DEBUG
  printf( "SCIdelete_object: EXIT\n" ) ; fflush( stdout ) ;
#endif
}


void	SCIconstruct()
/*
 * Constructs the CI super object if it doesn't exit yet.
 * NOTE:
 *	Can be improved with a static variable if exec time appears to be
 * critical. AF: Certainly not ! The module MAY change !
 */
{
OM_S_OBJID	super_id;
struct GRid	mod;
long		msg ;

SCI_DEBUG( "SCIconstruct: ENTER" )


	ex$get_cur_mod(	id	= &mod.objid,
			osnum	= &mod.osnum ) ;
	msg = ex$get_super(mod_id	= mod.objid,
	     		mod_osnum	= mod.osnum,
	     		super_name	= "super_ci",
	     		create		= TRUE,
	     		super_class	= "super_ci",
	     		super_id	= &super_id);
	if( msg != OM_S_SUCCESS ) {
		printf( "SCIconstruct: ex$get_super error :\n" ) ;
		om$report_error( sts = msg ) ;
		fflush( stdout ) ;
	}
#ifdef DEBUG
  printf( "SCIconstruct: super_ci = (%d,%d)\n", mod.osnum, super_id  ) ;
  printf( "SCIconstruct: module   = (%d,%d)\n", mod.osnum, mod.objid ) ;
#endif
SCI_DEBUG( "SCIconstruct: EXIT" )
}


unsigned short	SCIhash(file_name)
/*
 *   Returns a hash index in a table with NUM_HASH elements.
 */
char	*file_name;
{
    unsigned short	entry = 0;	/* h-code */

    while (1)
    {
	if ( ! *file_name )
	    return (entry % NUM_HASH);
	entry += *file_name++;
    }
}

unsigned short	SCIsearch_file(file_name)
/*   Search for the file in SCIfiles[] using a H-table.
 * RC
 *   'file_entry' if the file is found in the DataBase, END_OF_LIST otherwise
 */
char	*file_name;  /* IN: absolute name of the file, without suffix */
{
    unsigned short	file_entry;		/* file index in SCIfiles[] */

#ifdef DEBUG
  printf( "SCIsearch_file: ENTER(%s)\n", file_name ) ; fflush( stdout ) ;
#endif
    file_entry = SCIhash_table[ SCIhash(file_name) ];
    while ( file_entry != END_OF_LIST )
    {
#ifdef DEBUG
  printf( "SCIsearch_file: (%s)=?(%s)\n", file_name, SCIfiles[file_entry].name ) ; fflush( stdout ) ;
#endif
        if ( !strcmp(SCIfiles[file_entry].name, file_name) )
            return file_entry;
        file_entry = SCIfiles[file_entry].next;
#ifdef DEBUG
  printf( "SCIsearch_file: next = %d[%u]\n", file_entry, file_entry ) ; fflush( stdout ) ;
#endif
    }

#ifdef DEBUG
  printf( "SCIsearch_file: EXIT(%s)\n", file_name ) ; fflush( stdout ) ;
#endif
/* nothing found */
    return END_OF_LIST;
}


unsigned short	SCIstore_file(file_name, object)
/*
 *   Store in the DataBase, the file and its attached object.
 * RC:	CI_S_SUCCESS		OK
 *	CI_E_FATAL_ERROR	DataBase overflow
 */
char	*file_name;	/* IN: absolute name of the file, without suffix */
unsigned short object;	/* IN: fills the field 'p_object' in the file record */
{
    unsigned short	last_elt;	/* last element in the linked list */
    unsigned short	key;		/* h_code */
    int			SCIrc ;		/* Completion code */

#ifdef DEBUG
  printf( "SCIstore_file: ENTER(%s)\n", file_name ) ; fflush( stdout ) ;
#endif
    SCIrc = CI_S_SUCCESS ;
/* Check if there is an unused element in SCIfiles[] */
    if ( SCIfree_file == END_OF_LIST )
    {
        SCI_DEBUG( "SCIfiles overflow" )
        SCIrc = CI_E_FATAL_ERROR ;
	goto WRAPUP ;
    }

    if ( (last_elt = SCIhash_table[ key = SCIhash(file_name) ]) == END_OF_LIST )
    {
        /* Create a new linked list */
        SCIhash_table[key] = SCIfree_file;
    }
    else
    {
SCI_DEBUG( "h_collision while storing file" )
        /* Update the end of an existing list */
        while (SCIfiles[last_elt].next != END_OF_LIST)
            last_elt = SCIfiles[last_elt].next;
    	SCIfiles[last_elt].next = SCIfree_file;
    }

/* Add the new element at the end of the linked list and update the free list */
    SCIfree_file = SCIfiles[last_elt = SCIfree_file].next;
    SCIfiles[last_elt].next = END_OF_LIST;

/* Specific fields */
    if( ( SCIfiles[last_elt].name = malloc(strlen(file_name) + 1) ) == NULL ) {
	SCIrc = CI_E_CANT_MALLOC ;
    } else {
#ifdef DEBUG
printf("SCIstore_file: malloc: addr = %d\n", SCIfiles[last_elt].name); fflush( stdout ) ;
#endif
	strcpy(SCIfiles[last_elt].name, file_name);
	SCIfiles[last_elt].p_object = object;
    }

    WRAPUP :
#ifdef DEBUG
printf("SCIstore_file: EXIT(rc)\n", SCIrc ) ; fflush( stdout ) ;
#endif
    return SCIrc ;
}


void	SCIclear_file(file_name)
/*
 *   Removes a file entry from the DataBase.
 * NOTE:
 *   The attached object list is ignored and must have been previously freed by
 * the caller.
 */
char	*file_name;	/* IN: absolute name of the file, without suffix */
{
    unsigned short	curr_elt,     /* current elt. in the file linked list */
    			prec_elt;     /* preceding .......................... */
    unsigned short	key;	      /* h_code */
    
/* Get the head of the list */
    if ( (curr_elt = SCIhash_table[key = SCIhash(file_name)]) == END_OF_LIST )
    {
    	SCI_DEBUG( "software error: file not stored in the DataBase" )
    	return;
    }

/* Look for the element in the single linked list, and update this list */
    if ( !strcmp(SCIfiles[curr_elt].name, file_name) )
    {
        /* Got a match with the head of the list */
        /* The linked list is either removed or maintained */
        SCIhash_table[key] = SCIfiles[curr_elt].next;
    }
    else
    {
SCI_DEBUG( "h_collision while deleting file" )
        /* Look for the element in the tail of the list */
    	prec_elt = curr_elt;
    	while ( strcmp(SCIfiles[curr_elt].name, file_name) )
        {
            prec_elt = curr_elt;
            if ((curr_elt = SCIfiles[curr_elt].next) == END_OF_LIST)
            {
    	        SCI_DEBUG( "software error: file not stored in the DataBase" )
                return;
            }
        }

        /* Maintain the linked list */
        SCIfiles[prec_elt].next = SCIfiles[curr_elt].next;
    }

/* Check that the attached object list has already been released */
    if ( SCIfiles[curr_elt].p_object != END_OF_LIST )
    	SCI_DEBUG( "software error: file being cleared with attached objects" )

/* Add the element to the free list */
    SCIfiles[curr_elt].next = SCIfree_file;
    SCIfree_file = curr_elt;

/* Specific treatment */
    SCI_FREE( SCIfiles[curr_elt].name )
}


int	SCIstore_object(file_entry, file_name, objid, mtime)
/*
 *   Store, in the database, the id. of a CI object loaded with the code of a
 *file whose index is 'file_entry' in the file array.
 * NOTES:
 *   'file_entry' may be equal to END_OF_LIST, in which case a new file list
 * must be created.
 * RC:	CI_S_SUCCESS		OK
 *	CI_E_FATAL_ERROR	DataBase overflow
 */
unsigned short	file_entry;  /* IN: file entry in the DataBase */
char		*file_name;  /* IN: absolute name of the file, without suffix */
GRobjid		objid;	     /* IN: newly created CI object */
time_t		mtime;	     /* IN: last modification time of the ".e" file */
{
    unsigned short	last_elt;	/* last element in the object list */
    int			SCIrc ;		/* Completion code */

    SCIrc = CI_S_SUCCESS ;

/* Check if there is an unused element in SCIobjects[] */
    if ( SCIfree_object == END_OF_LIST )
    {
        SCI_DEBUG( "SCIobjects overflow" )
        SCIrc = CI_E_FATAL_ERROR;
	goto WRAPUP ;
    }

    if ( file_entry == END_OF_LIST )
    {
        /* Create a new linked list */
    	if ( SCIstore_file(file_name, SCIfree_object) == CI_E_FATAL_ERROR ) {
            SCIrc = CI_E_FATAL_ERROR;
	    goto WRAPUP ;
	}
    }
    else
    {
        /* Update the end of an existing list */
        last_elt = SCIfiles[file_entry].p_object;
        while (SCIobjects[last_elt].next != END_OF_LIST)
            last_elt = SCIobjects[last_elt].next;
    	SCIobjects[last_elt].next = SCIfree_object;
    }

/* Add the new element at the end of the linked list and update the free list */
    SCIfree_object = SCIobjects[last_elt = SCIfree_object].next;
    SCIobjects[last_elt].next = END_OF_LIST;

/* Specific fields */
    SCIobjects[last_elt].objid = objid;
    SCIobjects[last_elt].mtime = mtime;

    WRAPUP :
    return SCIrc ;
}


void	SCIclear_object(head, objid)
/*
 *   Removes the object from the DataBase, and deletes it physically.
 * NOTES:
 *   If "objid" equals NULL_OBJID, all the objects in the list are deleted.
 */
unsigned short	*head;		/* I/O: head of the object list */
GRobjid		objid;		/* IN:  CI object to be deleted */
{
    unsigned short	curr_elt,     /* current elt in the object list */
    			prec_elt;     /* preceding .................... */
    
    if ( objid != NULL_OBJID )		/* Destruction of ONE element */
    {
        /* Look for the element in the single linked list; update this list */
        curr_elt = *head;
        if ( SCIobjects[curr_elt].objid == objid )
        {
            /* Got a match with the head of the list */
            /* The linked list is either removed or maintained */
            *head = SCIobjects[curr_elt].next;
        }
        else
        {
            /* Look for the element in the tail of the list */
            prec_elt = curr_elt;
            while (SCIobjects[curr_elt].objid != objid)
            {
                prec_elt = curr_elt;
                if ((curr_elt = SCIobjects[curr_elt].next) == END_OF_LIST)
                {
        	    SCI_DEBUG( "object not stored in the DataBase" )
                    goto SPECIFIC_TREATMENT;
                }
            }

            /* Maintain the linked list */
            SCIobjects[prec_elt].next = SCIobjects[curr_elt].next;
        }

        /* Add the element to the free list */
        SCIobjects[curr_elt].next = SCIfree_object;
        SCIfree_object = curr_elt;

        /* Specific treatment */
SPECIFIC_TREATMENT:
        SCIdelete_object(objid);
    }
    else				/* Deletes ALL objects in the list */
    {
	if (*head == END_OF_LIST)	/* Defensive programming style */
        {
    	    SCI_DEBUG( "software error: empty object list" )
            return;
        }
	prec_elt = curr_elt = *head;
	do
        {
	    SCIdelete_object(SCIobjects[curr_elt].objid);
            prec_elt = curr_elt;
	}
	while ((curr_elt = SCIobjects[curr_elt].next) != END_OF_LIST);

	/* The records and the entry in SCIfiles[] must be freed */
        SCIobjects[prec_elt].next = SCIfree_object;
        SCIfree_object = *head;
        *head = END_OF_LIST;
    }
}

/*-PUBLIC FUNCTIONS-----------------------------------------------------------*/

int	SCIload(file_name, objid, mode, sender_id, sender_os )

char		*file_name;
OM_S_OBJID	*objid, sender_id ;
int 		mode;
OMuword		sender_os ;
/*
 *  Look for a CI object running the file "file_name". Make some tests on the
 * last modification date of the CI file. Clone the eventual CI object if rele-
 * vant, else load an object the usual way.
 * RC: CI_S_SUCCESS	a CI object has been successfully cloned or loaded
 *     CI_E_CANT_ACCESS	neither the source file, nor the compiled file exists
 *     CI_E_ACCCOMPILED	the system failed to give info. on the compiled file
 *     CI_E_CLON_FAILED	an error occured while cloning for the new CI object
 *     CI_E_LOAD_FAILED	an error occured while loading the new CI object
 *     CI_E_MODELNOTFND	no model object found
 *     CI_E_DB_OVERFLOW	the object has been created but cannot be registered in
 *			the database
 *
 * ARGUMENTS
 * file_name	INPUT. Represents the CI source file name, with or without the
 *		suffix ".u", with an absolute or a relative path.
 * objid	INPUT if mode = NO_LOAD, else OUTPUT. May not be NULL.
 * mode		INPUT. Defines the requested action.
 *
 * The following flow-chart explains in details the impact of "mode": 
 *
 * IF (mode == LOAD_UNCOND)
 *    A new CI object is loaded unconditionaly. Its object id. is stored in the
 *      DataBase and assigned to objid.
 * ELSE
 *    Look for a model object in the DataBase (i.e. a CI object that is running
 *     the current version of the CI file).
 *    IF a model object has been found
 *	IF (mode == RETRIEVE || mode == LOAD)
 *	    objid <-- the model object id.
 *	    Return CI_S_SUCCESS
 *	ELSE		// DUP
 *	    The model object is cloned.
 *	    objid <-- the newly created object id.
 *	ENDIF
 *    ELSE		// No model found
 *	IF  (mode == RETRIEVE)
 *	    Return CI_E_MODELNOTFND
 *	ELSE
 *	    Load a new CI object: O1.
 *	    objid <-- O1.
 *	    IF (mode == DUP)
 *		O1 is stored in the DB.
 *		Clone O1 to built a new object O2.
 *		objid <-- O2.
 *	    ENDIF
 *	ENDIF
 *    ENDIF
 * ENDIF
 * Store objid in the DataBase
 *
 * NOTES
 *   It is valuable here to make clear the meaning of the word "model". In the
 * DataBase, an objid is associated with the last modification date of the
 * ".e" file. For a given file name, a loaded object is a model if and only if:
 *  -1/ The source file doesn't exist OR doesn't need to be recompiled.
 *  -2/ The ".e" file exists AND is not newer than the date stored in the DB.
 *   Therefore a model object can be cloned to get a new CI object sharing the
 * same intruction segment.
 */
{
    unsigned short	f_entry,	/* file entry in the DataBase */
			curr_obj;	/* current object */
    struct stat		statbuf;	/* buffer used by stat() */
    time_t		mtime;		/* last modification date */
    OM_S_OBJID		model_id;	/* id of a clonable object */
    UNIXpath	expanded_name,		/* absolute name */
    		name_radical;		/* absolute name without suffix */
    char	clonable;		/* flag: is there a clonable object ? */
    char	date_check;		/* flag: do we check dates ? */
    long	msg ;

    SCI_DEBUG( "SCIload ENTER" )
    msg = CI_S_SUCCESS ;

#ifdef DEBUG
  printf( "SCIload : <%s> sender (%d, %u[%d])\n", file_name,
		sender_os, sender_id, sender_id ) ;
  fflush( stdout ) ;
#endif
/* 20/10/88 */
    date_check = ! (mode & NO_DATE);
    mode &= ~NO_DATE;

/* Check that 'objid' has a valid value */
    if ( objid == NULL )
    {
        SCI_DEBUG( "'objid' not specified" )
	msg = CI_E_INVALIDARGS;
	goto WRAPUP ;
    }

    if ( mode == NO_LOAD ) {
 	msg = CI_S_SUCCESS;
	goto WRAPUP ;
    }

					/* LOAD_UNCOND, LOAD, DUP or RETRIEVE */
/* Check that 'file_name' has a valid value */
    if ( file_name == NULL )
    {
        SCI_DEBUG( "'file_name' not specified" )
	msg = CI_E_INVALIDARGS;
	goto WRAPUP ;
    }

/* Make sure the CI super object does exist */
    SCIconstruct();

/* Convert the file name to absolute path */
    if ( ! CIgetname(file_name, expanded_name) ) {
	msg = CI_E_CANT_ACCESS ;
	goto WRAPUP ;
    }
    strcpy(name_radical, expanded_name);
    name_radical[strlen(name_radical) - 2] = '\0';

/* Look for the file in the DataBase */
    f_entry = SCIsearch_file(name_radical);

    if ( mode == LOAD_UNCOND )
    {
        /* Construct a new CI object */
     	if( ! CIconstruct(	&msg	, name_radical	, mode	,
				objid	, sender_id	, sender_os ) )
            goto WRAPUP ;
    }
    else				/* LOAD, DUP or RETRIEVE */
    {
        /* Check that 'mode' has a valid value */
        switch ( mode ) {
        case DUP:
        case LOAD:
        case RETRIEVE:
            break;
        default:
            SCI_DEBUG( "'mode' has not a valid value" )
	    msg = CI_E_INVALIDARGS;
	    goto WRAPUP ;
        }

        /* Look for a model object in the DataBase */
        if ( ends_with_dot_u(expanded_name) )
        {
	    clonable = 0;
	    expanded_name[strlen(expanded_name) - 1] = 'e';
        }
        else	/* file assumed to end with ".e" */
        {
            if ( date_check )
                if ( ! stat(expanded_name, &statbuf) )
                    mtime = statbuf.st_mtime;
                else
                {
                    CI_SYS_ERR("stat", expanded_name)
                    msg = CI_E_ACCCOMPILED;
		    goto WRAPUP ;
                }

	    if (f_entry == END_OF_LIST)
	        clonable = 0;
	    else
	    {
	        /* Scanning the object list for a valid CI object */
	        if ( date_check )
                {
                    curr_obj = SCIfiles[f_entry].p_object;
	            clonable = 0;
	            while (curr_obj != END_OF_LIST)
	            {
                        if (SCIobjects[curr_obj].mtime >= mtime)
                        {
		            model_id = SCIobjects[curr_obj].objid;
			    clonable = 1;
    	                    break;		/* success */
                        }
                        curr_obj = SCIobjects[curr_obj].next;
                    }
 	        }
                else	/* no date check */
                {
		    model_id = SCIobjects[SCIfiles[f_entry].p_object].objid;
		    clonable = 1;
                }
            }
        }
#ifdef DEBUG
printf("SCIload: clonable = %d\n", clonable);
  fflush( stdout ) ;
#endif

        /* Object construction */
        if ( clonable )
        {
            if ( mode == LOAD || mode == RETRIEVE )
            {
		/* Returns the model objid */
		*objid = model_id;
		msg = CI_S_SUCCESS;
		goto WRAPUP ;
            }
            else			/* DUP */
	    {
	        /* The model object is cloned */
    	        if ( ! ci_clonage( &msg, model_id, objid,
					 sender_id, sender_os ) )
                    goto WRAPUP ;
	    }
        }
        else				/* no model object found */
        {
	    if  (mode == RETRIEVE) {
		msg = CI_E_MODELNOTFND;
		goto WRAPUP ;
	    }
	    else			/* LOAD or DUP */
            {
	        /* Load a new CI object */
     	        if( ! CIconstruct(	&msg	, name_radical	, mode	,
					objid	, sender_id	, sender_os ) )
                    goto WRAPUP ;
	        if (mode == DUP)
		{
	            /* Stores this first object in the DataBase and */
		    /* clones it to built a new object */
		    OM_S_OBJID obj1 = *objid;
		    if ( ! stat(expanded_name, &statbuf) )
			mtime = statbuf.st_mtime;
		    else
		    {
			CI_SYS_ERR("stat", expanded_name)
			msg = CI_E_ACCCOMPILED;
			goto WRAPUP ;
		    }
		    SCIstore_object(f_entry, name_radical, *objid, mtime);
		    /*  We don't care to know if it was successful, but
			if the file wasn't in the DB yet, f_entry must be
			reevaluated */
		    f_entry = SCIsearch_file(name_radical);
    	            if ( ! ci_clonage( &msg, obj1, objid,
					sender_id, sender_os ) )
                        goto WRAPUP ;
	        }
	    }
        }
    }

/* At last, store the new CI object in the DataBase */
    if ( ! stat(expanded_name, &statbuf) )
        mtime = statbuf.st_mtime;
    else
    {
        CI_SYS_ERR("stat", expanded_name)
        msg = CI_E_ACCCOMPILED;
	goto WRAPUP ;
    }
    if( SCIstore_object(f_entry, name_radical, *objid, mtime) != CI_S_SUCCESS ){
        msg = CI_E_DB_OVERFLOW;
    }

    WRAPUP :
    SCI_DEBUG( "SCIload EXIT" )
#ifdef DEBUG
  ci$report_error( status = msg, output = CI_ERR_STDOUT ) ;
#endif

    return msg ;
}


int	SCIdelete(file_name, objid)
/*
 *   Remove the id. of a CI object from the object array.
 * NOTES:
 *   'file_name' may not be specified but that increases the exec. time.
 *   'objid' can be 0, in this case, all objects running the file are deleted.
 * RC:	CI_S_SUCCESS		OK
 *	CI_E_INVALIDARGS	Invalid arguments
 */
char	*file_name;	/* IN: absolute name of the file, without suffix */
GRobjid	objid;		/* IN: CI object id. */
{
    unsigned short	*head,		/* head of the object linked list */
			key;		/* loop index in SCIhash_table */
    unsigned short	f_entry;	/* file index */
    UNIXpath 		name_radical;	/* absolute name without suffix */

/* Make sure the CI super object does exist */
    SCIconstruct();

    if ( file_name != NULL )		/* 'file_name' is specified */
    {
        /* Conversion of the file name in absolute path without radical */
        if ( ! CIgetname(file_name, name_radical) )
            goto NAME_NOT_SPECIFIED;
        name_radical[strlen(name_radical) - 2] = '\0';

        /* Check that the file name exists in the DataBase */
        if ((f_entry = SCIsearch_file(name_radical)) == END_OF_LIST)
        {
            SCI_DEBUG( "file not stored in the DataBase" )
            goto NAME_NOT_SPECIFIED;
        }

        /* Fire ! */
        SCIclear_object(head = &(SCIfiles[f_entry].p_object), objid);
        if ( *head == END_OF_LIST )
            SCIclear_file(name_radical);
    }
    else				/* 'file_name' is NOT specified */
    {
NAME_NOT_SPECIFIED:
        if ( objid == NULL_OBJID )
        {
            SCI_DEBUG( "File name meaningless and object id equals NULL_OBJID" )
            return CI_E_INVALIDARGS;
        }
	for (key=0; key<NUM_HASH; key++)
        {
            f_entry = SCIhash_table[key];
            while (f_entry != END_OF_LIST)
            {
                SCIclear_object(head = &(SCIfiles[f_entry].p_object), objid);
                if ( *head == END_OF_LIST )
		{
		    unsigned short	f_entry_0 = f_entry;
                    f_entry = SCIfiles[f_entry].next;
                    SCIclear_file(SCIfiles[f_entry_0].name);
		}
		else
                    f_entry = SCIfiles[f_entry].next;
            }
        }
    }
    return CI_S_SUCCESS;
}


int SCIinq_files(count, names)
int	*count;
char	**names;
/*
 *  Inquire the CI super object to get the list of CI files that it knows
 * smthing about.
 * Referenced in the macro: ci$inq_files
 * RC:	CI_S_SUCCESS		OK
 *	CI_E_INVALIDARGS	Invalid arguments
 */
{
    unsigned short	key;		/* loop index in SCIhash_table */
    unsigned short	f_entry;	/* file index */
    int			limit, rc;	/* max # of elts that can be returned */

/* Make sure the CI super object does exist */
#ifdef DEBUG
  printf( "SCIinq_files: ENTER *count = %d\n", *count ) ; fflush( stdout ) ;
#endif
    rc = CI_S_SUCCESS ;
    SCIconstruct();

    if ( *count == 0 )
    {
	for (key=0; key<NUM_HASH; key++)
        {

            f_entry = SCIhash_table[key];
            while (f_entry != END_OF_LIST)
            {
		(*count)++;
                f_entry = SCIfiles[f_entry].next;
            }
        }
    }
    else
    {
	if ( names == NULL ) {
		rc = CI_E_INVALIDARGS;
		goto WRAPUP ;
	}
	limit = *count;
	*count = 0;
	for (key=0; key<NUM_HASH; key++)
        {
#ifdef DEBUG
  printf( "SCIinq_files: key = %d\n", key ) ; fflush( stdout ) ;
#endif
            f_entry = SCIhash_table[key];
            while (f_entry != END_OF_LIST)
            {
#ifdef DEBUG
  printf( "SCIinq_files: 1- *count = %d\n", *count ) ; fflush( stdout ) ;
#endif
/*
                names[*count] = SCIfiles[f_entry].name;
		if ( (*count)++ >= limit )
		    break;
*/
		if( *count < limit ) {
			names[(*count)++] = SCIfiles[f_entry].name ;
		} else break ;
#ifdef DEBUG
  printf( "SCIinq_files: 2- *count = %d\n", *count ) ; fflush( stdout ) ;
#endif
                f_entry = SCIfiles[f_entry].next;
            }
        }
    }

    WRAPUP :
#ifdef DEBUG
  printf( "SCIinq_files: EXIT\n" ) ; fflush( stdout ) ;
#endif
    return rc ;
}


int SCIinq_objects(f_name, count, objects)
char		*f_name;
int		*count;
OM_S_OBJID	*objects;
/*
 *  Inquire the CI super object to get the list of CI objects loaded with a
 * given CI file.
 * Referenced in the macro: ci$inq_objects
 * RC:	CI_S_SUCCESS	 OK
 *	CI_E_INVALIDARGS Invalid arguments
 *	CI_E_CANT_ACCESS Neither the source file, nor the compiled file exists
 */
{
    int			limit,		/* max # of elts that can be returned */
			SCIrc ;		/* Completion code		*/
    unsigned short	f_entry,	/* file entry in the DataBase */
			curr_elt;	/* current object */
    UNIXpath		name_radical;	/* absolute name without suffix */

    SCIrc = CI_S_SUCCESS;
/* Make sure the CI super object does exist */
    SCIconstruct();

/* Arg. check */
    limit = *count;
    if ( limit && (objects == NULL) ) {
        SCIrc = CI_E_INVALIDARGS;
	goto WRAPUP ;
    }
    *count = 0;

/* Conversion of the file name to absolute path without radical */
    if ( ! CIgetname(f_name, name_radical) ) {
        SCIrc = CI_E_CANT_ACCESS ;
	goto WRAPUP ;
    }
    name_radical[strlen(name_radical) - 2] = '\0';

/* Check that the file name exists in the DataBase */
    if ((f_entry = SCIsearch_file(name_radical)) == END_OF_LIST) {
        SCIrc = CI_S_SUCCESS;
	goto WRAPUP ;
    }

    curr_elt = SCIfiles[f_entry].p_object;
    do
    {
	if ( limit )
	{
	    objects[*count] = SCIobjects[curr_elt].objid;
	    if ( *count >= limit - 1 )
		goto WRAPUP ;
	}
	(*count)++;
    } while ((curr_elt = SCIobjects[curr_elt].next) != END_OF_LIST);

    WRAPUP :
    return SCIrc ;
}
/*----------------------------------------------------------------------------*/
int SCIbroadcast( entry, argc, argv )	char		*entry	;
					int		argc	;
					CIpushlist	*argv	; {

	int	i, objix	;
	int	CIsts, OMsts	;

#ifdef DEBUG
  printf( "SCIbroadcast: ENTER\n" ) ;
  fflush( stdout ) ;
#endif

  for( i = 0 ; i < SCI_MX_FILE ; i++ ) {
    if( SCIfiles[i].name != NULL ) {
	objix = SCIfiles[i].p_object ;
#ifdef DEBUG
  printf( "SCIbroadcast: file %s\n", SCIfiles[i].name ) ;
  fflush( stdout ) ;
#endif
	do {
	  if( objix != END_OF_LIST ) {
#ifdef DEBUG
  printf( "SCIbroadcast: fileid %d\n", SCIobjects[objix].objid ) ;
  fflush( stdout ) ;
#endif

	    OMsts = ci$is_entry_point(	entry	= entry,
					file	= SCIobjects[objix].objid,
					senderid= NULL_OBJID,
					stat	= &CIsts ) ;
	    if( ( OMsts & OM_S_SUCCESS ) && ( CIsts & CI_S_SUCCESS ) ) {
#ifdef DEBUG
  printf( "SCIbroadcast: <%s> for fileid %s\n", entry, SCIobjects[objix].objid ) ;
  fflush( stdout ) ;
#endif
		if( argc > 0 ) ci$push( argc = argc, argv = argv ) ;

		CIsts = 0 ;
		ci$f_execute(	entry	= entry,
				file	= SCIobjects[objix].objid,
				senderid= NULL_OBJID,
				action	= &CIsts ) ;

	    }
	    objix = SCIobjects[objix].next ;
          } /* if objix ... */

	} while( objix != END_OF_LIST ) ;

    } /* if SCIfiles[i].name ... */

  } /* for ... */

#ifdef DEBUG
  printf( "SCIbroadcast: EXIT\n" ) ;
  fflush( stdout ) ;
#endif
  return CI_S_SUCCESS ;

} /* SCIbroadcast */
/*----------------------------------------------------------------------------*/

end implementation super_ci;
