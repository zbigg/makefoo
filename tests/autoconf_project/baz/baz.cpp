extern int a(int, int); // from ../libfoo/foo.cpp
extern "C" int spam(const char* a); // from ../libfoo/spam.cpp

int main()
{
    a(0,0);
    spam("eggs");
}

