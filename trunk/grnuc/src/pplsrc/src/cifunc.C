/*
 *	 Etienne Beeker
 *	10-4-86
 *
 * emulation of some basic C-like routines for ci, command interpretor:
 *	read
 *	prompt
 *	getpoint
 *	call to the shell
 *	...
 */

#include "exsysdep.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "ex.h"
#include "igrdp.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciprivmacros.h"
#include "cimsg.h"
#include <malloc.h>
#include <string.h>
#include "cisetup.h"
#include <fcntl.h>
#include <errno.h>
#ifdef CLIX
#define  _INGR_EXTENSIONS 1
#include <math.h>
#undef   _INGR_EXTENSIONS
#else
#if defined ( SUNOS ) || defined ( SUNOS5 )
#if __STDC__
#undef __STDC__
#define __STDC__ 0
#include <math.h>
#undef __STDC__
#define __STDC__ 1
#else
#include <math.h>
#endif
#endif
#ifdef IRIX
#include <math.h>
#endif
#endif
#include <memory.h>
#include "madef.h"
#include "exmacros.h"
#include <malloc.h>
#include <sys/param.h>
/*
   rlw 2/14/92 added the line below since this macro is not defined
   on the Sun.  On the Clipper it is defined in param.h.
 */
#ifdef BIG_ENDIAN
#define	hibyte(X)	(((unsigned char *)&X)[1])
#endif
#include <sys/types.h>
#include <sys/stat.h>
#include "cimsg.h"
#include "griomacros.h"

extern	char errmess[];
extern	struct instance_ci *ci_data;
extern  char	**ci_data_varvaltable;
extern  char	*ci_data_info;
extern  char	*CIexmessage();

double	(* Ci_math_f)();	/* pointer on functions in math. lib. */
double  ci_give_value();


int cifcall(instr, evdata, runenv, state )
struct ci_instruction	*instr	;
CIco_resp		*evdata	;
CIruntime		*runenv	;
short			*state	;

