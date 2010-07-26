
#include "stdio.h"
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

	if (argc < 2)
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

	i = (argc > 2)?(argc - 2):-1;
	while (i)
	{
		if (!decode_info(fd, &i, &argv[2]))
			break;
	}

	close(fd);
}

decode_info(fd, count, list)
int fd;
int *count;
char *list[];
{
	int i, skip_bytes;
	static char *dros_codenames[] =
			 {"NULL", "CHAR", "UCHAR", "SHORT", "USHORT", "INT",
                          "UINT", "LONG", "ULONG", "FLOAT", "DOUBLE", "STRING",
                          "CHANNEL", "POINTER", "ARRAY", "VARARRAY",
                          "BITFIELD", "FUNCTION", "STRUCT", "UNION", 
                          "ENUMERATION", "ENUM_FIELD", "CLASS" };

	if (read(fd, &Cdef, sizeof(Cdef)) != sizeof(Cdef))
		return(0);

	if (*count > 0)
	{
		for (i=0; i < *count; i++)
			if (!strcmp(list[i], Cdef.Cname))
				break;
		if (i >= *count)
		{
			skip_bytes = sizeof(struct OM_sd_ParentDef) *
					((Cdef.Np >= 0)?Cdef.Np:0) +
				     sizeof(struct OM_sd_DataDef) * Cdef.Nd;
			lseek(fd, skip_bytes, SEEK_CUR);
			return(1);
		}

		(*count)++;
	}
	
    if (Cdef.Np >= 0)
    {
	printf("\n\nClass: %s\n", Cdef.Cname);
	printf("Size: %d bytes\n", Cdef.size);
	printf("Offset: %d bytes\n", Cdef.offset);
	printf("No of parents: %d\n\n\n", Cdef.Np);

	if (Cdef.Np)
	{
		printf("--------------------------------\n");
		printf("     Parent       Offset    Size\n");
		printf("--------------------------------\n");

		for (i=0; i<Cdef.Np; i++)
		{
			if (read(fd, &Pdef, sizeof(Pdef)) != sizeof(Pdef))
				return(0);

			printf("%-16s    %-6d    %-4d\n",
				Pdef.Pname,
				Pdef.offset,
				Pdef.size);
		}

		printf("--------------------------------\n\n\n\n");
	}
    }
    else
    {
	printf("\n\nTemplate: %s\n", Cdef.Cname);
	printf("Size: %d bytes\n", Cdef.size);
    }

	if (Cdef.Nd)
	{
		printf("----------------------------------------\n");
		printf("   DataType       Offset    Size    Dim\n");
		printf("----------------------------------------\n");

		for (i=0; i<Cdef.Nd; i++)
		{
			if (read(fd, &Ddef, sizeof(Ddef)) != sizeof(Ddef))
				return(0);

			if (Ddef.type == -1)
				printf("ENDARRAY           -         -       -\n");
			else	printf("%-15s    %-6d    %-4d    %-4d\n",
					dros_codenames[Ddef.type],
					Ddef.offset,
					Ddef.size,
					Ddef.dim);
		}

		printf("----------------------------------------\n\n\n\n");
	}

	return(1);
}
