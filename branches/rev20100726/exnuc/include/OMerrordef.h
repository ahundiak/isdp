/*
-------------------------------------------------------------------------------

	Name:			OMerrordef.h
	Author:			Chuck Puckett
	Creation Date:		15-aug-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	 This file contains OM error definitions by symbol. These symbols
	 are of the form:

			OM_E_errorname

	 where "errorname" is the name of the error. When this file is
	 included in a module where the symbol OM_D_DEFINE_ERRMSG is
	 defined, then both the error symbols and a set of error messages
	 are created. The error messages are then known by a symbol:

			OM_erm_errorname

	 where "errorname" is the same as in OM_E_errorname.

	 Note that OM error codes follow OSA standards,  where:

	 bits <0-2>:	severity
			0	warning
			1	success
			2	error
			3	information
			4	severe (fatal) error
			5-7	undefined

	 bits <3-15>	message number (bit 15 set, since facility spec.)

	 bits <16-26>	facility (OM)

	Revision History:

cgp001	14-oct-1985	made includes check before including to speed up
			compile. Made flags "defined". Bit fields on struct
			to avoid compiler woes.

cgp002	12-nov-1985	Add new defns.

jaj001  07-jul-1986	Added OM_E_CLASS_CHKSUM_MISMATCH warning.

saw001	18-jan-1988	Added OM_F_OUT_OF_SWAP_SPACE.

-------------------------------------------------------------------------------
*/

#ifndef	OM_D_ERRORDEF
#define	OM_D_ERRORDEF	1

#ifndef	OM_FACILITY_CODE
#define	OM_FACILITY_CODE	0x250
#endif

#ifndef WARN
#define	WARN	0
#endif
#ifndef SUCC
#define	SUCC	1
#endif
#ifndef ERRO
#define	ERRO	2
#endif
#ifndef INFO
#define	INFO	3
#endif
#ifndef SEVE
#define	SEVE	4
#endif
#ifndef SEV_LEV
#define SEV_LEV	7
#endif

/*
-------------------------------------------------------------------------------

	Now we define the OM error symbols and messages.

-------------------------------------------------------------------------------
*/

#define OM_S_SUCCESS	1

#define OM_E_OBJECT_LOCKED (OM_FACILITY_CODE << 16)+0X8000+(1 << 3)+ERRO
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_OBJECT_LOCKED[]=
{"OM-E-OBJECT_LOCKED, Message attempt to object with locked instance data\n"};
#endif

#define OM_W_UNKNOWN_MSG (OM_FACILITY_CODE << 16)+0X8000+(2 << 3)+WARN
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_UNKNOWN_MSG[]=
{"OM-W-UNKNOWN_MSG, Unknown message send attempted\n"};
#endif

#define OM_E_OBJECT_OVERSIZED (OM_FACILITY_CODE << 16)+0X8000+((3) << 3)+(ERRO)
#ifdef  OM_DEFINE_ERRMSG
static char OM_E_erm_OBJECT_OVERSIZED[]=
{"OM-E-OBJECT_OVERSIZED, Object's size is greater than swap page size."};
#endif
	
#define OM_I_STOP_SENDING (OM_FACILITY_CODE << 16)+0X8000+((4) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_STOP_SENDING[]=
{"OM-I-STOP_SENDING, Object found - stopped sending to channel\n"};
#endif

#define OM_E_NO_RELATION (OM_FACILITY_CODE << 16)+0X8000+((5) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_NO_RELATION[]=
{"OM-E-NO_RELATION, Channel send attempted with no relation connected\n"};
#endif

#define OM_F_BUGCHECK (OM_FACILITY_CODE << 16)+0X8000+((6) << 3)+(SEVE)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_BUGCHECK[]=
{"OM-F-BUGCHECK, OM fatal internal inconsistency.\n"};
#endif

#define OM_E_NOTIMPL (OM_FACILITY_CODE << 16)+0X8000+((7) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_NOTIMPL[]=
{"OM-E-NOTIMPL, Functionality not implemented\n"};
#endif

#define OM_E_NODYNMEM (OM_FACILITY_CODE << 16)+0X8000+((8) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_NODYNMEM[]=
{"OM-E-NODYNMEM, No dynamic memory available\n"};
#endif

#define OM_W_CLASS_EXISTS (OM_FACILITY_CODE << 16)+0X8000+((9) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_CLASS_EXISTS[]=
{"OM-w-CLASS_EXISTS, Class already exists\n"};
#endif

#define OM_E_NOPARENT (OM_FACILITY_CODE << 16)+0X8000+((10) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_NOPARENT[]=
{"OM-E-NOPARENT, No parent for class; class was not created\n"};
#endif

