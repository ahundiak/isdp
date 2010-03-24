/*
---------------------------------------------------------------------------

	Name:			OMparameters.h
	Author:			Chuck Puckett
	Creation Date:		oct-14-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	 This file contains names of and default values for OM runtime
	 parameters.

	Revision History:

cgp001	31-oct-1985	Add CONSISTENT flag

cgp002	14-nov-1985	Add OS parameters. Add version dependency
			parameters.
cgp003	26-nov-1985	Take out "KS" of names of parameters,  just
			document
kek001	24-mar-1986	add ISO and ISOdir default initial and extend size
geo001  07-may-1986	add malloc(3X) parameters; fix number of parameters;
			add definition of OM_sd_param_def structure and
			OM_K_DYNAMIC_PARAMETER for OM_set_dynamic_defaults
jaj001  01-jul-1986	added CONSISTENT-CLASS flag

			function
jkm001	18-jul-86	changed os defaults (extsize,numobjs, etc) to cluster0
			and group 0 defaults

geo002	10-nov-86	add swap mode param and list of swap files param

ems001  10-apr-87       add default for tag connect extend size.

rme001  23-apr-87       add defaults for tag record extend size, hash table
                        size, and hash table extend size.

rme002	05-may-87	remove vla_collapse runtime parameter.

geo003  06-jul-87	remove OPL & OPP versions from runtime parameters

geo004	23-jul-87	remove envirfile, consistent & consistent_class
			parameters

geo005	19-aug-87	add tunable parameter: (unit is 512-byte block)
			swap partitions' fixed page size 
			
saw001	20-nov-87	move swap partion & bitmap definitions to
			OMminimum.h

geo006	09-dec-87	remove previous swapping parameters
			remove cluster initial and extend size parameters
			make default trans group extend size same as
					group's initial number of objs

cgp004	14-dec-1987	add some CCCP process private parameters

geo007  22-feb-1988	add get statistics parameter

saw002  29-def-1992	Undo a lot of the remaining CCCP support for NT.
                        No OM regions.  Already no shared memory.  Only
			concept of slots remains.
---------------------------------------------------------------------------
*/

#ifndef	OM_D_PARAMETERS
#define	OM_D_PARAMETERS
#ifndef	OM_D_MOSD
#include 	"OMMOSD.h"
#endif
#include	"OMlimits.h"


/*	Note:	maxOS is now MAX_MODULES + MAX_INVIS_MODULES */
#define	OM_K_MAXOSNUMBER	65535

/*	"MAX_MODULES"	maximum number of modules */
#define	OM_K_DEF_MAX_MODULES	1

/*	"MAX_REF_FILES"	maximum number reference files */
#define	OM_K_DEF_MAX_REF_FILES	50

/*	 "DEFTRANS_CLUSTER_EXTSIZE" default extend size*/
#define OM_K_DEFTRANS_CLUSTER_EXTSIZE   (OMuint)4*1024		/* make it 4K bytes */

/*	 "DEFFILED_CLUSTER_EXTSIZE" default extend size*/
#define OM_K_DEFFILED_CLUSTER_EXTSIZE   (OMuint)4*1024		/* make it 4K bytes */

/* 	 "DEFTRANS_GROUP_NUMOBJS" default init number of objects */
#define OM_K_DEFTRANS_GROUP_NUMOBJS     (OMuint) 256

/*	 "DEFFILED_GROUP_NUMOBJS" default init number of objects */
#define OM_K_DEFFILED_GROUP_NUMOBJS     (OMuint) 8192

/* 	 "DEFTRANS_GROUP_EXTOBJS" default extend  of objects */
#define OM_K_DEFTRANS_GROUP_EXTOBJS     (OMuint) 256

/* 	 "DEFFILED_GROUP_EXTOBJS" default extend #  of objects */
#define OM_K_DEFFILED_GROUP_EXTOBJS     (OMuint) 1024

/*	"MAXCHAN_SIZE"	max number of entries in channel */
#define OM_K_MAXCHAN_SIZE		200000

