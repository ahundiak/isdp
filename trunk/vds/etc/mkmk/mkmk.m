/* $Id: mkmk.m,v 1.1 2001/05/17 14:36:37 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdbin/vdbin.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: mkmk.m,v $
 *	Revision 1.1  2001/05/17 14:36:37  ahundiak
 *	*** empty log message ***
 *	
# Revision 1.1  2000/12/06  15:14:48  pinnacle
# ah
#
# Revision 1.1  2000/12/01  14:07:52  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/29/00  ah      Creation
 *
 * -------------------------------------------------------------------*/

SOURCE
mkmk.c
exfilnam.c
fget_atom.c
fget_str.c
fread_input.c
ignore.c
is_file.c
make_rules.c
red_fname.c
reduce_pth.c
str_malloc.c
version.c
toolshash.c


EXEC
mkmk

LINKLIB
-lmalloc


INCLUDE
$EXNUC/include


