CXX = g++
CFLAGS = -fPIC -Wall -Wextra
LDFLAGS = -shared
RM = rm -f

all: time_extern time_inline

libnoop.so: noop.cpp
	$(CXX) ${LDFLAGS} -o $@ $^

time_extern: libnoop.so time.cpp
	$(CXX) $(CFLAGS) -DEXTERN -L$(PWD) -lnoop -Wl,-rpath,$(PWD) time.cpp -o $@

time_inline: time.cpp
	$(CXX) $(CFLAGS) time.cpp -o $@

dump: all
	-objdump -CSr time_extern > time_extern.s
	-objdump -CSr time_inline > time_inline.s

clean:
	-$(RM) *.o *.so *.s
	-$(RM) time_extern time_inline
