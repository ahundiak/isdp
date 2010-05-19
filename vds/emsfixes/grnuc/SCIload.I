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
*
* 08 May 2002 ah Copied SCIload here to enable tracing the full path of a ppl
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

extern SCI_S_FILE	SCIfiles[SCI_MX_FILE];	/* Array of CI files */
extern SCI_S_OBJECT	SCIobjects[SCI_MX_OBJ];	/* Array of running CI object */
extern unsigned short	SCIfree_file;		/* index of the first unused element
						in SCIfiles */
extern unsigned short	SCIfree_object;		/* index of the first unused element
						in SCIobjects */
extern unsigned short	SCIhash_table[NUM_HASH]; /* array of index to SCIfiles[] */

extern char	*sys_errlist[];
char		*malloc();
void		SCIinit();
char            *getenv(char *name);

unsigned short	SCIstore_file(file_name, object);

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

    char *p;

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
#if 1
    p = getenv("ISDP_SHOW_PPL_PATH");
    if ((p && (*p == '1')) || VDdbgGetTracePPL()) {
      printf("PPL %s\n",expanded_name);
    }
#endif
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

end implementation super_ci;

