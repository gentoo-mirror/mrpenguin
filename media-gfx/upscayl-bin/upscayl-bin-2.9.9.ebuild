EAPI=8
DESCRIPTION="Free and Open Source AI Image Upscaler for Linux, MacOS, and Windows"
HOMEPAGE="https://github.com/upscayl/upscayl"
SRC_URI="https://github.com/upscayl/upscayl/releases/download/v${PV}/upscayl-${PV}-linux.deb
    custom-models? ( mirror+https://github.com/upscayl/custom-models/archive/refs/heads/main.zip -> custom-models.zip )"
RESTRICT="mirror"
LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="~amd64"
QA_PRESTRIPPED="opt/Upscayl/.*"

IUSE="custom-models"

pkg_pretend() {
    if use custom-models; then
        ewarn "WARNING: Custom-models are ~300MB in size. This will be fetched and included in the installation."
        einfo "Fetching custom-models.zip...."
    fi
}

DEPEND="
    sys-apps/coreutils
    app-arch/tar
    custom-models? ( app-arch/unzip )
"

RDEPEND="
    !<media-gfx/upscayl-bin-${PV}
    sys-apps/coreutils
    app-arch/tar
    net-libs/nodejs
    dev-libs/nss
    media-libs/openjpeg
    media-libs/vips
    x11-libs/gtk+
"

S="${WORKDIR}"

src_unpack() {
    unpack ${A}
    ar x "${DISTDIR}/upscayl-${PV}-linux.deb"
    tar -xJpf data.tar.xz -C "${S}"
    if use custom-models; then
        unzip -nj -d "${S}"/opt/Upscayl/resources/models "${DISTDIR}"/custom-models.zip
    fi
}

src_install() {
    insinto /opt
    cp -r "${S}"/opt/* "${D}/opt/"

    insinto /usr/share/doc/upscayl-bin-${PV}
    gunzip "${S}/usr/share/doc/upscayl/changelog.gz"
    doins "${S}/usr/share/doc/upscayl/changelog"
    rm -r "${S}/usr/share/doc/upscayl"

    insinto /usr
    doins -r "${S}"/usr/*
    exeinto /usr/bin
    newexe "${S}/opt/Upscayl/resources/bin/upscayl-bin" upscayl-cli
}

pkg_postinst() {
    if use custom-models; then
        ewarn "!!!!!!!!!!!!!!!!!!!!!!"
        einfo "NOTICE: 'Custom Model Path' needs to be set."
        einfo "Settings -> Add custom models"
        einfo "Set to '/opt/Upscayl/resources/models'"
    fi
}
