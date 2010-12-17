dates ACC \
      COMPILSUP \
      COMPTOOLS \
      INGRUTIL \
      LIBXC \
      SYSTEMV \
      SUNCC \
      UNIXBOOT  |
  cut -c1-18,20-73 |
  sed 's/^/  /'

echo
dates BAGTOOLS |
  cut -c1-18,20-73 |
  sed 's/^/  /'
