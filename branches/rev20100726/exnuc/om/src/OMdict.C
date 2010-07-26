#include "exsysdep.h"

#ifdef BIG_ENDIAN

#include <stdio.h>
#include "trans.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <fcntl.h>
#include <unistd.h>
#include <hash.h>
#if 0
#ifdef SUNOS
#include <dlfcn.h>
#endif
#endif
#include <dload.h>
#include <dirent.h>
#include <string.h>

#include "OMminimum.h"
#include "OMport.h"
#include "OMprimitives.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "OMerrordef.h"

extern char	*OM_Gp_inst_in;
extern char	*OM_Gp_inst_out;

/******************************************************************************/

static HASHTABLE	*TemplateTbl = 0;	/* template definitions */
static HASHTABLE	*LoadedTbl = 0;		/* dictionaries and directories already loaded */

static OM_S_CLASSDEF	*p_CurAcld = 0;		/* for recursive special conversion */

/******************************************************************************/

#ifdef DEBUG_INVOKE
	static int	DebugLevel = 0;
	static int	LevelCount;
#	define DEBUG_PRINT(S)	\
	{ \
		for (LevelCount = 0; LevelCount < DebugLevel; ++LevelCount) \
			printf("\t"); \
		printf S ; \
	}
#	define DEBUG_ENTER(S)	{DEBUG_PRINT(S) ++DebugLevel;}
#	define DEBUG_EXIT(S)	{--DebugLevel; DEBUG_PRINT(S)}
#else
#	define DEBUG_ENTER(S)
#	define DEBUG_EXIT(S)
#	define DEBUG_PRINT(S)
#endif

/******************************************************************************/

static int	has_been_loaded(name)
char	*name;
{
	if (LoadedTbl && hashlookup(LoadedTbl, name))
		return 1;
	else
		return 0;
}

/******************************************************************************/

static int	mark_is_loaded(name)
char	*name;
{
	char	*tmp;

	if (!LoadedTbl)
	{
		LoadedTbl = hashinit(NAKED(char *), 47, hashc, strcmp,
				NAKEDKEY, NOMEM);
		if (!LoadedTbl)
			return OM_E_NODYNMEM;
	}

	tmp = om$malloc(size = strlen(name) + 1);
	if (!tmp)
		return OM_E_NODYNMEM;
	strcpy(tmp, name);
	if (!hashadd(LoadedTbl, tmp, (char **)0))
	{
		om$dealloc(ptr=tmp);
		return OM_E_NODYNMEM;
	}
	return OM_S_SUCCESS;
}

/******************************************************************************/

static int	load_data_definitions(pp_Ddef, n, fd)
struct OM_sd_DataDef	**pp_Ddef;
int			n;
int			fd;
{
	*pp_Ddef = 0;

	if (n)
	{
		int	data_size;

		data_size = sizeof(struct OM_sd_DataDef) * n;
		*pp_Ddef = (struct OM_sd_DataDef *)om$malloc(size=data_size);
		if (*pp_Ddef == NULL)
		{
			fprintf(stderr, "load_data_definitions: error: unable to malloc %u bytes\n", data_size);
			return OM_E_NODYNMEM;
		}
		if (read(fd, *pp_Ddef, data_size) != data_size)
		{
			fprintf(stderr, "load_data_definitions: error: unable to read %u bytes\n", data_size);
			om$dealloc(ptr=*pp_Ddef);
			return OM_E_ABORT;
		}
	}
	return OM_S_SUCCESS;
}

/******************************************************************************/

