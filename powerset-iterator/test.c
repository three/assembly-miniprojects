#include <malloc.h>
#include <stdlib.h>
#include <stdint.h>

#include "powerset.h"

void print_it(struct iterator *it) {
    printf("STRUCT\n"
            "  vals   = %i\n"
            "  length = %i\n"
            "  _state = %i\n"
            "  _max   = %i\n"
            "  _input = %i\n", it->vals, it->length, it->_state, it->_max, it->_input);
}


int main() {
    int errorcode;
    uint64_t set[9] = { 1,2,3,4,5,6,7,8,9 };

    struct iterator *it = malloc(sizeof (struct iterator));

    if ( !it ) {
        perror("Error allocating buffer: \n");
        exit(1);
    }

    printf("INIT\n"
            "  set    = %i\n"
            "  length = %i\n"
            "  buffer = %i\n", set, 9, it);

    errorcode = powerset_init(set, 9, it);
    print_it(it);
    if (errorcode) {
        printf("Recieved error code %i from powerset_init!\n", errorcode);
        exit(1);
    }


    do {
        printf("LENGTH: %i\n", it->length);
        for (int i=0;i<it->length;i++)
            printf("  %i\n", it->vals[i]);
        print_it(it);
    } while (!(errorcode = powerset_next(it)));

    if (errorcode != 1) {
        printf("Recieved error code %i from powerset_next!\n", errorcode);
        exit(1);
    }

    printf("DONE\n");
    exit(0);
}
