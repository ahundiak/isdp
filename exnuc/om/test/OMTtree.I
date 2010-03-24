class implementation Root;

/*
*	Tester for OMbtree, OMrtree, DIbtree.
*
*	Tests should be run on BIG_ENDIAN machines first.  Write out the
*	object space.  Then run the same test on LITTLE_ENDIAN reading
*	the previous object space.
*
*	OMbtree test(s):
*		test #1:
*		  BIG_ENDIAN:     OMTtree.x -w -b 1 foo.os 1>foo.out 2>&1
*		  LITTLE_ENDIAN:  OMTtree.x -o 20 -b 1 foo.os 1>foo2.out 2>&1
*		  diff foo.out foo2.out
*/

#include <exsysdep.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <limits.h>
#include <sys/param.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMintprims.h"
#include "OMDB.h"
#include "OMindex.h"
#include "OMrtreedef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMport.h"

from OMrtree import OMrtree_constr, add;
from OMbtree import OMbtree_constr, btree_dump;
from OMFiledOS import write;

%safe
static char	*Image = 0;
static int	NumKeys = 1000;
%endsafe

#define FLAGS           "b:rdwn:o:p:"
#define ERROR(E)	(fprintf E, exit(1))
#define OM_ERROR(E,S)	(fprintf E, om$report_error(sts=S), exit(S))
#define DI_ERROR(E,S)	(fprintf E, di$report_error(sts=S), exit(S))
#define GET_IMAGE_NAME	((Image=strrchr(argv[0],'/'))?++Image:(Image=argv[0]))

/******************************************************************************/

static void     print_usage()
{
	fprintf(stderr, "\
usage: %s [-w] [-n num] [-o objid] [-p path] {-r | -d | -b type} file\n\
-w\t\tWrite the object space at the end of the test.\n\
-n num\t\tCreate num keys if file is new.  Default is 1000.\n\
-o objid\tObject id of the tree.  Must be specified for existing file.\n\
-p path\t\tProduct path.  Used to load dictionary info.\n\
-r\t\tRun rtree test.\n\
-d\t\tRun DIbtree test.\n\
-b type\t\tRun OMbtree test with tree type: 0:ascii, 1:char 2:integer.\n\
file\t\tName of object space to create for test.\n\
", Image);
	exit(1);
}

/******************************************************************************/

static void	get_object(p_objid, n, osnum)
OM_S_OBJID	*p_objid;
int		n;
OMuword		osnum;
{
	int	sts;

	sts = om$construct(classname="A", osnum=osnum, p_objid=p_objid);
	if (!(1&sts))
		OM_ERROR((stderr,"error in om$construct(A[%d])\n", n), sts);
}

/******************************************************************************/

static void	get_range(p_lfkey)
DB_3D_DBL_BOX	*p_lfkey;
{
	double		a, b, c;

#define RAND   (mrand48())
#define DRAND  (drand48())
#define HI_VAL (2147483647)

	a =  RAND;
	b =  RAND;
	c =  RAND;
	while (a > HI_VAL - 100)
		a = RAND;
	while (b > HI_VAL - 100)
		b = RAND;
	while (c > HI_VAL - 100)
		c = RAND;

	p_lfkey->xmin = a;
	while (a <= p_lfkey->xmin)
		a = RAND;
	p_lfkey->ymin = b;
	while (b <= p_lfkey->ymin)
		b = RAND;
	p_lfkey->zmin = c;
	while (c <= p_lfkey->ymin)
		c = RAND;
	p_lfkey->xmax = a;
	p_lfkey->ymax = b;
	p_lfkey->zmax = c;
}

/******************************************************************************/

static void	rtree_test(new, osnum, tree_objid)
int		new;
OMuword		osnum;
OM_S_OBJID	tree_objid;
{
	int	sts, ret;

	if (new)
	{
		printf("Constructing rtree\n");
		sts = om$construct(classname="OMrtree",
			osnum=osnum,
			p_objid=&tree_objid,
			msg=message OMrtree.OMrtree_constr(RTREE_3D_FLT, &ret));
		if (!(sts&1))
			OM_ERROR((stderr, "error in constructing rtree\n"), sts);
		if (ret != DB_SUCCESS)
			ERROR((stderr, "error return from rtree create, return code: %d\n", ret));
	}

	printf("rtree_test: tree_objid %u\n", tree_objid);

	if (new)
	{
		OM_S_KEY_DESC	rtree_key;
		DB_3D_DBL_BOX	lfkey;		
		int		i;

		printf("Adding %d keys\n", NumKeys);

		srand48(1);

		rtree_key.type = KEY_3D_DBL;
		rtree_key.key.p_3ddbl = &lfkey;

		for (i = 0; i < NumKeys; ++i)
		{
			OM_S_OBJID	objid;

			get_object(&objid, i, osnum);
			get_range(&lfkey);

			sts = om$send(msg=message OMrtree.add(&rtree_key,
						&objid, 0, &ret),
				senderid=NULL_OBJID,
				targetos=osnum,
				targetid=tree_objid);
			if (!(sts&1))
				OM_ERROR((stderr, "error in OMrtree.add(%u) to %u.%u\n", objid, osnum, tree_objid), sts);
			if (ret != DB_SUCCESS)
				ERROR((stderr, "error in OMrtree.add(%u) %d\n", objid, ret));
		}
	}

	DB_dump_rtree3df(osnum, tree_objid);
}