static int	load_template(p_cdef, fd)
struct OM_sd_ClassDef	*p_cdef;
int			fd;
{
	int			sts;
	struct OM_sd_Dtemplate	*template = 0;

	if (!TemplateTbl)
	{
		TemplateTbl = hashinit(struct OM_sd_Dtemplate, 47, hashc, strcmp, name[0], NOMEM);
		if (!TemplateTbl)
		{
			fprintf(stderr, "load_template: error: unable to hashinit\n");
			return OM_E_ABORT;
		}
	}

	/*
	**	Make sure template is not already in hash table.
	*/

	template = (struct OM_sd_Dtemplate *)hashlookup(TemplateTbl, p_cdef->Cname);
	if (template)
	{
		/* Validate template size */

		if (template->size != p_cdef->size)
		{
			fprintf(stderr, "load_template: error: read template %s size %d already had %d\n", template->name, p_cdef->size, template->size);
			return OM_E_ABORT;
		}
		return OM_S_SUCCESS;
	}

	template = (struct OM_sd_Dtemplate *)
		om$calloc(num=1, size=sizeof(*template));
	if (!template)
	{
		fprintf(stderr, "load_template: error: unable to malloc\n");
		return OM_E_NODYNMEM;
	}

	strncpy(template->name, p_cdef->Cname, OM_K_MAXCLASS_LEN);
	template->size = p_cdef->size;
	template->Nd = p_cdef->Nd;

	sts = load_data_definitions(&template->Ddef, template->Nd, fd);
	if (!(1&sts))
	{
		fprintf(stderr, "load_template: error: unable to load data definitions for %s\n", template->name);
		om$dealloc(ptr=template);
		return sts;
	}
	if (!(hashadd(TemplateTbl, (char *)template, (char **)0)))
	{
		fprintf(stderr, "load_template: error: unable to add template %s\n", template->name);
		om$dealloc(ptr=template);
		return sts;
	}

	return OM_S_SUCCESS;
}

/******************************************************************************/

static int	assign_conversion_function(classname, component, conv_func)
char	*classname;
char	*component;
int	(*conv_func)();
{
	OM_S_CLASSDEF		*p_acld, *p_c_acld;
	int			sts;
	struct OM_sd_Dclass	*classdef;
	int			i;

	sts = om$get_class(classname=classname, pp_cld=&p_acld);
	if (!(1&sts))
	{
		if (OM_Gf_verbose_warning)
			fprintf(stderr, "assign_conversion_function: warning: unable to find class %s\n", classname);
		return OM_S_SUCCESS;
	}
	sts = om$get_class(classname=component, pp_cld=&p_c_acld);
	if (!(1&sts))
	{
		if (OM_Gf_verbose_warning)
			fprintf(stderr, "assign_conversion_function: warning: unable to find component %s\n", component);
		return OM_S_SUCCESS;
	}

	classdef = p_acld->p_instance_def;
	if (!classdef)
	{
		fprintf(stderr, "assign_conversion_function: error: class %s has no dictionary definition\n", classname);
		return OM_E_ABORT;
	}

	/*
	**	Find the matching component for the conversion function.
	**	Check to make sure instance data was not rejected for
	**	that component.
	*/

	for (i = 0; i < classdef->Nc; ++i)
		if (classdef->CompDef[i].p_acld == p_c_acld)
		{
			if (classdef->CompDef[i].offset)
				classdef->CompDef[i].conv_function = conv_func;
			break;
		}

	if (i == classdef->Nc)
	{
		fprintf(stderr, "assign_conversion_function: error: unable to find component %s in class %s\n", component, classname);
		return OM_E_ABORT;
	}

	return OM_S_SUCCESS;
}

/******************************************************************************/

static int	parse_conversion_function_name(name, p_classname, p_component)
char	*name;
char	**p_classname;
char	**p_component;
{
	int	len = 0;

	*p_classname = 0;
	*p_component = 0;

#if defined (CLIX) || defined (SUNOS4)
	if ('_' == name[0])
#endif
	{
		int	i;

#if defined IRIX || defined (SUNOS5)
		for (i = 0; name[i]; ++i)
#else
		for (i = 1; name[i]; ++i)
#endif
			if ('_' == name[i] && !strncmp(&name[i], "_OMPORT_", 8))
			{
#if defined IRIX || defined (SUNOS5)
				*p_classname = &name[0];
				len = i;
#else
				*p_classname = &name[1];
				len = i - 1;
#endif
				*p_component = &name[i] + 8;
				break;
			}
	}

	return len;
}