/*
 * Execute instructions of type FCALL: PPL library function call.
 */
{
	int i0;
	char *fname;

	i0 = instr->paramlist[0];
	fname = ci_data->vartable[i0];

	/* Reset of the returned value */
	switch( ci_data->vartypetable[i0] )
	{
	  case CI_CHAR :
	    c_cival(i0) = 0;
	    break;
	  case CI_SHORT :
	    s_cival(i0) = 0;
	    break;
	  case CI_INT :
	    i_cival(i0) = 0;
	    break;
	  case CI_DOUBLE :
	    d_cival(i0) = 0.;
	    break;
	  case CI_GROBJ :
	    o_cival(i0) = NULL_OBJID;
	    break;
	  default:
	    if( ispointer(i0) ){
		p_cival(i0) = NULL;
	    } else {
		sprintf(errmess,"FCALL: unknown function type for %s",fname);
		erreur(errmess);
	    }
	    break;
	}

	switch(fname[0]){

        case 'C':
	  if(!strcmp("CIlocate", fname))
	    return CIlocate(instr, evdata, runenv, state );

	  if(!strcmp("CIgetevent", fname))
	    return CIgetevent(instr, evdata, runenv, state  );

	  if(!strcmp("CIputevent", fname))
	    return CIputevent(instr, evdata, runenv, state  );

	  if(!strcmp("CIexec", fname))
	    return CIexec(instr, evdata, runenv, state );

	  if(!strcmp("CIsend", fname))
	    return CIsend(instr, evdata, runenv, state );

	  if(!strcmp("CIget_module_info", fname))
	    return CIget_module_info(instr);

	  if(!strcmp("CIget_channel_objects", fname))
	    return CIget_channel_objects(instr);

	  if(!strcmp("CIquiet", fname))
	    return CIquiet(instr, evdata, runenv, state );

	  if(!strcmp("CIdpdynamics", fname))
	    return CIdpdynamics(instr, evdata, runenv, state );

        case 'D':
	  if(!strcmp("DBclose", fname))
	    return ciDBclose(instr);
	  if(!strcmp("DBopen", fname))
	    return ciDBopen(instr);
	  if(!strcmp("DBcmd", fname))
	    return ciDBcmd(instr);
	  if(!strcmp("DBflush", fname))
	    return ciDBflush(instr);
	  if(!strcmp("DBinit", fname))
	    return ciDBinit(instr);
	  if(!strcmp("DBread", fname))
	    return ciDBread(instr);
	  if(!strcmp("DBsearch", fname))
	    return ciDBsearch(instr);
	  if(!strcmp("DBwrite", fname))
	    return ciDBwrite(instr);
	  if(!strcmp("DBselect", fname))
	    return ciDBselect(instr);
	  if(!strcmp("DBattach", fname))
	    return ciDBattach(instr);
	  if(!strcmp("DBdetach", fname))
	    return ciDBdetach(instr);

	case 'S':
	  if(!strcmp("SCIdelete", fname))
	    return ciSCIdelete(instr);
	  if(!strcmp("SCIinq_files", fname))
	    return ciSCIinq_files(instr);
	  if(!strcmp("SCIinq_objects", fname))
	    return ciSCIinq_objects(instr);

	case 'a':
	  if( !strcmp("awrite", fname))
	    return ciwrite(instr);

	  if( !strcmp("aread", fname) )
	    return ciread(instr);

	  if(!strcmp("asin", fname)) {
	    Ci_math_f = asin;
	    return cimath(instr);
	  }
	  if(!strcmp("acos", fname)) {
	    Ci_math_f = acos;
	    return cimath(instr);
	  }
	  if(!strcmp("atan", fname)) {
	    Ci_math_f = atan;
	    return cimath(instr);
	  }
	  if(!strcmp("atan2", fname)) {
	    Ci_math_f = atan2;
	    return cimath2(instr);
	  }
	  if(!strcmp("atof", fname))
	    return ciatof(instr);

	  if(!strcmp("atoi", fname))
	    return ciatoi(instr);

	case 'b':
	  if(!strcmp("begincmd", fname))
	    return cidocmd( CI_DOCMD_STR, instr, evdata, runenv, state );

	  if(!strcmp("begincmd_key", fname))
	    return cidocmd( CI_DOCMD_KEY, instr, evdata, runenv, state );

	case 'c':
	  if(!strcmp("ci_clonage", fname))
	    return cici_clonage( instr, evdata, runenv, state );

	  if(!strcmp("close", fname))
	    return ciclose(instr);

	  if(!strcmp("cosh", fname)) {
	    Ci_math_f = cosh;
	    return cimath(instr);
	  }
	  if(!strcmp("cos", fname)) {
	    Ci_math_f = cos;
	    return cimath(instr);
	  }
	  if(!strcmp("ceil", fname)) {
	    Ci_math_f = ceil;
	    return cimath(instr);
	  }

	case 'd':
	  if( !strcmp("dump", fname) )
		return cidump(instr);

	case 'e':
	  if(!strcmp("exp", fname)) {
	    Ci_math_f = exp;
	    return cimath(instr);
	  }
	  if(!strcmp("endcmd", fname))
	    return cidocmd( CI_DOCMD_END, instr, evdata, runenv, state );

	case 'f':
	  if( !strcmp("fwrite", fname))
	    return ciwrite(instr);

	  if( !strcmp("fread", fname) )
	    return ciread(instr);

	  if(!strcmp("floor", fname)) {
	    Ci_math_f = floor;
	    return cimath(instr);
	  }
	  if(!strcmp("fmod", fname)) {
	    Ci_math_f = fmod;
	    return cimath2(instr);
	  }
	  if(!strcmp("fabs", fname)) {
	    Ci_math_f = fabs;
	    return cimath(instr);
	  }

	case 'g':
	  if(!strcmp("gamma", fname)) {
	    Ci_math_f = gamma;
	    return cimath(instr);
	  }

/*	NOTE: CI_SYMB should output an error message if cnst_list not here ! */
	  if(!strcmp("get_symb", fname))
	    return CI_SYMB(fname);

	  if(!strcmp("get_text_attr", fname))
	    return CI_SYMB(fname);

	case 'h':
	  if(!strcmp("hypot", fname)) {
	    Ci_math_f = hypot;
	    return cimath2(instr);
	  }

	case 'i':

	case 'l':
	  if(!strcmp("log", fname)) {
	    Ci_math_f = log;
	    return cimath(instr);
	  }
	  if(!strcmp("log10", fname)) {
	    Ci_math_f = log10;
	    return cimath(instr);
	  }
	
	case 'm':
	  if(!strcmp("message", fname))
	    return cimessage(instr, evdata,  runenv, state );

	  if(!strcmp("msonoff", fname))
	    return cimsonoff(instr);

	  if(!strcmp("my_id", fname))
	    return cimy_id(instr, evdata,  runenv, state );

	  if(!strcmp("my_os", fname))
	    return cimy_os(instr);

	  if(!strcmp("memcpy", fname))
	    return cimemcpy(instr);

	case 'n':
	  if(!strcmp("ntoa", fname))
	    return cintoa(instr);

	case 'p':
	  if(!strcmp("pread", fname))
	    return ciread(instr);

	  if(!strcmp("pwrite", fname))
	    return ciwrite(instr);

	  if(!strcmp("pow", fname)) {
	    Ci_math_f = pow;
	    return cimath2(instr);
	  }
	  if(!strcmp("prompt", fname))
	    return ciprompt(instr, evdata, runenv, state );

	case 'r':
	  if(!strcmp("readrtree", fname))
	    return cireadrtree(instr);

	case 's':
	  if(!strcmp("strlen", fname))
	    return cistrlen(instr);

	  if(!strcmp("strcmp", fname))
	    return cistrcmp(instr);

	  if(!strcmp("strcat", fname))
	    return cistrcat(instr);

	  if(!strcmp("strcpy", fname))
	    return cistrcpy(instr);  

	  if(!strcmp("status", fname))
	    return cistatus(instr);

	  if(!strcmp("sh", fname))
	    return cish(instr);

	  if(!strcmp("set_symb", fname))
	    return CI_SYMB(fname);

	  if(!strcmp("set_gal_symb", fname))    /* jla 17-10-87 */
	    return CI_SYMB(fname);

	  if(!strcmp("set_text_attr", fname))
	    return CI_SYMB(fname);

	  if(!strcmp("sin", fname)) {
	    Ci_math_f = sin;
	    return cimath(instr);
	  }
	  if(!strcmp("sinh", fname)) {
	    Ci_math_f = sinh;
	    return cimath(instr);
	  }
	  if(!strcmp("sqrt", fname)) {
	    Ci_math_f = sqrt;
	    return cimath(instr);
	  }
	  if(!strcmp("sender_id", fname))
	    return cisender_id(instr);

	case 't':
	  if(!strcmp("tanh", fname)) {
	    Ci_math_f = tanh;
	    return cimath(instr);
	  }
	  if(!strcmp("tan", fname)) {
	    Ci_math_f = tan;
	    return cimath(instr);
	  }

	case 'w':
	  if( !strcmp("write", fname))
	    return ciwrite(instr);

	default:
	  break;
        }

	/* software error */
	sprintf(errmess,"unknown function:%s", fname);
	erreur(errmess);
	return 0;
}


