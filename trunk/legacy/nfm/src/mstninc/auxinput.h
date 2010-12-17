/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   auxinput.h  $
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
|   auxinput.h  							|
|									|
+----------------------------------------------------------------------*/
#if !defined (__auxinputH__)
#define __auxinputH__

#if !defined (__basedefsH__)
#   include	<basedefs.h>
#endif
#if !defined (__basetypeH__)
#   include	<basetype.h>
#endif

/*----------------------------------------------------------------------+
|									|
|   Defines								|
|									|
+----------------------------------------------------------------------*/
/*  Values for trigger */
#define	    AUXINPUT_NO_DATA	    0
#define	    AUXINPUT_DATAPOINT	    1
#define	    AUXINPUT_TENTATIVE	    3
#define	    AUXINPUT_RESET	    4
#define	    AUXINPUT_BUTTON_CODE    5

#define	    FUNC_SETMODE	0
#define	    FUNC_GETPOSITION	1
#define	    FUNC_GETBUTTONEVENT	2
	
/*----------------------------------------------------------------------+
|									|
|   Typedefs								|
|									|
+----------------------------------------------------------------------*/
typedef struct auxInputMode
    {
    byte	    mode;	    /* 0=off, 1=on */
    byte	    reserved[29];
    } AuxInputMode;

typedef struct auxInputPosition
    {
    Point3d	    uorCoord;
    byte	    reserved[18];
    } AuxInputPosition;

typedef struct auxInputButtonEvt
    {
    int		    inputCode;
    Point3d	    uorCoord;
    int		    ticks;
    short	    qualifier;
    byte	    reserved[8];
    } AuxInputButtonEvt;

typedef union 
    {
    AuxInputMode	auxMode;
    AuxInputPosition	auxPosition;
    AuxInputButtonEvt	auxButtonEvt;
    } AuxInputData;
    
typedef struct auxInputMsg
    {
    byte	    func;
    byte	    status;
    AuxInputData    data;
    } AuxInputMsg;

    
#endif
