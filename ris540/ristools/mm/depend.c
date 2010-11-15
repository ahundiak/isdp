/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							depend.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

/*
**	INCLUDES
*/
#include "mm.h"

/*
**	DEFINES
*/
#define MAX_DEPENDS		150
#define MAX_FILES		500

/*
**	TYPES
*/
typedef struct file_s
{
	char	name[PATH_MAX];
	int		depends_count;
	int		depends[MAX_DEPENDS];
} file_s; 

/*
**	FUNCTION PROTOTYPES
*/
#define depend_c
#include "depend.prt"
#include "output.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
int		depends_count = 0;
int		files_count = 0;
#if defined(__hpux__)
static int              depends[MAX_DEPENDS];
static file_s   files[MAX_FILES];
#else
int		depends[MAX_DEPENDS];
file_s	files[MAX_FILES];
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

static int add_depend(
	int index)
{
	int i;

	DBG(("add_depend(index:%d)\n", index));

	for (i = 0; i < depends_count; i++)
	{
		if (index == depends[i])
		{
			DBG(("add_depend: returning 0\n"));
			return 0;
		}
	}

	if (depends_count == MAX_DEPENDS)
	{
		fprintf(stderr, "%s: increase MAX_DEPENDS(%d) in \"%s\".\n",
			exe, MAX_DEPENDS, __FILE__);
		EXIT(1);
	}

	depends[depends_count++] = index;

	DBG(("add_depend:returning 1\n"));
	return 1;
}

/******************************************************************************/

static void get_depends(
	int index)
{
	int i;

	DBG(("get_depends(index:%d)\n", index));

	if (index < 0 || index >= files_count)
	{
		fprintf(stderr,
			"get_depends: Internal error: invalid index:%d\n",
			index);
		EXIT(1);
	}

	if (add_depend(index))
	{
		for (i = 0; i < files[index].depends_count; i++)
		{
			get_depends(files[index].depends[i]);
		}
	}

	DBG(("get_depends:returning\n"));
}

/******************************************************************************/

extern  void write_depends(
	char *obj_filename,
	int	index)
{
	int i;

	DBG(("write_depends(obj_filename:<%s> index:%d)\n", obj_filename, index));

	get_depends(index);

	output("\n%s:", obj_filename);
	for (i = 0; i < depends_count; i++)
	{
		output("\\\n\t%s", files[depends[i]].name);
	}
	output("\n");

	depends_count = 0;

	DBG(("write_depends:returning\n"));
}

/******************************************************************************/

extern int add_file(
	char	*name,
	int		*indexp)
{
	int i;

	DBG(("add_file(name:<%s> indexp:0x%x)\n", name, indexp));

	for (i = 0; i < files_count; i++)
	{
		if (!strcmp(name, files[i].name))
		{
			*indexp = i;
			DBG(("add_file: *indexp:%d returning 0\n", *indexp));
			return 0;
		}
	}

	if (files_count == MAX_FILES)
	{
		fprintf(stderr, "%s: increase MAX_FILES(%d) in \"%s\".\n",
			exe, MAX_FILES, __FILE__);
		EXIT(1);
	}

	strcpy(files[files_count].name, name);
	files[files_count].depends_count = 0;
	*indexp = files_count++;

	DBG(("add_file: *indexp:%d returning 1\n", *indexp));
	return 1;
}

/******************************************************************************/

extern int add_file_depend(
	int		file_index,
	int		depend_index)
{
	int i;

	DBG(("add_file_depend(file_index:%d depend_index:%d)\n",
		file_index,depend_index));

	if (file_index < 0 || file_index >= files_count)
	{
		fprintf(stderr,
			"add_file_depend: Internal error: invalid file_index:%d\n",
			file_index);
		EXIT(1);
	}

	for (i = 0; i < files[file_index].depends_count; i++)
	{
		if (files[file_index].depends[i] == depend_index)
		{
			DBG(("add_file_depend:returning 1\n"));
			return 0;
		}
	}

	if (files[file_index].depends_count == MAX_DEPENDS)
	{
		fprintf(stderr, "%s: increase MAX_DEPENDS(%d) in \"%s\".\n",
			exe, MAX_DEPENDS, __FILE__);
		EXIT(1);
	}

	files[file_index].depends[files[file_index].depends_count++] = depend_index;

	DBG(("add_file_depend:returning 1\n"));
	return 1;
}

/******************************************************************************/
