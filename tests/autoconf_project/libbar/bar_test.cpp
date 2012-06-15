#include "bar.h"
#include <cassert>
#include <iostream>

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
    std::cout << "this is bar_test, hello\n";
    test_negative();
    test_positive();
    test_zero();
}