/******************************************************************************/
static int	load_conversion_functions(filename)
char	*filename;
{
	void	        *handle=NULL;
	char	        **symbols;
	int             i;
        int             numsyms=0;
        struct symdef   *symbuf;

        if (dload_ctrl(GETHANDLE, filename)) /* Already loaded? */
           return(OM_S_SUCCESS);
        if (!(handle = dload(filename,
              INCRLOAD | TEXTREF | DATAREF | HIDEGLOBAL)))
        {   
           fprintf(stderr, "load_conversion_functions: error: failed to load %s\n",
              filename);
           return OM_E_ABORT;
        }
        if (!dload_ctrl(LOADCMPL, DLOAD_PEND, 0)) /* End of incremental dload */
           return OM_E_ABORT;

        numsyms = dload_symbol_lookup(handle, (char *) 0, &symbuf);
	if (!numsyms)
	{
		fprintf(stderr, "load_conversion_functions: unable to find symbols in file %s\n", filename);
		return OM_E_ABORT;
	}

	/*
	**	Loop through all the symbols and look for
	**	conversion function names.
	*/

	for (i = 0; (i < numsyms); ++i)
	{
		int	(*conv_func)();
		char	*classname = 0;
		int	classlen = 0;
		char	*component = 0;
		int	sts;

                if (!(symbuf[i].flags & DL_TEXT))
                   continue;
		if (!(classlen = parse_conversion_function_name(symbuf[i].name,
						&classname, &component)))
			continue;

		conv_func = (int(*)()) symbuf[i].value;
		if (!conv_func)
		{
			fprintf(stderr, "load_conversion_functions: error: no value given for symbol %s in %s\n",
			   symbuf[i].name, filename);
			return OM_E_ABORT;
		}

		classname[classlen] = 0;
		sts = assign_conversion_function(classname, component, conv_func);
		if (!(1&sts))
		{
			fprintf(stderr, "load_conversion_functions: error: could not assign conversion function class %s component %s from file %s\n", classname, component, filename);
			return sts;
		}
	}

	return OM_S_SUCCESS;
}


/******************************************************************************/

int	som_dload_conversion_functions(dirname)
char	*dirname;
{
	DIR		*dp;
	struct dirent	*dent;
	int		sts;

	if (has_been_loaded(dirname))
		return OM_S_SUCCESS;

	dp = opendir(dirname);
	if (dp == NULL)
	{
		if (OM_Gf_verbose_warning)
			fprintf(stderr, "som_dload_conversion_functions: warning: %s: no such directory\n", dirname);
		return OM_S_SUCCESS;
	}

	sts = OM_S_SUCCESS;
	while (dent = readdir(dp))
	{
		int	len;

		len = strlen(dent->d_name);
#ifdef IRIX4
		if (len > 2 &&
			'.' == dent->d_name[len - 2] &&
			'o' == dent->d_name[len - 1] )
#else
		if (len > 3 &&
			'.' == dent->d_name[len - 3] &&
			's' == dent->d_name[len - 2] &&
			'o' == dent->d_name[len - 1] )
#endif
		{
			char	filename[MAXPATHLEN];

			if (strlen(dirname) + strlen(dent->d_name) + 1 + 1 > MAXPATHLEN)
			{
				fprintf(stderr, "som_dload_conversion_functions: error: max path len %d exceeded by %s/%s\n", MAXPATHLEN, dirname, dent->d_name);
				return OM_E_ABORT;
			}

			strcpy(filename, dirname);
			strcat(filename, "/");
			strcat(filename, dent->d_name);

			sts = load_conversion_functions(filename);
			if (!(1&sts))
			{
				fprintf(stderr, "som_dload_conversion_functions: error: could not load conversion functions from %s\n", filename);
				break;
			}
		}
	}

	closedir(dp);
	if (1&sts)
		return mark_is_loaded(dirname);
	return sts;
}

/******************************************************************************/