/******************************************************************************/

static void	get_name(p_name, dirname)
char	**p_name;
char	*dirname;
{
	static char	fullname[MAXPATHLEN];
	char		name[MAXPATHLEN];
	int		len, i;

	/*  Get random length between 4 and 53 characters. */

	len = (rand() % 50) + 4;

	/*  Generate random alpha string of length characters. */

	for (i = 0; i < len; ++i)
		name[i] = (rand() % 26) + 'a';
	name[i] = 0;

	/*  Append directory name. */

	strcpy(fullname, dirname);
	DIstrcat(fullname, name);
	*p_name = fullname;
}

/******************************************************************************/

static void	get_single_char_name(p_name)
char	**p_name;
{
	static char	name[2];

	name[0] = (rand() % 26) + 'a';
	name[1] = 0;

	*p_name = name;
}

/******************************************************************************/

static void	dump_dibtree(filename, dirname)
char	*filename;
char	*dirname;
{
	int	i, count;
	char	regexp[MAXPATHLEN];

	DIstrcat(regexp, filename);
	DIstrcat(regexp, dirname);
	DIstrcat(regexp, "*");

	printf("================= Dumping DIbtree \":%s:%s:*\" =====\n", filename, dirname);

	di$start_dump(regexp=regexp, ptr=&count);
	for (i = 0; i < count; ++i)
	{
		char	line[MAXPATHLEN];
		DIgrid	grid;

		line[0] = 0;
		di$fetch_dump(line=line, index=i, p_grid=&grid);
		printf("%u\t\"%s\"\n", grid.objid, line);
	}
	printf("====================================================\n");
}

/******************************************************************************/

static void	dibtree_test(new, osnum, filename)
int	new;
OMuword	osnum;
char	*filename;
{
	OM_S_OBJID	tree_objid;
	int		sts;
	char		*dirname = "test";

	tree_objid = NULL_OBJID;

	if (new)
	{
		printf("Constructing directory \"%s\"\n", dirname);
		sts = di$mkdir(dirname=dirname,
			osnum=osnum,
			p_dirid=&tree_objid);
		if (!(sts&1))
			DI_ERROR((stderr, "error in di$mkdir\n"), sts);
		printf("dibtree_test: tree_objid %u\n", tree_objid);
	}

	if (new)
	{
		int	i;

		printf("Adding %d names\n", NumKeys);

		srand(1);

		for (i = 0; i < NumKeys; ++i)
		{
			OM_S_OBJID	objid;
			char		*name;

			get_object(&objid, i, osnum);
			get_name(&name, dirname);

			sts = di$add_name (objname=name,
					osnum=osnum,
					objid=objid);
			if (!(sts&1))
				DI_ERROR((stderr, "error in di$add_name(%s)\n", name), sts);
		}
	}

	dump_dibtree(filename, dirname);
}

/******************************************************************************/

static int	integer_compare(key1_ptr, key2_ptr, length1, length2)
int	*key1_ptr, *key2_ptr;
int	length1, length2;
{
	return *key1_ptr > *key2_ptr ? 1 : *key1_ptr == *key2_ptr ? 0 : -1;
}

static void	ombtree_test(new, osnum, tree_objid, tree_type, single_char)
int		new;
OMuword		osnum;
OM_S_OBJID	tree_objid;
char		tree_type;
int		single_char;
{
	int	sts, ret;

	if (new)
	{
		printf("Constructing %s OMbtree\n",
			BTREE_INTEGER==tree_type?"integer":"string");
		sts = om$construct(classname="OMbtree",
			osnum=osnum,
			p_objid=&tree_objid,
			msg=message OMbtree.OMbtree_constr(tree_type, &ret));
		if (!(sts&1))
			OM_ERROR((stderr, "error in constructing btree\n"), sts);
		if (ret != DB_SUCCESS)
			ERROR((stderr, "error return from btree create, return code: %d\n", ret));
	}

	printf("ombtree_test: tree_objid %u\n", tree_objid);

	if (new)
	{
		int		i;
		OM_S_KEY_DESC	btree_key;
		int		key;
		int		(*compare)();

		printf("Adding %d keys\n", NumKeys);

		srand(1);
		if (BTREE_INTEGER == tree_type)
		{
			btree_key.type = KEY_INTEGER;
			btree_key.key.p_integer = &key;
			compare = integer_compare;
		}
		else
		{
			btree_key.type = KEY_STRING;
			compare = strcmp;
		}

		for (i = 0; i < NumKeys; ++i)
		{
			OM_S_OBJID	objid;

			get_object(&objid, i, osnum);

			if (BTREE_INTEGER == tree_type)
				key = rand();
			else
			{
				if (!single_char)
					get_name(&btree_key.key.p_string, ":test");
				else
					get_single_char_name(&btree_key.key.p_string);
			}

			sts = om$send(msg=message OMbtree.add(&btree_key,
						&objid, compare, &ret),
				senderid=NULL_OBJID,
				targetos=osnum,
				targetid=tree_objid);
			if (!(sts&1))
				OM_ERROR((stderr, "error in OMbtree.add(%u)\n", objid), sts);
			if (ret != DB_SUCCESS)
				ERROR((stderr, "error in OMbtree.add(%u) %d\n", objid, ret));
		}
	}

        sts = om$send(msg=message OMbtree.btree_dump(tree_type),
		targetos=osnum,
		targetid=tree_objid,
		senderid=NULL_OBJID);
	if (!(1&sts))
		OM_ERROR((stderr, "error in OMbtree.btree_dump()\n"), sts);
}

