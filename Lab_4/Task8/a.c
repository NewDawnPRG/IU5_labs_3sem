#include <stdio.h>
#include <string.h>

void createAlternatingNumber(char *n) {
    char result[100] = "";
    int length = strlen(n);

    for (int i = 0; i < length; i++) {
        result[i * 2] = n[i];
        result[i * 2 + 1] = '0';
    }

    result[length * 2 + 1] = '\0';

    printf("Результат: %s\n", result);
}

int main() {
    char n[100];

    printf("Введите число n: ");
    scanf("%s", n);

    createAlternatingNumber(n);
    return 0;
}
