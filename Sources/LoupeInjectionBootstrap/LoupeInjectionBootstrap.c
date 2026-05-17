#include <dlfcn.h>

typedef void (*LoupeInjectorStartFunction)(void);

__attribute__((constructor))
static void LoupeInjectionBootstrap(void) {
    void *symbol = dlsym(RTLD_DEFAULT, "LoupeInjectorStart");
    if (symbol == 0) {
        return;
    }

    LoupeInjectorStartFunction start = (LoupeInjectorStartFunction)symbol;
    start();
}