int cidump(func)
struct ci_instruction *func;
/*
 * For debugging purposes. Dumps the arguments to the standard output.
 */
{
    register int  i ;

    for (i=1; i<func->nbparam ;i++) {
	cieditvar( func->paramlist[i] ) ;
    }
    return ISUCCESS ;
}


#argsused
int ciprompt(func, evinfo, runparms, state )
struct ci_instruction	*func		;
CIco_resp		*evinfo		;
CIruntime		*runparms	;
short			*state		;
/*
 * Writes a character string to the prompt field. Argument is either a string or
 * a message number.
 * Returned value : always TRUE.
 * NOTE: text may be truncated : too long a message causes disaster ! 
 */
{
	int ivar ; char *prompt ;


	ivar	= func->paramlist[1] ;
	prompt = runparms->msgsys.Prompt ;
	if( isstring( ivar ) ) {	/* Character string */
		strncpy(	prompt	,
				st_cival( ivar )	,
				CI_MAX_SMGR_MSG_SIZE	) ;
	} else {			/* Message number   */
		strncpy(	prompt	,
				CIexmessage( i_cival( ivar ) )	,
				CI_MAX_SMGR_MSG_SIZE		) ;
	}
	prompt[CI_MAX_SMGR_MSG_SIZE] = '\0' ;
	COND_prompt( prompt ) ;

	runparms->msgsys.clear_prompt = FALSE ;

	i_cival(func->paramlist[0]) = TRUE ;
	return ISUCCESS ;
}

#argsused
int cimessage(func, evinfo, runparms, state )
struct ci_instruction	*func		;
CIco_resp		*evinfo		;
CIruntime		*runparms	;
short			*state		;
/*
 * Writes a character string to the message field. Argument is either a string
 * or a message number.
 * Returned value : always TRUE .
 * NOTE: text may be truncated : too long a message causes disaster ! 
 */
{
	int ivar ; char *message ;

	ivar	= func->paramlist[1];
	message	= runparms->msgsys.Message ;
	if( isstring( ivar ) ) {	/* Character string */
		strncpy(	message	,
				st_cival( ivar )	,
				CI_MAX_SMGR_MSG_SIZE	) ;
	} else {			/* Message number   */
		strncpy(	message	,
				CIexmessage( i_cival( ivar ) )	,
				CI_MAX_SMGR_MSG_SIZE		) ;
	}
	message[CI_MAX_SMGR_MSG_SIZE] = '\0' ;

	COND_message( message ) ;

	i_cival(func->paramlist[0]) = TRUE ;
	return ISUCCESS ;
}

