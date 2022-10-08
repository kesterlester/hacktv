
CC      := $(CROSS_HOST)gcc
PKGCONF := $(CROSS_HOST)pkg-config
CFLAGS  := -g -Wall -pthread -O3 $(EXTRA_CFLAGS)
LDFLAGS := -g -lm -pthread $(EXTRA_LDFLAGS)
OBJS    := hacktv.o common.o fir.o vbidata.o teletext.o wss.o video.o mac.o dance.o eurocrypt.o videocrypt.o videocrypts.o syster.o acp.o vits.o nicam728.o test.o ffmpeg.o file.o hackrf.o
PKGS    := libavcodec libavformat libavdevice libswscale libswresample libavutil libhackrf $(EXTRA_PKGS)

SOAPYSDR := $(shell $(PKGCONF) --exists SoapySDR && echo SoapySDR)
ifeq ($(SOAPYSDR),SoapySDR)
	OBJS += soapysdr.o
	PKGS += SoapySDR
	CFLAGS += -DHAVE_SOAPYSDR
endif

FL2K := $(shell $(PKGCONF) --exists libosmo-fl2k && echo fl2k)
ifeq ($(FL2K),fl2k)
	OBJS += fl2k.o
	PKGS += libosmo-fl2k
	CFLAGS += -DHAVE_FL2K
endif

CFLAGS  += $(shell $(PKGCONF) --cflags $(PKGS))
LDFLAGS += $(shell $(PKGCONF) --libs $(PKGS))

all: hacktv

hacktv: $(OBJS)
	$(CC) -o hacktv $(OBJS) $(LDFLAGS)

%.o: %.c Makefile
	$(CC) $(CFLAGS) -c $< -o $@
	@$(CC) $(CFLAGS) -MM $< -o $(@:.o=.d)

# Macports wants the install phase to be "make install DESTDIR=blah" 
# (see https://guide.macports.org/chunked/reference.phases.html ) so 
# to allow both macports and non-macports builds, we reallly should
# either detect macports or DESTDIR and act accordingly. However, for
# now let's just assume it's only macports trying to build us.
install:
        mkdir -p $(DESTDIR)/bin/
	cp -f hacktv $(DESTDIR)/bin/
#OLD	cp -f hacktv $(PREFIX)/usr/local/bin/

clean:
	rm -f *.o *.d hacktv hacktv.exe

-include $(OBJS:.o=.d)

