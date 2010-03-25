unsigned int	checksum(buf, size)
int	*buf;
unsigned int	size;	/* size in bytes */
{
	unsigned int	sum = 0;
	int	*c;
	int	i;

	c = buf;
	for (i = 0; i < (size / sizeof(int)); i++, c++)
		sum += *c;

	return(sum);
}
