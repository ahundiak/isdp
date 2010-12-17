/****************************************************************
Copyright (c) 1990 and 1991
Intergraph Corporation; All Rights Reserved
Including Application Programs, File Formats, and Visual Displays

File:		create_cat.h

Purpose: 	This header file contains the default attribute
	information for the 10 writeable system attributes and
	the redline catalog D_COLOR attribute.

Author:	Jeff Silvaggi

Date:	01-03-91

Change History:
**********************************************************************/

#ifdef DMI
/* this is the template for the DM series redline catalog */

#define redline_size 462

#define redline_attrs 14

static char *redline_data="n_itemname\n\
char(22)\n\
Item Name\n\
n_itemrev\n\
char(15)\n\
Revision\n\
n_itemdesc\n\
char(40)\n\
Description\n\
n_aclno\n\
integer\n\
ACL Number\n\
n_versionlimit\n\
integer\n\
Version Limit\n\
n_iconno\n\
integer\n\
Icon Number\n\
n_filetype\n\
char(5)\n\
File Type\n\
n_cisano\n\
integer\n\
Storage Location\n\
n_cosano\n\
integer\n\
Check Out Location\n\
n_cofilename\n\
char(14)\n\
Local Filename\n\
n_detitemno\n\
integer\n\
Detail File ItemNo\n\
n_detfileno\n\
integer\n\
Detail File FileNo\n\
n_redlayerno\n\
integer\n\
Redline layer numb\n\
d_color\n\
integer\n\
d_color\n";

#else
/* this is the template for the old redline catalogs. */

#define redline_size 344

#define redline_attrs 11

static char *redline_data="n_itemname\n\
char(22)\n\
Item Name\n\
n_itemrev\n\
char(15)\n\
Revision\n\
n_itemdesc\n\
char(40)\n\
Description\n\
n_aclno\n\
integer\n\
ACL Number\n\
n_versionlimit\n\
integer\n\
Version Limit\n\
n_iconno\n\
integer\n\
Icon Number\n\
n_filetype\n\
char(5)\n\
File Type\n\
n_cisano\n\
integer\n\
Storage Location\n\
n_cosano\n\
integer\n\
Check Out Location\n\
n_cofilename\n\
char(14)\n\
Local Filename\n\
d_color\n\
integer\n\
d_color\n";
#endif