#define OM_E_BADCLASSNAME (OM_FACILITY_CODE << 16)+0X8000+((11) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_BADCLASSNAME[]=
{"OM-E-BADCLASSNAME, Class name is ill-formed\n"};
#endif

#define OM_E_TOOMANYCLASSES (OM_FACILITY_CODE << 16)+0X8000+((12) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_TOOMANYCLASSES[]=
{"OM-E-TOMMANYCLASSES, Class def attempted for more classes than specified\n"};
#endif

#define OM_E_NO_OBJECT_SPACE (OM_FACILITY_CODE << 16)+0X8000+((13) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_NO_OBJECT_SPACE[]=
{"OM-E-NO_OBJECT_SPACE, No object space available for this instance\n"};
#endif

#define OM_E_NOSUCHCLASS (OM_FACILITY_CODE << 16)+0X8000+((14) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_NOSUCHCLASS[]=
{"OM-E-NOSUCHCLASS, No such class exists\n"};
#endif

#define OM_E_REL_MISMATCH (OM_FACILITY_CODE << 16)+0X8000+((15) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_REL_MISMATCH[]=
{"OM-E-REL_MISMATCH, Relation create attempted on mismatched objects\n"};
#endif

#define OM_E_CHAN_OVERFLOW (OM_FACILITY_CODE << 16)+0X8000+((16) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_CHAN_OVERFLOW[]=
{"OM-E-CHAN_OVERFLOW, Attempt to connect more than MAXCHAN_SIZE objects\n"};
#endif

#define OM_E_INVCHAN (OM_FACILITY_CODE << 16)+0X8000+((17) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_INVCHAN[]=
{"OM-E-INVCHAN, Attempt to create or access object with invalid channel\n"};
#endif

#define OM_E_NOSUCHOBJ (OM_FACILITY_CODE << 16)+0X8000+((18) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_NOSUCHOBJ[]=
{"OM-E-NOSUCHOBJ, No such object exists\n"};
#endif

#define OM_E_CHAN_NOTEMPTY (OM_FACILITY_CODE << 16)+0X8000+((19) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_CHAN_NOTEMPTY[]=
{"OM-E-CHAN_NOTEMPTY, Connect attempted on already connected channel\n"};
#endif

#define OM_I_CHAN_EMPTY (OM_FACILITY_CODE << 16)+0X8000+((20) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_CHAN_EMPTY[]=
{"OM-I-CHAN_EMPTY, Operation attempted on empty channel\n"};
#endif

#define OM_W_NOTONCHAN (OM_FACILITY_CODE << 16)+0X8000+((21) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_NOTONCHAN[]=
{"OM-W-NOTONCHAN, Object is not on channel\n"};
#endif

#define OM_I_LISTOVFLOW (OM_FACILITY_CODE << 16)+0X8000+((22) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_LISTOVFLOW[]=
{"OM-I-LISTOVFLOW, Not enough space in list\n"};
#endif

#define OM_E_INVARG (OM_FACILITY_CODE << 16)+0X8000+((23) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_INVARG[]=
{"OM-E-INVARG, Invalid argument specified in call\n"};
#endif

#define OM_I_OBJONCHAN (OM_FACILITY_CODE << 16)+0X8000+((24) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_OBJONCHAN[]=
{"OM-I-OBJONCHAN, Object already on channel\n"};
#endif

#define OM_I_RELVANISHED (OM_FACILITY_CODE << 16)+0X8000+((25) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_RELVANISHED[]=
{"OM-I-RELVANISHED, Relation vanished during a 1-m relation compression\n"};
#endif

#define OM_F_VERSION_MISMATCH (OM_FACILITY_CODE <<16)+0X8000+((26) << 3)+(SEVE)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_VERSION_MISMATCH[]=
{"OM-F-VERSION_MISMATCH, Version mismatch between major OM components.\n"};
#endif

#define OM_W_OBJSPACE_EXISTS (OM_FACILITY_CODE <<16)+0X8000+((27) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_OBJSPACE_EXISTS[]=
{"OM-W-OBJSPACE_EXISTS, Object Space already exists.\n"};
#endif

#define OM_E_NO_OS_AVAIL (OM_FACILITY_CODE <<16)+0X8000+((28) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_NO_OS_AVAIL[]=
{"OM-E-NO_OS_AVAIL, No Object Space descriptor available.\n"};
#endif

#define OM_I_DEFER_SUCCESS (OM_FACILITY_CODE <<16)+0X8000+((29) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_DEFER_SUCCESS[]=
{"OM-I-DEFER_SUCCESS, Deferred Success on object delete.\n"};
#endif

