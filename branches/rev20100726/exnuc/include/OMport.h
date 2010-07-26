#ifndef OM_D_PORT_INCLUDED
#define OM_D_PORT_INCLUDED 1

#include "OMlimits.h"

/*----------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int som_conv_bitfields __((void *b, int size));
extern int som_conv_double __((void *d, int n));
extern int som_conv_int __((void *i, int n));
extern int som_conv_short __((void *s, int n));
extern int som_convert_by_template __((void *p_inst,
		void *p_template, int count));
extern int som_convert_by_template_name __((void *p_inst,
		char *name, int count));
extern double som_double_value __((void *d));
extern void *som_get_template __((char *name));
extern int som_integer_value __((void *i));
extern short som_short_value __((void *s));

#if defined(__cplusplus)
}
#endif

/*----------------------------------------------------------------------------*/

#ifndef OM_D_MINIMUM

#define OM_D_MINIMUM

struct OM_sd_varlenarr_descr
{
	int i_offset;
	unsigned int i_count;
};

struct OM_sd_channel_hdr
{
	unsigned short flags;
	union
	{
		unsigned short count;
		unsigned short isoindex;
	} u1;
};
#endif

/*
**	Data Representation in a class dictionary on disk
*/

struct OM_sd_ClassDef {
	char Cname[OM_K_MAXCLASS_LEN];
	short offset;
	short size;
	short Np;
	short Nd;
};

struct OM_sd_ParentDef {
	char Pname[OM_K_MAXCLASS_LEN];
	short offset;
	short size;
};

struct OM_sd_DataDef {
	short type;
	short offset;
	short size;
	short dim;
};

/*
**	Data representation in a class dictionary in memory.  The p_instance_def
**	field of the acld points to the dictionary class def.
*/

struct OM_sd_Dcomp
{
	struct OM_sd_classdef *p_acld;		/* active class */
	int		offset;			/* instance data offset */
	int		(*conv_function)();	/* function for special conversion */
};

struct OM_sd_Dclass
{
	int			offset;		/* offset to base instance data */
	int			size;		/* instance size sans vlas */
	int			flag;
	short			Nc;		/* number of components */
	short			Nd;		/* number of fields in instance data */
	struct OM_sd_Dcomp	*CompDef;	/* array of components */
	struct OM_sd_DataDef	*Ddef;		/* array of field descriptors */
};

struct OM_sd_Dtemplate
{
	char	name[OM_K_MAXCLASS_LEN];	/* template name */
	int			size;	/* instance size sans vlas */
	int			flag;
	int			Nd;	/* number of fields in instance data */
	struct OM_sd_DataDef	*Ddef;	/* array of field descriptors */
};

#define READ_PORT    0
#define WRITE_PORT   1

#define TRANS_SYM_TAB   "_Trans_SymTab"

/*----------------------------------------------------------------
	Name:	OMPORT_CONV_SHORT, OMPORT_CONV_INT, OMPORT_CONV_DOUBLE
	Descr:	Convert instance data at the given location.
		The conversion is done assuming that the location
		points to the data type indicated.
	Args:	Name		Type		Descr

	(I)	p		void *		pointer to the instance
						data location to convert.
	(I)	cnt		int		number of elements to
						convert.
	RetVal:	1 for success, 0 for failure
----------------------------------------------------------------*/

#define OMPORT_CONV_SHORT(p, cnt)	som_conv_short(p, cnt)
#define OMPORT_CONV_INT(p, cnt)		som_conv_int(p, cnt)
#define OMPORT_CONV_DOUBLE(p, cnt)	som_conv_double(p, cnt)

/*----------------------------------------------------------------
	Name:	OMPORT_CONV_BITFIELDS
	Descr:	Convert instance data at the given location.
		The conversion is done assuming that the location
		points to the "bitfields" data type and occupies
		"size" number of bytes, overall.
	Args:	Name		Type		Descr

	(I)	p		void *		pointer to the instance
						data location to convert.
	(I)	size		int		number of bytes occupied
						by the bit_field definitions,
						overall (1, 2 or 4).
	RetVal:	1 for success, 0 for failure
----------------------------------------------------------------*/

