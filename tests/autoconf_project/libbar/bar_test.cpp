#include "bar.h"
#include <cassert>

void test_zero()
{
    assert(bar(0,10) == 10);
}

void test_negative()
{
    assert(bar(-10,7) == 7);
}

void test_positive()
{
    assert(bar(10,3) == -3);
}

int main()
{
    test_negative();
    test_positive();
    test_zero();
}
