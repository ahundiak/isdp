#include "stdio.h"
#include "trans.h"
#include "sys/types.h"
#include "sys/stat.h"
#include "fcntl.h"
#include "OMport.h"

struct OM_sd_ClassDef Cdef;
struct OM_sd_ParentDef Pdef;
struct OM_sd_DataDef Ddef;

main(argc, argv)
int argc;
char *argv[];
{
	int i, fd;
	char errmsg[80];

	if (argc != 2)
	{
		fprintf(stderr, "Usage: %s <class_defn_file> [ class ... ]\n",
				argv[0]);
		exit(1);
	}

	fd = open(argv[1], O_RDONLY);
	if (fd == -1)
	{
		sprintf(errmsg, "Error opening %s\n", argv[1]);
		perror(errmsg);
		exit(2);
	}

	while (1)
	{
		if (!decode_info(fd))
			break;
	}

	close(fd);
}

decode_info(fd)
int fd;
{
	int i, bit_flag, union_flag;

	if (read(fd, &Cdef, sizeof(Cdef)) != sizeof(Cdef))
		return(0);

	for (i=0; i<Cdef.Np; i++)
	{
		if (read(fd, &Pdef, sizeof(Pdef)) != sizeof(Pdef))
			return(0);
	}

	bit_flag = 0;
	union_flag = 0;
	for (i=0; i<Cdef.Nd; i++)
	{
		if (read(fd, &Ddef, sizeof(Ddef)) != sizeof(Ddef))
			return(0);
		if ((Ddef.type == DROS_BITFIELD_CODE) && !bit_flag)
		{
			bit_flag = 1;
			printf("%s: BITFIELD\n", Cdef.Cname);
		}

		if ((Ddef.type == DROS_UNION_CODE) && !union_flag)
		{
			union_flag = 1;
			printf("%s: UNION\n", Cdef.Cname);
		}
	}

	return(1);
}
