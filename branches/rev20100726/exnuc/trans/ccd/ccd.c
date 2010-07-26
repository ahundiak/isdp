#include "stdio.h"
#include "trans.h"


extern char *getname();
DROS_S_CLASS *p_class = NULL, **p_order = NULL;
int	      class_count = 0, order_count = 0;

main(argc, argv)
int argc;
char *argv[];
{
	int sts;
	int i;

	if (argc != 2)
	{
		fprintf(stderr, "Usage: %s <classname>\n", argv[0]);
		return(1);
	}

	if (!newclass(argv[1]))
	{
		fprintf(stderr, "%s: Error in processing\n", argv[0]);
		return(2);
	}

	printf("/* - Class %s - */\n\n", argv[1]);
	printf("#include <stdio.h>\n");
	printf("#include <unistd.h>\n");
	printf("#include \"OMport.h\"\n");

	if ((class_count == 1) && strcmp(argv[1], "Root"))
	{
		sts = print_template_definition();
		check_status(sts);
	}
	else
	{
		for (i=0; i<class_count; i++)
		{
			sts = print_class_instance(i);
			check_status(sts);
		}

		sts = print_total_class_instance(class_count - 1);
		check_status(sts);
	}

	return(0);
}

newclass(classname)
char *classname;
{
	int sts;
	int i;
	char filename[32];
	int parcount;
	char parlist[20][16];
	extern int load_parents();

	for (i=0; i<class_count; i++)
	{
		if (!strcmp(classname, p_class[i].class))
			return(1);
	}

	strcpy(filename, classname);
	strcat(filename, ".");

	sts = load_parents(filename, parlist, &parcount);
	check_status(sts);

	for (i=0; i<parcount; i++)
	{
		sts = newclass(parlist[i]);
		check_status(sts);
	}

	if (!class_count)
		p_class = (DROS_p_CLASS)malloc(sizeof(DROS_S_CLASS));
	else	p_class = (DROS_p_CLASS)realloc(p_class,
				(class_count + 1) * sizeof(DROS_S_CLASS));

	if (!p_class)
	{
		fprintf(stderr, "newclass: Malloc failed for %s\n", classname);
		return(0);
	}

	p_class[class_count].p_ctype = NULL;
	p_class[class_count].p_chtype = NULL;
	p_class[class_count].p_parent = NULL;
	p_class[class_count].p_reject = NULL;
	p_class[class_count].p_node = NULL;
	p_class[class_count].class = getname(classname);
	class_count++;

	sts = dros_parddp(filename, &p_class[class_count-1], class_count-1);
	check_status(sts);

	/*
	*	If a class is unioned with Root, we must remove Root as a
	*	parent.  A Root union causes print_total_class_instance to
	*	exit prematurely.
	*/

	if (p_class[class_count-1].p_parent && 
		p_class[class_count-1].p_parent->p_next)
	{
		/*	Class is a union.	*/

		DROS_p_PARENT p_cur, *pp_cur;

		p_cur = p_class[class_count-1].p_parent;
		pp_cur = &p_class[class_count-1].p_parent;
		while (p_cur)
		{
			if (!strcmp(p_cur->class, "Root"))
				*pp_cur = p_cur->p_next;
			else
				pp_cur = &p_cur->p_next;
			p_cur = p_cur->p_next;
		}
	}

	return(1);
}

print_class_definition(class_ndx, dcount)
int class_ndx;
int *dcount;
{
	int	sts;
	short	*p_node;

	p_node = (short *)p_class[class_ndx].p_node;
	*dcount = 0;

	while (p_node)
	{
		sts = print_node_definition(p_node, dcount);
		check_status(sts);

		if (*p_node == DROS_ATTR_TYPE)
			p_node = ((DROS_p_ATTR)p_node)->p_next;
		else if (*p_node == DROS_CHAN_TYPE)
			p_node = ((DROS_p_CHANNEL)p_node)->p_next;
		else	break;
	}

	return(1);
}

