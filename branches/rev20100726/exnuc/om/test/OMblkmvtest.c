/* cc OMblkmvtest.c OMblkmvSUN.s */
/* cc OMblkmvtest.c OMblkmvCLIP.s */

#define SIZE	5

init_list(list, count)
int	list[];
int	count;
{
	int	i;

	for (i = 0; i < count; ++i)
		list[i] = 32 + i;
	list[i-1] = -1;
}

print_list(list, count)
int	list[];
int	count;
{
	int	i;

	for (i = 0; i < count; ++i)
		printf("list[%d] = %d\n", i, list[i]);
	printf("\n");
}

test_list(list, count, bytes, src, dest, message)
int	list[];
int	count;
int	bytes;
int	*src;
int	*dest;
char	*message;
{
	init_list(list, count);
	printf("before:\n");
	print_list(list, SIZE);

	OMblockmove(bytes, src, dest);

	printf("after %s:\n", message);
	print_list(list, SIZE);
}

main()
{
	int list[SIZE];

	test_list(list, SIZE, 8, &list[2], &list[2], "blkmv(8, list+2, list+2) dest == src");
	test_list(list, SIZE, 4, &list[2], &list[0], "blkmv(4, list+2, list+0) dest < src nooverlap");
	test_list(list, SIZE, 12, &list[2], &list[0], "blkmv(12, list+2, list+0) dest < src overlap");
	test_list(list, SIZE, 4, &list[0], &list[2], "blkmv(4, list+0, list+2) dest > src nooverlap");
	test_list(list, SIZE, 12, &list[0], &list[2], "blkmv(12, list+0, list+2) dest > src overlap");
}