#define OMPORT_CONV_BITFIELDS(p, size)	som_conv_bitfields(p, size)


/*----------------------------------------------------------------
	Name:	OMPORT_SHORT_VALUE, OMPORT_INTEGER_VALUE, OMPORT_DOUBLE_VALUE
	Descr:	Returns instance data value at the given location,
		after swapping the bytes, if needed.
	Args:	Name		Type		Descr

	(I)	p		void *		pointer to the instance
						data location for value.
	RetVal:	short value for OMPORT_SHORT_VALUE
		int   value for OMPORT_INTEGER_VALUE
		double value for OMPORT_DOUBLE_VALUE
----------------------------------------------------------------*/

#define OMPORT_SHORT_VALUE(p)		som_short_value(p)
#define OMPORT_INTEGER_VALUE(p)		som_integer_value(p)
#define OMPORT_DOUBLE_VALUE(p)		som_double_value(p)

/*----------------------------------------------------------------
	Name:	OMPORT_GET_TEMPLATE
	Descr:	Returns a pointer to the template description,
		given the template name.
	Args:	Name		Type		Descr

	(I)	nm		char *		template name

	RetVal:	Pointer to template description (void *)
----------------------------------------------------------------*/

#define OMPORT_GET_TEMPLATE(nm)	som_get_template(nm)

/*----------------------------------------------------------------
	Name:	OMPORT_CONV_BY_TEMPLATE_NAME
	Descr:	Converts the instance data, given a pointer to
		the instance data and a template name.
	Args:	Name		Type		Descr

	(I)	p		void *		instance data pointer
	(I)	nm		char *		template name
	(I)	cnt		int		number of elements to
						convert.
	RetVal:	1 for success, 0 for failure
----------------------------------------------------------------*/

#define OMPORT_CONV_BY_TEMPLATE_NAME(p, nm, cnt) som_convert_by_template_name(p, nm, cnt)

/*----------------------------------------------------------------
	Name:	OMPORT_CONV_BY_TEMPLATE
	Descr:	Converts the instance data, given a pointer to
		the instance data and a template ptr (obtained
		from OMPORT_GET_TEMPLATE macro).
	Args:	Name	Type			Descr

	(I)	p		void *		instance data pointer
	(I)	p_template	void *		template descr.
	(I)	cnt		int		number of elements to
						convert.
	RetVal:	1 for success, 0 for failure
----------------------------------------------------------------*/

#define OMPORT_CONV_BY_TEMPLATE(p, p_template, cnt) som_convert_by_template(p, p_template, cnt)

/*----------------------------------------------------------------
	Name:	OMPORT_DIMENSION_OF
	Descr:	Array dimension of a variable length array
	Args:	Name	Type		Descr

	(I)	vla	void *		pointer to the structure
					representing a vla.

	RetVal:	Array dimension
----------------------------------------------------------------*/

#define OMPORT_DIMENSION_OF(vla) \
	(OMPORT_INTEGER_VALUE(&((struct OM_sd_varlenarr_descr *)(vla))->i_count))

/*----------------------------------------------------------------
	Name:	OMPORT_VLA_VALUE
	Descr:	Returns starting address of a variable length
		array, given a pointer to its representation
		(struct OM_sd_varlenarr_desc) in the instance
		data.
	Args:	Name		Type		Descr

	(I)	vla		void *		pointer to the structure
						representing a vla.
	RetVal:	Pointer to the starting address of the vla data.
----------------------------------------------------------------*/

#define OMPORT_VLA_VALUE(vla) \
  ( \
  	OMPORT_INTEGER_VALUE(&((struct OM_sd_varlenarr_descr *)(vla))->i_offset) \
  		+ \
  	(char *)&((struct OM_sd_varlenarr_descr*)(vla))->i_offset \
  )

#endif