print_node_definition(p_node, dcount)
short *p_node;
int *dcount;
{
	int sts;
	DROS_p_ATTR    p_attr;
	DROS_p_CHANNEL p_chan;

	if (*p_node == DROS_ATTR_TYPE)
	{
		p_attr = (DROS_p_ATTR)p_node;

		sts =
		print_attr(
			p_attr->list_size,
			p_attr->p_list,
			p_attr->p_ctype,
			p_attr->offset,
			p_attr->size,
			dcount);
		check_status(sts);
	}
	else if (*p_node == DROS_CHAN_TYPE)
	{
		p_chan = (DROS_p_CHANNEL)p_node;
		(*dcount)++;
		printf("Ddef.type = %d;\n", DROS_CHANNEL_CODE);
		printf("Ddef.offset = %d;\n", p_chan->offset);
		printf("Ddef.size = sizeof(struct OM_sd_channel_hdr);\n");
		printf("Ddef.dim = 1;\n");
		printf("write(fd, &Ddef, sizeof(Ddef));\n");
	}

	return(1);
}

dmp_field(var_type, offset, dcount)
int var_type, offset;
int *dcount;
{
	int sts;

	sts =
	output_field(
		var_type,
		offset,
		1,
		getsize(var_type, NULL),
		dcount);
	check_status(sts);

	return(1);
}

dmp_union(p_ctype, offset, dcount)
DROS_p_CTYPE p_ctype;
int offset;
int *dcount;
{
	int sts;
	DROS_p_FIELD p_field;

	if (!p_ctype) return(0);
	if (p_ctype->code != DROS_UNION_CODE)
	{
		dmp_field(p_ctype->code, offset, dcount);
		return(1);
	}

	p_field = p_ctype->p_field;
	if (p_field)
	{
		sts =
		print_attr(
			p_field->list_size,
			p_field->p_list,
			p_field->p_ctype,
			offset + p_field->offset,
			p_field->size,
			dcount);
		check_status(sts);
	}

	return(1);
}

dmp_struct(p_ctype, offset, dcount)
DROS_p_CTYPE p_ctype;
int offset;
int *dcount;
{
	int sts;
	DROS_p_FIELD p_field;

	if (!p_ctype) return(0);
	if (p_ctype->code != DROS_STRUCT_CODE)
	{
		dmp_field(p_ctype->code, offset, dcount);
		return(1);
	}

	p_field = p_ctype->p_field;
	while (p_field)
	{
		sts =
		print_attr(
			p_field->list_size,
			p_field->p_list,
			p_field->p_ctype,
			offset + p_field->offset,
			p_field->size,
			dcount);
		check_status(sts);

		p_field = p_field->p_next;
	}

	return(1);
}