int cistatus(func)
struct ci_instruction *func;
/*
 * Writes a character string to the status field. Argument is either a string or
 * a message number.
 * Returned value : always TRUE .
 * NOTE: text may be truncated : too long a message causes disaster ! 
 */
{
	int ivar; char tmp[1+CI_MAX_SMGR_MSG_SIZE] ;

	ivar = func->paramlist[1];

	if( isstring( ivar ) ) {	/* Character string */
		strncpy(	tmp			,
				st_cival( ivar )	,
				CI_MAX_SMGR_MSG_SIZE	) ;
	} else {			/* Message number   */
		strncpy(	tmp				,
				CIexmessage( i_cival( ivar ) )	,
				CI_MAX_SMGR_MSG_SIZE		) ;
	}
	tmp[CI_MAX_SMGR_MSG_SIZE] = '\0' ;
	COND_status( tmp );

	i_cival(func->paramlist[0]) = TRUE ;
	return ISUCCESS ;
}
  
int cish(func)
struct ci_instruction *func;
/*
 * Executes a shell command. Will only work if application run by driver.
 */
{
#define SHELL    "/bin/ksh"

  int	ivar	,	/* Index of PPL variable containing command	*/
	narg	,	/* Argument count for ex$fork			*/
  	rc	,	/* Return code of command (high byte of sh rc )	*/
	sysrc ;		/* Return code from shell executing command	*/
  char	*args[3] ;	/* Array of arguments for ex$fork		*/

  ivar = func->paramlist[1] ;

  if( ex$is_driver_exist() ) {
	narg = 0 ;
	args[narg++] = SHELL		;
	args[narg++] = "-c"		;
	args[narg++] = st_cival( ivar )	;

	sysrc = ex$fork(	num_entry	= narg ,
	  	            	argu		= args ,
	       	        	wait_flag	= TRUE    ) ;
	rc = hibyte( sysrc ) == 0 ;
	if( !rc ) {
	  sprintf( errmess, "Error %d in executing <%s>", rc, st_cival(ivar) );
	  erreur( errmess ) ;
	} 
  } else {
	ex$message( msgnumb = CI_F_lsNODRIV ) ;
	rc = FALSE ;
  }
  i_cival(func->paramlist[0]) = rc ;
  return ISUCCESS ;
}
/*----------------------------------------------------------------------------*/
char CI_in_math = FALSE ;

int cimath(func)
struct ci_instruction *func;
/*
 * Emulation of math functions
 * Returns ISUCCESS.
 */
{
	int i0, i1;

	i1 = func->paramlist[1];
	i0 = func->paramlist[0];
	CI_in_math = TRUE ;
	d_cival(i0) = Ci_math_f(ci_give_value(i1));
	CI_in_math = FALSE ;

	return ISUCCESS ;
}

int cimath2(func)
struct ci_instruction *func;
/*
 * Emulation of math functions with 2 arguments 
 * Returns ISUCCESS.
 */
{
	int i0, i1, i2;
	double x, y;

	i1 = func->paramlist[1];
	i2 = func->paramlist[2];
	x  = ci_give_value(i1);
	y  = ci_give_value(i2);
	i0 = func->paramlist[0];
	CI_in_math = TRUE ;
	d_cival(i0) = Ci_math_f(x, y);
	CI_in_math = FALSE ;

	return ISUCCESS ;
}

int ciatoi(func)
struct ci_instruction *func;
/* Alpha to integer conversion function.
 * Returns ISUCCESS.
 */
{
	sscanf( st_cival(func->paramlist[1]), "%d", cival(func->paramlist[0]));
	return ISUCCESS ;
}

int ciatof(func)
struct ci_instruction *func;
/* Alpha to double precision floating point number conversion function.
 * Returns ISUCCESS.
 */
{
	sscanf( st_cival(func->paramlist[1]), "%lf", cival(func->paramlist[0]));
	return ISUCCESS ;
}


int cintoa(func)
struct ci_instruction *func;
/* Integer/double precision to alpha conversion function.
 * Also valid for chars and short.
 * Returns ISUCCESS.
 */
{
	int i1, i0;
	static char s0[512];

	i0 = func->paramlist[0];
	i1 = func->paramlist[1];

	if(isint(i1) || isGRobj(i1))
	    sprintf(s0, "%d", i_cival(i1));
	else if(ischar(i1))
	    sprintf(s0, "%d", c_cival(i1));
	else if(isshort(i1))
	    sprintf(s0, "%d", s_cival(i1));
	else if(isdouble(i1))
	    sprintf(s0, "%lf", d_cival(i1));

        p_cival(i0) = &s0[0];
	return ISUCCESS ;
}

