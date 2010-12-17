/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   userfnc.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
| Copyright (C) 1986-90   Bentley Systems, Inc., All rights reserved.	|
|									|
| "MicroStation", "MDL", and "MicroCSL" are trademarks of Bentley	|
|  Systems, Inc.							|
|									|
| Limited permission is hereby granted to reproduce and modify this	|
| copyrighted material provided that the resulting code is used only in	|
| conjunction with Bentley Systems products under the terms of the	|
| license agreement provided therein, and that this notice is retained	|
| in its entirety in any such reproduction or modification.		|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   userfnc.h -- Provides definitions for accessing MDL user		|
|		  functions.    					|
|									|
+----------------------------------------------------------------------*/
#if !defined	(__userfncH__)
#define __userfncH__

/* .h File Dependencies */
#if !defined (__basetypeH__)
#   include	<basetype.h>
#endif
#if !defined (__msinputqH__)
#   include	<msinputq.h>
#endif

/*----------------------------------------------------------------------+
|									|
|	Parameters for mdlState_ user functions				|
|									|
+----------------------------------------------------------------------*/
/* Function types specified with mdlState_setFunction. To specify a
    function for simple dynamics, use mdlState_dynamicUpdate. */
#define	    STATE_DATAPOINT		    1
#define	    STATE_RESET			    2
#define	    STATE_KEYIN			    3
#define	    STATE_COMPLEX_DYNAMICS	    4
#define	    STATE_COMMAND_CLEANUP	    5
#define	    STATE_OOPSFUNCTION		    6

/*----------------------------------------------------------------------+
|									|
|	Parameters for "mdlLocate_" user functions			|
|									|
+----------------------------------------------------------------------*/
/*  Function types specified with mdlLocate_setFunction	*/
#define	    LOCATE_MODIFY_SCAN_LIST	    1
#define	    LOCATE_ELEMENT_LOCATED	    2
#define	    LOCATE_PRELOCATE		    3
#define	    LOCATE_POSTLOCATE		    4
#define	    LOCATE_ACCEPTFUNC   	    5
#define	    LOCATE_SHOWFUNC     	    6
#define	    LOCATE_CLEANFUNC    	    7
#define	    LOCATE_NOTFOUNDFUNC    	    8

/*  Values returned by element scanning filters.  */
#define	    LOCATE_ELEMENT_REJECT	    0
#define	    LOCATE_ELEMENT_NEUTRAL	    1
#define	    LOCATE_ELEMENT_ACCEPT	    2

/* structures passed to user functions */
typedef struct elementLocated
    {
    union msElementUnion *pElement;	/* => element accepted */
    int			fileNumber;     /* => 0 FOR MASTER FILE, 1 - 32 for
    						reference files */
    ULong		filePosition;   /* => element's position in file. */
    Point3d		*point;		/* => user entered point */
    int			viewnumber;	/* => view number */
    } ElementLocated;

typedef struct modifyScanList
    {
    struct extScanlist *pScanList;
    int		fileNumber;
    Point3d	*pPoint;
    int		viewNumber;
    } ModifyScanList;


/*----------------------------------------------------------------------+
|									|
|	Parameters for "mdlParse_" user functions 			|
|									|
+----------------------------------------------------------------------*/
/*  Function types specified with mdlParse_setFunction.  */
#define	    PARSE_HANDLE_STRING		    1

/*----------------------------------------------------------------------+
|									|
|	Parameters for "mdlSystem_" user functions			|
|									|
+----------------------------------------------------------------------*/
/*  Function types specified with mdlSystem_setFunction.  */
#define	    SYSTEM_NEW_DESIGN_FILE	    1
#define	    SYSTEM_UNLOAD_PROGRAM           2
#define	    SYSTEM_MDLCHILD_TERMINATED	    3
#define	    SYSTEM_RELOAD_PROGRAM           4
#define	    SYSTEM_WRITE_TO_FILE	    5
#define	    SYSTEM_ROOT_CHANGE		    6
    
/*  Values for mdlChildTerminated.exitReason.  If the flag is
    less than zero, the application cannot abort the unload. */