#define OM_E_INVALIDRANGE (OM_FACILITY_CODE <<16)+0X8000+((30) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_INVALIDRANGE[]=
{"OM-E-INVALIDRANGE, Invalid range specified on send to ordered relation.\n"};
#endif

#define OM_E_NOSUCHOS (OM_FACILITY_CODE <<16)+0X8000+((31) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_NOSUCHOS[]=
{"OM-E-NOSUCHOS, No such Object Space exists.\n"};
#endif

#define OM_E_IOERR (OM_FACILITY_CODE <<16)+0X8000+((32) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_IOERR[]=
{"OM-E-IOERR, I/O error occurred on operation.\n"};
#endif

#define OM_E_INCONOIDS (OM_FACILITY_CODE <<16)+0X8000+((33) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_INCONOIDS[]=
{"OM-E-INCONOIDS, Filed OS was written by different Object ID mechanism.\n"};
#endif

#define OM_E_INCONOPSYS (OM_FACILITY_CODE <<16)+0X8000+((34) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_INCONOPSYS[]=
{"OM-E-INCONOPSYS, Filed OS written by different operating system.\n"};
#endif

#define OM_E_INCONCPUS (OM_FACILITY_CODE <<16)+0X8000+((35) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_INCONCPUS[]=
{"OM-E-INCONCPUS, Filed OS written by different CPU.\n"};
#endif

#define OM_E_INVOSHDR (OM_FACILITY_CODE <<16)+0X8000+((36) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_INVOSHDR[]=
{"OM-E-INVOSHDR, Filed OS has invalid header.\n"};
#endif

#define OM_E_NOSUCHREL (OM_FACILITY_CODE <<16)+0X8000+((37) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_NOSUCHREL[]=
{"OM-E-NOSUCHREL, No such relation exists.\n"};
#endif

#define OM_E_BADSTATE (OM_FACILITY_CODE <<16)+0X8000+((38) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_BADSTATE[]=
{"OM-E-BADSTATE, OS is in invalid state for operation.\n"};
#endif

#define OM_I_ADDEDATEND (OM_FACILITY_CODE <<16)+0X8000+((39) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_erm_ADDEDATEND[]=
{"OM-I-ADDEDATEND, Object added at end of ordered relation.\n"};
#endif

#define OM_E_MSGNOTSUPP (OM_FACILITY_CODE << 16)+0X8000+((41) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_MSGNOTSUPP[]=
{"OM-E-MSGNOTSUPP, Message either not supported or refused\n"};
#endif

#define OM_E_NOEXTEND (OM_FACILITY_CODE << 16)+0X8000+((42) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NOEXTEND[]=
{"OM-E-NOEXTEND, Attempt to extend channel with zero extend size\n"};
#endif

#define OM_W_NOTORDERED (OM_FACILITY_CODE << 16)+0X8000+((43) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_W_erm_NOTORDERED[]=
{"OM-W-NOTORDERED, Operation valid on ordered channels only\n"};
#endif

#define OM_E_NAMETOOLONG (OM_FACILITY_CODE << 16)+0X8000+((44) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NAMETOOLONG[]=
{"OM-E-NAMETOOLONG, Length of name exceeds maximum length allowed\n"};
#endif

#define OM_W_WARNING (OM_FACILITY_CODE << 16)+0X8000+((45) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_W_erm_WARNING[]=
{"OM-W-WARNING, Generic warning message\n"};
#endif

#define OM_E_ERROR (OM_FACILITY_CODE << 16)+0X8000+((46) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_ERROR[]=
{"OM-E-ERROR, Generic error message\n"};
#endif

#define OM_E_BADCLASS (OM_FACILITY_CODE << 16)+0X8000+((47) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_BADCLASS[]=
{"OM-E-BADCLASS, This class cannot do this OM primitive/message\n"};
#endif

#define OM_W_INDEXEMPTY (OM_FACILITY_CODE << 16)+0X8000+((48) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_W_erm_INDEXEMPTY[]=
{"OM-W-INDEXEMPTY, Index within an ordered channel was empty\n"};
#endif

#define OM_I_FILEOVRWRTN (OM_FACILITY_CODE << 16)+0X8000+((49) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_I_erm_FILEOVRWRTN[]=
{"OM-I-FILEOVRWRTN, OS written over file that had existed under given name\n"};
#endif

#define OM_W_ISODIRONOS (OM_FACILITY_CODE << 16)+0X8000+((50) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_W_erm_ISODIRONOS[]=
{"OM-W-ISODIRONOS, ISO directory linked to OS, name change denied\n"};
#endif

