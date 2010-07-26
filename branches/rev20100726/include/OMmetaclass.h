/*
-------------------------------------------------------------------------------

	Name:			OMmetaclass.h
	Author:			Chuck Puckett
	Creation Date:		14-oct-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	 This file defines some interesting metaclass values.

	Revision History:

cgp001	12-nov-1985	Add objspaces, MOSD's, ordered relations
cgp002	18-nov-1985	Reserve Root methods.
geo001  20-mar-1987	Add new metaclasses for inclusion of dict.o 
			into libOM.o
ems001  31-may-1988     Remove OMSymCon, OMNamObjDir, and OMdirectory.
rme001	16-may-1989	Remove DIbobpt
-------------------------------------------------------------------------------
*/

#ifndef	OM_D_METACLASS
#define	OM_D_METACLASS

/* define some values for Root */

#define OM_KS_ROOT_CLASS			"Root"
#define OM_K_ROOT_ACTCLASSID		0

/* define the methods indices that everybody does */

#define OM_K_OMCLUSTER_ACTCLASSID	1

#define OM_K_OMISO_ACTCLASSID		2

#define OM_K_OMOBJSPACE_ACTCLASSID	4

#define OM_K_OMMOSDOS_ACTCLASSID	5

#define OM_K_OMTRANSOS_ACTCLASSID	6

#define OM_K_OMFILEDOS_ACTCLASSID	7

#define OM_K_OMMOSD_ACTCLASSID		8

#define OM_K_OMGROUP_ACTCLASSID		10

#define OM_K_OMOSCO_ACTCLASSID		11

#define OM_K_OMINDEX_ACTCLASSID		12

#define OM_K_OMBTREE_ACTCLASSID		13

#define OM_K_OMLNKBTREE_ACTCLASSID	14

#define OM_K_OMRTREE_ACTCLASSID		16

#define OM_K_OMTAG_ACTCLASSID           29

#define OM_K_OMTAGCON_ACTCLASSID        30

#define OM_K_OMSUPGROUP_ACTCLASSID	31

#define OM_K_IGRDIR_ACTCLASSID          32

#define OM_K_DILINK_ACTCLASSID          33

#define OM_K_GROUP_ACTCLASSID           34

#define OM_K_GROUPS_ACTCLASSID          35

#define OM_K_DISTORAGE_ACTCLASSID       36

#define OM_K_DIBTREE_ACTCLASSID         37

#define OM_K_DIBST_ACTCLASSID           38

#define OM_K_DIBSTOB_ACTCLASSID         40

#define OM_K_DIBSTGR_ACTCLASSID         41

#define OM_K_DIMASTER_ACTCLASSID        42

#define OM_K_DIRECTORY_ACTCLASSID       43

#define OM_K_DIROOT_ACTCLASSID          44

#endif