int	som_load_dictionary(filename)
char	*filename;
{
	int 			fd;
	struct OM_sd_ClassDef	cdef;
	int			nbytes;

	if (has_been_loaded(filename))
		return OM_S_SUCCESS;

	if (-1 == (fd = open(filename, O_RDONLY)))
	{
		/* OK - application layer may not have a dictionary */

		if (OM_Gf_verbose_warning)
			fprintf(stderr, "som_load_dictionary: warning: %s: no such file\n", filename);

		return OM_S_SUCCESS;
	}

	while (0 != (nbytes = read(fd, &cdef, sizeof(cdef))))
	{
		int			sts;
		struct OM_sd_Dclass	*classdef;
		int			skip_bytes;
		OM_S_CLASSDEF		*p_acld = 0;

		if (nbytes != sizeof(cdef))
		{
			fprintf(stderr, "som_load_dictionary: unable to read class record from %s\n", filename);
			close(fd);
			return OM_E_ABORT;
		}

		if (cdef.Np < 0)
		{
			sts = load_template(&cdef, fd);
			if (!(1&sts))
			{
				fprintf(stderr, "som_load_dictionary: error: unable to load template %s from %s\n", cdef.Cname, filename);
				om$report_error(sts=sts);
				close(fd);
				return sts;
			}
			continue;
		}

		/* - Class definition - */

		sts = om$get_class(classname=cdef.Cname, pp_cld=&p_acld);
		if (!(1&sts))
		{
			/* - No instances for this class.
			   - Skip class defintion record */

			skip_bytes = (cdef.Np * sizeof(struct OM_sd_ParentDef)) +
				     (cdef.Nd * sizeof(struct OM_sd_DataDef));
			lseek(fd, skip_bytes, SEEK_CUR);
			if (OM_Gf_verbose_warning)
				fprintf(stderr, "som_load_dictionary: warning: unknown class %s in %s\n", cdef.Cname, filename);
			continue;
		}
		classdef = p_acld->p_instance_def;
		if (classdef)
		{
			/* - Class defn exists for this class.
			   - Skip class defintion record */

			skip_bytes = (cdef.Np * sizeof(struct OM_sd_ParentDef)) +
				     (cdef.Nd * sizeof(struct OM_sd_DataDef));
			lseek(fd, skip_bytes, SEEK_CUR);
			continue;
		}

		/*
		**	Validate that the classdef in the dictionary
		**	matches the memory version.
		*/

		if (cdef.size != p_acld->i_instance_size)
		{
			fprintf(stderr, "som_load_dictionary: error: class %s size in dictionary %s is %u size in image is %u\n", cdef.Cname, filename, cdef.size, p_acld->i_instance_size);
			close(fd);
			return OM_E_ABORT;
		}

		classdef = (struct OM_sd_Dclass *)om$calloc(num=1, size=sizeof(*classdef));
		if (!classdef)
		{
			fprintf(stderr, "som_load_dictionary: error: unable to calloc class %s in %s\n", cdef.Cname, filename);
			close(fd);
			return OM_E_NODYNMEM;
		}

		classdef->offset = cdef.offset;
		classdef->Nc = cdef.Np;
		if (cdef.Np)
		{
			int	i;

			classdef->CompDef = (struct OM_sd_Dcomp *)om$malloc(size=
					sizeof(struct OM_sd_Dcomp) * cdef.Np);
			if (classdef->CompDef == NULL)
			{
				fprintf(stderr, "som_load_dictionary: error: malloc failed for %u parent(s) of %s in %s\n", cdef.Np, cdef.Cname, filename);
				om$dealloc(ptr=classdef);
				close(fd);
				return OM_E_ABORT;
			}

			for (i=0; i<cdef.Np; i++)
			{
				struct OM_sd_ParentDef	pdef;
	
				if (read(fd, &pdef, sizeof(pdef)) != sizeof(pdef))
				{
					fprintf(stderr, "som_load_dictionary: error: unable to read parent[%u] of class %s in %s\n", i, cdef.Cname, filename);
					om$dealloc(ptr=classdef->CompDef);
					om$dealloc(ptr=classdef);
					close(fd);
					return OM_E_ABORT;
				}

				classdef->CompDef[i].offset = pdef.offset;
				classdef->CompDef[i].conv_function = NULL;
				sts = om$get_class(classname=pdef.Pname, pp_cld=&classdef->CompDef[i].p_acld);
				if (!(1&sts))
				{
					fprintf(stderr, "som_load_dictionary: error: cannot find class for parent %s of class %s\n",
						cdef.Cname, pdef.Pname);
					om$dealloc(ptr=classdef->CompDef);
					om$dealloc(ptr=classdef);
					close(fd);
					return sts;
				}
			}
		}
		classdef->size = cdef.size;
		classdef->Nd = cdef.Nd;
		sts = load_data_definitions(&classdef->Ddef, classdef->Nd, fd);
		if (!(1&sts))
		{
			fprintf(stderr, "som_load_dictionary: error: could not read/malloc %u data records for class %s in %s failed\n", cdef.Nd, cdef.Cname, filename);
			if (classdef->CompDef)
				om$dealloc(ptr=classdef->CompDef);
			om$dealloc(ptr=classdef);
			close(fd);
			return sts;
		}

		p_acld->p_instance_def = classdef;
	}

	/* End Of File */

	close(fd);
	return mark_is_loaded(filename);
}

/******************************************************************************/

static int	is_char_array(p_ddef)
struct OM_sd_DataDef	*p_ddef;
{
	if (1 == p_ddef[0].size && DROS_ENDBLOCK_CODE == p_ddef[1].type)
		return 1;
	return 0;
}

/******************************************************************************/