#define OM_E_NOEXTEND_OS (OM_FACILITY_CODE << 16)+0X8000+((51) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NOEXTEND_OS[]=
{"OM-E-NOEXTEND_OS, Attempt to extend an Object Space with zero extend count\n"};
#endif

#define OM_E_OS_ALLOC (OM_FACILITY_CODE << 16)+0X8000+((52) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_OS_ALLOC[]=
{"OM-E-OS_ALLOC, Error allocating dynamic memory for extended OS spacemap\n"};
#endif

#define OM_I_INVANCESTRY (OM_FACILITY_CODE << 16)+0X8000+((53) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_I_erm_INVANCESTRY[]=
{"OM-I-INVANCESTRY, Invalid class ancestry detected\n"};
#endif

#define OM_I_NOPARENT (OM_FACILITY_CODE << 16)+0X8000+((54) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_I_erm_NOPARENT[]=
{"OM-I-NOPARENT, No parent exists for class\n"};
#endif

#define OM_E_FILEEXISTS (OM_FACILITY_CODE << 16)+0X8000+((55) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_FILEEXISTS[]=
{"OM-E-FILEEXISTS, New name for OS represents an existing file\n"};
#endif

#define OM_W_OSNOTACTIVE (OM_FACILITY_CODE << 16)+0X8000+((56) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_W_erm_OSNOTACTIVE[]=
{"OM-W-OSNOTACTIVE, Attempt to access an object in a nonactive Object Space\n"};
#endif

#define OM_W_USE_ISO_IF (OM_FACILITY_CODE << 16)+0X8000+((57) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_W_erm_USE_ISO_IF[]=
{"OM-W-USE_ISO_IF, Use the ISO interface for proper (osnum,objid) output\n"};
#endif

#define OM_E_DIREXISTS (OM_FACILITY_CODE << 16)+0X8000+((58) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_DIREXISTS[]=
{"OM-E-DIREXISTS, The directory already exists\n"};
#endif

#define OM_E_NODIREXISTS (OM_FACILITY_CODE << 16)+0X8000+((59) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NODIREXISTS[]=
{"OM-E-NODIREXISTS, The directory does not exist\n"};
#endif

#define OM_E_INDEXERROR (OM_FACILITY_CODE << 16)+0X8000+((60) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_INDEXERROR[]=
{"OM-E-INDEXERROR, Some indexing error\n"};
#endif

#define OM_E_OIDNAMEINUSE (OM_FACILITY_CODE << 16)+0X8000+((61) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_OIDNAMEINUSE[]=
{"OM-E-OIDNAMEINUSE, Object Name already being used\n"};
#endif

#define OM_E_TOOMANYNAMES (OM_FACILITY_CODE << 16)+0X8000+((62) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_TOOMANYNAMES[]=
{"OM-E-TOOMANYNAMES, Object already has maximum number of names allowed\n"};
#endif

#define OM_W_NAMENOTFOUND (OM_FACILITY_CODE << 16)+0X8000+((63) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_W_erm_NAMENOTFOUND[]=
{"OM-W-NAMENOTFOUND, Name is not found in index\n"};
#endif

#define OM_E_NOINDEXEXISTS (OM_FACILITY_CODE << 16)+0X8000+((64) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NOINDEXEXISTS[]=
{"OM-E-NOINDEXEXISTS, No objects have been named\n"};
#endif

#define OM_E_OIDNOTNAMED (OM_FACILITY_CODE << 16)+0X8000+((65) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_OIDNOTNAMED[]=
{"OM-E-OIDNOTNAMED, This object has not been named\n"};
#endif

#define OM_E_INDEXNOTEMPTY (OM_FACILITY_CODE << 16)+0X8000+((66) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_INDEXNOTEMPTY[]=
{"OM-E-INDEXNOTEMPTY, The index is not empty\n"};
#endif

#define OM_F_SEVERE (OM_FACILITY_CODE << 16)+0X8000+((67) << 3)+(SEVE)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_F_erm_SEVERE[]=
{"OM-F-SEVERE, Generic severe message\n"};
#endif

#define OM_E_CHNSELTYPINV (OM_FACILITY_CODE << 16)+0X8000+((68) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_CHNSELTYPINV[]=
{"OM-E-CHNSELTYPINV, The type in OM_S_CHANSELECT is invalid\n"};
#endif

#define OM_E_EXCEEDFANOUT (OM_FACILITY_CODE << 16)+0X8000+((69) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_EXCEEDFANOUT[]=
{"OM-E-EXCEEDFANOUT, Attempting to connect more than allowed by channel\n"};
#endif

