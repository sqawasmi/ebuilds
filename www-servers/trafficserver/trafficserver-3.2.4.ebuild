# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit autotools eutils

DESCRIPTION="Apache Traffic Server is a fast, scalable and extensible HTTP/1.1 compliant caching proxy server."
HOMEPAGE="http://trafficserver.apache.org/"
SRC_URI="mirror://apache/${PN}/${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"
IUSE="+api +cap +lzma wccp profiler"

DEPEND="
	lzma? ( app-arch/xz-utils )
	cap? ( sys-libs/libcap )
	>=dev-libs/libpcre-4.2
	dev-libs/openssl
	sys-libs/zlib
	dev-lang/tcl
	dev-libs/expat
	sys-devel/autoconf
	sys-devel/automake
	sys-devel/libtool"

RDEPEND="${DEPEND}"

pkg_setup() {
	
	ebegin "Creating Apache TrafficServer user and group"
	enewgroup ${PN}
	enewuser ${PN} -1 -1 -1 ${PN}
	eend $?
	
	if use !api; then
		ewarn "you are removing support for API and Plugins by disabling api"
	fi
}

src_configure() {
	local myconf= 
	
	use lzma	&& myconf+=" --with-lzma"
	use api		&& myconf+=" --enable-api"
	use cap		&& myconf+=" --enable-posix-cap"
	use wccp	&& myconf+=" --enable-wccp"
	use profiler	&& myconf+=" --with-profiler"
	
	./configure \
		--enable-layout=Gentoo \
		--with-user=${PN} \
		--with-group=${PN} \
		--sysconfdir=/etc/${PN} \
		--without-lzma \
		--disable-api \
		--disable-posix-cap \
		--disable-wccp \
		--without-profiler \
		--disable-ccache \
		--enable-tproxy=auto \
		${myconf} || die "configure failed"
		# standalone-iocore is broken until now!
		#--enable-standalone-iocore \
}

src_compile() {
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# adding init script
	newinitd "${FILESDIR}"/initd-trafficserver trafficserver

}