static int	convert_data(p_data, p_ddef, nd)
unsigned char		*p_data;
struct OM_sd_DataDef	*p_ddef;
int			nd;
{
	int	i;

	for (i = 0; i < nd;)
	{
		unsigned char	*ptr;
		int		sts;
		int		j;

		ptr = p_data + p_ddef[i].offset;
		switch (p_ddef[i].type)
		{
		case DROS_ENDBLOCK_CODE:
		case DROS_NULL_CODE:
			i++; 
			break;

		case DROS_CHAR_CODE:
		case DROS_UCHAR_CODE:
			i++;
			break;

		case DROS_STRING_CODE:
			/*printf("    %s\n", *ptr );*/
			i++;
			break;

		case DROS_SHORT_CODE:
		case DROS_USHORT_CODE:
			sts = OMPORT_CONV_SHORT(ptr, 1);
			if (!(1&sts))
			{
				fprintf(stderr, "convert_data: error: could not convert short in field %d at offset %u\n", i, ptr - p_data);
				return sts;
			}
			i++;
			break;

		case DROS_INT_CODE:
		case DROS_UINT_CODE:
		case DROS_LONG_CODE:
		case DROS_ULONG_CODE:
		case DROS_POINTER_CODE:
		case DROS_FLOAT_CODE:
		case DROS_ENUMERATION_CODE:
		case DROS_ENUM_FIELD_CODE:
			sts = OMPORT_CONV_INT(ptr, 1);
			if (!(1&sts))
			{
				fprintf(stderr, "convert_data: error: could not convert int/ptr/float/enum in field %d at offset %u\n", i, ptr - p_data);
				return sts;
			}
			i++;
			break;

		case DROS_DOUBLE_CODE:
			sts = OMPORT_CONV_DOUBLE(ptr, 1);
			if (!(1&sts))
			{
				fprintf(stderr, "convert_data: error: could not convert double in field %d at offset %u\n", i, ptr - p_data);
				return sts;
			}
			i++;
			break;

		case DROS_CHANNEL_CODE:
			sts = som_convert_channel(ptr);
			if (!(1&sts))
			{
				fprintf(stderr, "convert_data: error: could not convert channel in field %d at offset %u\n", i, ptr - p_data);
				return sts;
			}
			i++;
			break;

		case DROS_UNION_CODE:
		case DROS_BITFIELD_CODE:
			i++;
			break;

		case DROS_ARRAY_CODE:
		case DROS_VARARRAY_CODE:
			sts = som_convert_array(&p_ddef[i], ptr, &j);
			if (!(1&sts))
			{
				fprintf(stderr, "convert_data: error: could not convert array/vararray in field %d at offset %u\n", i, ptr - p_data);
				return sts;
			}
			i += j;
			break;

		default:
			fprintf(stderr, "convert_data: error: unknown field type %u for field %d\n", p_ddef[i].type, i);
			return OM_E_ABORT;
		}
	}

	return OM_S_SUCCESS;
}

/******************************************************************************/

int	som_convert_array(p_ddef, inst, n)
struct OM_sd_DataDef	*p_ddef;
unsigned char		*inst;
int			*n;
{
	int	sts;
	int	i, j, count;

	for (i = 1,j = 1; j > 0; i++)
	{
		if ((p_ddef[i].type == DROS_ARRAY_CODE)
		||  (p_ddef[i].type == DROS_VARARRAY_CODE))
			j++;
		else if (p_ddef[i].type == DROS_ENDBLOCK_CODE)
			j--;
	}

	*n = i;

	if (p_ddef[0].type == DROS_VARARRAY_CODE)
	{
		int i_count, i_offset;
		struct OM_sd_varlenarr_descr *p_vla;

		p_vla = (struct OM_sd_varlenarr_descr *)inst;

		i_offset = OMPORT_INTEGER_VALUE(&p_vla->i_offset);
		i_count  = OMPORT_INTEGER_VALUE(&p_vla->i_count);

		/*
		**	Convert these here in case of write.  It assures they
		**	are in the output buffer.
		*/

		sts = OMPORT_CONV_INT(&p_vla->i_offset, 1);
		if (!(1&sts))
		{
			fprintf(stderr, "convert_array: error: unable to convert offset in array descriptor\n");
			return sts;
		}

		sts = OMPORT_CONV_INT(&p_vla->i_count, 1);
		if (!(1&sts))
		{
			fprintf(stderr, "convert_array: error: unable to convert count in array descriptor\n");
			return sts;
		}

		inst += i_offset;
		count = i_count * p_ddef[0].dim; /* KILLER */
	}
	else
		count = p_ddef[0].dim;

	if (count && is_char_array(&p_ddef[1]))
		return OM_S_SUCCESS;

	for (j=0; j<count; j++)
	{
		sts = convert_data(inst, &p_ddef[1], i-2);
		if (!(1&sts))
		{
			fprintf(stderr, "convert_array: error: unable to convert array data\n");
			return sts;
		}

		inst += p_ddef[0].size;
	}

	return OM_S_SUCCESS;
}