print_attr(list_size, p_list, p_ctype, offset, size, dcount)
int list_size;
int p_list[];
DROS_p_CTYPE p_ctype;
int offset;
int size;
int *dcount;
{
	int sts;
	int i;
	int is_array = 0;
	int is_vla   = 0;
	int is_ptr   = 0;
	int is_bit   = 0;
	int is_str   = 0;
	int is_union = 0;
	int num_bits = 1;
	int arr_dim  = 1;
	int var_type = DROS_NULL_CODE;

	for (i=0; i<list_size; i++)
	{
		switch (p_list[i])
		{
			case DROS_ARRAY_CODE:
			is_array = 1;
			arr_dim *= (p_list[++i] & 0x7FFFFFFF);
			break;

			case DROS_VARARRAY_CODE:
			is_vla = 1;
			i++;
			break;

			case DROS_POINTER_CODE:
			case DROS_FUNCTION_CODE:
			is_ptr = 1;
			break;

			case DROS_STRUCT_CODE:
			is_str = 1;
			var_type = DROS_STRUCT_CODE;
			break;

			case DROS_UNION_CODE:
			var_type = DROS_UNION_CODE;
			is_union = 1;
			break;

			case DROS_BITFIELD_CODE:
			is_bit = 1;
			var_type = DROS_BITFIELD_CODE;
			num_bits = (p_list[++i] & 0x7FFFFFFF);
			break;

			default:
			if (i == (list_size - 1))
				var_type = p_list[i];
			else
			{
				fprintf(stderr, "error in attr list\n");
				return(0);
			}
			break;
		}
	}

	if (is_ptr) var_type = DROS_POINTER_CODE;

	if (is_vla)
	{
		size = getsize(var_type, p_ctype);

		sts =
		output_field(
			DROS_VARARRAY_CODE,
			offset,
			arr_dim,
			size,
			dcount);
		check_status(sts);

		offset = 0;
	}
	else if (is_array)
	{
		size = getsize(var_type, p_ctype);

		sts =
		output_field(
			DROS_ARRAY_CODE,
			offset,
			arr_dim,
			size,
			dcount);
		check_status(sts);

		offset = 0;
	}

	if (is_ptr)
	{
		sts =
		dmp_field(DROS_POINTER_CODE, offset, dcount);
		check_status(sts);
	}
	else if (is_str)
	{
		sts =
		dmp_struct(p_ctype, offset, dcount);
		check_status(sts);
	}
	else if (is_union)
	{
		sts =
		dmp_union(p_ctype, offset, dcount);
		check_status(sts);
/*
		sts =
		output_field(
			DROS_UNION_CODE,
			offset,
			1,
			p_ctype->size,
			dcount);
		check_status(sts);
*/
	}
	else if (is_bit)
	{
		sts =
		output_field(
			DROS_BITFIELD_CODE,
			offset,
			1,
			size,
			dcount);
		check_status(sts);
	}
	else	dmp_field(var_type, offset, dcount);

	if (is_array || is_vla)
	{
		sts =
		output_field(
			DROS_ENDBLOCK_CODE,
			0,
			0,
			0,
			dcount);
		check_status(sts);
	}

	return(1);
}

output_field(code, offset, dim, size, dcount)
int code, offset, dim, size;
int *dcount;
{
	printf("\n\
		Ddef.type = %d;\n\
		Ddef.offset = %d;\n\
		Ddef.size = %d;\n\
		Ddef.dim = %d;\n\
		write(fd, &Ddef, sizeof(Ddef));\n",
		code, offset, size, dim);
	(*dcount)++;

	return(1);
}

getsize(code, p_ctype)
int code;
DROS_p_CTYPE p_ctype;
{
	switch (code)
	{
		case DROS_CHAR_CODE:
		case DROS_UCHAR_CODE:
		return(1);

		case DROS_SHORT_CODE:
		case DROS_USHORT_CODE:
		return(2);

		case DROS_INT_CODE:
		case DROS_UINT_CODE:
		case DROS_ENUMERATION_CODE:
		case DROS_LONG_CODE:
		case DROS_ULONG_CODE:
		case DROS_FLOAT_CODE:
		case DROS_POINTER_CODE:
		case DROS_FUNCTION_CODE:
		return(4);

		case DROS_DOUBLE_CODE:
		return(8);

		case DROS_STRUCT_CODE:
		case DROS_UNION_CODE:
		return((int)p_ctype->size);
	}

	fprintf(stderr, "Unknown field type %d\n", code);
	return(0);
}