#define OM_E_CLASSNOTANCESTOR (OM_FACILITY_CODE << 16)+0X8000+((70)<< 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_CLASSNOTANCESTOR[]=
{"OM-E-CLASSNOTANCESTOR, Class in CHANSELECT not an ancestor\n"};
#endif

#define OM_E_CHANNOTFOUND (OM_FACILITY_CODE << 16)+0X8000+((71) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_CHANNOTFOUND[]=
{"OM-E-CHANNOTFOUND, Channel in CHANSELECT not found in Class definition\n"};
#endif

#define OM_I_ISAUNION (OM_FACILITY_CODE << 16)+0X8000+((72) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_I_erm_ISAUNION[]=
{"OM-I-ISAUNION, Class specified is a union class\n"};
#endif

#define OM_W_CLASS_CHKSUM_MISMATCH (OM_FACILITY_CODE <<16)+0X8000+((73) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_W_erm_CLASS_CHKSUM_MISMATCH[]=
{"OM_W_CLASS_CHKSUM_MISMATCH, Checksum mismatch between OM classes.\n"};
#endif

#define OM_E_INVINDEX (OM_FACILITY_CODE << 16)+0X8000+((74) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_INVINDEX[]=
{"OM-E-INVINDEX, Index specified was not valid for this channel.\n"};
#endif

#define OM_E_INVCLUSTERID (OM_FACILITY_CODE << 16)+0X8000+((75) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_INVCLUSTERID[]=
{"OM-E-INVCLUSTERID, Invalid cluster id.\n"};
#endif

#define OM_E_MAX_CLUSTERS_ALLOWED (OM_FACILITY_CODE << 16)+0X8000+((77) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_MAX_CLUSTERS_ALLOWED[]=
{"OM-E-MAX_CLUSTERS_ALLOWED, Maximum number of clusters allowed exist.\n"};
#endif

#define OM_E_CLASS_CONFLICT (OM_FACILITY_CODE << 16)+0X8000+((78) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_CLASS_CONFLICT[]=
{"OM-E-CLASS_CONFLICT, Connection of channel to this class not specified.\n"};
#endif

#define OM_I_NO_FREE_OIDS (OM_FACILITY_CODE << 16)+0X8000+((79) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_I_erm_NO_FREE_OIDS[]=
{"OM-I-NO_FREE_OIDS, Group has no free object id numbers.\n"};
#endif

#define OM_E_NO_EXTEND_GROUP (OM_FACILITY_CODE << 16)+0X8000+((80) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NO_EXTEND_GROUP[]=
{"OM-E-NO_EXTEND_GROUP, Group may not be extended and is full.\n"};
#endif

#define OM_E_NOTTREEROOT (OM_FACILITY_CODE << 16)+0X8000+((81) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NOTTREEROOT[]=
{"OM-E-NOTTREEROOT, Attempted to send to page other than root.\n"};
#endif

#define OM_E_NO_DELETE_GROUP (OM_FACILITY_CODE << 16)+0X8000+((82) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NO_DELETE_GROUP[]=
{"OM-E-NO_DELETE_GROUP, It is invalid to delete OMGroup class objects.\n"};
#endif

#define OM_E_NO_DELETE_CLUSTER (OM_FACILITY_CODE << 16)+0X8000+((83) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NO_DELETE_CLUSTER[]=
{"OM-E-NO_DELETE_CLUSTER, It is invalid to delete OMCluster class objects.\n"};
#endif

#define OM_E_AMBIGUOUS_CHANNAME (OM_FACILITY_CODE << 16)+0X8000+((84) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_AMBIGUOUS_CHANNAME[]=
{"OM-E-AMBIGUOUS-CHANNAME, The specified channame must include a class name.\n"};
#endif

#define OM_E_NOPASSPASS (OM_FACILITY_CODE << 16)+0X8000+((85) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NOPASSPASS[]=
{"OM-E-NOPASSPASS, It is invalid to send a pass msg to a pass method\n"};
#endif

#define OM_E_INVSTSTYPE (OM_FACILITY_CODE << 16)+0X8000+((86) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_INVSTSTYPE[]=
{"OM-E-INVSTSTYPE, stattype field in an OM_S_OSSTATUS struct is invalid.\n"};
#endif

#define OM_E_OBJSIZE_TOOBIG (OM_FACILITY_CODE << 16)+0X8000+((87) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_OBJSIZE_TOOBIG[]=
{"OM-E-OBJSIZE_TOOBIG, size of object greater than maximum allowed.\n"};
#endif

#define OM_E_NOEXTEND_GROUP (OM_FACILITY_CODE << 16)+0X8000+((89) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NOEXTEND_GROUP[]=
{"OM-E-NOEXTEND_GROUP, group is not extendable and is full.\n"};
#endif