/******************************************************************************/

void	*som_get_template(name)
char			*name;
{
	void	*p_template = 0;

	if (TemplateTbl)
		p_template = (struct OM_sd_Dtemplate *)hashlookup(TemplateTbl, name);
	return p_template;
}

/******************************************************************************/

int	som_convert_by_template(p_data, p_temp, count)
void	*p_data;
void	*p_temp;
int	count;
{
	unsigned char		*p_inst = p_data;
	struct OM_sd_Dtemplate	*p_template = p_temp;

	while (count)
	{
		int	sts;

		sts = convert_data(p_inst, p_template->Ddef, p_template->Nd);
		if (!(1&sts))
		{
			fprintf(stderr, "som_convert_by_template: error: converting template %s[%d]\n", p_template->name, count);
			return 0;
		}
		p_inst += p_template->size;
		count--;
	}
	return 1;
}

/******************************************************************************/

int	som_convert_by_template_name(p_data, name, count)
void	*p_data;
char	*name;
int 	count;
{
	unsigned char		*p_inst = p_data;
	int			sts;
	struct OM_sd_Dtemplate	*p_template;

	p_template = som_get_template(name);
	if (!p_template)
	{
		fprintf(stderr, "som_convert_by_template_name: error: template %s not found\n", name);
		return 0;
	}
	sts = som_convert_by_template(p_inst, p_template, count);
	if (!(1&sts))
	{
		fprintf(stderr, "som_convert_by_template_name: error: unable to convert by template %s\n", name);
		return 0;
	}

	return 1;
}

/******************************************************************************/

static int	fire_conv_func(p_inst, p_comp_acld, conv_func)
unsigned char	*p_inst;
OM_S_CLASSDEF	*p_comp_acld;
int		(*conv_func)();
{
	int			i;
	struct OM_sd_Dcomp	*p_comp;
	int			offset;

	i = p_CurAcld->p_instance_def->Nc - 1;
	p_comp = p_CurAcld->p_instance_def->CompDef;
	offset = 0;

	while (p_comp[i].p_acld != p_comp_acld && i >= 0)
		i--;
	offset = (int) ( i >= 0 ) ? (int)p_comp[i].offset : 0 ;

	if (offset)
		return conv_func((short)p_CurAcld->w_classid,
			p_inst,
			p_inst + offset);
	else
		return OM_S_SUCCESS;

}

/******************************************************************************/

static int	invoke_conversion_functions(p_inst, p_acld)
unsigned char	*p_inst;
OM_S_CLASSDEF	*p_acld;
{
	int	sts;
	int	i;
	int	nc;
	struct OM_sd_Dcomp	*p_comp;

	nc = p_acld->p_instance_def->Nc;
	p_comp = p_acld->p_instance_def->CompDef;

	if (!nc)
		return OM_S_SUCCESS;

	DEBUG_ENTER(("+invoke_conversion_functions(0x%.8x, %s)\n",
		p_inst, p_acld->s_name))

	for (i = 0; i < nc; ++i)
	{
		struct OM_sd_Dclass	*p_comp_class;

		if (!(p_comp_class = p_comp[i].p_acld->p_instance_def))
		{
			fprintf(stderr, "invoke_conversion_functions: error: component %s in class %s is not in the class dictionary\n", p_comp[i].p_acld->s_name, p_CurAcld->s_name);
			return OM_E_ABORT;
		}
		if (p_comp_class->flag)
			continue;

		if (p_comp[i].conv_function)
		{
			DEBUG_PRINT(("fire_conv_func(0x%.8x, %s, 0x%.8x)\n",
				p_inst, p_comp[i].p_acld->s_name, p_comp[i].conv_function))

			sts = fire_conv_func(p_inst,
				p_comp[i].p_acld,
				p_comp[i].conv_function);
			if (!(1&sts))
			{
				fprintf(stderr, "invoke_conversion_functions: error: unable to execute conversion function for component %s in class %s\n", p_comp[i].p_acld->s_name, p_CurAcld->s_name);
				return OM_E_ABORT;
			}
			/*
			**	The flag prevents an ancestor (in the loop
			**	below) from converting data that I've already
			**	converted.
			*/
			p_comp_class->flag = 1;
		}
	}

	for (i = nc - 1; i > 0; --i)
	{
		struct OM_sd_Dclass	*p_comp_class;

		p_comp_class = p_comp[i].p_acld->p_instance_def;

		if (p_comp[i].p_acld == p_acld || p_comp_class->flag)
			continue;

		sts = invoke_conversion_functions(p_inst, p_comp[i].p_acld);
		if (!(1&sts))
		{
			fprintf(stderr, "invoke_conversion_functions: error: unable to recursively execute conversion function for component %s in class %s\n", p_comp[i].p_acld->s_name, p_CurAcld->s_name);
			return OM_E_ABORT;
		}
	}

	DEBUG_EXIT(("-invoke_conversion_functions(0x%.8x, %s)\n",
		p_inst, p_acld->s_name))

	return OM_S_SUCCESS;
}