print_total_class_instance()
{
	int sts;
	int i, dcount;
	DROS_p_REJECT p_reject;
	DROS_p_PARENT p_parent;
	char *classname;
	extern int class_count;
	extern DROS_p_CLASS p_class;

	p_order = (DROS_p_CLASS *)malloc(class_count * sizeof(DROS_p_CLASS));
	p_order[0] = &p_class[0];

	for (i=0; i<class_count; i++)
		p_class[i].flag = 0;

	p_reject = p_class[class_count - 1].p_reject;
	p_parent = p_class[class_count - 1].p_parent;
	classname = p_class[class_count - 1].class;

	printf("struct %s_total_instance {\n", classname);
	printf("struct Root_instance Root;\n");

	if (strcmp(classname, "Root"))
	{
		order_count = 1;

		sts = print_parent_instance(p_parent, p_reject);
		check_status(sts);

		if (p_class[class_count - 1].p_node)
		{
			printf("struct %s_instance %s;\n", classname, classname);
		}
			p_order[order_count++] = &p_class[class_count - 1];

	}
	else	order_count = 0;

	printf("} %s;\n", classname);

	printf("struct OM_sd_ClassDef Cdef;\n");
	printf("struct OM_sd_ParentDef Pdef;\n");
	printf("struct OM_sd_DataDef Ddef;\n");

	printf("\n\n\
	main()\n\
	{\n\
		int fd;\n\
\n\
		fd = creat(\"%s.d\", 0644);\n\
		if (fd == -1)\n\
		{\n\
			perror(\"Error opening %s.d\\n\");\n\
			return(1);\n\
		}\n\
\n\
		lseek(fd, sizeof(struct OM_sd_ClassDef), SEEK_SET);\n",
	classname,
	classname);

	for (i=0; i<order_count; i++)
	{
	    if (p_order[i]->p_node == NULL) {
		printf("\
		strcpy(Pdef.Pname, \"%s\");\n\
		Pdef.offset = 0;\n\
		Pdef.size = 0;\n\
		write(fd, &Pdef, sizeof(Pdef));\n",
		p_order[i]->class,
		classname, p_order[i]->class, classname,
		p_order[i]->class);
	    }
	    else {
		printf("\
		strcpy(Pdef.Pname, \"%s\");\n\
		Pdef.offset = (int)&%s.%s - (int)&%s;\n\
		Pdef.size = sizeof(struct %s_instance);\n\
		write(fd, &Pdef, sizeof(Pdef));\n",
		p_order[i]->class,
		classname, p_order[i]->class, classname,
		p_order[i]->class);
	    }
	}

	sts = print_class_definition(class_count - 1, &dcount);
	check_status(sts);

	if (p_class[class_count - 1].p_node)
	{
		printf("\n\
		Cdef.offset = (int)&%s.%s - (int)&%s;",
		classname, classname, classname);
	}
	else	printf("\nCdef.offset = 0;");

	printf("\n\
		strcpy(Cdef.Cname, \"%s\");\n\
		Cdef.size = sizeof(struct %s_total_instance);\n\
		Cdef.Np = %d;\n\
		Cdef.Nd = %d;\n\
		lseek(fd, 0, SEEK_SET);\n\
		write(fd, &Cdef, sizeof(Cdef));\n\
		close(fd);\n\n\
		return(0);\n\t}\n",
		classname, classname, order_count, dcount);

	return(1);
}

print_template_definition()
{
	int sts;
	int dcount;
	DROS_p_ATTR p_attr;

	p_attr = (DROS_p_ATTR)p_class[0].p_node;

	printf("struct OM_sd_ClassDef Tdef;\n");
	printf("struct OM_sd_DataDef Ddef;\n");
	printf("int pos1, pos2;\n");

	printf("\n\n\
	main()\n\
	{\n\
		int fd;\n\
\n\
		fd = creat(\"%s.d\", 0644);\n\
		if (fd == -1)\n\
		{\n\
			perror(\"Error opening %s.d\\n\");\n\
			return(1);\n\
		}\n\
\n\
		Tdef.Np = -1;\n\
		Tdef.offset = 0;\n",
		p_class[0].class, p_class[0].class);

	while (p_attr)
	{
		printf("\n\
		pos1 = lseek(fd, 0, SEEK_CUR);\n\
		lseek(fd, sizeof(struct OM_sd_ClassDef), SEEK_CUR);\n");

		dcount = 0;
		p_attr->offset = 0;

		sts = print_node_definition((short *)p_attr, &dcount);
		check_status(sts);

		printf("\n\
		strcpy(Tdef.Cname, \"%s\");\n\
		Tdef.size = %d;\n\
		Tdef.Nd = %d;\n\
		pos2 = lseek(fd, 0, SEEK_CUR);\n\
		lseek(fd, pos1, SEEK_SET);\n\
		write(fd, &Tdef, sizeof(Tdef));\n\
		lseek(fd, pos2, SEEK_SET);\n\n",
		p_attr->name,
/*		getsize(DROS_STRUCT_CODE, p_attr->p_ctype), */
		(p_attr->p_ctype  ? getsize(DROS_STRUCT_CODE, p_attr->p_ctype)
				  : p_attr->size ),
		dcount);

		p_attr = (DROS_p_ATTR)p_attr->p_next;
	}

	printf("\treturn(0);}\n");

	return(1);
}

