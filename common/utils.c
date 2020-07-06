void int_to_ascii(int n, char* str) {
  int sign = 1;
  if (n < 0) {
    sign = -1;
    n = -n;
  }

  int i = 0;
  for (; n; n /= 10) {
    str[i++] = '0' + (n % 10);
  }
  if (i == 0) {
    str[i++] = '0';
  }
  if (sign < 0) {
    str[i++] = '-';
  }
  str[i] = 0;

  for (int j = 0; j < i / 2; ++j) {
    char tmp = str[j];
    str[j] = str[i-1-j];
    str[i-1-j] = tmp;
  }
}

