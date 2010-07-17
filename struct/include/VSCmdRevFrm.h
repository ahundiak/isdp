/* $Id: VSCmdRevFrm.h,v 1.2 2001/02/27 18:25:24 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:       struct/include/VSCmdRevFrm.h
 *
 * Description: Command Class for "Review Structural Objects" command.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSCmdRevFrm.h,v $
 *      Revision 1.2  2001/02/27 18:25:24  ramarao
 *      Modifications to add object id search.
 *
 *      Revision 1.1  2001/02/25 19:19:31  ramarao
 *      Created "Review Structural Objects" command.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/25/01        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

#ifndef vd_revobj_include
#define vd_revobj_include

#define PCMK_SEARCH     0
#define NAME_SEARCH	1
#define OBJID_SEARCH	2

#define SEARCH_PLATES	0x0001
#define SEARCH_BEAMS	0x0002
#define STRUCT_AUTO_FIT 0x0004
#define CHILD_AUTO_FIT	0x0008

#define G_MESSAGE	10
#define G_STRUCT_LIST   12
#define G_EVENT		14
#define G_SEARCH_PCMK	15
#define G_SEARCH_TYPE	16
#define G_PLATES	18
#define G_BEAMS		19
#define G_PREVIOUS	20
#define G_NEXT		21
#define G_STRUCT_FIT	22
#define G_STRUCT_WINDOW 23
#define G_STRUCT_AUTO	24
#define G_CHILD_LIST	26
#define G_CHILD_TYPE	27
#define G_CHILD_FIT	28
#define G_CHILD_WINDOW  29
#define G_CHILD_AUTO	30
#define G_MACRO_SEARCH  31
#define G_VALIDATE	32

#endif