/*	"DEFCHAN_SIZE"	def initial size for m-m 1-m channel */
#define OM_K_DEFCHAN_SIZE		1

/*	"DEFCHAN_EXT"	def. extend size for m-m 1-m channel */
#define OM_K_DEFCHAN_EXT		10

/*	"DEFISO_SIZE"	default initial number of entries in an ISO */
#define OM_K_DEFISO_SIZE	32

/*	"DEFISO_EXT"	default extend size for ISO entries */
#define OM_K_DEFISO_EXT		32

/*	"DEFISODIR_SIZE" default initial size of ISOdir */
#define OM_K_DEFISODIR_SIZE	32

/*	"DEFISODIR_EXT"	default extend size for ISOdir */
#define OM_K_DEFISODIR_EXT	32

/*  Default and extend sizes for symbolic connect symbol table.  */

#define OM_K_SYMTABLE_EXT_SIZE  15

/* used by default MOSD OS definitions; not itself a runtime parameter */
#define  OM_K_APPR_OBJSPACE_OBJ_SIZE  5*1024

/* 	"DEFMOSD_NUMOBJS" default number of objects in MOSD OS */
#define OM_K_DEFMOSD_NUMOBJS	10		/* OS object & MOSD */

/*	"DEFMOSD_EXTOBJS" default number of objects to extend MOSD OS by */
#define OM_K_DEFMOSD_EXTOBJS	-1


/* some flags ... */

/*	"MAKEDEF_TRANSOS"	*/
/* 	whether or not to make the OM_TransOS_0 default transient OS */
/*	This is defaulted as TRUE */

/*	"BUGCHECK_FATAL"	*/
/* 	whether internal inconsistencies cause OM to belly up after a message
 	by core dumping */
/*	This is defaulted as TRUE */


#define OM_K_VERBOSE_WARNING	1	/* whether or not OM prints out
					   warning messages on stdout */

#define OM_K_MIN_CACHING_SEND	2	/* method ptr cache in channel send
					   is used only if the number of
					   objects on the channel exceeds
					   this number */

#define OM_K_TAGCON_DEF_EXT_SIZE 100    /* Default extend size for tag */
                                        /*  connect vla                */

#define OM_K_TAG_DEF_EXT_SIZE 1023       /* Default extend size for tag */
                                        /* record vla.                 */

#define OM_K_TAG_DEF_HASH_SIZE 1023      /* Default size of hash table for */
                                        /* tag records.                   */

#define OM_K_TAG_DEF_HASH_EXT_SIZE 1023  /* Default number of entries to   */
                                        /* be allocated to the free list  */
                                        /* of hash entries.               */

#define	OM_K_LCF_QUEUEDEPTH	-1	/* how deep to search last cluster
					   faulted queue when autoclustering */
					   
#define	OM_K_TAGGINGENABLED	0	/* allows or disallows tagged objs */

#define	OM_K_ERRTOSTDOUT	0	/* sends err to stdout (o/w to stderr */

#define	OM_K_PERCENT_EXTEND_TAG	20	/* percent growth of tagged thinngy */

#define	OM_K_PHYCLUSTERSIZE	60*512

#if defined (NT)
#define OM_K_NUMBER_PARAMETERS	36	/* Bump this whenever you add */
#else
#define OM_K_NUMBER_PARAMETERS	43	/* Bump this whenever you add */
#endif
					/* a parameter definition */

#define OM_K_DYNAMIC_PARAMETER	1	/* this parameter may be changed dynamically */

#define	P_INTEGER		1
#define	P_STRING		2
#define	P_UINT			4
#define	P_WORD			5
#define	P_UWORD			6
#define	P_CHAR			7

#define	PD_DEC			1
#define	PD_OCT			2
#define	PD_HEX			3
#define	PD_CHAR			4
#define	PD_STR			5
#define	PD_BOOL			6
#define	PD_PERCENT		7

struct OM_sd_param_def
{
  char		s_name[64];
  OMuint	i_namelen;
  OMuint	*p_variable;
  int		i_minval;
  int		i_maxval;
  uword		w_dynamic;
  uword         w_type;
  int           i_display;
};

#endif