/******************************************************************************/

int	som_convert_instance(p_inst, p_out, p_acld)
char	*p_inst;
char	*p_out;
OM_S_CLASSDEF	*p_acld;
{
	struct OM_sd_Dclass	*p_class;
	int			i;
	int			sts;

	p_class = p_acld->p_instance_def;
	if (!p_class)
	{
		fprintf(stderr, "som_convert_instance: error: class %s not in dictionary\n", p_acld->s_name);
		return OM_E_ABORT;
	}

	OM_Gp_inst_in = p_inst;
	OM_Gp_inst_out = p_out;

	for (i = 0; i < p_class->Nc; ++i)
	{
		struct OM_sd_Dcomp	*p_comp;
		int			sts;

		p_comp = &p_class->CompDef[i];

		/*  check for rejected instance data */
		if( !p_comp->offset && p_comp->p_acld->w_classid )
			continue;

		sts = convert_data(p_inst + p_comp->offset,
			p_comp->p_acld->p_instance_def->Ddef,
			p_comp->p_acld->p_instance_def->Nd);
		if (!(1&sts))
		{
			fprintf(stderr, "som_convert_instance: error: unable to convert component %s of class %s in instance 0x%.8x\n", p_comp->p_acld->s_name, p_acld->s_name, p_inst);
			return sts;
		}
		p_comp->p_acld->p_instance_def->flag = 0;
	}

	/*
	**	Set global to ensure that all offsets to instance data are
	**	computed using my acld.
	*/
	p_CurAcld = p_acld;
	sts = invoke_conversion_functions(p_inst, p_acld);
	p_CurAcld = 0;
	if (!(1&sts))
	{
		fprintf(stderr, "som_convert_instance: error: unable to invoke conversion functions for class %s\n", p_acld->s_name);
		return sts;
	}

	return OM_S_SUCCESS;
}

/******************************************************************************/

#ifdef DEBUG
static void	dump_Dcomp(p, n)
struct OM_sd_Dcomp	*p;
int			n;
{
	int	i;

	printf("#\tp_acld\t\toffset\tconv_func\t(name)\n");
	for (i = 0; i < n; ++i, ++p)
	{
		printf("[%u]\t0x%.8x\t%u\t0x%.8x\t%s\n", i, p->p_acld, p->offset, p->conv_function, p->p_acld->s_name);
	}
	printf("\n");
}