int cimsonoff( func )

struct ci_instruction *func;

/*
 * Sets the message fields ON or OFF
 * if param is 0: OFF
 * if param is 1: ON
 * if param is 2: reset to the last value
 */
{
	int 		i1 ;
	static short	lastvalue ;
	long		msg ;

 i1 = func->paramlist[1] ;

 switch( i_cival( i1 ) ) {
	case 0 : ms$onoff( msg = &msg, type = MS_OFF, prevstate = &lastvalue ) ;
		 break; 
	case 1 : ms$onoff( msg = &msg, type = MS_ON , prevstate = &lastvalue ) ;
		 break; 
	case 2 : ms$onoff( msg = &msg, type = MS_SET, prevstate = &lastvalue,
			   setstate = lastvalue ) ;
		 break; 
	default: msg = MSFAIL ;
 }

 i_cival( func->paramlist[0] ) = msg == MSSUCC ;
 return ISUCCESS ;
}

int cimemcpy(func)
struct ci_instruction *func;
/*
 * memory copy
 */
{
	int i1, i2, i3;

	i1 = func->paramlist[1];
	i2 = func->paramlist[2];
	i3 = func->paramlist[3];

	p_cival(func->paramlist[0]) =
		 memcpy(st_cival(i1),st_cival(i2),i_cival(i3));

	return ISUCCESS ;
}

/*-------------------- string manipulations --------------------*/
int cistrcmp(func)
struct ci_instruction *func;
/*
 * string comparison
 */
{
	int i1, i2;

	i1 = func->paramlist[1];
	i2 = func->paramlist[2];

	i_cival(func->paramlist[0]) = strcmp(st_cival(i1),st_cival(i2));  

	return ISUCCESS ;
}

int cistrlen(func)
struct ci_instruction *func;
/*
 * string length
 */
{
	int i1;

	i1 = func->paramlist[1];
	i_cival(func->paramlist[0]) = strlen(st_cival(i1));  

	return ISUCCESS ;
}

int cistrcpy(func)
struct ci_instruction *func;
/*
 * string copy
 */
{
	int i1, i2;

	i1 = func->paramlist[1];
	i2 = func->paramlist[2];

	strcpy(st_cival(i1),st_cival(i2));  
	p_cival(func->paramlist[0]) = st_cival(i1);

	return ISUCCESS ;
}

int cistrcat(func)
struct ci_instruction *func;
/*
 * string concatenate
 */
{
	int i1, i2;

	i1 = func->paramlist[1];
	i2 = func->paramlist[2];

	strcat(st_cival(i1),st_cival(i2));  
	p_cival(func->paramlist[0]) = st_cival(i1);

	return ISUCCESS ;
}


#argsused
int cimy_id(func, codata, runparms, state )
struct ci_instruction	*func;
CIco_resp		*codata	;
CIruntime		*runparms ;
short			*state	;
/*
 * Returns the id of the currently active (executing) ci object.
 */
{
#ifdef DEBUG
printf("in cimy_id(), ci_id = %d, ci_data = %d, ci_data_varvaltable = %d\n",
		codata->ci_id, ci_data,  ci_data_varvaltable );
#endif
	o_cival(func->paramlist[0]) = codata->ci_id;
	return ISUCCESS ;
}

int cimy_os( func )

struct ci_instruction *func ;
/*
 * Returns OM_Gw_TransOSnum_0: the transient object space number where all ci
 * objects live.
 */
{

	s_cival( func->paramlist[0] ) = OM_Gw_TransOSnum_0 ;
	return ISUCCESS ;
}

int cisender_id(func)
struct ci_instruction *func;
/*
 * Returns the id of the object which requested the execution of the PPL file.
 */
{
	o_cival(func->paramlist[0]) = CI_IGE->sender_id;
	return ISUCCESS ;
}

#argsused
int cici_clonage( func, codata, runparms, state )
struct ci_instruction	*func		;
CIco_resp		*codata		;
CIruntime		*runparms	;
short			*state		;
/*
 * returns ci_clonage
 */
{
	long CIsts ;

	i_cival(func->paramlist[0]) =
		 ci_clonage(	&CIsts, 
				o_cival(func->paramlist[1]),
				st_cival(func->paramlist[2]),
				codata->ci_id,
				OM_Gw_TransOSnum_0 );
	return ISUCCESS ;
}

