#include <stdio.h>

int main() {
    int n, sum = 0;
    printf("Введите n: ");
    scanf("%d", &n);

    for (int i = 1; i <= n; i++) {
        if (i % 4 == 1 || i % 4 == 2) {
            sum += i;
        } else {
            sum -= i;
        }
    }

    printf("Сумма ряда: %d\n", sum);
    return 0;
}
