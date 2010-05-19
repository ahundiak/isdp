/* $Id: VDintf_rev.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDintf_rev.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDintf_rev.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/08/04  16:55:42  pinnacle
 * Created: vdinclude/VDintf_rev.h by jwfrosch for vds
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/


#ifndef VDintf_rev_include

#define VDintf_rev_include

/*
Name
        VDintf_rev.h

Description
        This file contains a structure used by the VDintf command object
        that replaces the regular "Analyze Interference" command.

*/
union state
{
  unsigned char		byt_stat[4];
  unsigned int		int_stat;
};

#define	MAX_NAME_LEN	80

struct VDintf_info
{
  struct GRid		intf;
  struct GRobj_env	tmp1;
  struct GRobj_env	tmp2;
  struct GRsymbology	symb1;
  struct GRsymbology	symb2;
  char                  name1  [MAX_NAME_LEN];
  char                  name2  [MAX_NAME_LEN];
  char                  objinf1[MAX_NAME_LEN];
  char                  objinf2[MAX_NAME_LEN];

  union  state		STATE;
};

#endif
