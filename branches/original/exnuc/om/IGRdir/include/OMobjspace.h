/*
-------------------------------------------------------------------------------

	Name:			OMobjspace.h
	Author:			Chuck Puckett
	Creation Date:		14-oct-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	This file contains OS (object space) structure definitions, etc.

	Revision History:

cgp001	16-nov-1985	Add OS send depth.
cgp002	17-nov-1985	Make init count differ from current count. Change
			arglist to add extend count.
cgp003	26-nov-1985	Help make OS's real classes.
cgp004	19-jan-1986	ISO support.
cgp005	11-jun-1986	OM 4.0
-------------------------------------------------------------------------------
*/

#ifndef	OM_D_OBJSPACE
#define	OM_D_OBJSPACE	1
#endif

/*===================================================================
   Macro to determine if a target class is an ancestor of the
   class pointed to by the p_acld, and if so
   to find the offset of the instance data for the target class.
   If sts = 1, target is a descendant and offset is set.
   If sts = 2, target is not a descendant (offset is not set).
====================================================================*/

#define FIND_ANC_OFFSET(STS,P_ACLD,TARGET_CLASS,OFFSET)\
	{ register OMuint base,disp,transmap_index;\
          base = (P_ACLD)->w_baseclass;\
	  disp = (TARGET_CLASS) - base;\
          if( ((TARGET_CLASS) < base ) ||\
	      ((TARGET_CLASS) > (P_ACLD)->w_maxclass )) \
		{ (OFFSET) = (OMuint) -1; (STS) = 2; }\
	  else if ( (P_ACLD)->p_transmap[disp] == OM_K_NULL_TRANS )\
		{ (OFFSET) = (OMuint) -1; (STS) = 2; }\
	  else {transmap_index = (P_ACLD)->p_transmap[disp];\
	       (OFFSET) = (P_ACLD)->MsgMap[transmap_index].offset;(STS) = 1;}\
	}

/*=======================================*/
/* Macro to set an arg to a user value   */
/* or default if the user value is null. */
/*=======================================*/
#define SETARG(ARG,USER,DEFTRANS,DEFFILED,DEFMOSDOS) \
  if (USER == 0) \
  {  if (trans_decen) ARG = DEFTRANS;\
     else if (filed_decen) ARG = DEFFILED;\
     else if(mosdos_decen) ARG = DEFMOSDOS;\
  }\
  else\
    ARG = USER;