print_parent_instance(p_parent, p_reject)
DROS_p_PARENT p_parent;
DROS_p_REJECT p_reject;
{
	int sts;
	int i;
	DROS_p_REJECT p_rej;
	extern int class_count;
	extern DROS_p_CLASS p_class;

	if (!p_parent || !strcmp(p_parent->class, "Root"))
		return(1);

	if (p_parent->p_next)
	{
		sts = print_parent_instance(p_parent->p_next, p_reject);
		check_status(sts);
	}

	for (i=0; i<class_count; i++)
	{
		if (!strcmp(p_parent->class, p_class[i].class))
		{
			sts = print_parent_instance(p_class[i].p_parent, p_reject);
			check_status(sts);

			if (p_class[i].flag) return(1);

			p_class[i].flag = 1;
			if (p_class[i].p_node)
			{
				p_rej = p_reject;
				while (p_rej)
				{
					if (!strcmp(p_rej->class, p_parent->class))
						break;
					p_rej = p_rej->p_next;
				}

				if (p_rej == NULL)
				{
					printf("struct %s_instance %s;\n",
						p_parent->class, p_parent->class);
				}
				else 
					p_class[i].p_node = NULL;
			}

			p_order[order_count++] = &p_class[i];

		}
	}

	return(1);
}

print_class_instance(class_ndx)
int class_ndx;
{
	int sts;
	short *p_node;
	DROS_p_ATTR p_attr;
	DROS_p_CHANNEL p_chan;
	int var_type;
	extern DROS_p_CLASS p_class;

	p_node = p_class[class_ndx].p_node;
	if (p_node == NULL) return(1);

	while (p_node)
	{
		if (*p_node == DROS_ATTR_TYPE)
		{
			p_attr = (DROS_p_ATTR)p_node;
			var_type = p_attr->p_list[p_attr->list_size - 1];
			if (var_type == DROS_STRUCT_CODE
			||  var_type == DROS_UNION_CODE)
			{
				sts =
				print_struct(var_type, p_attr->p_ctype);
				check_status(sts);
			}

			p_node = p_attr->p_next;
		}
		else if (*p_node == DROS_CHAN_TYPE)
		{
			p_chan = (DROS_p_CHANNEL)p_node;
			p_node = p_chan->p_next;
		}
		else	break;
	}

	printf("struct %s_instance {\n", p_class[class_ndx].class);
	p_node = p_class[class_ndx].p_node;
	while (p_node)
	{
		if (*p_node == DROS_ATTR_TYPE)
		{
			p_attr = (DROS_p_ATTR)p_node;

			sts =
			print_field(
				p_attr->list_size,
				p_attr->p_list,
				p_attr->p_ctype,
				p_attr->name);
			check_status(sts);

			p_node = p_attr->p_next;
		}
		else if (*p_node == DROS_CHAN_TYPE)
		{
			p_chan = (DROS_p_CHANNEL)p_node;
			printf("struct OM_sd_channel_hdr *%s;\n", p_chan->name);
			p_node = p_chan->p_next;
		}
		else	break;
	}
	printf("};\n");

	return(1);
}

print_struct(type, p_ctype)
int type;
DROS_p_CTYPE p_ctype;
{
	int sts;
	DROS_p_FIELD p_field;
	int var_type, flag;

	if ((p_ctype == NULL) || (p_ctype->p_field == NULL))
		return(1);

	flag = p_ctype->name[strlen(p_ctype->name) + 1];
	if (flag) return(1);

	p_ctype->name[strlen(p_ctype->name) + 1] = 1;
	p_field = p_ctype->p_field;
	while (p_field)
	{
		var_type = p_field->p_list[p_field->list_size - 1];
		if (var_type == DROS_STRUCT_CODE
		||  var_type == DROS_UNION_CODE)
		{
			sts = print_struct(var_type, p_field->p_ctype);
			check_status(sts);
		}

		p_field = p_field->p_next;
	}

	if (type == DROS_STRUCT_CODE)
		printf("struct %s {\n", p_ctype->name);
	else	printf("union  %s {\n", p_ctype->name);
	p_field = p_ctype->p_field;
	while (p_field)
	{
		sts =
		print_field(
			p_field->list_size,
			p_field->p_list,
			p_field->p_ctype,
			p_field->name);
		check_status(sts);

		p_field = p_field->p_next;
	}
	printf("};\n");

	return(1);
}

