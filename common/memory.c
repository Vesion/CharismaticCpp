void memory_copy(const char* src, char* dst) {
  for (; *src != 0; ++src, ++dst) {
    *dst = *src;
  }
}

void memory_copy_n(const char* src, char* dst, int nbytes) {
  for (int i = 0; i < nbytes; ++i) {
    *(dst + i) = *(src + i);
  }
}

void memory_set(char* dst, char c, int nbytes) {
  for (int i = 0; i < nbytes; ++i) {
    *(dst + i) = c;
  }
}