#define OM_E_ILLEGAL_GROUP0 (OM_FACILITY_CODE << 16)+0X8000+((90) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_ILLEGAL_GROUP0[]=
{"OM-E-ILLEGAL_GROUP0, group zero may not be merged or removed.\n"};
#endif

#define OM_E_DUPGRPNAME (OM_FACILITY_CODE << 16)+0X8000+((91) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_DUPGRPNAME[]=
{"OM-E-DUPGRPNAME, group name is already in use.\n"};
#endif

#define OM_E_DUPCLUSTNAME (OM_FACILITY_CODE << 16)+0X8000+((92) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_DUPCLUSTNAME[]=
{"OM-E-DUPCLUSTNAME, cluster name is already in use.\n"};
#endif

#define OM_E_WRITE_ERROR (OM_FACILITY_CODE << 16)+0X8000+((93) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_WRITE_ERROR[]=
{"OM-E-WRITE-ERROR, an error occurred while attempting to write to a file."};
#endif

#define OM_E_READ_ERROR (OM_FACILITY_CODE << 16)+0X8000+((94) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_READ_ERROR[]=
{"OM-E-READ-ERROR, an error occurred while attempting to read from a file."};
#endif

#define OM_W_SIZE_TOO_SMALL (OM_FACILITY_CODE << 16)+0X8000+((95) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_W_erm_SIZE_TOO_SMALL[]=
{"OM-W-SIZE-TOO-SMALL, the cluster size specified was too small and was\n adjusted upward."};
#endif

#define OM_E_NULL_STRING (OM_FACILITY_CODE << 16)+0X8000+((96) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NULL_STRING[]=
{"OM-E-NULL-STRING, a null string was passed as an argument;\na non null string was expected."};
#endif

#define OM_I_READ_FROM_FILE (OM_FACILITY_CODE << 16)+0X8000+((97) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_I_erm_READ_FROM_FILE[]=
{"OM-I-READ-FROM-FILE, a filed OS was constructed from an existing disk file."};
#endif

#define OM_W_OS_NOT_IN_MOSD (OM_FACILITY_CODE << 16)+0X8000+((98) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_W_erm_OS_NOT_IN_MOSD[]=
{"OM-W-OS-NOT-IN-MOSD, the OS specified is unknown to the MOSD."};
#endif

#define OM_E_NO_DISK_SPACE (OM_FACILITY_CODE << 16)+0X8000+((99) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NO_DISK_SPACE[]=
{"OM-E-NO-DISK-SPACE, the OS specified is too large for its file system."};
#endif

#define OM_E_MOSDOS_OS (OM_FACILITY_CODE << 16)+0X8000+((100) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_MOSDOS_OS[]=
{"OM-E-MOSDOS-OS, the OS specified is the MOSDOS and cannot be deleted."};
#endif

#define OM_E_TRANS_OS (OM_FACILITY_CODE << 16)+0X8000+((101) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_TRANS_OS[]=
{"OM-E-TRANS-OS, the OS specified is transient; request is illogical."};
#endif

#define OM_I_LOGICAL_DISCONNECT (OM_FACILITY_CODE << 16)+0X8000+((102) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_I_erm_LOGICAL_DISCONNECT[]=
{"OM-I-LOGICAL_DISCONNECT, the target object has been logically disconnected"};
#endif

#define OM_E_DUPSYMNAME (OM_FACILITY_CODE << 16)+0X8000+((103) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_DUPSYMNAME[]=
{"OM-E-DUPSYMNAME, attempt to make a symbolic connection with a duplicate name."};
#endif

#define OM_I_UNABLE_TO_CONNECT (OM_FACILITY_CODE << 16)+0X8000+((104) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_I_erm_UNABLE_TO_CONNECT[]=
{"OM-I-UNABLE_TO_CONNECT, a matching connect name was found but no connection was established."};
#endif

#define OM_E_BADCHAN_TYPE (OM_FACILITY_CODE << 16)+0X8000+((105) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_BADCHAN_TYPE[]=
{"OM-E-BADCHAN_TYPE, this type of channel is not allowed in a symbolic connect."};
#endif

#define OM_I_NOMATCH (OM_FACILITY_CODE << 16)+0X8000+((106) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_I_erm_NOMATCH[]=
{"OM-I-NOMATCH, a matching symbolic connect name was not found."};
#endif

#define OM_E_SYMBOLNOTFOUND (OM_FACILITY_CODE << 16)+0X8000+((107) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_SYMBOLNOTFOUND[]=
{"OM-E-SYMBOLNOTFOUND, Unable to find this symbolic connect."};
#endif

