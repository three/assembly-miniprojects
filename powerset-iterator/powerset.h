#pragma once

#include <stdint.h>

struct iterator {
    uint64_t *vals;
    uint64_t length;
    uint64_t _state;
    uint64_t _max;
    uint64_t *_input;
} __attribute((__packed__));

int powerset_init(uint64_t *input, int length, struct iterator *buffer);
int powerset_next(struct iterator *buffer);