print_field(list_size, p_list, p_ctype, name)
int list_size;
int *p_list;
DROS_p_CTYPE p_ctype;
char *name;
{
	int i;
	int is_array = 0;
	int is_ptr   = 0;
	int is_bit   = 0;
	int is_str   = 0;
	int is_union = 0;
	int num_bits = 1;
	int arr_dim  = 1;
	int var_type = DROS_NULL_CODE;

	for (i=0; i<list_size; i++)
	{
		switch (p_list[i])
		{
			case DROS_ARRAY_CODE:
			is_array = 1;
			arr_dim *= (p_list[++i] & 0x7FFFFFFF);
			break;

			case DROS_VARARRAY_CODE:
			printf("struct OM_sd_varlenarr_descr %s;\n", name);
			return(1);

			case DROS_POINTER_CODE:
			case DROS_FUNCTION_CODE:
			var_type = DROS_POINTER_CODE;
			is_ptr = 1;
			break;

			case DROS_STRUCT_CODE:
			is_str = 1;
			var_type = DROS_STRUCT_CODE;
			break;

			case DROS_UNION_CODE:
			is_union = 1;
			var_type = DROS_UNION_CODE;
			break;

			case DROS_BITFIELD_CODE:
			is_bit = 1;
			var_type = DROS_BITFIELD_CODE;
			num_bits = (p_list[++i] & 0x7FFFFFFF);
			break;

			default:
			if (i == (list_size - 1))
				var_type = p_list[i];
			else
			{
				fprintf(stderr, "error in attr list: val=%d, index=%d\n",
					p_list[i], i);
				return(0);
			}
			break;
		}
	}

	switch (var_type)
	{
		case DROS_CHAR_CODE:
		printf("char "); break;

		case DROS_UCHAR_CODE:
		printf("unsigned char "); break;

		case DROS_SHORT_CODE:
		printf("short "); break;

		case DROS_USHORT_CODE:
		printf("unsigned short "); break;

		case DROS_INT_CODE:
		case DROS_BITFIELD_CODE:
		printf("int "); break;

		case DROS_UINT_CODE:
		printf("unsigned int "); break;

		case DROS_ENUMERATION_CODE:
		case DROS_LONG_CODE:
		printf("long "); break;

		case DROS_ULONG_CODE:
		printf("unsigned long "); break;

		case DROS_FLOAT_CODE:
		printf("float "); break;

		case DROS_DOUBLE_CODE:
		printf("double "); break;

		case DROS_POINTER_CODE:
		case DROS_FUNCTION_CODE:
		printf("char *"); break;

		case DROS_NULL_CODE:
		printf("void "); break;

		case DROS_STRUCT_CODE:
		if (p_ctype == NULL)
		{
			fprintf(stderr, "print_field: ERROR in p_ctype = NULL\n");
			break;
		}
		printf("struct %s ", p_ctype->name); break;

		case DROS_UNION_CODE:
		if (p_ctype == NULL)
		{
			fprintf(stderr, "print_field: ERROR in p_ctype = NULL\n");
			break;
		}
		printf("union %s ", p_ctype->name); break;

		default:
		fprintf(stderr, "Unknown field type %d\n", var_type);
		return(0);
	}

	if (var_type != DROS_POINTER_CODE && is_ptr) printf("*");
	printf("%s", name);
	if (is_bit)   printf(":%d", num_bits);
	if (is_array) printf("[%d]", arr_dim);
	printf(";\n");

	return(1);
}