#define OM_E_SPECIAL_FILE (OM_FACILITY_CODE << 16)+0X8000+((108) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_SPECIAL_FILE[]=
{"OM-E-SPECIAL-FILE, the OS name specified is a directory or other special file."};
#endif

#define OM_E_INACCESSABLE_FILE (OM_FACILITY_CODE << 16)+0X8000+((109) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_INACCESSABLE_FILE[]=
{"OM-E-INACCESSABLE-FILE, the OS name specified is a bad file name."};
#endif

#define OM_I_NOEXIST_WRITEABLE_FILE (OM_FACILITY_CODE << 16)+0X8000+((110) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_I_erm_NOEXIST_WRITEABLE_FILE[]=
{"OM-I-NOEXIST-WRITEABLE-FILE, the OS name specified is a good file name."};
#endif

#define OM_I_EXIST_READONLY_FILE (OM_FACILITY_CODE << 16)+0X8000+((111) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_I_erm_EXIST_READONLY_FILE[]=
{"OM-I-EXIST-READONLY-FILE, the OS name specified is an old, read only file."};
#endif

#define OM_I_EXIST_READ_WRITE_FILE (OM_FACILITY_CODE << 16)+0X8000+((112) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_I_erm_EXIST_READ_WRITE_FILE[]=
{"OM-I-EXIST-READ-WRITE-FILE, the OS name specified is an old, read/write file."};
#endif

#define OM_I_READ_FROM_RO_FILE (OM_FACILITY_CODE << 16)+0X8000+((113) << 3)+(INFO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_I_erm_READ_FROM_RO_FILE[]=
{"OM-I-READ-FROM-RO-FILE, a filed OS was constructed from a read-only disk file."};
#endif

#define OM_E_FILEISDIR (OM_FACILITY_CODE << 16)+0X8000+((114) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_FILEISDIR[]=
{"OM-E-FILEISDIR, filename represents a directory file."};
#endif

#define OM_E_INTERNALS_CORRUPT (OM_FACILITY_CODE << 16)+0X8000+((117) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_INTERNALS_CORRUPT[]=
{"OM-E-INTERNALS_CORRUPT, internal data structures corrupt."};
#endif

#define OM_E_NOTTAGGED (OM_FACILITY_CODE << 16)+0X8000+((118) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NOTTAGGED[]=
{"OM-E-NOTTAGGED, specified object has no tag."};
#endif

#define OM_E_TAGEXISTS (OM_FACILITY_CODE << 16)+0X8000+((119) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_TAGEXISTS[]=
{"OM-E-TAGEXISTS, specified object is already tagged."};
#endif

#define OM_W_NOTTAGGED (OM_FACILITY_CODE << 16)+0X8000+((120) << 3)+(WARN)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_W_erm_NOTTAGGED[]=
{"OM-W-NOTTAGGED, the specified object is not tagged."};
#endif

#define OM_E_NOSUCHTAG (OM_FACILITY_CODE << 16)+0X8000+((121) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NOSUCHTAG[]=
{"OM-E-NOSUCHTAG, the specified tag does not exist in this os."};
#endif

#define OM_E_NOAVAILABLETAG (OM_FACILITY_CODE << 16)+0X8000+((122) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_NOAVAILABLETAG[]=
{"OM-E-NOAVAILABLETAG, all the tags in the specified os are in use."};
#endif

#define OM_E_BADSENDDEPTH (OM_FACILITY_CODE << 16)+0X8000+((123) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_BADSENDDEPTH[]=
{"OM-E-BADSENDDEPTH, send depth must be zero before an object can be promoted/demoted."};
#endif

#define OM_E_BADPROMCLASS (OM_FACILITY_CODE << 16)+0X8000+((124) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_BADPROMCLASS[]=
{"OM-E-BADPROMCLASS, An object of this class cannot be promoted/demoted."};
#endif

#define OM_E_INTERCEPTED (OM_FACILITY_CODE << 16)+0X8000+((125) << 3)+(ERRO)
#ifdef  OM_DEFINE_ERRMSG
static char OM_E_erm_INTERCEPTED[]=
{"OM-E-INTERCEPTED, Intercept already active."};
#endif

#define OM_W_NOINTERCEPT (OM_FACILITY_CODE << 16)+0X8000+((126) << 3)+(WARN)
#ifdef  OM_DEFINE_ERRMSG
static char OM_W_erm_NOINTERCEPT[]=
{"OM-W-NOINTERCEPT, No intercept active."};
#endif

#define OM_W_NODYNLOAD (OM_FACILITY_CODE << 16)+0X8000+((127) << 3)+(WARN)
#ifdef  OM_DEFINE_ERRMSG
static char OM_W_erm_NODYNLOAD[]=
{"OM-W-NODYNLOAD, An attempt to dynamically load an object file has failed."};
#endif