#define	    SYSTEM_TERMINATED_SHUTDOWN	    -2
#define	    SYSTEM_TERMINATED_FATAL	    -1
#define	    SYSTEM_TERMINATED_COMMAND	    1
#define	    SYSTEM_TERMINATED_EXIT	    2
#define	    SYSTEM_TERMINATED_BY_APP	    3
#define	    SYSTEM_TERMINATED_EXCEPTION	    4
    
/* Values passed to the newDesignFile user function. These values
   identify MicroStation stage in new design file processing. */
#define	    SYSTEM_NEWFILE_CLOSE	    0
#define	    SYSTEM_NEWFILE_COMPLETE	    1

/* structures passed to user functions */
typedef struct mdlChildTerminated
    {
    char	*pName;
    short	exitReason;
    long	exitStatus;	    /* Valid only if exitReason == ...EXIT */
    } MdlChildTerminated;


/*----------------------------------------------------------------------+
|									|
|	Parameters for "mdlExternal_" user functions			|
|									|
+----------------------------------------------------------------------*/
/*  Function types specified with mdlExternal_setFunction. */
#define	    EXTERNAL_MESSAGE_RECEIVED	    1
#define	    EXTERNAL_PROGRAM_TERMINATED	    2

/*----------------------------------------------------------------------+
|									|
|	Parameters for "mdlString_" user functions			|
|									|
+----------------------------------------------------------------------*/

/*  Function types specified with mdlString_setFunction. */
#define	    STRING_TO_UORS		    1
#define	    STRING_FROM_UORS		    2
#define	    STRING_TO_ANGLE		    3
#define	    STRING_FROM_ANGLE		    4
#define	    STRING_FROM_DIRECTION	    5

/*----------------------------------------------------------------------+
|									|
|	Parameters for "mdlView_" user functions			|
|									|
+----------------------------------------------------------------------*/
/*  Function types specified with mdlView_setFunction.  */
#define	    UPDATE_PRE			    1
#define	    UPDATE_POST			    2
#define	    VIEW_NOMOTION		    3
#define	    VIEW_MOTION			    4
#define	    UPDATE_EACH_ELEMENT		    5
#define	    PLOTUPDATE_PRE		    6
#define	    PLOTUPDATE_POST		    7

/*----------------------------------------------------------------------+
|									|
|	Parameters for "mdlInput_" user functions			|
|									|
+----------------------------------------------------------------------*/
/*  Function types specified with mdlInput_setFunction.  To specify a
    function to monitor all queue elements, use mdlInput_monitor.   */
#define	    INPUT_COMMAND_FILTER	    1
#define	    INPUT_MESSAGE_RECEIVED	    2
#define	    INPUT_KEYIN_PREPROCESS	    3

/*  Input to mdlInput_defineMonitor     */
#define	    MONITOR_NOT_FROM_APP	    0
#define	    MONITOR_ALL			    1
#define	    MONITOR_FROM_APP		    2

/*  Values returned by command filters.	 */
#define	    INPUT_COMMAND_ACCEPT	    0
#define	    INPUT_COMMAND_REJECT	    1
#define	    INPUT_COMMAND_CHANGED	    2
    
/* Values returned by preprocessor and monitor filters */
#define	    INPUT_ACCEPT		    0
#define	    INPUT_REJECT		    1

/*----------------------------------------------------------------------+
|									|
|	Parameters for "mdlUndo_" user functions			|
|									|
+----------------------------------------------------------------------*/
/*  Function types specified with mdlUndo_setFunction	*/
#define	    UNDOFUNC_ADD_ENTRIES	    1
#define	    UNDOFUNC_UNDO_COMMAND	    2


/*  Undo Entry types */
#define	    UNDO_DELETE			    1
#define	    UNDO_ADD			    2
#define	    UNDO_MODIFY			    3
#define	    UNDO_MARK			    4
#define	    UNDO_MODIFYFENCE		    5

typedef struct undoInfo
    {
    ULong	filePos;	/* file position of element		*/
    long	processNumber;	/* process active at time of entry	*/
    short       funcname;	/* Number of RTYPE_CMDNAME resource.	*/
    short	idNumber;	/* id for grouping			*/
    byte	markLevel;	/* is this entry a mark			*/
    byte	undoAction;	/* type of entry			*/
    } UndoInfo;
    
#endif
