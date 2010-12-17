/************************************************
 * Product Data User data structure definitions *
 *     - for functions internal to EMS -        *
 ************************************************/

#ifndef PDUint
#define PDUint 1

#include	<OMminimum.h>
#include	<igrtypedef.h>
#include	<PDUstr.h>

struct PDUserial
   {
    IGRchar	*catalog;
    IGRchar	*partid;
    IGRchar	*revision;
    IGRchar	*history;
    IGRchar	*orient;
    IGRchar	*quantity;
    IGRchar	*serial;
    IGRchar	*usageid;
    IGRchar	*viewname;
   };

struct PDUserindex
   {
    IGRint	index;
    IGRint	serial;
   };

struct	PDUid
        {
	OMuword		osnum;
	OM_S_OBJID	objid;
	};

struct	PDUpoint
        {
	IGRdouble	x;
	IGRdouble	y;
	IGRdouble	z;
	};

struct	PDUptr_info
        {
	IGRchar		symbol[2];
	IGRchar		*usage_id;
	IGRchar		*quantity;
	IGRchar		*history;
	IGRchar		*text_symb;
	IGRint		index;
	IGRint		type;
	IGRdouble	active_angle;
	struct PDUpoint	point;
	};

struct	PDUview_info
        {
	IGRmatrix	matrix;
	IGRint		levels;
	IGRchar		*info;
	};


struct	PDUreport
        {
	IGRint		type;
	IGRshort	items;
	IGRchar		**data;
	};

#endif