#define OM_E_NOSUCHMSG (OM_FACILITY_CODE << 16)+0X8000+((127) << 3)+(ERRO)
#ifdef  OM_DEFINE_ERRMSG
static char OM_E_erm_NOSUCHMSG[]=
{"OM-E-NOSUCHMSG, No such message exists."};
#endif

#define OM_W_REJECTED_METHOD (OM_FACILITY_CODE << 16)+0X8000+((129)<< 3)+(WARN)
#ifdef  OM_DEFINE_ERRMSG
static char OM_W_erm_REJECTED_METHOD[]=
{"OM-W-REJECTED_METHOD, You have reached a rejected method."};
#endif

#define OM_E_ABORT (OM_FACILITY_CODE << 16)+0X8000+((131)<< 3)+(ERRO)
#ifdef  OM_DEFINE_ERRMSG
static char OM_E_erm_ABORT[]=
{"OM-E-ABORT, A Non-OM method failed."};
#endif

#define OM_W_ABORT (OM_FACILITY_CODE << 16)+0X8000+((132)<< 3)+(WARN)
#ifdef  OM_DEFINE_ERRMSG
static char OM_W_erm_ABORT[]=
{"OM-W-ABORT, A Non-OM method failed."};
#endif

#define OM_E_FROM_RTREE (OM_FACILITY_CODE << 16)+0X8000+((134)<< 3)+(ERRO)
#ifdef  OM_DEFINE_ERRMSG
static char OM_E_erm_FROM_RTREE[]=
{"OM-E-FROM_RTREE, Error return from rtree."};
#endif

#define OM_E_CYCLEINSUPGROUP (OM_FACILITY_CODE << 16)+0X8000+((137)<< 3)+(ERRO)
#ifdef  OM_DEFINE_ERRMSG
static char OM_E_erm_CYCLEINSUPGROUP[]=
{"OM-E-CYCLEINSUPGROUP, There is a cycle in the SupGroup graph."};
#endif

#define OM_W_NOSUCHMEMBER (OM_FACILITY_CODE << 16)+0X8000+((138)<< 3)+(WARN)
#ifdef  OM_DEFINE_ERRMSG
static char OM_W_erm_NOSUCHMEMBER[]=
{"OM-W-NOSUCHMEMBER, No such member exists in the SupGroup."};
#endif

#define OM_W_NOTTAGGABLE (OM_FACILITY_CODE << 16)+0X8000+((139)<< 3)+(WARN)
#ifdef  OM_DEFINE_ERRMSG
static char OM_W_erm_NOTTAGGABLE[]=
{"OM-W-NOTTAGGABLE, Class is not taggable via its specification"};
#endif

#define OM_W_TAGDISABLED (OM_FACILITY_CODE << 16)+0X8000+((140)<< 3)+(WARN)
#ifdef  OM_DEFINE_ERRMSG
static char OM_W_erm_TAGDISABLED[]=
{"OM-W-TAGDISABLED, Tagging is disabled"};
#endif

#define OM_I_OBJNOTTAGGED (OM_FACILITY_CODE << 16)+0X8000+((141)<< 3)+(INFO)
#ifdef  OM_DEFINE_ERRMSG
static char OM_I_erm_OBJNOTTAGGED[]=
{"OM-I-OBJNOTTAGGED, Object was not tagged, either disabled or class not taggable"};
#endif

#define OM_I_DUPLICATE_OS (OM_FACILITY_CODE << 16)+0X8000+((142)<< 3)+(INFO)
#ifdef  OM_DEFINE_ERRMSG
static char OM_I_erm_DUPLICATE_OS[]=
{"OM-I-DUPLICATE_OS, Object Space constructed had duplicate internal OS name"};
#endif

#define OM_I_DUPLICATE_OS_RO (OM_FACILITY_CODE << 16)+0X8000+((143)<< 3)+(INFO)
#ifdef  OM_DEFINE_ERRMSG
static char OM_I_erm_DUPLICATE_OS_RO[]=
{"OM-I-DUPLICATE_OS_RO, Read-only Object Space constructed had duplicate internal OS name"};
#endif

#define OM_E_FILEOVRWRTN (OM_FACILITY_CODE << 16)+0X8000+((144) << 3)+(ERRO)
#ifdef	OM_DEFINE_ERRMSG 
static char OM_E_erm_FILEOVRWRTN[]=
{"OM-E-FILEOVRWRTN, object space file rewritten since last access\n"};
#endif

#endif   /* end of OMerrordef.h */
