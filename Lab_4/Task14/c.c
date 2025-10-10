#include <stdio.h>

int main() {
    int n;
    printf("Введите n: ");
    scanf("%d", &n);
    for (int x = 1; x <= n; x++) {
        long long square = (long long)x * x;
        int temp = x;
        long long modulus = 1;

        while (temp > 0) {
            modulus *= 10;
            temp /= 10;
        }

        if (square % modulus == x) {
            printf("%d\n", x);
        }
    }
    return 0;
}