/******************************************************************************/

main(argc, argv)
int	argc;
char	*argv[];
{
	int		sts;
	int		c;
	OM_S_OBJID	oso_objid;
	OM_S_OBJID	objid = NULL_OBJID;
	OMuword		osnum;
	extern char	*optarg;
	extern int	optind, opterr;
	char		*path = 0;
	int		new = 0;
	int		writeOS = 0;
	int		rtree = 0;
	int		dibtree = 0;
	int		ombtree = 0;
	char		btype = 0;
	int		single_char = 0;

	GET_IMAGE_NAME;

	while (EOF != (c = getopt(argc, argv, FLAGS)))
		switch (c)
		{
		case 'b':
			if (rtree || dibtree)
				print_usage();
			ombtree = 1;
			btype = (char)atoi(optarg);
			if (2 == btype)
				btype = BTREE_INTEGER;
			else if (0 == btype || 1 == btype)
			{
				if (1 == btype)
					single_char = 1;
				btype = BTREE_STRING;
			}
			else
				print_usage();
			break;

		case 'r':
			if (ombtree || dibtree)
				print_usage();
			rtree = 1;
			break;

		case 'd':
			if (ombtree || rtree)
				print_usage();
			dibtree = 1;
			break;

		case 'w':
			writeOS = 1;
			break;

		case 'n':
			NumKeys = atoi(optarg);
			break;

		case 'o':
			objid = atoi(optarg);
			break;

		case 'p':
			path = optarg;
			break;

		case '?':
		default:
			print_usage();
			break;
		}

	if (optind >= argc || (!rtree && !dibtree && !ombtree))
		print_usage();

	printf("Initializing OM\n");
	sts = om$runtime_init();
	if (!(sts & 1))
		OM_ERROR((stderr, "error in om$runtime_init()\n"), sts);

#ifdef _BIG_ENDIAN
	if (path)
	{
		char	buf[MAXPATHLEN];

		strcpy(buf, path);
		strcat(buf, "/config/class_defns");
		printf("Loading dictionary \"%s\"\n", buf);
		sts = som_load_dictionary(buf);
		if (!(sts&1))
			OM_ERROR((stderr, "error in som_load_dictionary(%s)\n", buf), sts);

		strcpy(buf, path);
		strcat(buf, "/config/dload/port");
		printf("Loading special functions from \"%s\"\n", buf);
		sts = som_dload_conversion_functions(buf);
		if (!(sts&1))
			OM_ERROR((stderr, "error in som_dload_conversion_functions(%s)\n", buf), sts);
	}
#endif

	printf("Constructing object space \"%s\"\n", argv[optind]);
	sts = om$construct_os(classname="OMFiledOS", osnum=&osnum,
			osname=argv[optind], p_objid=&oso_objid,
			di_logical=argv[optind]);
	if (!(1&sts))
		OM_ERROR((stderr, "error in om$construct_os(%s)\n", argv[optind]), sts);

	new = (sts == OM_I_READ_FROM_FILE ? 0 : 1);
	if (!dibtree && !new && IF_NULL_OBJID(objid))
	{
		fprintf(stderr, "error: -o must be specified for existing file\n");
		print_usage();
	}

	if (rtree)
		rtree_test(new, osnum, objid);
	else if (dibtree)
		dibtree_test(new, osnum, argv[optind]);
	else if (ombtree)
		ombtree_test(new, osnum, objid, btype, single_char);

	if (writeOS)
	{
		printf("Deleting object space \"%s\"\n", argv[optind]);
		sts = om$send(msg=message OMFiledOS.delete(0),
			senderid=NULL_OBJID,
			targetid=oso_objid,
			targetos=osnum);
		if (!(1&sts))
			OM_ERROR((stderr, "error in OMFiledOS.delete(\"%s\")\n", argv[optind]), sts);
	}

	exit(0);
}

EX_error_box(vs, msg, title)
int   vs;
char  *msg, *title;
{
   if (!vs || !msg || !title)
   {
      printf("\n\nPoor Man's EX_error_box:\n");
      printf("\n+-------------------+\n");
      printf("|                   |\n");
      printf("|       x  x        |\n");
      printf("|         >         |\n");
      printf("|       ____        |\n");
      printf("|        U          |\n");
      printf("|                   |\n");
      printf("+-------------------+\n\n");
   }
   return(1);
}

end implementation Root;
