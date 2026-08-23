#ifndef RANDOM_SEED_H
#define RANDOM_SEED_H

float rand_from_seed(inout uint seed) {
    int k;
    int s = int(seed);
    if (s == 0) s = 305420679; // 种子0保护

    k = s / 127773;
    s = 16807 * (s - k * 127773) - 2836 * k;

    if (s < 0) s += 2147483647; // 溢出修正

    seed = uint(s);
    return float(seed % uint(65536)) / 65535.0; // [0,1]范围
}

float rand_from_seed_m1_p1(inout uint seed) {
    return rand_from_seed(seed) * 2.0 - 1.0; // [-1,1]范围
}

#endif