static char	*type_to_name(type)
int	type;
{
	char	*name = "<UNKNOWN>";

	switch (type)
	{
	case DROS_ENDBLOCK_CODE:	name = "ENDBLOCK";	break;
	case DROS_NULL_CODE:		name = "NULL";		break;
	case DROS_CHAR_CODE:		name = "CHAR";		break;
	case DROS_UCHAR_CODE:		name = "UCHAR";		break;
	case DROS_SHORT_CODE:		name = "SHORT";		break;
	case DROS_USHORT_CODE:		name = "USHORT";	break;
	case DROS_INT_CODE:		name = "INT";		break;
	case DROS_UINT_CODE:		name = "UINT";		break;
	case DROS_LONG_CODE:		name = "LONG";		break;
	case DROS_ULONG_CODE:		name = "ULONG";		break;
	case DROS_FLOAT_CODE:		name = "FLOAT";		break;
	case DROS_DOUBLE_CODE:		name = "DOUBLE";	break;
	case DROS_STRING_CODE:		name = "STRING";	break;
	case DROS_CHANNEL_CODE:		name = "CHANNEL";	break;
	case DROS_POINTER_CODE:		name = "POINTER";	break;
	case DROS_ARRAY_CODE:		name = "ARRAY";		break;
	case DROS_VARARRAY_CODE:	name = "VARARRAY";	break;
	case DROS_BITFIELD_CODE:	name = "BITFIELD";	break;
	case DROS_FUNCTION_CODE:	name = "FUNCTION";	break;
	case DROS_STRUCT_CODE:		name = "STRUCT";	break;
	case DROS_UNION_CODE:		name = "UNION";		break;
	case DROS_ENUMERATION_CODE:	name = "ENUMERATION";	break;
	case DROS_ENUM_FIELD_CODE:	name = "ENUM_FIELD";	break;
	case DROS_CLASS_CODE:		name = "CLASS";		break;
	}

	return name;
}

static void	dump_DataDef(p, n)
struct OM_sd_DataDef	*p;
int			n;
{
	int	i;

	printf("#\ttype\toffset\tsize\tdim\ttype name\n");
	for (i = 0; i < n; ++i, ++p)
	{
		printf("[%u]\t%d\t%u\t%u\t%u\t%s\n", i, p->type, p->offset, p->size, p->dim, type_to_name(p->type));
	}
	printf("\n");
}

static void	dump_Dclass(p)
struct OM_sd_Dclass	*p;
{
	printf("offset  .....  %u\n", p->offset);
	printf("size  .......  %u\n", p->size);
	printf("flag  .......  0x%.8x\n", p->flag);
	printf("Nc  .........  %d\n", p->Nc);
	printf("Nd  .........  %d\n", p->Nd);
	printf("CompDef  ....  0x%.8x\n", p->CompDef);
	if (p->CompDef)
		dump_Dcomp(p->CompDef, p->Nc);
	printf("Ddef  .......  0x%.8x\n", p->Ddef);
	if (p->Ddef)
		dump_DataDef(p->Ddef, p->Nd);
}

static void	dump_Dtemplate(p)
struct OM_sd_Dtemplate	*p;
{
	printf("name  .......  %s\n", p->name);
	printf("size  .......  %u\n", p->size);
	printf("flag  .......  0x%.8x\n", p->flag);
	printf("Nd  .........  %d\n", p->Nd);
	printf("Ddef  .......  0x%.8x\n", p->Ddef);
	if (p->Ddef)
		dump_DataDef(p->Ddef, p->Nd);
}

void	som_dump_dictionary(name)
char	*name;
{
	if (name)
	{
		/*
		**	Dump just this name.
		*/

		OM_S_CLASSDEF	*p_acld;
		int		sts;

		sts = om$get_class(classname=name, pp_cld=&p_acld);
		if (sts == OM_E_NOSUCHCLASS)
		{
			struct OM_sd_Dtemplate	*template;

			template = (struct OM_sd_Dtemplate *)hashlookup(TemplateTbl, name);
			if (template)
			{
				printf("\ntemplate %s\n", template->name);
				dump_Dtemplate(template);
			}
			fprintf(stderr, "som_dump_dictionary: error: %s not found\n", name);
		}
		else if (1&sts)
		{
			printf("\nclass %s:\n", p_acld->s_name);
			dump_Dclass(p_acld->p_instance_def);
		}
		else
		{
			fprintf(stderr, "som_dump_dictionary: error in get_class %s\n", name);
			om$report_error(sts=sts);
		}
	}
	else
	{
		/*
		**	Dump all.
		*/

		int	i;

		for (i = 0; i < OM_Gw_numclasses; ++i)
		{
			OM_S_CLASSDEF	*p_acld;

			p_acld = OM_GA_active_classes[i];
			if (p_acld && p_acld->p_instance_def)
			{
				printf("\nclass %s:\n", p_acld->s_name);
				dump_Dclass(p_acld->p_instance_def);
			}
		}

		if (TemplateTbl)
		{
			struct OM_sd_Dtemplate	*template;

			while (template = (struct OM_sd_Dtemplate *)hashnext(TemplateTbl))
			{
				printf("\ntemplate %s:\n", template->name);
				dump_Dtemplate(template);
			}
		}
	}
}
#endif

#endif
